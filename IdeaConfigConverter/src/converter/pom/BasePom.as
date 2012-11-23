package converter.pom {
	import converter.dom.Module;
	import converter.dom.Project;

	import flash.errors.IllegalOperationError;

	public class BasePom {

		private var _iml : Module;
		private var _data : String;
		private var _project : Project;

		public function BasePom(project : Project, iml : Module) {
			_project = project;
			_iml = iml;
		}

		public function get project() : Project {
			return _project;
		}

		public function get data() : String {
			return _data ||= getXML().toXMLString();
		}

		public function getXML() : XML {
			throw new IllegalOperationError();
		}

		public function get iml() : Module {
			return _iml;
		}

		protected function getFullSDKVersion(sdkVersion : String) : String {
			return sdkVersion == "4.5.1" ? sdkVersion + ".21328" : sdkVersion;
		}

		public function getFilePath() : String {
			return iml.directory.url + "/pom.xml";
		}
	}
}
