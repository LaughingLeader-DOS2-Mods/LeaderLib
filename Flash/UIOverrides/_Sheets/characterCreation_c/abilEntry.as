package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class abilEntry extends MovieClip
	{
		public var bg_mc:MovieClip;
		public var bullet_mc:MovieClip;
		public var hl_mc:MovieClip;
		public var label_txt:TextField;
		public var min_mc:MovieClip;
		public var plus_mc:freePoint;
		public var value_txt:TextField;
		public const headerColor = 0;
		public var root_mc:MovieClip;
		public var isAltered:Boolean;
		public var value:uint;

		//LeaderLib Changes
		// Set in talentsMC_51.addTalentElement, we're just adding it here for sanity
		public var abilityID:uint;
		public var isCivil:Boolean = false;
		//Custom non-standard talents
		public var customID:String;
		public var isCustom:Boolean = false;
		
		public function abilEntry()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onInit(param1:MovieClip) : *
		{
			this.root_mc = param1;
			this.bullet_mc.gotoAndStop(2);
			this.bullet_mc.visible = false;
			this.label_txt.wordWrap = this.label_txt.multiline = false;
			this.label_txt.autoSize = TextFieldAutoSize.LEFT;
			this.hl_mc.visible = false;
			this.min_mc.visible = this.plus_mc.visible = false;
			addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler,false,0,true);
		}
		
		public function removedFromStageHandler(param1:Event) : *
		{
			var val2:MovieClip = param1.currentTarget as MovieClip;
			if(val2)
			{
				this.hl_mc.stopTweens();
			}
		}
		
		public function setAbility(label:String, valueAmount:int, deltaAmount:int) : *
		{
			this.isAltered = param3 > 0;
			this.label_txt.htmlText = label;
			this.value_txt.htmlText = String(valueAmount);
			this.value = valueAmount;
			this.deltaVal = deltaAmount;
			this.label_txt.textColor = !!this.isAltered?uint(this.root_mc.hFont):uint(this.headerColor);
			this.value_txt.textColor = !!this.isAltered?uint(this.root_mc.alteredFont):uint(this.headerColor);
			this.bullet_mc.visible = this.isAltered;
			if(this.hl_mc.visible)
			{
				this.min_mc.visible = this.isAltered;
				this.plus_mc.visible = !!this.isCivil?this.root_mc.availableCivilPoints > 0 && (this.deltaVal < this.root_mc.cibilAbilityCap || this.root_mc.cibilAbilityCap < 0):this.root_mc.availableAbilityPoints > 0 && (this.deltaVal < this.root_mc.combatAbilityCap || this.root_mc.combatAbilityCap < 0);
			}
		}
		
		public function selectElement() : *
		{
			this.hl_mc.visible = true;
			this.min_mc.visible = this.isAltered;
			this.plus_mc.visible = !!this.isCivil?this.root_mc.availableCivilPoints > 0 && (this.deltaVal < this.root_mc.cibilAbilityCap || this.root_mc.cibilAbilityCap < 0):this.root_mc.availableAbilityPoints > 0 && (this.deltaVal < this.root_mc.combatAbilityCap || this.root_mc.combatAbilityCap < 0);
			this.hl_mc.startAnimHL();
			if(!isCustom)
			{
				ExternalInterface.call("requestAbilityTooltip",this.abilityID);
			}
			else
			{
				ExternalInterface.call("requestCustomAbilityTooltip",this.abilityID);
			}
		}
		
		public function deselectElement() : *
		{
			this.hl_mc.visible = false;
			this.hl_mc.stopTweens();
			this.min_mc.visible = this.plus_mc.visible = false;
		}
		
		private function frame1() : * {}
	}
}
