package statsPanel_c_fla
{
	import LS_Classes.larTween;
	import LS_Classes.textEffect;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	
	public dynamic class MainTimeline extends MovieClip
	{
		public var mainpanel_mc:MovieClip;
		public var events:Array;
		public var layout:String;
		public var alignment:String;
		public var isDragging:Boolean;
		public var curTooltip:int;
		public var hasTooltip:Boolean;
		public var invCellSize:Number;
		public var invCellSpacing:Number;
		public var invBgDiscrap:Number;
		public var invRows:Number;
		public var invCols:Number;
		public var charIconW:Number;
		public var charIconH:Number;
		public var ability_array:Array;
		public var tags_array:Array;
		public var talent_array:Array;
		public var infoStat_array:Array;
		public var lvlBtnAbility_array:Array;
		public var lvlBtnStat_array:Array;
		public var lvlBtnTalent_array:Array;
		public var customStats_array:Array;
		public var tooltipArray:Array;
		public var text_array:Array;
		public var initDone:Boolean;
		public var hasCanceled:Boolean;
		public var tooltipTw:larTween;
		public const s_disabledTooltipAlpha:Number = 0.0;
		public const s_TooltipTween:Number = 0.3;
		public var status_array:Array;
		public var oldId:Number;
		
		//LeaderLib
		public var characterHandle:Number;
		//In case mods are still using this.
		public var charHandle:Number;
		
		public function MainTimeline()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onEventResize() : *
		{
		}
		
		public function onEventDown(param1:Number) : *
		{
			var val2:Boolean = false;
			var val3:String = this.events[param1];
			switch(this.events[param1])
			{
				case "IE UIBack":
					val2 = true;
					break;
				case "IE UIUp":
					this.mainpanel_mc.cursorUp();
					val2 = true;
					break;
				case "IE UIDown":
					this.mainpanel_mc.cursorDown();
					val2 = true;
					break;
				case "IE UILeft":
					this.mainpanel_mc.cursorLeft();
					val2 = true;
					break;
				case "IE UIRight":
					this.mainpanel_mc.cursorRight();
					val2 = true;
					break;
				case "IE UIRemovePoints":
					val2 = this.mainpanel_mc.removePoint();
					break;
				case "IE UIAddPoints":
					val2 = this.mainpanel_mc.addPoint();
					break;
				case "IE UITooltipUp":
					if(this.mainpanel_mc.stats_mc.tooltip_mc.visible)
					{
						this.mainpanel_mc.stats_mc.tooltip_mc.scrollUp();
					}
					else
					{
						this.mainpanel_mc.stats_mc.statsList.m_scrollbar_mc.scrollUp();
					}
					val2 = true;
					break;
				case "IE UITooltipDown":
					if(this.mainpanel_mc.stats_mc.tooltip_mc.visible)
					{
						this.mainpanel_mc.stats_mc.tooltip_mc.scrollDown();
					}
					else
					{
						this.mainpanel_mc.stats_mc.statsList.m_scrollbar_mc.scrollDown();
					}
					val2 = true;
					break;
				case "IE UITabPrev":
					this.mainpanel_mc.stats_mc.tabBar_mc.lb_mc.showHL();
					this.mainpanel_mc.subTabPrevious();
					val2 = true;
					break;
				case "IE UITabNext":
					this.mainpanel_mc.stats_mc.tabBar_mc.rb_mc.showHL();
					this.mainpanel_mc.subTabNext();
					val2 = true;
					break;
				case "IE UIShowTooltip":
					if(this.hasTooltip)
					{
						this.mainpanel_mc.toggleTooltip();
					}
					val2 = true;
					break;
				case "IE UICancel":
					if(this.mainpanel_mc.stats_mc.tooltip_mc.visible)
					{
						this.mainpanel_mc.stats_mc.tooltip_mc.visible = false;
						this.hasCanceled = true;
						val2 = true;
					}
			}
			return val2;
		}
		
		public function onEventUp(param1:Number) : *
		{
			var val2:Boolean = false;
			switch(this.events[param1])
			{
				case "IE UIUp":
				case "IE UIDown":
					this.mainpanel_mc.setListLoopable(true);
					val2 = true;
					break;
				case "IE UILeft":
				case "IE UIRight":
					val2 = true;
					break;
				case "IE UIAccept":
					this.mainpanel_mc.cursorAccept();
					val2 = true;
					break;
				case "IE UITooltipUp":
				case "IE UITooltipDown":
					this.mainpanel_mc.stats_mc.tooltip_mc.stopScrolling();
					val2 = true;
					break;
				case "IE UITabPrev":
					this.mainpanel_mc.stats_mc.tabBar_mc.lb_mc.hideHL();
					val2 = true;
					break;
				case "IE UITabNext":
					this.mainpanel_mc.stats_mc.tabBar_mc.rb_mc.hideHL();
					val2 = true;
					break;
				case "IE UIShowTooltip":
					val2 = true;
					break;
				case "IE UIBack":
				case "IE UICancel":
					if(this.hasCanceled)
					{
						this.hasCanceled = false;
						val2 = true;
					}
					else
					{
						ExternalInterface.call("PlaySound","UI_Game_Inventory_Close");
						ExternalInterface.call("hideUI");
					}
			}
			return val2;
		}
		
		public function setPanelTitle(param1:String) : *
		{
			this.mainpanel_mc.panelTitle_txt.htmlText = param1;
			this.mainpanel_mc.panelTitle_txt.filters = textEffect.createStrokeFilter(0,2,0.75,1.8,3);
		}
		
		public function onEventInit() : *
		{
			this.mainpanel_mc.init();
			this.mainpanel_mc.stats_mc.tooltip_mc.visible = false;
		}
		
		public function setAnchor(param1:Number, param2:* = true) : *
		{
			ExternalInterface.call("registerAnchorId","statspanel_c" + param1);
			ExternalInterface.call("setAnchor","center","splitscreen","center");
		}
		
		public function setPlayer(param1:Number, param2:Boolean) : *
		{
			this.mainpanel_mc.stats_mc.bg_mc.setAvatar(param2);
		}
		
		public function setHLOnRT(param1:Boolean) : *
		{
			if(param1)
			{
				this.mainpanel_mc.RT_mc.showHL();
			}
			else
			{
				this.mainpanel_mc.RT_mc.hideHL();
			}
		}
		
		public function setHLOnLT(param1:Boolean) : *
		{
			if(param1)
			{
				this.mainpanel_mc.LT_mc.showHL();
			}
			else
			{
				this.mainpanel_mc.LT_mc.hideHL();
			}
		}
		
		public function clearTooltip() : *
		{
			this.setTooltip("","",false);
			this.mainpanel_mc.stats_mc.tooltip_mc.visible = false;
		}
		
		public function enableTooltip() : *
		{
			this.hasTooltip = true;
		}
		
		public function setTooltip(title:String, text:String, unused:Boolean) : *
		{
			var arr:Array = new Array(1,title);
			arr.push(58);
			arr.push(text);
			this.mainpanel_mc.stats_mc.tooltip_mc.setupTooltip(arr);
			this.mainpanel_mc.stats_mc.setTooltipSide();
			if(text != "")
			{
				this.enableTooltip();
			}
			else
			{
				this.hasTooltip = false;
			}
		}
		
		public function showTooltip() : *
		{
			if(this.tooltipArray.length > 0)
			{
				this.mainpanel_mc.stats_mc.tooltip_mc.setupTooltip(this.tooltipArray);
				this.tooltipArray = new Array();
				this.mainpanel_mc.stats_mc.setTooltipSide();
				this.enableTooltip();
			}
		}
		
		public function setText(param1:Number, param2:String) : *
		{
			if(param1 >= 0 && param1 < this.text_array.length)
			{
				this.text_array[param1].htmlText = param2;
				if(this.text_array[param1] == this.mainpanel_mc.stats_mc.info_mc.repVal_txt || this.text_array[param1] == this.mainpanel_mc.stats_mc.info_mc.repLabel_txt)
				{
					this.resetReputationPos();
				}
				else if(this.text_array[param1] == this.mainpanel_mc.stats_mc.info_mc.levelStr_txt)
				{
					this.mainpanel_mc.stats_mc.info_mc.levelStr2_txt.htmlText = param2;
				}
				else if(this.text_array[param1] == this.mainpanel_mc.stats_mc.attributes_mc.pointsLabel_txt || this.text_array[param1] == this.mainpanel_mc.stats_mc.combatAbilities_mc.pointsLabel_txt || this.text_array[param1] == this.mainpanel_mc.stats_mc.civilAbilities_mc.pointsLabel_txt || this.text_array[param1] == this.mainpanel_mc.stats_mc.talents_mc.pointsLabel_txt)
				{
					this.text_array[param1].y = 77 - Math.round(this.text_array[param1].textHeight * 0.5);
				}
			}
		}
		
		public function resetReputationPos() : *
		{
			this.mainpanel_mc.stats_mc.info_mc.repVal_txt.x = Math.round(770 - this.mainpanel_mc.stats_mc.info_mc.repVal_txt.textWidth);
			this.mainpanel_mc.stats_mc.info_mc.repLabel_txt.x = Math.round(this.mainpanel_mc.stats_mc.info_mc.repVal_txt.x - this.mainpanel_mc.stats_mc.info_mc.repLabel_txt.textWidth) - 10;
			this.mainpanel_mc.stats_mc.info_mc.repIcon_mc.x = Math.round(this.mainpanel_mc.stats_mc.info_mc.repLabel_txt.x - this.mainpanel_mc.stats_mc.info_mc.repIcon_mc.width) - 10;
		}
		
		public function addBtnHint(param1:Number, param2:String, param3:Number) : *
		{
			this.mainpanel_mc.buttonHint_mc.addBtnHint(param1,param2,param3);
			if(this.mainpanel_mc.stats_mc.currentPanel)
			{
				this.mainpanel_mc.stats_mc.currentPanel.updateHints();
			}
		}
		
		public function clearBtnHints() : *
		{
			this.mainpanel_mc.buttonHint_mc.clearBtnHints();
		}
		
		public function showPanel(param1:Number) : *
		{
			this.mainpanel_mc.showPanel(param1);
		}
		
		public function addInfoStat(param1:Number, param2:Number, param3:String, param4:String, param5:Number, param6:uint) : *
		{
			this.mainpanel_mc.stats_mc.addInfoStat(param1,param2,param3,param4,param5,param6);
		}
		
		public function setInfoStatValue(param1:Number, param2:String) : *
		{
			this.mainpanel_mc.stats_mc.setInfoStatValue(param1,param2);
		}
		
		public function addInfoStatSpacing(param1:Number, param2:Number) : *
		{
			this.mainpanel_mc.stats_mc.addSpacing(param1,param2);
		}
		
		public function clearInfoStats() : *
		{
			this.mainpanel_mc.stats_mc.clearInfoStats();
		}
		
		public function setExperience(param1:Number, param2:String, param3:String) : *
		{
			this.mainpanel_mc.stats_mc.info_mc.setExp(param1);
			this.mainpanel_mc.stats_mc.info_mc.currentXp_txt.htmlText = param2;
			this.mainpanel_mc.stats_mc.info_mc.nextXp_txt.htmlText = param3;
		}
		
		public function setNextLevelStats(param1:Number, param2:Number, param3:Number, param4:Number) : *
		{
			var val5:String = "-";
			var val6:String = "-";
			var val7:String = "-";
			var val8:String = "-";
			if(param1 > 0)
			{
				val5 = "+" + param1;
			}
			if(param2 > 0)
			{
				val6 = "+" + param2;
			}
			if(param3 > 0)
			{
				val7 = "+" + param3;
			}
			if(param4 > 0)
			{
				val8 = "+" + param4;
			}
			this.mainpanel_mc.stats_mc.info_mc.attrPoints_txt.htmlText = val5;
			this.mainpanel_mc.stats_mc.info_mc.combatAbilPoints_txt.htmlText = val6;
			this.mainpanel_mc.stats_mc.info_mc.civilAbilPoints_txt.htmlText = val7;
			this.mainpanel_mc.stats_mc.info_mc.tallPoints_txt.htmlText = val8;
		}
		
		public function setStatPoints(param1:Number, param2:String) : *
		{
			switch(param1)
			{
				case 0:
					this.mainpanel_mc.stats_mc.attributes_mc.setPoints(param2);
					this.mainpanel_mc.stats_mc.tabBar_mc.setTabPoints(1,Number(param2));
					break;
				case 1:
					this.mainpanel_mc.stats_mc.combatAbilities_mc.setPoints(param2);
					this.mainpanel_mc.stats_mc.tabBar_mc.setTabPoints(2,Number(param2));
					break;
				case 2:
					this.mainpanel_mc.stats_mc.civilAbilities_mc.setPoints(param2);
					this.mainpanel_mc.stats_mc.tabBar_mc.setTabPoints(3,Number(param2));
					break;
				case 3:
					this.mainpanel_mc.stats_mc.talents_mc.setPoints(param2);
					this.mainpanel_mc.stats_mc.tabBar_mc.setTabPoints(4,Number(param2));
			}
		}
		
		public function showBreadcrumb(param1:Number, param2:Boolean) : *
		{
			this.mainpanel_mc.stats_mc.tabBar_mc.showBreadcrumb(param1,param2);
		}
		
		public function setPointAssignMode(param1:Boolean) : *
		{
			this.mainpanel_mc.stats_mc.setPointAssignMode(param1);
		}
		
		public function selectTab(param1:Number) : *
		{
			this.mainpanel_mc.stats_mc.tabBar_mc.selectTab(param1);
		}
		
		public function updateStatuses(param1:Boolean) : *
		{
			var val4:Number = NaN;
			var val5:Number = NaN;
			var val6:Number = NaN;
			var val7:String = null;
			var val8:Number = NaN;
			var val9:String = null;
			var val2:Number = this.mainpanel_mc.stats_mc.statusList.size;
			var val3:* = 0;
			while(val3 < this.status_array.length)
			{
				if(this.status_array[val3] != undefined)
				{
					val4 = Number(this.status_array[val3]);
					val5 = Number(this.status_array[val3 + 1]);
					val6 = Number(this.status_array[val3 + 2]);
					val7 = String(this.status_array[val3 + 3]);
					val8 = Number(this.status_array[val3 + 4]);
					val9 = String(this.status_array[val3 + 5]);
					this.setStatus(param1,val4,val5,val6,val7,val8,val9);
				}
				val3 = val3 + 6;
			}
			this.status_array = new Array();
			this.mainpanel_mc.stats_mc.cleanupStatuses();
		}
		
		public function selectFirstStatus(param1:Boolean = false) : *
		{
			var val2:StatusElement = null;
			if(this.mainpanel_mc.stats_mc.statusList.size > 0)
			{
				val2 = this.mainpanel_mc.stats_mc.statusList.getCurrentMovieClip();
				if(!val2 || val2 && val2.id != this.oldId || param1)
				{
					this.mainpanel_mc.stats_mc.statusList.selectFirstVisible(true);
					val2 = this.mainpanel_mc.stats_mc.statusList.getCurrentMovieClip();
					val2.selectElement();
					this.oldId = val2.id;
				}
			}
		}
		
		public function setStatus(param1:Boolean, param2:Number, param3:Number, param4:Number, param5:String, param6:Number, param7:String = "") : *
		{
			this.mainpanel_mc.stats_mc.setStatus(param1,param2,param3,param4,param5,param6,param7);
		}
		
		public function clearStatuses() : *
		{
			this.mainpanel_mc.stats_mc.clearStatuses();
		}

		public function clearArray(name:String): *
		{
			switch(name)
			{
				case "all":
					this.ability_array = new Array();
					this.customStats_array = new Array();
					this.infoStat_array = new Array();
					this.lvlBtnAbility_array = new Array();
					this.lvlBtnStat_array = new Array();
					this.lvlBtnTalent_array = new Array();
					this.status_array = new Array();
					this.tags_array = new Array();
					this.talent_array = new Array();
					this.tooltipArray = new Array();
					break;
				case "ability_array":
					this.ability_array.length = 0;
					break;
				case "customStats_array":
					this.customStats_array.length = 0;
					break;
				case "infoStat_array":
					this.infoStat_array.length = 0;
					break;
				case "lvlBtnAbility_array":
					this.lvlBtnAbility_array.length = 0;
					break;
				case "lvlBtnStat_array":
					this.lvlBtnStat_array.length = 0;
					break;
				case "lvlBtnTalent_array":
					this.lvlBtnTalent_array.length = 0;
					break;
				case "status_array":
					this.status_array.length = 0;
					break;
				case "tags_array":
					this.tags_array.length = 0;
					break;
				case "talent_array":
					this.talent_array.length = 0;
					break;
				case "tooltipArray":
					this.tooltipArray.length = 0;
					break;
				default:
					ExternalInterface.call("UIAssert","[characterSheet:clearArray] name ("+String(name)+") isn't valid.");
			}
		}
		
		public function updateArraySystem() : *
		{
			var val3:* = undefined;
			var val4:Boolean = false;
			var val5:Number = NaN;
			var val6:String = null;
			var val7:String = null;
			var val1:Boolean = false;
			var val2:Number = 0;
			if(this.infoStat_array.length > 0)
			{
				val2 = 0;
				while(val2 < this.infoStat_array.length)
				{
					if(this.infoStat_array[val2])
					{
						this.addInfoStatSpacing(this.infoStat_array[val2 + 1],this.infoStat_array[val2 + 2]);
					}
					else
					{
						this.addInfoStat(this.infoStat_array[val2 + 1],this.infoStat_array[val2 + 2],this.infoStat_array[val2 + 3],this.infoStat_array[val2 + 4],this.infoStat_array[val2 + 5],this.infoStat_array[val2 + 6]);
					}
					val2 = val2 + 7;
				}
				this.mainpanel_mc.stats_mc.statsList.positionElements();
				this.mainpanel_mc.stats_mc.updateDone();
			}
			val2 = 0;
			while(val2 < this.ability_array.length)
			{
				this.addAbility(this.ability_array[val2++],this.ability_array[val2++],this.ability_array[val2++],this.ability_array[val2++],this.ability_array[val2++],this.ability_array[val2++]);
			}
			this.mainpanel_mc.stats_mc.civilAbilities_mc.statList.positionElements();
			this.mainpanel_mc.stats_mc.combatAbilities_mc.statList.positionElements();
			this.mainpanel_mc.stats_mc.civilAbilities_mc.statList.unCollapseAll();
			this.mainpanel_mc.stats_mc.combatAbilities_mc.statList.unCollapseAll();
			val2 = 0;
			while(val2 < this.talent_array.length)
			{
				this.addTalent(this.talent_array[val2],this.talent_array[val2 + 1],this.talent_array[val2 + 2]);
				val2 = val2 + 3;
			}
			val2 = 0;
			while(val2 < this.tags_array.length)
			{
				val3 = 1;
				if(val2 > 0)
				{
					val3 = val2 + 4 >= this.tags_array.length?3:2;
				}
				this.addTag(this.tags_array[val2++],this.tags_array[val2++],this.tags_array[val2++],this.tags_array[val2++],val3);
			}
			val2 = 0;
			while(val2 < this.lvlBtnStat_array.length)
			{
				this.mainpanel_mc.stats_mc.attributes_mc.setBtnVisible(this.lvlBtnStat_array[val2],this.lvlBtnStat_array[val2 + 1],this.lvlBtnStat_array[val2 + 2]);
				val2 = val2 + 3;
			}
			val2 = 0;
			while(val2 < this.lvlBtnAbility_array.length)
			{
				val4 = this.lvlBtnAbility_array[val2++];
				val1 = Boolean(this.lvlBtnAbility_array[val2++]);
				if(val4)
				{
					this.mainpanel_mc.stats_mc.civilAbilities_mc.setBtnVisible(this.lvlBtnAbility_array[val2++],this.lvlBtnAbility_array[val2++],val1,this.lvlBtnAbility_array[val2++]);
				}
				else
				{
					this.mainpanel_mc.stats_mc.combatAbilities_mc.setBtnVisible(this.lvlBtnAbility_array[val2++],this.lvlBtnAbility_array[val2++],val1,this.lvlBtnAbility_array[val2++]);
				}
			}
			val2 = 0;
			while(val2 < this.lvlBtnTalent_array.length)
			{
				this.mainpanel_mc.stats_mc.talents_mc.setBtnVisible(this.lvlBtnTalent_array[val2],this.lvlBtnTalent_array[val2 + 1],this.lvlBtnTalent_array[val2 + 2]);
				val2 = val2 + 3;
			}
			if(this.ability_array.length > 0)
			{
				this.mainpanel_mc.stats_mc.combatAbilities_mc.updateDone();
				this.mainpanel_mc.stats_mc.civilAbilities_mc.updateDone();
			}
			if(this.tags_array.length > 0)
			{
				this.mainpanel_mc.stats_mc.tags_mc.updateDone();
			}
			if(this.talent_array.length > 0)
			{
				this.mainpanel_mc.stats_mc.talents_mc.updateDone();
			}
			this.clearCustomStats();
			if(this.customStats_array.length > 0)
			{
				val2 = 0;
				while(val2 < this.customStats_array.length)
				{
					val5 = Number(this.customStats_array[val2 + 0]);
					val6 = String(this.customStats_array[val2 + 1]);
					val7 = String(this.customStats_array[val2 + 2]);
					this.addCustomStat(val5,val6,val7);
					val2 = val2 + 3;
				}
				this.mainpanel_mc.stats_mc.customStats_mc.updateDone();
			}
			this.mainpanel_mc.stats_mc.currentPanel.updateHints();
			this.ability_array = new Array();
			this.infoStat_array = new Array();
			this.talent_array = new Array();
			this.tags_array = new Array();
			this.lvlBtnStat_array = new Array();
			this.lvlBtnAbility_array = new Array();
			this.lvlBtnTalent_array = new Array();
			this.customStats_array = new Array();
			this.initDone = true;
			ExternalInterface.call("characterSheetUpdateDone");
		}
		
		public function setAmountOfPlayers(param1:Number) : *
		{
		}
		
		public function addAbility(param1:Boolean, param2:Number, param3:Number, param4:String, param5:String, param6:uint) : *
		{
			if(param1)
			{
				this.mainpanel_mc.stats_mc.civilAbilities_mc.addAbility(param2,param3,param4,param5,param6);
			}
			else
			{
				this.mainpanel_mc.stats_mc.combatAbilities_mc.addAbility(param2,param3,param4,param5,param6);
			}
		}
		
		public function removeAbilities() : *
		{
			this.mainpanel_mc.stats_mc.civilAbilities_mc.removeStats();
			this.mainpanel_mc.stats_mc.combatAbilities_mc.removeStats();
		}
		
		public function addAbilityGroup(param1:Boolean, param2:Number, param3:String) : *
		{
			if(param1)
			{
				this.mainpanel_mc.stats_mc.civilAbilities_mc.addAbilityGroup(param2,param3);
			}
			else
			{
				this.mainpanel_mc.stats_mc.combatAbilities_mc.addAbilityGroup(param2,param3);
			}
		}
		
		public function addTalent(id:Number, displayName:String, state:Number) : *
		{
			this.mainpanel_mc.stats_mc.talents_mc.addTalent(id,displayName,state);
		}

		public function addCustomTalent(id:String, displayName:String, state:Number) : *
		{
			this.mainpanel_mc.stats_mc.talents_mc.addCustomTalent(id,displayName,state);
		}
		
		public function removeTalents() : *
		{
			this.mainpanel_mc.stats_mc.talents_mc.removeStats();
		}
		
		public function addTag(param1:String, param2:String, param3:Number, param4:Number, param5:Number) : *
		{
			this.mainpanel_mc.stats_mc.tags_mc.addTag(param1,param2,param3,param4,param5);
			this.mainpanel_mc.stats_mc.setTagsTabVis(true);
		}
		
		public function addCustomStat(param1:Number, param2:String, param3:String) : *
		{
			this.mainpanel_mc.stats_mc.customStats_mc.addStat(param1,param2,param3);
		}
		
		public function clearCustomStats() : *
		{
			this.mainpanel_mc.stats_mc.customStats_mc.removeStats();
		}
		
		public function clearTags() : *
		{
			this.mainpanel_mc.stats_mc.tags_mc.removeStats();
			this.mainpanel_mc.stats_mc.setTagsTabVis(false);
		}
		
		public function addStatsTab(param1:Number, param2:Number, param3:String) : *
		{
			this.mainpanel_mc.stats_mc.tabBar_mc.addTab(param1,param2,param3);
		}
		
		public function removeStatsTabs() : *
		{
			this.mainpanel_mc.stats_mc.tabBar_mc.removeTabs();
		}
		
		public function selectStatsTab(param1:Number) : *
		{
			this.mainpanel_mc.stats_mc.tabBar_mc.selectTab(param1);
		}
		
		public function setMainInfoStats(param1:String, param2:String, param3:String) : *
		{
			this.mainpanel_mc.hp_txt.htmlText = param1;
			this.mainpanel_mc.ap_txt.htmlText = param2;
			this.mainpanel_mc.rep_txt.htmlText = param3;
		}
		
		public function setAttribute(param1:Number, param2:String, param3:Boolean = false, param4:Boolean = false, param5:uint = 0) : *
		{
			this.mainpanel_mc.stats_mc.attributes_mc.setAttribute(param1,param2,param3,param4,param5);
		}
		
		public function setAttributeLabel(param1:Number, param2:String) : *
		{
			this.mainpanel_mc.stats_mc.attributes_mc.setAttributeLabel(param1,param2);
		}
		
		public function setActionsDisabled(param1:Boolean) : *
		{
		}
		
		public function startsWith(param1:String, param2:String) : Boolean
		{
			param1 = param1.toLowerCase();
			param2 = param2.toLowerCase();
			return param2 == param1.substr(0,param2.length);
		}
		
		private function frame1() : *
		{
			this.events = new Array("IE UIUp","IE UIDown","IE UILeft","IE UIRight","IE UIRemovePoints","IE UIAddPoints","IE UIAccept","IE UICancel","IE UITabPrev","IE UITabNext","IE UIShowTooltip","IE UITooltipUp","IE UITooltipDown","IE UIBack");
			this.layout = "fixed";
			this.alignment = "none";
			this.isDragging = false;
			this.curTooltip = -1;
			this.hasTooltip = false;
			this.invCellSize = 94;
			this.invCellSpacing = 2;
			this.invBgDiscrap = -1;
			this.invRows = 7;
			this.invCols = 8;
			this.charIconW = 80;
			this.charIconH = 100;
			this.ability_array = new Array();
			this.tags_array = new Array();
			this.talent_array = new Array();
			this.infoStat_array = new Array();
			this.lvlBtnAbility_array = new Array();
			this.lvlBtnStat_array = new Array();
			this.lvlBtnTalent_array = new Array();
			this.customStats_array = new Array();
			this.tooltipArray = new Array();
			this.text_array = new Array(null,null,this.mainpanel_mc.stats_mc.attributes_mc.pointsLabel_txt,this.mainpanel_mc.stats_mc.combatAbilities_mc.pointsLabel_txt,this.mainpanel_mc.stats_mc.civilAbilities_mc.pointsLabel_txt,this.mainpanel_mc.stats_mc.talents_mc.pointsLabel_txt,this.mainpanel_mc.stats_mc.info_mc.currentXpStr_txt,this.mainpanel_mc.stats_mc.info_mc.nextXpStr_txt,this.mainpanel_mc.stats_mc.info_mc.levelStr_txt,this.mainpanel_mc.stats_mc.info_mc.level_txt,this.mainpanel_mc.stats_mc.info_mc.nextLevel_txt,this.mainpanel_mc.stats_mc.info_mc.noStatus_txt,this.mainpanel_mc.stats_mc.info_mc.statusEffect_txt,this.mainpanel_mc.stats_mc.info_mc.attrPointsLabel_txt,this.mainpanel_mc.stats_mc.info_mc.combatAbilPointsLabel_txt,this.mainpanel_mc.stats_mc.info_mc.civilAbilPointsLabel_txt,this.mainpanel_mc.stats_mc.info_mc.tallPointsLabel_txt);
			this.initDone = false;
			this.hasCanceled = false;
			this.tooltipTw = null;
			this.status_array = new Array();
			this.oldId = -1;
		}
	}
}
