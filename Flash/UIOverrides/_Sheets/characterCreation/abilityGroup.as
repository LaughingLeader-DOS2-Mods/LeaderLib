package
{
	import LS_Classes.listDisplay;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class abilityGroup extends MovieClip
	{
		public var listContainer_mc:MovieClip;
		public var title_txt:TextField;
		public var value_txt:TextField;
		public var root_mc:MovieClip;
		public var abilities:listDisplay;
		
		public function abilityGroup()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onInit(param1:MovieClip) : *
		{
			this.root_mc = param1;
			this.title_txt.wordWrap = this.title_txt.multiline = false;
			this.title_txt.autoSize = TextFieldAutoSize.LEFT;
			this.abilities = new listDisplay();
			this.listContainer_mc.addChild(this.abilities);
		}
		
		public function setTitle(param1:String) : *
		{
			this.title_txt.htmlText = param1;
		}
		
		public function addAbility(abilityID:uint, label:String, value:int, delta:int, isCivil:Boolean) : *
		{
			var ability_mc:MovieClip = this.abilities.getElementByNumber("abilityID",abilityID);
			if(!ability_mc)
			{
				ability_mc = new abilEntry();
				ability_mc.onInit(this.root_mc,this.root_mc.CCPanel_mc.abilities_mc.onPlus,this.root_mc.CCPanel_mc.abilities_mc.onMin);
				this.abilities.addElement(ability_mc,false);
				ability_mc.abilityID = abilityID;
				ability_mc.isCivil = isCivil;
				ability_mc.scrollList = this.ownerList;
			}
			ability_mc.setAbility(label,value,delta);
			ability_mc.isUpdated = true;
		}

		public function addCustomAbility(customID:String, label:String, value:int, delta:int, isCivil:Boolean) : *
		{
			var ability_mc:MovieClip = this.abilities.getElementByString("customID",customID);
			if(!ability_mc)
			{
				ability_mc = new abilEntry();
				ability_mc.onInit(this.root_mc,this.root_mc.CCPanel_mc.abilities_mc.onPlus,this.root_mc.CCPanel_mc.abilities_mc.onMin);
				this.abilities.addElement(ability_mc,false);
				ability_mc.customID = customID;
				ability_mc.isCustom = true;
				ability_mc.isCivil = isCivil;
				ability_mc.scrollList = this.ownerList;
			}
			ability_mc.setAbility(label,value,delta);
			ability_mc.isUpdated = true;
		}
		
		public function calculateTotalVal() : *
		{
			var ability_mc:MovieClip = null;
			var total:uint = 0;
			for each(ability_mc in this.abilities.content_array)
			{
				total = total + ability_mc.value;
			}
			this.value_txt.htmlText = String(total);
		}
		
		private function frame1() : * {}
	}
}
