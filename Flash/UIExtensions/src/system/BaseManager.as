package system
{
	import flash.display.MovieClip;
	import interfaces.IDestroyable;

	public class BaseManager extends MovieClip
	{
		public var entries:Array;

		public function BaseManager()
		{
			super();
			entries = new Array();
		}

		public function get length() : uint
		{
			return this.entries.length;
		}

		public function getIndexByID(id:*) : int
		{
			var obj:MovieClip = null;
			var index:int = 0;
			while(index < this.entries.length)
			{
				obj = this.entries[index];
				if(obj && obj.id == id)
				{
					return index;
				}
				index++;
			}
			return -1;
		}

		public function remove(obj:MovieClip) : Boolean
		{
			var success:Boolean = this.removeChild(obj) != null;
			var index:int = 0;
			while(index < this.entries.length)
			{
				if(this.entries[index] == obj)
				{
					if (obj is IDestroyable)
					{
						obj.OnDestroying();
					}
					this.entries.splice(index, 1);
					success = true;
					break;
				}
				index++;
			}
			return success;
		}

		public function removeWithID(id:*) : Boolean
		{
			var success:Boolean = false;
			var obj:MovieClip = null;
			var index:int = 0;
			while(index < this.entries.length)
			{
				obj = this.entries[index];
				if(obj && obj.id == id)
				{
					if (obj is IDestroyable)
					{
						obj.OnDestroying();
					}
					this.removeChild(obj);
					this.entries.splice(index, 1);
					success = true;
				}
				index++;
			}
			return success;
		}

		public function clearAll() : void
		{
			var obj:MovieClip = null;
			var index:int = 0;
			while(index < this.entries.length)
			{
				obj = this.entries[index];
				if(obj)
				{
					if (obj is IDestroyable)
					{
						obj.OnDestroying();
					}
					this.removeChild(obj);
				}
				index++;
			}
			this.entries.length = 0;
		}
	}
}