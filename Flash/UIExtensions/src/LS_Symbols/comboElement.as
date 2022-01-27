package LS_Symbols
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import LS_Classes.larCombo;
	
	public dynamic class comboElement extends MovieClip
	{
		public var sel_mc:MovieClip;
		public var text_txt:TextField;
		public var Combo:MovieClip;
		public var _item:Object;
		public var id:*;
		
		public function comboElement()
		{
			super();
			this.addFrameScript(0,this.frame1);
		}
		
		public function deselectElement() : *
		{
			this.text_txt.textColor = 11246731;
			this.text_txt.visible = true;
		}
		
		public function selectElement() : *
		{
			this.text_txt.textColor = 15132390;
			if(this.Combo.m_isOpen)
			{
				Registry.ExtCall("PlaySound","UI_Generic_Over");
			}
		}
		
		public function setSelectionText() : *
		{
		}
		
		public function onMouseOver(param1:MouseEvent) : *
		{
			this.setSelectionText();
			if(this.tooltip != null && this.tooltip != "")
			{
				Registry.ExtCall("showTooltip",this.tooltip);
			}
		}
		
		public function onMouseOut(param1:MouseEvent) : *
		{
			Registry.ExtCall("hideTooltip");
		}
		
		public function frame1() : *
		{
			this.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
		}
	}
}
