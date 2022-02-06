package controls.hotbar
{
	import flash.display.MovieClip;
	
	public dynamic class HotBarButtonBG extends MovieClip
	{
		public function HotBarButtonBG()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function frame1() : *
		{
			stop();
		}
	}
}
