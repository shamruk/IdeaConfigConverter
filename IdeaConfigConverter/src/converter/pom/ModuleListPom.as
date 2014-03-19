package converter.pom {
	import converter.dom.Project;

	import flash.utils.Dictionary;

	public class ModuleListPom extends BasePom implements IPom {

		private var _pomPacks : Vector.<Dictionary>;

		public function ModuleListPom(project : Project, pomPacks : Vector.<Dictionary>) {
			super(project, null);
			_pomPacks = pomPacks;
		}

		override public function getData() : String {
			var moduleNames : Array = [];
			for each(var poms : * in _pomPacks) {
				for each(var pom : IPom in poms) {
					//result.*::modules.module += <module>{pom.iml.relativePomDirecoryPath}</module>;
					moduleNames.push("'" + pom.iml.pomDirectory.name + "'");
				}
			}
			moduleNames.sort();
			return "include " + moduleNames.join(", ");
		}

		override public function getFilePath() : String {
			return project.pomDirectory.url + "/settings.gradle";
		}
	}
}
