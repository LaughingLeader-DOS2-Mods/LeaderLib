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

		public function rebuildListIndexes() : void
		{
			var obj:MovieClip = null;
			for (var i:uint=this.entries.length; i--;)
			{
				obj = this.entries[i];
				if(obj)
				{
					obj.listIndex = i;
				}
			}
		}

		public function getIndexByID(id:*) : int
		{
			var obj:MovieClip = null;
			for (var i:uint=this.entries.length; i--;)
			{
				obj = this.entries[i];
				if(obj && obj.id == id)
				{
					return i;
				}
			}
			return -1;
		}

		public function removeAt(obj:MovieClip, index:uint) : Boolean
		{
			var success:Boolean = this.removeChild(obj) != null;
			if (obj is IDestroyable)
			{
				obj.OnDestroying();
			}
			this.entries.splice(index, 1);
			return success;
		}

		public function remove(obj:MovieClip) : Boolean
		{
			var success:Boolean = this.removeChild(obj) != null;
			for (var i:uint=this.entries.length; i--;)
			{
				if(this.entries[i] == obj)
				{
					success = this.removeAt(obj, i);
					break;
				}
			}
			if(success) {
				this.rebuildListIndexes();
			}
			return success;
		}

		public function removeAtIndex(index:uint) : Boolean
		{
			var success:Boolean = false;
			var obj:MovieClip = this.entries[index];
			if (obj) {
				success = this.removeAt(obj, index);
			}
			if(success) {
				this.rebuildListIndexes();
			}
			return success;
		}

		public function removeWithID(id:*) : Boolean
		{
			var success:Boolean = false;
			var obj:MovieClip = null;
			for (var i:uint=this.entries.length; i--;)
			{
				obj = this.entries[i];
				if(obj && obj.id == id)
				{
					if(this.removeAt(obj, i)) {
						success = true;
					}
				}
			}
			if(success) {
				this.rebuildListIndexes();
			}
			return success;
		}

		public function clearAll() : void
		{
			var obj:MovieClip = null;
			for (var i:uint=this.entries.length; i--;)
			{
				obj = this.entries[i];
				if(obj)
				{
					this.removeAt(obj, i)
				}
			}
			this.entries.length = 0;
		}
	}
}