package converter.pom {
	import converter.StringUtil;
	import converter.dom.Lib;
	import converter.dom.Module;
	import converter.dom.Project;

	public class LibPom extends BasePom implements IPom {

		[Embed(source="/../resources/lib/pom.xml", mimeType="application/octet-stream")]
		private static const POM_LIB_DATA : Class;
		private static const POM_LIB_XML : XML = XML(new POM_LIB_DATA);

		private static const GROUP_ID : String = "icc-module-gen";
		private static const MODULE_VERSION : String = "current";

		public function LibPom(project : Project, iml : Module) {
			super(project, iml);
		}

		override public function getXML() : XML {
			var fullSDKVersion : String = getFullSDKVersion(iml.sdkVersion);
			var template : String = POM_LIB_XML.toXMLString();
			template = StringUtil.replaceByMap(template, {
				"${flex.framework.version}":fullSDKVersion,
				"${flash.player.version}":iml.flashPlayerVersion,
				"${artifactId}":iml.name,
				"${groupId}":GROUP_ID,
				"${version}":MODULE_VERSION,
				"${repository.local.generated.url}":project.getDirectoryForLibrariesURL()
			});
			var result : XML = XML(template);
			addDependencies(result);
			return result;
		}

		private function addDependencies(result : XML) : void {
			for each(var decadencyString : String in iml.dependedModules) {
				var dependencyXML : XML = <dependency>
					<groupId>{GROUP_ID}</groupId>
					<artifactId>{decadencyString}</artifactId>
					<version>{MODULE_VERSION}</version>
					<type>swc</type>
				</dependency>;
				result.*::dependencies.dependency += dependencyXML;
			}
			for each(var decadencyLib : Lib in iml.dependedLibs) {
				var dependencyLibXML : XML = <dependency>
					<groupId>{decadencyLib.groupID}</groupId>
					<artifactId>{decadencyLib.artifactID}</artifactId>
					<version>{LibCreator.VERSION}</version>
					<type>swc</type>
				</dependency>;
				result.*::dependencies.dependency += dependencyLibXML;
			}
		}
	}
}
