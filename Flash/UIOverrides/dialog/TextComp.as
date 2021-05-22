package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import LS_Classes.tooltipHelper;
	
	public dynamic class TextComp extends MovieClip
	{
		public var frame_mc:MovieClip;
		public var icon_mc:IggyImg;
		public var text_txt:TextField;
		
		public function TextComp()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function elementInView(b:Boolean) : *
		{
			if(this.text_txt.visible != b) {
				if(!b) {
					this.disableInput();
				} else {
					this.enableInput();
				}
			}
			this.text_txt.visible = b;
		}

		public function enableInput() : *
		{
			addEventListener(MouseEvent.MOUSE_MOVE,this.onOver);
			addEventListener(MouseEvent.ROLL_OUT,this.onOut);
		}
		
		public function disableInput() : *
		{
			removeEventListener(MouseEvent.MOUSE_MOVE,this.onOver);
			removeEventListener(MouseEvent.ROLL_OUT,this.onOut);
		}

		public function onOver(e:MouseEvent) : *
		{
			var pt:Point = tooltipHelper.getGlobalPositionOfMC(this,this.root);
			pt.x += text_txt.x;
			var xCheck:Number = Math.max(0, Math.floor(text_txt.mouseX));
			var yCheck:Number = Math.max(0, Math.floor(text_txt.mouseY));
			//trace(e.localX, e.localY, text_txt.mouseX, text_txt.mouseY, text_txt.x, text_txt.y)
			var index:int = text_txt.getCharIndexAtPoint(xCheck, yCheck);
			ExternalInterface.call("dialogTextHovered", text_txt.htmlText, index, pt.x, pt.y, this.nametxt, this.dialogtxt, this.playerID, xCheck, yCheck);
		}
		
		public function onOut(e:MouseEvent) : *
		{
			ExternalInterface.call("hideTooltip");
		}
		
		private function frame1() : *
		{
			this.enableInput();
		}
	}
}
