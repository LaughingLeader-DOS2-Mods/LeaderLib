package characterSheet_fla
{
	import LS_Classes.scrollList;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public dynamic class talentsHolder_11 extends MovieClip
	{
		public var bgGlow_mc:MovieClip;
		public var listHolder_mc:empty;
		public var list:scrollList;
		
		public function talentsHolder_11()
		{
			super();
		}
		
		public function init() : *
		{
			this.list = new scrollList("down_id","up_id","handle_id","scrollBgBig_id");
			this.list.EL_SPACING = -5;
			this.list.setFrame(328,735);
			this.listHolder_mc.addChild(this.list);
			this.list.TOP_SPACING = 40;
			this.list.sortOn(["talentState","label"],[Array.NUMERIC,0]);
			this.list.setTileableBG = "scrollBGmc";
			this.list.containerBG_mc.addChild(this.bgGlow_mc);
			this.list.m_scrollbar_mc.addEventListener(Event.CHANGE,this.updateBGPos);
			this.list.m_scrollbar_mc.m_hideWhenDisabled = false;
			this.list.m_scrollbar_mc.setLength(663 + 38 + 4);
			this.list.m_scrollbar_mc.ScaleBG = true;
			this.list.m_scrollbar_mc.x = -1;
			this.list.m_scrollbar_mc.y = -13 - 4;
			(parent as MovieClip).scrollbarHolder_mc.addChild(this.list.m_scrollbar_mc);
			this.list.m_scrollbar_mc.addEventListener(MouseEvent.ROLL_OUT,function():*
			{
				list.m_scrollbar_mc.mouseWheelEnabled = false;
			});
			this.list.m_scrollbar_mc.addEventListener(MouseEvent.ROLL_OVER,function():*
			{
				list.m_scrollbar_mc.mouseWheelEnabled = true;
			});
		}
		
		public function updateBGPos(e:Event) : *
		{
			this.bgGlow_mc.y = this.list.m_scrollbar_mc.scrolledY;
		}
	}
}
