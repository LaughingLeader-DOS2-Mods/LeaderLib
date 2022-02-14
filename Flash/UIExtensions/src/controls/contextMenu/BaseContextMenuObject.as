package controls.contextMenu
{
	import flash.display.MovieClip;
	import interfaces.IContextMenuObject;
	import flash.geom.Point;
	public class BaseContextMenuObject extends MovieClip
	{
		public var parentCM:IContextMenuObject;
		public var childCM:IContextMenuObject;

		private var _isOpen:Boolean = false;
		public function BaseContextMenuObject()
		{
			super();
		}
		public function get isOpen():Boolean
		{
			return _isOpen;
		}
		public function set isOpen(v:Boolean):void
		{
			_isOpen = v;
		}
		public function get isParentOpen():Boolean
		{
			return parentCM && parentCM.isOpen;
		}
		public function get isChild():Boolean
		{
			return parentCM != null;
		}
		public function get isMouseHoveringAny():Boolean
		{
			if(parentCM && parentCM.isMouseHovering)
			{
				return true;
			}
			if(childCM && childCM.isMouseHovering)
			{
				return true;
			}
			return isMouseHovering;
		}
		public function get isMouseHovering():Boolean
		{
			var mousePoint:Point = this.localToGlobal(new Point(this.mouseX, this.mouseY));
			return this.hitTestPoint(mousePoint.x, mousePoint.y, true);
		}

		public function setHierarchy(parentCMObject:IContextMenuObject, childCMObject:IContextMenuObject = null) : void
		{
			this.parentCM = parentCMObject;
			this.childCM = childCMObject;
		}
	}
}