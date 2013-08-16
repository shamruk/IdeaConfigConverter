package converter.pom {
	import converter.FileHelper;
	import converter.StringUtil;
	import converter.dom.Lib;
	import converter.dom.Module;
	import converter.dom.ModuleDependency;
	import converter.dom.Project;

	import flash.errors.IllegalOperationError;
	import flash.filesystem.File;

	public class BasePom {

		[Embed(source="/../resources/addExtraSource.pom", mimeType="application/octet-stream")]
		private static const ADD_EXTRA_SOURCE_DATA : Class;
		private static const ADD_EXTRA_SOURCE_XML : XML = XML(new ADD_EXTRA_SOURCE_DATA);

		[Embed(source="/../resources/flexDependency.pom", mimeType="application/octet-stream")]
		private static const FLEX_DEPENDENCE_DATA : Class;
		private static const FLEX_DEPENDENCE_XML : XML = XML(new FLEX_DEPENDENCE_DATA);

		[Embed(source="/../resources/namespace.xml", mimeType="application/octet-stream")]
		private static const NAMESPACE_DATA : Class;
		private static const NAMESPACE_XML : XML = XML(new NAMESPACE_DATA);

		[Embed(source="/../resources/includeSources.xml", mimeType="application/octet-stream")]
		private static const INCLUDE_SOURCES_DATA : Class;
		private static const INCLUDE_SOURCES_XML : XML = XML(new INCLUDE_SOURCES_DATA);

		//private static const GROUP_ID : String = "icc-module-gen";
		//private static const MODULE_VERSION : String = "current";

		private var _iml : Module;
		private var _data : String;
		private var _project : Project;

		public function BasePom(project : Project, iml : Module) {
			_project = project;
			_iml = iml;
		}

		public function get project() : Project {
			return _project;
		}

		public function get data() : String {
			return _data ||= getXML().toXMLString();
		}

		public function getXML() : XML {
			throw new IllegalOperationError();
		}

		public function get iml() : Module {
			return _iml;
		}

		protected function getFullSDKVersion(sdkVersion : String) : String {
			return "4.6.b.23201";
//			return sdkVersion == "4.5.1" ? sdkVersion + ".21328" : sdkVersion;
		}

		public function getFilePath() : String {
			return iml.pomDirectory.url + "/pom.xml";
		}

		private function addExtraSource(result : XML) : void {
			if (!iml.sourceDirectoryURLs.length) {
				log(this, "warn");
				return;
			}
			if (iml.sourceDirectoryURLs.length == 1 && iml.sourceDirectoryURLs[0] == Module.DEFAULT_SOURCE_DIRECTORY) {
				return;
			}
			const pre : String = "${basedir}/";
			var xml : XML = ADD_EXTRA_SOURCE_XML.copy();
			for each(var source : String in iml.sourceDirectoryURLs) {
				if (source != Module.DEFAULT_SOURCE_DIRECTORY) {
					xml.executions.execution.configuration.sources.appendChild(<source>{pre + source}</source>);
				}
			}
			result.*::build.*::plugins.appendChild(xml);

		}

		private function addExtraConfig(result : XML) : void {
			addExtraConfigFrom(project.directory.resolvePath("extraPomConfig.xml"), result);
			addExtraConfigFrom(iml.directory.resolvePath("extraPomConfig.xml"), result);
		}

		private function addExtraConfigFrom(file : File, result : XML) : void {
			if (!file.exists) {
				return;
			}
			var xml : XML = XML(FileHelper.readFile(file));
			addPlugingConfiguration(xml, result);
		}

		private function addPlugingConfiguration(from : XML, to : XML) : void {
			for each(var xmlNode : XML in from.children()) {
				to.*::build.*::plugins.*::plugin.*::configuration.appendChild(xmlNode);
			}
		}

		private static const DEPENDENCY_TYPE_TO_SCOPE : Object = {};
		{
//			DEPENDENCY_TYPE_TO_SCOPE[ModuleDependency.TYPE_MERGED] = "merged";
//			DEPENDENCY_TYPE_TO_SCOPE[ModuleDependency.TYPE_INCLUDE] = "internal";
			DEPENDENCY_TYPE_TO_SCOPE[ModuleDependency.TYPE_EXTERNAL] = "external";
		}

		private function addDependencies(result : XML) : void {
			for each(var moduleDependency : ModuleDependency in iml.dependedModules) {
				if (moduleDependency.type == ModuleDependency.TYPE_LOADED) {
					continue;
				}
				var scope : String = DEPENDENCY_TYPE_TO_SCOPE[moduleDependency.type];
				var module : Module = project.findModuleByName(moduleDependency.moduleID);
				var dependencyXML : XML = <dependency>
					<groupId>{module.groupID}</groupId>
					<artifactId>{moduleDependency.moduleID}</artifactId>
					<version>{module.version}</version>
					<type>swc</type>
				</dependency>;
				if (scope) {
					dependencyXML.appendChild(<scope>{scope}</scope>)
				}
				result.*::dependencies.dependency += dependencyXML;
			}
			for each(var decadencyLib : Lib in iml.dependedLibs) {
				var dependencyLibXML : XML = <dependency>
					<groupId>{decadencyLib.groupID}</groupId>
					<artifactId>{decadencyLib.artifactID}</artifactId>
					<version>{LibCreator.VERSION}</version>
					<type>swc</type>
				</dependency>;
				result.*::dependencies.dependency += dependencyLibXML;
			}
			if (iml.type == Module.TYPE_FLEX) {
				var dep : String = replaceBasicVars(FLEX_DEPENDENCE_XML.toXMLString());
				result.*::dependencies.dependency += XML(dep).children();
			}
		}

		protected function replaceBasicVars(template : String) : String {
			var fullSDKVersion : String = getFullSDKVersion(iml.sdkVersion);
			var fileName : String = iml.outputFile.substr(0, iml.outputFile.lastIndexOf("."));

			var srcPath : String = "../../" + iml.moduleRoot.directory.getRelativePath(iml.directory.resolvePath(Module.DEFAULT_SOURCE_DIRECTORY));

			return StringUtil.replaceByMap(template, {
				"${flex.framework.version}": fullSDKVersion,
				"${flash.player.version}": iml.flashPlayerVersion,
				"${artifactId}": iml.name,
				"${groupId}": iml.groupID,
				"${version}": iml.version,
				"${source.directory.main}": srcPath,
				"${repository.local.generated.url}": project.getDirectoryForLibrariesURL(iml.pomDirectory, iml.moduleRoot.directory),
				"${out.output.directory}": getTempOutput(iml),
				"${out.directory}": getOutputDirectory(iml),
				"${out.file}": fileName,
				"${ns_uri}": iml.namespaceURI,
				"${ns_location}": iml.namespaceLocation
			});
		}

		private function getOutputDirectory(module : Module) : String {
			var file : File = module.directory.resolvePath(module.outputDirectory);
			var a : String = project.directory.getRelativePath(file);
			var b : String = project.directory.getRelativePath(module.pomDirectory);
			var c : String = b.replace(/[\w\d\.]+/g, "..") + "/" + a;
			return  c;
		}

		private function getTempOutput(module : Module) : String {
			return module.pomDirectory.getRelativePath(project.directory, true) + "/out/maven-temp";
		}

		protected function addStuffToResultXML(result : XML) : void {
			addDependencies(result);
			addNamespaces(result);
			addIncludeSources(result);
			addExtraConfig(result);
			addExtraSource(result);
		}

		private function addNamespaces(result : XML) : void {
			if( iml.namespaceURI){
				var namespaceConfiguration : String = replaceBasicVars(NAMESPACE_XML.toXMLString());
				addPlugingConfiguration(XML(namespaceConfiguration), result);
			}
		}

		private function addIncludeSources(result : XML) : void {
			if( iml.namespaceURI){
				var includeConfiguration : String = replaceBasicVars(INCLUDE_SOURCES_XML.toXMLString());
				addPlugingConfiguration(XML(includeConfiguration), result);
			}
		}
	}
}
