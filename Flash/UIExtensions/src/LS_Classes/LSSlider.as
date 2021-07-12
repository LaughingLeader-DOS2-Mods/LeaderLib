package LS_Classes
{
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.utils.getDefinitionByName;
   
   public class LSSlider extends MovieClip
   {
      public var SND_Over:String = "UI_Generic_Over";
      public var SND_Down:String = "UI_MainMenu_Slider_Press";
      public var SND_Up:String = "UI_MainMenu_Slider_Release";
      private var m_disabled:Boolean = false;
      private var m_content_mc:MovieClip;
      private var m_SCROLLSPEED:Number = 10;
      private var m_last_X:Number = 0;
      private var m_scrollerDiff:Number = 0;
      public var m_right_mc:MovieClip;
      public var m_left_mc:MovieClip;
      public var m_handle_mc:MovieClip;
      public var m_bg_mc:MovieClip;
      public var m_visualBG_mc:MovieClip;
      public var m_notches_mc:MovieClip;
      private var m_bgToWidthDiff:Number = 0;
      private var m_liveDragging:Boolean = false;
      private var m_snapStepSize:Number = 1;
      private var m_scrolledX:Number = 0;
      private var m_value:Number = 0;
      private var m_max:Number = 100;
      private var m_min:Number = 0;
      private var m_handleResizable:Boolean = false;
      private var m_notchStr:String = "";
      private var m_useNotches:Boolean = false;
      private var m_handleDown:Boolean = false;
      private var m_handleOver:Boolean = false;
      public var m_NotchLeftOffset:Number = 0;
      public var m_NotchRightOffset:Number = 0;
      
      public function LSSlider(param1:String = "notch_id")
      {
         super();
         this.m_notchStr = param1;
         this.m_notches_mc = new MovieClip();
         addChild(this.m_notches_mc);
         var _loc2_:Number = this.m_bg_mc.height;
         if(this.m_left_mc)
         {
            if(_loc2_ < this.m_left_mc.height)
            {
               _loc2_ = this.m_left_mc.height;
            }
            this.m_left_mc.y = Math.round((_loc2_ - this.m_left_mc.height) * 0.5);
            this.m_left_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.upPressed);
            this.m_left_mc.addEventListener(MouseEvent.ROLL_OVER,this.upOn);
            this.m_left_mc.addEventListener(MouseEvent.ROLL_OUT,this.upOff);
            this.m_left_mc.addEventListener(MouseEvent.MOUSE_UP,this.onUp);
         }
         if(this.m_right_mc)
         {
            if(_loc2_ < this.m_right_mc.height)
            {
               _loc2_ = this.m_right_mc.height;
            }
            this.m_right_mc.y = Math.round((_loc2_ - this.m_right_mc.height) * 0.5);
            this.m_right_mc.x = this.m_bg_mc.width - this.m_right_mc.width;
            this.m_right_mc.addEventListener(MouseEvent.ROLL_OUT,this.downPressed);
            this.m_right_mc.addEventListener(MouseEvent.ROLL_OVER,this.downOff);
            this.m_right_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.downOn);
            this.m_right_mc.addEventListener(MouseEvent.MOUSE_UP,this.onUp);
         }
         if(this.m_handle_mc)
         {
            if(_loc2_ < this.m_handle_mc.height)
            {
               _loc2_ = this.m_handle_mc.height;
            }
            this.m_handle_mc.y = this.m_bg_mc.y - Math.round((this.m_handle_mc.height - this.m_bg_mc.height) * 0.5);
            this.m_handle_mc.addEventListener(MouseEvent.ROLL_OUT,this.handleOff);
            this.m_handle_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.handlePressed);
            this.m_handle_mc.addEventListener(MouseEvent.ROLL_OVER,this.handleOn);
            this.m_handle_mc.addEventListener(MouseEvent.MOUSE_UP,this.handleUp);
         }
         this.m_bg_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.BGPressed);
         this.m_bg_mc.addEventListener(MouseEvent.ROLL_OUT,this.downOff);
         this.m_bg_mc.addEventListener(MouseEvent.ROLL_OVER,this.downOn);
         this.m_bg_mc.addEventListener(MouseEvent.MOUSE_UP,this.onUp);
         this.m_scrollerDiff = this.m_right_mc.x - (this.m_left_mc.x + this.m_left_mc.width) - this.m_handle_mc.width + this.m_bgToWidthDiff;
      }
      
      public function set bgToWidthDiff(param1:Number) : *
      {
         this.m_bgToWidthDiff = param1;
         this.m_scrollerDiff = this.m_right_mc.x - (this.m_left_mc.x + this.m_left_mc.width) - this.m_handle_mc.width + this.m_bgToWidthDiff;
      }
      
      public function set useNotches(param1:Boolean) : *
      {
         this.m_useNotches = param1;
         if(this.m_useNotches)
         {
            this.setNotches(this.m_snapStepSize);
         }
      }
      
      public function get useNotches() : Boolean
      {
         return this.m_useNotches;
      }
      
      private function setNotches(param1:Number) : *
      {
         var _loc2_:Class = null;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:* = undefined;
         var _loc7_:MovieClip = null;
         if(this.m_notchStr != "" && this.m_useNotches && param1 != 0)
         {
            _loc2_ = getDefinitionByName(this.m_notchStr) as Class;
            this.removeChildrenOf(this.m_notches_mc);
            _loc3_ = int((this.m_max - this.m_min) / param1) + 1;
            if(_loc3_ > 1 && _loc2_)
            {
               _loc4_ = this.m_right_mc.x - this.m_left_mc.x - this.m_NotchLeftOffset - this.m_NotchRightOffset + this.m_bgToWidthDiff;
               _loc5_ = _loc4_ / (_loc3_ - 1);
               _loc6_ = 0;
               while(_loc6_ < _loc3_)
               {
                  _loc7_ = new _loc2_();
                  _loc7_.x = this.m_NotchLeftOffset + _loc5_ * _loc6_;
                  this.m_notches_mc.addChild(_loc7_);
                  _loc6_++;
               }
            }
         }
      }
      
      private function removeChildrenOf(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(param1.numChildren != 0)
         {
            _loc2_ = param1.numChildren;
            while(_loc2_ > 0)
            {
               _loc2_--;
               param1.removeChildAt(_loc2_);
            }
         }
      }
      
      public function setHandle(param1:Class) : *
      {
         removeChild(this.m_handle_mc);
         this.m_handle_mc = new param1();
         addChild(this.m_handle_mc);
         this.m_handle_mc.addEventListener(MouseEvent.ROLL_OUT,this.handleOff);
         this.m_handle_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.handlePressed);
         this.m_handle_mc.addEventListener(MouseEvent.ROLL_OVER,this.handleOn);
         this.m_handle_mc.addEventListener(MouseEvent.MOUSE_UP,this.onUp);
         this.m_scrollerDiff = this.m_right_mc.x - this.m_left_mc.width - this.m_handle_mc.width;
      }
      
      public function addMouseEvent(param1:MovieClip) : *
      {
         param1.addEventListener(MouseEvent.MOUSE_WHEEL,this.handleMouseWheel);
      }
      
      public function addMouseEventStage(param1:Stage) : *
      {
         param1.addEventListener(MouseEvent.MOUSE_WHEEL,this.handleMouseWheel);
      }
      
      public function removeMouseEventStage(param1:Stage) : *
      {
         param1.removeEventListener(MouseEvent.MOUSE_WHEEL,this.handleMouseWheel);
      }
      
      public function addContent(param1:MovieClip) : void
      {
         this.m_content_mc = param1;
         this.setWidth(this.m_content_mc.scrollRect.width);
      }
      
      public function position() : void
      {
         this.x = this.m_content_mc.x + this.m_content_mc.scrollRect.width;
         this.y = this.m_content_mc.y;
      }
      
      public function get handleResize() : Boolean
      {
         return this.m_handleResizable;
      }
      
      public function set handleResize(param1:Boolean) : *
      {
         this.m_handleResizable = param1;
         if(param1)
         {
            this.setWidth(this.m_content_mc.scrollRect.height);
         }
      }
      
      public function set ScrolledX(param1:Number) : *
      {
         this.setScrolledXInt(param1);
         this.m_handle_mc.x = this.m_scrolledX + (this.m_left_mc.x + this.m_left_mc.width);
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      private function setScrolledXInt(param1:Number) : *
      {
         this.m_value = this.m_min + Math.floor((param1 / this.m_scrollerDiff * (this.m_max - this.m_min) + this.m_snapStepSize * 0.5) / this.m_snapStepSize) * this.m_snapStepSize;
         this.m_value = int(Math.round(this.m_value * 100)) / 100;
         this.m_scrolledX = (this.m_value - this.m_min) / (this.m_max - this.m_min) * this.m_scrollerDiff;
      }
      
      public function get ScrolledX() : Number
      {
         return this.m_scrolledX;
      }
      
      public function get value() : Number
      {
         return this.m_value;
      }
      
      public function set value(param1:Number) : *
      {
         if(param1 < this.m_min)
         {
            param1 = this.m_min;
         }
         if(param1 > this.m_max)
         {
            param1 = this.m_max;
         }
         this.m_value = param1;
         this.m_scrolledX = (this.m_value - this.m_min) / (this.m_max - this.m_min) * this.m_scrollerDiff;
         this.m_handle_mc.x = this.m_scrolledX + (this.m_left_mc.x + this.m_left_mc.width);
      }
      
      public function get liveDragging() : Boolean
      {
         return this.m_liveDragging;
      }
      
      public function set liveDragging(param1:Boolean) : *
      {
         this.m_liveDragging = param1;
      }
      
      public function get snapInterval() : Number
      {
         return this.m_snapStepSize;
      }
      
      public function set snapInterval(param1:Number) : *
      {
         this.m_snapStepSize = param1;
         if(param1 > 1 && param1 < 11)
         {
            this.setNotches(param1);
         }
         else
         {
            this.setNotches(0);
         }
      }
      
      public function set minimum(param1:Number) : *
      {
         this.m_min = param1;
      }
      
      public function get minimum() : Number
      {
         return this.m_min;
      }
      
      public function set maximum(param1:Number) : *
      {
         this.m_max = param1;
      }
      
      public function get maximum() : Number
      {
         return this.m_max;
      }
      
      public function resetHandle() : void
      {
         this.ScrolledX = 0;
      }
      
      public function resetHandleToBottom() : void
      {
         this.ScrolledX = this.m_scrollerDiff;
      }
      
      public function set disabled(param1:Boolean) : void
      {
         this.m_disabled = param1;
      }
      
      public function get disabled() : Boolean
      {
         return this.m_disabled;
      }
      
      public function scrollTo(param1:Number) : void
      {
         var _loc2_:Number = param1;
         if(_loc2_ <= 0)
         {
            _loc2_ = 0;
         }
         else if(_loc2_ > this.m_scrollerDiff)
         {
            _loc2_ = this.m_scrollerDiff;
         }
         this.ScrolledX = _loc2_;
      }
      
      private function setWidth(param1:Number) : void
      {
         this.m_right_mc.x = param1 - this.m_right_mc.width;
         this.m_bg_mc.width = param1 - this.m_left_mc.width - this.m_right_mc.width;
         this.m_bg_mc.x = this.m_left_mc.width;
         this.m_handle_mc.x = this.m_left_mc.width;
         if(param1 < 90)
         {
            this.m_handle_mc.visible = false;
         }
         else
         {
            this.m_handle_mc.visible = true;
         }
         this.m_scrollerDiff = this.m_right_mc.x - this.m_left_mc.width - this.m_handle_mc.width;
      }
      
      private function adjustScrollHandle(param1:Number) : void
      {
         this.ScrolledX = this.ScrolledX + param1;
         if(this.ScrolledX <= 0)
         {
            this.ScrolledX = 0;
         }
         else if(this.ScrolledX > this.m_scrollerDiff)
         {
            this.ScrolledX = this.m_scrollerDiff;
         }
      }
      
      private function handleMouseWheel(param1:MouseEvent) : void
      {
         if(!this.m_disabled)
         {
            this.adjustScrollHandle(param1.delta * -3);
         }
      }
      
      private function handlePressed(param1:Event) : *
      {
         this.m_handleDown = true;
         if(!this.m_disabled)
         {
            ExternalInterface.call("PlaySound",this.SND_Down);
            this.m_handle_mc.gotoAndStop(3);
            this.m_last_X = mouseX - this.m_handle_mc.x;
            stage.addEventListener(MouseEvent.MOUSE_UP,this.handleReleased);
            stage.addEventListener(MouseEvent.MOUSE_MOVE,this.handleMove);
         }
      }
      
      private function handleUp(param1:Event) : *
      {
         if(!this.m_disabled)
         {
            ExternalInterface.call("PlaySound",this.SND_Up);
            if(this.m_handleOver)
            {
               this.m_handle_mc.gotoAndStop(2);
            }
            else
            {
               this.m_handle_mc.gotoAndStop(1);
            }
            dispatchEvent(new Event("handleReleased"));
         }
         this.m_handleDown = false;
      }
      
      private function handleReleased(param1:Event) : *
      {
         if(!this.m_disabled)
         {
            if(this.m_handleOver)
            {
               this.m_handle_mc.gotoAndStop(2);
            }
            else
            {
               this.m_handle_mc.gotoAndStop(1);
            }
            dispatchEvent(new Event("handleUp"));
            stage.removeEventListener(MouseEvent.MOUSE_UP,this.handleReleased);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.handleMove);
         }
         this.m_handleDown = false;
      }
      
      private function handleMove(param1:Event) : *
      {
         var _loc2_:Number = NaN;
         if(!this.m_disabled)
         {
            _loc2_ = 0;
            if(this.mouseX - this.m_last_X < this.m_left_mc.width)
            {
               this.m_handle_mc.x = this.m_left_mc.width;
               _loc2_ = 0;
            }
            else if(this.mouseX - this.m_last_X >= this.m_scrollerDiff + this.m_left_mc.width)
            {
               this.m_handle_mc.x = this.m_scrollerDiff + this.m_left_mc.width;
               _loc2_ = this.m_scrollerDiff;
            }
            else
            {
               this.m_handle_mc.x = this.mouseX - this.m_last_X;
               _loc2_ = this.m_handle_mc.x - this.m_left_mc.width;
            }
            if(this.m_liveDragging)
            {
               this.ScrolledX = _loc2_;
            }
            else
            {
               this.setScrolledXInt(_loc2_);
            }
         }
      }
      
      private function handleOff(param1:Event) : *
      {
         this.m_handleOver = false;
         if(!this.m_handleDown)
         {
            this.m_handle_mc.gotoAndStop(1);
            if(this.m_visualBG_mc)
            {
               this.m_visualBG_mc.gotoAndStop(1);
            }
         }
      }
      
      function handleOn(param1:Event) : *
      {
         if(!this.m_disabled)
         {
            this.m_handleOver = true;
            if(!this.m_handleDown)
            {
               ExternalInterface.call("PlaySound",this.SND_Over);
               this.m_handle_mc.gotoAndStop(2);
               if(this.m_visualBG_mc)
               {
                  this.m_visualBG_mc.gotoAndStop(2);
               }
            }
         }
      }
      
      function upOff(param1:Event) : *
      {
         if(!this.m_disabled)
         {
            this.m_left_mc.gotoAndStop(1);
         }
      }
      
      function upOn(param1:Event) : *
      {
         if(!this.m_disabled)
         {
            ExternalInterface.call("PlaySound",this.SND_Over);
            this.m_left_mc.gotoAndStop(2);
         }
      }
      
      private function upPressed(param1:Event) : *
      {
         if(!this.m_disabled)
         {
            ExternalInterface.call("PlaySound",this.SND_Up);
            this.m_left_mc.gotoAndStop(3);
            this.moveLeft();
         }
      }
      
      public function moveLeft() : *
      {
         this.adjustScrollHandle(-this.m_SCROLLSPEED);
      }
      
      public function moveRight() : *
      {
         this.adjustScrollHandle(this.m_SCROLLSPEED);
      }
      
      private function BGPressed(param1:Event) : *
      {
         if(!this.m_disabled)
         {
            ExternalInterface.call("PlaySound",this.SND_Up);
            this.scrollTo(this.m_bg_mc.mouseX - this.m_handle_mc.width * 0.5);
            dispatchEvent(new Event("bgPressed"));
         }
      }
      
      private function downPressed(param1:Event) : *
      {
         if(!this.m_disabled)
         {
            ExternalInterface.call("PlaySound",this.SND_Up);
            this.moveRight();
            this.m_right_mc.gotoAndStop(3);
         }
      }
      
      function downOn(param1:Event) : *
      {
         if(!this.m_disabled)
         {
            ExternalInterface.call("PlaySound",this.SND_Over);
            this.m_right_mc.gotoAndStop(2);
            if(this.m_visualBG_mc)
            {
               this.m_visualBG_mc.gotoAndStop(2);
            }
         }
      }
      
      function downOff(param1:Event) : *
      {
         if(!this.m_disabled)
         {
            this.m_right_mc.gotoAndStop(1);
            if(this.m_visualBG_mc)
            {
               this.m_visualBG_mc.gotoAndStop(1);
            }
         }
      }
      
      private function onUp(param1:Event) : *
      {
         if(!this.m_disabled)
         {
            param1.currentTarget.gotoAndStop(1);
         }
      }
   }
}
