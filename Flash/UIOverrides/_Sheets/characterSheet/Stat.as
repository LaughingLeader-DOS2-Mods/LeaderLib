package
{
	import LS_Classes.larTween;
	import fl.motion.easing.Quartic;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class Stat extends MovieClip
	{
		public var hl_mc:MovieClip;
		public var icon_mc:MovieClip;
		public var label_txt:TextField;
		public var minus_mc:MovieClip;
		public var plus_mc:MovieClip;
		public var text_txt:TextField;
		public var timeline:larTween;
		public var base:MovieClip;

		//LeaderLib Changes
		public var statID:Number;
		public var tooltip:Number; // The tooltip ID
		public var callbackStr:String = "showStatTooltip";
		public var isCustom:Boolean = false;
		public var hasCustomIcon:Boolean = false;

		public function MakeCustom(statID:Number, b:Boolean=true) : *
		{
			this.statID = statID;
			this.isCustom = b;
			if(b)
			{
				this.callbackStr = "showStatTooltipCustom";
				this.minus_mc.callbackStr = "minusStatCustom";
				this.plus_mc.callbackStr = "plusStatCustom";
			}
			else
			{
				this.callbackStr = "showStatTooltip";
				this.minus_mc.callbackStr = "minusStat";
				this.plus_mc.callbackStr = "plusStat";
			}
		}
		
		public function Stat()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onOver(param1:MouseEvent) : *
		{
			this.widthOverride = 269;
			!isCustom ? this.base.showCustomTooltipForMC(this, this.callbackStr, this.tooltip) : this.base.showCustomTooltipForMC(this, this.callbackStr, this.statID);
			if(this.timeline && this.timeline.isPlaying)
			{
				this.timeline.stop();
			}
			this.hl_mc.visible = true;
			this.timeline = new larTween(this.hl_mc,"alpha",Quartic.easeIn,this.hl_mc.alpha,1,0.01);
		}
		
		public function onOut(param1:MouseEvent) : *
		{
			this.timeline = new larTween(this.hl_mc,"alpha",Quartic.easeOut,this.hl_mc.alpha,0,0.01);
			this.base.hasTooltip = false;
			ExternalInterface.call("hideTooltip");
		}

		//LeaderLib
		public function SetCustomIcon(iconName:String, offsetX:Number = 0, offsetY:Number = 0, useDefaultOffset:Boolean = true) : Boolean
		{
			if(useDefaultOffset) {
				this.base = root as MovieClip;
				offsetX = this.base.stats_mc.customPrimaryStatIconOffsetX;
				offsetY = this.base.stats_mc.customPrimaryStatIconOffsetY;
			}
			this.icon_mc.visible = false;
			if(this.customIcon_mc == undefined)
			{
				this.customIcon_mc = new IggyIcon();
				this.customIcon_mc.mouseEnabled = false;
				this.addChild(this.customIcon_mc);
				this.customIcon_mc.scale = 0.5625; // 36/64
			}
			this.customIcon_mc.x = this.icon_mc.x + offsetX;
			this.customIcon_mc.y = this.icon_mc.y + offsetY;
			this.customIcon_mc.name = iconName;
			this.customIcon_mc.visible = true;
			this.hasCustomIcon = true;
			return true;
		}

		public function RemoveCustomIcon() : Boolean
		{
			this.icon_mc.visible = true;
			this.hasCustomIcon = false;
			if(this.customIcon_mc != undefined)
			{
				this.removeChild(this.customIcon_mc);
				this.customIcon_mc = null;
				return true;
			}
			return false;
		}
		
		public function frame1() : *
		{
			this.base = root as MovieClip;
			this.hl_mc.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			this.hl_mc.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			// this.minus_mc.callbackStr = "minusStat";
			// this.plus_mc.callbackStr = "plusStat";
		}
	}
}
