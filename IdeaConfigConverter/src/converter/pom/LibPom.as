package converter.pom {
	import converter.FileHelper;
	import converter.StringUtil;
	import converter.dom.Module;
	import converter.dom.Project;

	import flash.filesystem.File;

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
			addIncludeAsToIgnore(result);
			return result;
		}

		private function addIncludeAsToIgnore(result : XML) : void {
			var sourceDirectory : File = iml.directory.resolvePath(Module.DEFAULT_SOURCE_DIRECTORY);
			var files : Vector.<File> = FileHelper.findFiles(sourceDirectory, /(.*)\.as$/i);
			//var nonValidAS : Vector.<String> = new Vector.<String>();
			for each(var file : File in files) {
				var string : String = FileHelper.readFile(file);
				if (string.indexOf("package") < 0) {
					var path : String = sourceDirectory.getRelativePath(file);
					var name : String = StringUtil.replace(path, "/", ".").substr(0, -3);
					//nonValidAS.push(path);
					result.*::build.*::plugins.*::plugin.*::configuration.*::includeClasses.*::scan.*::excludes.aaa += (<exclude>{name}</exclude>);
					log(this, "skipping: " + name);
				}
			}
		}
	}
}
