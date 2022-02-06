package interfaces
{
	import flash.events.IEventDispatcher;

	public interface IDropdownButton extends IEventDispatcher
	{
		function get width():Number;
		function get height():Number;
		function get toggled():Boolean;
		function set toggled(b:Boolean):void;

		function onHover():void;
		function onClick():void;
		function onOut():void;
		function onUp():void;
	}
}