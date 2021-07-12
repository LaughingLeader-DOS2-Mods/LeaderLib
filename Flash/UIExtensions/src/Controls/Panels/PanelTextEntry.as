package Controls.Panels {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public dynamic class PanelTextEntry extends MovieClip
	{
		public var text_txt:TextField;
		public var list_id:int;
		
		public function PanelTextEntry()
		{
			super();
		}

		public function setText(text:String):void
		{
			this.text_txt.wordWrap = true;
			this.text_txt.htmlText = text;
			this.text_txt.height = this.text_txt.textHeight;
		}
	}
	
}
