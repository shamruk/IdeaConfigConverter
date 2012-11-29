package converter.dom {
	import converter.FileHelper;
	import converter.StringUtil;

	import flash.filesystem.File;

	public class Project {

		private var _directory : File;
		private var _modules : Vector.<Module>;
		public var projectLibs : Vector.<Lib>;
		private var _moduleRoots : ModuleRoots;

		public function Project(directory : File) {
			_directory = directory;
			_moduleRoots = new ModuleRoots(directory);
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
				var moduleURL : String = StringUtil.replace(modulePath, "$PROJECT_DIR$", directory.url);
				var file : File = new File(moduleURL);
				var moduleRoot : ModuleRoot = _moduleRoots.findRoot(file.parent);
				_modules.push(new Module(this, file, moduleRoot));
			}
		}

		private function getIdeaConfigXML(configName : String) : XML {
			return XML(FileHelper.readFile(directory.resolvePath(".idea/" + configName + ".xml")));
		}

		private function loadModulesFromDirectory() : void {
			var files : Vector.<File> = FileHelper.findFiles(directory, /(.*)\.iml$/i);
			for each(var file : File in files) {
				var moduleRoot : ModuleRoot = _moduleRoots.findRoot(file.parent);
				modules.push(new Module(this, file, moduleRoot));
			}
		}

		public function get modules() : Vector.<Module> {
			return _modules;
		}

		public function get directory() : File {
			return _directory;
		}

		public function get moduleRoots() : ModuleRoots {
			return _moduleRoots;
		}

		public function getLibByName(name : String) : Vector.<Lib> {
			return projectLibs.filter(function (lib : Lib, ...args) : Boolean {
				return name == lib.name;
			});
		}

		public function getDirectoryForLibrariesURL(file : File = null) : String {
			return (file ? file.getRelativePath(directory, true) : directory.url) + "/MavenExternalLibs";
		}

		public function findModuleByName(moduleID : String) : Module {
			for each(var module : Module in _modules) {
				if (module.name == moduleID) {
					return module;
				}
			}
			return null;
		}
	}
}
