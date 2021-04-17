package
{
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	public class ClientTimer extends Timer
	{
		public var name:String;
		public var removeOnTick:Boolean = false;

		private var parent:MainTimeline;

		public function ClientTimer(name:String, delay:Number, repeat:int, parent:MainTimeline)
		{
			super(delay, repeat);
			this.parent = parent;
			this.name = name;
			this.addEventListener(TimerEvent.TIMER_COMPLETE, this.onComplete);
			if (repeat != 1) {
				this.addEventListener(TimerEvent.TIMER, this.onTick);
			}
			this.removeOnTick = repeat != 1;
		}

		public function onComplete(event:TimerEvent) : *
		{
			ExternalInterface.call("LeaderLib_TimerComplete", this.name);
			this.dispose(true);
		}

		public function onTick(event:TimerEvent) : *
		{
			ExternalInterface.call("LeaderLib_TimerTick", this.name);
		}

		public function dispose(removeFromArray:Boolean = false) : *
		{
			this.removeEventListener(TimerEvent.TIMER_COMPLETE, this.onComplete);
			if(this.removeOnTick) {
				this.removeEventListener(TimerEvent.TIMER, this.onTick);
			}
			if (this.parent != null) {
				parent.removeTimer(this, removeFromArray);
			}
		}
	}
}