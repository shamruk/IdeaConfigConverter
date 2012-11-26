package converter.pom {
	import converter.FileHelper;
	import converter.StringUtil;
	import converter.dom.Lib;
	import converter.dom.Module;
	import converter.dom.Project;

	import flash.filesystem.File;

	public class LibPom extends BasePom implements IPom {

		[Embed(source="/../resources/lib/pom.xml", mimeType="application/octet-stream")]
		private static const POM_LIB_DATA : Class;
		private static const POM_LIB_XML : XML = XML(new POM_LIB_DATA);

		[Embed(source="/../resources/addExtraSource.pom", mimeType="application/octet-stream")]
		private static const ADD_EXTRA_SOURCE_DATA : Class;
		private static const ADD_EXTRA_SOURCE_XML : XML = XML(new ADD_EXTRA_SOURCE_DATA);

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
			addExtraConfig(result);
			addExtraSource(result);
			return result;
		}

		private function addExtraSource(result : XML) : void {
			if (!iml.sourceDirectoryURLs.length) {
				log(this, "warn");
				return;
			}
			if (iml.sourceDirectoryURLs.length == 1 && iml.sourceDirectoryURLs[0] == Module.DEFAULT_SOURCE_DIRECTORY) {
				return;
			}
			const pre : String = "${basedir}/";
			var xml : XML = ADD_EXTRA_SOURCE_XML.copy();
			for each(var source : String in iml.sourceDirectoryURLs) {
				if (source != Module.DEFAULT_SOURCE_DIRECTORY) {
					xml.executions.execution.configuration.sources.appendChild(<source>{pre + source}</source>);
				}
			}
			result.*::build.*::plugins.appendChild(xml);
		}

		private function addExtraConfig(result : XML) : void {
			var file : File = iml.directory.resolvePath("extraPomConfig.xml");
			if (!file.exists) {
				return;
			}
			var xml : XML = XML(FileHelper.readFile(file));
			for each(var xmlNode : XML in xml.children()) {
				result.*::build.*::plugins.*::plugin.*::configuration.appendChild(xmlNode);
			}
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
