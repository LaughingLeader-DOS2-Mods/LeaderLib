package characterSheet_fla
{
	import LS_Classes.scrollListGrouped;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	//LeaderLib: Various functions have been added or changed to make this behave and look more like an ability holder.
	public dynamic class customStatsHolder_14 extends MovieClip
	{
		public var create_mc:btnCreateCustomStat;
		public var listHolder_mc:empty;
		public var list:scrollListGrouped;
		public const elemOffset:int = 3;
		public var stats_array:Array;
		public var groups_array:Array;
		
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
			this.groups_array = new Array();
			this.list = new scrollListGrouped("down_id","up_id","handle_id","scrollBgBig_id");

			//Ability group settings
			this.list.SUBEL_SPACING = -4;
			this.list.EL_SPACING = 22;
			this.list.SB_SPACING = -10;
			this.list.TOP_SPACING = 40;
			this.list.setFrame(270,735);
			this.list.m_scrollbar_mc.m_hideWhenDisabled = false;
			this.listHolder_mc.addChild(this.list);
			this.list.setGroupMC("StatCategory");
			//ExternalInterface.call("setupCustomStatSort");

			this.list.m_scrollbar_mc.setLength(663 + 42);
			this.list.m_scrollbar_mc.ScaleBG = true;
			this.list.m_scrollbar_mc.x = -1;
			this.list.m_scrollbar_mc.y = -17;
			(parent as MovieClip).scrollbarHolder_mc.addChild(this.list.m_scrollbar_mc);
			this.create_mc.init(this.onCreateBtnClicked);
			this.create_mc.tooltip = "Create Custom Stat";

			this.base = root as MovieClip;
			//this.base.stats_mc.panelBg2_mc.visible = true;

			//this.list.sortOn("groupId", Array.NUMERIC);
			//this.list.elementsSortOn("textStr", Array.CASEINSENSITIVE);
		}
		
		public function onCreateBtnClicked() : *
		{
			ExternalInterface.call("createCustomStat");
		}
		
		public function positionElements(sortElements:Boolean=true, sortValue:String="groupName") : *
		{
			if(sortElements) {
				switch(sortValue)
				{
					case "groupName":
						this.list.sortOn(sortValue, Array.CASEINSENSITIVE);
						break;
					case "groupId":
						this.list.sortOn(sortValue, Array.NUMERIC);
						break;
					default:
						this.list.sortOn(sortValue, Array.DESCENDING);
				}
			}
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
			}
			this.stats_array = new Array();
			this.groups_array = new Array();
			//ExternalInterface.call("createCustomStatGroups");
		}
		
		public function setGameMasterMode(isGM:Boolean) : *
		{
			this.list.setFrame(328,!!isGM?Number(this.create_mc.y):Number(735));
			this.create_mc.visible = isGM;
		}

		public function OnGroupClicked(group_mc:StatCategory) : *
		{
			ExternalInterface.call("statCategoryCollapseChanged", group_mc.arrayIndex, group_mc.groupId, group_mc.isOpen, group_mc.groupName);
		}

		public function addGroup(groupId:Number, labelText:String, reposition:Boolean=false, visible:Boolean=true) : *
		{
			this.list.addGroup(groupId,labelText,reposition);
			var group_mc:MovieClip = this.list.getElementByNumber("groupId",groupId);
			if (group_mc != null)
			{
				group_mc.groupName = labelText;
				group_mc.visible = visible;
				group_mc.arrayIndex = groups_array.length;
				group_mc.onUpCallback = OnGroupClicked;
				groups_array.push(group_mc);
				ExternalInterface.call("customStatsGroupAdded", groupId, labelText, group_mc.arrayIndex);
			}
		}

		public function setGroupTooltip(groupId:Number, text:String) : *
		{
			var group_mc:MovieClip = this.list.getElementByNumber("groupId",groupId);
			if (group_mc != null)
			{
				group_mc.tooltip = text;
			}
		}

		public function setGroupVisibility(groupId:Number, visible:Boolean=true) : *
		{
			var group_mc:MovieClip = this.list.getElementByNumber("groupId",groupId);
			if (group_mc != null)
			{
				group_mc.visible = visible;
			}
		}

		public function recountAllPoints() : *
		{
			if(this.list.length > 0)
			{
				var i:uint = 0;
				var j:uint = 0;
				var group_mc:MovieClip = null;
				var amount:Number = 0;
				while(i < this.list.length)
				{
					group_mc = this.list.content_array[i];
					if(group_mc)
					{
						if (group_mc.list && group_mc.hidePoints != true)
						{
							amount = 0;
							j = 0;
							while(j < group_mc.list.length)
							{
								amount = amount + group_mc.list.content_array[j].am;
								j++;
							}
							group_mc.amount_txt.visible = false;
							group_mc.amount_txt.htmlText = amount;
						}
						else
						{
							group_mc.amount_txt.visible = false;
						}
					}
					i++;
				}
			}
		}

		public function addCustomStat(doubleHandle:Number, labelText:String, valueText:String, groupId:Number=0, plusVisible:Boolean=false, minusVisible:Boolean=false) : *
		{
			var cstat_mc:MovieClip = new CustomStat();
			cstat_mc.hl_mc.alpha = 0;

			cstat_mc.plus_mc.visible = !this.base.isGameMasterChar ? plusVisible : true;
			cstat_mc.minus_mc.visible = !this.base.isGameMasterChar ? minusVisible : true;
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
			cstat_mc.am = Number(valueText);
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
			cstat_mc.text_txt.x = 203.5;
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
			ExternalInterface.call("customStatAdded", doubleHandle, this.stats_array.length-1);
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