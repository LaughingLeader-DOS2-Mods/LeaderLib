package characterCreation_c_fla
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getDefinitionByName;
	
	public dynamic class MainTimeline extends MovieClip
	{
		public var CCPanel_mc:MovieClip;
		public var btnHints_mc:MovieClip;
		public var header_mc:MovieClip;
		public var letterB_mc:MovieClip;
		public var letterT_mc:MovieClip;
		public var portraits_mc:MovieClip;
		public var tooltipHolder_mc:empty;
		public var waiting_mc:MovieClip;
		public var canShowTooltip:Boolean;
		public var tooltipVisible:Boolean;
		public const btnHintSize:uint = 250;
		public const charIconHeight:uint = 100;
		public const charIconWidth:uint = 80;
		public const userIconHeight:uint = 38;
		public const userIconWidth:uint = 38;
		public const designResolution:Point = new Point(2120,1080);
		public const zeroXpoint:Number = 100;
		public const fixedContentSize:Point = new Point(300,150);
		public const iconSize:uint = 64;
		public const iconSpacing:uint = 25;
		public const maxNameChars:uint = 20;
		public const numberOfClassEdits:uint = 4;
		public const numberOfInstruments:uint = 4;
		public const chosenListCols:uint = 3;
		public const chosenListIconSize:uint = 64;
		public const chosenListSpacingH:uint = 25;
		public const chosenListSpacingV:uint = 25;
		public const dFont:Number = 0;
		public const hFont:Number = 0;
		public const alteredFont:Number = 35130;
		public const dFont2:Number = 16777215;
		public const hFont2:Number = 16777215;
		public const tutorialBoxLeftX:uint = 920;
		public const tutorialBoxLeftY:uint = 305;
		public const tutorialBoxRightX:uint = 1200;
		public const tutorialBoxRightY:uint = 305;
		public const tutorialBoxSPX:uint = 1370;
		public const tutorialBoxSPY:uint = 305;
		public var availableAttributePoints:uint;
		public var availableTalentPoints:uint;
		public var availableTagPoints:uint;
		public var availableAbilityPoints:uint;
		public var availableCivilPoints:uint;
		public var availableSkillPoints:uint;
		public var chosenInstrumentPrefix:String;
		public var attributeCap:int;
		public var combatAbilityCap:int;
		public var cibilAbilityCap:int;
		public var events:Array;
		public var layout:String;
		public var alignment:String;
		public var uiScaling:Number;
		public var screenWidth:uint;
		public var screenHeight:uint;
		public var buttonHints:Array;
		public var contentArray:Array;
		public var stepArray:Array;
		public var attributeArray:Array;
		public var abilityArray:Array;
		public var skillArray:Array;
		public var talentArray:Array;
		public var racialTalentArray:Array;
		public var tagArray:Array;
		public var racialTagArray:Array;
		public var tooltipArray:Array;
		public var playerArray:Array;
		public var isMaster:Boolean;
		public var isOrigin:Boolean;
		public var currentPanel:int;
		public var tooltipMC:MovieClip;
		public var g_playerId:Number;
		public var g_playerAmount:Number;
		public var g_isLeft:Boolean;
		public var shiftUI:Boolean;
		public var hackOffset:Number;
		public var enableOrigin:Boolean;
		public const portraitsXposDesigned:uint = 200;
		public var eatup:Boolean;
		public var textArray;

		//LeaderLib
		public var characterHandle:Number;
		//In case mods are still using this.
		public var charHandle:Number;
		
		public function MainTimeline()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onEventInit() : *
		{
			this.g_playerId = -1;
			this.g_playerAmount = -1;
			this.g_isLeft = false;
			this.CCPanel_mc.onInit(this);
			this.header_mc.onInit(this);
			this.btnHints_mc.onInit(this);
			this.isOrigin = false;
			var val1:Class = getDefinitionByName("tt_tooltipObj") as Class;
			this.tooltipMC = new val1();
			this.tooltipHolder_mc.addChild(this.tooltipMC);
			this.tooltipMC.visible = false;
			this.tooltipMC.tooltipH = 812;
			this.setLetterBoxVisibility(false,false);
			this.waiting_mc.visible = false;
			this.waiting_mc.waiting_txt.TextFieldAutoSize = TextFieldAutoSize.CENTER;
			this.waiting_mc.waiting_txt.multiline = this.waiting_mc.waiting_txt.wordWrap = false;
			this.portraits_mc.onInit();
			this.portraits_mc.visible = false;
			this.portraits_mc.hint_mc.visible = this.isMaster;
		}
		
		public function updatePortraits(param1:*) : *
		{
			this.portraits_mc.visible = !param1;
			this.portraits_mc.updatePortraits(this.playerArray);
			this.playerArray = new Array();
		}
		
		public function setVoiceChatVisibility(param1:int, param2:Boolean) : *
		{
			this.portraits_mc.SetVoiceChatVisibility(param1,param2);
		}
		
		public function setSaturation(param1:Number) : ColorMatrixFilter
		{
			var val2:Number = 0.212671;
			var val3:Number = 0.71516;
			var val4:Number = 0.072169;
			var val5:Number = param1 / 100 + 1;
			var val6:Number = 1 - val5;
			var val7:Number = val6 * val2;
			var val8:Number = val6 * val3;
			var val9:Number = val6 * val4;
			var val10:Array = new Array();
			val10 = val10.concat([val7 + val5,val8,val9,0,0]);
			val10 = val10.concat([val7,val8 + val5,val9,0,0]);
			val10 = val10.concat([val7,val8,val9 + val5,0,0]);
			val10 = val10.concat([0,0,0,1,0]);
			return new ColorMatrixFilter(val10);
		}
		
		public function setArmourState(param1:Number) : *
		{
			this.CCPanel_mc.appearance_mc.equip_mc.toggleState(param1);
		}
		
		public function setLetterBoxText(param1:String) : *
		{
			this.letterB_mc.text_txt.htmlText = param1;
		}
		
		public function setLetterBoxVisibility(param1:Boolean = false, param2:Boolean = false) : *
		{
			this.letterT_mc.visible = this.letterB_mc.visible = param1;
			this.CCPanel_mc.visible = this.btnHints_mc.visible = this.header_mc.visible = !param1;
			this.portraits_mc.visible = !param1 && !param2;
		}
		
		public function setAnchor(param1:Number, param2:* = true) : *
		{
			this.g_playerId = param1;
			ExternalInterface.call("registerAnchorId","characterCreation_c" + param1);
			ExternalInterface.call("setAnchor","center","splitscreen","center");
			this.g_isLeft = param2;
			this.INTSetPanelPos();
		}
		
		public function setAmountOfPlayers(param1:Number) : *
		{
			this.g_playerAmount = param1;
			this.INTSetPanelPos();
		}
		
		public function INTSetPanelPos() : *
		{
			var val3:Number = NaN;
			var val1:Number = Math.round((this.designResolution.x - (this.screenWidth - this.designResolution.x)) * 0.25);
			if(this.shiftUI)
			{
				this.hackOffset = this.screenWidth / 4;
			}
			else
			{
				this.hackOffset = 0;
			}
			var val2:Number = 400;
			if(this.g_playerAmount && !isNaN(this.g_playerAmount) && this.g_playerId && !isNaN(this.g_playerId) && this.g_playerId >= 0)
			{
				if(this.g_playerAmount > 1)
				{
					val3 = this.designResolution.x - val1;
					if(this.g_isLeft)
					{
						if(this.CCPanel_mc.isDetailsPanel(this.currentPanel))
						{
							this.CCPanel_mc.x = 779 + this.zeroXpoint + this.hackOffset;
						}
						else
						{
							this.CCPanel_mc.x = 477 + this.zeroXpoint + this.hackOffset;
						}
						this.header_mc.name_mc.x = 230 - this.hackOffset;
						this.CCPanel_mc.loreBox_mc.x = !!this.shiftUI?-383:453;
						this.letterT_mc.scrollRect = new Rectangle(0,0,val3,this.letterT_mc.height);
						this.letterB_mc.scrollRect = new Rectangle(0,0,val3,this.letterB_mc.height);
						this.letterT_mc.x = this.letterB_mc.x = 0;
					}
					else
					{
						if(this.CCPanel_mc.isDetailsPanel(this.currentPanel))
						{
							this.CCPanel_mc.x = 700 + this.zeroXpoint - this.hackOffset;
						}
						else
						{
							this.CCPanel_mc.x = 976 + this.zeroXpoint - this.hackOffset;
						}
						this.letterT_mc.x = this.letterB_mc.x = Math.round(val1);
						this.letterT_mc.scrollRect = new Rectangle(this.letterB_mc.x,0,val3,this.letterT_mc.height);
						this.letterB_mc.scrollRect = new Rectangle(this.letterB_mc.x,0,val3,this.letterB_mc.height);
						this.header_mc.name_mc.x = -230 + this.hackOffset;
						this.CCPanel_mc.loreBox_mc.x = !!this.shiftUI?453:-383;
					}
				}
				else
				{
					this.letterT_mc.scrollRect = this.letterB_mc.scrollRect = null;
					this.CCPanel_mc.x = 1292;
					this.header_mc.name_mc.x = 0;
					this.CCPanel_mc.loreBox_mc.x = -383;
					this.letterT_mc.x = this.letterB_mc.x = 0;
				}
			}
			this.setTooltipPos();
		}
		
		public function setTooltipPos() : *
		{
			var val1:Number = 197;
			var val2:Boolean = this.CCPanel_mc.isDetailsPanel(this.currentPanel);
			if(this.g_playerAmount > 1)
			{
				if(this.g_isLeft)
				{
					if(val2)
					{
						if(this.shiftUI)
						{
							this.tooltipHolder_mc.x = 0;
						}
						else
						{
							this.tooltipHolder_mc.x = this.CCPanel_mc.x + val1;
						}
						this.btnHints_mc.x = 980 + this.zeroXpoint;
						this.btnHints_mc.y = 1000;
					}
					else
					{
						this.tooltipHolder_mc.x = 927 + this.zeroXpoint;
						if(this.shiftUI)
						{
							this.tooltipHolder_mc.x = this.tooltipHolder_mc.x - 150;
						}
						this.btnHints_mc.x = 960 + this.zeroXpoint;
						this.btnHints_mc.y = 1024;
					}
				}
				else if(val2)
				{
					if(this.shiftUI)
					{
						this.tooltipHolder_mc.x = 998;
					}
					else
					{
						this.tooltipHolder_mc.x = this.CCPanel_mc.x + val1;
					}
					this.btnHints_mc.x = 938 + this.zeroXpoint;
					this.btnHints_mc.y = 1000;
				}
				else
				{
					this.tooltipHolder_mc.x = 584 + this.zeroXpoint;
					if(this.shiftUI)
					{
						this.tooltipHolder_mc.x = this.tooltipHolder_mc.x + 362;
					}
					this.btnHints_mc.x = 960 + this.zeroXpoint;
					this.btnHints_mc.y = 1024;
				}
			}
			else if(val2)
			{
				this.tooltipHolder_mc.x = this.CCPanel_mc.x + val1;
				this.btnHints_mc.x = 1410 + this.zeroXpoint;
				this.btnHints_mc.y = 1000;
			}
			else
			{
				this.tooltipHolder_mc.x = 801 + this.zeroXpoint;
				this.btnHints_mc.x = 960 + this.zeroXpoint;
				this.btnHints_mc.y = 1024;
			}
		}
		
		public function setGM(param1:String) : *
		{
			ExternalInterface.call("UIAssert","Trying to set controller UI for GM");
		}
		
		public function setInstrument(param1:uint) : *
		{
			this.CCPanel_mc.instruments_mc.selectInstrument(param1);
		}
		
		public function setInstrumentName(param1:uint, param2:String) : *
		{
			this.CCPanel_mc.instruments_mc.setInstrumentName(param1,param2);
		}
		
		public function creationDone(param1:String, param2:Boolean, param3:Boolean) : *
		{
			this.CCPanel_mc.visible = !param2;
			this.header_mc.visible = !param2;
			if(param3)
			{
				this.waiting_mc.visible = param2;
				this.waiting_mc.waiting_txt.htmlText = param1;
			}
			else
			{
				this.waiting_mc.visible = false;
			}
			if(param2 && this.tooltipMC.visible)
			{
				this.toggleShowTooltip();
			}
		}
		
		public function showTooltip() : *
		{
			this.tooltipMC.setupTooltip(this.tooltipArray);
			this.tooltipArray = new Array();
			this.tooltipMC.visible = this.tooltipVisible && this.canShowTooltip;
		}
		
		public function clearTooltip() : *
		{
			this.tooltipMC.visible = false;
			this.tooltipMC.clear();
		}
		
		public function hideTooltip() : *
		{
			this.tooltipMC.visible = false;
		}
		
		public function setDetails(param1:uint, param2:Boolean) : *
		{
			this.CCPanel_mc.origins_mc.genderSelector_mc.gender = param1;
			this.CCPanel_mc.origins_mc.genderSelector_mc.visible = param2;
		}
		
		public function enableStoryPlayback(param1:Boolean) : *
		{
			this.enableOrigin = param1;
		}
		
		public function onEventResolution(param1:Number, param2:Number) : *
		{
			var val3:Number = param1 / param2 * 1080;
			var val4:int = (2120 - val3) / 2;
			var val5:* = this.portraitsXposDesigned + val4;
			if(val5 <= 18)
			{
				val5 = this.portraitsXposDesigned;
			}
			this.portraits_mc.x = val5;
			this.uiScaling = param2 / this.designResolution.y;
			param1 = param1 / this.uiScaling;
			param2 = param2 / this.uiScaling;
			this.screenWidth = param1;
			this.INTSetPanelPos();
		}
		
		public function onEventDown(param1:Number, param2:Number) : *
		{
			var val3:int = 0;
			var val4:Boolean = false;
			var val5:String = this.events[param1];
			if(this.header_mc.name_mc.isSelected && (val5 == "IE UIAccept" || val5 == "IE UIBack"))
			{
				this.header_mc.name_mc.deselectElement();
				this.eatup = true;
				return true;
			}
			if(this.letterT_mc.visible)
			{
				if(val5 == "IE UIBack")
				{
					ExternalInterface.call("PlaySound","UI_Gen_XButton_Click");
					ExternalInterface.call("stopOriginStory");
					return true;
				}
				return false;
			}
			if(this.CCPanel_mc.delegateDown(val5))
			{
				return true;
			}
			switch(val5)
			{
				case "IE UIAccept":
					if(this.currentPanel == 0 && this.isOrigin && this.enableOrigin)
					{
						ExternalInterface.call("playOriginStory");
						return true;
					}
					break;
				case "IE UIShowInfo":
					this.toggleShowTooltip();
					return true;
				case "IE UIEditCharacter":
					if(this.header_mc.name_mc.isEnabled)
					{
						ExternalInterface.call("PlaySound","UI_Gen_XButton_Click");
						if(this.header_mc.name_mc.isSelected)
						{
							this.header_mc.name_mc.deselectElement();
						}
						else
						{
							this.header_mc.name_mc.selectElement();
						}
						return true;
					}
				case "IE UITooltipUp":
					this.tooltipMC.scrollUp();
					return true;
				case "IE UITooltipDown":
					this.tooltipMC.scrollDown();
					return true;
				case "IE UICancel":
					if(this.tooltipMC.visible)
					{
						ExternalInterface.call("PlaySound","UI_Gen_XButton_Click");
						this.hideTooltip();
						return true;
					}
					break;
				case "IE UIBack":
					if(!this.CCPanel_mc.isDetailsPanel(this.currentPanel))
					{
						ExternalInterface.call("PlaySound","UI_Gen_XButton_Click");
						ExternalInterface.call("mainMenu");
						return true;
					}
					break;
				case "IE UICreationTabNext":
					if(this.currentPanel < this.CCPanel_mc.panelArray.length - 1)
					{
						ExternalInterface.call("PlaySound","UI_Gen_XButton_Click");
						if(this.header_mc.rightBtn_mc)
						{
							this.header_mc.rightBtn_mc.showHL();
						}
						ExternalInterface.call("nextStep");
						return true;
					}
					break;
				case "IE UICreationTabPrev":
					if(this.currentPanel > 0)
					{
						ExternalInterface.call("PlaySound","UI_Gen_XButton_Click");
						if(this.header_mc.leftBtn_mc)
						{
							this.header_mc.leftBtn_mc.showHL();
						}
						ExternalInterface.call("previousStep");
						return true;
					}
					break;
				case "IE UIStartGame":
					if(this.header_mc.name_mc.isSelected)
					{
						this.header_mc.name_mc.deselectElement();
					}
					if(!this.CCPanel_mc.isDetailsPanel(this.currentPanel))
					{
						ExternalInterface.call("startGame");
						return true;
					}
					break;
			}
			return false;
		}
		
		public function onEventUp(param1:Number, param2:Number) : *
		{
			var val3:int = 0;
			var val4:Boolean = false;
			var val5:String = this.events[param1];
			if(this.eatup && (val5 == "IE UIAccept" || val5 == "IE UIBack"))
			{
				this.eatup = false;
				return true;
			}
			if(this.letterT_mc.visible)
			{
				return false;
			}
			if(this.CCPanel_mc.delegateUp(val5))
			{
				return true;
			}
			switch(val5)
			{
				case "IE UICreationTabPrev":
					if(this.header_mc.leftBtn_mc)
					{
						this.header_mc.leftBtn_mc.hideHL();
					}
					return true;
				case "IE UICreationTabNext":
					if(this.header_mc.rightBtn_mc)
					{
						this.header_mc.rightBtn_mc.hideHL();
					}
					return true;
				case "IE UITooltipUp":
					this.tooltipMC.stopScrolling();
					return true;
				case "IE UITooltipDown":
					this.tooltipMC.stopScrolling();
					return true;
				default:
					return false;
			}
		}
		
		public function toggleShowTooltip() : *
		{
			if(this.canShowTooltip)
			{
				this.tooltipVisible = !this.tooltipVisible;
			}
			else
			{
				this.tooltipVisible = false;
			}
			if(this.tooltipMC.list.length > 0 || this.tooltipMC.visible)
			{
				this.tooltipMC.visible = this.tooltipVisible;
			}
		}
		
		public function setPanel(param1:uint, param2:uint) : *
		{
			this.CCPanel_mc.setPanel(param1,param2);
		}
		
		public function selectOption(param1:uint, param2:uint, param3:Boolean = true) : *
		{
			var val4:MovieClip = this.CCPanel_mc.findContentByID(param1);
			if(val4)
			{
				val4.selectOption(param2);
				val4.setEnabled(param3 && val4.numOfElements > 1);
			}
		}
		
		public function setBtnHints() : *
		{
			this.btnHints_mc.updateBtnHints(this.buttonHints);
			this.buttonHints = new Array();
		}
		
		public function setText(param1:uint, param2:String, param3:Boolean = false) : *
		{
			if(param1 < this.textArray.length)
			{
				if(param1 == 4)
				{
					this.CCPanel_mc.class_mc.setHintText(param2,param3);
				}
				else if(param1 == 30)
				{
					this.CCPanel_mc.instruments_mc.setHintText(param2,param3);
				}
				else if(param1 == 31)
				{
					this.header_mc.name_mc.setHintText(!!param3?param2.toUpperCase():param2);
				}
				if(this.textArray[param1] == null)
				{
					this.textArray[param1] = !!param3?param2.toUpperCase():param2;
				}
				else
				{
					this.textArray[param1].htmlText = !!param3?param2.toUpperCase():param2;
				}
				if(this.CCPanel_mc.combatAbilities_mc.title_txt == this.textArray[param1])
				{
					this.CCPanel_mc.civilAbilities_mc.title_txt.htmlText = !!param3?param2.toUpperCase():param2;
				}
			}
		}
		
		public function headerBtnHintsVisible(param1:Boolean) : *
		{
			if(this.header_mc.leftBtn_mc)
			{
				this.header_mc.leftBtn_mc.visible = param1;
			}
			if(this.header_mc.rightBtn_mc)
			{
				this.header_mc.rightBtn_mc.visible = param1;
			}
		}
		
		public function updateSteps() : *
		{
			this.header_mc.updateSteps(this.stepArray);
			this.stepArray = new Array();
		}
		
		public function setStepLabel(param1:uint, param2:String) : *
		{
			this.header_mc.setTabLabel(param1,param2);
		}

		//LeaderLib
		public function clearArray(name:String): *
		{
			switch(name)
			{
				case "all":
					this.buttonHints = new Array();
					this.contentArray = new Array();
					this.stepArray = new Array();
					this.attributeArray = new Array();
					this.abilityArray = new Array();
					this.skillArray = new Array();
					this.talentArray = new Array();
					this.racialTalentArray = new Array();
					this.tagArray = new Array();
					this.racialTagArray = new Array();
					this.tooltipArray = new Array();
					this.playerArray = new Array();
					break;
				case "buttonHints":
					this.buttonHints.length = 0;
					break;
				case "contentArray":
					this.contentArray.length = 0;
					break;
				case "stepArray":
					this.stepArray.length = 0;
					break;
				case "attributeArray":
					this.attributeArray.length = 0;
					break;
				case "abilityArray":
					this.abilityArray.length = 0;
					break;
				case "skillArray":
					this.skillArray.length = 0;
					break;
				case "talentArray":
					this.talentArray.length = 0;
					break;
				case "racialTalentArray":
					this.racialTalentArray.length = 0;
					break;
				case "tagArray":
					this.tagArray.length = 0;
					break;
				case "racialTagArray":
					this.racialTagArray.length = 0;
					break;
				case "tooltipArray":
					this.tooltipArray.length = 0;
					break;
				case "playerArray":
					this.playerArray.length = 0;
					break;
				default:
					ExternalInterface.call("UIAssert","[characterCreation_c:clearArray] name ("+String(name)+") isn't valid.");
			}
		}
		
		public function updateContent() : *
		{
			this.CCPanel_mc.updateContent(this.contentArray);
			this.contentArray = new Array();
		}
		
		public function updateSkills() : *
		{
			this.CCPanel_mc.skills_mc.updateSkills(this.skillArray);
			this.skillArray = new Array();
		}
		
		public function updateAttributes() : *
		{
			this.CCPanel_mc.attributes_mc.updateAttributes(this.attributeArray);
			this.attributeArray = new Array();
		}
		
		public function updateAbilities() : *
		{
			var val3:uint = 0;
			var val4:uint = 0;
			var val5:String = null;
			var val6:uint = 0;
			var val7:String = null;
			var val8:Number = NaN;
			var val9:Number = NaN;
			var val10:Boolean = false;
			var val1:Array = new Array();
			var val2:Array = new Array();
			if(this.abilityArray.length > 0)
			{
				val3 = 0;
				while(val3 < this.abilityArray.length)
				{
					val4 = this.abilityArray[val3++];
					val5 = this.abilityArray[val3++];
					val6 = this.abilityArray[val3++];
					val7 = this.abilityArray[val3++];
					val8 = this.abilityArray[val3++];
					val9 = this.abilityArray[val3++];
					val10 = this.abilityArray[val3++];
					this.addAbility(val4,val5,val6,val7,val8,val9,val10);
					if(val9 > 0)
					{
						if(val10)
						{
							val2.push(val7);
							val2.push(val9);
						}
						else
						{
							val1.push(val7);
							val1.push(val9);
						}
					}
				}
			}
			this.CCPanel_mc.class_mc.addTabTextContent(1,val1);
			this.CCPanel_mc.class_mc.addTabTextContent(2,val2);
			this.CCPanel_mc.civilAbilities_mc.postUpdateAbilities();
			this.CCPanel_mc.combatAbilities_mc.postUpdateAbilities();
			this.abilityArray = new Array();
		}
		
		public function addAbility(param1:uint, param2:String, param3:uint, param4:String, param5:Number, param6:Number, param7:Boolean) : *
		{
			if(param7)
			{
				this.CCPanel_mc.civilAbilities_mc.addAbility(param1,param2,param3,param4,param5,param6,param7);
			}
			else
			{
				this.CCPanel_mc.combatAbilities_mc.addAbility(param1,param2,param3,param4,param5,param6,param7);
			}
		}
		
		public function updateTalents() : *
		{
			//LeaderLib - Disabled since we're just adding talents through Lua.
			/*this.CCPanel_mc.talents_mc.updateTalents(this.talentArray,this.racialTalentArray);*/
			this.talentArray = new Array();
			this.racialTalentArray = new Array();
		}
		
		public function updateTags() : *
		{
			this.CCPanel_mc.tags_mc.updateTags(this.tagArray,this.racialTagArray);
			this.tagArray = new Array();
			this.racialTagArray = new Array();
		}
		
		public function setTextField(param1:uint, param2:String, param3:Boolean) : *
		{
			if(param1 == 2)
			{
				this.isOrigin = !param3;
				this.header_mc.name_mc.setText(param2,param3);
			}
			else
			{
				this.CCPanel_mc.setTextField(param1,param2);
			}
		}
		
		public function setClassEditTabLabel(param1:uint, param2:String) : *
		{
			this.CCPanel_mc.setClassEditLabel(param1,param2);
		}
		
		public function clearPanelSelectors(param1:uint) : *
		{
			this.CCPanel_mc.clearPanelSelectors(param1);
		}
		
		public function setFreeClassPoints(param1:uint, param2:int) : *
		{
			switch(param1)
			{
				case 0:
					this.availableAttributePoints = param2;
					break;
				case 1:
					this.availableAbilityPoints = param2;
					break;
				case 2:
					this.availableCivilPoints = param2;
					break;
				case 3:
					this.availableSkillPoints = param2;
			}
			this.CCPanel_mc.attributes_mc.base_mc.setFreePoints(param1);
			this.CCPanel_mc.combatAbilities_mc.base_mc.setFreePoints(param1);
			this.CCPanel_mc.civilAbilities_mc.base_mc.setFreePoints(param1);
			this.CCPanel_mc.skills_mc.base_mc.setFreePoints(param1);
		}
		
		public function setAvailableSkillSlots(param1:uint) : *
		{
		}
		
		private function frame1() : *
		{
			this.canShowTooltip = false;
			this.tooltipVisible = false;
			this.attributeCap = -1;
			this.combatAbilityCap = -1;
			this.cibilAbilityCap = -1;
			this.events = new Array("IE UICreationTabPrev","IE UICreationTabNext","IE UIAccept","IE UIBack","IE UIEditCharacter","IE UIShowInfo","IE UIUp","IE UIDown","IE UILeft","IE UIRight","IE UIStartGame","IE UIToggleEquipment","IE UITooltipUp","IE UITooltipDown","IE UICancel");
			this.layout = "fitVertical";
			this.alignment = "none";
			this.uiScaling = 1;
			this.buttonHints = new Array();
			this.contentArray = new Array();
			this.stepArray = new Array();
			this.attributeArray = new Array();
			this.abilityArray = new Array();
			this.skillArray = new Array();
			this.talentArray = new Array();
			this.racialTalentArray = new Array();
			this.tagArray = new Array();
			this.racialTagArray = new Array();
			this.tooltipArray = new Array();
			this.playerArray = new Array();
			this.enableOrigin = true;
			this.eatup = false;
			this.textArray = new Array(this.header_mc.title_txt,this.CCPanel_mc.origins_mc.title_txt,null,this.CCPanel_mc.skills_mc.title_txt,null,this.CCPanel_mc.appearance_mc.title_txt,this.CCPanel_mc.class_mc.title_txt,this.CCPanel_mc.combatAbilities_mc.title_txt,this.CCPanel_mc.attributes_mc.title_txt,this.CCPanel_mc.talents_mc.title_txt,this.CCPanel_mc.tags_mc.title_txt,this.CCPanel_mc.class_mc.currentClass_txt,null,null,null,null,null,null,null,null,null,null,null,this.CCPanel_mc.tags_mc.tagTitle_txt,null,this.CCPanel_mc.instruments_mc.title_txt,null,null,null,null,null,null,null,this.CCPanel_mc.loreBox_mc.title_txt,null,this.CCPanel_mc.skills_mc.noSkill_txt,null,this.portraits_mc.hint_mc.hint_txt);
		}
	}
}
