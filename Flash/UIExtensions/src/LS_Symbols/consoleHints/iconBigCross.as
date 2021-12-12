package LS_Symbols.consoleHints
{
	import flash.display.MovieClip;
	
	public dynamic class iconBigCross extends MovieClip
	{

		public function iconBigCross()
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
