package contextMenu
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class ContextMenuEntry extends MovieClip
	{
		public var arrow_mc:MovieClip;
		public var hl_mc:MovieClip;
		public var text_txt:TextField;
		public var base:ContextMenuMC;
		public var selectedColor:uint;
		public var deSelectedColor:uint;
		public var clickSound:Boolean;
		public var text:String;
		
		public function ContextMenuEntry(parent:ContextMenuMC)
		{
			super();
			this.base = parent;
			addFrameScript(0,this.frame1);
		}
		
		public function deselectElement(e:MouseEvent) : *
		{
			this.hl_mc.alpha = 0;
			this.text_txt.textColor = this.deSelectedColor;
			this.text_txt.htmlText = this.text;
			ExternalInterface.call("PlaySound","UI_Generic_Over");
		}
		
		public function selectElement(e:MouseEvent) : *
		{
			this.hl_mc.alpha = 1;
			this.text_txt.textColor = this.selectedColor;
			this.text_txt.htmlText = this.text;
		}
		
		public function pressedButton() : *
		{
			if(!this.disabled)
			{
				ExternalInterface.call("LeaderLib_ContextMenu_EntryPressed",this.id,this.actionID,this.handle);
			}
		}
		
		public function buttonUp(e:MouseEvent) : *
		{
			removeEventListener(MouseEvent.MOUSE_UP,this.buttonUp);
			if(this.clickSound)
			{
				ExternalInterface.call("PlaySound","UI_GM_Generic_Click");
			}
			this.pressedButton();
		}
		
		public function buttonDown(e:MouseEvent) : *
		{
			addEventListener(MouseEvent.MOUSE_UP,this.buttonUp);
		}
		
		public function buttonOver(e:MouseEvent) : *
		{
			this.base.selectButton(this);
		}
		
		public function buttonOut(e:MouseEvent) : *
		{
			removeEventListener(MouseEvent.MOUSE_UP,this.buttonUp);
			this.base.selectButton(null);
		}
		
		public function frame1() : *
		{
			addEventListener(MouseEvent.MOUSE_DOWN,this.buttonDown);
			addEventListener(MouseEvent.ROLL_OVER,this.buttonOver);
			addEventListener(MouseEvent.ROLL_OUT,this.buttonOut);
		}
	}
}