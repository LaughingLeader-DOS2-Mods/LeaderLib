package interfaces
{
	public interface IInputHandler extends IDestroyable
	{
		function OnInputDown(id:String):Boolean;
		function OnInputUp(id:String):Boolean;
		function get IsInputEnabled():Boolean;
	}
}