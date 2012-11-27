package converter.dom {
	public class ModuleDependency {

		public static const TYPE_LOADED : String = "Loaded";
		public static const TYPE_INCLUDE : String = "Include";
		public static const TYPE_MERGED : String = "Merged";
		public static const TYPE_EXTERNAL : String = "External";

		public var moduleID : String;
		public var type : String;

		public function ModuleDependency(moduleID : String, type : String) {
			this.moduleID = moduleID;
			this.type = type;
		}

		public function toString() : String {
			return moduleID + " (" + type + ")";
		}
	}
}
