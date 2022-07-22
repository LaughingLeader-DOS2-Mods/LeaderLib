package journal_fla
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import LS_Classes.scrollList;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public dynamic class tutorialHolder_34 extends MovieClip
	{
		public var base:MovieClip;

		public var desc_txt:TextField;
		public var showTutorialPopups_mc:MovieClip; // CheckBoxWlabel
		public var title_txt:TextField;

		//LeaderLib addition - makes text scrollable
		public var text_mc:MovieClip;
		public var list:scrollList;

		public var scrollPlaneLWidth:Number = 400;
		public var scrollPlaneRWidth:Number = 760;
		public var scrollPlaneHeight:Number = 724;
		public var cqSbYOffset:Number = 160;
		public var cLineHeight:Number = 30;
		public var scrollbarSize:Number = 401;
		public var RListHeightDisc:Number = 10;

		public var lastGroupId:Number = -1;

		public function tutorialHolder_34()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function init() : *
		{
			this.showTutorialPopups_mc.init(this.onCheckBoxPressed);
		}
		
		public function onCheckBoxPressed() : *
		{
			ExternalInterface.call("tutPopups",this.showTutorialPopups_mc.isActive);
		}
		
		public function showSelected(group_mc:MovieClip) : *
		{
			if(group_mc && group_mc.grpMc)
			{
				this.title_txt.htmlText = group_mc.titleStr.toUpperCase();
				this.desc_txt.htmlText = group_mc.descStr;
				this.text_mc.heightOverride = this.desc_txt.textHeight;
				this.list.mouseWheelEnabled = true;
				this.list.positionElements()
				this.list.selectMC(this.text_mc, true);
				this.lastGroupId = group_mc.id;
			}
		}	

		public function resetText() : *
		{
			this.title_txt.htmlText = "";
			this.desc_txt.htmlText = "";
			this.list.checkScrollBar();
		}
		
		private function frame1() : *
		{
			this.base = parent as MovieClip;
			this.showTutorialPopups_mc.visible = false;

			var tf:TextFormat = this.title_txt.defaultTextFormat;
			tf.size = 28;
			this.title_txt.defaultTextFormat = tf;
			this.title_txt.autoSize = TextFieldAutoSize.CENTER;
			this.title_txt.x = 510;
			this.title_txt.y = 80;

			this.list = new scrollList("down2_id","up2_id","handle2_id","scrollBg2_id");
			// this.list.mouseEnabled = false;
			// this.list.mouseChildren = false;
			this.list.EL_SPACING = 0;
			this.list.TOP_SPACING = 0;
			//this.list.setFrame(this.scrollPlaneLWidth,this.scrollPlaneHeight + this.RListHeightDisc);
			this.list.setFrame(810, 640);
			this.addChild(this.list);
			this.list.x = 476;
			this.list.y = 130;

			this.list.m_scrollbar_mc.m_hideWhenDisabled = true;
			this.list.m_scrollbar_mc.x = 751;
			this.list.m_scrollbar_mc.y = 81;
			this.list.m_scrollbar_mc.m_SCROLLSPEED = this.cLineHeight;
			this.list.m_scrollbar_mc.ScaleBG = true;
			this.list.m_scrollbar_mc.setLength(this.scrollbarSize);
			this.list.m_cyclic = true;

			this.removeChild(this.desc_txt);
			this.text_mc = new MovieClip();
			//this.text_mc.x = 186; //Center
			this.desc_txt.width = 700;
			this.desc_txt.x = 50;
			this.desc_txt.y = 0;
			this.desc_txt.autoSize = TextFieldAutoSize.CENTER;
			this.text_mc.mouseEnabled = false;
			this.text_mc.mouseChildren = false;
			this.text_mc.visible = true;
			this.text_mc.addChild(this.desc_txt);
			this.text_mc.desc_txt = this.desc_txt;
			this.list.addElement(this.text_mc);
		}
	}
}
