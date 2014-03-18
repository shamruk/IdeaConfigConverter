package converter.dom {
	import converter.FileHelper;

	import flash.filesystem.File;

	public class ModuleRoots {

		private var roots : Vector.<ModuleRoot>;

		public function ModuleRoots(directory : File) {
			loadProjectRoots(directory);
		}

		private function loadProjectRoots(directory : File) : void {
			var files : Vector.<File> = FileHelper.findFiles(directory, "gradleProject.xml");
			var projectMainRoot : File = directory;
			roots = new Vector.<ModuleRoot>();
			for each(var file : File in files) {
				var folder : File = file.parent;
				if (folder.url == projectMainRoot.url) {
					projectMainRoot = null;
				}
				var xml : XML = XML(FileHelper.readFile(file));
				roots.push(new ModuleRoot(folder, xml));
			}
			if (projectMainRoot) {
				roots.push(new ModuleRoot(projectMainRoot));
			}
		}

		public function findRoot(folder : File) : ModuleRoot {
			var minRank : uint = uint.MAX_VALUE;
			var bestRoot : ModuleRoot;
			for each(var root : ModuleRoot in roots) {
				var relativePath : String = root.directory.getRelativePath(folder);
				var same : Boolean = root.directory.url == folder.url;
				if (relativePath || same) {
					var rank : uint = same ? 0 : relativePath.split("/").length + 1;
					if (rank < minRank) {
						minRank = rank;
						bestRoot = root;
					}
				}
			}
			return bestRoot;
		}
	}
}
