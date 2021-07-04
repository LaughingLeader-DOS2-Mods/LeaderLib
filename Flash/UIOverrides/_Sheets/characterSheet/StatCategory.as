package
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class StatCategory extends MovieClip
	{
		public var amount_txt:TextField;
		public var bg_mc:MovieClip;
		public var listContainer_mc:empty;
		public var title_txt:TextField;
		public var isOpen:Boolean;
		public var hidePoints:Boolean;
		public var texty:Number;
		public var groupName:String = "";
		
		public function StatCategory()
		{
			super();
			addFrameScript(0,this.frame1);
		}

		public function setIsOpen(b:Boolean) : *
		{
			this.isOpen = b;
			this.bg_mc.gotoAndStop(!!this.isOpen?5:2);

			this.listContainer_mc.visible = this.isOpen;
			if(this.listContainer_mc.visible)
			{
				this.listContainer_mc.scaleY = 1;
				this.listContainer_mc.y = 26;
			}
			else
			{
				this.listContainer_mc.scaleY = 0;
				this.listContainer_mc.y = 18;
			}

			if(this.isOpen)
			{
				this.heightOverride = null;
			}
			else
			{
				this.heightOverride = this.title_txt.textHeight;
			}

			if(this.mainList)
			{
				this.mainList.positionElements();
			}
		}
		
		public function onMouseOver(e:MouseEvent) : *
		{
			this.bg_mc.gotoAndStop(!!this.isOpen?5:2);

			if(this.tooltip != "" && !this.base.hasTooltip)
			{
				this.base.hasTooltip = true;
				this.currentTooltip = this.tooltip;
				ExternalInterface.call("showTooltip",this.tooltip);
			}
		}
		
		public function onMouseOut(e:MouseEvent) : *
		{
			this.bg_mc.gotoAndStop(!!this.isOpen?4:1);
			this.bg_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.title_txt.y = this.texty;
			this.amount_txt.y = this.texty;

			if(this.base.hasTooltip && this.currentTooltip == this.tooltip)
			{
				this.base.hasTooltip = false;
				this.currentTooltip = "";
				ExternalInterface.call("hideTooltip");
			}
		}
		
		public function onDown(e:MouseEvent) : *
		{
			this.bg_mc.gotoAndStop(!!this.isOpen?6:3);
			this.bg_mc.addEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.title_txt.y = this.texty + 2;
			this.amount_txt.y = this.texty + 2;
		}
		
		public function onUp(e:MouseEvent) : *
		{
			this.bg_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			
			this.setIsOpen(!this.isOpen);

			this.title_txt.y = this.texty;
			this.amount_txt.y = this.texty;

			if (this.onUpCallback)
			{
				this.onUpCallback(this);
			}
		}
		
		public function frame1() : *
		{
			this.isOpen = true;
			this.hidePoints = false;
			this.texty = 0;
			this.title_txt.mouseEnabled = false;
			this.amount_txt.mouseEnabled = false;
			this.tooltip = "";

			this.bg_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
			this.bg_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
			this.bg_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);

			this.base = root as MovieClip;
		}
	}
}
