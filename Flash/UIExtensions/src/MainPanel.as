package
{
	import LS_Classes.listDisplay;
	import flash.display.MovieClip;
	
	public dynamic class MainPanel extends MovieClip
	{
		public var list:listDisplay;

		public function MainPanel()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		function frame1() : *
		{
			list = new listDisplay();
			this.addChild(list);
		}
	}
}