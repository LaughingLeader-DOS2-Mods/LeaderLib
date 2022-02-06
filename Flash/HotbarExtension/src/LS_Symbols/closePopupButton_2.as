package LS_Symbols
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public dynamic class closePopupButton_2 extends MovieClip
	{
		public var bg_mc:MovieClip;
		public var base:MovieClip;
		
		public function closePopupButton_2()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onOut(e:MouseEvent) : *
		{
			removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.bg_mc.gotoAndStop(1);
		}
		
		public function onOver(e:MouseEvent) : *
		{
			this.bg_mc.gotoAndStop(2);
			Registry.ExtCall("PlaySound","UI_Generic_Over");
		}
		
		public function onUp(e:MouseEvent) : *
		{
			removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.bg_mc.gotoAndStop(2);
			Registry.ExtCall("PlaySound","UI_Generic_Click");
			//Registry.ExtCall("buttonPressed",2,0);
			Registry.ExtCall("requestCloseUI");
		}
		
		public function onDown(e:MouseEvent) : *
		{
			addEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.bg_mc.gotoAndStop(3);
		}
		
		internal function frame1() : void
		{
			addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
			this.base = parent as MovieClip;
		}
	}
}
