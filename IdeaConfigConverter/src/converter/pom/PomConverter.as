package converter.pom {
	import converter.*;

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.Dictionary;

	public class PomConverter {

		public function convert(imls : Vector.<Iml>) : void {
			var libs : Dictionary = new Dictionary();
			var rootIml : Iml;
			for each(var iml : Iml in imls) {
				if (iml.moduleType != "Flex") {
					rootIml = iml;
				} else if (iml.outputType == Iml.OUTPUT_TYPE_LIBRARY) {
					libs[iml] = new LibPom(iml);
				}
			}
			savePoms([new RootPom(rootIml, new <Dictionary>[libs])]);
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