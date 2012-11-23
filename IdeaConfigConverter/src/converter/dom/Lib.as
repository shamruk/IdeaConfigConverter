package converter.dom {
	import converter.FileHelper;
	import converter.StringUtil;

	import flash.filesystem.File;

	public class Lib {

		private var _name : String;
		private var _file : File;
		private var _id : String;
		private var _artifactID : String;
		public static const GROUP_ID : String = "icc-generated";

		public function Lib(name : String, file : File) {
			_name = name;
			_file = file;
		}

		public function toString() : String {
			return id;
		}

		public function get groupID() : String {
			return GROUP_ID;
		}

		public function get artifactID() : String {
			var delimiter : String = "-";
			return _artifactID ||= id.split(".").join(delimiter).split("_").join(delimiter).split(" ").join(delimiter).split("/").join(delimiter).split(":").join(delimiter).toLowerCase();
		}

		public function get id() : String {
			return _id ||= getID();
		}

		private function getID() : String {
			var fileName : String = _file.name.substring(0, _file.name.lastIndexOf("."));
			return _name + "." + fileName;
		}

		public function get name() : String {
			return _name;
		}

		public function get file() : File {
			return _file;
		}

		private static function cleanPath(url : String) : String {
			return StringUtil.replaceFromMany(url, new <String>["file://", "jar://", "!/"], "");
		}

		public static function resolveFileFromInternalDependably(url : String, directory : File, intLibXML : XML) : Vector.<Lib> {
			url = cleanPath(url);
			url = StringUtil.replace(url, "$MODULE_DIR$", directory.url);
			return getFiles(url, intLibXML.library.@name);
		}

		public static function fromProjectLibraryFile(project : Project, file : File) : Vector.<Lib> {
			var xml : XML = XML(FileHelper.readFile(file));
			var url : String = xml.library.CLASSES.root.@url;
			url = cleanPath(url);
			url = StringUtil.replace(url, "$PROJECT_DIR$", project.directory.url);
			return getFiles(url, xml.library.@name);
		}

		private static function getFiles(url : String, name : String) : Vector.<Lib> {
			var libFile : File = new File(url);
			var libs : Vector.<Lib> = new Vector.<Lib>();
			if (!libFile.exists) {
				trace("error");
				return libs;
			}
			var files : Array = libFile.isDirectory ? libFile.getDirectoryListing() : [libFile];
			for each(var fileLib : File in files) {
				libs.push(new Lib(name, fileLib));
			}
			return libs;
		}
	}
}
