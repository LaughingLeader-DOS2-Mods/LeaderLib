package
{
	import LS_Classes.tooltipHelper;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class DropDown extends MovieClip
	{
		public var combo_mc:comboBox;
		public var formHL_mc:MovieClip;
		public var label_txt:TextField;
		public var base:MovieClip;
		public var div:MovieClip;
		public var mHeight:Number = 30;
		
		public function DropDown()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onOpen(e:Event) : *
		{
			ExternalInterface.call("hideTooltip");
		}
		
		public function onChange(e:Event) : *
		{
			// LeaderLib: comboBoxID changed to llcomboBoxID
			ExternalInterface.call("llcomboBoxID",this.id,this.combo_mc.selectedIndex);
		}
		
		public function deselectElement(e:MouseEvent=null) : *
		{
		}
		
		public function selectElement(e:MouseEvent=null) : *
		{
			ExternalInterface.call("PlaySound","UI_Generic_Over");
		}
		
		public function onMouseOver(e:MouseEvent) : *
		{
			this.base.mainMenu_mc.setCursorPosition(this.id);
			if(this.tooltip != null && this.tooltip != "" && !this.combo_mc.m_isOpen)
			{
				this.base.curTooltip = this.name;
				this.tooltipYOffset = -4;
				this.tooltipOverrideW = this.base.ElW;
				tooltipHelper.ShowTooltipForMC(this,root,"bottom",this.base.hasTooltip == false);
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
			this.base = root as MovieClip;
			//Changed to just combo_mc, so the whole row doesn't cause a tooltip
			combo_mc.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
			combo_mc.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
			//this.label_txt.y = 0; // 9
			//this.combo_mc.y = 0; // 2
			this.combo_mc.addEventListener(Event.CHANGE,this.onChange);
			this.combo_mc.addEventListener(Event.OPEN,this.onOpen);
			this.combo_mc.m_dropOutYDisplacement = -2;
			this.combo_mc.bgHSpacing = -3;
			this.div = new scrollbarDivider();
			this.div.x = 241;
			this.div.y = 2;
			this.combo_mc.divider = this.div;
		}
	}
}
