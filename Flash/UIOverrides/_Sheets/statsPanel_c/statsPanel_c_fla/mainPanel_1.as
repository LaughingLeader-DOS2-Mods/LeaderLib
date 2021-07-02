package statsPanel_c_fla
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class mainPanel_1 extends MovieClip
	{
		public var buttonHint_mc:MovieClip;
		public var panelTitle_txt:TextField;
		public var stats_mc:MovieClip;
		
		public function mainPanel_1()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function init() : *
		{
			this.stats_mc.init();
			this.buttonHint_mc.init();
			this.stats_mc.setHintContainer(this.buttonHint_mc);
		}
		
		public function subTabNext() : *
		{
			this.stats_mc.nextSubTab();
		}
		
		public function subTabPrevious() : *
		{
			this.stats_mc.previousSubTab();
		}
		
		public function cursorRight() : *
		{
			this.stats_mc.cursorRight();
		}
		
		public function cursorLeft() : *
		{
			this.stats_mc.cursorLeft();
		}
		
		public function cursorUp() : *
		{
			this.stats_mc.cursorUp();
		}
		
		public function cursorDown() : *
		{
			this.stats_mc.cursorDown();
		}
		
		public function setListLoopable(param1:Boolean) : *
		{
			this.stats_mc.setListLoopable(param1);
		}
		
		public function addPoint() : Boolean
		{
			return this.stats_mc.addPoint();
		}
		
		public function removePoint() : Boolean
		{
			return this.stats_mc.removePoint();
		}
		
		public function cursorAccept() : *
		{
			this.stats_mc.cursorAccept();
		}
		
		public function cursorShowActionMenu() : *
		{
			this.stats_mc.cursorShowActionMenu();
		}
		
		public function toggleTooltip() : *
		{
			this.stats_mc.toggleTooltip();
		}
		
		public function showPanel(param1:Number) : *
		{
			switch(param1)
			{
				case 0:
					ExternalInterface.call("showEquipment");
					break;
				case 1:
					visible = true;
					this.stats_mc.visible = true;
					if(this.stats_mc.tabBar_mc.tabList.length > 0 && this.stats_mc.tabBar_mc.tabList.getCurrentMovieClip() == null)
					{
						this.stats_mc.tabBar_mc.tabList.select(0);
					}
					break;
				case 2:
					ExternalInterface.call("showInventory");
					break;
				case 3:
					ExternalInterface.call("showSkills");
					break;
				default:
					return;
			}
		}
		
		function frame1() : *
		{
		}
	}
}
