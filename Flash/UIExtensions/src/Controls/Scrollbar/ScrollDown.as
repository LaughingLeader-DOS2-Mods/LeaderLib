package Controls.Scrollbar
{
	import flash.display.MovieClip;
	
	public dynamic class ScrollDown extends MovieClip
	{
		public function ScrollDown()
		{
			super();
			this.addFrameScript(0,this.frame1,1,this.frame2,2,this.frame3);
		}
		
		private function frame1() : *
		{
			stop();
		}
		
		private function frame2() : *
		{
			stop();
		}
		
		private function frame3() : *
		{
			stop();
		}
	}
}
