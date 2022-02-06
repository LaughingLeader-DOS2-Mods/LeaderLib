package controls.hotbar
{
	import flash.display.MovieClip;
	
	public dynamic class BrowseButtonDownBG extends MovieClip
	{
		public function BrowseButtonDownBG()
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
