package LS_Symbols.consoleHints
{
	import flash.display.MovieClip;
	
	public dynamic class iconRB extends MovieClip
	{

		public function iconRB()
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
