package
{
	import LS_Classes.textEffect;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import LS_Classes.tooltipHelper;
	import flash.external.ExternalInterface;
	
	public dynamic class Label extends MovieClip
	{
		public var label_txt:TextField;
		public var mHeight:Number;
		public var tooltip:String;
		
		public function Label()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function deselectElement(param1:MouseEvent) : *
		{
		}
		
		public function selectElement(param1:MouseEvent) : *
		{
		}

		public function onMouseOver(param1:MouseEvent) : *
		{
			if(this.tooltip != null && this.tooltip != "")
			{
				this.base.curTooltip = this.pos;
				this.tooltipOverrideW = this.base.ElW;
				this.tooltipYOffset = -4;
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
			this.base = root as MovieClip;
			this.label_txt.filters = textEffect.createStrokeFilter(0,1.2,1,1.4,3);
			this.label_txt.height = 60;
			this.label_txt.y = 30;
			this.mHeight = 40;
			addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
		}
	}
}