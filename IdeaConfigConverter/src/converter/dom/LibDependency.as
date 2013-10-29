package converter.dom {
	public class LibDependency {
		private var _lib : Lib;
		private var _linkage : String;
		public function LibDependency(lib : Lib, linkage : String) {
			_lib = lib;
			_linkage = linkage;
		}

		public function get lib() : Lib {
			return _lib;
		}

		public function get linkage() : String {
			return _linkage;
		}
	}

}
