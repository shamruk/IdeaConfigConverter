package converter.pom {
	import converter.FileHelper;
	import converter.StringUtil;
	import converter.dom.Module;
	import converter.dom.Project;

	import flash.filesystem.File;

	public class LibPom extends BasePom implements IPom {

		[Embed(source="/../gradle/lib.gradle", mimeType="application/octet-stream")]
		private static const POM_LIB_DATA : Class;
		private static const POM_LIB : String = String(new POM_LIB_DATA);

		public function LibPom(project : Project, iml : Module) {
			super(project, iml);
		}

		override public function getData() : String {
			var template : String = POM_LIB;
			template = replaceBasicVars(template);
			template = addStuffToResultXML(template);
			template = addIncludeAsToIgnore(template);
			return template;
		}

		private function addIncludeAsToIgnore(result : String) : String {
			var hasSkips:Boolean=false;
			var sourceDirectory : File = iml.directory.resolvePath(Module.DEFAULT_SOURCE_DIRECTORY);
			var files : Vector.<File> = FileHelper.findFiles(sourceDirectory, /(.*)\.as$/i);
			//var nonValidAS : Vector.<String> = new Vector.<String>();
			for each(var file : File in files) {
				var string : String = FileHelper.readFile(file);
				if (string.indexOf("package") < 0) {
					var path : String = sourceDirectory.getRelativePath(file);
					var name : String = StringUtil.replace(path, "/", ".").substr(0, -3);
					//nonValidAS.push(path);
					// todo: result.*::build.*::plugins.*::plugin.*::configuration.*::includeClasses.*::scan.*::excludes.aaa += (<exclude>{name}</exclude>);
					log(this, "skipping: " + name);
					hasSkips=true;
				}
			}
			result = StringUtil.replace(result, "${source.directory.hasSkips.enabler}", hasSkips?"":"//");
			return result;
		}
	}
}
