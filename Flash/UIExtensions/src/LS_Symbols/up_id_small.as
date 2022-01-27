package LS_Symbols
{
	import flash.display.MovieClip;
	
	public dynamic class up_id_small extends MovieClip
	{
		public function up_id_small()
		{
			super();
			addFrameScript(0,this.frame1,1,this.frame2,2,this.frame3);
		}
		
		public function frame1() : *
		{
			this.stop();
		}
		
		public function frame2() : *
		{
			this.stop();
		}
		
		public function frame3() : *
		{
			this.stop();
		}
	}
}
