package
{
	import LS_Classes.textEffect;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import LS_Classes.tooltipHelper;
	import flash.external.ExternalInterface;
	
	// LeaderLib Changes: Added tooltip support
	public dynamic class LabelInfo extends MovieClip
	{
		public var info_txt:TextField;
		public var label_txt:TextField;
		public var mHeight:Number = 40;
		//LeaderLib
		public var formHL_mc:MovieClip;
		private var _tooltip:String = "";

		public function set tooltip(v:String) : void
		{
			this._tooltip = v;
			this.formHL_mc.mouseEnabled = this._tooltip != null && this._tooltip != "";
			//this.mouseChildren = false;
		}

		public function get tooltip() : String
		{
			return this._tooltip;
		}
		
		public function LabelInfo()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function deselectElement(e:MouseEvent) : * { }
		
		public function selectElement(e:MouseEvent) : * { }

		public function onMouseOver(e:MouseEvent) : *
		{
			if(this.tooltip != null && this.tooltip != "")
			{
				this.base.curTooltip = this.pos;
				this.tooltipOverrideW = this.base.ElW;
				this.tooltipYOffset = -4;
				tooltipHelper.ShowTooltipForMC(this,root,"bottom",this.base.hasTooltip == false);
			}
		}
		
		public function onMouseOut(e:MouseEvent) : *
		{
			if(this.base.curTooltip == this.pos && this.base.hasTooltip)
			{
				ExternalInterface.call("hideTooltip");
				this.base.hasTooltip = false;
				this.base.curTooltip = -1;
			}
		}
		
		public function frame1() : *
		{
			this.formHL_mc = new MovieClip();
			this.formHL_mc.width = 930;
			this.formHL_mc.visible = false;
			this.addChild(this.formHL_mc);
			this.label_txt.filters = textEffect.createStrokeFilter(0,1.2,1,1.4,3);
			this.info_txt.y = 0; // 30 in .fla
			this.label_txt.y = 0;  // 30 in .fla
			this.info_txt.mouseEnabled = false;
			this.label_txt.mouseEnabled = false;
			this.formHL_mc.mouseEnabled = this._tooltip != null && this._tooltip != "";
			this.formHL_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
			this.formHL_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
		}
	}
}
