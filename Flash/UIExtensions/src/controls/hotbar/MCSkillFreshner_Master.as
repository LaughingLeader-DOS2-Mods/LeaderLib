package controls.hotbar
{
	import flash.display.MovieClip;
	
	public dynamic class MCSkillFreshner_Master extends MovieClip
	{
		public function MCSkillFreshner_Master()
		{
			super();
			addFrameScript(0,this.frame1,73,this.frame74);
		}
		
		public function frame1() : *
		{
			this.stop();
		}
		
		public function frame74() : *
		{
			this.stop();
			this.visible = false;
		}
	}
}
