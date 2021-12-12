package LS_Symbols.consoleHints
{
	import flash.display.MovieClip;
	
	public dynamic class iconCircle extends MovieClip
	{

		public function iconCircle()
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
