package converter {
	public class StringUtil {

		public static function replace(string : String, from : String, to : String) : String {
			return string.split(from).join(to);
		}

		public static function replaceByMap(string : String, map : Object) : String {
			for (var from : String in map) {
				string = replace(string, from, map[from]);
			}
			return string;
		}

		public static function replaceFromMany(string : String, froms : Vector.<String>, to : String) : String {
			for each(var from : String in froms) {
				string = replace(string, from, to);
			}
			return string;
		}
	}
}
