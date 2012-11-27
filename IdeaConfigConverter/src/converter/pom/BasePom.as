package converter.pom {
	import converter.FileHelper;
	import converter.StringUtil;
	import converter.dom.Lib;
	import converter.dom.Module;
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

		private static const GROUP_ID : String = "icc-module-gen";

		private static const MODULE_VERSION : String = "current";

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
			return sdkVersion == "4.5.1" ? sdkVersion + ".21328" : sdkVersion;
		}

		public function getFilePath() : String {
			return iml.directory.url + "/pom.xml";
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
			for each(var xmlNode : XML in xml.children()) {
				result.*::build.*::plugins.*::plugin.*::configuration.appendChild(xmlNode);
			}
		}

		private function addDependencies(result : XML) : void {
			for each(var decadencyString : String in iml.dependedModules) {
				var dependencyXML : XML = <dependency>
					<groupId>{GROUP_ID}</groupId>
					<artifactId>{decadencyString}</artifactId>
					<version>{MODULE_VERSION}</version>
					<type>swc</type>
				</dependency>;
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
			return StringUtil.replaceByMap(template, {
				"${flex.framework.version}":fullSDKVersion,
				"${flash.player.version}":iml.flashPlayerVersion,
				"${artifactId}":iml.name,
				"${groupId}":GROUP_ID,
				"${version}":MODULE_VERSION,
				"${source.directory.main}":Module.DEFAULT_SOURCE_DIRECTORY,
				"${repository.local.generated.url}":project.getDirectoryForLibrariesURL()
			});
		}

		protected function addStuffToResultXML(result : XML) : void {
			addDependencies(result);
			addExtraConfig(result);
			addExtraSource(result);
		}
	}
}
