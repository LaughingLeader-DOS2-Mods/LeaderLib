package
{
	import LS_Classes.textEffect;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class Menu_button extends MovieClip
	{
		public var bg_mc:MovieClip;
		public var disable_mc:MovieClip;
		public var formHL_mc:MovieClip;
		public var label_txt:TextField;
		public var textY:Number;
		public var downEventStr:String;
		
		public function Menu_button()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function buttonOver(param1:Event = null) : *
		{
			this.bg_mc.gotoAndStop(2);
			ExternalInterface.call("PlaySound","UI_Generic_Over");
			ExternalInterface.call("menuButtonOver",this.id);
		}
		
		public function buttonOut(param1:Event = null) : *
		{
			this.bg_mc.gotoAndStop(1);
			this.label_txt.y = this.textY;
		}
		
		public function buttonPressed(param1:Event = null) : *
		{
			this.bg_mc.gotoAndStop(3);
			this.label_txt.y = this.textY + 3;
		}
		
		public function buttonReleased(param1:Event = null) : *
		{
			this.bg_mc.gotoAndStop(2);
			this.label_txt.y = this.textY;
			ExternalInterface.call("PlaySound","UI_Generic_Click");
			// LeaderLib Change from buttonPressed
			ExternalInterface.call("llbuttonPressed",this.id);
		}
		
		public function deselectElement() : *
		{
			this.bg_mc.gotoAndStop(1);
		}
		
		public function selectElement() : *
		{
			this.bg_mc.gotoAndStop(2);
		}
		
		public function handleEvent(eventId:String, param2:Boolean) : Boolean
		{
			var isHandled:Boolean = false;
			switch(eventId)
			{
				case "IE UIAccept":
					if(isDown)
					{
						this.buttonPressed(null);
					}
					else if(this.downEventStr == eventId)
					{
						this.buttonReleased(null);
						ExternalInterface.call("PlaySound","UI_Gen_Accept");
					}
					isHandled = true;
			}
			if(isHandled && isDown)
			{
				this.downEventStr = eventId;
			}
			else
			{
				this.downEventStr = "";
			}
			return isHandled;
		}
		
		function frame1() : *
		{
			this.label_txt.filters = textEffect.createStrokeFilter(0,1.2,1,1.4,3);
			this.textY = 24;
			this.downEventStr = "";
		}
	}
}
