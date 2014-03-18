package converter.pom {
	import converter.StringUtil;
	import converter.dom.ModuleRoot;
	import converter.dom.Project;

	import flash.utils.Dictionary;

	public class RootPom extends BasePom implements IPom {

		[Embed(source="/../gradle/root.gradle", mimeType="application/octet-stream")]
		private static const POM_LIB_DATA : Class;
		private static const POM_LIB : String = String(new POM_LIB_DATA);

		private var _pomPacks : Vector.<Dictionary>;

		public function RootPom(project : Project, pomPacks : Vector.<Dictionary>) {
			super(project, null);
			_pomPacks = pomPacks;
		}

		override public function getData() : String {
			var moduleRoot : ModuleRoot = project.moduleRoots.findRoot(project.directory);
			var template : String = POM_LIB;
			template = StringUtil.replaceByMap(template, {
				"${artifactId}": moduleRoot.artifactID,
				"${groupId}": moduleRoot.groupID,
				"${version}": moduleRoot.version,
				"${gradlefx.version}": moduleRoot.gradleFXVersion,
				"${flex.sdk.version}": moduleRoot.flexSDKVersion,
				"${air.sdk.version}": moduleRoot.airSDKVersion,
				"${player.version}": moduleRoot.playerVersion
			});
//			template=template.replace("${flex.framework.version}", getFullSDKVersion(iml.sdkVersion));
//			template=template.replace("${flash.player.version}", iml.flashPlayerVersion);
//			template=template.replace("${artifactId}", iml.name);
//			for each(var poms : * in _pomPacks) {
//				for each(var pom : IPom in poms) {
//					result.*::modules.module += <module>{pom.iml.relativePomDirecoryPath}</module>;
//				}
//			}
			//template = addExtraConfigFrom(project.directory.resolvePath("extraPomConfig.xml"), template);
			return template;
		}

		override public function getFilePath() : String {
			return project.pomDirectory.url + "/build.gradle";
		}
	}
}
