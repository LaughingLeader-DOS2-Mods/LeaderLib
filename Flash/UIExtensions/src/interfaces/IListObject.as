package interfaces
{
	import LS_Classes.listDisplay;

	public interface IListObject
	{
		function get list_pos():uint;
		function get list_id():uint;
		function get selectable():Boolean;
		function get m_filteredObject():Object;
		function get ownerList():listDisplay;

		function set list_pos(v:uint):void;
		function set list_id(v:uint):void;
		function set selectable(b:Boolean):void;
		function set m_filteredObject(v:Object):void;
		function set ownerList(v:listDisplay):void;
	}
}