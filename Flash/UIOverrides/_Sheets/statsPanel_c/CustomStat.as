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
		//LeaderLib
		public var statID:Number; // Double handle
		public var id:Number; // Set to the statList length
		public var statIndex:int;
		public var tooltip:String;
		public var am:Number;

		public function CustomStat()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function selectElement() : *
		{
			this.hl_mc.visible = true;
			ExternalInterface.call("selectCustomStat", this.statID, this.id);
		}
		
		public function deselectElement() : *
		{
			this.hl_mc.visible = false;
		}

		public function editCustomStat() : *
		{
			ExternalInterface.call("editCustomStat",this.statID, this.id);
		}
		
		public function removeCustomStat() : *
		{
			ExternalInterface.call("removeCustomStat",this.statID, this.id);
		}
		
		public function frame1() : * {}
	}
}
