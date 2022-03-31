package LS_Classes
{
	import flash.display.MovieClip;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public dynamic class LSButton extends MovieClip
	{
		private var pressedFunc:Function = null;
		public var onOverFunc:Function = null;
		public var onOutFunc:Function = null;
		public var onUpFunc:Function = null;
		public var onDownFunc:Function = null;
		public var onOverParams:Object = null;
		public var onOutParams:Object = null;
		public var onDownParams:Object = null;
		private var pressedParams:Object = null;
		private var textY:Number;
		private var iconY:Number;
		public var tooltip:String;
		public var alignTooltip:String;
		public var hoverSound:String;
		public var clickSound:String;
		public var textNormalAlpha:Number = 1;
		public var textClickAlpha:Number = 1;
		public var textDisabledAlpha:Number = 0.5;
		public var hitArea_mc:MovieClip;
		public var text_txt:TextField = null;
		public var bg_mc:MovieClip;
		public var icon_mc:MovieClip;
		public var disabled_mc:MovieClip;
		public var m_Disabled:Boolean = false;
		public var bgStartFrame:uint = 0;
		public var SND_Press:String = "";
		public var SND_Over:String = "UI_Generic_Over";
		public var SND_Click:String = "UI_Gen_XButton_Click";
		
		public function LSButton()
		{
			super();
			if(this.text_txt)
			{
				this.text_txt.mouseEnabled = false;
				this.text_txt.alpha = this.textNormalAlpha;
			}
			if(this.icon_mc)
			{
				this.icon_mc.mouseEnabled = false;
				this.icon_mc.alpha = this.textNormalAlpha;
			}
			if(this.hitArea_mc)
			{
				this.hitArea_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
				this.hitArea_mc.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
				this.hitArea_mc.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
			}
			else
			{
				addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
				addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
				addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
			}
			addEventListener(FocusEvent.FOCUS_OUT,this.onFocusLost);
		}
		
		public function init(onPressed:Function, objectParam:Object = null, isDisabled:Boolean = false) : *
		{
			this.pressedFunc = onPressed;
			if(objectParam)
			{
				this.pressedParams = objectParam;
			}
			this.setEnabled(!isDisabled);
			if(this.text_txt)
			{
				this.textY = this.text_txt.y;
			}
			if(this.icon_mc)
			{
				this.iconY = this.icon_mc.y;
			}
		}
		
		public function initialize(text:String, onPressed:Function, objectParam:Object = null, textSize:Number = -1, isDisabled:Boolean = false) : *
		{
			this.pressedFunc = onPressed;
			if(objectParam)
			{
				this.pressedParams = objectParam;
			}
			this.setEnabled(!isDisabled);
			if(this.text_txt)
			{
				this.textY = this.text_txt.y;
			}
			if(this.icon_mc)
			{
				this.iconY = this.icon_mc.y;
			}
			this.setText(text,textSize);
		}
		
		public function setText(text:String, textSize:Number = -1) : *
		{
			var val3:TextFormat = null;
			if(this.text_txt)
			{
				this.text_txt.y = this.textY;
				if(textSize != -1)
				{
					val3 = this.text_txt.defaultTextFormat;
					val3.size = textSize;
					this.text_txt.defaultTextFormat = val3;
				}
				this.text_txt.htmlText = text;
				this.textY = this.text_txt.y;
				this.text_txt.filters = textEffect.createStrokeFilter(0,1.5,0.75,1,3);
			}
		}
		
		public function setEnabled(isEnabled:Boolean) : *
		{
			if(this.disabled_mc)
			{
				this.disabled_mc.visible = !isEnabled;
			}
			if(this.text_txt)
			{
				this.text_txt.alpha = !!isEnabled?Number(this.textNormalAlpha):Number(this.textDisabledAlpha);
			}
			if(this.icon_mc)
			{
				this.icon_mc.alpha = !!isEnabled?Number(this.textNormalAlpha):Number(this.textDisabledAlpha);
			}
			this.m_Disabled = !isEnabled;
		}
		
		private function onFocusLost(e:FocusEvent) : void
		{
			if(this.text_txt)
			{
				this.text_txt.y = this.textY;
			}
			if(this.icon_mc)
			{
				this.icon_mc.y = this.iconY;
			}
		}
		
		public function onMouseOver(e:MouseEvent) : *
		{
			tooltipHelper.ShowTooltipForMC(this as MovieClip,MainTimeline.Instance,this.alignTooltip != null?this.alignTooltip:"right");
			if(!this.m_Disabled)
			{
				if(this.SND_Over != null)
				{
					Registry.ExtCall("PlaySound",this.SND_Over);
				}
				if(this.text_txt)
				{
					this.text_txt.alpha = this.textClickAlpha;
				}
				if(this.icon_mc)
				{
					this.icon_mc.alpha = this.textClickAlpha;
				}
				this.bg_mc.gotoAndStop(this.bgStartFrame + 2);
				if(this.onOverFunc != null)
				{
					if(this.onOverParams == null)
					{
						this.onOverFunc();
					}
					else
					{
						this.onOverFunc(this.onOverParams);
					}
				}
			}
		}
		
		public function onMouseOut(e:MouseEvent) : *
		{
			if(this.hitArea_mc)
			{
				this.hitArea_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			}
			else
			{
				removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			}
			if(this.tooltip != null)
			{
				Registry.ExtCall("hideTooltip");
			}
			
			if(this.onOutFunc != null)
			{
				if(this.onOutParams == null)
				{
					this.onOutFunc();
				}
				else
				{
					this.onOutFunc(this.onOutParams);
				}
			}
			this.bg_mc.gotoAndStop(this.bgStartFrame + 1);
			
			if(this.text_txt && !this.m_Disabled)
			{
				this.text_txt.alpha = this.textNormalAlpha;
				this.text_txt.y = this.textY;
			}
			if(this.icon_mc && !this.m_Disabled)
			{
				this.icon_mc.alpha = this.textNormalAlpha;
				this.icon_mc.y = this.iconY;
			}
		}
		
		public function onDown(e:MouseEvent) : *
		{
			if(this.text_txt)
			{
				this.text_txt.y = this.textY;
			}
			if(!this.m_Disabled)
			{
				if(this.hitArea_mc)
				{
					this.hitArea_mc.addEventListener(MouseEvent.MOUSE_UP,this.onUp);
				}
				else
				{
					addEventListener(MouseEvent.MOUSE_UP,this.onUp);
				}
				if(this.SND_Press != null)
				{
					Registry.ExtCall("PlaySound",this.SND_Press);
				}
				if(this.onDownFunc != null)
				{
					if(this.onDownParams == null)
					{
						this.onDownFunc();
					}
					else
					{
						this.onDownFunc(this.onDownParams);
					}
				}
				this.bg_mc.gotoAndStop(this.bgStartFrame + 3);
				if(this.text_txt)
				{
					this.text_txt.y = this.textY + 2;
				}
				if(this.icon_mc)
				{
					this.icon_mc.y = this.iconY + 2;
				}
			}
		}
		
		public function onUp(e:MouseEvent) : *
		{
			if(this.hitArea_mc)
			{
				this.hitArea_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			}
			else
			{
				removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			}
			if(this.SND_Click != null)
			{
				Registry.ExtCall("PlaySound",this.SND_Click);
			}
			if(this.onUpFunc != null)
			{
				this.onUpFunc();
			}
			this.bg_mc.gotoAndStop(this.bgStartFrame + 2);
			if(this.text_txt)
			{
				this.text_txt.y = this.textY;
			}
			if(this.icon_mc)
			{
				this.icon_mc.y = this.iconY;
			}
			if(this.pressedFunc != null && !this.m_Disabled)
			{
				if(this.pressedParams != null)
				{
					this.pressedFunc(this.pressedParams);
				}
				else
				{
					this.pressedFunc();
				}
			}
		}
	}
}
