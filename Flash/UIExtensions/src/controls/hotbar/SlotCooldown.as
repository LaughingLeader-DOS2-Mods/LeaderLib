package controls.hotbar
{
	import LS_Classes.textEffect;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	public dynamic class SlotCooldown extends MovieClip
	{
		public var cd_txt:TextField;
		public var mask_mc:MovieClip;
		public var lineOpacity:Number;
		public var rot:Number;
		public var cellSize:Number;
		
		public function SlotCooldown()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function setCoolDown(cd:Number) : *
		{
			this.cd_txt.filters = textEffect.createStrokeFilter(0xffffff,1.2,0.8,1,3);
			this.cd_txt.text = int(Math.ceil(cd)).toString();
			this.cd_txt.background = false;
			this.cd_txt.border = false;
			var isInCombat:Boolean = (root as MovieClip).isInCombat;
			if(isInCombat)
			{
				this.lineOpacity = 0;
			}
			else
			{
				this.lineOpacity = 1;
			}
			this.mask_mc.drawWedge(this.cellSize * 0.5,this.cellSize * 0.5,this.cellSize,(1 - cd) * 6 * 60 - 90,270,0.6,this.lineOpacity,2);
		}
		
		public function onDraw(e:Event) : *
		{
			this.mask_mc.drawWedge(this.cellSize * 0.5,this.cellSize * 0.5,this.cellSize,this.rot,270);
		}
		
		public function drawDone() : *
		{
			removeEventListener(Event.ENTER_FRAME,this.onDraw);
			if(this.rot == 270)
			{
				this.mask_mc.deleteWedge();
			}
			(parent as MovieClip).isEnabled = true;
		}
		
		public function frame1() : *
		{
			this.lineOpacity = 1;
			this.rot = -90;
			this.cellSize = 50;
			scrollRect = new Rectangle(0,0,this.cellSize,this.cellSize);
		}
	}
}
