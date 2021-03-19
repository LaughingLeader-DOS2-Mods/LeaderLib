package LS_Classes
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class coverFlow extends listDisplay
   {
       
      
      public var frameWidth:Number = 200;
      
      public var frameHeight:Number = 100;
      
      public var currentWidth:Number = 180;
      
      public var currentHeight:Number = 180;
      
      public var scaleMod:Number = 0.96;
      
      public var selectedScale:Number = 1;
      
      public var foldedXscale:Number = 0.9;
      
      public var foldedYscale:Number = 0.9;
      
      public var centerSpacing:Number = 10;
      
      public var listY:Number = 30;
      
      protected var m_displaySideCards:Number = 6;
      
      private var TweenDuration:Number = 0.4;
      
      public function coverFlow()
      {
         super();
      }
      
      override public function setFrameWidth(param1:Number) : *
      {
         this.frameWidth = param1;
         this.positionElements();
      }
      
      override public function setFrame(param1:Number, param2:Number) : *
      {
         this.frameWidth = param1;
         this.frameHeight = param2;
         this.positionElements();
      }
      
      override public function positionElements() : *
      {
         var _loc15_:MovieClip = null;
         if(content_array.length < 1)
         {
            return;
         }
         var _loc1_:* = 0;
         var _loc2_:Number = 0;
         var _loc3_:Number = content_array[0].width;
         var _loc4_:Number = (this.frameWidth - this.currentWidth) * 0.5 - this.centerSpacing;
         var _loc5_:Number = 0;
         var _loc6_:Number = 0;
         var _loc7_:Number = this.foldedYscale * this.selectedScale;
         var _loc8_:Number = this.foldedXscale * this.selectedScale;
         var _loc9_:Number = this.currentHeight * 0.5;
         var _loc10_:Number = 0;
         var _loc11_:MovieClip = getCurrentMovieClip();
         var _loc12_:Number = 0.45;
         var _loc13_:Number = 0.6;
         var _loc14_:Number = 2;
         if(!_loc11_)
         {
            return;
         }
         var _loc16_:Number = _loc11_.list_pos;
         var _loc17_:Number = 0;
         if(_loc16_ > 0)
         {
            _loc5_ = Math.round(_loc4_ / _loc14_);
            _loc2_ = Math.round(_loc4_);
            _loc6_ = _loc16_ - 1;
            _loc17_ = _loc16_ - this.m_displaySideCards;
            if(_loc17_ < 0)
            {
               _loc17_ = 0;
            }
            _loc1_ = _loc16_ - 1;
            while(_loc1_ >= _loc17_)
            {
               content_array[_loc1_].visible = true;
               containerContent_mc.setChildIndex(content_array[_loc1_],_loc1_);
               _loc10_ = _loc9_ - this.currentHeight * 0.5 * _loc7_;
               content_array[_loc1_].tempX = _loc2_;
               _loc15_ = content_array[_loc1_];
               stopElementMCTweens(_loc15_);
               _loc15_.list_tweenX = new larTween(_loc15_,"x",m_PositionTweenFunc,_loc15_.x,_loc2_,this.TweenDuration,removeTweenState,_loc15_.list_id);
               _loc15_.list_tweenY = new larTween(_loc15_,"y",m_PositionTweenFunc,_loc15_.y,_loc10_,this.TweenDuration);
               _loc15_.list_tweenScaleY = new larTween(_loc15_,"scaleY",m_PositionTweenFunc,_loc15_.scaleY,_loc7_,this.TweenDuration);
               _loc15_.list_tweenScaleX = new larTween(_loc15_,"scaleX",m_PositionTweenFunc,_loc15_.scaleX,_loc8_,this.TweenDuration);
               if(_loc7_ > _loc12_)
               {
                  _loc7_ = _loc7_ * this.scaleMod;
                  _loc8_ = _loc8_ * this.scaleMod;
               }
               if(_loc5_ > 1)
               {
                  _loc5_ = _loc5_ * _loc13_;
               }
               _loc2_ = _loc2_ - _loc5_;
               _loc1_--;
            }
            if(_loc17_ - 1 >= 0)
            {
               content_array[_loc17_ - 1].x = _loc2_;
               content_array[_loc17_ - 1].y = _loc10_;
               content_array[_loc17_ - 1].scaleY = _loc7_;
               content_array[_loc17_ - 1].scaleX = _loc8_;
            }
            _loc1_ = 0;
            while(_loc1_ < _loc17_)
            {
               content_array[_loc1_].visible = false;
               _loc1_++;
            }
         }
         content_array[_loc16_].visible = true;
         _loc10_ = _loc9_ - this.currentHeight * 0.5 * this.selectedScale;
         dispatchEvent(new Event("Positioning_Start"));
         _loc15_ = content_array[_loc16_];
         stopElementMCTweens(_loc15_);
         _loc15_.list_tweenX = new larTween(_loc15_,"x",m_PositionTweenFunc,_loc15_.x,this.frameWidth * 0.5,this.TweenDuration,this.positionElementsDone);
         _loc15_.list_tweenY = new larTween(_loc15_,"y",m_PositionTweenFunc,_loc15_.y,_loc10_,this.TweenDuration);
         _loc15_.list_tweenScaleY = new larTween(_loc15_,"scaleY",m_PositionTweenFunc,_loc15_.scaleY,this.selectedScale,this.TweenDuration);
         _loc15_.list_tweenScaleX = new larTween(_loc15_,"scaleX",m_PositionTweenFunc,_loc15_.scaleX,this.selectedScale,this.TweenDuration);
         containerContent_mc.setChildIndex(content_array[_loc16_],containerContent_mc.numChildren - 1);
         var _loc18_:Number = content_array.length - 1 - _loc16_;
         if(_loc18_ > 0)
         {
            _loc2_ = Math.round(this.frameWidth - _loc4_);
            _loc5_ = Math.round(_loc4_ / _loc14_);
            _loc6_ = containerContent_mc.numChildren - 2;
            _loc7_ = this.foldedYscale * this.selectedScale;
            _loc8_ = this.foldedXscale * this.selectedScale;
            _loc17_ = _loc16_ + 1 + this.m_displaySideCards;
            if(_loc17_ > content_array.length)
            {
               _loc17_ = content_array.length;
            }
            _loc1_ = _loc16_ + 1;
            while(_loc1_ < _loc17_)
            {
               content_array[_loc1_].visible = true;
               containerContent_mc.setChildIndex(content_array[_loc1_],_loc6_);
               _loc6_--;
               _loc10_ = _loc9_ - this.currentHeight * 0.5 * _loc7_;
               content_array[_loc1_].tempX = _loc2_;
               _loc15_ = content_array[_loc1_];
               stopElementMCTweens(_loc15_);
               _loc15_.list_tweenX = new larTween(_loc15_,"x",m_PositionTweenFunc,_loc15_.x,_loc2_,this.TweenDuration,removeTweenState,_loc15_.list_id);
               _loc15_.list_tweenY = new larTween(_loc15_,"y",m_PositionTweenFunc,_loc15_.y,_loc10_,this.TweenDuration);
               _loc15_.list_tweenScaleY = new larTween(_loc15_,"scaleY",m_PositionTweenFunc,_loc15_.scaleY,_loc7_,this.TweenDuration);
               _loc15_.list_tweenScaleX = new larTween(_loc15_,"scaleX",m_PositionTweenFunc,_loc15_.scaleX,_loc8_,this.TweenDuration);
               if(_loc7_ > _loc12_)
               {
                  _loc7_ = _loc7_ * this.scaleMod;
                  _loc8_ = _loc8_ * this.scaleMod;
               }
               if(_loc5_ > 1)
               {
                  _loc5_ = _loc5_ * _loc13_;
               }
               _loc2_ = _loc2_ + _loc5_;
               _loc1_++;
            }
            if(_loc17_ < content_array.length)
            {
               content_array[_loc17_].x = _loc2_;
               content_array[_loc17_].y = _loc10_;
               content_array[_loc17_].scaleY = _loc7_;
               content_array[_loc17_].scaleX = _loc8_;
            }
            _loc1_ = _loc17_;
            while(_loc1_ < content_array.length)
            {
               content_array[_loc1_].visible = false;
               _loc1_++;
            }
         }
      }
      
      private function positionElementsDone() : *
      {
         dispatchEvent(new Event("Positioning_Stop"));
      }
      
      override public function addElement(param1:DisplayObject, param2:Boolean = true, param3:Boolean = true) : *
      {
         if(!m_CurrentSelection && content_array.length > 0)
         {
            m_CurrentSelection = content_array[0];
         }
         super.addElement(param1,param2,param3);
      }
      
      override public function selectMC(param1:MovieClip, param2:Boolean = false) : *
      {
         super.selectMC(param1,param2);
         this.positionElements();
         dispatchEvent(new Event(Event.CHANGE));
      }
   }
}
