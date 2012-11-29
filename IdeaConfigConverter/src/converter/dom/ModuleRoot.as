package converter.dom {
	import flash.filesystem.File;

	public class ModuleRoot {

		private static const DEF_MAIN_ROOT_XML : XML =
				<project>
					<groupId>icc-module-gen</groupId>
					<artifactId>icc-root</artifactId>
					<version>current</version>
				</project>;

		private var _directory : File;
		private var _xml : XML;

		public function ModuleRoot(directory : File, xml : XML = null) {
			_directory = directory;
			_xml = xml || DEF_MAIN_ROOT_XML;
		}

		public function get directory() : File {
			return _directory;
		}

		public function get xml() : XML {
			return _xml;
		}

		public function get groupID() : String {
			return _xml.groupId;
		}

		public function get version() : String {
			return _xml.version;
		}
	}
}
