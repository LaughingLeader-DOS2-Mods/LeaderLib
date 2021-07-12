package Controls.Panels
{
	import LS_Classes.scrollList;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import Controls.Buttons.MinimizeButton;
	import Controls.Buttons.CloseButton;
	import flash.external.ExternalInterface;
	import LS_Classes.LSPanelHelpers;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.display.Stage;
	
	public dynamic class BaseDraggablePanel extends MovieClip
	{
		public var windowDragStarted:Boolean = false;
		public var dragStartMP:Point;
		public var startDragDiff:uint = 20;
		public var dragTarget:MovieClip;

		public function BaseDraggablePanel()
		{
			super();
			this.addFrameScript(0,this.frame1);
		}

		private function get targetStage():Stage
		{
			return MainTimeline.Instance.stage;
		}

		public function dragPanelStart(e:MouseEvent):void
		{
			this.windowDragStarted = false;
			this.targetStage.addEventListener(MouseEvent.MOUSE_MOVE,this.dragPanelMove);
			this.dragStartMP.x = this.targetStage.mouseX;
			this.dragStartMP.y = this.targetStage.mouseY;
			this.targetStage.addEventListener(MouseEvent.MOUSE_UP,this.dragPanelStop);

			MainTimeline.Instance.mouseChildren = true;
			MainTimeline.Instance.mouseEnabled = true;
		}

		public function dragPanelMove(e:MouseEvent):void
		{
			if(!this.windowDragStarted)
			{
				if(this.dragStartMP.x + startDragDiff > this.targetStage.mouseX || this.dragStartMP.y + startDragDiff > this.targetStage.mouseY || this.dragStartMP.x - startDragDiff < this.targetStage.mouseX || this.dragStartMP.y - startDragDiff < this.targetStage.mouseY)
				{
					this.dragStartMP.x = this.targetStage.mouseX - this.x;
					this.dragStartMP.y = this.targetStage.mouseY - this.y;
					this.targetStage.focus = null;
					ExternalInterface.call("hideTooltip");
					//ExternalInterface.call("startMoveWindow");
					//this.targetStage.removeEventListener(MouseEvent.MOUSE_MOVE,this.dragPanelMove);
					this.windowDragStarted = true;
				}
			}
			else
			{
				// var pos:Point = this.globalToLocal(new Point(this.targetStage.mouseX,this.targetStage.mouseY));
				// this.x = pos.x;
				// this.y = pos.y;
				this.x = this.targetStage.mouseX - this.dragStartMP.x;
				this.y = this.targetStage.mouseY - this.dragStartMP.y;
			}
		}

		public function dragPanelStop(e:MouseEvent):void
		{
			this.targetStage.removeEventListener(MouseEvent.MOUSE_MOVE,this.dragPanelMove);
			this.targetStage.removeEventListener(MouseEvent.MOUSE_UP,this.dragPanelStop);
			this.windowDragStarted = false;
		}

		public function initializeDrag(mc:MovieClip):void
		{
			dragTarget = mc;
			dragTarget.addEventListener(MouseEvent.MOUSE_DOWN,this.dragPanelStart);
		}

		public function frame1() : void
		{
			this.stop();
			this.windowDragStarted = false;
			this.dragStartMP = new Point();
		}
	}
}