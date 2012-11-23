package converter.pom {
	import converter.FileHelper;
	import converter.StringUtil;
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

		public static const VERSION : String = "1.0";

		public static function createLibrary(project : Project) : void {
			var libsDirectory1 : File = new File(project.getDirectoryForLibrariesURL());
			if (!libsDirectory1.exists) {
				libsDirectory1.createDirectory();
			}
			var libsDirectory2 : File = new File(libsDirectory1.url + "/" + Lib.GROUP_ID);
			if (libsDirectory2.exists) {
				libsDirectory2.deleteDirectory(true);
			}
			libsDirectory2.createDirectory();
			var libs : Object = {};
			for each(var module : Module in project.modules) {
				for each(var moduleLib : Lib in module.dependedLibs) {
					libs[moduleLib.id] = moduleLib;
				}
			}
			for each(var lib : Lib in libs) {
				var libDirectory2 : File = new File(libsDirectory2.url + "/" + lib.artifactID);
				libDirectory2.createDirectory();

				var metadataString : String = METADATA_LIB_XML.toXMLString();
				metadataString = addGroupAndArtifactID(metadataString, lib);
				var metadataFile : File = new File(libDirectory2.url + "/maven-metadata-local.xml");
				FileHelper.writeFile(metadataFile, metadataString);

				var libFilesDirectory : File = new File(libDirectory2.url + "/" + VERSION);
				libFilesDirectory.createDirectory();

				var filesName : String = lib.artifactID + "-" + VERSION;

				var libPomString : String = POM_LIB_XML.toXMLString();
				libPomString = addGroupAndArtifactID(libPomString, lib);
				var pomFile : File = new File(libFilesDirectory.url + "/" + filesName + ".pom");
				FileHelper.writeFile(pomFile, libPomString);

				lib.file.copyTo(new File(libFilesDirectory.url + "/" + filesName + ".swc"));
			}
		}

		private static function addGroupAndArtifactID(libPomString : String, lib : Lib) : String {
			return StringUtil.replaceByMap(libPomString, {"${groupId}":lib.groupID, "${artifactId}":lib.artifactID, "${version}":VERSION});
		}
	}
}
