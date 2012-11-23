package converter.pom {
	import converter.FileHelper;
	import converter.dom.Lib;
	import converter.dom.Module;
	import converter.dom.Project;

	import flash.filesystem.File;

	public class LibCreator {

		[Embed(source="/../resources/extLib/pom.xml", mimeType="application/octet-stream")]
		private static const POM_LIB_DATA : Class;
		private static const POM_LIB_XML : XML = XML(new POM_LIB_DATA);

		[Embed(source="/../resources/extLib/maven-metadata-local.xml", mimeType="application/octet-stream")]
		private static const METADATA_LIB_DATA : Class;
		private static const METADATA_LIB_XML : XML = XML(new METADATA_LIB_DATA);

		private static const VERSION : String = "current";

		public static function createLibrary(project : Project) : void {
			var libsDirectory : File = new File(project.getDirectoryForLibrariesURL());
			if (!libsDirectory.exists) {
				libsDirectory.createDirectory();
			}
			var libs : Object = {};
			for each(var module : Module in project.modules) {
				for each(var moduleLib : Lib in module.dependedLibs) {
					libs[moduleLib.id] = moduleLib;
				}
			}
			for each(var lib : Lib in libs) {
				var libDirectory : File = new File(libsDirectory.url + "/" + lib.groupID);
				if (libDirectory.exists) {
					libDirectory.deleteDirectory(true);
				}
				libDirectory.createDirectory();

				var metadataString : String = METADATA_LIB_XML.toXMLString();
				metadataString = lib.addGroupAndArtifactID(metadataString);
				var metadataFile : File = new File(libDirectory.url + "/maven-metadata-local.xml");
				FileHelper.writeFile(metadataFile, metadataString);

				var libFilesDirectory : File = new File(libDirectory.url + "/" + VERSION);
				libFilesDirectory.createDirectory();

				var filesName : String = lib.artifactID + "-" + VERSION;

				var libPomString : String = POM_LIB_XML.toXMLString();
				libPomString = lib.addGroupAndArtifactID(libPomString);
				var pomFile : File = new File(libFilesDirectory.url + "/" + filesName + ".xml");
				FileHelper.writeFile(pomFile, libPomString);

				lib.file.copyTo(new File(libFilesDirectory.url + "/" + filesName + ".swc"));
			}
		}
	}
}
