package
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class CustomStat extends MovieClip
	{
		 
		
		public var hl_mc:MovieClip;
		
		public var label_txt:TextField;
		
		public var line_mc:MovieClip;
		
		public var val_txt:TextField;
		
		public function CustomStat()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function selectElement() : *
		{
			this.hl_mc.visible = true;
			ExternalInterface.call("selectCustomStat",this.id);
		}
		
		public function deselectElement() : *
		{
			this.hl_mc.visible = false;
		}
		
		function frame1() : *
		{
		}
	}
}
