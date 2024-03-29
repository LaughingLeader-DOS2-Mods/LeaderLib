package
{
	import LS_Classes.coverFlow;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class Selector extends MovieClip
	{
		public var cont_mc:emptyBG;
		public var formHL_mc:MovieClip;
		public var hl_mc:MovieClip;
		public var label_txt:TextField;
		public var selList:coverFlow;
		public var base:MovieClip;
		
		public function Selector()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onChange(e:Event) : *
		{
			// LeaderLib: selectorID changed to llselectorID
			ExternalInterface.call("llselectorID",this.id,this.selList.currentSelection);
			ExternalInterface.call("PlaySound","UI_Gen_OptMenu_Slider");
		}
		
		public function deselectElement(e:MouseEvent) : *
		{
			this.hl_mc.visible = false;
		}
		
		public function selectElement(e:MouseEvent) : *
		{
			ExternalInterface.call("PlaySound","UI_Gen_OptMenu_Over");
			this.hl_mc.visible = true;
		}
		
		public function onMouseOver(e:MouseEvent) : *
		{
			this.base.mainMenu_mc.setCursorPosition(this.id);
			if(this.tooltip != null && this.tooltip != "")
			{
				this.base.curTooltip = this.name;
				ExternalInterface.call("showItemTooltip",this.tooltip);
				this.base.hasTooltip = true;
			}
		}
		
		public function onMouseOut(e:MouseEvent) : *
		{
			if(this.base.curTooltip == this.name && this.base.hasTooltip)
			{
				ExternalInterface.call("hideTooltip");
				this.base.hasTooltip = false;
				this.base.curTooltip = "";
			}
		}
		
		public function frame1() : *
		{
			this.selList.addEventListener(Event.CHANGE,this.onChange);
			this.base = root as MovieClip;
			addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
			addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
		}
	}
}
