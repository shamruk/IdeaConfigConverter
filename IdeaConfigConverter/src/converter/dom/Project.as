package converter.dom {
	import converter.FileHelper;

	import flash.filesystem.File;

	public class Project {

		private var _directory : File;
		private var _modules : Vector.<Module>;
		public var projectLibs : Vector.<Lib>;

		public function Project(directory : File) {
			_directory = directory;
			loadProjectLibs();
			loadModulesFromIdeaConfig();
		}

		private function loadProjectLibs() : void {
			projectLibs = new Vector.<Lib>();
			var files : Vector.<File> = FileHelper.findFiles(directory.resolvePath(".idea/libraries"), /(.*).xml/i);
			for each(var file : File in files) {
				projectLibs = projectLibs.concat(Lib.fromProjectLibraryFile(this, file));
			}
		}

		private function loadModulesFromIdeaConfig() : void {
			_modules = new Vector.<Module>();
			var modulesXML : XML = getIdeaConfigXML("modules");
			for each(var modulePath : String in modulesXML.component.modules.module.@filepath) {
				var moduleURL : String = modulePath.replace("$PROJECT_DIR$", directory.url);
				var file : File = new File(moduleURL);
				_modules.push(new Module(this, file));
			}
		}

		private function getIdeaConfigXML(configName : String) : XML {
			return XML(FileHelper.readFile(directory.resolvePath(".idea/" + configName + ".xml")));
		}

		private function loadModulesFromDirectory() : void {
			var files : Vector.<File> = FileHelper.findFiles(directory, /(.*).iml/i);
			for each(var file : File in files) {
				modules.push(new Module(this, file));
			}
		}

		public function get modules() : Vector.<Module> {
			return _modules;
		}

		public function get directory() : File {
			return _directory;
		}

		public function getLibByName(name : String) : Vector.<Lib> {
			return projectLibs.filter(function (lib : Lib, ...args) : Boolean {
				return name == lib.name;
			});
		}
	}
}
