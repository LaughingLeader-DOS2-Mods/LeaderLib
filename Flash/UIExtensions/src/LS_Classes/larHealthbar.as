package LS_Classes
{
	import fl.motion.Color;
	import fl.motion.easing.Sine;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	public class larHealthbar extends MovieClip
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
		
		public function larHealthbar()
		{
			this.easingFunction = Sine.easeOut;
			super();
			this.hBar_mc.scaleX = this.hBar2_mc.scaleX = 0;
		}
		
		public function set onComplete(param1:Function) : *
		{
			this.m_FinishCallback = param1;
		}
		
		public function get onComplete() : Function
		{
			return this.m_FinishCallback;
		}
		
		public function setBar(param1:Number, param2:Boolean) : Boolean
		{
			var val3:Boolean = false;
			this.stopHPTweens();
			if(param1 > 1)
			{
				param1 = 1;
			}
			if(param2)
			{
				this.percTemp = param1;
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
				this.hBar_mc.scaleX = param1;
				this.hBar2_mc.scaleX = param1;
			}
			if(this.percHB != param1)
			{
				val3 = true;
			}
			this.percHB = param1;
			return val3;
		}
		
		public function stopHPTweens() : *
		{
			if(this.timeline)
			{
				this.timeline.stop();
				this.timeline = null;
			}
		}
		
		public function setBarColour(param1:uint) : *
		{
			var val2:ColorTransform = this.hBar_mc.transform.colorTransform;
			val2.color = param1;
			this.hBar_mc.transform.colorTransform = val2;
			var val3:Color = new Color();
			val3.color = param1;
			val3 = this.changeColour(val3,200);
			this.m_BarColour = param1;
			var val4:ColorTransform = this.hBar2_mc.transform.colorTransform;
			val4.color = val3.color;
			this.hBar2_mc.transform.colorTransform = val4;
		}
		
		public function get barColour() : Number
		{
			return this.m_BarColour;
		}
		
		private function changeColour(param1:Color, param2:Number) : Color
		{
			param1.blueOffset = param1.blueOffset + param2;
			param1.redOffset = param1.redOffset + param2;
			param1.greenOffset = param1.greenOffset + param2;
			if(param1.blueOffset > 255)
			{
				param1.blueOffset = 255;
			}
			if(param1.greenOffset > 255)
			{
				param1.greenOffset = 255;
			}
			if(param1.redOffset > 255)
			{
				param1.redOffset = 255;
			}
			return param1;
		}
	}
}
