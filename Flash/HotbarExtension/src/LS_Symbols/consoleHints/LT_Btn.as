package LS_Symbols.consoleHints
{
	import flash.display.MovieClip;
	
	public dynamic class LT_Btn extends MovieClip
	{

		public var bg_mc:iconLT;
		
		public var hl_mc:iconLTHL;
		
		public function LT_Btn()
		{
			super();
			this.addFrameScript(0,this.frame1);
		}
		
		public function showHL() : *
		{
			this.hl_mc.alpha = 1;
			this.hl_mc.visible = true;
			this.bg_mc.visible = false;
			this.hl_mc.x = -10;
		}
		
		public function hideHL() : *
		{
			this.hl_mc.alpha = 0;
			this.hl_mc.visible = false;
			this.bg_mc.visible = true;
			this.hl_mc.x = 0;
		}
		
		public function frame1() : *
		{
		}
	}
}
