package LS_Classes
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
		private var _time:Number;
		private var _beginTime:Number;
		private var _cachedDelta:Number;
		private var _sprite:Sprite;
		private var _manageCollisions:Boolean;
		private var _useWeakRef:Boolean;
		private var _obj:Object;
		private var _prop:String;
		
		public function IggyTween(target:Object, propertyName:String, tweenFunc:Function, beginAt:Number, finishAt:Number, durationNum:Number, bUseSeconds:Boolean = false, bUseWeakRef:Boolean = false, bManageCollisions:Boolean = false)
		{
			var d:Dictionary = null;
			var t:IggyTween = null;
			var obj:Object = target;
			var prop:String = propertyName;
			var func:Function = tweenFunc;
			var begin:Number = beginAt;
			var finish:Number = finishAt;
			var duration:Number = durationNum;
			var useSeconds:Boolean = bUseSeconds;
			var useWeakRef:Boolean = bUseWeakRef;
			var manageCollisions:Boolean = bManageCollisions;
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
				this.func = function(a:Number, b:Number, c:Number, d:Number):Number
				{
					return b + c * (a / d);
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
		
		public function motionStart() : void
		{
		}
		
		public function motionStop() : void
		{
		}
		
		public function motionResume() : void
		{
		}
		
		public function motionLoop() : void
		{
		}
		
		public function motionOverride() : void
		{
		}
		
		public function motionFinish() : void
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
		
		public function set time(amount:Number) : void
		{
			var val2:* = undefined;
			if(amount <= this.duration)
			{
				if(amount < 0)
				{
					amount = 0;
				}
				val2 = this.func(amount,this.begin,this._cachedDelta,this.duration);
				this._time = amount;
				this.position = val2;
				this._obj[this._prop] = val2;
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
		
		public function continueTo(finishAt:Number, duration:Number = NaN) : void
		{
			this.begin = this.position;
			this.finish = finishAt;
			this._cachedDelta = this.finish - this.begin;
			if(!isNaN(duration))
			{
				this.duration = duration;
			}
			this.start();
		}
		
		public function fforward() : void
		{
			this._settime(this.duration);
		}
		
		public function nextFrame() : void
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
		
		public function prevFrame() : void
		{
			if(!this.useSeconds)
			{
				this.time = this._time - 1;
			}
		}
		
		public function resume() : void
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
		
		public function rewind(time:Number = 0) : void
		{
			this._settime(time);
			this.time = this._time;
		}
		
		public function start() : void
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
		
		public function stop() : void
		{
			this._stopPlaying();
			this.motionStop();
		}
		
		public function yoyo() : void
		{
			this.continueTo(this.begin,this.time);
		}
		
		private function _settime(time:Number) : void
		{
			this._time = time;
			if(this.useSeconds)
			{
				this._beginTime = getTimer() - time * 1000;
			}
		}
		
		private function _cancel() : void
		{
			this._obj = null;
		}
		
		private function _startPlaying() : void
		{
			this.isPlaying = true;
			this._sprite.addEventListener(Event.ENTER_FRAME,this._onEnterFrame,false,0,this._useWeakRef);
			if(this._manageCollisions)
			{
				_tweenObjects[this._obj][this._prop] = this;
			}
		}
		
		private function _stopPlaying() : void
		{
			this.isPlaying = false;
			this._sprite.removeEventListener(Event.ENTER_FRAME,this._onEnterFrame);
			if(this._manageCollisions)
			{
				_tweenObjects[this._obj][this._prop] = null;
			}
		}
		
		private function _onEnterFrame(e:Event) : void
		{
			this.nextFrame();
		}
	}
}
