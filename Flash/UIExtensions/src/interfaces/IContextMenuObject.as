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
		
		function get side():String;
		function set side(v:String):void;
		
		function get depth():int;
		function set depth(v:int):void;

		function close(force:Boolean = false):void;
		function open(targetX:Number=0, targetY:Number=0):void;
	}
}