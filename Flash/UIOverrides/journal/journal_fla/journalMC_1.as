package journal_fla
{
	import LS_Classes.horizontalList;
	import LS_Classes.listDisplay;
	import LS_Classes.scrollList;
	import LS_Classes.scrollListGrouped;
	import LS_Classes.textHelpers;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class journalMC_1 extends MovieClip
	{
		public var bg_mc:MovieClip;
		public var close_mc:MovieClip;
		public var container_mc:empty;
		public var dialogLogContainer_mc:empty;
		public var infoContainer_mc:MovieClip;
		public var journalContainer_mc:empty;
		public var leftJournalBtn_mc:stateButton;
		public var mapName_txt:TextField;
		public var map_mc:MovieClip;
		public var onMapBtn_mc:button;
		public var paperTop_mc:MovieClip;
		public var postponeBtn_mc:button;
		public var rightJournalBtn_mc:stateButton;
		public var showPostponed_mc:MovieClip; //CheckBoxWlabel
		public var tabHolder_mc:empty;
		public var tutorialContainer_mc:tutorialHolder_34;
		public const cLineHeight:Number = 30;
		public const cSbOffset:Number = -5;
		public const cListTopSpacing:Number = 30;
		public const cScrollSpeed:Number = 60.0;
		public const cSbYOffset:Number = -4;
		public const cMaxLines:Number = 20;
		public const tutEntryDeselectColour:uint = 0;
		public const tutDeselectColour:uint = 7346462;
		public const tutSelectColour:uint = 23424;
		public var selectedCompID:Number;
		public var totalHeight:Number;
		public var maxWidth:Number;
		public var WidthSpacing:Number;
		public var HeightSpacing:Number;
		public var minWidth:Number;
		public var root_mc:MovieClip;
		public var scrollPlaneLWidth:Number;
		public var scrollPlaneRWidth:Number;
		public var scrollPlaneHeight:Number;
		public var openedQuest:MovieClip;
		public var openedDialog:MovieClip;
		public var questSelectedId:String;
		public var postponeBtnText:Array;
		public const RListHeightDisc:Number = 10;
		public const scrollbarSize:Number = 404;
		public const cqSbYOffset:Number = 160;
		public var activeList:scrollList;
		public var closedList:scrollList;
		public var journalList:scrollList;
		public const cInfoListY:Number = 40;
		public var infoList:scrollList;
		public var dialogList:scrollList;
		public var tutorialList:scrollListGrouped;
		public var tabList:horizontalList;
		public var currentList:listDisplay;
		public var tooltipBtn_array:Array;
		public var isAvatar:Boolean;
		public var lastDialog:MovieClip;
		public var dialogColours:Array;
		
		public function journalMC_1()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onSelectTut(param1:Event) : *
		{
			this.tutorialContainer_mc.showSelected(this.tutorialList.getCurrentMovieClip());
		}
		
		public function setBtnTooltip(param1:Number, param2:String) : *
		{
			if(param1 >= 0 && param1 < this.tooltipBtn_array.length)
			{
				this.tooltipBtn_array[param1].tooltip = param2;
			}
		}
		
		public function nextEl() : *
		{
			this.journalList.next();
		}
		
		public function prevEl() : *
		{
			this.journalList.previous();
		}
		
		public function addTutorialEntry(gName:String, id:Number, title:String, description:String, tooltip:String = "") : *
		{
			var entry_mc:MovieClip = null;
			var group_mc:MovieClip = this.tutorialList.getElementByString("gName",gName);
			if(group_mc == null)
			{
				group_mc = this.addTutorialCategory(this.tutorialList.length + 1,gName);
			}
			if(group_mc != null)
			{
				entry_mc = this.addTutorialEntryINT(group_mc.groupId,id,title,description,tooltip);
				if(this.tutorialList.length == 1 && group_mc.list.length == 1)
				{
					group_mc.setOpen(true);
					this.tutorialList.selectMC(entry_mc);
				}
			}
		}
		
		public function addTutorialCategory(groupId:Number, title:String, tooltip:String = "") : MovieClip
		{
			var group_mc:MovieClip = this.tutorialList.addGroup(groupId,title,false);
			if(group_mc != null)
			{
				group_mc.init();
				group_mc.title_txt.autoSize = TextFieldAutoSize.LEFT;
				group_mc.heightOverride = this.tutorialList.m_myInterlinie;
				group_mc.gName = title;
				group_mc.tooltip = tooltip;
				group_mc.list.EL_SPACING = 0;
				group_mc.list.TOP_SPACING = 0;
				group_mc.list.m_customElementHeight = this.tutorialList.m_myInterlinie;
				group_mc.entryHeight = this.tutorialList.m_myInterlinie;
				group_mc.listOffset = this.cLineHeight;
				group_mc.deselectColour = this.tutDeselectColour;
				group_mc.selectColour = this.tutDeselectColour;
				group_mc.setTextColor(this.tutDeselectColour);
				return group_mc;
			}
			return null;
		}
		
		public function addTutorialEntryINT(groupId:Number, id:Number, title:String, description:String, tooltip:String = "") : MovieClip
		{
			var entry_mc:MovieClip = this.getTutorialEntry(groupId,id);
			if(entry_mc == null)
			{
				entry_mc = new TutorialEntry();
				entry_mc.Init();
				entry_mc.title_txt.autoSize = TextFieldAutoSize.LEFT;
				entry_mc.id = id;
				entry_mc.title_txt.htmlText = title;
				entry_mc.titleStr = title;
				entry_mc.descStr = description;
				entry_mc.tooltip = tooltip;
				entry_mc.mainlist = this.tutorialList;
				entry_mc.deselectColour = this.tutEntryDeselectColour;
				entry_mc.selectColour = this.tutSelectColour;
				entry_mc.setTextColor(this.tutEntryDeselectColour);
				this.tutorialList.addGroupElement(groupId,entry_mc,false);
			}
			return entry_mc;
		}
		
		public function getTutorialEntry(groupId:Number, id:Number) : MovieClip
		{
			var group_mc:MovieClip = this.tutorialList.getElementByNumber("groupId",groupId);
			if(group_mc)
			{
				return group_mc.list.getElementByNumber("id",id);
			}
			return null;
		}
		
		public function tutorialUpdateDone() : *
		{
			this.tutorialList.positionElements();
			ExternalInterface.call("tutorialUpdateDone");
		}
		
		public function clearTutorials() : *
		{
			this.tutorialList.clearElements();
		}
		
		public function addTab(id:Number, funcId:Number, label:String, isActive:Boolean) : *
		{
			var tab_mc:MovieClip = new tabBtn();
			if(tab_mc)
			{
				tab_mc.SND_Click = "UI_Gen_BigButton_Click";
				tab_mc.textInActiveAlpha = 1;
				tab_mc.m_AllowToggleActive = false;
				tab_mc.textActiveAlpha = 1;
				tab_mc.id = id;
				tab_mc.funcId = funcId;
				tab_mc.initialize(label,this.selectClickedTab,tab_mc,isActive);
				this.tabList.addElement(tab_mc);
				if(isActive)
				{
					this.tabList.selectMC(tab_mc);
				}
			}
		}
		
		public function setTabEnabled(id:Number, enabled:Boolean) : *
		{
			var tab_mc:MovieClip = this.tabList.getElementByNumber("id",id);
			if(tab_mc)
			{
				tab_mc.setEnabled(enabled);
			}
		}
		
		public function selectTab(param1:uint) : *
		{
			var val2:MovieClip = this.tabList.getElementByNumber("id",param1);
			this.selectClickedTab(val2);
		}
		
		public function selectClickedTab(param1:MovieClip) : *
		{
			this.tabList.getCurrentMovieClip().setActive(false);
			this.tabList.selectMC(param1);
			param1.setActive(true);
			this.infoContainer_mc.visible = false;
			if(this.tabList.getCurrentMovieClip() != param1)
			{
				this.dialogLogContainer_mc.visible = false;
				this.infoList.clearElements();
				this.infoContainer_mc.title_mc.visible = false;
				this.openedDialog = null;
			}
			if(param1.funcId == 0)
			{
				this.infoContainer_mc.visible = true;
				this.journalContainer_mc.visible = true;
				this.journalList.mouseWheelWhenOverEnabled = true;
				this.currentList = this.journalList;
				this.leftJournalBtn_mc.visible = true;
				this.rightJournalBtn_mc.visible = true;
				this.paperTop_mc.visible = true;
				this.onMapBtn_mc.visible = this.postponeBtn_mc.visible = this.showPostponed_mc.visible = this.rightJournalBtn_mc.visible && !this.rightJournalBtn_mc.isActive;
				this.toggleQuest(this.openedQuest,true,false);
			}
			else
			{
				this.journalContainer_mc.visible = false;
				this.journalList.mouseWheelWhenOverEnabled = false;
				this.leftJournalBtn_mc.visible = false;
				this.rightJournalBtn_mc.visible = false;
				this.paperTop_mc.visible = false;
				this.onMapBtn_mc.visible = this.postponeBtn_mc.visible = this.showPostponed_mc.visible = false;
			}
			if(param1.funcId == 3)
			{
				this.bg_mc.gotoAndStop(2);
				this.mapName_txt.visible = true;
				this.map_mc.visible = true;
				this.map_mc.mouseWheelEnabled = true;
				this.currentList = null;
			}
			else
			{
				this.mapName_txt.visible = false;
				this.map_mc.visible = false;
				this.map_mc.mouseWheelEnabled = false;
			}
			if(param1.funcId == 4)
			{
				this.infoContainer_mc.visible = true;
				this.dialogLogContainer_mc.visible = true;
				this.dialogList.mouseWheelWhenOverEnabled = true;
				this.currentList = this.dialogList;
			}
			else
			{
				this.dialogLogContainer_mc.visible = false;
				this.dialogList.mouseWheelWhenOverEnabled = false;
			}
			if(param1.funcId == 7)
			{
				this.tutorialContainer_mc.visible = true;
				this.tutorialList.mouseWheelWhenOverEnabled = true;
				this.currentList = this.tutorialList;
			}
			else
			{
				this.tutorialContainer_mc.visible = false;
				this.tutorialList.mouseWheelWhenOverEnabled = false;
			}
			if(this.map_mc.visible)
			{
				this.bg_mc.gotoAndStop(3);
			}
			else if(param1.funcId == 0)
			{
				this.bg_mc.gotoAndStop(1);
				if(this.bg_mc.btnBG_mc)
				{
					this.bg_mc.btnBG_mc.visible = this.onMapBtn_mc.visible;
				}
			}
			else
			{
				this.bg_mc.gotoAndStop(2);
			}
			ExternalInterface.call("PlaySound","UI_Game_Journal_Click");
			ExternalInterface.call("selectClickedTab",param1.id);
		}
		
		public function toggleDialog(param1:MovieClip, param2:Boolean = true) : *
		{
			var val3:uint = 0;
			var val4:String = null;
			if(param1)
			{
				if(this.openedDialog != param1 || param2)
				{
					this.infoList.clearElements();
					if(this.openedDialog != null)
					{
						this.openedDialog.setTextColour(18034);
					}
					this.infoContainer_mc.title_mc.subTitle_txt.htmlText = "";
					val3 = 0;
					while(val3 < param1.infolist.length)
					{
						this.infoList.addElement(param1.infolist.getAt(val3),false);
						val3++;
					}
					val4 = param1.title_mc.name_txt.htmlText;
					this.infoContainer_mc.title_mc.title_txt.htmlText = val4.toUpperCase();
					this.infoContainer_mc.title_mc.title_txt.textColor = 6881285;
					param1.setTextColour(6881285);
					this.openedDialog = param1;
					this.infoContainer_mc.title_mc.visible = true;
					this.infoContainer_mc.title_mc.setDeco();
					this.infoList.positionElements();
					this.infoPageResetLayout();
				}
				else
				{
					this.openedDialog.setTextColour(18034);
					this.openedDialog = null;
					this.infoList.clearElements();
					this.infoContainer_mc.title_mc.visible = false;
				}
			}
		}
		
		public function infoPageResetLayout() : *
		{
			var val1:int = 0;
			if(this.openedQuest && this.openedQuest.isMystery && !this.openedQuest.isCompleted)
			{
				val1 = 20;
				this.infoList.setFrame(this.scrollPlaneRWidth,this.scrollPlaneHeight + this.RListHeightDisc - 10 - this.infoContainer_mc.title_mc.subTitle_txt.textHeight - val1);
				this.infoList.y = this.cInfoListY + 14 + this.infoContainer_mc.title_mc.subTitle_txt.textHeight + val1;
				this.infoList.m_scrollbar_mc.y = this.cqSbYOffset - 2 - this.infoContainer_mc.title_mc.subTitle_txt.textHeight - val1;
				this.infoList.m_scrollbar_mc.setLength(this.scrollbarSize);
			}
			else
			{
				this.infoList.setFrame(this.scrollPlaneRWidth,this.scrollPlaneHeight + this.RListHeightDisc - 10);
				this.infoList.y = this.cInfoListY + 14;
				this.infoList.m_scrollbar_mc.y = this.cqSbYOffset - 2;
				this.infoList.m_scrollbar_mc.setLength(this.scrollbarSize);
			}
		}
		
		public function addDialog(id:Number, dateTime:Number, dateTimeStr:String, name:String, level:String) : *
		{
			var dialog_mc:MovieClip = new DialogEntry();
			if(dialog_mc)
			{
				dialog_mc.title_mc.name_txt.autoSize = TextFieldAutoSize.LEFT;
				dialog_mc.title_mc.level_txt.autoSize = TextFieldAutoSize.LEFT;
				dialog_mc.title_mc.dateTime_txt.autoSize = TextFieldAutoSize.LEFT;
				dialog_mc.id = id;
				dialog_mc.dateTime = dateTime;
				dialog_mc.title_mc.name_txt.htmlText = name;
				dialog_mc.title_mc.level_txt.htmlText = level;
				dialog_mc.title_mc.dateTime_txt.htmlText = dateTimeStr;
				dialog_mc.infolist = new listDisplay();
				dialog_mc.infolist.TOP_SPACING = this.cLineHeight;
				dialog_mc.infolist.EL_SPACING = 0;
				this.dialogList.addElement(dialog_mc,false);
				dialog_mc.speakerArray = new Array();
				dialog_mc.heightOverride = Math.round(dialog_mc.height / this.cLineHeight) * this.cLineHeight;
				if(this.lastDialog == null || this.lastDialog && this.lastDialog.dateTime < dialog_mc.dateTime)
				{
					this.lastDialog = dialog_mc;
				}
			}
		}
		
		public function addDialogLine(id:Number, speakerType:int, speakerName:String, text:String) : *
		{
			var val6:MovieClip = null;
			var val7:Number = NaN;
			var val5:MovieClip = this.dialogList.getElementByNumber("id",id);
			if(val5)
			{
				val6 = null;
				val7 = val5.infolist.length;
				if(val7 > 0)
				{
					val6 = val5.infolist.getAt(val7 - 1) as MovieClip;
					if(val6 != null && (speakerName != val6._speaker || speakerName == val6._speaker && speakerType != val6.speakerType))
					{
						val6 = null;
					}
				}
				if(val6 == null)
				{
					val6 = new DialogLine();
					val6.iline_txt.autoSize = val6.line_txt.autoSize = TextFieldAutoSize.LEFT;
					val6.iline_txt.width = val6.line_txt.width = this.scrollPlaneRWidth - 64;
					val6._speaker = speakerName;
					val6.speakerType = speakerType;
					val6.textStr = "\t" + speakerName + " - " + text;
					val5.infolist.addElement(val6,false);
				}
				else
				{
					val6.textStr = val6.textStr + (" " + text);
				}
				if(speakerType == 4)
				{
					val6.iline_txt.htmlText = "";
					textHelpers.setFormattedText(val6.iline_txt,val6.textStr);
					val6.iline_txt.textColor = 0;
				}
				else
				{
					textHelpers.setFormattedText(val6.line_txt,val6.textStr);
					val6.line_txt.textColor = this.getColourForSpeaker(speakerName,val5.speakerArray);
				}
				val6.heightOverride = Math.round(val6.height / this.cLineHeight) * this.cLineHeight;
			}
		}
		
		public function findIdInArray(param1:String, param2:Array) : Number
		{
			var val3:Number = -1;
			var val4:uint = 0;
			while(val4 < param2.length)
			{
				if(param1 == param2[val4])
				{
					val3 = val4;
					break;
				}
				val4++;
			}
			if(val3 == -1)
			{
				val3 = param2.length;
				param2.push(param1);
			}
			return val3;
		}
		
		public function getColourForSpeaker(param1:String, param2:Array) : uint
		{
			var val3:Number = this.findIdInArray(param1,param2);
			val3 = val3 % this.dialogColours.length;
			return this.dialogColours[val3];
		}
		
		public function dialogUpdateDone() : *
		{
			var val1:MovieClip = null;
			if(this.dialogList.length > 0)
			{
				this.dialogList.positionElements();
				for each(val1 in this.dialogList.content_array)
				{
					val1.infolist.positionElements();
				}
				if(this.lastDialog)
				{
					this.toggleDialog(this.lastDialog,true);
				}
			}
		}
		
		public function clearDialogs() : *
		{
			this.lastDialog = null;
			this.dialogList.clearElements();
		}
		
		public function clearQuests() : *
		{
			var val3:MovieClip = null;
			if(this.openedQuest)
			{
				this.openedQuest = null;
			}
			var val1:MovieClip = null;
			var val2:uint = 0;
			while(val2 < this.journalList.length)
			{
				val3 = this.journalList.getAt(val2);
				if(val3 && val3.filterName != this.root_mc.secretsFilterName)
				{
					val3.questList.clearElements();
				}
				else if(val3 && val3.filterName == this.root_mc.secretsFilterName)
				{
					val1 = val3;
				}
				val2++;
			}
			this.journalList.clearElements();
			this.infoList.clearElements();
			this.infoContainer_mc.title_mc.visible = false;
			if(val1 != null)
			{
				this.journalList.addElement(val1);
			}
		}
		
		public function loadQuests(param1:Boolean = false) : *
		{
			if(this.leftJournalBtn_mc.isActive != param1)
			{
				this.leftJournalBtn_mc.setActive(param1);
				this.onMapBtn_mc.visible = this.postponeBtn_mc.visible = this.showPostponed_mc.visible = param1;
				if(this.bg_mc.btnBG_mc)
				{
					this.bg_mc.btnBG_mc.visible = this.onMapBtn_mc.visible;
				}
				this.rightJournalBtn_mc.setActive(!param1);
				this.infoList.clearElements();
				this.infoContainer_mc.title_mc.visible = false;
				this.swapList(param1);
			}
		}
		
		public function swapList(param1:Boolean) : *
		{
			if(this.journalList)
			{
				this.journalContainer_mc.removeChild(this.journalList);
			}
			this.journalList = !!param1?this.activeList:this.closedList;
			if(this.bg_mc.btnBG_mc)
			{
				this.bg_mc.btnBG_mc.visible = Boolean(this.journalList == this.activeList);
			}
			this.journalContainer_mc.addChild(this.journalList);
			this.toggleQuest(this.openedQuest);
			if(this.journalList == this.closedList)
			{
				this.checkForCompletedQuests();
			}
			this.journalList.positionElements();
			this.openedQuest = null;
			this.questUpdateDone();
		}
		
		public function checkForCompletedQuests() : *
		{
			var val2:* = undefined;
			var val3:uint = 0;
			var val4:* = undefined;
			var val1:uint = 0;
			while(val1 < this.activeList.length)
			{
				val2 = this.activeList.getAt(val1);
				if(val2)
				{
					val3 = 0;
					while(val3 < val2.questList.length)
					{
						val4 = val2.questList.getAt(val3);
						if(val4 && val4.isCompleted && val4.isSeen)
						{
							this.setQuestComplete(val4.questId);
						}
						val3++;
					}
				}
				val1++;
			}
		}
		
		public function toggleQuest(param1:MovieClip, param2:Boolean = false, param3:Boolean = true) : *
		{
			var val4:uint = 0;
			var val5:String = null;
			var val6:String = null;
			var val7:MovieClip = null;
			var val8:uint = 0;
			var val9:MovieClip = null;
			this.infoList.clearElements();
			this.infoContainer_mc.title_mc.visible = false;
			if(param1)
			{
				val4 = 23424;
				if(this.openedQuest != param1 || param2)
				{
					if(this.openedQuest != null)
					{
						this.openedQuest.title_mc.img_mc.gotoAndStop(1);
						this.openedQuest.title_mc.name_txt.textColor = 0;
						this.openedQuest.flag_mc.gotoAndStop(1);
					}
					this.openedQuest = param1;
					this.infoContainer_mc.title_mc.visible = true;
					this.openedQuest.flag_mc.gotoAndStop(2);
					val5 = param1.title_mc.name_txt.htmlText;
					this.infoContainer_mc.title_mc.title_txt.htmlText = val5.toUpperCase();
					this.infoContainer_mc.title_mc.title_txt.textColor = 2555904;
					if(param1.isMystery && !param1.isCompleted)
					{
						this.infoContainer_mc.title_mc.subTitle_txt.htmlText = param1.questionStr;
					}
					else
					{
						this.infoContainer_mc.title_mc.subTitle_txt.htmlText = "";
					}
					if(param1.infolist.length > 0)
					{
						val7 = null;
						val8 = 0;
						while(val8 < param1.infolist.length)
						{
							val7 = param1.infolist.getAt(val8);
							if(val7)
							{
								val7.isNew = val7.isNew && !param1.isSeen;
								this.infoList.addElement(val7,false);
								val7.icon_mc.gotoAndStop(1);
							}
							val8++;
						}
						val7 = this.infoList.getFirstElement();
						if(val7)
						{
							val7.icon_mc.gotoAndStop(2);
						}
					}
					this.infoContainer_mc.title_mc.setDeco();
					param1.isSeen = true;
					param1.title_mc.img_mc.gotoAndStop(4);
					param1.title_mc.name_txt.textColor = val4;
					this.infoList.positionElements();
					val6 = "";
					val8 = 0;
					while(val8 < this.infoList.length)
					{
						val9 = this.infoList.getAt(val8);
						if(val9)
						{
							if(val9.objectiveID == val6)
							{
								if(val6 != "")
								{
									val9.setObjectiveStr("",false);
								}
							}
							else
							{
								val6 = val9.objectiveID;
								val9.setObjectiveStr(val9.objectiveStr,false);
							}
						}
						val8++;
					}
					this.infoList.positionElements();
					this.infoPageResetLayout();
					if(param3 && this.journalList == this.activeList)
					{
						ExternalInterface.call("questOpened",param1.questId);
						this.questSelectedId = param1.questId;
					}
					param1.filterCategory.expand(true);
				}
				else
				{
					this.openedQuest = null;
					param1.title_mc.img_mc.gotoAndStop(1);
					param1.title_mc.name_txt.textColor = 0;
				}
				this.onMapBtn_mc.setEnabled(this.journalList == this.activeList && param1.flag_mc.visible && !param1.isPostponed);
				this.postponeBtn_mc.setEnabled(param1.canPostpone);
				this.postponeBtn_mc.setText(!!param1.isPostponed?this.postponeBtnText[0]:this.postponeBtnText[1]);
			}
			else
			{
				this.onMapBtn_mc.setEnabled(false);
				this.postponeBtn_mc.setEnabled(false);
				this.postponeBtn_mc.setText(this.postponeBtnText[0]);
			}
		}
		
		public function GetFilter(param1:String, param2:Boolean, param3:Boolean = true) : MovieClip
		{
			var val4:scrollList = !!param2?this.closedList:this.activeList;
			var val5:MovieClip = val4.getElementByString("filterName",param1);
			if(!val5 && param3)
			{
				val5 = new questFilter();
				val5.selectable = false;
				val5.lineHeight = this.cLineHeight;
				val5.init(param1,val4);
				val5.name = "q" + param1 + "_mc";
				val4.addElement(val5);
			}
			return val5;
		}
		
		public function findQuest(param1:String) : MovieClip
		{
			var val2:MovieClip = this.findQuestInList(this.activeList,param1);
			if(!val2)
			{
				val2 = this.findQuestInList(this.closedList,param1);
			}
			return val2;
		}
		
		public function findQuestInList(param1:scrollList, param2:String) : MovieClip
		{
			var val3:MovieClip = null;
			var val4:MovieClip = null;
			for each(val3 in param1.content_array)
			{
				val4 = val3.questList.getElementByString("questId",param2);
				if(val4)
				{
					return val4;
				}
			}
			return null;
		}
		
		public function OnMapQuest() : *
		{
			ExternalInterface.call("showQuestOnMap",this.getCurrentQuestMarkerId());
		}
		
		public function getCurrentQuestMarkerId() : String
		{
			var val1:String = "";
			if(this.openedQuest)
			{
				val1 = this.openedQuest.getCurrentMarker();
			}
			return val1;
		}
		
		public function showPostponed() : *
		{
			ExternalInterface.call("showPostponed",this.showPostponed_mc.isActive);
		}
		
		public function addSubQuest(param1:String, param2:String, param3:String, param4:Boolean, param5:Boolean, param6:Boolean, param7:Number, param8:int) : *
		{
			var val10:MovieClip = null;
			var val11:String = null;
			var val9:MovieClip = this.findQuest(param1);
			if(val9 && !val9.isUpdated)
			{
				if(this.showPostponed_mc.isActive || !val9.isPostponed)
				{
					val9 = this.findQuestInList(this.closedList,param1);
				}
			}
			if(val9)
			{
				val10 = val9.subQuests.getElementByString("questId",param2);
				if(!val10)
				{
					val10 = new QuestEntry();
					val10.title_mc.name_txt.autoSize = TextFieldAutoSize.LEFT;
					val11 = param3.toUpperCase();
					val10.base = this;
					val10.entryHeight = this.cLineHeight;
					val10.onInit();
					val10.infolist.sortOn(["objectiveOrder","updateTime","id"],[Array.NUMERIC | Array.DESCENDING,Array.NUMERIC | Array.DESCENDING,Array.NUMERIC | Array.DESCENDING]);
					val10.filterCategory = val9.filterCategory;
					val10.isQuest = true;
					val10.questId = param2;
					val10.updateTime = param7;
					val10.priority = param8;
					val10.qName = param3;
					val10.title_mc.x = val10.subQuestIcon_mc.x + val10.subQuestIcon_mc.width + 3;
					val10.title_mc.hl_mc.x = -val10.title_mc.x;
					val10.title_mc.name_txt.width = 330;
					val9.subQuests.addElement(val10,false);
				}
				val10.title_mc.img_mc.gotoAndStop(!!param5?5:1);
				val10.title_mc.name_txt.htmlText = param3;
				val10.isPostponed = param6;
				val10.alpha = !!param6?Number(0.5):Number(1);
				val10.isUpdated = true;
				val10.isCompleted = param4;
				if(param4)
				{
					val10.title_mc.name_txt.htmlText = val10.title_mc.name_txt.htmlText + (" (" + this.root_mc.questCompletedLabel + ")");
					val10.refreshLocationIcon();
					val10.title_mc.img_mc.gotoAndStop(1);
					val10.title_mc.name_txt.textColor = 0;
				}
				if(param5)
				{
					val10.startAnim();
				}
			}
		}
		
		public function addQuest(param1:String, param2:String, param3:String, param4:int, param5:String, param6:Boolean, param7:Boolean, param8:Boolean, param9:Number, param10:int, param11:Boolean) : *
		{
			var val13:MovieClip = null;
			var val12:MovieClip = this.GetFilter(param3,param6);
			if(val12)
			{
				val12.priority = param4;
				val13 = val12.questList.getElementByString("questId",param1);
				if(val13 == null)
				{
					val13 = new QuestEntry();
					val13.flag_mc.visible = false;
					val13.filterCategory = val12;
					val13.logType = "quest";
					val13.entryHeight = this.cLineHeight;
					val13.onInit();
					val13.infolist.sortOn(["objectiveOrder","updateTime","id"],[Array.NUMERIC | Array.DESCENDING,Array.NUMERIC | Array.DESCENDING,Array.NUMERIC | Array.DESCENDING]);
					val13.questId = param1;
					val13.name = param1 + "_mc";
					val13.title_mc.name_txt.autoSize = TextFieldAutoSize.LEFT;
					val13.subQuestIcon_mc.visible = false;
					val13.updateTime = 0;
					val13.subQuests = new listDisplay();
					val13.subQuests.EL_SPACING = 0;
					val13.addChild(val13.subQuests);
					val12.questList.addElement(val13,false);
				}
				if(param7)
				{
					val12.expand(true);
				}
				val13.priority = param10;
				val13.canPostpone = param11 && !param6;
				val13.isPostponed = !param6 && param8;
				val13.isSeen = !param7;
				val13.updateTime = param9;
				val13.isUpdated = this.showPostponed_mc.isActive || !param8;
				val13.isCompleted = param6;
				val13.title_mc.hl_mc.visible = false;
				val13.title_mc.img_mc.gotoAndStop(!!param7?5:1);
				val13.title_mc.name_txt.htmlText = param5;
				if(param6)
				{
					val13.title_mc.name_txt.htmlText = val13.title_mc.name_txt.htmlText + (" (" + this.root_mc.questCompletedLabel + ")");
					val13.title_mc.img_mc.gotoAndStop(1);
					val13.title_mc.name_txt.textColor = 0;
				}
				val13.subQuests.y = val13.title_mc.y + val13.title_mc.name_txt.y + val13.title_mc.name_txt.textHeight - 2;
				val13.qName = param5;
			}
		}
		
		public function addMystery(param1:String, param2:String, param3:String, param4:Boolean, param5:Boolean, param6:String, param7:String) : *
		{
			var val9:MovieClip = null;
			var val8:MovieClip = this.GetFilter(param2.toUpperCase(),param4);
			if(val8)
			{
				val8.priority = int.MAX_VALUE;
				val9 = val8.questList.getElementByString("questId",param1);
				if(val9 == null)
				{
					val9 = new QuestEntry();
					val9.filterCategory = val8;
					val9.logType = "quest";
					val9.entryHeight = this.cLineHeight;
					val9.isMystery = true;
					val9.onInit();
					val9.infolist.sortOn(["objectiveOrder","updateTime","id"],[Array.NUMERIC | Array.DESCENDING,Array.NUMERIC | Array.DESCENDING,Array.NUMERIC | Array.DESCENDING]);
					val9.questId = param1;
					val9.name = param1 + "_mc";
					val9.title_mc.name_txt.autoSize = TextFieldAutoSize.LEFT;
					val9.subQuestIcon_mc.visible = false;
					val9.updateTime = 0;
					val9.flag_mc.visible = false;
					val8.questList.addElement(val9,false);
					if(param4)
					{
						this.addQuestAction(true,"",param1,"",-1,"",0,param7,"",0,"");
					}
				}
				if(param5)
				{
					val8.expand(true);
				}
				val9.questionStr = param6;
				val9.completeStr = param7;
				val9.priority = 0;
				val9.canPostpone = false;
				val9.isPostponed = false;
				val9.isSeen = !param5;
				val9.updateTime = 0;
				val9.isUpdated = true;
				val9.isCompleted = param4;
				val9.title_mc.hl_mc.visible = false;
				val9.title_mc.img_mc.gotoAndStop(!!param5?5:1);
				val9.title_mc.name_txt.htmlText = param3;
				if(param4)
				{
					val9.title_mc.name_txt.htmlText = val9.title_mc.name_txt.htmlText + (" (" + this.root_mc.questCompletedLabel + ")");
				}
				val9.qName = param3;
			}
		}
		
		public function PostponeQuest() : *
		{
			ExternalInterface.call("postponeQuest",this.openedQuest.questId,this.openedQuest.isPostponed);
		}
		
		public function setQuestComplete(param1:String) : *
		{
			var val3:MovieClip = null;
			var val4:MovieClip = null;
			var val2:MovieClip = this.findQuestInList(this.activeList,param1);
			if(val2 != null && !val2.finalUpdateSeen)
			{
				val2.finalUpdateSeen = true;
				val3 = this.GetFilter(val2.filterCategory.filterName,false);
				if(val3)
				{
					val3.questList.removeElement(val2.list_pos,true);
					val3.calculateHeight();
					val3.visible = val3.questList.length > 0;
					val3 = this.GetFilter(val2.filterCategory.filterName,true);
					val4 = val3.questList.getElementByString("questId",val2.questId);
					if(!val4)
					{
						if(val2.isMystery)
						{
							this.addQuestAction(true,"",val2.questId,"",-1,"",0,val2.completeStr,"",0,"");
						}
						val2.flag_mc.visible = false;
						val2.isCompleted = true;
						val3.questList.addElement(val2,true);
						val3.calculateHeight();
						val2.filterCategory = val3;
						this.journalList.positionElements();
					}
				}
			}
		}
		
		public function addQuestAction(param1:Boolean, param2:String, param3:String, param4:String, param5:int, param6:String, param7:Number, param8:String, param9:String, param10:Number = 0, param11:String = "") : *
		{
			var val12:MovieClip = null;
			var val13:MovieClip = null;
			if(param2 == "")
			{
				val12 = this.findQuest(param3);
			}
			else
			{
				val13 = this.findQuest(param2);
				if(val13)
				{
					val12 = val13.subQuests.getElementByString("questId",param3);
				}
			}
			if(val12)
			{
				this.int_addQuestAction(param1,param2,val12,param4,param5,param6,param7,param8,param9,param10,param11);
			}
		}
		
		public function int_addQuestAction(param1:Boolean, param2:String, param3:MovieClip, param4:String, param5:int, param6:String, param7:Number, param8:String, param9:String, param10:Number = 0, param11:String = "") : *
		{
			var val12:MovieClip = null;
			if(param3 != null)
			{
				val12 = param3.infolist.getElementByNumber("id",param7);
				if(val12 == null)
				{
					val12 = new QuestAction();
					val12.mysteryIcon_mc.visible = param1;
					val12.id = param7;
					val12.dateNr = param10;
					val12.name_txt.autoSize = TextFieldAutoSize.LEFT;
					val12.objective_txt.autoSize = TextFieldAutoSize.LEFT;
					val12.icon_mc.gotoAndStop(1);
					param3.infolist.addElement(val12,false);
					val12.markerID = param11;
					val12.cLineHeight = this.cLineHeight;
					if(param11 == "")
					{
						val12.markerList = new Array();
					}
					else
					{
						val12.markerList = param11.split(";");
					}
				}
				val12.text = param8;
				if(param5 == -1)
				{
					param5 = int.MAX_VALUE;
				}
				val12.objectiveOrder = param5;
				val12.objectiveID = param4;
				val12.setObjectiveStr(param6);
				val12.name_txt.htmlText = param8;
				if(param10 > param3.updateTime)
				{
					param3.updateTime = param10;
				}
			}
		}
		
		public function fixOffset(param1:Number, param2:Number) : Number
		{
			return Math.ceil(param1 / param2) * param2;
		}
		
		public function strReplace(param1:String, param2:String, param3:String) : String
		{
			return param1.split(param2).join(param3);
		}
		
		public function questAddingDone() : *
		{
			var val1:MovieClip = null;
			for each(val1 in this.journalList.content_array)
			{
				if(val1)
				{
					val1.questList.cleanUpElements();
				}
			}
			this.journalList.positionElements();
		}
		
		public function questUpdateDone() : *
		{
			var val2:MovieClip = null;
			var val3:MovieClip = null;
			var val4:MovieClip = null;
			var val5:MovieClip = null;
			var val6:MovieClip = null;
			this.journalContainer_mc.visible = true;
			var val1:Boolean = false;
			for each(val2 in this.journalList.content_array)
			{
				if(val2)
				{
					for each(val3 in val2.questList.content_array)
					{
						if(val3)
						{
							val3.visible = this.showPostponed_mc.isActive || !val3.isPostponed;
							if(val3.visible)
							{
								if(!val1 && val3.subQuests && val3.subQuests.length > 0)
								{
									val4 = val3.subQuests.getElementByString("questId",this.questSelectedId);
									if(val4)
									{
										if(this.openedQuest == null)
										{
											this.openedQuest = val4;
										}
										val1 = true;
									}
								}
								if(!val1 && this.questSelectedId == val3.questId)
								{
									if(this.openedQuest == null)
									{
										this.openedQuest = val3;
									}
									val1 = true;
								}
							}
							if(!val3.isMystery)
							{
								if(val3.subQuests && val3.subQuests.length > 0)
								{
									for each(val5 in val3.subQuests.content_array)
									{
										val5.infolist.positionElements();
										if(!val5.isMystery)
										{
											val5.refreshLocationIcon();
										}
									}
								}
							}
							val3.infolist.positionElements();
							if(!val3.isMystery)
							{
								val3.refreshLocationIcon();
							}
						}
					}
					val2.questList.positionElements();
					val2.visible = val2.questList.visibleLength > 0;
					val2.calculateHeight();
				}
			}
			this.journalList.positionElements();
			if(!val1)
			{
				val6 = this.journalList.getFirstVisible();
				if(val6)
				{
					this.openedQuest = val6.questList.getFirstElement();
				}
			}
			if(this.openedQuest)
			{
				this.toggleQuest(this.openedQuest,true,!val1);
			}
			else
			{
				this.infoList.clearElements();
				this.infoContainer_mc.title_mc.visible = false;
			}
		}
		
		public function getFirstJournalEntry(param1:Boolean) : MovieClip
		{
			var val3:MovieClip = null;
			var val4:uint = 0;
			var val5:* = undefined;
			var val2:uint = 0;
			while(val2 < this.journalList.length)
			{
				val3 = this.journalList.getAt(val2);
				if(val3)
				{
					val4 = 0;
					while(val4 < val3.questList.length)
					{
						val5 = val3.questList.getAt(val4);
						if(val5)
						{
							if(val5.isPostponed == param1)
							{
								return val5;
							}
						}
						val4++;
					}
				}
				val2++;
			}
			return null;
		}
		
		public function setPersonalTrait(param1:Number, param2:String, param3:String, param4:Number) : *
		{
		}
		
		public function clearPersonalTraits() : *
		{
		}
		
		public function moveCursor(param1:Boolean) : *
		{
			if(this.currentList)
			{
				if(this.currentList == this.journalList)
				{
					return;
				}
				if(param1)
				{
					this.currentList.previous();
				}
				else
				{
					this.currentList.next();
				}
				this.setListLoopable(false);
			}
		}
		
		public function setListLoopable(param1:Boolean) : *
		{
			if(this.currentList)
			{
				this.currentList.m_cyclic = param1;
			}
		}
		
		public function setCursorPositionMC(param1:MovieClip) : *
		{
			if(this.currentList)
			{
				if(param1)
				{
					this.currentList.selectMC(param1);
				}
				else
				{
					this.currentList.clearSelection();
				}
			}
		}
		
		public function executeSelected() : *
		{
			var val1:MovieClip = null;
			if(this.currentList)
			{
				val1 = this.currentList.getCurrentMovieClip();
				if(val1 && val1.onUp)
				{
					val1.onUp(null);
				}
			}
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
		
		public function addIggyIcon(param1:MovieClip, param2:String) : *
		{
			var val3:MovieClip = null;
			if(param2 != param1.texture)
			{
				this.removeChildrenOf(param1);
				val3 = new IggyIcon();
				val3.name = "iggy_" + param2;
				param1.texture = param2;
				param1.addChild(val3);
			}
		}
		
		public function resizeToContent() : *
		{
			this.journalList.m_scrollbar_mc.scrollToFit();
		}
		
		private function frame1() : *
		{
			this.selectedCompID = 0;
			this.totalHeight = 0;
			this.maxWidth = 0;
			this.WidthSpacing = 80;
			this.HeightSpacing = 10;
			this.minWidth = 400;
			this.root_mc = root as MovieClip;
			this.scrollPlaneLWidth = 400;
			this.scrollPlaneRWidth = 760;
			this.scrollPlaneHeight = 724;
			this.openedDialog = null;
			this.activeList = new scrollList("down2_id","up2_id","handle2_id","scrollBg2_id");
			this.activeList.setFrame(this.scrollPlaneLWidth,this.scrollPlaneHeight);
			this.activeList.containerBG_mc.x = 20;
			this.activeList.y = 35;
			this.activeList.x = 0;
			this.activeList.EL_SPACING = this.cLineHeight;
			this.activeList.m_allowKeepIntoView = false;
			this.activeList.m_scrollbar_mc.m_hideWhenDisabled = true;
			this.activeList.SB_SPACING = -(this.scrollPlaneLWidth + 49);
			this.activeList.m_scrollbar_mc.y = this.cqSbYOffset;
			this.activeList.m_scrollbar_mc.m_SCROLLSPEED = this.cLineHeight;
			this.activeList.m_scrollbar_mc.setLength(this.scrollbarSize);
			this.activeList.m_scrollbar_mc.ScaleBG = true;
			this.activeList.sortOn(["priority","updateTime","filterName"],[Array.NUMERIC,Array.NUMERIC,Array.CASEINSENSITIVE]);
			this.activeList.m_cyclic = true;
			this.closedList = new scrollList("down2_id","up2_id","handle2_id","scrollBg2_id");
			this.closedList.setFrame(this.scrollPlaneLWidth,this.scrollPlaneHeight);
			this.closedList.containerBG_mc.x = 20;
			this.closedList.y = 35;
			this.closedList.x = 0;
			this.closedList.EL_SPACING = this.cLineHeight;
			this.closedList.m_allowKeepIntoView = false;
			this.closedList.m_scrollbar_mc.m_hideWhenDisabled = true;
			this.closedList.SB_SPACING = -(this.scrollPlaneLWidth + 49);
			this.closedList.m_scrollbar_mc.y = this.cqSbYOffset;
			this.closedList.m_scrollbar_mc.m_SCROLLSPEED = this.cLineHeight;
			this.closedList.m_scrollbar_mc.setLength(this.scrollbarSize);
			this.closedList.m_scrollbar_mc.ScaleBG = true;
			this.closedList.sortOn(["priority","updateTime","filterName"],[Array.NUMERIC,Array.NUMERIC,Array.CASEINSENSITIVE]);
			this.closedList.m_cyclic = true;
			this.journalList = this.activeList;
			this.journalContainer_mc.addChild(this.journalList);
			this.activeList.addEventListener(MouseEvent.ROLL_OVER,function():*
			{
				activeList.mouseWheelEnabled = true;
			});
			this.activeList.addEventListener(MouseEvent.ROLL_OUT,function():*
			{
				activeList.mouseWheelEnabled = false;
			});
			this.closedList.addEventListener(MouseEvent.ROLL_OVER,function():*
			{
				closedList.mouseWheelEnabled = true;
			});
			this.closedList.addEventListener(MouseEvent.ROLL_OUT,function():*
			{
				closedList.mouseWheelEnabled = false;
			});
			this.infoList = new scrollList("down2_id","up2_id","handle2_id","scrollBg2_id");
			this.infoList.EL_SPACING = this.cLineHeight;
			this.infoList.TOP_SPACING = this.cLineHeight;
			this.infoList.setFrame(this.scrollPlaneRWidth,this.scrollPlaneHeight + this.RListHeightDisc - 10);
			this.infoContainer_mc.addChild(this.infoList);
			this.infoList.y = this.cInfoListY + 14;
			this.infoList.x = 54;
			this.infoList.m_allowKeepIntoView = false;
			this.infoList.mouseWheelWhenOverEnabled = true;
			this.infoList.m_scrollbar_mc.m_hideWhenDisabled = true;
			this.infoList.SB_SPACING = this.scrollPlaneRWidth - 800;
			this.infoList.m_scrollbar_mc.y = this.cqSbYOffset - 2;
			this.infoList.m_scrollbar_mc.m_SCROLLSPEED = this.cLineHeight;
			this.infoList.m_scrollbar_mc.setLength(this.scrollbarSize);
			this.infoList.m_scrollbar_mc.ScaleBG = true;
			this.infoList.m_cyclic = true;
			this.dialogList = new scrollList("down2_id","up2_id","handle2_id","scrollBg2_id");
			this.dialogList.EL_SPACING = 0;
			this.dialogList.TOP_SPACING = 0;
			this.dialogList.setFrame(this.scrollPlaneLWidth,this.scrollPlaneHeight + this.RListHeightDisc);
			this.dialogList.sortOn(["dateTime","id"],[Array.NUMERIC | Array.DESCENDING,Array.NUMERIC]);
			this.dialogLogContainer_mc.addChild(this.dialogList);
			this.dialogLogContainer_mc.visible = false;
			this.dialogList.y = 49;
			this.dialogList.x = 30;
			this.dialogList.m_scrollbar_mc.m_hideWhenDisabled = true;
			this.dialogList.SB_SPACING = -(this.scrollPlaneLWidth + 40);
			this.dialogList.m_scrollbar_mc.y = this.cqSbYOffset - 2;
			this.dialogList.m_scrollbar_mc.m_SCROLLSPEED = this.cLineHeight;
			this.dialogList.m_scrollbar_mc.setLength(this.scrollbarSize);
			this.dialogList.m_scrollbar_mc.ScaleBG = true;
			this.dialogList.m_cyclic = true;
			this.tutorialList = new scrollListGrouped("down2_id","up2_id","handle2_id","scrollBg2_id");
			this.tutorialList.EL_SPACING = 0;
			this.tutorialList.setGroupMC("TutCategory");
			this.tutorialList.TOP_SPACING = this.cListTopSpacing;
			this.tutorialList.setFrame(this.scrollPlaneLWidth,this.scrollPlaneHeight);
			this.tutorialContainer_mc.addChild(this.tutorialList);
			this.tutorialList.m_myInterlinie = this.cLineHeight;
			this.tutorialList.m_allowAutoScroll = true;
			this.tutorialList.groupedScroll = false;
			this.tutorialList.x = 0;
			this.tutorialList.y = 72;
			this.tutorialList.m_scrollbar_mc.m_hideWhenDisabled = true;
			this.tutorialList.SB_SPACING = -(this.scrollPlaneLWidth + 9);
			this.tutorialList.m_scrollbar_mc.y = this.cqSbYOffset + 25;
			this.tutorialList.m_scrollbar_mc.m_SCROLLSPEED = this.cLineHeight;
			this.tutorialList.m_scrollbar_mc.setLength(this.scrollbarSize);
			this.tutorialList.m_scrollbar_mc.ScaleBG = true;
			this.tutorialList.m_cyclic = true;
			this.showPostponed_mc.interactiveTextOnClick = false;
			this.tutorialList.addEventListener(Event.CHANGE,this.onSelectTut);
			this.mapName_txt.visible = false;
			this.map_mc.visible = false;
			this.tabList = new horizontalList();
			this.tabList.EL_SPACING = 60;
			this.tabList.m_forceDepthReorder = true;
			this.tabHolder_mc.addChild(this.tabList);
			this.currentList = this.journalList;
			this.tooltipBtn_array = new Array(this.map_mc.zoomInBtn,this.map_mc.zoomOutBtn);
			this.bg_mc.mouseEnabled = false;
			this.bg_mc.mouseChildren = false;
			this.isAvatar = false;
			this.lastDialog = null;
			this.dialogColours = new Array(0,6881285,17257,1529887);
		}
	}
}
