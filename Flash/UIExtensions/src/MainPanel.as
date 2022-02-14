package
{
	import flash.display.MovieClip;

	public dynamic class MainPanel extends MovieClip
	{
		public var elements:Array;

		public function MainPanel()
		{
			super();
			this.elements = new Array();
			this.mouseEnabled = false;
			this.addFrameScript(0,this.frame1);
		}

		public function addElement(obj:MovieClip) : uint
		{
			var index:uint = this.elements.length;
			obj.list_id = index;
			elements.push(obj);
			this.addChild(obj);
			return index;
		}

		public function removeElement(obj:MovieClip) : void
		{
			this.removeChild(obj);
			var index:uint = 0;
			while(index < this.elements.length)
			{
				if(this.elements[index] == obj)
				{
					elements.splice(index, 1);
					break;
				}
				index++;
			}
		}

		public function removeElementWithID(id:Number) : Boolean
		{
			var success:Boolean = false;
			var index:uint = 0;
			while(index < this.elements.length)
			{
				if(this.elements[index])
				{
					var obj:MovieClip = this.elements[index];
					if (obj.id == id) {
						this.removeChild(obj);
						elements.splice(index, 1);
						success = true;
					}
				}
				index++;
			}
			return success;
		}

		public function clearElements() : void
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
		}
		
		private function frame1() : void
		{
			this.stop();
		}
	}
}