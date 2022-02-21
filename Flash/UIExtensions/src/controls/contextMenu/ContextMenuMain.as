package controls.contextMenu
{
	import interfaces.IContextMenuObject;
	import flash.display.MovieClip;

	public class ContextMenuMain extends ContextMenuMC
	{
		public var children_mc:MovieClip;
		public var activeSubmenu:IContextMenuObject;
		
		public function ContextMenuMain()
		{
			super("main");
		}

		public function clearActiveSubmenu(skipClose:Boolean = false, sub:IContextMenuObject = null) : void
		{
			if(sub != null && sub != this.activeSubmenu)
			{
				return;
			}
			if(!skipClose && this.activeSubmenu != null)
			{
				this.activeSubmenu.close(true);
			}
			this.activeSubmenu = null;
		}

		public function setActiveSubmenu(sub:IContextMenuObject) : void
		{
			//Registry.Log("setActiveSubmenu(%s) depth(%s) currentDepth(%s) this.activeSubmenu(%s)", sub, sub.depth, this.activeSubmenu ? this.activeSubmenu.depth : -1, this.activeSubmenu);
			if(this.activeSubmenu != null && sub.depth <= this.activeSubmenu.depth)
			{
				this.activeSubmenu.close(true);
			}
			this.activeSubmenu = sub;
		}

		public function closeSubmenus() : void
		{
			var sub:IContextMenuObject = null;
			for (var i:uint = this.list.content_array.length; i--;)
			{
				sub = this.list.content_array[i];
				if(sub && sub.isOpen)
				{
					sub.close(true);
				}
			}
		}
	}
}