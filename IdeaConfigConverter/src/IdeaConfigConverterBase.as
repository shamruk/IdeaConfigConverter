package {
	import flash.desktop.ClipboardFormats;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;

	import mx.collections.ArrayCollection;
	import mx.managers.DragManager;

	import spark.components.WindowedApplication;

	public class IdeaConfigConverterBase extends WindowedApplication {

		[Bindable]
		public var filesArrayCollection : ArrayCollection;

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

		protected function onDragDrop(e : NativeDragEvent) : void {
			var arr : Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			readBaseDirectory(arr[0]);
		}

		private function readBaseDirectory(directory : File) : void {
			var files : Vector.<File> = FileFindHelper.findFiles(directory, /(.*).iml/i);
			var ac : ArrayCollection = new ArrayCollection();
			for each(var file : File in files) {
				ac.addItem(new Iml(directory, file));
			}
			filesArrayCollection = ac;
		}
	}
}
