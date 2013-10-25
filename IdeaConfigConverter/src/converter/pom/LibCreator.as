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

		private static const MANUAL_INSTALL_COMMAND : String = "mvn install:install-file -DgroupId=${groupId} -DartifactId=${artifactId} -Dversion=${version} -Dpackaging=swc -Dfile=${artifactId}-${version}.swc";

		public static function createLibrary(project : Project) : void {
			var libsDirectory1 : File = new File(project.getDirectoryForLibrariesURL());
			if (!libsDirectory1.exists) {
				libsDirectory1.createDirectory();
			}
			var libsDirectory2 : File = libsDirectory1.resolvePath(Lib.GROUP_ID);
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
			var manualInstalls : Vector.<String> = new Vector.<String>();
			for each(var lib : Lib in libs) {
				var libDirectory2 : File = libsDirectory2.resolvePath(lib.artifactID);
				libDirectory2.createDirectory();

				var metadataString : String = METADATA_LIB_XML.toXMLString();
				metadataString = addGroupAndArtifactID(metadataString, lib);
				var metadataFile : File = libDirectory2.resolvePath("maven-metadata-local.xml");
				FileHelper.writeFile(metadataFile, metadataString);

				var libFilesDirectory : File = libDirectory2.resolvePath(VERSION);
				libFilesDirectory.createDirectory();

				var filesName : String = lib.artifactID + "-" + VERSION;

				var manualInstall : String = addGroupAndArtifactID(MANUAL_INSTALL_COMMAND, lib);
				var libPomString : String = POM_LIB_XML.toXMLString();
				libPomString = addGroupAndArtifactID(libPomString, lib);
				libPomString = StringUtil.replace(libPomString, "${description}", manualInstall);
				var pomFile : File = libFilesDirectory.resolvePath(filesName + ".gradle");
				FileHelper.writeFile(pomFile, libPomString);

				var swc : File = libFilesDirectory.resolvePath(filesName + ".swc");
				lib.file.copyTo(swc);

				manualInstalls.push("cd " + libsDirectory1.getRelativePath(libFilesDirectory));
				manualInstalls.push(manualInstall);
				manualInstalls.push("cd ../../../");
			}
			FileHelper.writeFile(libsDirectory1.resolvePath("icc-generated-manual-install.sh"), (new <String>["#!/bin/sh"]).concat(manualInstalls).join("\n"));
			FileHelper.writeFile(libsDirectory1.resolvePath("icc-generated-manual-install.bat"), manualInstalls.join("\r"));
		}

		private static function addGroupAndArtifactID(libPomString : String, lib : Lib) : String {
			return StringUtil.replaceByMap(libPomString, {"${groupId}": lib.groupID, "${artifactId}": lib.artifactID, "${version}": VERSION});
		}
	}
}
