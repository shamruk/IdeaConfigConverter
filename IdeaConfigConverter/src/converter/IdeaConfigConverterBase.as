package converter {
	import converter.dom.Module;
	import converter.dom.Project;
	import converter.pom.PomConverter;

	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.net.SharedObject;

	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.managers.DragManager;

	import spark.components.WindowedApplication;

	public class IdeaConfigConverterBase extends WindowedApplication {

		[Bindable]
		public var imlsArrayCollection : ArrayCollection;

		[Bindable]
		public var selectedIml : Module;

		[Bindable]
		public var lastOpened : File;

		protected var project : Project;

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
	}
}
