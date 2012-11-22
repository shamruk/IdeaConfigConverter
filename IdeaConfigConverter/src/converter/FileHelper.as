package converter {
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class FileHelper {

		public static function findFiles(baseDirectory : File, namePattern : *, includeSudirectories : Boolean = true) : Vector.<File> {
			var files : Vector.<File> = new Vector.<File>();
			if (!baseDirectory.isDirectory) {
				return files;
			}
			var directoryListing : Array = baseDirectory.getDirectoryListing();
			for each (var file : File in directoryListing) {
				if (file.name.match(namePattern)) {
					files.push(file);
				}
				if (includeSudirectories && file.isDirectory) {
					files = files.concat(findFiles(file, namePattern, includeSudirectories));
				}
			}
			return files;
		}

		public static function readFile(file : File) : String {
			var stream : FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			var string : String = stream.readUTFBytes(file.size);
			stream.close();
			return string;
		}
	}
}
