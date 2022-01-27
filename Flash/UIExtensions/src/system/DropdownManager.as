package system
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import LS_Symbols.comboBox;
	import controls.dropdowns.Dropdown;

	public class DropdownManager extends MovieClip
	{
		public var entries:Array;

		public function DropdownManager()
		{
			super();
			entries = new Array();
		}

		public function onDropdownPressed(dropdownIndex:int, selectedIndex:int = 0) : void
		{
			Registry.ExtCall("LeaderLib_UIExtensions_DropdownSelectionChanged", dropdownIndex, selectedIndex);
		}

		public function addDropdown(id:Number, xPos:Number = 0, yPos:Number = 0, comboText:String = "", topText:String = "", tooltipText:String = "") : int
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

		public function removeDropdown(obj:MovieClip) : Boolean
		{
			var success:Boolean = this.removeChild(obj) != null;
			var index:uint = 0;
			while(index < this.entries.length)
			{
				if(this.entries[index] == obj)
				{
					entries.splice(index, 1);
					success = true;
					break;
				}
				index++;
			}
			return success;
		}

		public function removeDropdownWithID(id:Number) : Boolean
		{
			var success:Boolean = false;
			var index:uint = 0;
			while(index < this.entries.length)
			{
				if(this.entries[index])
				{
					var obj:MovieClip = this.entries[index];
					if (obj.id == id) {
						this.removeChild(obj);
						entries.splice(index, 1);
						success = true;
					}
				}
				index++;
			}
			return success;
		}

		public function clearEntries() : void
		{
			var obj:MovieClip = null;
			var index:uint = 0;
			while(index < this.entries.length)
			{
				if(this.entries[index])
				{
					obj = this.entries[index];
					this.removeChild(obj);
				}
				index++;
			}
			this.entries.length = 0;
		}
	}
}