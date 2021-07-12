package Controls.Buttons
{
	import flash.display.MovieClip;

	public dynamic class MinimizeButtonBG extends MovieClip
	{
		public function MinimizeButtonBG()
		{
			super();
			this.addFrameScript(0,this.frame1);
		}
		
		private function frame1() : *
		{
			stop();
		}
	}
}