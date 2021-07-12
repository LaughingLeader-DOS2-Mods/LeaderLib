package Controls.Bars
{
	import flash.display.MovieClip;
	
	public dynamic class HPBG extends MovieClip
	{
		public function HPBG()
		{
			super();
			this.addFrameScript(0,this.frame1);
		}
		
		public function frame1() : void
		{
			this.stop();
		}
	}
}
