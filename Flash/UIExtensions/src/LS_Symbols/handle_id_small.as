package LS_Symbols
{
	import flash.display.MovieClip;
	
	public dynamic class handle_id_small extends MovieClip
	{
		 
		
		public function handle_id_small()
		{
			super();
			addFrameScript(0,this.frame1,1,this.frame2,2,this.frame3);
		}
		
		internal function frame1() : *
		{
			stop();
		}
		
		function frame2() : *
		{
			stop();
		}
		
		function frame3() : *
		{
			stop();
		}
	}
}
