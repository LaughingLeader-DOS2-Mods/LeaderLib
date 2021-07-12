package Controls.Bars
{
	import flash.display.MovieClip;
	
	public dynamic class HPBG extends MovieClip
	{
		public function HPBG()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function frame1() : *
		{
			this.stop();
		}
	}
}
