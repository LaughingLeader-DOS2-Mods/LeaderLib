package LS_Symbols.consoleHints
{
	import flash.display.MovieClip;
	
	public dynamic class iconStart extends MovieClip
	{

		public function iconStart()
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
