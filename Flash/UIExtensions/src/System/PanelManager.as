package System
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import Controls.Panels.IPanel;

	public dynamic class PanelManager extends MovieClip
	{
		public var panels:Array = new Array();

		public function PanelManager()
		{
			super();

			this.mouseEnabled = false;
			this.stop();
		}

		public function addPanel(obj:MovieClip) : int
		{
			obj.list_id = this.panels.length;
			this.panels.push(obj);
			this.addChild(obj);
			//ExternalInterface.call("LeaderLib_PanelAdded", obj.list_id, obj.id);
			return obj.list_id;
		}

		public function removePanel(obj:MovieClip) : *
		{
			this.removeChild(obj);
			var index:uint = 0;
			while(index < this.panels.length)
			{
				if(this.panels[index] == obj)
				{
					panels.splice(index, 1);
					break;
				}
				index++;
			}
		}

		public function removePanelWithID(id:Number) : Boolean
		{
			var success:Boolean = false;
			var index:uint = 0;
			while(index < this.panels.length)
			{
				if(this.panels[index])
				{
					var obj:MovieClip = this.panels[index];
					if (obj.id == id) {
						this.removeChild(obj);
						panels.splice(index, 1);
						success = true;
					}
				}
				index++;
			}
			return success;
		}

		public function clearPanels() : *
		{
			trace("clearPanels");
			var obj:MovieClip = null;
			var index:uint = 0;
			while(index < this.panels.length)
			{
				if(this.panels[index])
				{
					obj = this.panels[index];
					this.removeChild(obj);
				}
				index++;
			}
			this.panels.length = 0;
		}
	}
}