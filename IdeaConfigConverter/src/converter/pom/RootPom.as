package converter.pom {
	import converter.StringUtil;
	import converter.dom.ModuleRoot;
	import converter.dom.Project;

	public class RootPom extends BasePom implements IPom {

		[Embed(source="/../resources/root.pom", mimeType="application/octet-stream")]
		private static const POM_LIB_DATA : Class;
		private static const POM_LIB_XML : XML = XML(new POM_LIB_DATA);

		private var _poms : Vector.<IPom>;

		public function RootPom(project : Project, poms : Vector.<IPom>) {
			super(project, null);
			_poms = poms;
		}

		override public function getXML() : XML {
			var moduleRoot : ModuleRoot = project.moduleRoots.findRoot(project.directory);
			var template : String = POM_LIB_XML.toXMLString();
			template = StringUtil.replaceByMap(template, {
				"${artifactId}":moduleRoot.artifactID,
				"${groupId}":moduleRoot.groupID,
				"${version}":moduleRoot.version
			});
//			template=template.replace("${flex.framework.version}", getFullSDKVersion(iml.sdkVersion));
//			template=template.replace("${flash.player.version}", iml.flashPlayerVersion);
//			template=template.replace("${artifactId}", iml.name);
			var result : XML = XML(template);
			for each(var pom : IPom in _poms) {
				result.*::modules.module += <module>{pom.iml.relativeDirectoryPath}</module>;
			}
			return result;
		}

		override public function getFilePath() : String {
			return project.directory.url + "/pom.xml";
		}
	}
}
