package Controls.Buttons
{
	import flash.display.MovieClip;
	
	public dynamic class ButtonBG extends MovieClip
	{
		public function ButtonBG()
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