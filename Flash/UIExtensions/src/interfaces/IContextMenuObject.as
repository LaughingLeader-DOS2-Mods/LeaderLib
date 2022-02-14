package interfaces
{
	import flash.events.IEventDispatcher;

	public interface IContextMenuObject extends IEventDispatcher
	{
		function get isOpen():Boolean;
		function set isOpen(v:Boolean):void;

		function get isParentOpen():Boolean;
		function get isChild():Boolean;
		function get isMouseHovering():Boolean;
		function get isMouseHoveringAny():Boolean;

		function close(force:Boolean = false):void;
		function open(targetX:Number=0, targetY:Number=0):void;
	}
}