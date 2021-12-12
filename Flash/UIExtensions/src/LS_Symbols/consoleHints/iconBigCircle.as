package LS_Symbols.consoleHints
{
	import flash.display.MovieClip;
	
	public dynamic class iconBigCircle extends MovieClip
	{

		public function iconBigCircle()
		{
			super();
			this.addFrameScript(0,this.frame1);
		}
		
		public function frame1() : *
		{
			this.stop();
		}
	}
}
