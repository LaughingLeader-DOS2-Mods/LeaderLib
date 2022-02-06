package LS_Classes
{
   import fl.motion.easing.Linear;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
      
   public class scrollbar extends MovieClip
   {
      public var SND_Over:String = "UI_Generic_Over";
      public var SND_Click:String = "UI_Generic_Click";
      public var SND_Release:String = "";
      public var m_down_mc:MovieClip;
      public var m_up_mc:MovieClip;
      public var m_FFdown_mc:MovieClip = null;
      public var m_FFup_mc:MovieClip = null;
      public var m_handle_mc:MovieClip;
      public var m_bg_mc:MovieClip;
      public var m_scrolledY:Number = 0;
      public var m_scrollWheelMod:Number = 1;
      public var m_extraSpacing:Number = 0;
      public var m_positionButtons:Boolean = true;
      public var m_hideWhenDisabled:Boolean = true;
      public var m_animateScrolling:Boolean = false;
      public var m_normaliseScrolling:Boolean = false;
      public var m_contentFrameHeight:Number = -1;
      public var m_contentHeight:Number = -1;
      public var m_scrollingFunction:Function = null;
      public var m_contentSizeDisc:Number = 0;
      public var m_initialScrollDelay:Number = 300;
      public var m_minScrollDelay:Number = 50;
      public var m_scrollMultiplier:Number = 0.55;
      public var m_autoScrollFasterDelay:Number = 1800;
      public var m_allowScrollAcceleration:Boolean = true;
      public var m_autoScrollDefaultMultiplier:Number = 4;
      public var m_autoScrollFasterMultiplier:Number = 3;
      public var m_tweenY:Number = 0;
      public var m_scrollOverShoot:Number = 0;
      public var m_SCROLLSPEED:Number = 10;
      public var m_NormalizeValue:Number = -1;
      public var m_DisabledAlpha:Number = 0.3;
      public var m_FullSizeBG:Boolean = false;
      public var m_CanDisableBG:Boolean = false;
      private var m_noContent:Boolean = false;
      protected var m_disabled:Boolean = false;
      protected var m_content_mc:DisplayObject;
      private var m_last_Y:Number = 0;
      protected var m_scrollerDiff:Number = 0;
      private var m_scaleBG:Boolean = false;
      private var m_customPaneHeight:Number = -1;
      private var m_handleResizable:Boolean = false;
      private var m_ffUpH:Number = 0;
      private var m_ffDownH:Number = 0;
      private var m_isAutoScrolling:Boolean = false;
      private var m_currentScrollDelay:Number = 200;
      protected var m_currentScrollDown:Boolean = true;
      private var m_autoScrollStartTime:Number = 0;
      private var m_autoScrollPrevTime:Number = 0;
      protected var m_mouseWheelEnabled:Boolean = false;
      private var m_hasWheelListener:Boolean = false;
      private var m_CustomStage:Stage = null;
      private var m_scrollLength:Number = 0;
      private var m_scrollAnimToY:Number = 0;
      private var m_scrollWheelPrevious:Number = 0;
      private var m_scrollWheelStepSize:Number = 0;
      private var m_scrollWheelTimer:Timer;
      private const m_scrollWheelAcceleration:Number = 0.5;
      private var m_movementTimeline:larTween;
      private var m_frameHit_mc:MovieClip;
      
      public function scrollbar(downClassName:String = "down_id", upClassName:String = "up_id", handleClassName:String = "handle_id", bgClassName:String = "scrollBg_id", ffDownClassName:String = "", ffUpClassName:String = "")
      {
         var ffDownClass:Class = null;
         var ffUpClass:Class = null;
         this.m_scrollWheelTimer = new Timer(100);
         super();
         this.m_tweenY = 0;
         var downClass:Class = downClassName == "" ? MovieClip: Registry.GetClass(downClassName);
         var upClass:Class = upClassName == "" ? MovieClip: Registry.GetClass(upClassName);
         var handleClass:Class = Registry.GetClass(handleClassName);
         var bgClass:Class = Registry.GetClass(bgClassName);
         this.m_down_mc = new downClass();
         this.m_up_mc = new upClass();
         this.m_handle_mc = new handleClass();
         this.m_bg_mc = new bgClass();
         this.m_scrollWheelTimer.addEventListener(TimerEvent.TIMER,this.onScrollWheelTimer);
         addChild(this.m_bg_mc);
         this.m_frameHit_mc = new MovieClip();
         var frameHitSprite:Sprite = new Sprite();
         frameHitSprite.graphics.lineStyle(0,16777215);
         frameHitSprite.graphics.beginFill(16777215);
         frameHitSprite.graphics.drawRect(0,0,10,10);
         frameHitSprite.graphics.endFill();
         this.m_frameHit_mc.addChild(frameHitSprite);
         frameHitSprite.alpha = 0;
         addChild(this.m_frameHit_mc);
         addChild(this.m_handle_mc);
         addChild(this.m_up_mc);
         addChild(this.m_down_mc);
         var widthVal:Number = this.m_bg_mc.width;
         if(widthVal < this.m_up_mc.width)
         {
            widthVal = this.m_up_mc.width;
         }
         if(widthVal < this.m_down_mc.width)
         {
            widthVal = this.m_down_mc.width;
         }
         if(widthVal < this.m_handle_mc.width)
         {
            widthVal = this.m_handle_mc.width;
         }
         this.m_bg_mc.x = Math.round((widthVal - this.m_bg_mc.width) * 0.5);
         this.m_up_mc.x = Math.round((widthVal - this.m_up_mc.width) * 0.5);
         this.m_down_mc.x = Math.round((widthVal - this.m_down_mc.width) * 0.5);
         this.m_handle_mc.x = Math.round((widthVal - this.m_handle_mc.width) * 0.5);
         this.m_frameHit_mc.width = widthVal;
         if(ffDownClassName != "")
         {
            ffDownClass = Registry.GetClass(ffDownClassName);
            this.m_FFdown_mc = new ffDownClass();
            addChild(this.m_FFdown_mc);
            this.m_FFdown_mc.addEventListener("mouseUp",this.onUp);
            this.m_FFdown_mc.addEventListener("mouseDown",this.ffDownDown);
            this.m_FFdown_mc.addEventListener("mouseOut",this.onOut);
            this.m_FFdown_mc.addEventListener("mouseOver",this.onOver);
            this.m_FFdown_mc.x = Math.round((widthVal - this.m_FFdown_mc.width) * 0.5);
            this.m_ffDownH = this.m_FFdown_mc.height;
         }
         if(ffUpClassName != "")
         {
            ffUpClass = Registry.GetClass(ffUpClassName);
            this.m_FFup_mc = new ffUpClass();
            addChild(this.m_FFup_mc);
            this.m_FFup_mc.addEventListener("mouseUp",this.onUp);
            this.m_FFup_mc.addEventListener("mouseDown",this.ffUpDown);
            this.m_FFup_mc.addEventListener("mouseOut",this.onOut);
            this.m_FFup_mc.addEventListener("mouseOver",this.onOver);
            this.m_FFup_mc.x = Math.round((widthVal - this.m_FFup_mc.width) * 0.5);
            this.m_ffUpH = this.m_FFup_mc.height;
         }
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
         this.m_frameHit_mc.addEventListener("mouseDown",this.bgDown);
         this.setScrollDiff();
      }
      
      public function setHandle(param1:Class) : *
      {
         removeChild(this.m_handle_mc);
         this.m_handle_mc = new param1();
         addChild(this.m_handle_mc);
         this.m_handle_mc.addEventListener("mouseOut",this.onOut);
         this.m_handle_mc.addEventListener("mouseDown",this.handlePressed);
         this.m_handle_mc.addEventListener("mouseOver",this.onOver);
         this.setScrollDiff();
      }
      
      private function setScrollDiff() : void
      {
         this.m_scrollerDiff = this.m_down_mc.y - (this.m_up_mc.y + this.m_up_mc.height) - this.m_handle_mc.height;
         this.m_frameHit_mc.height = Math.max(this.m_scrollerDiff + this.m_handle_mc.height,1);
         this.m_frameHit_mc.y = this.m_up_mc.y + this.m_up_mc.height;
      }
      
      public function addContent(param1:DisplayObject) : void
      {
         if(this.m_movementTimeline)
         {
            this.m_movementTimeline.stop();
            if(this.m_movementTimeline.onComplete != null)
            {
               this.m_movementTimeline.onComplete = null;
            }
         }
         this.m_content_mc = param1;
         this.m_noContent = false;
         if(this.m_content_mc && this.m_content_mc.scrollRect)
         {
            this.setLength(this.m_content_mc.scrollRect.height);
         }
         else
         {
            Registry.ExtCall("UIAssert","LS_Classes.scrollbar addContent done for a movieclip without scrollRect");
         }
      }
      
      public function noContent() : *
      {
         this.m_content_mc = null;
         this.m_noContent = true;
         this.m_disabled = false;
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
            if(this.m_mouseWheelEnabled)
            {
               if(this.m_CustomStage)
               {
                  this.m_CustomStage.addEventListener(MouseEvent.MOUSE_WHEEL,this.handleMouseWheel);
               }
               else if(this.stage)
               {
                  this.stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.handleMouseWheel);
                  this.m_CustomStage = this.stage;
               }
            }
            else if(this.m_CustomStage)
            {
               this.m_CustomStage.removeEventListener(MouseEvent.MOUSE_WHEEL,this.handleMouseWheel);
            }
            else if(this.stage)
            {
               this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL,this.handleMouseWheel);
            }
            else
            {
               Registry.ExtCall("UIAssert","mouseWheelEnabled in scrollbar class is missing not working, missing stage");
            }
         }
      }
      
      public function get content() : DisplayObject
      {
         return this.m_content_mc;
      }
      
      public function position() : void
      {
         if(this.m_content_mc && this.m_content_mc.scrollRect)
         {
            this.x = this.m_content_mc.x + this.m_content_mc.scrollRect.width;
            this.y = this.m_content_mc.y;
         }
      }
      
      public function set customPaneHeight(param1:Number) : *
      {
         this.m_customPaneHeight = param1;
         if(param1 < this.m_scrolledY)
         {
            this.adjustScrollHandle(param1);
         }
      }
      
      public function get customPaneHeight() : *
      {
         return this.m_customPaneHeight;
      }
      
      public function disableCustomPaneHeight() : *
      {
         this.m_customPaneHeight = -1;
      }
      
      public function get handleResize() : Boolean
      {
         return this.m_handleResizable;
      }
      
      public function set handleResize(param1:Boolean) : *
      {
         this.m_handleResizable = param1;
         if(param1 && this.m_content_mc && this.m_content_mc.scrollRect)
         {
            this.setLength(this.m_content_mc.scrollRect.height);
         }
      }
      
      public function set ScaleBG(param1:Boolean) : *
      {
         this.m_scaleBG = param1;
         if(param1)
         {
            if(this.m_content_mc)
            {
               this.setLength(!!this.m_FullSizeBG?Number(this.m_down_mc.y - this.m_up_mc.y + this.m_down_mc.height):Number(this.m_down_mc.y - this.m_up_mc.y - this.m_up_mc.height));
            }
            else if(this.m_scrollLength > 0)
            {
               this.m_bg_mc.height = this.m_scrollLength;
            }
         }
         else
         {
            this.m_bg_mc.scaleY = 1;
         }
      }
      
      public function resetContentPosition() : void
      {
         var val1:Rectangle = null;
         var val2:Number = NaN;
         if(this.m_content_mc)
         {
            val1 = this.m_content_mc.scrollRect;
            if(val1)
            {
               val2 = this.getContDiff();
               if(val2 < 0)
               {
                  val2 = 0;
               }
               this.m_scrolledY = val1.y = (this.m_handle_mc.y - (this.m_up_mc.height + this.m_up_mc.y)) / this.m_scrollerDiff * val2;
               this.m_content_mc.scrollRect = val1;
               dispatchEvent(new Event(Event.CHANGE));
            }
         }
      }
      
      public function addCustomStage(param1:Stage) : *
      {
         this.m_CustomStage = param1;
      }
      
      public function isContentAtBottom() : Boolean
      {
         return Boolean(this.m_scrolledY == this.getContDiff() || this.getContDiff() <= 0);
      }
      
      public function alignContentToBottom() : void
      {
         this.scrollTo(this.getContDiff());
      }
      
      public function resetHandle() : void
      {
         this.scrollTo(0);
      }
      
      public function canScroll() : Boolean
      {
         return Boolean(this.getContDiff() > 0);
      }
      
      public function resetHandleToBottom() : void
      {
         this.scrollTo(this.getContDiff());
      }
      
      public function scrollbarVisible() : *
      {
         var val1:Number = NaN;
         var val2:Rectangle = null;
         if(this.m_content_mc)
         {
            val1 = this.m_content_mc.transform.pixelBounds.height / this.m_content_mc.transform.concatenatedMatrix.d + this.m_extraSpacing;
            if(this.m_customPaneHeight != -1)
            {
               val1 = this.m_customPaneHeight;
            }
            else if(this.m_contentHeight != -1)
            {
               val1 = this.m_contentHeight + this.m_extraSpacing;
            }
            val2 = this.m_content_mc.scrollRect;
            if(val2)
            {
               if(val1 > this.getFrameHeight() + this.m_contentSizeDisc)
               {
                  if(this.m_hideWhenDisabled)
                  {
                     this.visible = true;
                  }
                  else
                  {
                     this.visible = true;
                     this.setDisabled(false);
                  }
                  this.m_disabled = false;
                  this.scrollTo(this.m_scrolledY);
               }
               else
               {
                  if(this.m_hideWhenDisabled)
                  {
                     this.visible = false;
                  }
                  else
                  {
                     this.visible = true;
                     this.setDisabled(true);
                  }
                  this.m_disabled = true;
                  val2.y = 0;
                  this.m_scrolledY = 0;
                  this.m_content_mc.scrollRect = val2;
                  dispatchEvent(new Event(Event.CHANGE));
               }
            }
         }
         else
         {
            this.visible = this.m_noContent;
         }
      }
      
      private function setDisabled(param1:Boolean) : *
      {
         this.INTSetMCDisabled(this.m_down_mc,param1);
         this.INTSetMCDisabled(this.m_up_mc,param1);
         this.INTSetMCDisabled(this.m_FFdown_mc,param1);
         this.INTSetMCDisabled(this.m_FFup_mc,param1);
         this.INTSetMCDisabled(this.m_handle_mc,param1);
         if(this.m_CanDisableBG)
         {
            this.INTSetMCDisabled(this.m_bg_mc,param1);
         }
         if(param1)
         {
            this.m_handle_mc.y = this.m_up_mc.y + this.m_up_mc.height;
         }
      }
      
      private function INTSetMCDisabled(param1:MovieClip, param2:Boolean) : *
      {
         var val3:Number = NaN;
         if(param1)
         {
            if(param1.disabled_mc)
            {
               param1.disabled_mc.visible = param2;
            }
            else
            {
               val3 = 1;
               if(param2)
               {
                  val3 = this.m_DisabledAlpha;
               }
               param1.alpha = val3;
            }
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
      
      public function set scrolledY(param1:Number) : void
      {
         this.m_tweenY = this.m_scrollAnimToY = param1;
         this.INTScrolledY(param1);
      }
      
      private function INTScrolledY(param1:Number) : void
      {
         var val3:Number = NaN;
         var val2:Rectangle = new Rectangle();
         if(this.m_content_mc && this.m_content_mc.scrollRect)
         {
            val2 = this.m_content_mc.scrollRect;
         }
         if(val2)
         {
            val2.y = this.m_scrolledY = param1;
            val3 = 0;
            if(this.getContDiff() > 0)
            {
               val3 = this.m_scrolledY * this.m_scrollerDiff / this.getContDiff();
            }
            if(val3 < 0)
            {
               val3 = 0;
            }
            this.m_handle_mc.y = val3 + this.m_up_mc.y + this.m_up_mc.height;
            if(this.m_handle_mc.y > this.m_down_mc.y - this.m_handle_mc.height)
            {
               this.m_handle_mc.y = this.m_down_mc.y - this.m_handle_mc.height;
            }
            if(this.m_content_mc)
            {
               this.m_content_mc.scrollRect = val2;
            }
            dispatchEvent(new Event(Event.CHANGE));
         }
      }
      
      public function get scrolledY() : Number
      {
         return Math.round(this.m_scrolledY);
      }
      
      public function scrollToPercent(param1:Number, param2:Boolean) : void
      {
         if(param1 > 1)
         {
            param1 = 1;
         }
         var val3:uint = Math.round(param1 * 1000);
         param1 = val3 * 0.001;
         this.scrollTo(Math.round(this.getContDiff() * param1),param2);
      }
      
      protected function getContDiff() : Number
      {
         if(this.m_noContent)
         {
            return this.m_scrollLength - this.m_handle_mc.height;
         }
         var val1:Number = 0;
         if(this.m_customPaneHeight != -1)
         {
            val1 = this.m_customPaneHeight;
         }
         else if(this.m_contentHeight != -1)
         {
            val1 = this.m_contentHeight + this.m_extraSpacing;
         }
         else if(this.m_content_mc)
         {
            if(this.m_content_mc.transform)
            {
               val1 = this.m_content_mc.transform.pixelBounds.height / this.m_content_mc.transform.concatenatedMatrix.d + this.m_extraSpacing;
            }
            else
            {
               val1 = this.m_content_mc.height + this.m_extraSpacing;
            }
         }
         var val2:Number = this.getFrameHeight();
         return Math.round(val1 - val2);
      }
      
      private function getFrameHeight() : Number
      {
         var val2:Rectangle = null;
         var val1:Number = 0;
         if(this.m_contentFrameHeight != -1)
         {
            val1 = this.m_contentFrameHeight;
         }
         else if(this.m_content_mc)
         {
            val2 = this.m_content_mc.scrollRect;
            if(val2)
            {
               val1 = val2.height;
            }
         }
         return val1;
      }
      
      public function scrollToFit(param1:Boolean = false) : *
      {
         var val2:Rectangle = null;
         if(this.m_content_mc.scrollRect != null)
         {
            val2 = this.m_content_mc.scrollRect;
            if(this.m_scrolledY <= 0)
            {
               this.scrollTo(0,!!param1?false:Boolean(this.m_animateScrolling));
            }
            else if(this.m_scrolledY > this.getContDiff())
            {
               this.scrollTo(this.getContDiff(),!!param1?false:Boolean(this.m_animateScrolling));
            }
         }
      }
      
      public function scrollIntoView(param1:Number, param2:Number, param3:Boolean = false) : *
      {
         var val4:Number = NaN;
         var val5:Number = NaN;
         if(this.m_scrolledY >= param1 - this.m_scrollOverShoot)
         {
            this.scrollTo(param1 - this.m_scrollOverShoot,this.m_animateScrolling && !param3);
         }
         else
         {
            val4 = this.getFrameHeight();
            val5 = param1 + param2 + this.m_scrollOverShoot - val4;
            if(val4 > param2)
            {
               if(this.m_scrolledY < val5)
               {
                  this.scrollTo(val5,this.m_animateScrolling && !param3);
               }
            }
            else if(param1 + this.m_scrollOverShoot >= this.m_scrolledY + val4)
            {
               this.scrollTo(param1,this.m_animateScrolling && !param3);
            }
         }
      }
      
      public function scrollTo(param1:Number, param2:Boolean = false, param3:Boolean = false) : Boolean
      {
         var val6:Number = NaN;
         var val7:Number = NaN;
         if(this.m_disabled || !this.m_noContent && (!this.m_content_mc || this.m_content_mc.scrollRect == null))
         {
            return false;
         }
         var val4:Number = param1;
         var val5:Number = this.getContDiff();
         if(val5 < 0)
         {
            val5 = 0;
         }
         if(val4 <= 0)
         {
            val4 = 0;
         }
         else
         {
            val6 = this.m_NormalizeValue == -1?Number(this.m_SCROLLSPEED):Number(this.m_NormalizeValue);
            if(this.scrolledY < val4 && val4 > val5 - val6 * 0.1)
            {
               val4 = val5;
               param3 = false;
               if(this.m_scrollAnimToY == val4 || this.scrolledY == val4)
               {
                  return false;
               }
            }
            if(param3)
            {
               val4 = Math.round(val4 / val6) * val6;
            }
         }
         if(param2)
         {
            this.m_tweenY = this.m_scrolledY;
            if(this.m_movementTimeline)
            {
               this.m_movementTimeline.stop();
               if(this.m_movementTimeline.onComplete != null)
               {
                  this.m_movementTimeline.onComplete = null;
               }
            }
            val7 = this.m_currentScrollDelay * 0.001;
            this.m_movementTimeline = new larTween(this,"m_tweenY",Linear.easeNone,this.m_tweenY,val4,val7,this.INTMoveDone);
            this.m_movementTimeline.onUpdate = this.INTUpdatePos;
         }
         else
         {
            this.scrolledY = val4;
         }
         this.m_scrollAnimToY = Math.round(val4);
         return true;
      }
      
      private function INTUpdatePos() : void
      {
         this.INTScrolledY(this.m_tweenY);
         if(this.m_scrollingFunction != null)
         {
            this.m_scrollingFunction();
         }
      }
      
      private function INTMoveDone() : void
      {
         if(this.m_movementTimeline)
         {
            this.m_movementTimeline.onComplete = null;
         }
         this.INTScrolledY(this.m_scrollAnimToY);
         this.scrollbarVisible();
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
               this.m_bg_mc.height = param1 - (!this.m_FullSizeBG?this.m_down_mc.height + this.m_up_mc.height:0);
               if(this.m_FFup_mc)
               {
                  this.m_bg_mc.y = this.m_FFup_mc.y + (!this.m_FullSizeBG?this.m_FFup_mc.height:0);
               }
               else
               {
                  this.m_bg_mc.y = this.m_up_mc.y + (!this.m_FullSizeBG?this.m_up_mc.height:0);
               }
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
         this.m_scrollAnimToY = this.scrolledY = this.m_scrolledY;
         this.m_scrollLength = param1;
      }
      
      public function adjustScrollHandle(param1:Number, param2:Boolean = false, param3:Boolean = false) : Boolean
      {
         return this.scrollTo(this.m_scrollAnimToY + param1,param2,param3);
      }
      
      protected function handleMouseWheel(e:MouseEvent) : void
      {
         if(!this.m_disabled)
         {
            if(e.delta > 0 && this.m_scrollWheelPrevious < 0 || e.delta < 0 && this.m_scrollWheelPrevious > 0)
            {
               this.m_scrollWheelStepSize = 0;
            }
            this.m_scrollWheelPrevious = e.delta;
            this.m_scrollWheelStepSize = this.m_scrollWheelStepSize + this.m_scrollWheelPrevious * this.m_scrollWheelAcceleration;
            if(this.m_scrollWheelStepSize > 0 && this.m_scrollWheelStepSize < 1)
            {
               this.m_scrollWheelStepSize = 1;
            }
            else if(this.m_scrollWheelStepSize < 0 && this.m_scrollWheelStepSize > -1)
            {
               this.m_scrollWheelStepSize = -1;
            }
            this.adjustScrollHandle(this.m_scrollWheelStepSize * -(this.m_scrollWheelMod * this.m_SCROLLSPEED),this.m_animateScrolling,true);
            this.m_scrollWheelTimer.reset();
            this.m_scrollWheelTimer.start();
         }
      }
      
      private function onScrollWheelTimer(e:TimerEvent) : void
      {
         this.m_scrollWheelStepSize = this.m_scrollWheelStepSize - this.m_scrollWheelPrevious * this.m_scrollWheelAcceleration;
         if(this.m_scrollWheelStepSize == 0)
         {
            this.m_scrollWheelStepSize = 0;
            this.m_scrollWheelTimer.stop();
         }
      }
      
      private function handlePressed(e:Event) : *
      {
         if(!this.m_disabled)
         {
            Registry.ExtCall("PlaySound",this.SND_Click);
            this.m_handle_mc.gotoAndStop(3);
            this.m_last_Y = mouseY - this.m_handle_mc.y;
            stage.addEventListener("mouseUp",this.handleReleased);
            stage.addEventListener("mouseMove",this.handleMove);
         }
      }
      
      private function handleReleased(e:Event) : *
      {
         var val2:Number = NaN;
         if(!this.m_disabled)
         {
            Registry.ExtCall("PlaySound",this.SND_Release);
            this.m_handle_mc.gotoAndStop(1);
            stage.removeEventListener("mouseUp",this.handleReleased);
            stage.removeEventListener("mouseMove",this.handleMove);
            val2 = this.m_NormalizeValue != -1?Number(this.m_NormalizeValue):Number(this.m_SCROLLSPEED);
            this.scrolledY = Math.round(this.m_scrolledY / val2) * val2;
         }
      }
      
      private function handleMove(e:Event) : *
      {
         var val2:Rectangle = null;
         var val3:Number = NaN;
         if(!this.m_disabled)
         {
            val2 = this.m_content_mc.scrollRect;
            if(val2)
            {
               val3 = this.getContDiff();
               if(this.mouseY - this.m_last_Y < this.m_up_mc.y + this.m_up_mc.height)
               {
                  this.m_handle_mc.y = this.m_up_mc.y + this.m_up_mc.height;
                  val2.y = 0;
               }
               else if(this.mouseY - this.m_last_Y >= this.m_scrollerDiff + (this.m_up_mc.y + this.m_up_mc.height))
               {
                  this.m_handle_mc.y = this.m_scrollerDiff + (this.m_up_mc.y + this.m_up_mc.height);
                  val2.y = val3;
               }
               else
               {
                  this.m_handle_mc.y = this.mouseY - this.m_last_Y;
                  val2.y = (this.m_handle_mc.y - (this.m_up_mc.y + this.m_up_mc.height)) * (val3 / this.m_scrollerDiff);
               }
               this.m_tweenY = this.m_scrolledY = val2.y;
               this.m_content_mc.scrollRect = val2;
               dispatchEvent(new Event(Event.CHANGE));
            }
         }
      }
      
      private function upDown(e:Event) : *
      {
         if(!this.m_disabled)
         {
            Registry.ExtCall("PlaySound",this.SND_Click);
            this.m_up_mc.gotoAndStop(3);
            this.startAutoScroll(false);
         }
      }
      
      private function downDown(e:Event) : *
      {
         if(!this.m_disabled)
         {
            Registry.ExtCall("PlaySound",this.SND_Click);
            this.m_down_mc.gotoAndStop(3);
            this.startAutoScroll(true);
         }
      }
      
      public function scrollUp() : *
      {
         this.adjustScrollHandle(-this.m_SCROLLSPEED,this.m_animateScrolling,this.m_normaliseScrolling);
      }
      
      public function scrollDown() : *
      {
         this.adjustScrollHandle(this.m_SCROLLSPEED,this.m_animateScrolling,this.m_normaliseScrolling);
      }
      
      private function ffDownDown(e:Event) : *
      {
         if(!this.m_disabled)
         {
            Registry.ExtCall("PlaySound",this.SND_Click);
            this.scrollTo(this.getContDiff(),this.m_animateScrolling);
            this.m_FFdown_mc.gotoAndStop(3);
         }
      }
      
      private function ffUpDown(e:Event) : *
      {
         if(!this.m_disabled)
         {
            Registry.ExtCall("PlaySound",this.SND_Click);
            this.scrollTo(0,this.m_animateScrolling);
            this.m_FFup_mc.gotoAndStop(3);
         }
      }
      
      public function onOver(e:Event) : *
      {
         var mc:MovieClip = e.currentTarget as MovieClip;
         if(!this.m_disabled)
         {
            Registry.ExtCall("PlaySound",this.SND_Over);
            mc.gotoAndStop(2);
         }
      }
      
      public function onOut(e:Event) : *
      {
         var mc:MovieClip = e.currentTarget as MovieClip;
         if(!this.m_disabled)
         {
            mc.gotoAndStop(1);
            if(mc != this.m_handle_mc)
            {
               this.m_currentScrollDown = false;
               this.stopAutoScroll();
            }
         }
      }
      
      private function onUp(e:Event) : *
      {
         if(!this.m_disabled)
         {
            Registry.ExtCall("PlaySound",this.SND_Release);
            e.currentTarget.gotoAndStop(1);
         }
         this.stopAutoScroll();
      }
      
      public function startAutoScroll(b:Boolean) : *
      {
         var val2:Date = null;
         if(!this.m_isAutoScrolling)
         {
            this.m_currentScrollDown = b;
            this.m_currentScrollDelay = 0;
            val2 = new Date();
            this.m_autoScrollPrevTime = this.m_autoScrollStartTime = val2.getTime();
            addEventListener(Event.ENTER_FRAME,this.onAutoScrolling);
            this.m_isAutoScrolling = true;
         }
      }
      
      private function onAutoScrolling(e:Event) : *
      {
         var val5:Number = NaN;
         var val2:Number = new Date().getTime();
         var val3:Number = this.m_autoScrollDefaultMultiplier;
         var val4:Number = val2 - this.m_autoScrollPrevTime;
         if(this.m_allowScrollAcceleration && this.m_autoScrollStartTime + this.m_autoScrollFasterDelay < val2)
         {
            val3 = val3 * this.m_autoScrollFasterMultiplier;
         }
         if(val4 > 0)
         {
            val5 = (!!this.m_currentScrollDown?this.m_SCROLLSPEED:-this.m_SCROLLSPEED) * val3 * (val4 / 1000);
            if(!this.adjustScrollHandle(val5,false,false))
            {
               this.stopAutoScroll();
            }
            this.m_autoScrollPrevTime = val2;
         }
      }
      
      public function stopAutoScroll() : *
      {
         var val1:Number = NaN;
         if(this.m_isAutoScrolling)
         {
            this.m_currentScrollDelay = this.m_initialScrollDelay;
            removeEventListener(Event.ENTER_FRAME,this.onAutoScrolling);
            this.m_isAutoScrolling = false;
            if(this.m_normaliseScrolling)
            {
               val1 = 0;
               if(this.m_scrollAnimToY > this.getContDiff() - this.m_SCROLLSPEED * 0.3)
               {
                  val1 = this.getContDiff();
               }
               else
               {
                  val1 = Math.round(this.m_scrollAnimToY / this.m_SCROLLSPEED) * this.m_SCROLLSPEED;
               }
               if(val1 != this.m_scrolledY)
               {
                  this.scrollTo(val1);
               }
            }
         }
      }
      
      private function bgDown(e:Event) : *
      {
         if(!this.m_disabled)
         {
            Registry.ExtCall("PlaySound",this.SND_Click);
            this.scrollToPercent((this.mouseY - (this.m_up_mc.y + this.m_up_mc.height)) / this.m_scrollerDiff,this.m_animateScrolling);
         }
      }
   }
}
