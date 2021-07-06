package
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class Ability extends MovieClip
	{
		public var hl_mc:MovieClip;
		public var icon_mc:MovieClip;
		public var label_txt:TextField;
		public var min_mc:MovieClip;
		public var plus_mc:MovieClip;
		public var val_txt:TextField;

		//LeaderLib Changes
		public var id:uint;
		//Custom non-standard talents
		public var customID:String;
		public var isCustom:Boolean = false;
		
		public function Ability()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function selectElement() : *
		{
			this.hl_mc.visible = true;
			if(!this.isCustom)
			{
				ExternalInterface.call(this,"selectAbility", this.id);
			}
			else
			{
				ExternalInterface.call(this,"selectCustomAbility", this.customID);
			}
		}
		
		public function deselectElement() : *
		{
			this.hl_mc.visible = false;
		}
		
		public function frame1() : * {}
	}
}
