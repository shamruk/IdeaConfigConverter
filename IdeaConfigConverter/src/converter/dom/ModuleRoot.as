package converter.dom {

    import flash.filesystem.File;

    public class ModuleRoot {

//		private static const DEF_MAIN_ROOT_XML : XML =
//				<project>
//					<groupId>icc-module-gen</groupId>
//					<artifactId>icc-root</artifactId>
//					<version>current</version>
//				</project>;

		private var _directory : File;
		private var _xml : XML;

		public function ModuleRoot(directory : File, xml : XML = null) {
			_directory = directory;
			_xml = xml || new XML();
		}

		public function get directory() : File {
			return _directory;
		}

		public function get xml() : XML {
			return _xml;
		}

		public function get groupID() : String {
			return _xml.groupId || "icc-module-gen";
		}

		public function get version() : String {
			return _xml.version || "current";
		}

		public function get artifactID() : String {
			return _xml.artifactId || "icc-root";
		}

		public function get flashPlayerVersion() : String {
			return _xml.flashPlayerVersion;
		}

		public function get sdkVersion() : String {
			return _xml.flexSdkVersion;
		}

		public function get gradleFXVersion() : String {
			return _xml.gradleFxVersion || "0.8.2";
		}

		public function get flexSDKVersion() : String {
			return _xml.flexSdkVersion || "4.12.0";
		}

		public function get airSDKVersion() : String {
			return _xml.airSdkVersion || "4.0";
		}

		public function get playerVersion() : String {
			return _xml.flashPlayerVersion || "12.0";
		}

		public function get playerSWFVersion() : String {
			return _xml.flashSWFVersion || "14";
		}

		public function get skipModules() : Array {
			return (_xml.skipModules || "").split(",");
		}

		public function get storepass() : String {
			return _xml.storepass || "";
		}

		public function get platforms() : XML {
			return _xml.platforms.length() ? _xml.platforms[0] : null;
		}

        public function get repositories() : XML {
            return _xml.repositories.length() ? _xml.repositories[0] : null;
        }

	}
}
