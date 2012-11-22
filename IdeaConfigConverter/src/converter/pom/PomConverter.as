package converter.pom {
	import converter.dom.Module;
	import converter.dom.Project;

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Dictionary;

	public class PomConverter {

		public function convert(project : Project) : void {
			var libs : Dictionary = new Dictionary();
			for each(var iml : Module in project.modules) {
				if (iml.moduleType == "Flex") {
					if (iml.outputType == Module.OUTPUT_TYPE_LIBRARY) {
						libs[iml] = new LibPom(iml);
					}
				}
			}
			savePoms([new RootPom(project, new <Dictionary>[libs])]);
			savePoms(libs);
		}

		private function savePoms(poms : *) : void {
			for each(var pom : IPom in poms) {
				var file : File = new File(pom.getFilePath());
				if (file.exists) {
					file.deleteFile();
				}
				var stream : FileStream = new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeUTFBytes(pom.data);
				stream.close();
			}
		}
	}
}