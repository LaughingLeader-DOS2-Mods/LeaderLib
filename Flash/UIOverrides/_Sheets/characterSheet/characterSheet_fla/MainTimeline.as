package characterSheet_fla
{
	import LS_Classes.textHelpers;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	public dynamic class MainTimeline extends MovieClip
	{
		public var stats_mc:MovieClip;
		public var initDone:Boolean;
		public var events:Array;
		public var layout:String;
		public var alignment:String;
		public var curTooltip:int;
		public var hasTooltip:Boolean;
		public var availableStr:String;
		public var keepCustomInScreen;
		public var uiLeft:uint;
		public var uiRight:uint;
		public var uiTop:uint;
		public var uiMinHeight:uint;
		public var uiMinWidth:uint;
		public var charList_array:Array;
		public const charListPartyPosX:int = 156;
		public const charListOnePlayerPosX:int = 292;
		public const playerIconW:int = 80;
		public const playerIconH:int = 100;
		public var invRows:uint;
		public var invCols:uint;
		public var invCellSize:uint;
		public var invCellSpacing:uint;
		public var skillList:Array;
		public const skillIconSize:uint = 50;
		public const skillCols:uint = 3;
		public const spacingV:int = 15;
		public const spacingH:int = 15;
		public const listSpacing:int = 40;
		public const sysPanelX:int = 2;
		public const sysPanelY:int = 40;
		public const sysPanelW:int = 675;
		public const sysPanelH:int = 1020;
		public const leftPanelW:uint = 330;
		public var tabsTexts:Array;
		public var primStat_array:Array;
		public var secStat_array:Array;
		public var ability_array:Array;
		public var tags_array:Array;
		public var talent_array:Array;
		public var visual_array:Array;
		public var visualValues_array:Array;
		public var customStats_array:Array;
		public var lvlBtnAbility_array:Array;
		public var lvlBtnStat_array:Array;
		public var lvlBtnSecStat_array:Array;
		public var lvlBtnTalent_array:Array;
		public var allignmentArray:Array;
		public var aiArray:Array;
		public var inventoryUpdateList:Array;
		public var isGameMasterChar:Boolean;
		public var EQContainer:MovieClip;
		public var slotAmount:Number;
		public var cellSize:Number;
		public var slot_array:Array;
		public var itemsUpdateList:Array;
		public var renameBtnTooltip:String;
		public var alignmentTooltip:String;
		public var aiTooltip:String;
		public var createNewStatBtnLabel:String;
		public var isDragging:Boolean;
		public var draggingSkill:Boolean;
		public var tabState:Number;
		public var screenWidth:Number;
		public var screenHeight:Number;
		public var text_array:Array;
		public const maxIndexInView:uint = 3;
		public const strUndefined:String = "[UNDEFINED]";
		public var strSelectTreasure:String;
		public var strGenerate:String;
		public var strClear:String;
		public var strLevel:String;
		public var listRarity:Array;
		public var listTreasures:Array;
		public var generateTreasureRarityId:int;
		public var generateTreasureId:int;
		public var generateTreasureLevel:int;

		//LeaderLib
		public var characterHandle:Number;
		//In case mods are still using this.
		public var charHandle:Number;
		public var isExtended:Boolean = true;
		public var justUpdated:Boolean = false;
		
		public function MainTimeline()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onWheel() : *
		{
		}
		
		public function onEventResize() : *
		{
		}
		
		public function updateVisuals() : *
		{
			var i:Number = 0;
			while(i < this.visual_array.length)
			{
				this.addVisual(this.visual_array[i++],this.visual_array[i++]);
			}
			this.visual_array = new Array();
		}
		
		public function updateSkills() : *
		{
			this.stats_mc.skillTabHolder_mc.updateSkillList(this.skillList);
			this.skillList = new Array();
		}
		
		public function GMShowTargetSkills() : *
		{
			this.stats_mc.ClickTab(6);
		}
		
		public function resetSkillDragging() : *
		{
			this.draggingSkill = false;
		}
		
		public function updateInventory() : *
		{
			this.stats_mc.updateInventorySlots(this.inventoryUpdateList);
			this.inventoryUpdateList = new Array();
		}
		
		public function updateAllignmentList() : *
		{
			if(this.allignmentArray.length > 0)
			{
				this.stats_mc.upDateAllignments(this.allignmentArray);
			}
			this.allignmentArray = new Array();
		}
		
		public function selectAllignment(id:uint) : *
		{
			this.stats_mc.alignments_mc.selectItemByID(id);
		}
		
		public function updateAIList() : *
		{
			if(this.aiArray.length > 0)
			{
				this.stats_mc.updateAIs(this.aiArray);
			}
			this.aiArray = new Array();
		}
		
		public function selectAI(id:uint) : *
		{
			this.stats_mc.aiSel_mc.selectItemByID(id);
		}
		
		public function setGameMasterMode(isGameMasterMode:Boolean, isGameMasterChar:Boolean, isPossessed:Boolean) : *
		{
			this.isGameMasterChar = isGameMasterChar;
			var nextTabState:Number = !!isGameMasterChar?Number(2):!!isGameMasterMode?Number(1):Number(0);
			if(this.tabState != nextTabState)
			{
				this.stats_mc.buildTabs(nextTabState);
				this.tabState = nextTabState;
			}
			var tabsCount:uint = this.stats_mc.tabsArray.length;
			var spaceReduction:uint = 4;
			var unusedWidth:uint = this.leftPanelW / tabsCount - spaceReduction;
			this.stats_mc.charInfo_mc.min_mc.visible = isGameMasterChar;
			this.stats_mc.charInfo_mc.plus_mc.visible = isGameMasterChar;
			this.stats_mc.charInfo_mc.renameBtn_mc.visible = isGameMasterChar && !isPossessed;
			this.stats_mc.charInfo_mc.hit_mc.visible = isGameMasterChar && !isPossessed;
			this.stats_mc.alignments_mc.visible = isGameMasterChar && !isPossessed;
			this.stats_mc.aiSel_mc.visible = isGameMasterChar && !isPossessed;
			this.stats_mc.customStats_mc.setGameMasterMode(isGameMasterChar);
		}
		
		public function onEventUp(index:Number) : *
		{
			var isHandled:Boolean = false;
			switch(this.events[index])
			{
				case "IE ContextMenu":
					isHandled = this.stats_mc.equip_mc.onContainerContextEvent();
					if(!isHandled)
					{
						isHandled = this.stats_mc.invTabHolder_mc.onContextMenuInputUp(this.charHandle);
					}
					break;
				case "IE UIAccept":
					stage.focus = null;
					break;
				case "IE ToggleInGameMenu":
					ExternalInterface.call("PlaySound","UI_Game_Inventory_Close");
					ExternalInterface.call("hideUI");
					isHandled = true;
			}
			return isHandled;
		}
		
		public function onEventDown(index:Number) : *
		{
			var isHandled:Boolean = false;
			switch(this.events[index])
			{
				case "IE ContextMenu":
					isHandled = true;
					break;
				case "IE ToggleInGameMenu":
					isHandled = true;
			}
			return isHandled;
		}
		
		public function onEventResolution(width:Number, height:Number) : *
		{
			if(this.screenWidth != width || this.screenHeight != height)
			{
				ExternalInterface.call("setPosition","topleft","screen","topleft");
				this.screenWidth = width;
				this.screenHeight = height;
			}
		}
		
		public function onEventInit() : *
		{
			this.availableStr = "";
			this.stats_mc.init();
			this.setGameMasterMode(false,false,true);
			ExternalInterface.call("setPosition","topleft","screen","topleft");
		}
		
		public function setPossessedState(param1:Boolean) : *
		{
		}
		
		public function getGlobalPositionOfMC(mc:MovieClip) : Point
		{
			var pos:Point = new Point(mc.x - root.x,mc.y - root.y);
			var parentObj:DisplayObject = mc.parent;
			while(parentObj && (parentObj != root || parentObj != stage))
			{
				pos.x = pos.x + parentObj.x;
				pos.y = pos.y + parentObj.y;
				parentObj = parentObj.parent;
			}
			return pos;
		}
		
		public function showTooltipForMC(mc:MovieClip, externalCall:String) : *
		{
			var tWidth:Number = NaN;
			var globalPos:Point = this.getGlobalPositionOfMC(mc);
			this.hasTooltip = true;
			var offsetY:Number = 0;
			var offsetX:Number = 0;
			if(mc)
			{
				tWidth = mc.width;
				if(mc.widthOverride)
				{
					tWidth = mc.widthOverride;
				}
				if(mc.mOffsetY)
				{
					offsetY = mc.mOffsetY;
				}
				if(mc.mOffsetX)
				{
					offsetX = mc.mOffsetX;
				}
				ExternalInterface.call(externalCall,mc.tooltip,globalPos.x + offsetX,globalPos.y + offsetY,tWidth,mc.height,mc.tooltipAlign);
			}
		}

		//Just a tweak so we can pass the id parameter to use.
		public function showCustomTooltipForMC(mc:MovieClip, externalCall:String, statID:Number) : *
		{
			var tWidth:Number = NaN;
			var globalPos:Point = this.getGlobalPositionOfMC(mc);
			this.hasTooltip = true;
			var offsetY:Number = 0;
			var offsetX:Number = 0;
			if(mc)
			{
				tWidth = mc.width;
				if(mc.widthOverride)
				{
					tWidth = mc.widthOverride;
				}
				if(mc.mOffsetY)
				{
					offsetY = mc.mOffsetY;
				}
				if(mc.mOffsetX)
				{
					offsetX = mc.mOffsetX;
				}
				if(!mc.IsCustom)
				{
					ExternalInterface.call(externalCall, statID, globalPos.x + offsetX,globalPos.y + offsetY,tWidth,mc.height,mc.tooltipAlign);
				}
				else
				{
					ExternalInterface.call(externalCall, this.characterHandle, statID, globalPos.x + offsetX,globalPos.y + offsetY,tWidth,mc.height,mc.tooltipAlign);
				}
			}
		}
		
		public function setActionsDisabled(disabled:Boolean) : *
		{
			this.stats_mc.equip_mc.disableActions = disabled;
			this.stats_mc.equip_mc.iggy_Icons.alpha = !!disabled?0.6:1;
		}
		
		public function updateItems() : *
		{
			this.stats_mc.equip_mc.updateItems();
		}
		
		public function setHelmetOptionState(state:Number) : *
		{
			this.stats_mc.equip_mc.helmet_mc.setState(state);
		}
		
		public function setHelmetOptionTooltip(text:String) : *
		{
			this.stats_mc.equip_mc.helmet_mc.setTooltip(text);
		}
		
		public function setPlayerInfo(text:String) : *
		{
			var val2:uint = 10;
			this.stats_mc.charInfo_mc.selCharInfo_txt.htmlText = text.toUpperCase();
			this.stats_mc.charInfo_mc.min_mc.x = this.stats_mc.charInfo_mc.selCharInfo_txt.x + this.stats_mc.charInfo_mc.selCharInfo_txt.width / 2 + this.stats_mc.charInfo_mc.selCharInfo_txt.textWidth / 2 + val2;
			this.stats_mc.charInfo_mc.plus_mc.x = this.stats_mc.charInfo_mc.min_mc.x + this.stats_mc.charInfo_mc.min_mc.width;
			this.stats_mc.charInfo_mc.renameBtn_mc.x = this.stats_mc.charInfo_mc.selCharInfo_txt.x + (this.stats_mc.charInfo_mc.selCharInfo_txt.width / 2 - this.stats_mc.charInfo_mc.selCharInfo_txt.textWidth / 2 - this.stats_mc.charInfo_mc.renameBtn_mc.width - val2);
			this.stats_mc.charInfo_mc.hit_mc.width = this.stats_mc.charInfo_mc.selCharInfo_txt.textWidth;
			this.stats_mc.charInfo_mc.hit_mc.height = this.stats_mc.charInfo_mc.selCharInfo_txt.height;
			this.stats_mc.charInfo_mc.hit_mc.x = -(this.stats_mc.charInfo_mc.hit_mc.width / 2);
		}
		
		public function setAvailableLabels(text:String) : *
		{
			this.availableStr = text;
			this.stats_mc.pointsFrame_mc.label_txt.htmlText = this.availableStr;
			this.setAvailableStatPoints(0);
			this.setAvailableCombatAbilityPoints(0);
			this.setAvailableCivilAbilityPoints(0);
			this.setAvailableTalentPoints(0);
			this.setAvailableCustomStatPoints(0);
			this.pointsTextfieldChanged(this.stats_mc.pointsFrame_mc.label_txt);
		}
		
		public function pointsTextfieldChanged(tf:TextField) : *
		{
			textHelpers.smallCaps(tf);
		}
		
		public function selectCharacter(id:Number) : *
		{
			this.stats_mc.selectCharacter(id);
		}
		
		public function setText(tabId:Number, text:String) : *
		{
			switch(tabId)
			{
				case 0:
				case 1:
				case 2:
				case 3:
				case 4:
				case 5:
				case 6:
				case 7:
				case 8:
					this.stats_mc.panelArray[tabId].labelStr = text;
					if(this.stats_mc.currentOpenPanel == tabId)
					{
						this.stats_mc.tabTitle_txt.htmlText = text;
						textHelpers.smallCaps(this.stats_mc.tabTitle_txt);
					}
					this.tabsTexts[tabId] = text;
					this.stats_mc.pushTabTooltip(tabId,text);
					break;
				case 9:
					this.stats_mc.equipment_txt.htmlText = text;
					textHelpers.smallCaps(this.stats_mc.equipment_txt,7,true);
			}
		}
		
		public function setTitle(text:String) : *
		{
			this.stats_mc.title_txt.htmlText = text.toUpperCase();
		}
		
		public function addText(labelText:String, tooltipText:String, isSecondary:Boolean = false) : *
		{
			this.stats_mc.addText(labelText,tooltipText,isSecondary);
		}
		
		public function addPrimaryStat(statID:Number, labelText:String, valueText:String, tooltipType:Number) : *
		{
			this.stats_mc.addPrimaryStat(statID,labelText,valueText,tooltipType);
		}
		
		//statType:Number, labelText:String, valueText:String, statID:Number, iconFrame:Number, boostValue:Number, plusVisible:Boolean = false, minusVisible:Boolean = false
		public function addSecondaryStat(statType:Number, labelText:String, valueText:String, statID:Number, iconFrame:Number, boostValue:Number) : *
		{
			this.stats_mc.addSecondaryStat(statType,labelText,valueText,statID,iconFrame,boostValue);
		}
		
		public function clearSecondaryStats() : *
		{
			this.stats_mc.clearSecondaryStats();
		}
		
		public function addAbilityGroup(isCivil:Boolean, groupId:Number, labelText:String) : *
		{
			this.stats_mc.addAbilityGroup(isCivil,groupId,labelText);
		}
		
		public function addAbility(isCivil:Boolean, groupId:Number, statID:Number, labelText:String, valueText:String, plusTooltip:String = "", minusTooltip:String = "") : *
		{
			this.stats_mc.addAbility(isCivil, groupId, statID, labelText, valueText, plusTooltip, minusTooltip);
		}
		
		public function addTalent(labelText:String, statID:Number, talentState:Number) : *
		{
			this.stats_mc.addTalent(labelText,statID,talentState);
		}

		public function addTag(tooltipText:String, labelText:String, descriptionText:String, statID:Number) : *
		{
			this.stats_mc.addTag(labelText,statID,tooltipText,descriptionText);
		}
		
		public function addVisual(titleText:String, contentID:Number) : *
		{
			this.stats_mc.addVisual(titleText,contentID);
		}
		
		public function addVisualOption(id:Number, optionId:Number, select:Boolean) : *
		{
			this.stats_mc.addVisualOption(id,optionId,select);
		}
		
		public function updateCharList() : *
		{
			var count:uint = 2;
			if(this.charList_array.length == count)
			{
				this.stats_mc.onePlayerOverlay_mc.visible = true;
				this.stats_mc.charList_mc.x = this.charListOnePlayerPosX;
			}
			else
			{
				this.stats_mc.onePlayerOverlay_mc.visible = false;
				this.stats_mc.charList_mc.x = this.charListPartyPosX;
			}
			var charIndex:uint = 0;
			var i:uint = 0;
			while(i < this.charList_array.length)
			{
				this.stats_mc.addCharPortrait(this.charList_array[i],this.charList_array[i + 1],charIndex++);
				i = i + count;
			}
			this.stats_mc.cleanupCharListObsoletes();
			this.stats_mc.charList.positionElements();
			if(this.stats_mc.charList.length > 4)
			{
				this.stats_mc.leftCycleBtn_mc.visible = true;
				this.stats_mc.rightCycleBtn_mc.visible = true;
			}
			else
			{
				this.stats_mc.leftCycleBtn_mc.visible = false;
				this.stats_mc.rightCycleBtn_mc.visible = false;
			}
			this.charList_array = new Array();
		}
		
		public function cycleCharList(previous:Boolean) : *
		{
			if(previous)
			{
				this.stats_mc.charList.previous();
			}
			else
			{
				this.stats_mc.charList.next();
			}
			var character:MovieClip = this.stats_mc.charList.getCurrentMovieClip();
			if(character)
			{
				ExternalInterface.call("selectCharacter",character.id);
			}
		}

		public function clearArray(name:String): *
		{
			switch(name)
			{
				case "all":
					this.charList_array = new Array();
					this.skillList = new Array();
					this.tabsTexts = new Array();
					this.primStat_array = new Array();
					this.secStat_array = new Array();
					this.ability_array = new Array();
					this.tags_array = new Array();
					this.talent_array = new Array();
					this.visual_array = new Array();
					this.visualValues_array = new Array();
					this.customStats_array = new Array();
					this.lvlBtnAbility_array = new Array();
					this.lvlBtnStat_array = new Array();
					this.lvlBtnSecStat_array = new Array();
					this.lvlBtnTalent_array = new Array();
					this.allignmentArray = new Array();
					this.aiArray = new Array();
					this.inventoryUpdateList = new Array();
					break;
				case "update":
					this.primStat_array = new Array();
					this.ability_array = new Array();
					this.talent_array = new Array();
					this.secStat_array = new Array();
					this.tags_array = new Array();
					this.visualValues_array = new Array();
					this.customStats_array = new Array();
					this.lvlBtnAbility_array = new Array();
					this.lvlBtnStat_array = new Array();
					this.lvlBtnTalent_array = new Array();
					this.lvlBtnSecStat_array = new Array();
					break;
				case "charList_array":
					charList_array.length = 0;
					break;
				case "skillList":
					skillList.length = 0;
					break;
				case "tabsTexts":
					tabsTexts.length = 0;
					break;
				case "primStat_array":
					primStat_array.length = 0;
					break;
				case "secStat_array":
					secStat_array.length = 0;
					break;
				case "ability_array":
					ability_array.length = 0;
					break;
				case "tags_array":
					tags_array.length = 0;
					break;
				case "talent_array":
					talent_array.length = 0;
					break;
				case "visual_array":
					visual_array.length = 0;
					break;
				case "visualValues_array":
					visualValues_array.length = 0;
					break;
				case "customStats_array":
					customStats_array.length = 0;
					break;
				case "lvlBtnAbility_array":
					lvlBtnAbility_array.length = 0;
					break;
				case "lvlBtnStat_array":
					lvlBtnStat_array.length = 0;
					break;
				case "lvlBtnSecStat_array":
					lvlBtnSecStat_array.length = 0;
					break;
				case "lvlBtnTalent_array":
					lvlBtnTalent_array.length = 0;
					break;
				case "allignmentArray":
					allignmentArray.length = 0;
					break;
				case "aiArray":
					aiArray.length = 0;
					break;
				case "inventoryUpdateList":
					inventoryUpdateList.length = 0;
					break;
				default:
					ExternalInterface.call("UIAssert","[characterSheet:clearArray] name ("+String(name)+") isn't valid.");
			}
		}

		public function updateArraySystemOld() : *
		{
			var canAddPoints:Boolean = false;
			var isCivil:Boolean = false;
			var hasButtons:Boolean = false;
			var statId:int = 0;
			var showBothButtons:Boolean = false;
			var minusVisible:Boolean = false;
			var plusVisible:Boolean = false;
			var spacing:Number = NaN;
			var updateCivil:Boolean = false;
			var updateCombat:Boolean = false;
			var val4:Number = getTimer();
			var i:uint = 0;
			while(i < this.primStat_array.length)
			{
				this.addPrimaryStat(this.primStat_array[i],this.primStat_array[i + 1],this.primStat_array[i + 2],this.primStat_array[i + 3]);
				i = i + 4;
			}
			i = 0;
			while(i < this.ability_array.length)
			{
				isCivil = Boolean(this.ability_array[i]);
				if(isCivil)
				{
					updateCivil = true;
				}
				else
				{
					updateCombat = true;
				}
				this.addAbility(isCivil,this.ability_array[i + 1],this.ability_array[i + 2],this.ability_array[i + 3],this.ability_array[i + 4],this.ability_array[i + 5],this.ability_array[i + 6]);
				i = i + 7;
			}
			i = 0;
			while(i < this.secStat_array.length)
			{
				if(this.secStat_array[i])
				{
					this.addSpacing(this.secStat_array[i + 1],this.secStat_array[i + 2]);
				}
				else
				{
					this.addSecondaryStat(this.secStat_array[i + 1],this.secStat_array[i + 2],this.secStat_array[i + 3],this.secStat_array[i + 4],this.secStat_array[i + 5],this.secStat_array[i + 6]);
				}
				i = i + 7;
			}
			i = 0;
			while(i < this.talent_array.length)
			{
				this.addTalent(this.talent_array[i++],this.talent_array[i++],this.talent_array[i++]);
			}
			i = 0;
			while(i < this.tags_array.length)
			{
				this.addTag(this.tags_array[i++],this.tags_array[i++],this.tags_array[i++],this.tags_array[i++]);
			}
			this.stats_mc.clearVisualOptions();
			i = 0;
			while(i < this.visualValues_array.length)
			{
				this.addVisualOption(this.visualValues_array[i++],this.visualValues_array[i++],this.visualValues_array[i++]);
			}
			this.stats_mc.clearCustomStatsOptions();
			i = 0;
			while(i < this.customStats_array.length)
			{
				this.stats_mc.addCustomStat(this.customStats_array[i],this.customStats_array[i + 1],this.customStats_array[i + 2]);
				i = i + 3;
			}
			i = 0;
			while(i < this.lvlBtnStat_array.length)
			{
				canAddPoints = Boolean(this.lvlBtnStat_array[i]);
				if(canAddPoints)
				{
					this.setStatPlusVisible(this.lvlBtnStat_array[i + 1],this.lvlBtnStat_array[i + 2]);
				}
				else
				{
					this.setStatMinusVisible(this.lvlBtnStat_array[i + 1],this.lvlBtnStat_array[i + 2]);
				}
				i = i + 3;
			}
			if(this.lvlBtnSecStat_array.length > 0)
			{
				hasButtons = this.lvlBtnSecStat_array[0];
				i = 1;
				while(i < this.lvlBtnSecStat_array.length)
				{
					statId = this.lvlBtnSecStat_array[i];
					if(hasButtons)
					{
						showBothButtons = this.lvlBtnSecStat_array[i + 1];
						minusVisible = this.lvlBtnSecStat_array[i + 2];
						plusVisible = this.lvlBtnSecStat_array[i + 3];
						spacing = 5;
						if(statId == 44)
						{
							spacing = 9;
						}
						//id:int, showBoth:Boolean, minusVisible:Boolean, plusVisible:Boolean, param5:Number = 5
						this.setupSecondaryStatsButtons(statId,showBothButtons,minusVisible,plusVisible,spacing);
					}
					else
					{
						this.setupSecondaryStatsButtons(statId,false,false,false);
					}
					i = i + 4;
				}
			}
			i = 0;
			while(i < this.lvlBtnAbility_array.length)
			{
				canAddPoints = Boolean(this.lvlBtnAbility_array[i]);
				if(canAddPoints)
				{
					this.setAbilityPlusVisible(this.lvlBtnAbility_array[i + 1],this.lvlBtnAbility_array[i + 2],this.lvlBtnAbility_array[i + 3],this.lvlBtnAbility_array[i + 4]);
				}
				else
				{
					this.setAbilityMinusVisible(this.lvlBtnAbility_array[i + 1],this.lvlBtnAbility_array[i + 2],this.lvlBtnAbility_array[i + 3],this.lvlBtnAbility_array[i + 4]);
				}
				i = i + 5;
			}
			i = 0;
			while(i < this.lvlBtnTalent_array.length)
			{
				canAddPoints = Boolean(this.lvlBtnTalent_array[i]);
				if(canAddPoints)
				{
					this.setTalentPlusVisible(this.lvlBtnTalent_array[i + 1],this.lvlBtnTalent_array[i + 2]);
				}
				else
				{
					this.setTalentMinusVisible(this.lvlBtnTalent_array[i + 1],this.lvlBtnTalent_array[i + 2]);
				}
				i = i + 3;
			}
			if(updateCivil)
			{
				this.stats_mc.civicAbilityHolder_mc.list.positionElements();
				this.stats_mc.recountAbilityPoints(true);
			}
			if(updateCombat)
			{
				this.stats_mc.combatAbilityHolder_mc.list.positionElements();
				this.stats_mc.recountAbilityPoints(false);
			}
			if(this.tags_array.length > 0)
			{
				this.stats_mc.tagsHolder_mc.list.positionElements();
			}
			if(this.talent_array.length > 0)
			{
				this.stats_mc.talentHolder_mc.list.positionElements();
			}
			if(this.customStats_array.length > 0)
			{
				this.stats_mc.customStats_mc.positionElements();
			}
			this.primStat_array = new Array();
			this.ability_array = new Array();
			this.tags_array = new Array();
			this.talent_array = new Array();
			this.visualValues_array = new Array();
			this.customStats_array = new Array();
			this.secStat_array = new Array();
			this.lvlBtnAbility_array = new Array();
			this.lvlBtnStat_array = new Array();
			this.lvlBtnTalent_array = new Array();
			this.lvlBtnSecStat_array = new Array();
			this.stats_mc.resetScrollBarsPositions();
			this.stats_mc.resetListPositions();
			this.stats_mc.recheckScrollbarVisibility();
			this.initDone = true;
		}
		
		public function updateArraySystem() : *
		{
			var canAddPoints:Boolean = false;
			var hasButtons:Boolean = false;
			var statID:int = 0;
			var showBothButtons:Boolean = false;
			var minusVisible:Boolean = false;
			var plusVisible:Boolean = false;
			var spacing:Number = NaN;

			var i:uint = 0;

			while(i < this.tags_array.length)
			{
				this.addTag(this.tags_array[i++],this.tags_array[i++],this.tags_array[i++],this.tags_array[i++]);
			}

			this.stats_mc.clearVisualOptions();

			i = 0;
			while(i < this.visualValues_array.length)
			{
				this.addVisualOption(this.visualValues_array[i++],this.visualValues_array[i++],this.visualValues_array[i++]);
			}

			i = 0;
			while(i < this.lvlBtnStat_array.length)
			{
				canAddPoints = Boolean(this.lvlBtnStat_array[i]);
				if(canAddPoints)
				{
					this.setStatPlusVisible(this.lvlBtnStat_array[i + 1],this.lvlBtnStat_array[i + 2]);
				}
				else
				{
					this.setStatMinusVisible(this.lvlBtnStat_array[i + 1],this.lvlBtnStat_array[i + 2]);
				}
				i = i + 3;
			}

			i = 0;
			if(this.lvlBtnSecStat_array.length > 0)
			{
				hasButtons = this.lvlBtnSecStat_array[0];
				i = 1;
				while(i < this.lvlBtnSecStat_array.length)
				{
					statID = this.lvlBtnSecStat_array[i];
					if(hasButtons)
					{
						showBothButtons = this.lvlBtnSecStat_array[i + 1];
						minusVisible = this.lvlBtnSecStat_array[i + 2];
						plusVisible = this.lvlBtnSecStat_array[i + 3];
						spacing = 5;
						if(statID == 44)
						{
							spacing = 9;
						}
						//id:int, showBoth:Boolean, minusVisible:Boolean, plusVisible:Boolean, param5:Number = 5
						this.setupSecondaryStatsButtons(statID,showBothButtons,minusVisible,plusVisible,spacing);
					}
					else
					{
						this.setupSecondaryStatsButtons(statID,false,false,false);
					}
					i = i + 4;
				}
			}

			if(this.tags_array.length > 0)
			{
				this.stats_mc.tagsHolder_mc.list.positionElements();
			}
			
			i = 0;
			while(i < this.customStats_array.length)
			{
				this.stats_mc.customStats_mc.addCustomStat(this.customStats_array[i],this.customStats_array[i + 1],this.customStats_array[i + 2],this.customStats_array[i + 3],this.customStats_array[i + 4],this.customStats_array[i + 5]);
				i = i + 6;
			}
			if(this.customStats_array.length > 0)
			{
				this.stats_mc.customStats_mc.positionElements();
			}
			this.initDone = true;
			ExternalInterface.call("characterSheetUpdateDone");
		}
		
		public function setStatPlusVisible(statID:Number, isVisible:Boolean) : *
		{
			this.stats_mc.setStatPlusVisible(statID,isVisible);
		}
		
		public function setStatMinusVisible(statID:Number, isVisible:Boolean) : *
		{
			this.stats_mc.setStatMinusVisible(statID,isVisible);
		}
		
		public function setupSecondaryStatsButtons(id:int, showBoth:Boolean, minusVisible:Boolean, plusVisible:Boolean, maxChars:Number = 5) : void
		{
			this.stats_mc.setupSecondaryStatsButtons(id,showBoth,minusVisible,plusVisible,maxChars);
		}
		
		public function setAbilityPlusVisible(isCivil:Boolean, groupId:Number, statID:Number, isVisible:Boolean) : *
		{
			this.stats_mc.setAbilityPlusVisible(isCivil,groupId,statID,isVisible);
		}
		
		public function setAbilityMinusVisible(isCivil:Boolean, groupId:Number, statID:Number, isVisible:Boolean) : *
		{
			this.stats_mc.setAbilityMinusVisible(isCivil,groupId,statID,isVisible);
		}
		
		public function setTalentPlusVisible(statID:Number, isVisible:Boolean) : *
		{
			this.stats_mc.setTalentPlusVisible(statID,isVisible);
		}
		
		public function setTalentMinusVisible(statID:Number, isVisible:Boolean) : *
		{
			this.stats_mc.setTalentMinusVisible(statID,isVisible);
		}
		
		public function addTitle(param1:String) : *
		{
			this.stats_mc.addTitle(param1);
		}
		
		public function hideLevelUpStatButtons() : *
		{
			this.stats_mc.setVisibilityStatButtons(false);
			this.setAvailableStatPoints(0);
		}
		
		public function hideLevelUpAbilityButtons() : *
		{
			this.stats_mc.setVisibilityAbilityButtons(false,false);
			this.stats_mc.setVisibilityAbilityButtons(true,false);
			this.setAvailableCombatAbilityPoints(0);
			this.setAvailableCivilAbilityPoints(0);
			this.setAvailableCustomStatPoints(0);
		}
		
		public function hideLevelUpTalentButtons(force:Boolean=false) : *
		{
			// What's calling this after the array is parsed?
			if (!this.justUpdated || force) {
				this.stats_mc.setVisibilityTalentButtons(false);
				this.setAvailableTalentPoints(0);
			}
		}
		
		public function clearStats(force:Boolean=false) : *
		{
			if (!this.justUpdated || force) {
				this.stats_mc.clearStats();
			}
		}

		public function clearCustomStats(force:Boolean=false) : *
		{
			if (!this.justUpdated || force) {
				this.stats_mc.clearCustomStatsOptions();
			}
		}
		
		public function clearTags() : *
		{
			this.stats_mc.tagsHolder_mc.list.clearElements();
		}
		
		public function clearTalents(force:Boolean=false) : *
		{
			// What's calling this after the array is parsed?
			if (!this.justUpdated || force) {
				this.stats_mc.talentHolder_mc.list.clearElements();
			}
		}
		
		public function clearAbilities(force:Boolean=false) : *
		{
			if (!this.justUpdated || force) {
				this.stats_mc.clearAbilities();
			}
		}
		
		public function setPanelTitle(param1:Number, param2:String) : *
		{
			this.stats_mc.setPanelTitle(param1,param2);
		}
		
		public function showAcceptStatsAcceptButton(b:Boolean) : *
		{
		}
		
		public function showAcceptAbilitiesAcceptButton(b:Boolean) : *
		{
		}
		
		public function showAcceptTalentAcceptButton(b:Boolean) : *
		{
		}
		
		public function setAvailableStatPoints(amount:Number) : *
		{
			this.stats_mc.setAvailableStatPoints(amount);
		}
		
		public function setAvailableCombatAbilityPoints(amount:Number) : *
		{
			this.stats_mc.setAvailableCombatAbilityPoints(amount);
		}
		
		public function setAvailableCivilAbilityPoints(amount:Number) : *
		{
			this.stats_mc.setAvailableCivilAbilityPoints(amount);
		}
		
		public function setAvailableTalentPoints(amount:Number) : *
		{
			this.stats_mc.setAvailableTalentPoints(amount);
		}	

		public function setAvailableCustomStatPoints(amount:Number) : *
		{
			this.stats_mc.INTSetWarnAndPoints(4,amount);
		}
		
		public function addSpacing(statType:Number, height:Number) : *
		{
			this.stats_mc.addSpacing(statType,height);
		}
		
		public function addGoldWeight(param1:String, param2:String) : *
		{
		}
		
		public function startsWith(param1:String, param2:String) : Boolean
		{
			param1 = param1.toLowerCase();
			param2 = param2.toLowerCase();
			return param2 == param1.substr(0,param2.length);
		}
		
		public function ShowItemUnEquipAnim(param1:uint, param2:uint) : *
		{
			this.stats_mc.equip_mc.ShowItemUnEquipAnim(param1,param2);
		}
		
		public function ShowItemEquipAnim(param1:uint, param2:uint) : *
		{
			this.stats_mc.equip_mc.ShowItemEquipAnim(param1,param2);
		}
		
		public function setupStrings() : void
		{
			this.stats_mc.invTabHolder_mc.cbTreasures_mc.setDefaultText(String(this.strSelectTreasure).toUpperCase());
			this.stats_mc.invTabHolder_mc.btnGenerate_mc.setText(String(this.strGenerate).toUpperCase());
			this.stats_mc.invTabHolder_mc.btnClear_mc.setText(String(this.strClear).toUpperCase());
			this.stats_mc.invTabHolder_mc.lblLevel_txt.htmlText = String(this.strLevel).toUpperCase();
			this.stats_mc.customStats_mc.create_mc.setText(String(this.createNewStatBtnLabel).toUpperCase());
		}
		
		public function setupRarity() : void
		{
			var val1:Number = NaN;
			var val2:Number = NaN;
			var val3:GenStockCombo_Element = null;
			val1 = this.listRarity.length;
			val2 = 0;
			while(val2 < val1)
			{
				val3 = new GenStockCombo_Element();
				val3.init();
				val3.text = String(this.listRarity[val2]);
				this.stats_mc.invTabHolder_mc.cbRarity_mc.addElement(val3);
				val2 = val2 + 2;
			}
			this.stats_mc.invTabHolder_mc.cbRarity_mc.positionElements();
			this.setGenerationRarity(0);
		}
		
		public function setupTreasures() : void
		{
			var count:Number = NaN;
			var i:Number = NaN;
			var element:GenStockCombo_Element = null;
			count = this.listTreasures.length;
			i = 0;
			while(i < count)
			{
				element = new GenStockCombo_Element();
				element.init();
				element.treasureId = int(this.listTreasures[i + 0]);
				element.text = String(this.listTreasures[i + 1]);
				this.stats_mc.invTabHolder_mc.cbTreasures_mc.addElement(element);
				i = i + 2;
			}
			this.stats_mc.invTabHolder_mc.cbTreasures_mc.positionElements();
		}
		
		public function onOpenDropList(mc:MovieClip) : void
		{
			if(this.stats_mc.invTabHolder_mc.cbTreasures_mc != mc)
			{
				this.stats_mc.invTabHolder_mc.cbTreasures_mc.opened = false;
			}
			if(this.stats_mc.invTabHolder_mc.cbRarity_mc != mc)
			{
				this.stats_mc.invTabHolder_mc.cbRarity_mc.opened = false;
			}
		}
		
		public function closeDropLists() : void
		{
			this.stats_mc.invTabHolder_mc.cbTreasures_mc.opened = false;
			this.stats_mc.invTabHolder_mc.cbRarity_mc.opened = false;
		}
		
		public function setGenerationRarity(id:int) : void
		{
			this.generateTreasureRarityId = id;
			this.stats_mc.invTabHolder_mc.cbRarity_mc.select(id,false);
		}
		
		public function onSelectGenerationRarity(id:int) : void
		{
			this.generateTreasureRarityId = id;
		}
		
		public function onChangeGenerationLevel(level:Number) : void
		{
			this.generateTreasureLevel = level;
		}
		
		public function onSelectTreasure(index:int) : void
		{
			var treasure_mc:MovieClip = this.stats_mc.invTabHolder_mc.cbTreasures_mc.getElement(index);
			if(treasure_mc != null)
			{
				this.generateTreasureId = treasure_mc.treasureId;
				this.stats_mc.invTabHolder_mc.btnGenerate_mc.setEnabled(true);
			}
		}
		
		public function onBtnGenerateStock() : void
		{
			ExternalInterface.call("onGenerateTreasure",this.generateTreasureId,this.generateTreasureRarityId,this.generateTreasureLevel);
		}
		
		public function onBtnClearInventory() : void
		{
			ExternalInterface.call("onClearInventory");
		}
		
		public function frame1() : *
		{
			this.initDone = false;
			this.events = new Array("IE ContextMenu","IE UIAccept","IE ToggleInGameMenu");
			this.layout = "fixed";
			this.alignment = "none";
			this.curTooltip = -1;
			this.hasTooltip = false;
			this.keepCustomInScreen = true;
			this.uiLeft = 0;
			this.uiRight = 680;
			this.uiTop = 45;
			this.uiMinHeight = 190;
			this.uiMinWidth = 150;
			this.charList_array = new Array();
			this.invRows = 8;
			this.invCols = 5;
			this.invCellSize = 50;
			this.invCellSpacing = 12;
			this.skillList = new Array();
			this.tabsTexts = new Array();
			this.primStat_array = new Array();
			this.secStat_array = new Array();
			this.ability_array = new Array();
			this.tags_array = new Array();
			this.talent_array = new Array();
			this.visual_array = new Array();
			this.visualValues_array = new Array();
			this.customStats_array = new Array();
			this.lvlBtnAbility_array = new Array();
			this.lvlBtnStat_array = new Array();
			this.lvlBtnSecStat_array = new Array();
			this.lvlBtnTalent_array = new Array();
			this.allignmentArray = new Array();
			this.aiArray = new Array();
			this.inventoryUpdateList = new Array();
			this.isGameMasterChar = false;
			this.EQContainer = this.stats_mc.equip_mc.container_mc;
			this.slotAmount = 11;
			this.cellSize = 64;
			this.slot_array = new Array(this.EQContainer.s0_mc,this.EQContainer.s1_mc,this.EQContainer.s2_mc,this.EQContainer.s3_mc,this.EQContainer.s4_mc,this.EQContainer.s5_mc,this.EQContainer.s6_mc,this.EQContainer.s7_mc,this.EQContainer.s8_mc,this.EQContainer.s9_mc,this.EQContainer.s10_mc);
			this.itemsUpdateList = new Array();
			this.stats_mc.mouseWheelEnabled = true;
			this.stats_mc.addEventListener(MouseEvent.MOUSE_WHEEL,this.onWheel);
			this.stats_mc.mouseEnabled = true;
			this.tabState = 0;
			this.text_array = new Array(this.stats_mc.mainStats_mc.labelStr,this.stats_mc.combatAbilityHolder_mc.labelStr,this.stats_mc.civicAbilityHolder_mc.labelStr,this.stats_mc.tagsHolder_mc.labelStr,this.stats_mc.equipment_txt);
			this.strSelectTreasure = this.strUndefined;
			this.strGenerate = this.strUndefined;
			this.strClear = this.strUndefined;
			this.strLevel = this.strUndefined;
			this.listRarity = new Array();
			this.listTreasures = new Array();
			this.generateTreasureRarityId = 0;
			this.generateTreasureId = 0;
			this.generateTreasureLevel = 1;
		}
	}
}
