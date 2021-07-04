package characterSheet_fla
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public dynamic class minusButton_65 extends MovieClip
	{
		public var bg_mc:MovieClip;
		public var hit_mc:MovieClip;
		public var base:MovieClip;
		public var stat:MovieClip;
		public var callbackStr:String;
		public var currentTooltip:String;
		
		public function minusButton_65()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onMouseOver(param1:MouseEvent) : *
		{
			if(this.tooltip != "")
			{
				this.base.hasTooltip = true;
				this.currentTooltip = this.tooltip;
				ExternalInterface.call("showTooltip",this.tooltip);
			}
			this.bg_mc.gotoAndStop(2);
			ExternalInterface.call("PlaySound","UI_Game_Inventory_Over");
		}
		
		public function onMouseOut(param1:MouseEvent) : *
		{
			if(this.base.hasTooltip)
			{
				this.base.hasTooltip = false;
				this.currentTooltip = "";
				ExternalInterface.call("hideTooltip");
			}
			this.bg_mc.gotoAndStop(1);
			removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
		}
		
		public function onDown(param1:MouseEvent) : *
		{
			ExternalInterface.call("PlaySound","UI_GM_Generic_Click_Press");
			stage.focus = null;
			this.bg_mc.gotoAndStop(3);
			addEventListener(MouseEvent.MOUSE_UP,this.onUp);
		}
		
		public function onUp(param1:MouseEvent) : *
		{
			removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.bg_mc.gotoAndStop(2);
			if(this.stat)
			{
				if(!this.stat.isCustom)
				{
					ExternalInterface.call(this.callbackStr, this.stat.statId);
				}
				else
				{
					ExternalInterface.call(this.callbackStr, this.stat.customID);
				}
			}
			else
			{
				ExternalInterface.call(this.callbackStr);
			}
			ExternalInterface.call("PlaySound","UI_GM_Generic_Click_Release");
		}
		
		public function frame1() : *
		{
			this.base = root as MovieClip;
			this.stat = parent as MovieClip;
			this.currentTooltip = "";
			this.hit_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
			this.hit_mc.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
			this.hit_mc.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
		}
	}
}
