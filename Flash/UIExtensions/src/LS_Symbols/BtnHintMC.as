package LS_Symbols
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public dynamic class BtnHintMC extends MovieClip
	{
		 
		
		public var icon_mc:BtnHintBlah;
		
		public var text_txt:TextField;
		
		public function BtnHintMC()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function setBtnHint(hintText:String, iconFrame:Number) : *
		{
			var maxTextWidth:Number = 260;
			this.icon_mc.setHintIcon(iconFrame);
			this.text_txt.htmlText = hintText;
			this.text_txt.height = this.text_txt.textHeight + 10;
			this.text_txt.width = this.text_txt.textWidth + 20;
			if(this.text_txt.textWidth > maxTextWidth)
			{
				this.text_txt.width = maxTextWidth;
				this.text_txt.multiline = true;
			}
			this.text_txt.y = 21 - Math.round(this.text_txt.textHeight * 0.5);
			this.text_txt.x = this.icon_mc.x + this.icon_mc.width;
		}
		
		internal function frame1() : *
		{
		}
	}
}
