package converter.pom {
	import converter.StringUtil;
	import converter.dom.Module;
	import converter.dom.Project;

	public class AppPom extends BasePom implements IPom {

		[Embed(source="/../resources/app/pom.xml", mimeType="application/octet-stream")]
		private static const POM_DATA : Class;
		private static const POM_XML : XML = XML(new POM_DATA);

		public function AppPom(project : Project, iml : Module) {
			super(project, iml);
		}

		override public function getXML() : XML {
			var template : String = POM_XML.toXMLString();
			template = replaceBasicVars(template);
			template = addMainClass(template);
			var result : XML = XML(template);
			addStuffToResultXML(result);
			return result;
		}

		private function addMainClass(template : String) : String {
			var splitted : Array = iml.mainClass.split(".");
			var name : String = splitted.pop();
			template = StringUtil.replaceByMap(template, {"${source.file.directory}":splitted.join("/"), "${source.file.name}":name});
			return template;
		}
	}
}
