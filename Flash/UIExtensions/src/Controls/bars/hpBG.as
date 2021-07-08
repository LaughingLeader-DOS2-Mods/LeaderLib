package Controls.bars
{
	import flash.display.MovieClip;
	
	public dynamic class hpBG extends MovieClip
	{
		public function hpBG()
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
