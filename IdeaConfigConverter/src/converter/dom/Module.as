package converter.dom {
	import converter.StringUtil;

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

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

		public function Module(project : Project, file : File) {
			_project = project;
			_file = file;
		}

		public function get relativePath() : String {
			return _relativePath ||= _project.directory.getRelativePath(_file);
		}

		public function get relativeDirectoryPath() : String {
			return _relativeDirectoryPath ||= _project.directory.getRelativePath(_file.parent);
		}

		public function get directory() : File {
			return _file.parent;
		}

		public function get dependedModules() : Vector.<String> {
			var moduleNames : XMLList = content.component.orderEntry.(@type == "module").attribute("module-name");
			return Module.xmlListToVector(moduleNames);
		}

		public function get content() : XML {
			return _content ||= readFileContent();
		}

		private function readFileContent() : XML {
			var fileStream : FileStream = new FileStream();
			fileStream.open(_file, FileMode.READ);
			var data : String = fileStream.readUTFBytes(fileStream.bytesAvailable);
			fileStream.close();
			return XML(data);
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
			return result.join("\n");
		}

		public function get name() : String {
			return _name ||= _file.name.substring(0, _file.name.indexOf(".iml"));
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
			return _configurationXML ||= content.component.configurations.configuration[0];
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
			return _flashPlayerVersion ||= dependenciesXML.attribute("target-player");
		}

		public function get sdkVersion() : String {
			return _sdkVersion ||= dependenciesXML.sdk.@name;
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
	}
}
