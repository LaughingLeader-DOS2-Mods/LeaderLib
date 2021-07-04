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
		public var statId:*;
		public var tooltip:Number; // The tooltip ID
		public var callbackStr:String = "showStatTooltip";
		public var isCustom:Boolean = false;

		public function MakeCustom(id:*, b:Boolean=true) : *
		{
			this.statId = id;
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
			!isCustom ? this.base.showCustomTooltipForMC(this, this.callbackStr, this.tooltip) : this.base.showCustomTooltipForMC(this, this.callbackStr, this.statId);
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
		
		public function frame1() : *
		{
			this.base = root as MovieClip;
			this.hl_mc.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			this.hl_mc.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			this.minus_mc.callbackStr = "minusStat";
			this.plus_mc.callbackStr = "plusStat";
		}
	}
}
