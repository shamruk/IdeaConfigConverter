package converter.dom {
	import converter.FileHelper;

	import flash.filesystem.File;

	public class ModuleRoots {

		private var roots : Vector.<ModuleRoot>;

		public function ModuleRoots(directory : File) {
			loadProjectRoots(directory);
		}

		private function loadProjectRoots(directory : File) : void {
			var files : Vector.<File> = FileHelper.findFiles(directory, "pomProject.xml");
			var projectMainRoot : File = directory;
			roots = new Vector.<ModuleRoot>();
			for each(var file : File in files) {
				var folder : File = file.parent;
				if (folder == projectMainRoot) {
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
				if (relativePath) {
					var rank : uint = relativePath.split("/").length;
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
