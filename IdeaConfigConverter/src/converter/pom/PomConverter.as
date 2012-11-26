package converter.pom {
	import converter.FileHelper;
	import converter.dom.Module;
	import converter.dom.Project;

	import flash.filesystem.File;
	import flash.utils.Dictionary;

	public class PomConverter {

		public function convertAndSave(project : Project) : void {
			LibCreator.createLibrary(project);
			saveProjectPoms(project);
		}

		private function saveProjectPoms(project : Project) : void {
			var swcs : Dictionary = new Dictionary();
			for each(var module : Module in project.modules) {
				if (isSupported(module)) {
					if (module.outputType == Module.OUTPUT_TYPE_LIBRARY) {
						swcs[module] = new LibPom(project, module);
					} else {
						log(this, "unknown output type: " + module.outputType);
					}
				}
			}
			savePoms([new RootPom(project, new <Dictionary>[swcs])]);
			savePoms(swcs);
		}

		private function isSupported(module : Module) : Boolean {
			if (module.moduleType != "Flex") {
				log(this, "not flex module: " + module.name);
				return false;
			}
			if (module.flashPlayerVersion == "11.5") {
				log(this, "not flex FP in module: " + module.name);
				return false;
			}
			return true;
		}

		private function savePoms(poms : *) : void {
			for each(var pom : IPom in poms) {
				var file : File = new File(pom.getFilePath());
				FileHelper.writeFile(file, pom.data);
			}
		}
	}
}