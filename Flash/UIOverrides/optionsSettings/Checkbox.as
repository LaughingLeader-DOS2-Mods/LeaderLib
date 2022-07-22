package
{
	import LS_Classes.tooltipHelper;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class Checkbox extends MovieClip
	{
		public var bg_mc:MovieClip;
		public var formHL_mc:MovieClip;
		public var label_txt:TextField;
		public var base:MovieClip;
		public var mHeight:Number = 30;
		
		public function Checkbox()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onDown(param1:MouseEvent) : *
		{
			this.bg_mc.gotoAndStop(this.stateID * 3 + 3);
			addEventListener(MouseEvent.MOUSE_UP,this.onClick);
		}
		
		public function onClick(param1:MouseEvent) : *
		{
			if(this.enable)
			{
				this.stateID++;
				if(this.filterBool)
				{
					if(this.stateID > 2)
					{
						this.stateID = 0;
					}
				}
				else if(this.stateID > 1)
				{
					this.stateID = 0;
				}
				this.bg_mc.gotoAndStop(this.stateID * 3 + 1);
				ExternalInterface.call("PlaySound","UI_Gen_XButton_Click");
				// LeaderLib: checkBoxID changed to llcheckBoxID
				ExternalInterface.call("llcheckBoxID",this.id,this.stateID);
			}
			removeEventListener(MouseEvent.MOUSE_UP,this.onClick);
		}
		
		public function deselectElement(e:MouseEvent=null) : *
		{
			removeEventListener(MouseEvent.MOUSE_UP,this.onClick);
			this.bg_mc.gotoAndStop(this.stateID * 3 + 1);
		}
		
		public function selectElement(e:MouseEvent=null) : *
		{
			this.bg_mc.gotoAndStop(this.stateID * 3 + 2);
		}
		
		public function onMouseOver(e:MouseEvent) : *
		{
			if(this.enable)
			{
				this.base.mainMenu_mc.setCursorPosition(this.id);
				if(this.tooltip != null && this.tooltip != "")
				{
					this.base.curTooltip = this.pos;
					this.tooltipOverrideW = this.base.ElW;
					this.tooltipYOffset = -4;
					tooltipHelper.ShowTooltipForMC(this,root,"bottom",this.base.hasTooltip == false);
				}
				this.selectElement(e);
			}
		}
		
		public function onMouseOut(e:MouseEvent) : *
		{
			if(this.base.curTooltip == this.pos && this.base.hasTooltip)
			{
				ExternalInterface.call("hideTooltip");
				this.base.hasTooltip = false;
			}
			this.base.curTooltip = -1;
			removeEventListener(MouseEvent.MOUSE_UP,this.onClick);
			if(this.enabled)
			{
				this.deselectElement(e);
			}
		}
		
		public function setState(state:Number) : *
		{
			this.stateID = state;
			this.bg_mc.gotoAndStop(this.stateID * 3 + 1);
		}
		
		public function frame1() : *
		{
			this.base = root as MovieClip;
			this.bg_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown, false, 100);
			this.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver, false, 100);
			this.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut, false, 100);
			// this.graphics.beginFill(0xFF0000, 0.5);
			// this.graphics.drawRect(0, 0, this.width, this.height);
			// this.graphics.endFill();
		}
	}
}
