package LS_Symbols.consoleHints
{
	import flash.display.MovieClip;
	
	public dynamic class iconLB extends MovieClip
	{

		public function iconLB()
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
