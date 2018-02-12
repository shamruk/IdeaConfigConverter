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
			var moduleRoot : ModuleRoot = project.projectModuleRoot;
			var template : String = POM_LIB;
			template = StringUtil.replaceByMap(template, {
				"${artifactId}": moduleRoot.artifactID,
				"${groupId}": moduleRoot.groupID,
				"${version}": moduleRoot.version,
				"${gradlefx.version}": moduleRoot.gradleFXVersion,
				"${flex.sdk.version}": moduleRoot.flexSDKVersion,
				"${air.sdk.version}": moduleRoot.airSDKVersion,
				"${player.version}": moduleRoot.playerVersion,
				"${player.swfversion}": moduleRoot.playerSWFVersion
			});
			if (moduleRoot.platforms) {
				template = StringUtil.replace(template, "//${platform_options}", generateByPlatforms(moduleRoot.platforms.children()));
			}
            if (moduleRoot.repositories) {
                template = StringUtil.replace(template, "//${repositories}", generateByRepositories(moduleRoot.repositories.children()));
            }
            if (moduleRoot.pluginRepositories) {
                template = StringUtil.replace(template, "//${plugin_repositories}", generateByRepositories(moduleRoot.pluginRepositories.children()));
            }
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

		private function generateByPlatforms(platforms : XMLList) : String {
			var result : Array = [];
			for each(var xml : XML in platforms) {
				if (xml.compileOptions.length()) {
					result.push('case "' + xml.name() + '":');
					result.push("additionalCompilerOptions += [");
					result.push("'" + String(xml.compileOptions.text()).split(" ").join("',\n'") + "'");
					result.push("]");
					result.push("break;");
				}
			}
			return result.join("\n");
		}

        private function generateByRepositories(repositories : XMLList) : String {
            var result : Array = [];
            for each (var repo : XML in repositories) {
                var config : String = "\t\tivy {\n";
                config += "\t\t\tname '" + repo.@name + "'\n";
                config += "\t\t\tartifactPattern '" + repo.@pattern + "'\n";
                config += "\t\t}";
                result.push(config);
            }
            return result.join("\n");
        }

		override public function getFilePath() : String {
			return project.pomDirectory.url + "/build.gradle";
		}
	}
}
