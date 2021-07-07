package characterSheet_fla
{
	import LS_Classes.scrollListGrouped;
	import flash.display.MovieClip;
	
	public dynamic class abilitiesholder_9 extends MovieClip
	{
		public var listHolder_mc:empty;
		public var list:scrollListGrouped;
		
		public function abilitiesholder_9()
		{
			super();
		}
		
		public function init() : *
		{
			this.list = new scrollListGrouped("down_id","up_id","handle_id","scrollBgBig_id");
			this.list.SUBEL_SPACING = -4;
			this.list.EL_SPACING = 22;
			this.list.SB_SPACING = -10;
			this.list.setFrame(270,735);
			this.list.m_scrollbar_mc.m_hideWhenDisabled = false;
			this.listHolder_mc.addChild(this.list);
			this.list.TOP_SPACING = 40;
			this.list.setGroupMC("StatCategory");
			this.list.elementsSortOn("textStr");
			this.list.m_scrollbar_mc.setLength(663 + 42);
			this.list.m_scrollbar_mc.ScaleBG = true;
			this.list.m_scrollbar_mc.x = -1;
			this.list.m_scrollbar_mc.y = -17;
			(parent as MovieClip).scrollbarHolder_mc.addChild(this.list.m_scrollbar_mc);
		}
	}
}
