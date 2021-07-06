package statsPanel_c_fla
{
	import LS_Classes.larTween;
	import LS_Classes.scrollList;
	import fl.motion.easing.Linear;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class statsMC_2 extends MovieClip
	{
		public var attributes_mc:MovieClip;
		public var bg_mc:MovieClip;//MPBGData_c; //in texture_lib_c
		public var civilAbilities_mc:MovieClip;
		public var combatAbilities_mc:MovieClip;
		public var customStats_mc:MovieClip;
		public var infoStatContainer_mc:empty;
		public var info_mc:MovieClip;
		public var tabBar_mc:MovieClip;
		public var tags_mc:MovieClip;
		public var talents_mc:MovieClip;
		public var tooltip_mc:MovieClip;//tt_tooltipObj; //in tooltipHelper
		public var statsList:scrollList;
		public var prevSelectedStatId:Number;
		public var prevY:Number;
		public var leftPanelSelected:Boolean;
		public var statsListPos;
		public var statusList:scrollList;
		public var currentPanel:MovieClip;
		public var currentTab:Number;
		public var currentSelectionPanel:Number;
		public var pointsMode:Boolean;
		public var infoStatContainerFocused:Boolean;
		public var slideTw:larTween;
		
		public function statsMC_2()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function addInfoStat(param1:Number, param2:Number, param3:String, param4:String, param5:Number, param6:uint) : *
		{
			var val7:MovieClip = null;
			val7 = this.statsList.getElementByNumber("id",param1);
			if(val7 == null)
			{
				val7 = new InfoStat();
				val7.isStat = false;
				val7.id = param1;
				val7.hl_mc.visible = false;
				this.statsList.addElement(val7,false);
				val7.heightOverride = 31;
			}
			val7.statID = param2;
			val7.label_txt.htmlText = param3;
			val7.value_txt.htmlText = param4;
			val7.label_txt.textColor = param6;
			val7.value_txt.textColor = param6;
			val7.icon_mc.gotoAndStop(param5);
			val7.icon_mc.visible = true;
		}
		
		public function addSpacing(param1:Number, param2:Number) : *
		{
			var val3:MovieClip = null;
			val3 = this.statsList.getElementByNumber("id",param1);
			if(val3 == null)
			{
				val3 = new Spacing();
				val3.id = param1;
				val3.isStat = false;
				this.statsList.addElement(val3,false,false);
			}
			val3.bg_mc.height = param2;
		}
		
		public function setInfoStatValue(param1:Number, param2:String) : *
		{
			var val3:MovieClip = this.statsList.getElementByNumber("id",param1);
			if(val3 && val3.isMainStat)
			{
				val3.value_txt.htmlText = param2;
			}
		}
		
		public function clearInfoStats() : *
		{
			this.saveSelection();
			this.statsList.clearElements();
		}
		
		public function saveSelection() : *
		{
			var val1:MovieClip = this.getCurrentElement();
			if(val1)
			{
				this.prevSelectedStatId = val1.id;
				this.prevY = this.statsList.scrolledY;
			}
		}
		
		public function setTooltipSide() : *
		{
			var val1:Number = 0;
			if(this.infoStatContainerFocused)
			{
				val1 = 10;
			}
			else
			{
				val1 = 417;
			}
			if(this.slideTw)
			{
				this.slideTw.stop();
			}
			this.slideTw = new larTween(this.tooltip_mc,"x",Linear.easeNone,NaN,val1,0.07);
		}
		
		public function toggleTooltip() : *
		{
			ExternalInterface.call("PlaySound","UI_Game_Dialog_Click");
			this.tooltip_mc.visible = !this.tooltip_mc.visible;
		}
		
		public function previousSubTab() : *
		{
			this.tooltip_mc.visible = false;
			ExternalInterface.call("PlaySound","UI_Game_Journal_Click");
			ExternalInterface.call("selectStatsTab",this.tabBar_mc.getPreviousCyclicTabId());
		}
		
		public function nextSubTab() : *
		{
			this.tooltip_mc.visible = false;
			ExternalInterface.call("PlaySound","UI_Game_Journal_Click");
			ExternalInterface.call("selectStatsTab",this.tabBar_mc.getNextCyclicTabId());
		}
		
		public function setStatus(param1:Boolean, param2:Number, param3:Number, param4:Number, param5:String, param6:Number, param7:String = "") : *
		{
			var val8:MovieClip = null;
			val8 = this.statusList.getElementByNumber("id",param3);
			if(val8 == null)
			{
				if(!param1)
				{
					return;
				}
				val8 = new StatusElement();
				val8.id = param3;
				val8.name_txt.autoSize = TextFieldAutoSize.LEFT;
				val8.hl_mc.visible = false;
				this.statusList.addElement(val8,false);
			}
			val8.setStatusData(-1,param6,param4);
			val8.name_txt.htmlText = param7;
			val8.turns_txt.htmlText = param5;
			val8.alive = true;
		}
		
		public function cleanupStatuses() : *
		{
			var val4:MovieClip = null;
			var val5:Number = NaN;
			var val1:Number = 0;
			var val2:MovieClip = root as MovieClip;
			var val3:* = 0;
			while(val3 < this.statusList.length)
			{
				val4 = this.statusList.content_array[val3];
				if(val4.alive)
				{
					val4.alive = false;
					val5 = this.statusList.content_array[val3].name_txt.width + this.statusList.content_array[val3].name_txt.x;
					if(val1 < val5)
					{
						val1 = val5;
					}
				}
				else
				{
					this.statusList.removeElement(val3,false);
					val3--;
				}
				val3++;
			}
			if(this.statusList.length > 0)
			{
				this.info_mc.noStatus_txt.visible = false;
				this.statusList.positionElements();
				val2.selectFirstStatus();
			}
			else
			{
				if(val2)
				{
					val2.clearTooltip();
				}
				this.info_mc.noStatus_txt.visible = true;
			}
		}
		
		public function clearStatuses() : *
		{
			this.statusList.clearElements();
		}
		
		public function setPointAssignMode(param1:Boolean) : *
		{
			this.pointsMode = param1;
		}
		
		public function setListLoopable(param1:Boolean) : *
		{
			this.statsList.m_cyclic = param1;
			if(this.currentPanel && this.currentPanel.setListLoopable)
			{
				this.currentPanel.setListLoopable(param1);
			}
			this.statusList.m_cyclic = param1;
		}
		
		public function cursorUp() : *
		{
			var val1:MovieClip = null;
			if(this.currentPanel != this.info_mc)
			{
				if(this.infoStatContainerFocused)
				{
					this.statsList.previous();
					this.statsListPos = this.statsList.currentSelection;
				}
				else if(this.currentPanel)
				{
					this.currentPanel.previous();
					this.currentPanel.updateHints();
				}
			}
			else
			{
				this.statusList.previous();
				val1 = this.statusList.getCurrentMovieClip();
				if(val1)
				{
					(root as MovieClip).oldId = val1.id;
				}
			}
			ExternalInterface.call("PlaySound","UI_Gen_CursorMove");
			this.setListLoopable(false);
		}
		
		public function cursorDown() : *
		{
			var val1:MovieClip = null;
			if(this.currentPanel != this.info_mc)
			{
				if(this.infoStatContainerFocused)
				{
					this.statsList.next();
					this.statsListPos = this.statsList.currentSelection;
				}
				else if(this.currentPanel)
				{
					this.currentPanel.next();
					this.currentPanel.updateHints();
				}
			}
			else
			{
				this.statusList.next();
				val1 = this.statusList.getCurrentMovieClip();
				if(val1)
				{
					(root as MovieClip).oldId = val1.id;
				}
			}
			ExternalInterface.call("PlaySound","UI_Gen_CursorMove");
			this.setListLoopable(false);
		}
		
		public function cursorRight() : *
		{
			var val1:MovieClip = null;
			if(this.currentPanel != this.info_mc && this.currentPanel != this.tags_mc)
			{
				this.leftPanelSelected = false;
				val1 = this.currentPanel.getCurrentElement();
				if(val1 != null)
				{
					val1.deselectElement();
				}
				if(this.statsListPos != undefined)
				{
					this.statsList.select(this.statsListPos,true,true);
				}
				else
				{
					this.statsList.select(0,true,true);
				}
				this.infoStatContainerFocused = true;
				ExternalInterface.call("PlaySound","UI_Gen_CursorMove");
			}
		}
		
		public function cursorLeft() : *
		{
			var val1:MovieClip = null;
			if(this.currentPanel != this.info_mc && this.currentPanel != this.tags_mc)
			{
				this.leftPanelSelected = true;
				val1 = this.statsList.getCurrentMovieClip();
				this.statsListPos = this.statsList.currentSelection;
				if(this.statsListPos != undefined)
				{
					val1.deselectElement();
				}
				val1 = this.currentPanel.getCurrentElement();
				if(val1 != null)
				{
					val1.selectElement();
				}
				else
				{
					this.currentPanel.next();
				}
				this.infoStatContainerFocused = false;
				this.setTooltipSide();
				ExternalInterface.call("PlaySound","UI_Gen_CursorMove");
			}
		}
		
		public function updateDone() : *
		{
			var val1:MovieClip = null;
			if(this.prevSelectedStatId != -1)
			{
				val1 = this.statsList.getElementByNumber("id",this.prevSelectedStatId);
				if(val1)
				{
					this.statsList.selectMC(val1,true);
					this.statsList.m_scrollbar_mc.scrollTo(this.prevY);
					this.prevSelectedStatId = -1;
				}
			}
			if(this.currentTab == 1)
			{
				this.fixStatsSelections();
			}
		}
		
		public function fixStatsSelections() : *
		{
			var val1:MovieClip = this.statsList.getCurrentMovieClip();
			if(this.infoStatContainerFocused)
			{
				this.currentPanel.getCurrentElement().deselectElement();
				if(val1 != null)
				{
					val1.selectElement();
				}
			}
			else
			{
				this.currentPanel.getCurrentElement().selectElement();
				if(val1 != null)
				{
					val1.deselectElement();
				}
			}
		}
		
		public function removePoint() : Boolean
		{
			var val1:MovieClip = null;
			if(this.pointsMode)
			{
				val1 = this.currentPanel.getCurrentElement();
				if(val1 && val1.isStat)
				{
					ExternalInterface.call("removePoints" + this.currentPanel.typeStr,val1.id);
					ExternalInterface.call("PlaySound","UI_Generic_Click");
					return true;
				}
			}
			return false;
		}
		
		public function addPoint() : Boolean
		{
			var val1:MovieClip = null;
			if(this.pointsMode)
			{
				val1 = this.currentPanel.getCurrentElement();
				if(val1 && val1.isStat)
				{
					if(val1.plus_mc && val1.plus_mc.visible || !val1.plus_mc)
					{
						ExternalInterface.call("addPoints" + this.currentPanel.typeStr,val1.id);
						ExternalInterface.call("PlaySound","UI_Generic_Click");
						return true;
					}
				}
			}
			return false;
		}
		
		public function cursorAccept() : *
		{
			var val1:MovieClip = null;
			if(this.currentSelectionPanel == 1)
			{
				val1 = this.currentPanel.getCurrentElement();
				if(val1 && val1.toggleOpenClose && val1.hl_mc.visible)
				{
					ExternalInterface.call("PlaySound","UI_Generic_Click");
					val1.toggleOpenClose();
				}
			}
		}
		
		public function init() : *
		{
			this.attributes_mc.typeStr = "Attr";
			this.combatAbilities_mc.typeStr = "Abil";
			this.civilAbilities_mc.typeStr = "Abil";
			this.talents_mc.typeStr = "Talent";
			this.tags_mc.typeStr = "";
			this.attributes_mc.init();
			this.combatAbilities_mc.init();
			this.civilAbilities_mc.init();
			this.talents_mc.init();
			this.showPanel(0);
			ExternalInterface.call("selectStatsTab",0);
			this.tabBar_mc.init();
			this.tooltip_mc.scaleH = false;
			this.tooltip_mc.tooltipH = 814;
			this.tooltip_mc.setupTooltip(new Array(1,"",58,""));
		}
		
		public function setHintContainer(param1:MovieClip) : *
		{
			this.attributes_mc.hintContainer = param1;
			this.combatAbilities_mc.hintContainer = param1;
			this.civilAbilities_mc.hintContainer = param1;
			this.talents_mc.hintContainer = param1;
			this.tags_mc.hintContainer = param1;
		}
		
		public function showPanel(param1:Number) : *
		{
			var val2:MovieClip = root as MovieClip;
			if(val2)
			{
				val2.clearTooltip();
			}
			var val3:MovieClip = null;
			this.bg_mc.visible = true;
			this.bg_mc.gotoAndStop(param1 == 0 || param1 == 5?2:1);
			this.infoStatContainer_mc.visible = !(param1 == 0 || param1 == 5);
			switch(param1)
			{
				case 0:
					this.currentPanel = this.info_mc;
					(root as MovieClip).selectFirstStatus(true);
					break;
				case 1:
					this.currentPanel = this.attributes_mc;
					break;
				case 2:
					this.currentPanel = this.combatAbilities_mc;
					break;
				case 3:
					this.currentPanel = this.civilAbilities_mc;
					break;
				case 4:
					this.currentPanel = this.talents_mc;
					break;
				case 5:
					this.currentPanel = this.tags_mc;
					break;
				case 6:
					this.currentPanel = this.customStats_mc;
					break;
				default:
					return;
			}
			this.currentPanel.visible = true;
			if(this.currentPanel != this.info_mc)
			{
				this.info_mc.visible = false;
			}
			if(this.currentPanel != this.attributes_mc)
			{
				this.attributes_mc.visible = false;
			}
			if(this.currentPanel != this.talents_mc)
			{
				this.talents_mc.visible = false;
			}
			if(this.currentPanel != this.combatAbilities_mc)
			{
				this.combatAbilities_mc.visible = false;
			}
			if(this.currentPanel != this.civilAbilities_mc)
			{
				this.civilAbilities_mc.visible = false;
			}
			if(this.currentPanel != this.tags_mc)
			{
				this.tags_mc.visible = false;
			}
			if(this.currentPanel != this.customStats_mc)
			{
				this.customStats_mc.visible = false;
			}
			if(this.currentPanel != this.info_mc)
			{
				val3 = this.currentPanel.getCurrentElement();
			}
			else
			{
				val3 = this.statusList.getCurrentMovieClip();
			}
			if(val3)
			{
				val3.selectElement();
			}
			this.currentTab = param1;
		}
		
		public function setTagsTabVis(param1:Boolean) : *
		{
			var val2:MovieClip = this.tabBar_mc.tabList.getElementByNumber("id",4);
			if(val2)
			{
				if(val2.visible != param1)
				{
					val2.visible = param1;
					if(!param1)
					{
						val2.x = 0;
					}
				}
				this.tabBar_mc.tabList.positionElements();
			}
		}
		
		public function getCurrentElement() : MovieClip
		{
			return this.statsList.getCurrentMovieClip();
		}
		
		function frame1() : *
		{
			this.statsList = new scrollList("empty","empty");
			this.prevSelectedStatId = -1;
			this.prevY = -1;
			this.leftPanelSelected = true;
			this.infoStatContainer_mc.addChild(this.statsList);
			this.statsList.m_scrollbar_mc.ScaleBG = true;
			this.statsList.setFrame(390,730);
			this.statsList.EL_SPACING = 1;
			this.statsList.m_scrollbar_mc.m_SCROLLSPEED = 32;
			this.statsList.m_customElementHeight = 30;
			this.statsList.TOP_SPACING = 0;
			this.statsList.SB_SPACING = -15;
			this.statsList.m_cyclic = true;
			this.statsListPos = undefined;
			this.statusList = new scrollList("empty","empty");
			this.info_mc.statusContainer_mc.addChild(this.statusList);
			this.statusList.m_customElementHeight = 45;
			this.statusList.m_scrollbar_mc.ScaleBG = true;
			this.statusList.setFrame(712,4 * this.statusList.m_customElementHeight + 20);
			this.currentPanel = null;
			this.currentTab = 0;
			this.currentSelectionPanel = 1;
			this.pointsMode = false;
			this.infoStatContainerFocused = false;
		}
	}
}
