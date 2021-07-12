package Controls.Buttons
{
	import flash.display.MovieClip;

	public dynamic class CloseButtonBG extends MovieClip
	{
		public function CloseButtonBG()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		private function frame1() : *
		{
			stop();
		}
	}
}