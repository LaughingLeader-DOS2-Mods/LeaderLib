package
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class abilEntry extends MovieClip
	{
		public var bullet_mc:MovieClip;
		public var hit_mc:hit;
		public var label_txt:TextField;
		public var min_mc:minusButton;
		public var plus_mc:plusButton;
		public var value_txt:TextField;
		public const headerColor = 10588810;
		public var root_mc:MovieClip;
		public var isAltered:Boolean;
		public var value:uint;

		//LeaderLib Changes
		public var statID:*;
		public var callbackStr:String = "showAbilityTooltip";
		public var isCustom:Boolean = false;

		public function MakeCustom(id:*, b:Boolean=true) : *
		{
			this.statID = id;
			this.isCustom = b;
			if(b)
			{
				this.callbackStr = "showAbilityTooltipCustom";
				this.min_mc.callbackStr = "minusAbilityCustom";
				this.plus_mc.callbackStr = "plusAbilityCustom";
			}
			else
			{
				this.callbackStr = "showAbilityTooltip";
				this.min_mc.callbackStr = "minusAbility";
				this.plus_mc.callbackStr = "plusAbility";
			}
		}
		
		public function abilEntry()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onInit(mainTimeline:MovieClip, pointAddedFunc:Function, pointRemovedFunc:Function) : *
		{
			this.root_mc = mainTimeline;
			this.bullet_mc.gotoAndStop(1);
			this.bullet_mc.visible = false;
			this.label_txt.wordWrap = this.label_txt.multiline = false;
			this.label_txt.autoSize = TextFieldAutoSize.LEFT;
			this.plus_mc.init(pointAddedFunc,this);
			this.min_mc.init(pointRemovedFunc,this);
			this.hit_mc.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			this.hit_mc.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
		}
		
		public function setAbility(label:String, valueAmount:int, deltaAmount:int) : *
		{
			this.isAltered = deltaAmount > 0;
			this.delta = deltaAmount;
			this.label_txt.htmlText = label;
			this.value_txt.htmlText = String(valueAmount);
			this.value = valueAmount;
			this.bullet_mc.visible = this.isAltered;
			this.min_mc.visible = this.isAltered;
			this.plus_mc.visible = !!this.isCivil?this.root_mc.availableCivilPoints > 0 && (this.delta < this.root_mc.cibilAbilityCap || this.root_mc.cibilAbilityCap < 0):this.root_mc.availableAbilityPoints > 0 && (this.delta < this.root_mc.combatAbilityCap || this.root_mc.combatAbilityCap < 0);
		}
		
		public function onOver(e:MouseEvent) : *
		{
			ExternalInterface.call("PlaySound","UI_Generic_Over");
			var globalPos:Point = this.localToGlobal(new Point(0,0));
			ExternalInterface.call(this.callbackStr,this.root_mc.characterHandle,this.statID,globalPos.x - this.root_mc.x,globalPos.y,this.hit_mc.width,this.hit_mc.height,"left");
		}
		
		public function onOut(param1:MouseEvent) : *
		{
			ExternalInterface.call("hideTooltip");
		}
		
		public function frame1() : * {}
	}
}
