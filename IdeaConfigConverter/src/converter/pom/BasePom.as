package converter.pom {
	import converter.FileHelper;
	import converter.StringUtil;
	import converter.dom.LibDependency;
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
			return _data ||= getData();
		}

		public function getData() : String {
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
			return iml.pomDirectory.url + "/build.gradle";
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

		private function addExtraConfig(result : String) : String {
			result = addExtraConfigFrom(project.directory.resolvePath("extraGradleConfig.xml"), result);
			result = addExtraConfigFrom(iml.directory.resolvePath("extraGradleConfig.xml"), result);
			return result;
		}

		protected function addExtraConfigFrom(file : File, result : String) : String {
			if (!file.exists) {
				return result;
			}
			var xml : XML = XML(FileHelper.readFile(file));
			for each(var option : XML in xml.additionalCompilerOptions.option) {
				result = result.replace("additionalCompilerOptions = [", "additionalCompilerOptions = [\n\t'" + option.text() + "',");
				result = result.replace("additionalCompilerOptions += [", "additionalCompilerOptions += [\n\t'" + option.text() + "',");
			}
			//addPlugingConfiguration(xml, result);
			return result;
		}

		private function addPlugingConfiguration(from : XML, to : XML) : void {
			for each(var xmlNode : XML in from.children()) {
				to.*::build.*::plugins.*::plugin.*::configuration.appendChild(xmlNode);
			}
		}

		private static const DEPENDENCY_TYPE_TO_SCOPE : Object = {};
		{
			DEPENDENCY_TYPE_TO_SCOPE[ModuleDependency.TYPE_MERGED] = "merged";
			DEPENDENCY_TYPE_TO_SCOPE[ModuleDependency.TYPE_INCLUDE] = "internal";
			DEPENDENCY_TYPE_TO_SCOPE[ModuleDependency.TYPE_EXTERNAL] = "external";
		}

		private function addDependencies(result : String) : String {
			var dependacies : Vector.<String> = new Vector.<String>();
			for each(var moduleDependency : ModuleDependency in iml.dependedModules) {
				if (moduleDependency.type != ModuleDependency.TYPE_LOADED) {
					var scope : String = DEPENDENCY_TYPE_TO_SCOPE[moduleDependency.type];
					var module : Module = project.findModuleByName(moduleDependency.moduleID);
//						<groupId>{module.groupID}</groupId>
//						<artifactId>{moduleDependency.moduleID}</artifactId>
					dependacies.push(scope + " project(':" + module.pomDirectory.name + "')");
				}
			}
			for each(var decadencyLib : LibDependency in iml.dependedLibs) {
//					<groupId>{decadencyLib.groupID}</groupId>
//					<artifactId>{decadencyLib.artifactID}</artifactId>
				var dependencyType : String = DEPENDENCY_TYPE_TO_SCOPE[decadencyLib.linkage];
				dependacies.push(dependencyType + " files('" + iml.pomDirectory.getRelativePath(decadencyLib.lib.file, true) + "')");
			}
			result = result.replace("/*dependencies.gradle*/", dependacies.join("\n\t"));

			// todo: think
			result = result.replace("${frameworkLinkage}", "merged"); // or none
			//result = result.replace("/*frameworkLinkage.disabler*/", iml.type == Module.TYPE_FLEX ? "//" : "");

			result = StringUtil.replace(result, "/*frameworkLinkage.air.enabler*/", !iml.isAIR ? "//" : "");
			return result;
		}

		protected function replaceBasicVars(template : String) : String {
			var fullSDKVersion : String = getFullSDKVersion(iml.sdkVersion);
			var fileName : String = iml.outputFile.substr(0, iml.outputFile.lastIndexOf("."));

			var srcPath : String = "../../" + iml.moduleRoot.directory.getRelativePath(iml.directory.resolvePath(Module.DEFAULT_SOURCE_DIRECTORY));

			var srcPathsArray : Array = [];
			for each(var srcDir : String in iml.sourceDirectoryURLs) {
				if (srcDir.indexOf("include") != 0) {
					srcPathsArray.push("../../" + iml.moduleRoot.directory.getRelativePath(iml.file.parent.resolvePath(srcDir), true))
				}
			}
			var srcPaths : String = srcPathsArray.join("','");

			return StringUtil.replaceByMap(template, {
				"${flex.framework.version}": fullSDKVersion,
				"${flash.player.version}": iml.flashPlayerVersion,
				"${config.directory}": iml.name,
				"${artifactId}": iml.name,
				"${groupId}": iml.groupID,
				"${version}": iml.version,
				"${source.directory.main}": srcPath,
				"${source.directories}": srcPaths,
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
			return c;
		}

		private function getTempOutput(module : Module) : String {
			return module.pomDirectory.getRelativePath(project.directory, true) + "/out/maven-temp";
		}

		protected function addStuffToResultXML(result : String) : String {
			result = addDependencies(result);
			result = addNamespaces(result);
			result = addExtraConfig(result);
			return result;
		}

		private function addNamespaces(result : String) : String {
			if (iml.namespaceURI) {
				//var namespaceConfiguration : String = replaceBasicVars("'-namespace+=${ns_uri},${ns_location} -include-namespaces+=${ns_uri}'");
				// todo: try "'-namespace+=${ns_uri},${projectDir.path}/${ns_location}',"
				var namespaceConfiguration : String = replaceBasicVars("'-namespace+=${ns_uri},'+new File('${ns_location}').absolutePath,");
				result = result.replace("/*namespace_manifest*/", namespaceConfiguration);
				var namespaceInclude : String = replaceBasicVars("'-include-namespaces+=${ns_uri}',");
				result = result.replace("/*namespace_include*/", namespaceInclude);
			}
			return result;
		}

		protected function get includeFileList() : Boolean {
			return true;
			// return iml.namespaceURI;
		}

		// <namespace uri="http://ns.adobe.com/mxml/2009" manifest="${flexHome}/frameworks/mxml-2009-manifest.xml" />
		//library://ns.adobe.com/flex/spark ${flexHome}/frameworks/spark-manifest.xml library://ns.adobe.com/flex/mx ${flexHome}/frameworks/mx-manifest.xml

		private function addIncludeSources(result : XML) : void {
			if (iml.namespaceURI) {
				var includeConfiguration : String = replaceBasicVars(INCLUDE_SOURCES_XML.toXMLString());
				addPlugingConfiguration(XML(includeConfiguration), result);
			}
		}
	}
}
