package Controls.Bars
{
	import fl.motion.Color;
	import fl.motion.easing.Sine;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import LS_Classes.larTween;
	import Controls.TooltipHandler;
	
	public dynamic class BarHolder extends MovieClip
	{
		public var hBar_mc:MovieClip;
		public var hBar2_mc:MovieClip;
		public var easingFunction:Function;
		private var timeline:larTween;
		private var percHB:Number = 0;
		private var percTemp:Number = 0;
		private var m_BarColour:uint;
		public var tweenDelay:Number = 0.8;
		public var tweenTime:Number = 0.5;
		private var m_FinishCallback:Function = null;
		
		public function BarHolder()
		{
			super();
			this.easingFunction = Sine.easeOut;
			this.hBar_mc.scaleX = this.hBar2_mc.scaleX = 0;
			this.addFrameScript(0,this.frame1);
		}

		private function frame1():void
		{
			TooltipHandler.init(this);
		}
		
		private function set onComplete(func:Function) : *
		{
			this.m_FinishCallback = func;
		}
		
		private function get onComplete() : Function
		{
			return this.m_FinishCallback;
		}
		
		public function setBar(percentage:Number, doTween:Boolean) : Boolean
		{
			var isTweening:Boolean = false;
			this.stopHPTweens();
			if(percentage > 1)
			{
				percentage = 1;
			}
			if(doTween)
			{
				this.percTemp = percentage;
				if(this.percHB < this.percTemp)
				{
					this.hBar2_mc.scaleX = this.percTemp;
					this.timeline = new larTween(this.hBar_mc,"scaleX",this.easingFunction,this.hBar_mc.scaleX,this.percTemp,this.tweenTime,null,null,this.tweenDelay);
				}
				else
				{
					this.hBar_mc.scaleX = this.percTemp;
					this.timeline = new larTween(this.hBar2_mc,"scaleX",this.easingFunction,this.hBar2_mc.scaleX,this.percTemp,this.tweenTime,null,null,this.tweenDelay);
				}
				this.timeline.onComplete = this.m_FinishCallback;
			}
			else
			{
				this.hBar_mc.scaleX = percentage;
				this.hBar2_mc.scaleX = percentage;
			}
			if(this.percHB != percentage)
			{
				isTweening = true;
			}
			this.percHB = percentage;
			return isTweening;
		}
		
		public function stopHPTweens() : *
		{
			if(this.timeline)
			{
				this.timeline.stop();
				this.timeline = null;
			}
		}
		
		public function setBarColour(color:uint) : *
		{
			var colorTransform:ColorTransform = this.hBar_mc.transform.colorTransform;
			colorTransform.color = color;
			this.hBar_mc.transform.colorTransform = colorTransform;
			var colorObj:Color = new Color();
			colorObj.color = color;
			colorObj = this.changeColour(colorObj,200);
			this.m_BarColour = color;
			var colorTransform2:ColorTransform = this.hBar2_mc.transform.colorTransform;
			colorTransform2.color = colorObj.color;
			this.hBar2_mc.transform.colorTransform = colorTransform2;
		}
		
		public function get barColour() : Number
		{
			return this.m_BarColour;
		}
		
		private function changeColour(colorObj:Color, colorOffset:Number) : Color
		{
			colorObj.blueOffset = colorObj.blueOffset + colorOffset;
			colorObj.redOffset = colorObj.redOffset + colorOffset;
			colorObj.greenOffset = colorObj.greenOffset + colorOffset;
			if(colorObj.blueOffset > 255)
			{
				colorObj.blueOffset = 255;
			}
			if(colorObj.greenOffset > 255)
			{
				colorObj.greenOffset = 255;
			}
			if(colorObj.redOffset > 255)
			{
				colorObj.redOffset = 255;
			}
			return colorObj;
		}
	}
}
