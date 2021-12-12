package LS_Symbols.consoleHints
{
	import flash.display.MovieClip;
	
	public dynamic class iconSquare extends MovieClip
	{

		public function iconSquare()
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
