package Controls
{
	import flash.display.MovieClip;
	
	public dynamic class apUnit extends MovieClip
	{
		public function apUnit()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function frame1() : *
		{
			this.stop();
		}
	}
}
