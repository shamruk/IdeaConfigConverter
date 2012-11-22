package converter {
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class Iml {

		public static const OUTPUT_TYPE_APPLICATION : String = "Application";
		public static const OUTPUT_TYPE_LIBRARY : String = "Library";
		public static const OUTPUT_TYPE_RUNTIME : String = "...";

		private var _file : File;
		private var _relativePath : String;
		private var _content : XML;
		private var _info : String;
		private var _type : String;
		private var _configurationXML : XML;
		private var _dependedLibs : Vector.<String>;
		private var _outputType : String;
		private var _name : String;
		private var _flashPlayerVersion : String;
		private var _dependenciesXML : XML;
		private var _sdkVersion : String;
		private var _moduleType : String;
		private var _relativeDirectoryPath : String;

		public function Iml(baseDirectory : File, file : File) {
			_file = file;
			_relativePath = baseDirectory.getRelativePath(file);
			_relativeDirectoryPath = baseDirectory.getRelativePath(file.parent);
		}

		public function get relativePath() : String {
			return _relativePath;
		}

		public function get relativeDirectoryPath() : String {
			return _relativeDirectoryPath;
		}

		public function get directory() : File {
			return _file.parent;
		}

		public function get dependedModules() : Vector.<String> {
			var moduleNames : XMLList = content.component.orderEntry.(@type == "module").attribute("module-name");
			return Iml.xmlListToVector(moduleNames);
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

		private function get dependedLibs() : Vector.<String> {
			return _dependedLibs ||= xmlListToVector(content.component.orderEntry.(@type == "library").attribute("name"));
		}

		public function get type() : String {
			return _type ||= configurationXML.attribute("pure-as") == "true" ? "AS" : "Flex";
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

		public static function xmlListToVector(xmlList : XMLList) : Vector.<String> {
			var strings : Vector.<String> = new Vector.<String>();
			for each(var item : String in xmlList) {
				strings.push(String(item));
			}
			return strings;
		}
	}
}
