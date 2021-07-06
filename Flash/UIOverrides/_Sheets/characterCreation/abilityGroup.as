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
		
		public function addAbility(statID:*, label:String, value:int, delta:int, isCivil:Boolean, isCustom:Boolean=false) : *
		{
			var ability_mc:MovieClip = !isCustom ? this.abilities.getElementByNumber("statID",statID) : this.abilities.getElementByString("statID",statID);
			if(!ability_mc)
			{
				ability_mc = new abilEntry();
				ability_mc.onInit(this.root_mc,this.root_mc.CCPanel_mc.abilities_mc.onPlus,this.root_mc.CCPanel_mc.abilities_mc.onMin);
				this.abilities.addElement(ability_mc,false);
				ability_mc.statID = statID;
				ability_mc.isCivil = isCivil;
				ability_mc.scrollList = this.ownerList;
			}
			ability_mc.MakeCustom(statID, isCustom);
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
		
		public function frame1() : * {}
	}
}
