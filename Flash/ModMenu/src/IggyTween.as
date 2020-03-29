package
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class IggyTween extends EventDispatcher
   {
      
      private static var _tweenObjects:Dictionary = new Dictionary(true);
       
      
      public var begin:Number;
      
      public var duration:Number;
      
      public var finish:Number;
      
      public var func:Function;
      
      public var isPlaying:Boolean;
      
      public var looping:Boolean;
      
      public var position:Number;
      
      public var useSeconds:Boolean;
      
      public var motionFinishCallback:Function = null;
      
      private var _time;
      
      private var _beginTime;
      
      private var _cachedDelta;
      
      private var _sprite:Sprite;
      
      private var _manageCollisions:Boolean;
      
      private var _useWeakRef:Boolean;
      
      private var _obj:Object;
      
      private var _prop:String;
      
      public function IggyTween(param1:Object, param2:String, param3:Function, param4:Number, param5:Number, param6:Number, param7:Boolean = false, param8:Boolean = false, param9:Boolean = false)
      {
         var d:Dictionary = null;
         var t:IggyTween = null;
         var obj:Object = param1;
         var prop:String = param2;
         var func:Function = param3;
         var begin:Number = param4;
         var finish:Number = param5;
         var duration:Number = param6;
         var useSeconds:Boolean = param7;
         var useWeakRef:Boolean = param8;
         var manageCollisions:Boolean = param9;
         super();
         if(manageCollisions)
         {
            d = _tweenObjects[obj];
            if(!d)
            {
               _tweenObjects[obj] = new Dictionary();
            }
            else
            {
               t = d[prop];
               if(t)
               {
                  t.stop();
                  t._cancel();
                  t.motionOverride();
               }
            }
         }
         this._sprite = new Sprite();
         this._obj = obj;
         this._prop = prop;
         if(func != null)
         {
            this.func = func;
         }
         else
         {
            this.func = function(param1:Number, param2:Number, param3:Number, param4:Number):*
            {
               return param2 + param3 * (param1 / param4);
            };
         }
         if(isNaN(begin))
         {
            this.begin = obj[prop];
         }
         else
         {
            this.begin = begin;
         }
         this.finish = finish;
         this.duration = duration;
         this.useSeconds = useSeconds;
         this._manageCollisions = manageCollisions;
         this._cachedDelta = this.finish - this.begin;
         this._useWeakRef = useWeakRef;
         if(manageCollisions)
         {
            _tweenObjects[obj][prop] = this;
         }
         this.isPlaying = false;
         this.start();
      }
      
      public function motionStart() : *
      {
      }
      
      public function motionStop() : *
      {
      }
      
      public function motionResume() : *
      {
      }
      
      public function motionLoop() : *
      {
      }
      
      public function motionOverride() : *
      {
      }
      
      public function motionFinish() : *
      {
         if(this.motionFinishCallback != null)
         {
            this.motionFinishCallback();
         }
      }
      
      public function get obj() : Object
      {
         return this._obj;
      }
      
      public function get prop() : String
      {
         return this._prop;
      }
      
      public function get time() : Number
      {
         return this._time;
      }
      
      public function set time(param1:Number) : *
      {
         var _loc2_:* = undefined;
         if(param1 <= this.duration)
         {
            if(param1 < 0)
            {
               param1 = 0;
            }
            _loc2_ = this.func(param1,this.begin,this._cachedDelta,this.duration);
            this._time = param1;
            this.position = _loc2_;
            this._obj[this._prop] = _loc2_;
         }
         else if(this.looping)
         {
            this.time = 0;
            this.motionLoop();
         }
         else
         {
            if(this.useSeconds)
            {
               this.time = this.duration;
            }
            this.stop();
            this.motionFinish();
         }
      }
      
      public function continueTo(param1:Number, param2:Number = NaN) : *
      {
         this.begin = this.position;
         this.finish = param1;
         this._cachedDelta = this.finish - this.begin;
         if(!isNaN(param2))
         {
            this.duration = param2;
         }
         this.start();
      }
      
      public function fforward() : *
      {
         this._settime(this.duration);
      }
      
      public function nextFrame() : *
      {
         if(this.useSeconds)
         {
            this.time = (getTimer() - this._beginTime) / 1000;
         }
         else
         {
            this.time = this._time + 1;
         }
      }
      
      public function prevFrame() : *
      {
         if(!this.useSeconds)
         {
            this.time = this._time - 1;
         }
      }
      
      public function resume() : *
      {
         if(!this._obj)
         {
            return;
         }
         if(this.isPlaying)
         {
            return;
         }
         this._settime(this._time);
         this._startPlaying();
         this.motionResume();
      }
      
      public function rewind(param1:Number = 0) : *
      {
         this._settime(param1);
         this.time = this._time;
      }
      
      public function start() : *
      {
         if(!this._obj)
         {
            return;
         }
         this.rewind();
         if(!this.isPlaying)
         {
            this._startPlaying();
            this.motionStart();
         }
      }
      
      public function stop() : *
      {
         this._stopPlaying();
         this.motionStop();
      }
      
      public function yoyo() : *
      {
         this.continueTo(this.begin,this.time);
      }
      
      private function _settime(param1:Number) : *
      {
         this._time = param1;
         if(this.useSeconds)
         {
            this._beginTime = getTimer() - param1 * 1000;
         }
      }
      
      private function _cancel() : *
      {
         this._obj = null;
      }
      
      private function _startPlaying() : *
      {
         this.isPlaying = true;
         this._sprite.addEventListener(Event.ENTER_FRAME,this._onEnterFrame,false,0,this._useWeakRef);
         if(this._manageCollisions)
         {
            _tweenObjects[this._obj][this._prop] = this;
         }
      }
      
      private function _stopPlaying() : *
      {
         this.isPlaying = false;
         this._sprite.removeEventListener(Event.ENTER_FRAME,this._onEnterFrame);
         if(this._manageCollisions)
         {
            _tweenObjects[this._obj][this._prop] = null;
         }
      }
      
      private function _onEnterFrame(param1:Event) : *
      {
         this.nextFrame();
      }
   }
}
