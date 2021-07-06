package
{
	import LS_Classes.larTween;
	import fl.motion.easing.Quartic;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class Talent extends MovieClip
	{
		public var bullet_mc:MovieClip;
		public var hl_mc:MovieClip;
		public var label_txt:TextField;
		public var minus_mc:MovieClip;
		public var plus_mc:MovieClip;
		public var timeline:larTween;
		public var base:MovieClip;

		//LeaderLib Changes
		public var statID:Number;
		public var callbackStr:String = "showTalentTooltip";
		public var isCustom:Boolean = false;

		public function MakeCustom(statID:Number, b:Boolean=true) : *
		{
			this.statID = statID;
			this.isCustom = b;
			if(b)
			{
				this.callbackStr = "showTalentTooltipCustom";
				this.minus_mc.callbackStr = "minusTalentCustom";
				this.plus_mc.callbackStr = "plusTalentCustom";
			}
			else
			{
				this.callbackStr = "showTalentTooltip";
				this.minus_mc.callbackStr = "minusTalent";
				this.plus_mc.callbackStr = "plusTalent";
			}
		}
		
		public function Talent()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onOver(e:MouseEvent) : *
		{
			this.widthOverride = 269 + 44;
			this.mOffsetY = -this.base.stats_mc.talentHolder_mc.list.m_scrollbar_mc.scrolledY - 26;
			this.base.showCustomTooltipForMC(this, this.callbackStr, this.statID);
			
			this.hl_mc.visible = true;
			if(this.timeline && this.timeline.isPlaying)
			{
				this.timeline.stop();
			}
			this.timeline = new larTween(this.hl_mc,"alpha",Quartic.easeIn,this.hl_mc.alpha,1,0.01);
		}
		
		public function onOut(e:MouseEvent) : *
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
			this.hl_mc.alpha = 0;
			this.hl_mc.height = 24;
			this.label_txt.mouseEnabled = false;
			this.minus_mc.callbackStr = "minusTalent";
			this.plus_mc.callbackStr = "plusTalent";
		}
	}
}