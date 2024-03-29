package
{
	import LS_Classes.tooltipHelper;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class SliderComp extends MovieClip
	{
		public var amount_txt:TextField;
		public var formHL_mc:MovieClip;
		public var label_txt:TextField;
		public var max_txt:TextField;
		public var min_txt:TextField;
		public var slider_mc:SliderMC;
		public var base:MovieClip;
		public var mHeight:Number = 30;
		
		public function SliderComp()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onChange(e:Event) : *
		{
			var sliderValue:Number = this.slider_mc.value;
			this.amount_txt.htmlText = String(this.roundFloat(sliderValue));
			// LeaderLib: menuSliderID changed to llmenuSliderID
			ExternalInterface.call("llmenuSliderID", this.id, sliderValue);
			this.resetAmountPos();
		}
		
		public function roundFloat(param1:Number) : Number
		{
			return Math.round(param1 * 100) / 100;
		}
		
		public function onHandleUp(e:Event) : *
		{
			ExternalInterface.call("sliderHandleUp",this.id);
		}

		public function onHandleDown(e:Event) : *
		{
			this.base.focusedObject = this;
		}
		
		public function resetAmountPos() : *
		{
			this.amount_txt.x = this.slider_mc.x + this.slider_mc.m_handle_mc.x + Math.round((this.slider_mc.m_handle_mc.width - this.amount_txt.textWidth) * 0.5);
		}
		
		public function deselectElement(e:MouseEvent=null) : *
		{
			if(this.base != null && this.base.focusedObject == this)
			{
				this.base.focusedObject = null;
			}
		}
		
		public function selectElement(e:MouseEvent=null) : *
		{
			if(this.base != null)
			{
				this.base.focusedObject = this;
			}
			ExternalInterface.call("PlaySound","UI_Generic_Over");
		}
		
		public function onMouseOver(e:MouseEvent) : *
		{
			this.base.mainMenu_mc.setCursorPosition(this.id);
			if(this.tooltip != null && this.tooltip != "")
			{
				this.base.curTooltip = this.name;
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

		public function handleEvent(eventName:String, isDown:Boolean) : Boolean
		{
			var isHandled:Boolean = false;
			switch(eventName)
			{
				case "IE UILeft":
					if(isDown)
					{
						this.slider_mc.value = this.slider_mc.value - this.slider_mc.snapInterval;
						this.onChange(null);
						ExternalInterface.call("PlaySound","UI_Game_Dialog_Click");
					}
					isHandled = true;
					break;
				case "IE UIRight":
					if(isDown)
					{
						this.slider_mc.value = this.slider_mc.value + this.slider_mc.snapInterval;
						this.onChange(null);
						ExternalInterface.call("PlaySound","UI_Game_Dialog_Click");
					}
					isHandled = true;
					break;
			}
			return isHandled;
		}
		
		public function frame1() : *
		{
			this.slider_mc.addEventListener(Event.CHANGE,this.onChange);
			this.slider_mc.addEventListener("handleReleased",this.onHandleUp);
			this.slider_mc.addEventListener("handlePressed",this.onHandleDown);
			this.base = root as MovieClip;
			addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
			addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
		}
	}
}
