package converter.pom {
	import converter.dom.Module;
	import converter.dom.Project;

	public class LibPom extends BasePom implements IPom {

		[Embed(source="/../resources/lib.pom", mimeType="application/octet-stream")]
		private static const POM_LIB_DATA : Class;
		private static const POM_LIB_XML : XML = XML(new POM_LIB_DATA);

		public function LibPom(project : Project, iml : Module) {
			super(project, iml);
		}

		override public function getXML() : XML {
			var template : String = POM_LIB_XML.toXMLString();
			template = replaceBasicVars(template);
			var result : XML = XML(template);
			addStuffToResultXML(result);
			return result;
		}
	}
}
