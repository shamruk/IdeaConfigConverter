package converter.pom {
	import converter.Iml;

	public class LibPom extends BasePom implements IPom {

		[Embed(source="/../resources/lib/pom.xml", mimeType="application/octet-stream")]
		private static const POM_LIB_DATA : Class;
		private static const POM_LIB_XML : XML = XML(new POM_LIB_DATA);

		public function LibPom(iml : Iml) {
			super(iml);
		}

		override public function getXML() : XML {
			var template : String = POM_LIB_XML.toXMLString();
			var fullSDKVersion : String = getFullSDKVersion(iml.sdkVersion);
			template = template.split("${flex.framework.version}").join(fullSDKVersion);
			template = template.replace("${flash.player.version}", iml.flashPlayerVersion);
			template = template.replace("${artifactId}", iml.name);

			var result : XML = XML(template);

			addDependencies(result);

			return result;
		}

		private function addDependencies(result : XML) : void {
			for each(var decadencyString : String in iml.dependedModules) {
				var dependencyXML : XML = <dependency>
					<groupId>auto.groupId</groupId>
					<artifactId>{decadencyString}</artifactId>
					<version>1.0-SNAPSHOT</version>
					<type>swc</type>
				</dependency>;
				if (result.dependencies.length()) {
					result.dependencies[0].appendChild(dependencyXML);
				} else {
					result.dependencies.dependency += dependencyXML;
				}
			}
		}
	}
}
