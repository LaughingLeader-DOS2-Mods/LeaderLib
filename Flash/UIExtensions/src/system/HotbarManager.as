package system
{
	import flash.display.MovieClip;
	import controls.hotbar.Hotbar;

	public class HotbarManager extends BaseManager
	{
		public var activeBar:int = -1;

		public function HotbarManager()
		{
			super();
		}

		public function setActiveBar(id:int) : void
		{
			this.activeBar = id;
		}

		public function add(id:Number, xPos:Number = 0, yPos:Number = 0) : int
		{
			var listIndex:int = this.entries.length;
			var hotbar:Hotbar = new Hotbar();
			hotbar.id = id;
			hotbar.x = xPos;
			hotbar.y = yPos;
			hotbar.onInit();
			this.entries.push(hotbar);
			this.addChild(hotbar);
			return listIndex;
		}
	}
}