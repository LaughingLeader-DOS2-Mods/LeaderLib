package controls.hotbar
{
	import flash.display.MovieClip;
	
	public dynamic class HotBarButtonActiveBG extends MovieClip
	{
		public function HotBarButtonActiveBG()
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
