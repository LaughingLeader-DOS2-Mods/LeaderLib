package Controls
{
	import LS_Classes.tooltipHelper;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public dynamic class BaseTooltipSupport extends MovieClip
	{
		public var base:MovieClip;
		public var tooltip:String = "";
		public var tooltipOverrideW:Number = 0;
		public var tooltipYOffset:Number = 0;
		public var tooltipSide:String = "bottom";

		public function BaseTooltipSupport()
		{
			super();
			addFrameScript(0, this.setupTooltipListeners);
		}

		public function showTooltip() : *
		{
			if(this.tooltip != null && this.tooltip != "")
			{
				this.base.curTooltip = this.name;
				this.tooltipOverrideW = this.base.ElW;
				this.tooltipYOffset = -4;
				tooltipHelper.ShowTooltipForMC(this,this.base,this.tooltipSide);
			}
		}

		public function hideTooltip() : *
		{
			if(this.base.curTooltip == this.name && this.base.hasTooltip)
			{
				ExternalInterface.call("hideTooltip");
				this.base.hasTooltip = false;
				this.base.curTooltip = "";
			}
		}
		
		public function onMouseOver(e:MouseEvent) : *
		{
			this.showTooltip();
		}
		
		public function onMouseOut(e:MouseEvent) : *
		{
			this.hideTooltip();
		}
		
		private function setupTooltipListeners() : *
		{
			this.base = root as MovieClip;
			addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
		}
	}
}