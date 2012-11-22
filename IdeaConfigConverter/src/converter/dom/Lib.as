package converter.dom {
	import converter.FileHelper;

	import flash.filesystem.File;

	public class Lib {

		private var _name : String;
		private var _file : File;

		public function Lib(name : String, file : File) {
			_name = name;
			_file = file;
		}

		public function toString() : String {
			return _name + " : " + _file.name;
		}

		public function get name() : String {
			return _name;
		}

		public function get file() : File {
			return _file;
		}

		public static function resolveFileFromInternalDependably(url : String, directory : File) : File {
			url = cleanPath(url);
			url = url.replace("$MODULE_DIR$", directory.url);
			var file : File = new File(url);
			if (!file.exists) {
				trace("error");
			}
			return file;
		}

		private static function cleanPath(url : String) : String {
			url = url.replace("file://", "");
			url = url.replace("jar://", "");
			url = url.replace("!/", "");
			return url;
		}

		public static function fromProjectLibraryFile(project : Project, file : File) : Vector.<Lib> {
			var libs : Vector.<Lib> = new Vector.<Lib>();
			var xml : XML = XML(FileHelper.readFile(file));
			var url : String = xml.library.CLASSES.root.@url;
			url = cleanPath(url);
			url = url.replace("$PROJECT_DIR$", project.directory.url);
			var libFile : File = new File(url);
			if (!libFile.exists) {
				trace("error");
			}
			var files : Array = libFile.isDirectory ? libFile.getDirectoryListing() : [libFile];
			for each(var fileLib : File in files) {
				libs.push(new Lib(xml.library.@name, fileLib));
			}
			return libs;
		}
	}
}
