package controls
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class BaseDraggableObject extends MovieClip
	{
		public var dragStarted:Boolean = false;
		public var dragStartPoint:Point;
		public var startDragDiff:uint = 20;
		public var dragTarget:MovieClip;

		public var lastMouseEnabled:Boolean;

		public function BaseDraggableObject()
		{
			super();
			this.dragStarted = false;
			this.dragStartPoint = new Point();
		}

		private function get targetStage():Stage
		{
			return MainTimeline.Instance.stage;
		}

		public function get canDrag():Boolean
		{
			return true;
		}

		public function dragStart(e:MouseEvent):void
		{
			if(canDrag && this.dragTarget.mouseEnabled)
			{
				this.dragStarted = false;
				this.targetStage.addEventListener(MouseEvent.MOUSE_MOVE,this.dragMove);
				this.dragStartPoint.x = this.targetStage.mouseX;
				this.dragStartPoint.y = this.targetStage.mouseY;
				this.targetStage.addEventListener(MouseEvent.MOUSE_UP,this.dropStop);

				this.lastMouseEnabled = MainTimeline.Instance.mouseChildren;
				MainTimeline.Instance.mouseChildren = true;
				MainTimeline.Instance.mouseEnabled = true;
			}
		}

		public function dragMove(e:MouseEvent):void
		{
			if(!this.dragStarted)
			{
				if(this.dragStartPoint.x + startDragDiff > this.targetStage.mouseX || this.dragStartPoint.y + startDragDiff > this.targetStage.mouseY || this.dragStartPoint.x - startDragDiff < this.targetStage.mouseX || this.dragStartPoint.y - startDragDiff < this.targetStage.mouseY)
				{
					this.dragStartPoint.x = this.targetStage.mouseX - this.x;
					this.dragStartPoint.y = this.targetStage.mouseY - this.y;
					this.targetStage.focus = null;
					Registry.ExtCall("hideTooltip");
					//Registry.ExtCall("startMoveWindow");
					//this.targetStage.removeEventListener(MouseEvent.MOUSE_MOVE,this.dragPanelMove);
					this.dragStarted = true;
				}
			}
			else
			{
				this.x = this.targetStage.mouseX - this.dragStartPoint.x;
				this.y = this.targetStage.mouseY - this.dragStartPoint.y;
			}
		}

		public function dropStop(e:MouseEvent):void
		{
			this.targetStage.removeEventListener(MouseEvent.MOUSE_MOVE,this.dragMove);
			this.targetStage.removeEventListener(MouseEvent.MOUSE_UP,this.dropStop);
			this.dragStarted = false;

			MainTimeline.Instance.mouseChildren = this.lastMouseEnabled;
			MainTimeline.Instance.mouseEnabled = this.lastMouseEnabled;
		}

		public function initializeDrag(draggableMC:MovieClip):void
		{
			this.dragTarget = draggableMC;
			this.dragTarget.addEventListener(MouseEvent.MOUSE_DOWN,this.dragStart);
		}
	}
}