package controls.dropdowns
{
	public dynamic class DropdownItemData
	{
		public var label:String;
		public var id:Number;
		public var tooltip:String;
		
		public function DropdownItemData(label:String, id:Number, tooltip:String = "")
		{
			this.label = label;
			this.id = id;
			this.tooltip = tooltip;
		}
	}
}
