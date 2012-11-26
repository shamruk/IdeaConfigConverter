package {
	import converter.IdeaConfigConverterBase;

	public function log(where : *, ...what) : void {
		IdeaConfigConverterBase.addLog(where + ": " + what);
	}
}
