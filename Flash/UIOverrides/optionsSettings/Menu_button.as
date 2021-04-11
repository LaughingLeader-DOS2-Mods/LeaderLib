package
{
	import LS_Classes.textEffect;
	import LS_Classes.tooltipHelper;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class Menu_button extends MovieClip
	{
		public var bg_mc:MovieClip;
		public var disable_mc:MovieClip;
		public var formHL_mc:MovieClip;
		public var label_txt:TextField;
		public var textY:Number;
		public var snd_onUp:String;
		public var base:MovieClip;
		
		public function Menu_button()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function buttonOver(param1:Event) : *
		{
			this.bg_mc.gotoAndStop(2);
			ExternalInterface.call("PlaySound","UI_Generic_Over");
			ExternalInterface.call("menuButtonOver",this.id);
		}
		
		public function buttonOut(param1:Event) : *
		{
			this.bg_mc.gotoAndStop(1);
			this.label_txt.y = this.textY;
			removeEventListener("mouseUp",this.buttonReleased);
		}
		
		public function buttonPressed(param1:Event) : *
		{
			this.bg_mc.gotoAndStop(3);
			this.label_txt.y = this.textY + 3;
			addEventListener("mouseUp",this.buttonReleased);
		}
		
		public function buttonReleased(param1:Event) : *
		{
			this.bg_mc.gotoAndStop(2);
			this.label_txt.y = this.textY;
			ExternalInterface.call("PlaySound",this.snd_onUp);
			// LeaderLib: buttonPressed changed to llbuttonPressed so engine stuff doesn't fire when a Mod Settings button is pressed.
			ExternalInterface.call("llbuttonPressed",this.id);
			removeEventListener("mouseUp",this.buttonReleased);
		}
		
		public function deselectElement(param1:MouseEvent) : *
		{
			this.bg_mc.gotoAndStop(1);
		}
		
		public function selectElement(param1:MouseEvent) : *
		{
			this.bg_mc.gotoAndStop(2);
		}
		
		public function onMouseOver(param1:MouseEvent) : *
		{
			this.base.mainMenu_mc.setCursorPosition(this.id);
			if(this.tooltip != null && this.tooltip != "")
			{
				this.base.curTooltip = this.pos;
				this.tooltipYOffset = 10;
				this.tooltipOverrideW = this.base.ElW;
				tooltipHelper.ShowTooltipForMC(this,root,"bottom");
			}
		}
		
		public function onMouseOut(param1:MouseEvent) : *
		{
			if(this.base.curTooltip == this.pos && this.base.hasTooltip)
			{
				ExternalInterface.call("hideTooltip");
				this.base.hasTooltip = false;
			}
			this.base.curTooltip = -1;
		}
		
		function frame1() : *
		{
			this.label_txt.filters = textEffect.createStrokeFilter(0,2,0.75,1.4,3);
			this.textY = 20;
			addEventListener("mouseOver",this.buttonOver);
			addEventListener("mouseOut",this.buttonOut);
			addEventListener("mouseDown",this.buttonPressed);
			this.base = root as MovieClip;
			addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
		}
	}
}
