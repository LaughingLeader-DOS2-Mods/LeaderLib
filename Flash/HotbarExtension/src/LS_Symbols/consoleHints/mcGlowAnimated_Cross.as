package LS_Symbols.consoleHints
{
	import flash.display.MovieClip;
	
	public dynamic class mcGlowAnimated_Cross extends MovieClip
	{

		public function mcGlowAnimated_Cross()
		{
			super();
			this.addFrameScript(0,this.frame1,92,this.frame93);
		}
		
		public function frame1() : *
		{
			this.gotoAndPlay("start");
		}
		
		public function frame93() : *
		{
			this.gotoAndPlay("start");
		}
	}
}
