package LS_Classes
{
	import fl.motion.easing.Linear;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	
	public class controllerContainer extends horizontalList
	{
		 
		
		public var centerButtons:Boolean = false;
		
		public var alignLeft:Boolean = false;
		
		public var buttonhintContY:int = -1;
		
		public var centerPanelPosX:int = -1;
		
		public var leftPanelPosX:int = -1;
		
		public var buttonhintFrameWidth:int = -1;
		
		public var bounceTreshHold:int = 50;
		
		public var bounceInterval:Number = 1.5;
		
		public var bounceTime:Number = 50;
		
		private var m_BounceAmount:int = -1;
		
		private var m_BounceTween:larTween = null;
		
		public var m_CurrBounce:Number = 0;
		
		public var containerMaxWidth:uint = 0;
		
		public function controllerContainer()
		{
			super();
		}
		
		public function addBtnHint(param1:Number, param2:String, param3:Number, param4:Number = 110, param5:* = true) : MovieClip
		{
			var val6:MovieClip = getElementByNumber("id",param1);
			if(!val6)
			{
				val6 = new controllerBtnElement();
				val6.id = param1;
				val6.setBtnHintState(param5);
				addElement(val6);
			}
			if(val6)
			{
				val6.setBtnHint(param2,param3,param4,param5);
				if(this.containerMaxWidth > 0)
				{
					this.recalculateButtonsWidth();
				}
				this.recenterTabs();
			}
			else
			{
				Registry.ExtCall("UIAssert","addBtnHint failed again because the flash exporter is CRAP");
			}
			return val6;
		}
		
		public function recenterTabs() : *
		{
			if(this.buttonhintContY != -1 && this.centerPanelPosX != -1 && this.leftPanelPosX != -1 && this.buttonhintFrameWidth != -1)
			{
				this.bounceButtonHints();
			}
			else if(this.centerButtons)
			{
				container_mc.x = -Math.round(container_mc.width * 0.5);
			}
			else if(this.alignLeft)
			{
				container_mc.x = 0;
			}
			else
			{
				container_mc.x = -Math.round(container_mc.width);
			}
		}
		
		public function clearBtnHints() : *
		{
			clearElements();
		}
		
		private function bounceButtonHints() : *
		{
			if(this.buttonhintContY != -1 && this.centerPanelPosX != -1 && this.leftPanelPosX != -1 && this.buttonhintFrameWidth != -1)
			{
				if(this.width < this.buttonhintFrameWidth + this.bounceTreshHold)
				{
					this.x = this.centerPanelPosX - this.width / 2;
					if(this.m_BounceTween)
					{
						this.m_BounceTween.stop();
						this.m_BounceTween = null;
						this.m_BounceAmount = -1;
						this.y = this.buttonhintContY;
						this.scrollRect = null;
					}
				}
				else
				{
					this.x = this.leftPanelPosX;
					this.y = this.buttonhintContY - this.height / 2;
					this.scrollRect = new Rectangle(0,-this.height / 2,this.buttonhintFrameWidth,this.height);
					this.m_BounceAmount = this.width - this.buttonhintFrameWidth;
					this.m_CurrBounce = 0;
					this.bounceRight();
				}
			}
		}
		
		private function bounceLeft() : *
		{
			if(this.m_BounceTween)
			{
				this.m_BounceTween.stop();
				this.m_BounceTween = null;
			}
			this.m_BounceTween = new larTween(this,"m_CurrBounce",Linear.easeNone,this.m_BounceAmount,0,this.bounceTime * this.m_BounceAmount / 1000,this.bounceRight,null,this.bounceInterval);
			this.m_BounceTween.onUpdate = this.bounceButtonHint;
		}
		
		private function bounceRight() : *
		{
			if(this.m_BounceTween)
			{
				this.m_BounceTween.stop();
				this.m_BounceTween = null;
			}
			this.m_BounceTween = new larTween(this,"m_CurrBounce",Linear.easeNone,0,this.m_BounceAmount,this.bounceTime * this.m_BounceAmount / 1000,this.bounceLeft,null,this.bounceInterval);
			this.m_BounceTween.onUpdate = this.bounceButtonHint;
		}
		
		private function bounceButtonHint() : *
		{
			this.scrollRect = new Rectangle(this.m_CurrBounce,-this.height / 2,this.buttonhintFrameWidth,this.height);
		}
		
		private function recalculateButtonsWidth() : *
		{
			var val4:* = undefined;
			var val5:* = undefined;
			var val1:int = content_array.length;
			var val2:int = Math.ceil((this.containerMaxWidth - (val1 - 1) * EL_SPACING) / val1);
			var val3:int = 0;
			for each(val4 in content_array)
			{
				val3 = val3 + val4.getTextWidth();
			}
			if(this.containerMaxWidth - val3 > 0)
			{
				val2 = val2 + Math.ceil((this.containerMaxWidth - val3) / val1);
			}
			for each(val5 in content_array)
			{
				val5.setBtnHint(val5.text_txt.htmlText,val5.iconId,val2,val5.btnEnabled);
			}
			positionElements();
		}
	}
}
