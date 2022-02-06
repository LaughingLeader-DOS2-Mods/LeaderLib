package system
{
	import flash.display.MovieClip;

	public dynamic class PanelManager extends BaseManager
	{
		public var panels:Array = new Array();

		public function PanelManager()
		{
			super();

			this.mouseEnabled = false;
			this.stop();
		}

		public function add(obj:MovieClip) : int
		{
			obj.list_id = this.panels.length;
			this.panels.push(obj);
			this.addChild(obj);
			//Registry.ExtCall("LeaderLib_PanelAdded", obj.list_id, obj.id);
			return obj.list_id;
		}
	}
}