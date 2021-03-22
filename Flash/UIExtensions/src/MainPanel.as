package
{
	import LS_Classes.listDisplay;
	import flash.display.MovieClip;
	
	public dynamic class MainPanel extends MovieClip
	{
		public var elements:Array;
		public var idInc:uint = 0;

		public function MainPanel()
		{
			super();
			addFrameScript(0,this.frame1);
		}

		public function addElement(obj:MovieClip) : *
		{
			elements.push(obj);
			this.addChild(obj);
			obj.list_id = this.idInc++;
		}

		public function removeElement(obj:MovieClip) : *
		{
			this.removeChild(obj);
			elements.splice(obj, 1);
		}

		public function clearElements() : *
		{
			var obj:MovieClip = null;
			var index:uint = 0;
			while(index < this.elements.length)
			{
				if(this.elements[index])
				{
					obj = this.elements[index];
					this.removeChild(obj);
				}
				index++;
			}
			this.elements = new Array();
			this.idInc = 0;
		}
		
		function frame1() : *
		{
			elements = new Array();
			this.mousEnabled = false;
		}
	}
}