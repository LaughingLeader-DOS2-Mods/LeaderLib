package controls.scrollbar
{
	import flash.display.MovieClip;
	
	public dynamic class scrollBgBig_id extends MovieClip
	{
		public function scrollBgBig_id()
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
