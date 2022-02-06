package system
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import LS_Symbols.comboBox;
	import controls.dropdowns.Dropdown;

	public class DropdownManager extends BaseManager
	{
		public function DropdownManager()
		{
			super();
		}

		public function onDropdownPressed(dropdownIndex:int, selectedIndex:int = 0) : void
		{
			Registry.ExtCall("LeaderLib_UIExtensions_DropdownSelectionChanged", dropdownIndex, selectedIndex);
		}

		public function add(id:Number, xPos:Number = 0, yPos:Number = 0, comboText:String = "", topText:String = "", tooltipText:String = "") : int
		{
			var listIndex:int = this.entries.length;
			var dropdown:Dropdown = new Dropdown();
			dropdown.id = id;
			dropdown.setText(comboText, topText, tooltipText);
			// dropdown.init(function(index:Number=0) : void {
			// 	onDropdownPressed(listIndex, index);
			// });
			dropdown.x = xPos;
			dropdown.y = yPos;
			this.entries.push(dropdown);
			this.addChild(dropdown);
			return listIndex;
		}
	}
}