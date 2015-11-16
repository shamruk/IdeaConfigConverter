package converter {
	import converter.dom.Module;
	import converter.dom.Project;
	import converter.pom.PomConverter;

	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.SharedObject;

	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.managers.DragManager;

	import spark.components.WindowedApplication;

	public class IdeaConfigConverterBase extends WindowedApplication {

		[Embed(source="/../resources/info.txt", mimeType="application/octet-stream")]
		private static const INFO_DATA : Class;
		private static const INFO : String = String(new INFO_DATA);

		[Bindable]
		public var imlsArrayCollection : ArrayCollection;

		[Bindable]
		public var selectedIml : Module;

		[Bindable]
		public var lastOpened : File;

		[Bindable]
		public var log : String = "";

		public const info : String = INFO;

		[Bindable]
		public var project : Project;

		private const _converter : PomConverter = new PomConverter();

		protected function onDragIn(e : NativeDragEvent) : void {
			if (e.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) {
				var files : Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				if (files.length == 1 && File(files[0]).isDirectory) {
					DragManager.acceptDragDrop(this);
				}
			}
//			else if(e.clipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)){
//				DragManager.acceptDragDrop(this);
//			}
		}

		protected function convertAndSave() : void {
			_converter.convertAndSave(project)
		}

		protected function onDragDrop(e : NativeDragEvent) : void {
			var arr : Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			openProject(arr[0]);
		}

		protected function openProject(directory : File) : void {
			if (!directory.resolvePath(".idea").exists) {
				Alert.show("not an idea root directory");
				return;
			}
			project = new Project(directory);
			var ac : ArrayCollection = new ArrayCollection();
			for each(var module : Module in project.modules) {
				ac.addItem(module);
			}
			imlsArrayCollection = ac;
			setLastOpened(directory);
		}

		protected static function getLastOpened() : File {
			var lastOpened : File;
			try {
				var so : SharedObject = SharedObject.getLocal("IdeaConfigConverter");
				var file : File = new File(so.data["lastOpenedProject"]);
				if (file.exists) {
					lastOpened = file;
				}
			} catch (e : *) {
			}
			return lastOpened;
		}

		protected function browseProjectFolder() : void {
			var folder : File = new File();
			folder.addEventListener(Event.SELECT, onBrowse);
			folder.browseForDirectory("Select Project directory");
		}

		private function onBrowse(event : Event) : void {
			var folder : File = event.currentTarget as File;
			openProject(folder);
		}

		private function setLastOpened(folder : File) : void {
			lastOpened = folder;
			try {
				var so : SharedObject = SharedObject.getLocal("IdeaConfigConverter");
				so.data["lastOpenedProject"] = folder.url;
				so.flush();
			} catch (e : *) {
			}
		}

		private static var instance : IdeaConfigConverterBase;

		public function IdeaConfigConverterBase() {
			instance = this;
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
		}

		private function onInvoke(event : InvokeEvent) : void {
			var args : Array = event.arguments;
			if (args.length) {
				var file : File = new File(args[0]);
				if (file.exists) {
					openProject(file);
					convertAndSave();
					NativeApplication.nativeApplication.exit(0);
				} else {
					if (args[1]) {
						var fileStream : FileStream = new FileStream();
						fileStream.open(new File(args[1]), FileMode.WRITE);
						fileStream.writeUTF("no file: " + args[0]);
						fileStream.writeUTF("\n");
						fileStream.close();
					}
					NativeApplication.nativeApplication.exit(6);
				}
			}
		}

		public static function addLog(text : String) : void {
			instance.log += text + "\n";
		}
	}
}
