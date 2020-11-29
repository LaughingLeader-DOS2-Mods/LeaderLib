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
		
		public function onChange(param1:Event) : *
		{
			ExternalInterface.call("selectorID",this.id,this.selList.currentSelection);
			ExternalInterface.call("PlaySound","UI_Gen_OptMenu_Slider");
		}
		
		public function deselectElement(param1:MouseEvent) : *
		{
			this.hl_mc.visible = false;
		}
		
		public function selectElement(param1:MouseEvent) : *
		{
			ExternalInterface.call("PlaySound","UI_Gen_OptMenu_Over");
			this.hl_mc.visible = true;
		}
		
		public function onMouseOver(param1:MouseEvent) : *
		{
			this.base.mainMenu_mc.setCursorPosition(this.id);
			if(this.tooltip != null && this.tooltip != "")
			{
				this.base.curTooltip = this.pos;
				ExternalInterface.call("showItemTooltip",this.tooltip);
				this.base.hasTooltip = true;
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
			this.selList.addEventListener(Event.CHANGE,this.onChange);
			this.base = root as MovieClip;
			addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
		}
	}
}
