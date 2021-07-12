package System
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import Controls.Panels.IPanel;

	public dynamic class PanelManager extends MovieClip
	{
		public var panels:Array;
		public var idInc:uint = 0;

		public function PanelManager()
		{
			super();
			addFrameScript(0,this.frame1);
		}

		public function addPanel(obj:MovieClip) : *
		{
			this.panels.push(obj);
			this.addChild(obj);
			obj.list_id = this.idInc++;
			if (obj is IPanel)
			{
				ExternalInterface.call("LeaderLib_PanelAdded", obj.list_id, obj.id);
			}
			else
			{
				ExternalInterface.call("LeaderLib_PanelAdded", obj.list_id);
			}
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
			this.panels = new Array();
			this.idInc = 0;
		}
		
		public function frame1() : *
		{
			this.panels = new Array();
			this.mouseEnabled = false;
		}
	}
}