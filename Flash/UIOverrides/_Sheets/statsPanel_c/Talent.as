package
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class Talent extends MovieClip
	{
		public var bullet_mc:MovieClip;
		public var hl_mc:MovieClip;
		public var label_txt:TextField;
		public var min_mc:MovieClip;
		public var plus_mc:MovieClip;

		//LeaderLib Changes
		public var statID:uint;
		//Custom non-standard talents
		public var customID:String;
		public var isCustom:Boolean = false;
		
		public function Talent()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function selectElement() : *
		{
			this.hl_mc.visible = true;
			if(!this.isCustom)
			{
				ExternalInterface.call("selectTalent", this.id);
			}
			else
			{
				ExternalInterface.call("selectCustomTalent", this.customID);
			}
		}
		
		public function deselectElement() : *
		{
			this.hl_mc.visible = false;
		}
		
		public function frame1() : * {}
	}
}
