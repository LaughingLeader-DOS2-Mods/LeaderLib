package controls.hotbar
{
	import flash.display.MovieClip;
	
	public dynamic class BrowseButtonUpBG extends MovieClip
	{
		public function BrowseButtonUpBG()
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
