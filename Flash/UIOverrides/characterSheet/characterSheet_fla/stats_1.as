package characterSheet_fla
{
	import LS_Classes.LSPanelHelpers;
	import LS_Classes.horizontalList;
	import LS_Classes.horizontalScrollList;
	import LS_Classes.larTween;
	import LS_Classes.listDisplay;
	import LS_Classes.textEffect;
	import LS_Classes.textHelpers;
	import LS_Classes.scrollList;
	import fl.motion.easing.Sine;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
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
		public var infoStatList:listDisplay;
		public var resistanceStatList:listDisplay;
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
		public var statScrollList:scrollList;
		
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
			this.pointsWarn = new Array(this.attrPointsWrn_mc,this.combatAbilityPointsWrn_mc,this.civilAbilityPointsWrn_mc,this.talentPointsWrn_mc);
			this.pointTexts = new Array(this.pointsFrame_mc.statPoints_txt,this.pointsFrame_mc.combatAbilPoints_txt,this.pointsFrame_mc.civilAbilPoints_txt,this.pointsFrame_mc.talentPoints_txt);
			this.bg_mc.mouseEnabled = false;
			this.bg_mc.mouseChildren = false;
			this.close_mc.onPressedFunction = this.closeUI;
			this.onePlayerOverlay_mc.visible = false;
			ExternalInterface.call("getStats");
			this.equip_mc.init();
			var val1:uint = 0;
			while(val1 < this.pointsWarn.length)
			{
				this.pointsWarn[val1].visible = false;
				this.pointsWarn[val1].stop();
				this.pointsWarn[val1].mouseEnabled = false;
				this.pointsWarn[val1].mouseChildren = false;
				this.pointsWarn[val1].avPoints = 0;
				val1++;
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
		
		public function updateInventorySlots(param1:Array) : *
		{
			var val3:uint = 0;
			var val4:Number = NaN;
			var val5:uint = 0;
			var val2:uint = 0;
			while(val2 < param1.length)
			{
				val3 = param1[val2++];
				val4 = param1[val2++];
				val5 = param1[val2++];
				this.invTabHolder_mc.inventory.addItem(val3,val4,val5);
			}
			this.invTabHolder_mc.inventory.cleanUpItems();
		}
		
		public function resetListPositions() : *
		{
		}
		
		public function buildTabs(param1:Number, param2:Boolean = false) : *
		{
			var val3:uint = 0;
			var val6:MovieClip = null;
			var val7:MovieClip = null;
			var val8:MovieClip = null;
			var val9:MovieClip = null;
			val3 = 0;
			while(val3 < this.tabsArray.length)
			{
				val6 = this.tabsArray[val3];
				if(val6 != null && val6.tw != null)
				{
					val6.tw.stop();
					val6.tw = null;
				}
				val3++;
			}
			this.tabsList.clearElements();
			this.tabsArray = new Array();
			val3 = 0;
			switch(param1)
			{
				case 0:
					val3 = 0;
					while(val3 < 5)
					{
						val7 = new StatsTabButton();
						val7.id = val3;
						this.tabsArray.push(val7);
						val3++;
					}
					this.tabsList.EL_SPACING = -10;
					break;
				case 1:
					val3 = 0;
					while(val3 < 9)
					{
						if(val3 < 4 || val3 == 8)
						{
							val8 = new StatsTabButton();
							val8.id = val3;
							this.tabsArray.push(val8);
						}
						val3++;
					}
					this.tabsList.EL_SPACING = -10;
					break;
				case 2:
					val3 = 0;
					while(val3 < 9)
					{
						if(val3 != 4)
						{
							val9 = new StatsTabButtonGM();
							val9.id = val3;
							this.tabsArray.push(val9);
						}
						val3++;
					}
					this.tabsList.EL_SPACING = -15;
			}
			var val4:* = this.currentOpenPanel;
			var val5:Boolean = false;
			val3 = 0;
			while(val3 < this.tabsArray.length)
			{
				this.tabsList.addElement(this.tabsArray[val3],false);
				if(this.currentOpenPanel == this.tabsArray[val3].id)
				{
					val5 = val5 || true;
				}
				val3++;
			}
			this.tabsList.positionElements();
			this.initTabs(!val5,param2);
			this.ClickTab(!!val5?Number(val4):Number(0));
			this.INTSetAvailablePointsVisible();
		}
		
		public function pushTabTooltip(param1:*, param2:*) : *
		{
			var val3:uint = 0;
			while(val3 < this.tabsArray.length)
			{
				if(this.tabsArray[val3].id == param1)
				{
					this.tabsArray[val3].tooltip = param2;
					return;
				}
				val3++;
			}
		}
		
		public function initTabs(param1:Boolean = false, param2:Boolean = false) : *
		{
			var val4:uint = 0;
			var val5:Number = NaN;
			if(param2)
			{
				val4 = 0;
				while(val4 < this.panelArray.length)
				{
					this.panelArray[val4].visible = false;
					if(param1 && this.panelArray[val4].init != null)
					{
						this.panelArray[val4].init();
					}
					if(this.panelArray[val4].list)
					{
						this.panelArray[val4].list.enableMouseWheelOnOver = true;
						this.panelArray[val4].list.m_scrollbar_mc.visible = false;
						this.panelArray[val4].list.m_scrollbar_mc.disabled = false;
						this.panelArray[val4].list.m_scrollbar_mc.m_hideWhenDisabled = true;
					}
					val4++;
				}
			}
			var val3:uint = 0;
			while(val3 < this.tabsArray.length)
			{
				val5 = this.tabsArray[val3].id;
				if((root as MovieClip).tabsTexts.length > val5)
				{
					this.tabsArray[val3].tooltip = (root as MovieClip).tabsTexts[val5];
				}
				this.tabsArray[val3].icon_mc.gotoAndStop(val5 + 1);
				this.tabsArray[val3].pressedFunc = this.ClickTab;
				if(val3 == this.currentOpenPanel)
				{
					this.panelArray[val3].visible = true;
					this.tabsArray[val3].icon_mc.y = this.selectedTabY;
					this.tabsArray[val3].tw = new larTween(this.tabsArray[val3].icon_mc,"alpha",Sine.easeOut,this.tabsArray[val3].icon_mc.alpha,this.selectedTabAlpha,this.tabTweenInTime);
					this.tabsArray[val3].texty = this.selectedTabY;
					this.tabsArray[val3].setActive(true);
					this.tabTitle_txt.htmlText = this.panelArray[val5].labelStr;
					textHelpers.smallCaps(this.tabTitle_txt);
				}
				else
				{
					this.panelArray[val3].visible = false;
					this.tabsArray[val3].icon_mc.y = this.deselectedTabY;
					this.tabsArray[val3].tw = new larTween(this.tabsArray[val3].icon_mc,"alpha",Sine.easeOut,this.tabsArray[val3].icon_mc.alpha,this.deselectedTabAlpha,this.tabTweenInTime);
					this.tabsArray[val3].texty = this.deselectedTabY;
					this.tabsArray[val3].setActive(false);
				}
				val3++;
			}
			this.pointsFrame_mc.setTab(this.currentOpenPanel);
		}
		
		public function selectCharacter(param1:Number) : *
		{
			var val2:MovieClip = this.charList.getElementByNumber("id",param1);
			if(val2)
			{
				this.charList.selectMC(val2,true);
				this.invTabHolder_mc.inventory.id = param1;
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
		
		public function addCharPortrait(param1:Number, param2:String, param3:uint) : *
		{
			var val4:MovieClip = this.charList.getElementByNumber("id",param1);
			if(!val4)
			{
				val4 = new charPortrait();
				val4.init();
				val4.id = param1;
				this.charList.addElement(val4,false);
				val4.frame_mc.gotoAndStop(3);
			}
			if(val4)
			{
				val4.order = param3;
				val4.hasUpdated = true;
				val4.setIcon("p" + param2);
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
		
		public function removeChildrenOf(param1:MovieClip) : void
		{
			var val2:int = 0;
			if(param1.numChildren != 0)
			{
				val2 = param1.numChildren;
				while(val2 > 0)
				{
					val2--;
					param1.removeChildAt(val2);
				}
			}
		}
		
		public function ClickTab(param1:Number) : *
		{
			var val2:MovieClip = null;
			if(this.currentOpenPanel != param1)
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
					val2 = this.getTabById(this.currentOpenPanel);
					if(val2)
					{
						val2.setActive(false);
						val2.icon_mc.y = this.deselectedTabY;
						val2.icon_mc.alpha = this.deselectedTabAlpha;
						val2.texty = this.deselectedTabY;
					}
				}
				if(param1 != -1)
				{
					if(this.panelArray[param1])
					{
						this.panelArray[param1].visible = true;
						if(this.panelArray[param1].list && this.panelArray[param1].list.m_scrollbar_mc)
						{
							this.panelArray[param1].list.m_scrollbar_mc.visible = true;
							this.panelArray[param1].list.m_scrollbar_mc.scrollbarVisible();
						}
					}
					this.selectTab(param1);
				}
				this.panelBg1_mc.visible = param1 < 5 || param1 == 6;
				this.panelBg2_mc.visible = param1 == 5;
				if(param1 == 5)
				{
					this.panelBg2_mc.gotoAndStop(2);
				}
				this.currentOpenPanel = param1;
				this.INTSetAvailablePointsVisible();
				this.pointsFrame_mc.setTab(this.currentOpenPanel);
			}
			ExternalInterface.call("selectedTab",this.currentOpenPanel);
		}
		
		public function selectTab(param1:Number) : *
		{
			var val2:MovieClip = this.getTabById(param1);
			if(val2)
			{
				val2.setActive(true);
				val2.icon_mc.y = this.selectedTabY;
				val2.icon_mc.alpha = this.selectedTabAlpha;
				val2.texty = this.selectedTabY;
				this.tabTitle_txt.htmlText = this.panelArray[param1].labelStr;
				textHelpers.smallCaps(this.tabTitle_txt);
			}
		}
		
		public function getTabById(param1:Number) : MovieClip
		{
			var val2:MovieClip = null;
			var val3:uint = 0;
			while(val3 < this.tabsArray.length)
			{
				if(this.tabsArray[val3].id == param1)
				{
					val2 = this.tabsArray[val3];
					break;
				}
				val3++;
			}
			return val2;
		}
		
		public function setPanelTitle(param1:Number, param2:String) : *
		{
			this.panelArray[param1].title_txt.htmlText = param2;
		}
		
		public function resetScrollBarsPositions() : *
		{
			this.combatAbilityHolder_mc.list.m_scrollbar_mc.resetContentPosition();
			this.civicAbilityHolder_mc.list.m_scrollbar_mc.resetContentPosition();
			this.talentHolder_mc.list.m_scrollbar_mc.resetContentPosition();
			this.tagsHolder_mc.list.m_scrollbar_mc.resetContentPosition();
		}
		
		public function INTSetWarnAndPoints(param1:Number, param2:Number) : *
		{
			var val3:MovieClip = null;
			var val4:TextField = null;
			var val5:MovieClip = null;
			if(!(root as MovieClip).isGameMasterChar)
			{
				val3 = this.pointsWarn[param1];
				val4 = this.pointTexts[param1];
				if(val3 && val4)
				{
					val4.htmlText = param2 + "";
					textHelpers.smallCaps(val4);
					val4.x = this.pointsFrame_mc.label_txt.x + this.pointsFrame_mc.label_txt.textWidth + 8;
					this.pointsFrame_mc.x = this.PointsFrameW - Math.round((val4.x + val4.textWidth) * 0.5);
					val3.visible = param2 != 0;
					val3.avPoints = param2;
					if(val3.visible)
					{
						val3.play();
					}
					else
					{
						val3.stop();
					}
					if(this.currentOpenPanel == param1)
					{
						this.INTSetAvailablePointsVisible();
					}
				}
			}
			else
			{
				val5 = this.pointsWarn[param1];
				if(val5)
				{
					val5.stop();
					val5.visible = false;
				}
			}
		}
		
		public function INTSetAvailablePointsVisible() : *
		{
			if(this.currentOpenPanel >= 0 && this.currentOpenPanel < this.pointsWarn.length)
			{
				this.pointsFrame_mc.visible = this.pointsWarn[this.currentOpenPanel].visible;
			}
			else
			{
				this.pointsFrame_mc.visible = false;
			}
			this.tabTitle_txt.visible = !this.pointsFrame_mc.visible;
		}
		
		public function setAvailableStatPoints(param1:Number) : *
		{
			this.INTSetWarnAndPoints(0,param1);
		}
		
		public function setAvailableCombatAbilityPoints(param1:Number) : *
		{
			this.INTSetWarnAndPoints(1,param1);
		}
		
		public function setAvailableCivilAbilityPoints(param1:Number) : *
		{
			this.INTSetWarnAndPoints(2,param1);
		}
		
		public function setAvailableTalentPoints(param1:Number) : *
		{
			this.INTSetWarnAndPoints(3,param1);
		}
		
		public function setVisibilityStatButtons(param1:Boolean) : *
		{
			var val3:MovieClip = null;
			var val2:uint = 0;
			while(val2 < this.primaryStatList.length)
			{
				val3 = this.primaryStatList.content_array[val2];
				if(val3)
				{
					val3.plus_mc.visible = param1;
					val3.minus_mc.visible = param1;
				}
				val2++;
			}
		}
		
		public function setStatPlusVisible(param1:Number, param2:Boolean) : *
		{
			var val3:MovieClip = this.getStat(param1);
			if(val3)
			{
				val3.plus_mc.visible = param2;
			}
		}
		
		public function setStatMinusVisible(param1:Number, param2:Boolean) : *
		{
			var val3:MovieClip = this.getStat(param1);
			if(val3)
			{
				val3.minus_mc.visible = param2;
			}
		}
		
		public function setupSecondaryStatsButtons(param1:int, param2:Boolean, param3:Boolean, param4:Boolean, param5:Number = 5) : void
		{
			var val6:MovieClip = this.getSecStat(param1);
			if(val6.setupButtons != null)
			{
				val6.setupButtons(param2,param3,param4,param5);
			}
			else
			{
				val6.minus_mc.visible = param3;
				val6.plus_mc.visible = param4;
			}
		}
		
		public function getStat(param1:Number) : MovieClip
		{
			return this.primaryStatList.getElementByNumber("statId",param1);
		}
		
		public function getSecStat(param1:Number) : MovieClip
		{
			var val2:MovieClip = this.resistanceStatList.getElementByNumber("statId",param1);
			if(val2 == null)
			{
				val2 = this.secondaryStatList.getElementByNumber("statId",param1);
			}
			if(val2 == null)
			{
				val2 = this.infoStatList.getElementByNumber("statId",param1);
			}
			if(val2 == null)
			{
				val2 = this.expStatList.getElementByNumber("statId",param1);
			}
			return val2;
		}
		
		public function getAbility(param1:Boolean, param2:Number, param3:Number) : MovieClip
		{
			var val4:MovieClip = this.combatAbilityHolder_mc;
			if(param1)
			{
				val4 = this.civicAbilityHolder_mc;
			}
			var val5:MovieClip = val4.list.getElementByNumber("groupId",param2);
			if(val5)
			{
				return val5.list.getElementByNumber("statId",param3);
			}
			return null;
		}
		
		public function getTalent(param1:Number) : MovieClip
		{
			return this.talentHolder_mc.list.getElementByNumber("statId",param1);
		}
		
		public function getTag(param1:Number) : MovieClip
		{
			return this.tagsHolder_mc.list.getElementByNumber("statId",param1);
		}
		
		public function setVisibilityAbilityButtons(param1:Boolean, param2:Boolean) : *
		{
			var val4:uint = 0;
			var val5:MovieClip = null;
			var val6:uint = 0;
			var val7:MovieClip = null;
			var val3:MovieClip = this.combatAbilityHolder_mc;
			if(param1)
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
							val7.texts_mc.plus_mc.visible = param2;
							val7.texts_mc.minus_mc.visible = param2;
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
		
		public function setVisibilityTalentButtons(param1:Boolean) : *
		{
			var val2:uint = 0;
			while(val2 < this.talentHolder_mc.list.length)
			{
				if(this.talentHolder_mc.list.content_array[val2])
				{
					this.talentHolder_mc.list.content_array[val2].plus_mc.visible = param1;
					this.talentHolder_mc.list.content_array[val2].minus_mc.visible = param1;
				}
				val2++;
			}
		}
		
		public function setTalentPlusVisible(param1:Number, param2:Boolean) : *
		{
			var val3:MovieClip = this.getTalent(param1);
			if(val3)
			{
				val3.plus_mc.visible = param2;
			}
		}
		
		public function setTalentMinusVisible(param1:Number, param2:Boolean) : *
		{
			var val3:MovieClip = this.getTalent(param1);
			if(val3)
			{
				val3.minus_mc.visible = param2;
			}
		}
		
		public function addText(param1:String, param2:String, param3:Boolean) : *
		{
			var val4:MovieClip = new Text();
			val4.label_txt.autoSize = "left";
			val4.label_txt.htmlText = param1;
			val4.tooltip = param2;
			if(param3)
			{
				this.secondaryStatList.addElement(val4);
				this.secondaryStatList.height = this.secondaryStatList.getContentHeight();
			}
			else
			{
				this.primaryStatList.addElement(val4);
				this.primaryStatList.height = this.primaryStatList.getContentHeight();
			}
			this.statScrollList.positionElements();
		}
		
		public function addSpacing(param1:Number, param2:Number) : *
		{
			var val3:MovieClip = new Spacing();
			val3.height = param2;
			val3.heightOverride = param2;
			this.addToListWithId(param1,val3);
		}
		
		public function addAbilityGroup(param1:Boolean, param2:Number, param3:String) : *
		{
			var val4:MovieClip = this.combatAbilityHolder_mc;
			if(param1)
			{
				val4 = this.civicAbilityHolder_mc;
			}
			val4.list.addGroup(param2,param3);
		}
		
		public function addAbility(param1:Boolean, param2:Number, param3:Number, param4:String, param5:String, param6:String, param7:String) : *
		{
			var val9:MovieClip = null;
			var val8:MovieClip = this.getAbility(param1,param2,param3);
			if(!val8)
			{
				val9 = this.combatAbilityHolder_mc;
				if(param1)
				{
					val9 = this.civicAbilityHolder_mc;
				}
				val8 = new AbilityEl();
				val8.isCivil = param1;
				val9.list.addGroupElement(param2,val8,false);
				val8.texts_mc.plus_mc.visible = false;
				val8.texts_mc.minus_mc.visible = false;
				val8.texts_mc.statId = param3;
				val8.statId = param3;
				val8.tooltip = param3;
				val8.texts_mc.id = val9.list.length;
				val8.texts_mc.plus_mc.currentTooltip = "";
				val8.texts_mc.minus_mc.currentTooltip = "";
				val8.texts_mc.label_txt.autoSize = TextFieldAutoSize.LEFT;
			}
			val8.texts_mc.plus_mc.tooltip = param6;
			val8.texts_mc.minus_mc.tooltip = param7;
			if(val8.texts_mc.plus_mc.currentTooltip != "" && val8.texts_mc.plus_mc.currentTooltip != param6)
			{
				ExternalInterface.call("showTooltip",param6);
				val8.texts_mc.plus_mc.currentTooltip = param6;
			}
			if(val8.texts_mc.minus_mc.currentTooltip != "" && val8.texts_mc.minus_mc.currentTooltip != param7)
			{
				ExternalInterface.call("showTooltip",param7);
				val8.texts_mc.plus_mc.currentTooltip = param7;
			}
			val8.texts_mc.label_txt.htmlText = param4;
			val8.texts_mc.text_txt.htmlText = param5;
			val8.textStr = val8.texts_mc.label_txt.text;
			val8.am = Number(val8.texts_mc.text_txt.text);
			val8.texts_mc.statBasePoints = Number(param5);
			val8.texts_mc.statPoints = 0;
			val8.hl_mc.height = val8.abilTooltip_mc.height = val8.texts_mc.label_txt.y + val8.texts_mc.label_txt.textHeight - val8.hl_mc.y;
			val8.texts_mc.text_txt.y = Math.round((val8.hl_mc.height - val8.texts_mc.text_txt.textHeight) * 0.5);
		}
		
		public function recountAbilityPoints(param1:Boolean) : *
		{
			var val3:uint = 0;
			var val4:MovieClip = null;
			var val5:listDisplay = null;
			var val6:Number = NaN;
			var val7:uint = 0;
			var val2:MovieClip = this.combatAbilityHolder_mc;
			if(param1)
			{
				val2 = this.civicAbilityHolder_mc;
			}
			if(val2.list.length > 0)
			{
				val3 = 0;
				while(val3 < val2.list.length)
				{
					val4 = val2.list.content_array[val3];
					if(val4 && val4.list)
					{
						val5 = val4.list;
						val6 = 0;
						val7 = 0;
						while(val7 < val5.length)
						{
							val6 = val6 + val5.content_array[val7].am;
							val7++;
						}
					}
					val4.amount_txt.htmlText = val6;
					val3++;
				}
			}
		}
		
		public function addTalent(param1:String, param2:Number, param3:Number) : *
		{
			var val4:MovieClip = this.getTalent(param2);
			if(!val4)
			{
				val4 = new Talent();
				val4.label_txt.autoSize = "left";
				val4.tooltip = param2;
				val4.statId = param2;
				val4.minus_mc.x = 260;
				val4.plus_mc.x = val4.minus_mc.x + val4.minus_mc.width;
				val4.plus_mc.visible = val4.minus_mc.visible = false;
				val4.id = this.talentHolder_mc.list.length;
				this.talentHolder_mc.list.addElement(val4,false);
			}
			val4.label_txt.htmlText = param1;
			val4.hl_mc.width = this.statsElWidth;
			val4.hl_mc.height = val4.label_txt.textHeight + val4.label_txt.y;
			val4.plus_mc.y = val4.minus_mc.y = val4.hl_mc.y + Math.ceil((val4.hl_mc.height - val4.minus_mc.height) * 0.5) - 3;
			val4.label = val4.label_txt.text;
			val4.talentState = param3;
			val4.bullet_mc.gotoAndStop(this.getTalentStateFrame(param3));
		}
		
		public function getTalentStateFrame(param1:Number) : Number
		{
			switch(param1)
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
		
		public function addPrimaryStat(param1:Number, param2:String, param3:String, param4:Number) : *
		{
			var val5:MovieClip = new Stat();
			val5.tooltipAlign = "right";
			val5.hl_mc.alpha = 0;
			val5.plus_mc.visible = false;
			val5.minus_mc.visible = false;
			val5.label_txt.autoSize = TextFieldAutoSize.LEFT;
			val5.label_txt.htmlText = param2;
			val5.text_txt.htmlText = param3;
			val5.text_txt.width = val5.text_txt.width + 8;
			val5.statBasePoints = Number(param3);
			val5.statPoints = 0;
			val5.tooltip = param4;
			val5.statId = param1;
			val5.hl_mc.width = this.statsElWidth;
			val5.text_txt.mouseEnabled = false;
			val5.label_txt.mouseEnabled = false;
			val5.heightOverride = 26;
			val5.icon_mc.gotoAndStop(param1 + 1);
			val5.id = this.primaryStatList.length;
			this.primaryStatList.addElement(val5);
			this.primaryStatList.height = this.primaryStatList.getContentHeight();
			this.statScrollList.positionElements();
			trace("statScrollList.getContentHeight", this.statScrollList.getContentHeight());
			trace("primaryStatList.getContentHeight", this.primaryStatList.getContentHeight());
			trace("primaryStatList.height", this.primaryStatList.height);
			this.statScrollList.m_scrollbar_mc.scrollbarVisible();
			this.statScrollList.m_scrollbar_mc.visible = true;
			this.statScrollList.m_scrollbar_mc.disabled = false;
		}
		
		public function addSecondaryStat(param1:Number, param2:String, param3:String, param4:Number, param5:Number, param6:Number) : *
		{
			var val11:larTween = null;
			var val7:Number = 28;
			var val8:Number = this.statsElWidth;
			var val9:MovieClip = null;
			if(param1 == 0)
			{
				val8 = this.statsElWidth;
				val9 = new InfoStat();
			}
			else
			{
				val9 = new SecStat();
				if(param1 != 2)
				{
					val9.heightOverride = 26;
				}
			}
			val9.boostValue = param6;
			val9.hl_mc.alpha = 0;
			val9.texts_mc.label_txt.autoSize = TextFieldAutoSize.LEFT;
			val9.texts_mc.label_txt.htmlText = param2;
			val9.icon_mc.visible = Boolean(param5 != 0);
			if(val9.minus_mc != null)
			{
				val9.minus_mc.visible = false;
			}
			if(val9.plus_mc != null)
			{
				val9.plus_mc.visible = false;
			}
			if(val9.editText_txt != null)
			{
				val9.editText_txt.visible = false;
			}
			val9.texts_mc.text_txt.autoSize = TextFieldAutoSize.RIGHT;
			if(param1 == 0)
			{
				val9.icon_mc.x = 3;
				val7 = 48;
			}
			else if(param1 == 2)
			{
				val9.icon_mc.x = 5;
				val9.icon_mc.y = 5;
				val9.icon_mc.x = -23;
				val8 = val8 + 28;
			}
			else if(param5 != 0)
			{
				val9.icon_mc.x = -23;
				val8 = val8 + 28;
			}
			val9.tooltipAlign = "right";
			val9.hl_mc.width = val8 + 8;
			val9.widthOverride = val9.hl_mc.width;
			val9.texts_mc.text_txt.htmlText = param3;
			val9.texts_mc.text_txt.width = val9.texts_mc.text_txt.width + 8;
			val9.texts_mc.mouseEnabled = false;
			val9.icon_mc.mouseEnabled = false;
			val9.texts_mc.text_txt.mouseEnabled = false;
			val9.texts_mc.label_txt.mouseEnabled = false;
			val9.texts_mc.statBasePoints = Number(param3);
			val9.texts_mc.statPoints = 0;
			val9.tooltip = param4;
			val9.statId = param4;
			val9.hl_mc.height = Math.round(val9.texts_mc.height - 4);
			var val10:Number = val8;
			if(param5 != 0)
			{
				val10 = val8 - val7;
			}
			if(val9.texts_mc.text_txt.width > val10 - val9.texts_mc.label_txt.width)
			{
				val9.texts_mc.text_txt.scaleX = 0.82;
				val9.texts_mc.text_txt.scaleY = 0.82;
				val9.texts_mc.text_txt.y = val9.texts_mc.text_txt.y + 2;
			}
			this.addToListWithId(param1,val9);
			if(param5 != 0)
			{
				val9.icon_mc.gotoAndStop(param5);
				val9.texts_mc.x = val9.icon_mc.x + val7 - 3;
				if((root as MovieClip).initDone)
				{
					val9.icon_mc.alpha = 1;
				}
				else
				{
					val11 = new larTween(val9.icon_mc,"alpha",Sine.easeOut,val9.icon_mc.alpha,1,0.1);
				}
				val9.texts_mc.text_txt.x = val8 - val7 - val9.texts_mc.text_txt.width;
			}
			else
			{
				val9.texts_mc.text_txt.x = val8 - val9.texts_mc.text_txt.width;
			}
		}
		
		public function addTag(param1:String, param2:Number, param3:String, param4:String) : *
		{
			if(param1.length == 0)
			{
				return;
			}
			var val5:MovieClip = this.getTag(param2);
			if(!val5)
			{
				val5 = new TagMC();
				val5.label_txt.autoSize = "left";
				val5.statId = param2;
				val5.x = 40;
				val5.id = this.tagsHolder_mc.list.length;
				this.tagsHolder_mc.list.addElement(val5,false);
			}
			val5.setTag(param1,1,param3,param4);
			val5.label_txt.htmlText = param1;
		}
		
		public function addToListWithId(param1:Number, param2:MovieClip) : *
		{
			if(param1 == 0)
			{
				this.infoStatList.addElement(param2);
				this.infoStatList.height = this.infoStatList.getContentHeight();
			}
			else if(param1 == 1)
			{
				this.secondaryStatList.addElement(param2);
				this.secondaryStatList.height = this.secondaryStatList.getContentHeight();
			}
			else if(param1 == 2)
			{
				this.resistanceStatList.addElement(param2);
				this.resistanceStatList.height = this.resistanceStatList.getContentHeight();
			}
			else if(param1 == 3)
			{
				this.expStatList.addElement(param2);
				this.expStatList.height = this.expStatList.getContentHeight();
			}
			this.statScrollList.positionElements();
		}
		
		public function clearSecondaryStats() : *
		{
			this.secondaryStatList.clearElements();
			this.secondaryStatList.height = this.secondaryStatList.getContentHeight();
			this.expStatList.clearElements();
			this.expStatList.height = this.expStatList.getContentHeight();
			this.statScrollList.positionElements();
		}
		
		public function addTitle(param1:String) : *
		{
			var val2:MovieClip = new Title();
			val2.title_txt.autoSize = "left";
			val2.title_txt.htmlText = param1;
			this.primaryStatList.addElement(val2);
			this.primaryStatList.height = this.primaryStatList.getContentHeight();
			this.statScrollList.positionElements();
		}
		
		public function clearStats() : *
		{
			this.primaryStatList.clearElements();
			this.secondaryStatList.clearElements();
			this.expStatList.clearElements();
			this.infoStatList.clearElements();
			this.resistanceStatList.clearElements();

			this.primaryStatList.height = this.primaryStatList.getContentHeight();
			this.secondaryStatList.height = this.secondaryStatList.getContentHeight();
			this.expStatList.height = this.expStatList.getContentHeight();
			this.infoStatList.height = this.infoStatList.getContentHeight();
			this.resistanceStatList.height = this.resistanceStatList.getContentHeight();

			this.statScrollList.positionElements();
		}
		
		public function clearAbilities() : *
		{
			this.combatAbilityHolder_mc.list.clearGroupElements();
			this.civicAbilityHolder_mc.list.clearGroupElements();
		}
		
		public function addVisual(param1:String, param2:Number) : *
		{
			var val3:MovieClip = this.getVisual(param2);
			if(!val3)
			{
				val3 = new Visual();
				val3.title_txt.autoSize = "center";
				val3.contentID = param2;
				val3.id = this.visualHolder_mc.list.length;
				this.visualHolder_mc.list.addElement(val3);
				this.root_mc = root as MovieClip;
				val3.onInit(this.root_mc);
			}
			val3.title_txt.htmlText = param1;
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
		
		public function addVisualOption(param1:Number, param2:Number, param3:Boolean) : *
		{
			var val5:String = null;
			var val4:MovieClip = this.getVisual(param1);
			if(val4)
			{
				val5 = val4.title_txt.text + " " + param2;
				val4.addOption(param2,val5);
				val4.setEnabled(true);
				if(param3)
				{
					val4.selectOption(param2);
				}
			}
		}
		
		public function getVisual(param1:Number) : MovieClip
		{
			return this.visualHolder_mc.list.getElementByNumber("contentID",param1);
		}
		
		public function clearCustomStatsOptions() : *
		{
			this.customStats_mc.list.clearElements();
		}
		
		public function addCustomStat(param1:Number, param2:String, param3:String) : *
		{
			var val4:MovieClip = new CustomStat();
			val4.hl_mc.alpha = 0;
			var val5:Boolean = (root as MovieClip).isGameMasterChar;
			val4.plus_mc.visible = val5;
			val4.minus_mc.visible = val5;
			val4.edit_mc.visible = val5;
			val4.delete_mc.visible = val5;
			val4.label_txt.autoSize = TextFieldAutoSize.NONE;
			val4.label_txt.htmlText = param2;
			val4.text_txt.htmlText = param3;
			val4.text_txt.width = val4.text_txt.width + 8;
			val4.tooltipAlign = "right";
			val4.statId = param1;
			val4.hl_mc.width = this.statsElWidth;
			val4.text_txt.mouseEnabled = false;
			val4.label_txt.mouseEnabled = false;
			val4.heightOverride = 26;
			val4.id = this.customStats_mc.list.length;
			val4.init();
			this.customStats_mc.list.addElement(val4);
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

		public function initScrollList() : *
		{
			this.statScrollList = new scrollList("down_id","up_id","handle_id","scrollBgBig_id");
			this.statScrollList.x = this.mainStats_mc.statHolder_mc.x;
			this.statScrollList.y = this.mainStats_mc.statHolder_mc.y;
			this.statScrollList.EL_SPACING = 0;
			this.statScrollList.setFrame(328,735);
			this.mainStats_mc.addChild(this.statScrollList);
			this.statScrollList.TOP_SPACING = 40;
			this.statScrollList.m_scrollbar_mc.m_hideWhenDisabled = false;
			this.statScrollList.m_scrollbar_mc.setLength(667);
			this.statScrollList.m_scrollbar_mc.x = -1;
			this.statScrollList.m_scrollbar_mc.y = -17;
			this.scrollbarHolder_mc.addChild(this.statScrollList.m_scrollbar_mc);
			this.statScrollList.addElement(this.primaryStatList);
			this.statScrollList.addElement(this.secondaryStatList);
			this.statScrollList.addElement(this.infoStatList);
			this.statScrollList.addElement(this.resistanceStatList);
			this.statScrollList.addElement(this.expStatList);
			this.statScrollList.positionElements();
			this.mainStats_mc.list = this.statScrollList;
			this.mainStats_mc.init = initScrollList;
		}
		
		function frame1() : *
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
			this.primaryStatList = new listDisplay();
			this.secondaryStatList = new listDisplay();
			this.expStatList = new listDisplay();
			this.infoStatList = new listDisplay();
			this.resistanceStatList = new listDisplay();
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
			this.expStatList.y = 240;
			//this.mainStats_mc.secStatHolder_mc.addChild(this.secondaryStatList);
			//this.mainStats_mc.secStatHolder_mc.addChild(this.expStatList);
			//this.mainStats_mc.statHolder_mc.addChild(this.primaryStatList);
			//this.equip_mc.infoStatHolder_mc.addChild(this.infoStatList);
			//this.mainStats_mc.resistancesStatHolder_mc.addChild(this.resistanceStatList);
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

			this.initScrollList();
		}
	}
}