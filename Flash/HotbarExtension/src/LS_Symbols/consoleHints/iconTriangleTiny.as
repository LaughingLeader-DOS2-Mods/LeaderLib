package LS_Symbols.consoleHints
{
	import flash.display.MovieClip;
	
	public dynamic class iconTriangleTiny extends MovieClip
	{

		public function iconTriangleTiny()
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
