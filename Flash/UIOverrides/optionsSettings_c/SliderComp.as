package
{
	import LS_Classes.textEffect;
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
		public var hl_mc:MovieClip;
		public var label_txt:TextField;
		public var max_txt:TextField;
		public var min_txt:TextField;
		public var slider_mc:SliderMC;
		public var base:MovieClip;
		
		public function SliderComp()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onChange(param1:Event = null) : *
		{
			var sliderValue:Number = this.slider_mc.value;
			this.amount_txt.htmlText = String(this.roundFloat(sliderValue));
			ExternalInterface.call("PlaySound","UI_Generic_Slider");
			// LeaderLib: menuSliderID changed to llmenuSliderID
			ExternalInterface.call("llmenuSliderID", this.id, sliderValue);
			this.resetAmountPos();
		}
		
		public function setCol() : *
		{
			var val1:Number = this.slider_mc.m_handle_mc.x + this.slider_mc.m_handle_mc.width * 0.5 - this.slider_mc.col_mc.x;
			if(val1 <= 0)
			{
				val1 = 2;
			}
			this.slider_mc.col_mc.width = val1;
		}
		
		public function roundFloat(param1:Number) : Number
		{
			return Math.round(param1 * 100) / 100;
		}
		
		public function onhandleUp(param1:Event = null) : *
		{
			ExternalInterface.call("sliderHandleUp",this.id);
		}
		
		public function resetAmountPos() : *
		{
			this.amount_txt.x = this.slider_mc.x + this.slider_mc.m_handle_mc.x + Math.round((this.slider_mc.m_handle_mc.width - this.amount_txt.textWidth) * 0.5);
			this.setCol();
		}
		
		public function deselectElement() : *
		{
			ExternalInterface.call("deselectElement",this.id);
			this.hl_mc.visible = false;
			if(this.onOut)
			{
				this.onOut();
			}
		}
		
		public function selectElement() : *
		{
			ExternalInterface.call("selectElement",this.id);
			this.hl_mc.visible = true;
			ExternalInterface.call("PlaySound","UI_Generic_Over");
			if(this.onOver)
			{
				this.onOver(this);
			}
		}
		
		public function onMouseOver(param1:MouseEvent = null) : *
		{
			this.base.mainMenu_mc.setCursorPosition(this.id);
			if(this.tooltip != null && this.tooltip != "")
			{
				this.base.curTooltip = this.pos;
				tooltipHelper.ShowTooltipForMC(this,root,"bottom",this.base.hasTooltip == false);
			}
		}
		
		public function onMouseOut(param1:MouseEvent = null) : *
		{
			if(this.base.curTooltip == this.pos && this.base.hasTooltip)
			{
				ExternalInterface.call("hideTooltip");
				this.base.hasTooltip = false;
			}
			this.base.curTooltip = -1;
		}
		
		public function handleEvent(param1:String, param2:Boolean) : Boolean
		{
			var val3:Boolean = false;
			switch(param1)
			{
				case "IE UILeft":
					if(param2)
					{
						this.slider_mc.value = this.slider_mc.value - this.slider_mc.snapInterval;
						this.onChange(null);
						ExternalInterface.call("PlaySound","UI_Game_Dialog_Click");
					}
					val3 = true;
					break;
				case "IE UIRight":
					if(param2)
					{
						this.slider_mc.value = this.slider_mc.value + this.slider_mc.snapInterval;
						this.onChange(null);
						ExternalInterface.call("PlaySound","UI_Game_Dialog_Click");
					}
					val3 = true;
			}
			return val3;
		}
		
		function frame1() : *
		{
			this.label_txt.filters = textEffect.createStrokeFilter(0,1.2,1,1.4,3);
			this.min_txt.filters = textEffect.createStrokeFilter(0,1.2,1,1.4,3);
			this.max_txt.filters = textEffect.createStrokeFilter(0,1.2,1,1.4,3);
			this.amount_txt.filters = textEffect.createStrokeFilter(0,1.2,1,1.4,3);
			this.slider_mc.addEventListener(Event.CHANGE,this.onChange);
			this.slider_mc.addEventListener("handleReleased",this.onhandleUp);
			this.base = root as MovieClip;
		}
	}
}
