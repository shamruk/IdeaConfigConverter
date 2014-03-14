package converter.dom {
	import converter.FileHelper;
	import converter.StringUtil;

	import flash.filesystem.File;

	public class Module {

		public static const TYPE_AS : String = "AS";
		public static const TYPE_FLEX : String = "Flex";

		public static const OUTPUT_TYPE_APPLICATION : String = "Application";
		public static const OUTPUT_TYPE_LIBRARY : String = "Library";
		public static const OUTPUT_TYPE_RUNTIME : String = "...";

		public static const TARGET_PLATFORM_DESKTOP : String = "Desktop";
		public static const TARGET_PLATFORM_MOBILE : String = "Mobile";

		public static const DEFAULT_SOURCE_DIRECTORY : String = "src";

		private var _file : File;
		private var _relativePath : String;
		private var _content : XML;
		private var _info : String;
		private var _type : String;
		private var _configurationXML : XML;
		private var _dependedLibs : Vector.<Lib>;
		private var _outputType : String;
		private var _name : String;
		private var _flashPlayerVersion : String;
		private var _dependenciesXML : XML;
		private var _sdkVersion : String;
		private var _moduleType : String;
		private var _relativeDirectoryPath : String;
		private var _project : Project;
		private var _sourceDirectoryURLs : Vector.<String>;
		private var _mainClass : String;
		private var _targetPlatform : String;
		private var _outputDirectory : String;
		private var _outputFile : String;
		private var _dependedModules : Vector.<ModuleDependency>;
		public var moduleRoot : ModuleRoot;
		private var _configurationID : uint;
		private var _artifactID : String;

		public function Module(project : Project, file : File, moduleRoot : ModuleRoot, configurationID : uint) {
			_project = project;
			_file = file;
			this.moduleRoot = moduleRoot;
			_configurationID = configurationID;
		}

		public function get relativePath() : String {
			return _relativePath ||= _project.directory.getRelativePath(_file);
		}

		public function get relativeDirectoryPath() : String {
			return _relativeDirectoryPath ||= _project.directory.getRelativePath(_file.parent);
		}

		public function get relativePomDirecoryPath() : String {
			return _project.directory.getRelativePath(pomDirectory);
		}


		public function get directory() : File {
			return _file.parent;
		}

		public function get dependedModules() : Vector.<ModuleDependency> {
			return _dependedModules ||= getDependedModules();
//			return Module.xmlListToVector(content.component.orderEntry.(@type == "module").attribute("module-name"));
		}

		public function getDependedModules() : Vector.<ModuleDependency> {
			var moduleDependencies : Vector.<ModuleDependency> = new Vector.<ModuleDependency>();
			for each(var entry : XML in configurationXML.dependencies.entries.entry.(attribute("module-name").length())) {
				moduleDependencies.push(new ModuleDependency(entry.attribute("build-configuration-name"), entry.dependency.@linkage));
			}
			return moduleDependencies;
		}

		public function get content() : XML {
			return _content ||= readFileContent();
		}

		private function readFileContent() : XML {
			return XML(FileHelper.readFile(_file));
		}

		public function get info() : String {
			return _info ||= readInfo();
		}

		private function readInfo() : String {
			var result : Vector.<String> = new Vector.<String>();
			result.push("\tName:");
			result.push(name);
			result.push("\tType:");
			result.push(type);
			result.push("\tOutput type:");
			result.push(outputType);
			result.push("\tPath:");
			result.push(relativePath);
			result.push("\tDepends on modules:");
			result.push(dependedModules.join('\n'));
			result.push("\tDepends on libs:");
			result.push(dependedLibs.join('\n'));
			result.push("\tFlash player:");
			result.push(flashPlayerVersion);
			//result.push(_moduleRoot.xml.groupId);
			return result.join("\n");
		}


		public function get name() : String {
			return _name ||= configurationXML.attribute("name");
		}

		public function get artifactID() : String {
			return _artifactID ||= StringUtil.replaceFromMany(name, new <String>[".", "_", " ", "/", ":"], "-").toLowerCase();
		}

		public function get dependedLibs() : Vector.<Lib> {
			return _dependedLibs ||= getDependedLibs();
		}

		private function getDependedLibs() : Vector.<Lib> {
			var libs : Vector.<Lib> = new Vector.<Lib>();
			for each(var extLibXML : XML in content.component.orderEntry.(@type == "library")) {
				libs = libs.concat(_project.getLibByName(extLibXML.@name));
			}
			for each(var intLibXML : XML in content.component.orderEntry.(@type == "module-library")) {
				libs = libs.concat(Lib.resolveFileFromInternalDependably(intLibXML.library.CLASSES.root.@url, directory, intLibXML));
			}
			return libs;
		}

		public function get type() : String {
			return _type ||= configurationXML.attribute("pure-as") == "true" ? TYPE_AS : TYPE_FLEX;
		}

		public function get configurationXML() : XML {
			return _configurationXML ||= getConfigurationsXML(content)[_configurationID];
		}

		public static function getConfigurationsXML(xml : XML) : XMLList {
			return xml.component.configurations.configuration;
		}

		public function get dependenciesXML() : XML {
			return _dependenciesXML ||= configurationXML.dependencies[0];
		}

		public function get outputType() : String {
			return _outputType ||= configurationXML.attribute("output-type");
		}

		public function getOptionValue(key : String) : String {
			return content.component.option.(@name == key).@value;
		}

		public function get flashPlayerVersion() : String {
			return moduleRoot.flashPlayerVersion;
//			return _flashPlayerVersion ||= dependenciesXML.attribute("target-player");
		}

		public function get sdkVersion() : String {
			return moduleRoot.sdkVersion;
//			return _sdkVersion ||= dependenciesXML.sdk.@name;
		}

		public function get moduleType() : String {
			return _moduleType ||= content.@type;
		}

		public function get mainClass() : String {
			return _mainClass ||= configurationXML.attribute("main-class");
		}

		public function get targetPlatform() : String {
			return _targetPlatform ||= configurationXML.attribute("target-platform") || TARGET_PLATFORM_DESKTOP;
		}

		public function get outputDirectory() : String {
			return _outputDirectory ||= StringUtil.replace(configurationXML.attribute("output-folder"), "$MODULE_DIR$/", "");
		}

		public function get outputFile() : String {
			return _outputFile ||= configurationXML.attribute("output-file");
		}

		public function get sourceDirectoryURLs() : Vector.<String> {
			return _sourceDirectoryURLs ||= getSourceDirectoryURLs();
		}

		private function getSourceDirectoryURLs() : Vector.<String> {
			var sources : Vector.<String> = new Vector.<String>();
			for each(var source : String in content.component.content.sourceFolder.@url) {
				sources.push(StringUtil.replace(source, "file://$MODULE_DIR$/", ""));
			}
			return sources;
		}

		public static function xmlListToVector(xmlList : XMLList) : Vector.<String> {
			var strings : Vector.<String> = new Vector.<String>();
			for each(var item : String in xmlList) {
				strings.push(String(item));
			}
			return strings;
		}

		public function get groupID() : String {
			return moduleRoot.groupID;
		}

		public function get version() : String {
			return moduleRoot.version;
		}

		public function get pomDirectory() : File {
			return moduleRoot.directory.resolvePath("poms/" + name);
		}

		public function get namespaceURI() : String {
			for (var namespaceURI : String in namespaces) {
				return namespaceURI;
			}
			return null;
		}

		private function get namespaces() : Object {
			var namespaces : Object = {};
			var entries : XMLList = configurationXML["compiler-options"].map.entry.(@key == "compiler.namespaces.namespace");
			for each(var ns : XML in entries) {
				var nsData : String = ns.@value;
				if (nsData && nsData.length > 0) {
					var splitted : Array = nsData.split("\t");
					namespaces[splitted[0]] = splitted[1];
				}
			}
			return namespaces;
		}

		public function get namespaceLocation() : String {
			for each(var namespaceLocation : String in namespaces) {
				namespaceLocation = namespaceLocation.replace("$MODULE_DIR$/", "");
				return pomDirectory.getRelativePath(directory.resolvePath(namespaceLocation), true);
			}
			return null;
		}

		public function get extraSources() : Array {
			return null;
		}
	}
}
