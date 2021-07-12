package Controls
{
	import flash.display.MovieClip;
	
	public dynamic class APUnit extends MovieClip
	{
		public function APUnit()
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
