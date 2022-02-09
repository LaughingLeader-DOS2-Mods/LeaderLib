package controls.dropdowns
{
	import flash.display.MovieClip;
	import flash.text.TextField;

	public dynamic class TopHeader extends MovieClip
	{
		public var label_txt:TextField;
		public var bg_mc:MovieClip;

		public function TopHeader()
		{
			super();
		}

		public function resize(xPos:Number, yPos:Number, w:Number):void
		{
			this.bg_mc.width = w;
			this.x = xPos;
			this.y = yPos - this.bg_mc.height - 2;
			this.label_txt.width = w;
		}

		public function setText(text:String):void
		{
			this.label_txt.htmlText = text;
		}
	}
}