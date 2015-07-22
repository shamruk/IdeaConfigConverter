package converter.pom {
	import converter.StringUtil;
	import converter.dom.Module;
	import converter.dom.Project;

	import flash.filesystem.File;

	public class AppPom extends BasePom implements IPom {

		[Embed(source="/../gradle/app.gradle", mimeType="application/octet-stream")]
		private static const POM_DATA : Class;
		private static const POM : String = String(new POM_DATA);

		public function AppPom(project : Project, iml : Module) {
			super(project, iml);
		}

		override public function getData() : String {
			var template : String = POM;
			template = replaceBasicVars(template);
			template = addMainClass(template);
			template = addStuffToResultXML(template);
			template = replace(template, "${type}", iml.targetPlatform == Module.TARGET_PLATFORM_MOBILE ? "mobile" : "swf");
			template = replace(template, "${source.io.certificate}", iml.pomDirectory.getRelativePath(iml.getCerteficate("ios"), true));
			template = replace(template, "${source.an.certificate}", iml.pomDirectory.getRelativePath(iml.getCerteficate("android"), true));
			template = replace(template, "${source.am.certificate}", iml.pomDirectory.getRelativePath(iml.getCerteficate("android"), true));
			template = replace(template, "${source.provision}", iml.pomDirectory.getRelativePath(iml.provision, true));
			template = replace(template, "${source.io.keystoreType}", iml.getKeystoreType("ios"));
			template = replace(template, "${source.an.keystoreType}", iml.getKeystoreType("android"));
			template = replace(template, "${source.am.keystoreType}", iml.getKeystoreType("android"));
			template = replace(template, "${source.io.descriptor}", iml.pomDirectory.getRelativePath(iml.getDescriptor("ios"), true));
			template = replace(template, "${source.an.descriptor}", iml.pomDirectory.getRelativePath(iml.getDescriptor("android"), true));
			template = replace(template, "${source.am.descriptor}", iml.pomDirectory.getRelativePath(iml.getDescriptor("android"), true));
			template = replace(template, "${storepass}", project.projectModuleRoot.storepass);
			template = replace(template, "${source.io.resources}", formatMobileResources(iml.getMobileResources("ios")));
			template = replace(template, "${source.an.resources}", formatMobileResources(iml.getMobileResources("android")));
			template = replace(template, "${source.am.resources}", formatMobileResources(iml.getMobileResources("android")));
			return template;
		}

		private function replace(template : String, from : String, to : String) : String {
			if (from.match(/\$\{source\...\./)) {
				var pl : String = from.substr("${source.".length, 2);
				var replaceXML : XMLList = project.projectModuleRoot.platforms[pl].replace.(@from == from);
				if (replaceXML.length()) {
					to = replaceXML.@to;
				}
			}
			return StringUtil.replace(template, from, to);
		}

		private function formatMobileResources(mobileResources : Object) : String {
			var result : Array = [];
			for (var res : String in mobileResources) {
				result.push("'-C', '" + mobileResources[res] + "', '" + res + "'");
			}
			result.sort();
			return result.join(",\n");
		}

		private function addMainClass(template : String) : String {
			var splitted : Array = iml.mainClass.split(".");
			var name : String = splitted.pop();
			var main : String = splitted.join("/");
			if (main) {
				main += "/";
			}
			var possibleMXML : File = iml.directory.resolvePath(iml.sourceDirectoryURLs[0]).resolvePath(main).resolvePath(name + ".mxml");
			name += possibleMXML.exists ? ".mxml" : ".as";
			template = StringUtil.replaceByMap(template, {
				"${source.file.directory}": main,
				"${source.file.name}": name
			});
			return template;
		}
	}
}
