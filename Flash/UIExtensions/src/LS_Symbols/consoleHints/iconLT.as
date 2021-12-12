package LS_Symbols.consoleHints
{
	import flash.display.MovieClip;
	
	public dynamic class iconLT extends MovieClip
	{

		public function iconLT()
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
