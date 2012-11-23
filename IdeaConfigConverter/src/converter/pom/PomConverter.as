package converter.pom {
	import converter.FileHelper;
	import converter.dom.Module;
	import converter.dom.Project;

	import flash.filesystem.File;
	import flash.utils.Dictionary;

	public class PomConverter {

		public function convert(project : Project) : void {
			LibCreator.createLibrary(project);
			saveProjectPoms(project);
		}

		private function saveProjectPoms(project : Project) : void {
			var swcs : Dictionary = new Dictionary();
			for each(var module : Module in project.modules) {
				if (module.moduleType == "Flex") {
					if (module.outputType == Module.OUTPUT_TYPE_LIBRARY) {
						swcs[module] = new LibPom(module);
					}
				}
			}
			savePoms([new RootPom(project, new <Dictionary>[swcs])]);
			savePoms(swcs);
		}

		private function savePoms(poms : *) : void {
			for each(var pom : IPom in poms) {
				var file : File = new File(pom.getFilePath());
				FileHelper.writeFile(file, pom.data);
			}
		}
	}
}