package {
	import flash.filesystem.File;

	public class FileFindHelper {

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
	}
}
