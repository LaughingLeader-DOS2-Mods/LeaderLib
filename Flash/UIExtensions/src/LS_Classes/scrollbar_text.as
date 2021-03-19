package LS_Classes
{
	import fl.motion.easing.Sine;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	public class scrollbar_text extends MovieClip
	{
		 
		
		public var SND_Over:String = "";
		
		public var SND_Press:String = "";
		
		public var SND_Release:String = "";
		
		private var m_disabled:Boolean = false;
		
		private var m_content_txt:TextField;
		
		public var m_SCROLLSPEED:Number = 2;
		
		private var m_last_Y:Number = 0;
		
		private var m_scrollerDiff:Number = 0;
		
		public var m_down_mc:MovieClip;
		
		public var m_up_mc:MovieClip;
		
		public var m_handle_mc:MovieClip;
		
		public var m_FFdown_mc:MovieClip = null;
		
		public var m_FFup_mc:MovieClip = null;
		
		private var m_ffUpH:Number = 0;
		
		private var m_ffDownH:Number = 0;
		
		public var m_bg_mc:MovieClip;
		
		private var m_mouseWheelEnabled:Boolean = false;
		
		private var m_HasMouseWheelEvent:Boolean = true;
		
		public var m_mouseWheelWhenOverEnabled:Boolean = false;
		
		public var m_hideWhenDisabled:Boolean = true;
		
		public var m_disabledAlpha:Number = 0.3;
		
		public var m_tweenY:Number = 0;
		
		public var m_scaleBG:Boolean = true;
		
		private var m_handleResizable:Boolean = false;
		
		public var m_scrolledY:Number = 0;
		
		public var m_positionButtons:Boolean = true;
		
		public var m_animateScrolling:Boolean = false;
		
		private var m_scrollTimer:Timer;
		
		private var m_initialScrollDelay:Number = 400;
		
		private var m_scrollMultiplier:Number = 0.55;
		
		private var m_currentScrollDelay:Number = 400;
		
		private var m_currentScrollDown:Boolean = true;
		
		private var m_minScrollDelay:Number = 20;
		
		private var m_sbSpacing:Number = 0;
		
		public var m_scrollFunc:Function;
		
		public var m_scrollTime:Number = 0.2;
		
		private var m_scrollTween:larTween;
		
		public function scrollbar_text(param1:String = "down_id", param2:String = "up_id", param3:String = "handle_id", param4:String = "scrollBg_id", param5:String = "", param6:String = "")
		{
			var val12:Class = null;
			var val13:Class = null;
			this.m_scrollFunc = Sine.easeOut;
			super();
			var val7:Class = getDefinitionByName(param1) as Class;
			var val8:Class = getDefinitionByName(param2) as Class;
			var val9:Class = getDefinitionByName(param3) as Class;
			var val10:Class = getDefinitionByName(param4) as Class;
			this.m_down_mc = new val7();
			this.m_up_mc = new val8();
			this.m_handle_mc = new val9();
			this.m_bg_mc = new val10();
			addChild(this.m_bg_mc);
			addChild(this.m_handle_mc);
			addChild(this.m_up_mc);
			addChild(this.m_down_mc);
			var val11:Number = this.m_bg_mc.width;
			if(val11 < this.m_up_mc.width)
			{
				val11 = this.m_up_mc.width;
			}
			if(val11 < this.m_down_mc.width)
			{
				val11 = this.m_down_mc.width;
			}
			if(val11 < this.m_handle_mc.width)
			{
				val11 = this.m_handle_mc.width;
			}
			this.m_bg_mc.x = Math.round((val11 - this.m_bg_mc.width) * 0.5);
			this.m_up_mc.x = Math.round((val11 - this.m_up_mc.width) * 0.5);
			this.m_down_mc.x = Math.round((val11 - this.m_down_mc.width) * 0.5);
			this.m_handle_mc.x = Math.round((val11 - this.m_handle_mc.width) * 0.5);
			this.m_down_mc.addEventListener("mouseDown",this.downDown);
			this.m_down_mc.addEventListener("mouseOut",this.onOut);
			this.m_down_mc.addEventListener("mouseOver",this.onOver);
			this.m_down_mc.addEventListener("mouseUp",this.onUp);
			this.m_up_mc.addEventListener("mouseDown",this.upDown);
			this.m_up_mc.addEventListener("mouseOver",this.onOver);
			this.m_up_mc.addEventListener("mouseOut",this.onOut);
			this.m_up_mc.addEventListener("mouseUp",this.onUp);
			this.m_handle_mc.addEventListener("mouseOut",this.onOut);
			this.m_handle_mc.addEventListener("mouseDown",this.handlePressed);
			this.m_handle_mc.addEventListener("mouseOver",this.onOver);
			this.m_handle_mc.addEventListener("mouseUp",this.onUp);
			this.m_bg_mc.addEventListener("mouseDown",this.bgDown);
			if(param5 != "")
			{
				val12 = getDefinitionByName(param5) as Class;
				this.m_FFdown_mc = new val12();
				addChild(this.m_FFdown_mc);
				this.m_FFdown_mc.addEventListener("mouseUp",this.onUp);
				this.m_FFdown_mc.addEventListener("mouseDown",this.ffDownDown);
				this.m_FFdown_mc.addEventListener("mouseOut",this.onOut);
				this.m_FFdown_mc.addEventListener("mouseOver",this.onOver);
				this.m_FFdown_mc.x = Math.round((val11 - this.m_FFdown_mc.width) * 0.5);
				this.m_ffDownH = this.m_FFdown_mc.height;
			}
			if(param6 != "")
			{
				val13 = getDefinitionByName(param6) as Class;
				this.m_FFup_mc = new val13();
				addChild(this.m_FFup_mc);
				this.m_FFup_mc.addEventListener("mouseUp",this.onUp);
				this.m_FFup_mc.addEventListener("mouseDown",this.ffUpDown);
				this.m_FFup_mc.addEventListener("mouseOut",this.onOut);
				this.m_FFup_mc.addEventListener("mouseOver",this.onOver);
				this.m_FFup_mc.x = Math.round((val11 - this.m_FFup_mc.width) * 0.5);
				this.m_ffUpH = this.m_FFup_mc.height;
			}
			this.setScrollDiff();
		}
		
		public function set SND_Click(param1:String) : *
		{
			this.SND_Press = param1;
		}
		
		public function set SB_SPACING(param1:Number) : *
		{
			this.m_sbSpacing = param1;
			this.position();
		}
		
		public function get SB_SPACING() : Number
		{
			return this.m_sbSpacing;
		}
		
		private function setScrollDiff() : void
		{
			this.m_scrollerDiff = this.m_down_mc.y - (this.m_up_mc.y + this.m_up_mc.height) - this.m_handle_mc.height;
		}
		
		public function get mouseWheelWhenOverEnabled() : Boolean
		{
			return this.m_mouseWheelWhenOverEnabled;
		}
		
		public function set mouseWheelWhenOverEnabled(param1:Boolean) : *
		{
			if(this.m_mouseWheelWhenOverEnabled != param1)
			{
				this.m_mouseWheelWhenOverEnabled = param1;
				if(this.m_mouseWheelWhenOverEnabled)
				{
					this.m_content_txt.addEventListener(MouseEvent.ROLL_OUT,this.disableMouseWheelOnOut);
					this.m_content_txt.addEventListener(MouseEvent.ROLL_OVER,this.enableMouseWheelOnOver);
				}
				else
				{
					this.m_content_txt.removeEventListener(MouseEvent.ROLL_OUT,this.disableMouseWheelOnOut);
					this.m_content_txt.removeEventListener(MouseEvent.ROLL_OVER,this.enableMouseWheelOnOver);
				}
			}
		}
		
		private function addRemoveMouseWheelListener(param1:Boolean) : *
		{
			if(this.stage)
			{
				if(param1)
				{
					this.stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.handleMouseWheel);
					this.m_HasMouseWheelEvent = true;
				}
				else if(this.m_HasMouseWheelEvent)
				{
					this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL,this.handleMouseWheel);
					this.m_HasMouseWheelEvent = false;
				}
			}
		}
		
		private function disableMouseWheelOnOut(param1:MouseEvent) : *
		{
			this.mouseWheelEnabled = false;
		}
		
		private function enableMouseWheelOnOver(param1:MouseEvent) : *
		{
			this.mouseWheelEnabled = true;
		}
		
		public function addContent(param1:TextField) : void
		{
			if(param1 == null)
			{
				return;
			}
			this.m_content_txt = param1;
			this.m_content_txt.mouseWheelEnabled = false;
			this.addRemoveMouseWheelListener(this.m_mouseWheelEnabled);
			this.scrollbarVisible();
			this.setLength(this.m_content_txt.height);
			this.position();
			this.resetHandle();
		}
		
		public function resetScrollbar() : *
		{
			this.setLength(this.m_content_txt.height);
			this.position();
			this.scrollbarVisible();
		}
		
		public function position() : void
		{
			if(this.m_content_txt)
			{
				this.x = this.m_content_txt.x + this.m_content_txt.width + this.m_sbSpacing;
				this.y = this.m_content_txt.y;
			}
		}
		
		public function resetHandle() : void
		{
			this.m_handle_mc.y = this.m_up_mc.y + this.m_up_mc.height;
			this.m_content_txt.scrollV = 0;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function resetHandleToBottom() : void
		{
			this.m_handle_mc.y = this.m_down_mc.y - this.m_handle_mc.height;
			this.m_content_txt.scrollV = this.m_content_txt.maxScrollV;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function isContentAtBottom() : Boolean
		{
			return Boolean(this.m_content_txt.scrollV == this.m_content_txt.maxScrollV);
		}
		
		public function scrollbarVisible() : *
		{
			if(this.m_content_txt.maxScrollV > 1)
			{
				this.visible = true;
				this.alpha = 1;
				this.m_disabled = false;
			}
			else
			{
				if(!this.m_hideWhenDisabled)
				{
					this.visible = true;
					this.alpha = this.m_disabledAlpha;
				}
				else
				{
					this.visible = false;
				}
				this.m_disabled = true;
			}
		}
		
		public function get mouseWheelEnabled() : Boolean
		{
			return this.m_mouseWheelEnabled;
		}
		
		public function set mouseWheelEnabled(param1:Boolean) : *
		{
			if(this.m_mouseWheelEnabled != param1)
			{
				this.m_mouseWheelEnabled = param1;
				this.addRemoveMouseWheelListener(this.m_mouseWheelEnabled);
			}
		}
		
		public function set disabled(param1:Boolean) : void
		{
			this.m_disabled = param1;
		}
		
		public function get disabled() : Boolean
		{
			return this.m_disabled;
		}
		
		private function onUpdateScroll() : *
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function scrollTo(param1:Number, param2:Boolean = false) : void
		{
			if(param2)
			{
				if(this.m_scrollTween)
				{
					this.m_scrollTween.stop();
				}
				this.m_scrollTween = new larTween(this.m_content_txt,"scrollV",this.m_scrollFunc,this.m_content_txt.scrollV,param1,this.m_scrollTime);
				this.m_scrollTween.onUpdate = this.onUpdateScroll;
			}
			else
			{
				this.m_content_txt.scrollV = param1;
				dispatchEvent(new Event(Event.CHANGE));
			}
			this.m_handle_mc.y = Math.round((this.m_content_txt.scrollV - 1) / (this.m_content_txt.maxScrollV - 1) * this.m_scrollerDiff + this.m_up_mc.y + this.m_up_mc.height);
			if(this.m_handle_mc.y < this.m_up_mc.y + this.m_up_mc.height)
			{
				this.m_handle_mc.y = this.m_up_mc.y + this.m_up_mc.height;
			}
		}
		
		private function scrollToPrecent(param1:Number, param2:Boolean) : void
		{
			if(param1 > 1)
			{
				param1 = 1;
			}
			this.m_content_txt.scrollV = int(this.m_content_txt.maxScrollV * param1);
			dispatchEvent(new Event(Event.CHANGE));
			this.m_handle_mc.y = Math.round((this.m_content_txt.scrollV - 1) / (this.m_content_txt.maxScrollV - 1) * this.m_scrollerDiff + this.m_up_mc.y + this.m_up_mc.height);
		}
		
		public function set ScaleBG(param1:Boolean) : *
		{
			this.m_scaleBG = param1;
		}
		
		public function get ScaleBG() : Boolean
		{
			return this.m_scaleBG;
		}
		
		public function setLength(param1:Number) : void
		{
			if(this.m_positionButtons)
			{
				this.m_up_mc.y = this.m_ffUpH;
				if(this.m_FFdown_mc)
				{
					this.m_FFdown_mc.y = param1 - this.m_FFdown_mc.height;
				}
				this.m_down_mc.y = param1 - this.m_down_mc.height - this.m_ffDownH;
				if(this.m_scaleBG)
				{
					this.m_bg_mc.height = this.m_down_mc.y - (this.m_up_mc.y + this.m_up_mc.height);
					this.m_bg_mc.y = this.m_up_mc.y + this.m_up_mc.height;
				}
				if(param1 < 90)
				{
					this.m_handle_mc.visible = false;
				}
				else
				{
					this.m_handle_mc.visible = true;
				}
				this.setScrollDiff();
			}
		}
		
		public function adjustScrollHandle(param1:Number) : void
		{
			if(!this.m_disabled)
			{
				if(this.m_content_txt.maxScrollV > 1)
				{
					this.m_content_txt.scrollV = this.m_content_txt.scrollV - param1;
					this.m_handle_mc.y = Math.round((this.m_content_txt.scrollV - 1) / (this.m_content_txt.maxScrollV - 1) * this.m_scrollerDiff + this.m_up_mc.y + this.m_up_mc.height);
					if(this.m_handle_mc.y < this.m_up_mc.y + this.m_up_mc.height)
					{
						this.m_handle_mc.y = this.m_up_mc.y + this.m_up_mc.height;
					}
				}
			}
		}
		
		private function handleMouseWheel(param1:MouseEvent) : void
		{
			if(!this.m_disabled)
			{
				this.adjustScrollHandle(param1.delta);
			}
		}
		
		private function handlePressed(param1:Event) : *
		{
			if(!this.m_disabled)
			{
				ExternalInterface.call("PlaySound",this.SND_Press);
				this.m_handle_mc.gotoAndStop(2);
				this.m_last_Y = mouseY - this.m_handle_mc.y;
				stage.addEventListener("mouseUp",this.handleReleased);
				stage.addEventListener("mouseMove",this.handleMove);
			}
		}
		
		private function handleReleased(param1:Event) : *
		{
			if(!this.m_disabled)
			{
				this.m_handle_mc.gotoAndStop(1);
				stage.removeEventListener("mouseUp",this.handleReleased);
				stage.removeEventListener("mouseMove",this.handleMove);
			}
		}
		
		private function handleMove(param1:Event) : *
		{
			if(!this.m_disabled)
			{
				if(this.mouseY - this.m_last_Y < this.m_up_mc.y + this.m_up_mc.height)
				{
					this.m_handle_mc.y = this.m_up_mc.y + this.m_up_mc.height;
					this.m_content_txt.scrollV = 0;
				}
				else if(this.mouseY - this.m_last_Y >= this.m_scrollerDiff + this.m_up_mc.y + this.m_up_mc.height)
				{
					this.m_handle_mc.y = this.m_scrollerDiff + this.m_up_mc.y + this.m_up_mc.height;
					this.m_content_txt.scrollV = this.m_content_txt.maxScrollV;
				}
				else
				{
					this.m_handle_mc.y = this.mouseY - this.m_last_Y;
					this.m_content_txt.scrollV = (this.m_handle_mc.y - (this.m_up_mc.y + this.m_up_mc.height)) / this.m_scrollerDiff * (this.m_content_txt.maxScrollV - 1) + 1;
				}
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		private function upDown(param1:Event) : *
		{
			if(!this.m_disabled)
			{
				ExternalInterface.call("PlaySound",this.SND_Press);
				this.m_up_mc.gotoAndStop(3);
				this.scrollUp();
				this.startAutoScroll(true);
			}
		}
		
		private function downDown(param1:Event) : *
		{
			if(!this.m_disabled)
			{
				ExternalInterface.call("PlaySound",this.SND_Press);
				this.scrollDown();
				this.m_down_mc.gotoAndStop(3);
				this.startAutoScroll(false);
			}
		}
		
		public function scrollUp() : *
		{
			this.adjustScrollHandle(this.m_SCROLLSPEED);
		}
		
		public function scrollDown() : *
		{
			this.adjustScrollHandle(-this.m_SCROLLSPEED);
		}
		
		private function onUp(param1:Event) : *
		{
			if(!this.m_disabled)
			{
				ExternalInterface.call("PlaySound",this.SND_Release);
				param1.currentTarget.gotoAndStop(1);
				this.stopAutoScroll();
			}
		}
		
		private function ffDownDown(param1:Event) : *
		{
			if(!this.m_disabled)
			{
				this.scrollTo(this.m_content_txt.maxScrollV,this.m_animateScrolling);
				this.m_FFdown_mc.gotoAndStop(3);
			}
		}
		
		private function ffUpDown(param1:Event) : *
		{
			if(!this.m_disabled)
			{
				this.scrollTo(0,this.m_animateScrolling);
				this.m_FFup_mc.gotoAndStop(3);
			}
		}
		
		function onOver(param1:Event) : *
		{
			var val2:MovieClip = param1.currentTarget as MovieClip;
			if(!this.m_disabled)
			{
				val2.gotoAndStop(2);
			}
		}
		
		function onOut(param1:Event) : *
		{
			var val2:MovieClip = param1.currentTarget as MovieClip;
			if(!this.m_disabled)
			{
				val2.gotoAndStop(1);
				this.stopAutoScroll();
			}
		}
		
		public function startAutoScroll(param1:Boolean) : *
		{
			if(this.m_scrollTimer)
			{
				this.m_scrollTimer.reset();
				this.m_scrollTimer.stop();
			}
			this.m_currentScrollDown = param1;
			this.m_currentScrollDelay = this.m_initialScrollDelay;
			this.m_scrollTimer = new Timer(this.m_currentScrollDelay);
			this.m_scrollTimer.addEventListener(TimerEvent.TIMER,this.onScrollTimer);
			this.m_scrollTimer.start();
		}
		
		private function onScrollTimer(param1:TimerEvent) : *
		{
			if(this.m_currentScrollDelay > this.m_minScrollDelay)
			{
				this.m_currentScrollDelay = this.m_currentScrollDelay * this.m_scrollMultiplier;
			}
			else
			{
				this.m_currentScrollDelay = this.m_minScrollDelay;
			}
			if(this.m_currentScrollDown)
			{
				this.adjustScrollHandle(this.m_SCROLLSPEED);
			}
			else
			{
				this.adjustScrollHandle(-this.m_SCROLLSPEED);
			}
			this.m_scrollTimer.delay = this.m_currentScrollDelay;
		}
		
		public function stopAutoScroll() : *
		{
			if(this.m_scrollTimer)
			{
				this.m_scrollTimer.stop();
				this.m_scrollTimer = null;
			}
		}
		
		private function bgDown(param1:Event) : *
		{
			if(!this.m_disabled)
			{
				this.scrollToPrecent((this.mouseY - (this.m_up_mc.y + this.m_up_mc.height)) / this.m_scrollerDiff,this.m_animateScrolling);
			}
		}
	}
}
