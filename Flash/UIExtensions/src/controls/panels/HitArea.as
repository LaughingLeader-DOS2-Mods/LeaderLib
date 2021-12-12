package controls.panels
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public dynamic class HitArea extends MovieClip
	{
		public function HitArea()
		{
			super();
			this.addFrameScript(0,this.frame1);
		}
		
		public function onDown(e:MouseEvent) : *
		{
			stage.focus = null;
		}
		
		public function onUp(e:MouseEvent) : *
		{
			//Registry.ExtCall("onStopDraggingOnSkills");
		}
		
		private function frame1() : *
		{
			addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
			addEventListener(MouseEvent.MOUSE_UP,this.onUp);
			//addEventListener(MouseEvent.MOUSE_WHEEL,this.onScroll);
		}
	}
}
