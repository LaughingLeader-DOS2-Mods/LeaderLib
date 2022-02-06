package system
{
	import flash.display.MovieClip;
	import controls.hotbar.Hotbar;
	import flash.geom.Rectangle;

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
			hotbar.listIndex = listIndex;
			hotbar.id = id;
			hotbar.x = xPos;
			hotbar.y = yPos;
			hotbar.onInit();
			this.entries.push(hotbar);
			this.addChild(hotbar);
			return listIndex;
		}

		public function onResize(w:Number, h:Number, sizeDiff:Number) : void
		{
			var main:MainTimeline = MainTimeline.Instance;
			for (var i:int = this.entries.length; i--;) {
				var hotbar:Hotbar = this.entries[i] as Hotbar;
				if (hotbar) {
					var currentX:Number = hotbar.x;
					var slotAmount:uint = 0;
					var totalBarWidth:uint = 0;
					var barSpacing:Number = 0;
					if(sizeDiff < main.designResolution.x)
					{
						slotAmount = 0;
						if(sizeDiff > main.baseBarWidth)
						{
							slotAmount = Math.floor((sizeDiff - main.baseBarWidth) / main.visualSlotWidth);
						}
						totalBarWidth = main.barStopWidth + main.baseBarWidth + slotAmount * main.visualSlotWidth + 5;
						hotbar.scrollRect = new Rectangle(0,0,totalBarWidth,hotbar.height);
						barSpacing = 12;
						// if(slotAmount < hotbar.maxSlots)
						// {
						// 	if(hotbar.isSkillBarShown)
						// 	{
						// 		hotbar.endPiece_mc.visible = true;
						// 	}
						// }
						hotbar.x = (currentX + (barSpacing + main.designResolution.x - totalBarWidth)) * 0.5;
						Registry.ExtCall("LeaderLib_Hotbar_UpdateSlots", hotbar.listIndex, slotAmount);
					}
					else
					{
						hotbar.x = currentX;
						hotbar.scrollRect = null;
						Registry.ExtCall("LeaderLib_Hotbar_UpdateSlots", hotbar.listIndex, hotbar.maxSlots);
					}
				}
			}
		}
	}
}