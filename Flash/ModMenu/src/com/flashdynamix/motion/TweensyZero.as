package com.flashdynamix.motion
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.BitmapFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class TweensyZero
   {
      
      public static const version:Number = 0.2;
      
      public static const TIME:String = "time";
      
      public static const FRAME:String = "frame";
      
      public static var defaultTween:Function = easeOut;
      
      public static var onUpdate:Function;
      
      public static var onUpdateParams:Array;
      
      public static var onComplete:Function;
      
      public static var onCompleteParams:Array;
      
      public static var lazyMode:Boolean = true;
      
      private static var _secondsPerFrame:Number = 1 / 30;
      
      private static var frame:Sprite = new Sprite();
      
      private static var time:int = 0;
      
      private static var _refreshType:String = "time";
      
      private static var _paused:Boolean = false;
      
      private static var list:Array = [];
      
      private static var filterDictionary:Dictionary = new Dictionary(true);
      
      public static var LSModversion = 1;
       
      
      public function TweensyZero()
      {
         super();
      }
      
      public static function to(param1:Object, param2:Object, param3:Number = 0.5, param4:Function = null, param5:Number = 0, param6:Object = null, param7:Function = null, param8:Array = null) : TweensyTimelineZero
      {
         var _loc10_:* = null;
         if(!hasTimelines)
         {
            startUpdate();
         }
         var _loc9_:TweensyTimelineZero = setup(param1,param3,param4,param5,param7,param8,param6);
         for(_loc10_ in param2)
         {
            _loc9_.to[_loc10_] = translate(param1[_loc10_],param2[_loc10_]);
            _loc9_.properties++;
         }
         add(_loc9_);
         return _loc9_;
      }
      
      public static function from(param1:Object, param2:Object, param3:Number = 0.5, param4:Function = null, param5:Number = 0, param6:Object = null, param7:Function = null, param8:Array = null) : TweensyTimelineZero
      {
         var _loc10_:* = null;
         if(!hasTimelines)
         {
            startUpdate();
         }
         var _loc9_:TweensyTimelineZero = setup(param1,param3,param4,param5,param7,param8,param6);
         for(_loc10_ in param2)
         {
            _loc9_.to[_loc10_] = param1[_loc10_];
            param1[_loc10_] = translate(param1[_loc10_],param2[_loc10_]);
            _loc9_.properties++;
         }
         add(_loc9_);
         return _loc9_;
      }
      
      public static function fromTo(param1:Object, param2:Object, param3:Object, param4:Number = 0.5, param5:Function = null, param6:Number = 0, param7:Object = null, param8:Function = null, param9:Array = null) : TweensyTimelineZero
      {
         var _loc11_:* = null;
         if(!hasTimelines)
         {
            startUpdate();
         }
         var _loc10_:TweensyTimelineZero = setup(param1,param4,param5,param6,param8,param9,param7);
         for(_loc11_ in param3)
         {
            _loc10_.to[_loc11_] = translate(param1[_loc11_],param3[_loc11_]);
            param1[_loc11_] = translate(param1[_loc11_],param2[_loc11_]);
            _loc10_.properties++;
         }
         add(_loc10_);
         return _loc10_;
      }
      
      private static function add(param1:TweensyTimelineZero) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:TweensyTimelineZero = null;
         var _loc5_:Number = NaN;
         var _loc6_:* = null;
         if(lazyMode)
         {
            _loc2_ = 0;
            _loc3_ = list.length;
            _loc2_ = _loc3_ - 1;
            while(_loc2_ >= 0)
            {
               _loc4_ = list[_loc2_];
               _loc5_ = _loc4_.delayStart + _loc4_.duration + _loc4_.delayEnd;
               if(_loc4_.key == param1.key && param1.delayStart < _loc5_ - _loc4_.time)
               {
                  for(_loc6_ in param1.to)
                  {
                     delete _loc4_.to[_loc6_];
                     delete _loc4_.from[_loc6_];
                     _loc4_.properties--;
                  }
                  if(_loc4_.properties == 0)
                  {
                     list.splice(_loc2_,1);
                  }
               }
               _loc2_--;
            }
         }
         list.push(param1);
      }
      
      private static function setup(param1:Object, param2:Number, param3:Function, param4:Number, param5:Function, param6:Array, param7:Object) : TweensyTimelineZero
      {
         var _loc9_:Array = null;
         var _loc8_:TweensyTimelineZero = new TweensyTimelineZero();
         _loc8_.instance = param1;
         _loc8_.duration = param2;
         _loc8_.ease = param3 != null?param3:defaultTween;
         _loc8_.delayStart = param4;
         _loc8_.update = param7;
         _loc8_.onComplete = param5;
         _loc8_.onCompleteParams = param6;
         _loc8_.key = param7 != null?param7:param1;
         if(param1 is BitmapFilter && param7 != null)
         {
            _loc9_ = filterDictionary[param7];
            if(_loc9_ == null || _loc9_.length != DisplayObject(param7).filters.length)
            {
               _loc9_ = filterDictionary[param7] = DisplayObject(param7).filters;
            }
            if(_loc9_.indexOf(param1) == -1)
            {
               _loc9_.push(param1);
            }
            DisplayObject(param7).filters = _loc9_;
         }
         return _loc8_;
      }
      
      public static function stop(param1:* = null, ... rest) : void
      {
         var _loc3_:TweensyTimelineZero = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:* = null;
         if(param1 is TweensyTimelineZero)
         {
            _loc3_ = param1 as TweensyTimelineZero;
            stop(_loc3_.instance);
         }
         else
         {
            _loc4_ = param1 is Array?param1:param1 == null?null:[param1];
            _loc5_ = list.length - 1;
            while(_loc5_ >= 0)
            {
               _loc3_ = list[_loc5_];
               if(_loc4_ == null || _loc4_.indexOf(_loc3_.key) != -1)
               {
                  if(rest.length == 0)
                  {
                     list.splice(_loc5_,1);
                  }
                  else
                  {
                     for(_loc6_ in _loc3_.to)
                     {
                        if(rest.indexOf(_loc6_) != -1)
                        {
                           delete _loc3_.to[_loc6_];
                           delete _loc3_.from[_loc6_];
                           _loc3_.properties--;
                        }
                     }
                     if(_loc3_.properties == 0)
                     {
                        list.splice(_loc5_,1);
                     }
                  }
               }
               _loc5_--;
            }
         }
         if(list.length == 0)
         {
            stopUpdate();
         }
      }
      
      public static function stopAll() : void
      {
         list.length = 0;
         stopUpdate();
      }
      
      public static function pause() : void
      {
         if(_paused)
         {
            return;
         }
         _paused = true;
         stopUpdate();
      }
      
      public static function resume() : void
      {
         if(!_paused)
         {
            return;
         }
         _paused = false;
         startUpdate();
      }
      
      public static function get paused() : Boolean
      {
         return _paused;
      }
      
      public static function set secondsPerFrame(param1:Number) : void
      {
         _secondsPerFrame = param1;
      }
      
      public static function get secondsPerFrame() : Number
      {
         return _secondsPerFrame;
      }
      
      public static function set refreshType(param1:String) : void
      {
         _refreshType = param1;
      }
      
      public static function get refreshType() : String
      {
         return _refreshType;
      }
      
      public static function get timelines() : int
      {
         return list.length;
      }
      
      public static function get hasTimelines() : Boolean
      {
         return timelines > 0;
      }
      
      private static function update(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         var _loc5_:TweensyTimelineZero = null;
         var _loc6_:Array = null;
         var _loc7_:Number = NaN;
         var _loc8_:* = false;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:* = null;
         var _loc12_:Number = NaN;
         if(refreshType == TIME)
         {
            _loc2_ = getTimer() - time;
            time = time + _loc2_;
            _loc2_ = _loc2_ * 0.001;
         }
         var _loc3_:int = 0;
         var _loc4_:int = list.length;
         _loc3_ = _loc4_ - 1;
         while(_loc3_ >= 0)
         {
            _loc5_ = list[_loc3_];
            _loc5_.time = _loc5_.time + _loc2_;
            if(_loc5_.time > _loc5_.delayStart)
            {
               _loc7_ = _loc5_.time - _loc5_.delayStart;
               _loc7_ = _loc7_ > _loc5_.duration?Number(_loc5_.duration):Number(_loc7_);
               _loc8_ = _loc7_ >= _loc5_.duration + _loc5_.delayEnd;
               _loc6_ = [_loc7_,0,1,_loc5_.duration].concat(_loc5_.easeParams);
               _loc9_ = _loc5_.ease.apply(null,_loc6_);
               _loc10_ = 1 - _loc9_;
               for(_loc11_ in _loc5_.to)
               {
                  if(_loc5_.from[_loc11_] == null)
                  {
                     _loc5_.from[_loc11_] = _loc5_.instance[_loc11_];
                  }
                  _loc12_ = _loc5_.from[_loc11_] * _loc10_ + _loc5_.to[_loc11_] * _loc9_;
                  if(_loc11_ == "currentFrame")
                  {
                     MovieClip(_loc5_.instance).gotoAndStop(int(_loc12_));
                  }
                  else
                  {
                     _loc5_.instance[_loc11_] = _loc12_;
                  }
               }
               if(_loc5_.update != null)
               {
                  if(_loc5_.instance is ColorTransform)
                  {
                     DisplayObject(_loc5_.update).transform.colorTransform = _loc5_.instance;
                  }
                  else if(_loc5_.instance is Matrix)
                  {
                     DisplayObject(_loc5_.update).transform.matrix = _loc5_.instance;
                  }
                  else if(_loc5_.instance is SoundTransform)
                  {
                     if(_loc5_.update is SoundChannel)
                     {
                        SoundChannel(_loc5_.update).soundTransform = _loc5_.instance;
                     }
                     else
                     {
                        Sprite(_loc5_.update).soundTransform = _loc5_.instance;
                     }
                  }
                  else if(_loc5_.instance is BitmapFilter)
                  {
                     DisplayObject(_loc5_.update).filters = filterDictionary[_loc5_.update];
                  }
               }
               if(_loc5_.onUpdate != null)
               {
                  _loc5_.onUpdate.apply(null,_loc5_.onUpdateParams);
               }
               if(_loc8_)
               {
                  if(_loc5_.onComplete != null)
                  {
                     _loc5_.onComplete.apply(null,_loc5_.onCompleteParams);
                  }
                  list.splice(_loc3_,1);
               }
            }
            _loc3_--;
         }
         if(onUpdate != null)
         {
            onUpdate.apply(null,onUpdateParams);
         }
         if(!hasTimelines)
         {
            stopUpdate();
            if(onComplete != null)
            {
               onComplete.apply(null,onCompleteParams);
            }
         }
      }
      
      private static function easeOut(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return param3 * ((param1 = param1 / param4 - 1) * param1 * param1 * param1 * param1 + 1) + param2;
      }
      
      private static function startUpdate() : void
      {
         time = getTimer();
         frame.addEventListener(Event.ENTER_FRAME,update,false,0,true);
      }
      
      private static function stopUpdate() : void
      {
         frame.removeEventListener(Event.ENTER_FRAME,update);
      }
      
      private static function translate(param1:Number, param2:*) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:Array = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(param2 is String)
         {
            _loc4_ = String(param2).split(",");
            if(_loc4_.length == 1)
            {
               _loc3_ = param1 + parseFloat(param2);
            }
            else
            {
               _loc5_ = parseFloat(_loc4_[0]);
               _loc6_ = parseFloat(_loc4_[1]);
               _loc3_ = param1 + _loc5_ + Math.random() * (_loc6_ - _loc5_);
            }
         }
         else
         {
            _loc3_ = param2;
         }
         return _loc3_;
      }
      
      public function toString() : String
      {
         return "TweensyZero " + version + " {timelines:" + timelines + "}";
      }
   }
}
