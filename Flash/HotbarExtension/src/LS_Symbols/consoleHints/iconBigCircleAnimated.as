package LS_Symbols.consoleHints
{
	import flash.display.MovieClip;
	
	public dynamic class iconBigCircleAnimated extends MovieClip
	{

		public function iconBigCircleAnimated()
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
