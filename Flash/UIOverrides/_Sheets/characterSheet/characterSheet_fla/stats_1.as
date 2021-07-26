package characterSheet_fla
{
	import LS_Classes.LSPanelHelpers;
	import LS_Classes.horizontalList;
	import LS_Classes.horizontalScrollList;
	import LS_Classes.larTween;
	import LS_Classes.listDisplay;
	import LS_Classes.textEffect;
	import LS_Classes.textHelpers;
	import LS_Classes.scrollListGrouped;
	import fl.motion.easing.Sine;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.geom.Point;
	
	public dynamic class stats_1 extends MovieClip
	{
		public var aiSel_mc:comboBox;
		public var alignments_mc:comboBox;
		public var attrPointsWrn_mc:MovieClip;
		public var bg_mc:MovieClip;
		public var charInfo_mc:MovieClip;
		public var charList_mc:empty;
		public var civicAbilityHolder_mc:MovieClip;
		public var civilAbilityPointsWrn_mc:MovieClip;
		public var close_mc:MovieClip;
		public var combatAbilityHolder_mc:MovieClip;
		public var combatAbilityPointsWrn_mc:MovieClip;
		public var customStats_mc:MovieClip;
		public var customStatsPointsWrn_mc:mcPlus_Anim_69;
		public var customStatsPoints_txt:TextField;
		public var dragHit_mc:MovieClip;
		public var equip_mc:MovieClip;
		public var equipment_txt:TextField;
		public var hitArea_mc:MovieClip;
		public var invTabHolder_mc:MovieClip;
		public var leftCycleBtn_mc:MovieClip;
		public var mainStats_mc:MovieClip;
		public var onePlayerOverlay_mc:MovieClip;
		public var panelBg1_mc:MovieClip;
		public var panelBg2_mc:MovieClip;
		public var pointsFrame_mc:MovieClip;
		public var rightCycleBtn_mc:MovieClip;
		public var scrollbarHolder_mc:empty;
		public var skillTabHolder_mc:MovieClip;
		public var tabTitle_txt:TextField;
		public var tabsHolder_mc:empty;
		public var tagsHolder_mc:MovieClip;
		public var talentHolder_mc:MovieClip;
		public var talentPointsWrn_mc:MovieClip;
		public var title_txt:TextField;
		public var visualHolder_mc:MovieClip;
		public var myText:String;
		public var closeCenterX:Number;
		public var closeSideX:Number;
		public var buttonY:Number;
		public var base:MovieClip;
		public var lvlUP:Boolean;
		public var cellSize:Number;
		public var statholderListPosY:Number;
		public var listOffsetY:Number;
		public var tabsList:horizontalList;
		public var charList:horizontalScrollList;
		public var primaryStatList:listDisplay;
		public var secondaryStatList:listDisplay;
		public var expStatList:listDisplay;
		public var resistanceStatList:listDisplay;
		public var infoStatList:listDisplay;
		public const statsElWidth:Number = 240;
		public var secELSpacing:Number;
		public var currentOpenPanel:Number;
		public var panelArray:Array;
		public var selectedTabY:Number;
		public var deselectedTabY:Number;
		public var selectedTabAlpha:Number;
		public var deselectedTabAlpha:Number;
		public var tabsArray:Array;
		public var pointsWarn:Array;
		public var pointTexts:Array;
		public var root_mc:MovieClip;
		public var gmSkillsString:String;
		public const tabTweenInTime:Number = 0.12;
		public const PointsFrameW:Number = 160;
		public const RightFrameW:Number = 304;

		//LeaderLib
		public var customStatIconOffsetX:Number = -2;
		public var customStatIconOffsetY:Number = -6;
		public var pointWarningOffsetX:Number = -16;
		public var customStatPointsTextOffsetX:Number = -1.89;

		public var mainStatsList:scrollListGrouped;
		public var GROUP_MAIN_ATTRIBUTES:int = 0;
		public var GROUP_MAIN_STATS:int = 1;
		public var GROUP_MAIN_EXPERIENCE:int = 2;
		public var GROUP_MAIN_RESISTANCES:int = 3;
		
		public function stats_1()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function init() : *
		{
			this.tabsArray = new Array();
			this.root_mc = root as MovieClip;
			this.title_txt.filters = this.equipment_txt.filters = this.charInfo_mc.selCharInfo_txt.filters = this.tabTitle_txt.filters = this.pointsFrame_mc.filters = textEffect.createStrokeFilter(0,1.4,2,1.8,3);
			this.charInfo_mc.renameBtn_mc.initialize("",this.renameCallback);
			this.charInfo_mc.renameBtn_mc.tooltip = this.root_mc.renameBtnTooltip;
			this.charInfo_mc.renameBtn_mc.SND_Press = "UI_GM_Generic_Click_Press";
			this.charInfo_mc.renameBtn_mc.SND_Click = "UI_GM_Generic_Click_Release";
			this.aiSel_mc.init(this.selectAI);
			this.alignments_mc.init(this.selectAlignment);
			this.alignments_mc.SND_Open = "UI_GM_Generic_Slide_Open";
			this.alignments_mc.SND_Close = "UI_GM_Generic_Slide_Close";
			this.alignments_mc.SND_Click = "UI_GM_Generic_Click";
			this.panelArray = new Array(this.mainStats_mc,this.combatAbilityHolder_mc,this.civicAbilityHolder_mc,this.talentHolder_mc,this.tagsHolder_mc,this.invTabHolder_mc,this.skillTabHolder_mc,this.visualHolder_mc,this.customStats_mc);
			this.pointsWarn = new Array(this.attrPointsWrn_mc,this.combatAbilityPointsWrn_mc,this.civilAbilityPointsWrn_mc,this.talentPointsWrn_mc,this.customStatsPointsWrn_mc);
			this.pointTexts = new Array(this.pointsFrame_mc.statPoints_txt,this.pointsFrame_mc.combatAbilPoints_txt,this.pointsFrame_mc.civilAbilPoints_txt,this.pointsFrame_mc.talentPoints_txt,this.pointsFrame_mc.customStatPoints_txt);
			this.bg_mc.mouseEnabled = false;
			this.bg_mc.mouseChildren = false;
			this.close_mc.onPressedFunction = this.closeUI;
			this.onePlayerOverlay_mc.visible = false;
			ExternalInterface.call("getStats");
			this.equip_mc.init();
			var i:int = 0;
			while(i < this.pointsWarn.length)
			{
				this.pointsWarn[i].visible = false;
				this.pointsWarn[i].stop();
				this.pointsWarn[i].mouseEnabled = false;
				this.pointsWarn[i].mouseChildren = false;
				this.pointsWarn[i].avPoints = 0;
				i++;
			}
			this.panelBg1_mc.gotoAndStop(1);
			this.panelBg2_mc.gotoAndStop(2);
			this.panelBg2_mc.visible = false;
			if(this.root_mc)
			{
				this.updateAllignments(this.root_mc.allignmentArray);
				this.root_mc.allignmentArray = new Array();
			}
			this.charInfo_mc.min_mc.callbackStr = "minLevel";
			this.charInfo_mc.plus_mc.callbackStr = "plusLevel";
			this.leftCycleBtn_mc.initButton(true);
			this.rightCycleBtn_mc.initButton(false);
			this.leftCycleBtn_mc.visible = false;
			this.rightCycleBtn_mc.visible = false;
			this.onePlayerOverlay_mc.mouseEnabled = false;
			this.currentOpenPanel = -1;
			this.buildTabs(0,true);
		}
		
		public function selectAI() : *
		{
			if(this.aiSel_mc.selectedItem != null)
			{
				ExternalInterface.call("selectAI",this.aiSel_mc.selectedItem.id);
			}
		}
		
		public function selectAlignment() : *
		{
			if(this.alignments_mc.selectedItem != null)
			{
				ExternalInterface.call("selectAlignment",this.alignments_mc.selectedItem.id);
			}
		}
		
		public function renameCallback() : *
		{
			ExternalInterface.call("renameCharacter");
		}
		
		public function updateInventorySlots(arr:Array) : *
		{
			var slot:uint = 0;
			var itemHandle:Number = NaN;
			var frame:uint = 0;
			var i:uint = 0;
			while(i < arr.length)
			{
				slot = arr[i++];
				itemHandle = arr[i++];
				frame = arr[i++];
				this.invTabHolder_mc.inventory.addItem(slot,itemHandle,frame);
			}
			this.invTabHolder_mc.inventory.cleanUpItems();
		}
		
		public function resetListPositions() : *
		{
		}
		
		public function buildTabs(tabState:Number, initializeTabs:Boolean = false) : *
		{
			var i:uint = 0;
			var tab_mc:MovieClip = null;
			var tab_button:MovieClip = null;
			var tab_button2:MovieClip = null;
			var tab_buttonGM:MovieClip = null;
			i = 0;
			while(i < this.tabsArray.length)
			{
				tab_mc = this.tabsArray[i];
				if(tab_mc != null && tab_mc.tw != null)
				{
					tab_mc.tw.stop();
					tab_mc.tw = null;
				}
				i++;
			}
			this.tabsList.clearElements();
			this.tabsArray = new Array();
			i = 0;
			switch(tabState)
			{
				case 0:
					i = 0;
					while(i < 5)
					{
						tab_button = new StatsTabButton();
						tab_button.id = i;
						this.tabsArray.push(tab_button);
						i++;
					}
					//LeaderLib: Always add the custom stats button
					tab_button = new StatsTabButton();
					tab_button.id = 8;
					this.tabsArray.push(tab_button);
					this.tabsList.EL_SPACING = -10;
					break;
				case 1:
					i = 0;
					while(i < 9)
					{
						//LeaderLib: Making sure the tags button is added. i < 4 changed to i < 5
						if(i < 5 || i == 8)
						{
							tab_button2 = new StatsTabButton();
							tab_button2.id = i;
							this.tabsArray.push(tab_button2);
						}
						i++;
					}
					this.tabsList.EL_SPACING = -10;
					break;
				case 2:
					i = 0;
					while(i < 9)
					{
						//if(i != 4)
						//LeaderLib: Making sure the tags button is added.
						tab_buttonGM = new StatsTabButtonGM();
						tab_buttonGM.id = i;
						this.tabsArray.push(tab_buttonGM);
						i++;
					}
					this.tabsList.EL_SPACING = -15;
			}
			var currentPanel:* = this.currentOpenPanel;
			var isCurrentPanel:Boolean = false;
			i = 0;
			while(i < this.tabsArray.length)
			{
				this.tabsList.addElement(this.tabsArray[i],false);
				if(this.currentOpenPanel == this.tabsArray[i].id)
				{
					isCurrentPanel = isCurrentPanel || true;
				}
				i++;
			}
			this.tabsList.positionElements();
			
			//LeaderLib addition
			this.alignPointWarningsToButtons();

			this.initTabs(!isCurrentPanel,initializeTabs);
			this.ClickTab(!!isCurrentPanel?Number(currentPanel):Number(0));
			this.INTSetAvailablePointsVisible();
		}

		public function alignPointWarningsToButtons() : *
		{
			var i:int = 0;
			var tabIndex:int = 0;
			var pw:MovieClip = null;
			var pt:Point = null;
			while(i < this.pointsWarn.length)
			{
				pw = this.pointsWarn[i];
				tabIndex = i;
				if (i == 4)
				{
					tabIndex = 8;
				}
				var btn:* = this.tabsList.getElementByNumber("id", tabIndex);
				if (btn != undefined)
				{
					pt = this.tabsList.localToGlobal(new Point(btn.x+btn.width,btn.y));
					pt = this.globalToLocal(pt);
					pw.x = pt.x+pointWarningOffsetX;
				}

				i++;
			}
		}
		
		public function pushTabTooltip(tabId:Number, text:String) : *
		{
			var val3:uint = 0;
			while(val3 < this.tabsArray.length)
			{
				if(this.tabsArray[val3].id == tabId)
				{
					this.tabsArray[val3].tooltip = text;
					return;
				}
				val3++;
			}
		}
		
		public function initTabs(bInitTab:Boolean = false, resetTabs:Boolean = false) : *
		{
			var i:uint = 0;
			var tabId:Number = NaN;
			if(resetTabs)
			{
				i = 0;
				while(i < this.panelArray.length)
				{
					this.panelArray[i].visible = false;
					if(bInitTab && this.panelArray[i].init != null)
					{
						this.panelArray[i].init();
					}
					if(this.panelArray[i].list)
					{
						this.panelArray[i].list.enableMouseWheelOnOver = true;
						this.panelArray[i].list.m_scrollbar_mc.visible = false;
						this.panelArray[i].list.m_scrollbar_mc.disabled = false;
						this.panelArray[i].list.m_scrollbar_mc.m_hideWhenDisabled = true;
					}
					i++;
				}
			}
			i = 0;
			while(i < this.tabsArray.length)
			{
				tabId = this.tabsArray[i].id;
				if((root as MovieClip).tabsTexts.length > tabId)
				{
					this.tabsArray[i].tooltip = (root as MovieClip).tabsTexts[tabId];
				}
				this.tabsArray[i].icon_mc.gotoAndStop(tabId + 1);
				this.tabsArray[i].pressedFunc = this.ClickTab;
				if(i == this.currentOpenPanel)
				{
					this.panelArray[i].visible = true;
					this.tabsArray[i].icon_mc.y = this.selectedTabY;
					this.tabsArray[i].tw = new larTween(this.tabsArray[i].icon_mc,"alpha",Sine.easeOut,this.tabsArray[i].icon_mc.alpha,this.selectedTabAlpha,this.tabTweenInTime);
					this.tabsArray[i].texty = this.selectedTabY;
					this.tabsArray[i].setActive(true);
					this.tabTitle_txt.htmlText = this.panelArray[tabId].labelStr;
					textHelpers.smallCaps(this.tabTitle_txt);
				}
				else
				{
					this.panelArray[i].visible = false;
					this.tabsArray[i].icon_mc.y = this.deselectedTabY;
					this.tabsArray[i].tw = new larTween(this.tabsArray[i].icon_mc,"alpha",Sine.easeOut,this.tabsArray[i].icon_mc.alpha,this.deselectedTabAlpha,this.tabTweenInTime);
					this.tabsArray[i].texty = this.deselectedTabY;
					this.tabsArray[i].setActive(false);
				}
				i++;
			}

			this.pointsFrame_mc.setTab(this.currentOpenPanel);
		}
		
		public function selectCharacter(id:Number) : *
		{
			var charPortrait_mc:MovieClip = this.charList.getElementByNumber("id",id);
			if(charPortrait_mc)
			{
				this.charList.selectMC(charPortrait_mc,true);
				this.invTabHolder_mc.inventory.id = id;
			}
			if(this.aiSel_mc.visible && this.aiSel_mc.m_isOpen)
			{
				this.aiSel_mc.close();
			}
			if(this.alignments_mc.visible && this.alignments_mc.m_isOpen)
			{
				this.alignments_mc.close();
			}
		}
		
		public function addCharPortrait(id:Number, iconId:String, order:uint) : *
		{
			var charPortrait_mc:MovieClip = this.charList.getElementByNumber("id",id);
			if(!charPortrait_mc)
			{
				charPortrait_mc = new charPortrait();
				charPortrait_mc.init();
				charPortrait_mc.id = id;
				this.charList.addElement(charPortrait_mc,false);
				charPortrait_mc.frame_mc.gotoAndStop(3);
			}
			if(charPortrait_mc)
			{
				charPortrait_mc.order = order;
				charPortrait_mc.hasUpdated = true;
				charPortrait_mc.setIcon("p" + iconId);
			}
		}
		
		public function cleanupCharListObsoletes() : *
		{
			var val2:MovieClip = null;
			var val1:uint = 0;
			while(val1 < this.charList.length)
			{
				val2 = this.charList.getAt(val1);
				if(val2 && val2.hasUpdated)
				{
					val2.hasUpdated = false;
					val1++;
				}
				else
				{
					this.charList.removeElement(val1,false);
				}
			}
			this.charList.sortOnce(["order"],[Array.NUMERIC]);
		}
		
		public function removeChildrenOf(mc:MovieClip) : void
		{
			var val2:int = 0;
			if(mc.numChildren != 0)
			{
				val2 = mc.numChildren;
				while(val2 > 0)
				{
					val2--;
					mc.removeChildAt(val2);
				}
			}
		}
		
		public function ClickTab(tabIndex:Number) : *
		{
			var tab_mc:MovieClip = null;
			if(this.currentOpenPanel != tabIndex)
			{
				if(this.currentOpenPanel != -1)
				{
					if(this.panelArray[this.currentOpenPanel])
					{
						this.panelArray[this.currentOpenPanel].visible = false;
						if(this.panelArray[this.currentOpenPanel].list)
						{
							if(this.panelArray[this.currentOpenPanel].list.m_scrollbar_mc)
							{
								this.panelArray[this.currentOpenPanel].list.m_scrollbar_mc.visible = false;
							}
						}
					}
					tab_mc = this.getTabById(this.currentOpenPanel);
					if(tab_mc)
					{
						tab_mc.setActive(false);
						tab_mc.icon_mc.y = this.deselectedTabY;
						tab_mc.icon_mc.alpha = this.deselectedTabAlpha;
						tab_mc.texty = this.deselectedTabY;
					}
				}
				if(tabIndex != -1)
				{
					if(this.panelArray[tabIndex])
					{
						this.panelArray[tabIndex].visible = true;
						if(this.panelArray[tabIndex].list && this.panelArray[tabIndex].list.m_scrollbar_mc)
						{
							this.panelArray[tabIndex].list.m_scrollbar_mc.visible = true;
							this.panelArray[tabIndex].list.m_scrollbar_mc.scrollbarVisible();
						}
					}
					this.selectTab(tabIndex);
				}
				this.panelBg1_mc.visible = tabIndex < 5 || tabIndex == 6 || tabIndex == 8; // LeaderLib change
				this.panelBg2_mc.visible = tabIndex == 5;
				if(tabIndex == 5)
				{
					this.panelBg2_mc.gotoAndStop(2);
				}
				this.currentOpenPanel = tabIndex;
				this.INTSetAvailablePointsVisible();
				this.pointsFrame_mc.setTab(this.currentOpenPanel);
			}
			ExternalInterface.call("selectedTab",this.currentOpenPanel);
		}
		
		public function selectTab(index:Number) : *
		{
			var val2:MovieClip = this.getTabById(index);
			if(val2)
			{
				val2.setActive(true);
				val2.icon_mc.y = this.selectedTabY;
				val2.icon_mc.alpha = this.selectedTabAlpha;
				val2.texty = this.selectedTabY;
				this.tabTitle_txt.htmlText = this.panelArray[index].labelStr;
				textHelpers.smallCaps(this.tabTitle_txt);
			}
		}
		
		public function getTabById(tabId:Number) : MovieClip
		{
			var tab_mc:MovieClip = null;
			var i:uint = 0;
			while(i < this.tabsArray.length)
			{
				if(this.tabsArray[i].id == tabId)
				{
					tab_mc = this.tabsArray[i];
					break;
				}
				i++;
			}
			return tab_mc;
		}
		
		public function setPanelTitle(index:Number, titleText:String) : *
		{
			this.panelArray[index].title_txt.htmlText = titleText;
		}
		
		public function resetScrollBarsPositions() : *
		{
			this.combatAbilityHolder_mc.list.m_scrollbar_mc.resetContentPosition();
			this.civicAbilityHolder_mc.list.m_scrollbar_mc.resetContentPosition();
			this.talentHolder_mc.list.m_scrollbar_mc.resetContentPosition();
			this.tagsHolder_mc.list.m_scrollbar_mc.resetContentPosition();
		}
		
		public function INTSetWarnAndPoints(index:Number, pointsValue:Number) : *
		{
			var pointsWarn_mc:MovieClip = null;
			var pointsWarn_tf:TextField = null;

			if(!(root as MovieClip).isGameMasterChar)
			{
				pointsWarn_mc = this.pointsWarn[index];
				pointsWarn_tf = this.pointTexts[index];
				if(pointsWarn_mc)
				{
					pointsWarn_mc.visible = pointsValue != 0;
					pointsWarn_mc.avPoints = pointsValue;
					if(pointsWarn_mc.visible)
					{
						pointsWarn_mc.play();
					}
					else
					{
						pointsWarn_mc.stop();
					}
				}
				if(pointsWarn_tf)
				{
					pointsWarn_tf.htmlText = pointsValue + "";
					textHelpers.smallCaps(pointsWarn_tf);
					pointsWarn_tf.x = (this.pointsFrame_mc.label_txt.x + this.pointsFrame_mc.label_txt.textWidth + 8);
					this.pointsFrame_mc.x = this.PointsFrameW - Math.round((pointsWarn_tf.x + pointsWarn_tf.textWidth) * 0.5);

					if (index == 4)
					{
						//For some reason this text is slightly too much to the right, even though the x position says it's the same as the others.
						//Leading, margin values etc. all seem to be the same as well.
						pointsWarn_tf.x = pointsWarn_tf.x + this.customStatPointsTextOffsetX;//this.pointTexts[2].x;
					}
				}

				if((this.currentOpenPanel == 8 && index == 4) || this.currentOpenPanel == index)
				{
					this.INTSetAvailablePointsVisible();
				}
			}
			else
			{
				// pointsWarn_mc = this.pointsWarn[index];
				// if(pointsWarn_mc)
				// {
				// 	pointsWarn_mc.stop();
				// 	pointsWarn_mc.visible = false;
				// }
				//LeaderLib: Fix to make sure all the buttons are hidden.
				var i:uint = 0;
				while(i < this.pointsWarn.length)
				{
					this.pointsWarn[i].visible = false;
					this.pointsWarn[i].stop();
					this.pointsWarn[i].mouseEnabled = false;
					this.pointsWarn[i].mouseChildren = false;
					this.pointsWarn[i].avPoints = 0;
					i++;
				}
			}
		}
		
		public function INTSetAvailablePointsVisible() : *
		{
			//LeaderLib: Allowing the custom stats panel to display available points.
			if(this.currentOpenPanel == 8)
			{
				this.pointsFrame_mc.visible = this.pointsWarn[4].visible;
			}
			else
			{
				if(this.currentOpenPanel >= 0 && this.currentOpenPanel < 4)
				{
					this.pointsFrame_mc.visible = this.pointsWarn[this.currentOpenPanel].visible;
				}
				else
				{
					this.pointsFrame_mc.visible = false;
				}
			}
			this.tabTitle_txt.visible = !this.pointsFrame_mc.visible;
		}
		
		public function setAvailableStatPoints(points:Number) : *
		{
			this.INTSetWarnAndPoints(0,points);
		}
		
		public function setAvailableCombatAbilityPoints(points:Number) : *
		{
			this.INTSetWarnAndPoints(1,points);
		}
		
		public function setAvailableCivilAbilityPoints(points:Number) : *
		{
			this.INTSetWarnAndPoints(2,points);
		}
		
		public function setAvailableTalentPoints(points:Number) : *
		{
			this.INTSetWarnAndPoints(3,points);
		}
		
		public function setVisibilityStatButtons(isVisible:Boolean) : *
		{
			var stat_mc:MovieClip = null;
			var i:uint = 0;
			while(i < this.primaryStatList.length)
			{
				stat_mc = this.primaryStatList.content_array[i];
				if(stat_mc)
				{
					stat_mc.plus_mc.visible = isVisible;
					stat_mc.minus_mc.visible = isVisible;
				}
				i++;
			}
		}
		
		public function setStatPlusVisible(id:Number, isVisible:Boolean) : *
		{
			var stat_mc:MovieClip = this.getStat(id);
			if(stat_mc)
			{
				stat_mc.plus_mc.visible = isVisible;
			}
		}
		
		public function setStatMinusVisible(id:Number, isVisible:Boolean) : *
		{
			var stat_mc:MovieClip = this.getStat(id);
			if(stat_mc)
			{
				stat_mc.minus_mc.visible = isVisible;
			}
		}
		
		public function setupSecondaryStatsButtons(id:int, showBoth:Boolean, minusVisible:Boolean, plusVisible:Boolean, maxChars:Number = 5) : void
		{
			var stat_mc:MovieClip = this.getSecStat(id);
			if(stat_mc.setupButtons != null)
			{
				stat_mc.setupButtons(showBoth,minusVisible,plusVisible,maxChars);
			}
			else
			{
				stat_mc.minus_mc.visible = minusVisible;
				stat_mc.plus_mc.visible = plusVisible;
			}
		}
		
		public function getStat(statID:Number, isCustom:Boolean=false) : MovieClip
		{
			return this.primaryStatList.getElementByNumber("statID",statID);
		}
		
		public function getSecStat(statID:Number, isCustom:Boolean=false) : MovieClip
		{
			var stat_mc:MovieClip = this.resistanceStatList.getElementByNumber("statID",statID);
			if(stat_mc == null)
			{
				stat_mc = this.secondaryStatList.getElementByNumber("statID",statID);
			}
			if(stat_mc == null)
			{
				stat_mc = this.infoStatList.getElementByNumber("statID",statID);
			}
			if(stat_mc == null)
			{
				stat_mc = this.expStatList.getElementByNumber("statID",statID);
			}
			return stat_mc;
		}
		
		public function getAbility(isCivil:Boolean, groupId:Number, statID:Number, isCustom:Boolean=false) : MovieClip
		{
			var holder:MovieClip = this.combatAbilityHolder_mc;
			if(isCivil)
			{
				holder = this.civicAbilityHolder_mc;
			}
			var group_mc:MovieClip = holder.list.getElementByNumber("groupId",groupId);
			if(group_mc)
			{
				return group_mc.list.getElementByNumber("statID",statID);
			}
			return null;
		}
		
		public function getTalent(statID:Number, isCustom:Boolean=false) : MovieClip
		{
			return this.talentHolder_mc.list.getElementByNumber("statID",statID);
		}
		
		public function getTag(statID:Number) : MovieClip
		{
			return this.tagsHolder_mc.list.getElementByNumber("statID", statID);
		}
		
		public function setVisibilityAbilityButtons(isCivil:Boolean, isVisible:Boolean) : *
		{
			var val4:uint = 0;
			var val5:MovieClip = null;
			var val6:uint = 0;
			var val7:MovieClip = null;
			var val3:MovieClip = this.combatAbilityHolder_mc;
			if(isCivil)
			{
				val3 = this.civicAbilityHolder_mc;
			}
			if(val3.list.content_array)
			{
				val4 = 0;
				while(val4 < val3.list.length)
				{
					val5 = val3.list.getAt(val4);
					val6 = 0;
					while(val6 < val5.list.length)
					{
						val7 = val5.list.getAt(val6);
						if(val7)
						{
							val7.texts_mc.plus_mc.visible = isVisible;
							val7.texts_mc.minus_mc.visible = isVisible;
						}
						val6++;
					}
					val4++;
				}
			}
		}
		
		public function setAbilityPlusVisible(param1:Boolean, param2:Number, param3:Number, param4:Boolean) : *
		{
			var val5:MovieClip = this.getAbility(param1,param2,param3);
			if(val5)
			{
				val5.texts_mc.plus_mc.visible = param4;
			}
		}
		
		public function setAbilityMinusVisible(param1:Boolean, param2:Number, param3:Number, param4:Boolean) : *
		{
			var val5:MovieClip = this.getAbility(param1,param2,param3);
			if(val5)
			{
				val5.texts_mc.minus_mc.visible = param4;
			}
		}
		
		public function setVisibilityTalentButtons(isVisible:Boolean) : *
		{
			var val2:uint = 0;
			while(val2 < this.talentHolder_mc.list.length)
			{
				if(this.talentHolder_mc.list.content_array[val2])
				{
					this.talentHolder_mc.list.content_array[val2].plus_mc.visible = isVisible;
					this.talentHolder_mc.list.content_array[val2].minus_mc.visible = isVisible;
				}
				val2++;
			}
		}
		
		public function setTalentPlusVisible(talentId:Number, visible:Boolean) : *
		{
			var val3:MovieClip = this.getTalent(talentId);
			if(val3)
			{
				val3.plus_mc.visible = visible;
			}
		}
		
		public function setTalentMinusVisible(talentId:Number, visible:Boolean) : *
		{
			var val3:MovieClip = this.getTalent(talentId);
			if(val3)
			{
				val3.minus_mc.visible = visible;
			}
		}
		
		public function addText(text:String, tooltip:String, isSecondary:Boolean) : *
		{
			var text_mc:MovieClip = new Text();
			text_mc.label_txt.autoSize = "left";
			text_mc.label_txt.htmlText = text;
			text_mc.tooltip = tooltip;
			if(isSecondary)
			{
				this.secondaryStatList.addElement(text_mc);
			}
			else
			{
				this.primaryStatList.addElement(text_mc);
			}
			this.mainStatsList.positionElements();
		}
		
		public function addSpacing(listId:Number, height:Number) : *
		{
			var spacing_mc:MovieClip = new Spacing();
			spacing_mc.height = height;
			spacing_mc.heightOverride = height;
			this.addToListWithId(listId,spacing_mc);
		}
		
		public function addAbilityGroup(isCivil:Boolean, groupId:Number, labelText:String) : *
		{
			var groupHolder:MovieClip = this.combatAbilityHolder_mc;
			if(isCivil)
			{
				groupHolder = this.civicAbilityHolder_mc;
			}
			groupHolder.list.addGroup(groupId,labelText);
			var group_mc:MovieClip = groupHolder.list.getElementByNumber("groupId",groupId);
			if (group_mc != null)
			{
				group_mc.groupName = labelText;
			}
		}
		
		public function addAbility(isCivil:Boolean, groupId:Number, statID:Number, labelText:String, valueText:String, plusTooltip:String = "", minusTooltip:String = "", plusVisible:Boolean = false, minusVisible:Boolean = false, isCustom:Boolean=false) : *
		{
			var groupHolder:MovieClip = null;
			var ability_mc:MovieClip = this.getAbility(isCivil,groupId,statID,isCustom);
			if(ability_mc == null)
			{
				groupHolder = this.combatAbilityHolder_mc;
				if(isCivil)
				{
					groupHolder = this.civicAbilityHolder_mc;
				}
				ability_mc = new AbilityEl();
				ability_mc.isCivil = isCivil;
				groupHolder.list.addGroupElement(groupId,ability_mc,false);
				ability_mc.texts_mc.plus_mc.visible = false;
				ability_mc.texts_mc.minus_mc.visible = false;
				ability_mc.texts_mc.statID = statID;
				ability_mc.statID = statID;
				ability_mc.tooltip = statID;
				ability_mc.texts_mc.id = groupHolder.list.length;
				ability_mc.texts_mc.plus_mc.currentTooltip = "";
				ability_mc.texts_mc.minus_mc.currentTooltip = "";
				ability_mc.texts_mc.label_txt.autoSize = TextFieldAutoSize.LEFT;
			}
			ability_mc.texts_mc.plus_mc.tooltip = plusTooltip;
			ability_mc.texts_mc.minus_mc.tooltip = minusTooltip;
			ability_mc.texts_mc.plus_mc.visible = plusVisible;
			ability_mc.texts_mc.minus_mc.visible = minusVisible;
			if(ability_mc.texts_mc.plus_mc.currentTooltip != "" && ability_mc.texts_mc.plus_mc.currentTooltip != plusTooltip)
			{
				ExternalInterface.call("showTooltip",plusTooltip);
				ability_mc.texts_mc.plus_mc.currentTooltip = plusTooltip;
			}
			if(ability_mc.texts_mc.minus_mc.currentTooltip != "" && ability_mc.texts_mc.minus_mc.currentTooltip != minusTooltip)
			{
				ExternalInterface.call("showTooltip",minusTooltip);
				ability_mc.texts_mc.plus_mc.currentTooltip = minusTooltip;
			}
			ability_mc.texts_mc.label_txt.htmlText = labelText;
			ability_mc.texts_mc.text_txt.htmlText = valueText;
			ability_mc.textStr = ability_mc.texts_mc.label_txt.text;
			ability_mc.am = Number(ability_mc.texts_mc.text_txt.text);
			ability_mc.texts_mc.statBasePoints = Number(valueText);
			ability_mc.texts_mc.statPoints = 0;
			ability_mc.hl_mc.height = ability_mc.abilTooltip_mc.height = ability_mc.texts_mc.label_txt.y + ability_mc.texts_mc.label_txt.textHeight - ability_mc.hl_mc.y;
			ability_mc.texts_mc.text_txt.y = Math.round((ability_mc.hl_mc.height - ability_mc.texts_mc.text_txt.textHeight) * 0.5);
			ability_mc.MakeCustom(statID, isCustom);
			ExternalInterface.call("abilityAdded", ability_mc.statID, ability_mc.id);
		}
		
		public function recountAbilityPoints(isCivil:Boolean) : *
		{
			var i:uint = 0;
			var group_mc:MovieClip = null;
			var group_list:listDisplay = null;
			var amount:Number = NaN;
			var group_index:uint = 0;
			var holder:MovieClip = this.combatAbilityHolder_mc;
			if(isCivil)
			{
				holder = this.civicAbilityHolder_mc;
			}
			if(holder.list.length > 0)
			{
				i = 0;
				while(i < holder.list.length)
				{
					group_mc = holder.list.content_array[i];
					if(group_mc && group_mc.list)
					{
						group_list = group_mc.list;
						amount = 0;
						group_index = 0;
						while(group_index < group_list.length)
						{
							amount = amount + group_list.content_array[group_index].am;
							group_index++;
						}
					}
					group_mc.amount_txt.htmlText = amount;
					i++;
				}
			}
		}
		
		public function addTalent(labelText:String, statID:Number, talentState:Number, plusVisible:Boolean = false, minusVisible:Boolean = false, isCustom:Boolean=false) : *
		{
			var talent_mc:MovieClip = this.getTalent(statID, isCustom);
			if(!talent_mc)
			{
				talent_mc = new Talent();
				talent_mc.label_txt.autoSize = "left";
				talent_mc.tooltip = statID;
				talent_mc.statID = statID;
				talent_mc.minus_mc.x = 260;
				talent_mc.plus_mc.x = talent_mc.minus_mc.x + talent_mc.minus_mc.width;
				//talent_mc.plus_mc.visible = talent_mc.minus_mc.visible = false;
				talent_mc.id = this.talentHolder_mc.list.length;
				this.talentHolder_mc.list.addElement(talent_mc,false);
			}
			talent_mc.plus_mc.visible = plusVisible;
			talent_mc.minus_mc.visible = minusVisible;
			talent_mc.label_txt.htmlText = labelText;
			talent_mc.hl_mc.width = this.statsElWidth;
			talent_mc.hl_mc.height = talent_mc.label_txt.textHeight + talent_mc.label_txt.y;
			talent_mc.plus_mc.y = talent_mc.minus_mc.y = talent_mc.hl_mc.y + Math.ceil((talent_mc.hl_mc.height - talent_mc.minus_mc.height) * 0.5) - 3;
			talent_mc.label = talent_mc.label_txt.text;
			talent_mc.talentState = talentState;
			talent_mc.bullet_mc.gotoAndStop(this.getTalentStateFrame(talentState));
			talent_mc.MakeCustom(statID, isCustom);
			ExternalInterface.call("talentAdded", talent_mc.statID, talent_mc.id);
		}

		public function getTalentStateFrame(state:Number) : Number
		{
			switch(state)
			{
				case 0:
					return 2;
				case 1:
					return 3;
				case 2:
					return 1;
				case 3:
					return 1;
				default:
					return 1;
			}
		}
		
		public function addPrimaryStat(statID:Number, displayName:String, value:String, tooltipId:Number, plusVisible:Boolean = false, minusVisible:Boolean = false, isCustom:Boolean=false) : *
		{
			var stat_mc:MovieClip = new Stat();
			stat_mc.tooltipAlign = "right";
			stat_mc.hl_mc.alpha = 0;
			stat_mc.plus_mc.visible = plusVisible;
			stat_mc.minus_mc.visible = minusVisible;
			stat_mc.label_txt.autoSize = TextFieldAutoSize.LEFT;
			stat_mc.label_txt.htmlText = displayName;
			stat_mc.text_txt.htmlText = value;
			stat_mc.text_txt.width = stat_mc.text_txt.width + 8;
			stat_mc.statBasePoints = Number(value);
			stat_mc.statPoints = 0;
			stat_mc.tooltip = tooltipId;
			stat_mc.statID = statID;
			stat_mc.hl_mc.width = this.statsElWidth;
			stat_mc.text_txt.mouseEnabled = false;
			stat_mc.label_txt.mouseEnabled = false;
			stat_mc.heightOverride = 26;
			stat_mc.icon_mc.gotoAndStop(statID + 1);
			stat_mc.id = this.primaryStatList.length;
			this.primaryStatList.addElement(stat_mc);
			this.mainStatsList.positionElements();
			stat_mc.MakeCustom(statID, isCustom);
			ExternalInterface.call("statAdded", stat_mc.statID, stat_mc.id, stat_mc.tooltipId);
		}
		
		public function addSecondaryStat(statID:Number, labelText:String, valueText:String, tooltipId:Number, iconFrame:Number, boostValue:Number, plusVisible:Boolean = false, minusVisible:Boolean = false, isCustom:Boolean=false) : *
		{
			var tween:larTween = null;
			var xOffset:Number = 28;
			var xOffset2:Number = this.statsElWidth;
			var stat_mc:MovieClip = null;
			if(statID == 0)
			{
				xOffset2 = this.statsElWidth;
				stat_mc = new InfoStat();
			}
			else
			{
				stat_mc = new SecStat();
				if(statID != 2)
				{
					stat_mc.heightOverride = 26;
				}
			}
			stat_mc.boostValue = boostValue;
			stat_mc.hl_mc.alpha = 0;
			stat_mc.texts_mc.label_txt.autoSize = TextFieldAutoSize.LEFT;
			stat_mc.texts_mc.label_txt.htmlText = labelText;
			stat_mc.icon_mc.visible = Boolean(iconFrame != 0);
			if(stat_mc.minus_mc != null)
			{
				stat_mc.minus_mc.visible = minusVisible;
			}
			if(stat_mc.plus_mc != null)
			{
				stat_mc.plus_mc.visible = plusVisible;
			}
			if(stat_mc.editText_txt != null)
			{
				stat_mc.editText_txt.visible = false;
			}
			stat_mc.texts_mc.text_txt.autoSize = TextFieldAutoSize.RIGHT;
			if(statID == 0)
			{
				stat_mc.icon_mc.x = 3;
				xOffset = 48;
			}
			else if(statID == 2)
			{
				stat_mc.icon_mc.x = 5;
				stat_mc.icon_mc.y = 5;
				stat_mc.icon_mc.x = -23;
				xOffset2 = xOffset2 + 28;
			}
			else if(iconFrame != 0)
			{
				stat_mc.icon_mc.x = -23;
				xOffset2 = xOffset2 + 28;
			}
			stat_mc.tooltipAlign = "right";
			stat_mc.hl_mc.width = xOffset2 + 8;
			stat_mc.widthOverride = stat_mc.hl_mc.width;
			stat_mc.texts_mc.text_txt.htmlText = valueText;
			stat_mc.texts_mc.text_txt.width = stat_mc.texts_mc.text_txt.width + 8;
			stat_mc.texts_mc.mouseEnabled = false;
			stat_mc.icon_mc.mouseEnabled = false;
			stat_mc.texts_mc.text_txt.mouseEnabled = false;
			stat_mc.texts_mc.label_txt.mouseEnabled = false;
			stat_mc.texts_mc.statBasePoints = Number(valueText);
			stat_mc.texts_mc.statPoints = 0;
			stat_mc.tooltip = tooltipId;
			stat_mc.statID = tooltipId;
			stat_mc.hl_mc.height = Math.round(stat_mc.texts_mc.height - 4);
			var widthOffsetCheck:Number = xOffset2;
			if(iconFrame != 0)
			{
				widthOffsetCheck = xOffset2 - xOffset;
			}
			if(stat_mc.texts_mc.text_txt.width > widthOffsetCheck - stat_mc.texts_mc.label_txt.width)
			{
				stat_mc.texts_mc.text_txt.scaleX = 0.82;
				stat_mc.texts_mc.text_txt.scaleY = 0.82;
				stat_mc.texts_mc.text_txt.y = stat_mc.texts_mc.text_txt.y + 2;
			}
			this.addToListWithId(statID,stat_mc);
			if(iconFrame != 0)
			{
				var targetIcon:MovieClip = stat_mc.icon_mc;
				if (iconFrame <= stat_mc.icon_mc.totalFrames)
				{
					if(stat_mc.customIcon_mc != undefined)
					{
						stat_mc.customIcon_mc.visible = false;
					}
					stat_mc.icon_mc.visible = true;
					stat_mc.icon_mc.gotoAndStop(iconFrame);
				}
				else
				{
					stat_mc.icon_mc.visible = false;
					if(stat_mc.customIcon_mc == undefined)
					{
						stat_mc.customIcon_mc = new IggyIcon();
						stat_mc.customIcon_mc.mouseEnabled = false;
						stat_mc.addChild(stat_mc.customIcon_mc);
						stat_mc.customIcon_mc.scale = 0.4375; // 28/64
						//stat_mc.customIcon_mc.width = 28;
						//stat_mc.customIcon_mc.height = 28;
					}
					targetIcon = stat_mc.customIcon_mc;
					stat_mc.customIcon_mc.x = stat_mc.icon_mc.x + customStatIconOffsetX;
					stat_mc.customIcon_mc.y = stat_mc.icon_mc.y + customStatIconOffsetY;
					stat_mc.customIcon_mc.name = "iggy_LL_characterSheetIcon_" + iconFrame;
					stat_mc.customIcon_mc.visible = true;
				}
				stat_mc.texts_mc.x = targetIcon.x + xOffset - 3;
				if((root as MovieClip).initDone)
				{
					targetIcon.alpha = 1;
				}
				else
				{
					tween = new larTween(targetIcon,"alpha",Sine.easeOut,targetIcon.alpha,1,0.1);
				}
				stat_mc.texts_mc.text_txt.x = xOffset2 - xOffset - stat_mc.texts_mc.text_txt.width;
			}
			else
			{
				stat_mc.texts_mc.text_txt.x = xOffset2 - stat_mc.texts_mc.text_txt.width;
			}
			//stat_mc.MakeCustom(statID, isCustom);
			//ExternalInterface.call("statAdded", stat_mc.statID, stat_mc.id);
		}
		
		public function addTag(labelText:String, statID:Number, tooltipText:String, descriptionText:String) : *
		{
			if(labelText.length == 0)
			{
				return;
			}
			var val5:MovieClip = this.getTag(statID);
			if(!val5)
			{
				val5 = new TagMC();
				val5.label_txt.autoSize = "left";
				val5.statID = statID;
				val5.x = 40;
				val5.id = this.tagsHolder_mc.list.length;
				this.tagsHolder_mc.list.addElement(val5,false);
			}
			val5.setTag(labelText,1,tooltipText,descriptionText);
			val5.label_txt.htmlText = labelText;
		}
		
		public function addToListWithId(id:Number, mc:MovieClip) : *
		{
			if(id == 0)
			{
				this.infoStatList.addElement(mc);
			}
			else if(id == 1)
			{
				this.secondaryStatList.addElement(mc);
			}
			else if(id == 2)
			{
				this.resistanceStatList.addElement(mc);
			}
			else if(id == 3)
			{
				this.expStatList.addElement(mc);
			}
			this.mainStatsList.positionElements();
		}
		
		public function clearSecondaryStats() : *
		{
			this.mainStatsList.clearGroup(GROUP_MAIN_STATS, false);
			this.mainStatsList.clearGroup(GROUP_MAIN_EXPERIENCE, false);
			this.mainStatsList.positionElements();
			//this.secondaryStatList.clearElements();
			//this.expStatList.clearElements();
		}
		
		public function addTitle(param1:String) : *
		{
			var val2:MovieClip = new Title();
			val2.title_txt.autoSize = "left";
			val2.title_txt.htmlText = param1;
			this.primaryStatList.addElement(val2);
			this.mainStatsList.positionElements();
		}
		
		public function clearStats() : *
		{
			//this.primaryStatList.clearElements();
			//this.secondaryStatList.clearElements();
			//this.expStatList.clearElements();
			//this.resistanceStatList.clearElements();
			this.infoStatList.clearElements();
			this.mainStatsList.clearGroupElements();
		}
		
		public function clearAbilities() : *
		{
			this.combatAbilityHolder_mc.list.clearGroupElements();
			this.civicAbilityHolder_mc.list.clearGroupElements();
		}
		
		public function addVisual(titleText:String, contentID:Number) : *
		{
			var visual_mc:MovieClip = this.getVisual(contentID);
			if(!visual_mc)
			{
				visual_mc = new Visual();
				visual_mc.title_txt.autoSize = "center";
				visual_mc.contentID = contentID;
				visual_mc.id = this.visualHolder_mc.list.length;
				this.visualHolder_mc.list.addElement(visual_mc);
				this.root_mc = root as MovieClip;
				visual_mc.onInit(this.root_mc);
			}
			visual_mc.title_txt.htmlText = titleText;
		}
		
		public function clearVisualOptions() : *
		{
			var val2:MovieClip = null;
			var val1:uint = 0;
			while(val1 < this.visualHolder_mc.list.length)
			{
				val2 = this.visualHolder_mc.list.content_array[val1];
				val2.clearOptions();
				val2.setEnabled(false);
				val1++;
			}
		}
		
		public function addVisualOption(id:Number, optionId:Number, select:Boolean) : *
		{
			var displayText:String = null;
			var visual_mc:MovieClip = this.getVisual(id);
			if(visual_mc)
			{
				displayText = visual_mc.title_txt.text + " " + optionId;
				visual_mc.addOption(optionId,displayText);
				visual_mc.setEnabled(true);
				if(select)
				{
					visual_mc.selectOption(optionId);
				}
			}
		}
		
		public function getVisual(contentID:Number) : MovieClip
		{
			return this.visualHolder_mc.list.getElementByNumber("contentID",contentID);
		}
		
		public function clearCustomStatsOptions() : *
		{
			this.customStats_mc.list.clearElements();
		}
		
		public function addCustomStat(doubleHandle:Number, labelText:String, valueText:String) : *
		{
			this.customStats_mc.addCustomStat(doubleHandle, labelText, valueText);
		}
		
		public function justEatClick(param1:MouseEvent) : *
		{
		}
		
		public function onBGOut(param1:MouseEvent) : *
		{
			var val2:MovieClip = param1.currentTarget as MovieClip;
			if(val2)
			{
				val2.removeEventListener(MouseEvent.ROLL_OUT,this.onBGOut);
			}
		}
		
		public function closeUIOnClick(param1:MouseEvent) : *
		{
			var val2:MovieClip = param1.currentTarget as MovieClip;
			if(val2)
			{
				val2.removeEventListener(MouseEvent.ROLL_OUT,this.onBGOut);
				this.closeUI();
			}
		}
		
		public function closeUI() : *
		{
			ExternalInterface.call("PlaySound","UI_Game_Inventory_Click");
			ExternalInterface.call("closeCharacterUIs");
			stage.focus = null;
		}
		
		public function addIcon(param1:MovieClip, param2:String, param3:Number) : *
		{
			var val5:Bitmap = null;
			if(param2 != param1.texture)
			{
				val5 = param1.getChildByName("img") as Bitmap;
				if(val5 != null)
				{
					param1.removeChild(val5);
				}
				if(param2 != "")
				{
					val5 = new Bitmap(new bitmapPlaceholder(1,1));
					val5.name = "img";
					param1.addChild(val5);
					IggyFunctions.setTextureForBitmap(val5,param2);
					if(val5.width > val5.height)
					{
						val5.width = param3;
						val5.scaleY = val5.scaleX;
					}
					else
					{
						val5.height = param3;
						val5.scaleX = val5.scaleY;
					}
				}
			}
			param1.texture = param2;
			param1.alpha = 0;
			param1.visible = true;
			var val4:larTween = new larTween(param1,"alpha",Sine.easeOut,param1.alpha,1,0.8);
		}
		
		public function updateAIs(param1:Array) : *
		{
			var val3:uint = 0;
			var val4:String = null;
			var val5:Object = null;
			var val6:MovieClip = null;
			this.aiSel_mc.removeAll();
			var val2:uint = 0;
			while(val2 < param1.length)
			{
				val3 = param1[val2++];
				val4 = param1[val2++];
				val5 = this.aiSel_mc.selectItemByID(val3);
				if(!val5)
				{
					val6 = new comboElement();
					val6.id = val3;
					val6.label = val4;
					this.aiSel_mc.addItem(val6);
				}
			}
		}
		
		public function updateAllignments(param1:Array) : *
		{
			var val3:uint = 0;
			var val4:String = null;
			var val5:Object = null;
			this.alignments_mc.removeAll();
			var val2:uint = 0;
			while(val2 < param1.length)
			{
				val3 = param1[val2++];
				val4 = param1[val2++];
				val5 = this.alignments_mc.selectItemByID(val3);
				if(!val5)
				{
					val5 = new comboElement();
					val5.id = val3;
					val5.label = val4;
					val5.allignID = val3;
					val5.labelStr = val5.text_txt.htmlText = val4;
					this.alignments_mc.addItem(val5);
				}
			}
		}
		
		public function recheckScrollbarVisibility() : *
		{
			var val1:uint = 0;
			while(val1 < this.panelArray.length)
			{
				if(this.panelArray[val1].list)
				{
					this.panelArray[val1].list.mouseWheelWhenOverEnabled = Boolean(val1 == this.currentOpenPanel);
					if(val1 == this.currentOpenPanel)
					{
						this.panelArray[val1].list.m_scrollbar_mc.scrollbarVisible();
					}
					else
					{
						this.panelArray[val1].list.m_scrollbar_mc.visible = false;
					}
				}
				val1++;
			}
		}

		public function setMainStatsGroupName(groupId:int, name:String) : *
		{
			var group_mc:MovieClip = this.mainStatsList.getElementByNumber("groupId", groupId);
			if(group_mc != null && group_mc.title_txt != null)
			{
				group_mc.title_txt.htmlText = name;
			}
		}
		
		public function frame1() : *
		{
			LSPanelHelpers.makeDraggable(this.dragHit_mc);
			this.myText = "";
			this.closeCenterX = 145;
			this.closeSideX = 82;
			this.buttonY = 605;
			this.base = root as MovieClip;
			this.lvlUP = false;
			this.pointsFrame_mc.mouseEnabled = false;
			this.cellSize = 64;
			this.statholderListPosY = 305;
			this.listOffsetY = 15;
			this.tabsList = new horizontalList();
			this.charList = new horizontalScrollList("empty","empty","empty","empty");
			//this.primaryStatList = new listDisplay();
			//this.secondaryStatList = new listDisplay();
			//this.expStatList = new listDisplay();
			//this.resistanceStatList = new listDisplay();
			//LeaderLib - Making the main stats scrollable
			//Moving it to the left so icons aren't cut off
			this.mainStats_mc.x = 0;//44;
			this.mainStatsList = new scrollListGrouped("down_id","up_id","handle_id","scrollBgBig_id");
			this.mainStatsList.SUBEL_SPACING = 0;
			this.mainStatsList.EL_SPACING = 2;//22;
			this.mainStatsList.SB_SPACING = -10;
			this.mainStatsList.SIDE_SPACING = 44;
			//302 - 293 = 9
			this.mainStatsList.TOP_SPACING = 9;
			//this.mainStatsList.setFrame(270,735);
			this.mainStatsList.setFrame(328,735);
			this.mainStatsList.m_scrollbar_mc.m_hideWhenDisabled = true;
			this.mainStatsList.mouseWheelWhenOverEnabled = true;
			this.mainStats_mc.addChild(this.mainStatsList);
			this.mainStatsList.setGroupMC("StatCategory");
			//this.mainStatsList.elementsSortOn("statId");
			this.mainStatsList.m_scrollbar_mc.setLength(663 + 42);
			this.mainStatsList.m_scrollbar_mc.ScaleBG = true;
			this.mainStatsList.m_scrollbar_mc.x = -1;
			this.mainStatsList.m_scrollbar_mc.y = -17;
			this.scrollbarHolder_mc.addChild(this.mainStatsList.m_scrollbar_mc);

			this.primaryStatList = this.mainStatsList.addGroup(this.GROUP_MAIN_ATTRIBUTES, "Attributes", false).list;
			this.secondaryStatList = this.mainStatsList.addGroup(this.GROUP_MAIN_STATS, "Stats", false).list;
			this.expStatList = this.mainStatsList.addGroup(this.GROUP_MAIN_EXPERIENCE, "Experience", false).list;
			this.resistanceStatList = this.mainStatsList.addGroup(this.GROUP_MAIN_RESISTANCES, "Resistances", false).list;

			this.mainStats_mc.list = mainStatsList;

			this.infoStatList = new listDisplay();
			this.charList.m_customElementWidth = 92;
			this.charList.EL_SPACING = 2;
			this.primaryStatList.EL_SPACING = 0;
			this.secELSpacing = 2;
			this.secondaryStatList.EL_SPACING = this.secELSpacing;
			this.expStatList.EL_SPACING = this.secELSpacing;
			this.infoStatList.EL_SPACING = 4;
			this.resistanceStatList.EL_SPACING = 0;
			this.charList.EL_SPACING = 0;
			this.charList.setFrame(368,124);
			this.charList.m_cyclic = true;
			this.charList.m_autoCenter = false;
			this.tabsList.EL_SPACING = 0;
			//this.expStatList.y = 240;
			
			// this.mainStats_mc.secStatHolder_mc.addChild(this.secondaryStatList);
			// this.mainStats_mc.secStatHolder_mc.addChild(this.expStatList);
			// this.mainStats_mc.statHolder_mc.addChild(this.primaryStatList);
			// this.mainStats_mc.resistancesStatHolder_mc.addChild(this.resistanceStatList);

			//this.mainStatsList.addGroupElement(0, this.primaryStatList, false);
			//this.mainStatsList.addGroupElement(1, this.secondaryStatList, false);
			//this.mainStatsList.addGroupElement(2, this.expStatList, false);
			//this.mainStatsList.addGroupElement(3, this.resistanceStatList, false);

			this.mainStatsList.positionElements();

			this.equip_mc.infoStatHolder_mc.addChild(this.infoStatList);
			this.charList_mc.addChild(this.charList);
			this.tabsHolder_mc.addChild(this.tabsList);
			this.infoStatList.m_customElementHeight = 22;
			this.resistanceStatList.m_customElementHeight = 30;
			this.selectedTabY = 23;
			this.deselectedTabY = 21;
			this.selectedTabAlpha = 1;
			this.deselectedTabAlpha = 0.8;
			this.bg_mc.mouseChildren = false;
			this.bg_mc.mouseEnabled = false;
			this.title_txt.mouseEnabled = false;
			this.equipment_txt.mouseEnabled = false;
			this.charInfo_mc.selCharInfo_txt.mouseEnabled = false;
			this.hitArea_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.justEatClick);
			this.hitArea_mc.addEventListener(MouseEvent.MOUSE_UP,this.justEatClick);

			//LeaderLib additions
			customStatsPointsWrn_mc = new mcPlus_Anim_69();
			customStatsPointsWrn_mc.name = "customStatsPointsWrn_mc";
			customStatsPointsWrn_mc.visible = false;
			customStatsPointsWrn_mc.x = 394.5;
			customStatsPointsWrn_mc.y = 215;
			customStatsPointsWrn_mc.width = 77;
			customStatsPointsWrn_mc.height = 77;
			var index:int = this.getChildIndex(this.talentPointsWrn_mc);
			this.addChildAt(customStatsPointsWrn_mc, index);
		}
	}
}
