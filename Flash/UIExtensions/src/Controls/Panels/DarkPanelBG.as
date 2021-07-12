package Controls.Panels
{
	import flash.display.MovieClip;

	public dynamic class DarkPanelBG extends MovieClip
	{
		public function DarkPanelBG()
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