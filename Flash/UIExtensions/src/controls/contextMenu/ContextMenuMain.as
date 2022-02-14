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
			super();
		}


		public function clearActiveSubmenu() : void
		{
			this.activeSubmenu = null;
		}

		public function setActiveSubmenu(sub:IContextMenuObject) : void
		{
			if(this.activeSubmenu)
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