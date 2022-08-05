package
{
	import LS_Classes.textEffect;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import LS_Classes.tooltipHelper;
	import flash.external.ExternalInterface;
	
	// LeaderLib Changes: Added tooltip support
	public dynamic class Label extends MovieClip
	{
		public var label_txt:TextField;
		public var mHeight:Number = 40;
		
		private var _tooltip:String = "";
		private var _addedEventListeners:Boolean = false;

		public function set tooltip(v:String) : void
		{
			this._tooltip = v;
			if (v != null && v != "")
			{
				this.mouseChildren = true;
				this.mouseEnabled = true;
				this.label_txt.mouseEnabled = true;
				if(!this._addedEventListeners)
				{
					this.label_txt.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
					this.label_txt.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
					this._addedEventListeners = true;
				}
			}
			else
			{
				if(this._addedEventListeners)
				{
					this.label_txt.removeEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
					this.label_txt.removeEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
					this._addedEventListeners = false;
				}
				this.label_txt.mouseEnabled = false;
				this.mouseChildren = false;
				this.mouseEnabled = false;
			}
		}

		public function get tooltip() : String
		{
			return this._tooltip;
		}
		
		public function Label()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function deselectElement(e:MouseEvent=null) : *
		{

		}
		
		public function selectElement(e:MouseEvent=null) : *
		{
		}

		public function onMouseOver(e:MouseEvent) : *
		{
			if(this._tooltip != null && this._tooltip != "")
			{
				this.base.curTooltip = this.name;
				//this.tooltipOverrideW = this.base.ElW;
				this.tooltipXOffset = -350;
				this.tooltipYOffset = -4;
				tooltipHelper.ShowTooltipForMC(this,root,"right",this.base.hasTooltip == false);
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
			this.label_txt.filters = textEffect.createStrokeFilter(0,1.2,1,1.4,3);
			// this.graphics.beginFill(0xFFCC00, 0.5);
			// this.graphics.drawRect(0, 0, this.width, this.height);
			// this.graphics.endFill();
		}
	}
}