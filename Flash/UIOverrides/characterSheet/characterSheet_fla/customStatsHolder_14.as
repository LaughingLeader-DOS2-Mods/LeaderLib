package characterSheet_fla
{
	import LS_Classes.scrollListGrouped;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public dynamic class customStatsHolder_14 extends MovieClip
	{
		public var create_mc:btnCreateCustomStat;
		public var listHolder_mc:empty;
		public var list:scrollListGrouped;
		public const elemOffset:int = 3;
		public var stats_array:Array;
		
		public function customStatsHolder_14()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function init() : *
		{
			//Ability holder position
			this.y = 292;
			this.x = 12;
			this.create_mc.x = 53;
			this.listHolder_mc.x = 44
			this.stats_array = new Array();
			this.list = new scrollListGrouped("down_id","up_id","handle_id","scrollBgBig_id");

			//Original settings
			// this.list = new scrollList("down_id","up_id","handle_id","scrollBgBig_id");
			//this.list.EL_SPACING = 0;
			//this.list.setFrame(328,735);
			// this.listHolder_mc.addChild(this.list);
			//this.list.TOP_SPACING = 40;
			// this.list.m_scrollbar_mc.m_hideWhenDisabled = false;
			//this.list.m_scrollbar_mc.setLength(667);
			// this.list.m_scrollbar_mc.x = -1;
			// this.list.m_scrollbar_mc.y = -17;
			// (parent as MovieClip).scrollbarHolder_mc.addChild(this.list.m_scrollbar_mc);
			// this.create_mc.init(this.onCreateBtnClicked);

			//Ability group settings
			this.list.SUBEL_SPACING = -4;
			this.list.EL_SPACING = 22;
			this.list.SB_SPACING = -10;
			this.list.TOP_SPACING = 40;
			this.list.setFrame(270,735);
			this.list.m_scrollbar_mc.m_hideWhenDisabled = false;
			this.listHolder_mc.addChild(this.list);
			this.list.setGroupMC("StatCategory");
			this.list.elementsSortOn("textStr");
			this.list.m_scrollbar_mc.setLength(663 + 42);
			this.list.m_scrollbar_mc.ScaleBG = true;
			this.list.m_scrollbar_mc.x = -1;
			this.list.m_scrollbar_mc.y = -17;
			(parent as MovieClip).scrollbarHolder_mc.addChild(this.list.m_scrollbar_mc);
			this.create_mc.init(this.onCreateBtnClicked);
			this.create_mc.tooltip = "Create Custom Stat";

			this.list.addGroup(0,"Miscellaneous",false);

			this.base = root as MovieClip;
			//this.base.stats_mc.panelBg2_mc.visible = true;
		}
		
		public function onCreateBtnClicked() : *
		{
			ExternalInterface.call("createCustomStat");
		}
		
		public function positionElements() : *
		{
			// var mc:MovieClip = null;
			// var i:Number = 0;
			// while(i < this.list.size)
			// {
			// 	mc = this.list.getAt(i);
			// 	mc.heightOverride = mc.label_txt.textHeight;
			// 	mc.hl_mc.height = mc.label_txt.textHeight - this.elemOffset * 2;
			// 	mc.line_mc.y = mc.label_txt.textHeight - Math.round(mc.line_mc.height * 0.5) - this.elemOffset;
			// 	i++;
			// }
			this.list.positionElements();
		}

		public function clearElements() : *
		{
			this.resetGroups();
		}

		public function resetGroups() : *
		{
			if(this.list != null)
			{
				this.list.clearGroupElements();
				this.list.clearElements();
				this.list.addGroup(0,"Miscellaneous",true);
			}
			this.stats_array = new Array();
		}
		
		public function setGameMasterMode(isGM:Boolean) : *
		{
			this.list.setFrame(328,!!isGM?Number(this.create_mc.y):Number(735));
			this.create_mc.visible = isGM;
		}

		public function addGroup(groupId:Number, labelText:String, reposition:Boolean=false) : *
		{
			this.list.addGroup(groupId,labelText,reposition);
		}

		public function setGroupTooltip(groupId:Number, text:String) : *
		{
			var group_mc:MovieClip = this.list.getElementByNumber("groupId",groupId);
			if (group_mc != null)
			{
				group_mc.tooltip = text;
			}
		}

		public function addCustomStat(doubleHandle:Number, labelText:String, valueText:String, groupId:Number=0) : *
		{
			var cstat_mc:MovieClip = new CustomStat();
			cstat_mc.hl_mc.alpha = 0;

			cstat_mc.plus_mc.visible = this.base.isGameMasterChar;
			cstat_mc.minus_mc.visible = this.base.isGameMasterChar;
			cstat_mc.edit_mc.visible = this.base.isGameMasterChar;
			cstat_mc.delete_mc.visible = this.base.isGameMasterChar;
			cstat_mc.edit_mc.tooltip = "Edit";
			cstat_mc.delete_mc.tooltip = "Delete";
			cstat_mc.edit_mc.alignTooltip = "top";
			cstat_mc.delete_mc.alignTooltip = "top";
			cstat_mc.edit_mc.tooltipYOffset = 1;
			cstat_mc.delete_mc.tooltipYOffset = 1;
			//cstat_mc.label_txt.autoSize = TextFieldAutoSize.NONE;
			cstat_mc.label_txt.autoSize = TextFieldAutoSize.LEFT;
			cstat_mc.label_txt.htmlText = labelText;
			cstat_mc.text_txt.htmlText = valueText;
			cstat_mc.text_txt.width = cstat_mc.text_txt.width + 8;
			cstat_mc.tooltipAlign = "right";
			cstat_mc.statId = doubleHandle;
			cstat_mc.textStr = cstat_mc.label_txt.text;
			//cstat_mc.hl_mc.width = this.statsElWidth;
			cstat_mc.text_txt.mouseEnabled = false;
			cstat_mc.label_txt.mouseEnabled = false;
			//cstat_mc.heightOverride = 26;

			//Aligning like an AbilityEl
			var tf:TextFormat = cstat_mc.text_txt.getTextFormat();
			tf.align = TextFormatAlign.CENTER;
			cstat_mc.text_txt.setTextFormat(tf);
			cstat_mc.text_txt.x = 202.25;
			cstat_mc.text_txt.y = 0;
			cstat_mc.text_txt.width = 35;
			cstat_mc.text_txt.height = 24;

			//tf:TextFormat = cstat_mc.label_txt.getTextFormat();
			//tf.align = TextFormatAlign.LEFT;
			//cstat_mc.label_txt.setTextFormat(tf);
			cstat_mc.label_txt.x = 0;
			cstat_mc.label_txt.y = 0;
			cstat_mc.label_txt.width = 180.75;
			cstat_mc.label_txt.height = 22.05;

			cstat_mc.minus_mc.x = 183.1;
			cstat_mc.minus_mc.y = 3.95;
			cstat_mc.plus_mc.x = 235;
			cstat_mc.plus_mc.y = 4;

			cstat_mc.delete_mc.x = 136;//-58.5
			cstat_mc.delete_mc.y = 5;//2;
			cstat_mc.edit_mc.x = 157;//-40.65;
			cstat_mc.edit_mc.y = 5;

			cstat_mc.hl_mc.x = -22;
			cstat_mc.hl_mc.y = 2;
			cstat_mc.hl_mc.width = 285.05;
			cstat_mc.hl_mc.height = 18;

			cstat_mc.line_mc.x = -22.35;
			cstat_mc.line_mc.y = 25;
			// cstat_mc.line_mc.x = -41
			// cstat_mc.line_mc.y = -1
			// cstat_mc.line_mc.width = 288
			// cstat_mc.line_mc.height = 4

			cstat_mc.hl_mc.height = cstat_mc.label_txt.y + cstat_mc.label_txt.textHeight - cstat_mc.hl_mc.y;
			cstat_mc.label_txt.y = Math.round((cstat_mc.hl_mc.height - cstat_mc.label_txt.textHeight) * 0.5);

			cstat_mc.id = this.list.length;
			cstat_mc.init();

			this.list.addGroupElement(groupId,cstat_mc,false);

			this.stats_array.push(cstat_mc);
		}

		private function frame1() : *
		{
			// var obj:MovieClip = null;
			// var i:int = 0;
			// while(i < this.numChildren)
			// {
			// 	obj = this.getChildAt(i) as MovieClip;
			// 	if(obj != null && obj != this.listHolder_mc && obj != this.create_mc)
			// 	{
			// 		trace("BG?", i, obj.name);
			// 		obj.visible = false;
			// 	}
			// 	i++;
			// }
			//Hide the BG
			this.getChildAt(0).visible = false;
		}
	}
}