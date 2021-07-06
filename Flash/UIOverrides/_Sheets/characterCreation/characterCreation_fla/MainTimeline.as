package characterCreation_fla
{
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	
	public dynamic class MainTimeline extends MovieClip
	{
		public var CCPanel_mc:MovieClip;
		public var back_mc:RedBtn;
		public var dragHit_mc:hit;
		public var header_mc:MovieClip;
		public var letterB_mc:MovieClip;
		public var letterT_mc:MovieClip;
		public var portraits_mc:MovieClip;
		public var start_mc:MovieClip;
		public var events:Array;
		public const userIconHeight:uint = 38;
		public const userIconWidth:uint = 38;
		public const charIconHeight:uint = 100;
		public const charIconWidth:uint = 80;
		public const designResolution:Point = new Point(2120,1080);
		public const fixedContentSize:Point = new Point(300,150);
		public const iconSize:uint = 55;
		public const iconSpacing:uint = 25;
		public const maxNameChars:uint = 20;
		public const numberOfClassEdits:uint = 3;
		public const skillIconSize:uint = 50;
		public const chosenListSpacing:uint = 24;
		public const listSpacing:uint = 70;
		public const iconSpacingH:uint = 10;
		public const iconSpacingV:uint = 10;
		public const numberOfCols:uint = 4;
		public const chosenListCols:uint = 3;
		public const chosenListIconSize:uint = 55;
		public const chosenListSpacingH:uint = 25;
		public const chosenListSpacingV:uint = 25;
		public const PositionForTutorialX:uint = 1375;
		public const PositionForTutorialY:uint = 352;
		public var numberOfSlots:uint;
		public var availableAttributePoints:uint;
		public var availableTalentPoints:uint;
		public var availableTagPoints:uint;
		public var availableAbilityPoints:uint;
		public var availableCivilPoints:uint;
		public var availableSkillPoints:uint;
		public var attributeCap:int;
		public var combatAbilityCap:int;
		public var cibilAbilityCap:int;
		public var layout:String;
		public var alignment:String;
		public var isDragging:Boolean;
		public var isGM:Boolean;
		public var isMaster:Boolean;
		public var screenWidth:uint;
		public var screenHeight:uint;
		public var contentArray:Array;
		public var stepArray:Array;
		public var attributeArray:Array;
		public var abilityArray:Array;
		public var skillArray:Array;
		public var skillSchoolString:Array;
		public var talentArray:Array;
		public var racialTalentArray:Array;
		public var tagArray:Array;
		public var racialTagArray:Array;
		public var chosenSkills:Array;
		public var racialSkills:Array;
		public var panelTitles:Array;
		public var playerArray:Array;
		public var currentPanel:int;
		public var createOrigin:Boolean;
		public var isFinished:Boolean;
		public var creationType:int;
		public const portraitsXposDesigned:uint = 50;
		public const panelWidth:uint = 484;
		public const maxPanelPosX:uint = 1636.0;
		public var textArray:Array;
		public var enableOrigin:Boolean;

		//LeaderLib
		public var characterHandle:Number;
		//In case mods are still using this.
		public var charHandle:Number;
		public var initialized:Boolean = false;
		
		public function MainTimeline()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onOverScrollEat(e:MouseEvent) : *
		{
			ExternalInterface.call("blockMouseWheelInput",true);
		}
		
		public function onOutScrollEat(e:MouseEvent) : *
		{
			ExternalInterface.call("blockMouseWheelInput",false);
		}
		
		public function onEventInit() : *
		{
			this.dragHit_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onDragDown);
			this.CCPanel_mc.onInit(this);
			this.header_mc.onInit(this);
			this.back_mc.init(function():*
			{
				ExternalInterface.call("mainMenu");
			});
			this.start_mc.btn_mc.init(this.onStartButton);
			ExternalInterface.call("registerAnchorId","creation");
			ExternalInterface.call("setAnchor","center","screen","center");
			this.isGM = false;
			this.isFinished = false;
			this.back_mc.visible = false;
			this.setLetterBoxVisibility(false);
			this.letterB_mc.close_mc.init(this.closeOriginPreview);
			this.portraits_mc.onInit();
		}
		
		public function closeOriginPreview() : *
		{
			ExternalInterface.call("stopOriginStory");
		}
		
		public function onStartButton() : *
		{
			ExternalInterface.call("startGame");
		}
		
		public function onEventResolution(w:int, h:int) : *
		{
			var diff:Number = w / h * 1080;
			var widthScalar:int = (2120 - diff) / 2;
			var panelX:* = this.portraitsXposDesigned + widthScalar;
			if(panelX < this.portraitsXposDesigned)
			{
				panelX = this.portraitsXposDesigned;
			}
			this.portraits_mc.x = panelX;
			panelX = diff - this.panelWidth + widthScalar;
			if(panelX > this.maxPanelPosX)
			{
				panelX = this.maxPanelPosX;
			}
			this.CCPanel_mc.x = panelX;
		}
		
		public function setLetterBoxText(str:String) : *
		{
			this.letterB_mc.text_txt.htmlText = str;
		}
		
		public function setLetterBoxVisibility(visible:Boolean = false) : *
		{
			this.letterT_mc.visible = this.letterB_mc.visible = visible;
			this.CCPanel_mc.visible = this.header_mc.visible = this.portraits_mc.visible = !visible;
		}
		
		public function onEventUp(id:Number, param2:Number) : *
		{
			trace("onEventUp", id, param2);
			if(this.events[id] == "IE ToggleInGameMenu")
			{
				this.header_mc.textFieldName_mc.escapePressed();
				return true;
			}
			return false;
		}
		
		public function onEventDown(id:Number, param2:Number) : *
		{
			trace("onEventDown", id, param2);
			return false;
		}
		
		public function setPanel(currentPanel:uint, nextTab:uint) : *
		{
			if(!this.isFinished)
			{
				this.CCPanel_mc.setPanel(currentPanel,nextTab);
			}
		}
		
		public function selectOption(id:uint, option:uint, enabled:Boolean = true) : *
		{
			var mc:MovieClip = this.CCPanel_mc.findContentByID(id);
			if(mc)
			{
				mc.selectOption(option,false);
				mc.setEnabled(enabled);
			}
		}
		
		public function setText(textTypeId:uint, htmlText:String, makeUppercase:Boolean = false) : *
		{
			if(textTypeId < this.textArray.length)
			{
				if(textTypeId == 0 || textTypeId == 23 || textTypeId == 24 || textTypeId == 25 || this.textArray[textTypeId] == this.letterB_mc.stopOriginText_txt || this.textArray[textTypeId] == this.CCPanel_mc.skills_mc.noSkill_txt || textTypeId == 36)
				{
					this.textArray[textTypeId].htmlText = !!makeUppercase?htmlText.toUpperCase():htmlText;
				}
				else if(textTypeId == 4)
				{
					this.CCPanel_mc.class_mc.attributeTab_mc.editBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
					this.CCPanel_mc.class_mc.abilityTab_mc.editBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
					this.CCPanel_mc.class_mc.skillsTab_mc.editBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
				}
				else if(textTypeId == 9)
				{
					this.CCPanel_mc.talents_mc.title_txt.htmlText = htmlText.toUpperCase();
				}
				else if(textTypeId == 10)
				{
					this.CCPanel_mc.tags_mc.title_txt.htmlText = htmlText.toUpperCase();
				}
				else if(textTypeId == 17)
				{
					this.start_mc.btn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
				}
				else if(textTypeId == 18)
				{
					this.CCPanel_mc.appearance_mc.backBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
					this.CCPanel_mc.class_mc.backBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
					this.CCPanel_mc.attributes_mc.backBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
					this.CCPanel_mc.abilities_mc.backBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
					this.CCPanel_mc.talents_mc.backBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
					this.CCPanel_mc.tags_mc.backBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
					this.CCPanel_mc.instruments_mc.backBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
				}
				else if(textTypeId == 19)
				{
					this.CCPanel_mc.origins_mc.nextBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
					this.CCPanel_mc.appearance_mc.nextBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
					this.CCPanel_mc.class_mc.nextBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
					this.CCPanel_mc.attributes_mc.nextBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
					this.CCPanel_mc.abilities_mc.nextBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
					this.CCPanel_mc.talents_mc.nextBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
					this.CCPanel_mc.tags_mc.nextBtn_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
				}
				else if(textTypeId == 20)
				{
					this.CCPanel_mc.attributes_mc.button_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
					this.CCPanel_mc.abilities_mc.button_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
					this.CCPanel_mc.skills_mc.confirm_mc.setText(!!makeUppercase?htmlText.toUpperCase():htmlText);
				}
				else if(textTypeId == 21)
				{
					this.CCPanel_mc.skills_mc.topTitle_txt.htmlText = !!makeUppercase?htmlText.toUpperCase():htmlText;
				}
				else if(textTypeId == 22)
				{
					this.CCPanel_mc.skills_mc.bottomTitle_txt.htmlText = !!makeUppercase?htmlText.toUpperCase():htmlText;
				}
				else if(textTypeId == 26)
				{
					this.CCPanel_mc.origins_mc.maleBtn_mc.tooltip = htmlText;
				}
				else if(textTypeId == 27)
				{
					this.CCPanel_mc.origins_mc.femaleBtn_mc.tooltip = htmlText;
				}
				else if(textTypeId == 28)
				{
					this.CCPanel_mc.armourBtnHolder_mc.armourBtn_mc.tooltip = htmlText;
				}
				else if(textTypeId == 29)
				{
					this.CCPanel_mc.armourBtnHolder_mc.helmetBtn_mc.tooltip = htmlText;
				}
				else if(textTypeId == 32)
				{
					this.header_mc.voiceOriginBtn_mc.text_txt.htmlText = htmlText;
				}
				else
				{
					this.textArray[textTypeId] = !!makeUppercase?htmlText.toUpperCase():htmlText;
				}
			}
		}
		
		public function setArmourState(param1:Number) : *
		{
			this.CCPanel_mc.armourBtnHolder_mc.setArmourState(param1);
		}
		
		public function setInstrumentName(param1:uint, param2:String, param3:String) : *
		{
			this.CCPanel_mc.instruments_mc.setInstrumentName(param1,param2,param3);
		}
		
		public function setDetails(isFemaleInt:uint, buttonVisible:Boolean) : *
		{
			this.CCPanel_mc.origins_mc.setGender(isFemaleInt,buttonVisible);
			this.header_mc.voiceOriginBtn_mc.visible = this.enableOrigin && !buttonVisible && this.creationType == 0;
			this.header_mc.voiceOriginBtn_mc.isEnabled = buttonVisible;
		}
		
		public function enableStoryPlayback(enableOrigin:Boolean) : *
		{
			this.enableOrigin = enableOrigin;
			this.header_mc.voiceOriginBtn_mc.visible = enableOrigin && !this.header_mc.voiceOriginBtn_mc.isEnabled && this.creationType == 0;
		}
		
		public function updateSteps() : *
		{
			this.header_mc.updateSteps(this.stepArray);
			this.stepArray = new Array();
		}
		
		public function setStepLabel(tabIndex:uint, text:String) : *
		{
			this.header_mc.setTabLabel(tabIndex,text);
		}

		//LeaderLib
		public function clearArray(name:String): *
		{
			switch(name)
			{
				case "all":
					this.contentArray = new Array();
					this.stepArray = new Array();
					this.attributeArray = new Array();
					this.abilityArray = new Array();
					this.skillArray = new Array();
					this.skillSchoolString = new Array();
					this.talentArray = new Array();
					this.racialTalentArray = new Array();
					this.tagArray = new Array();
					this.racialTagArray = new Array();
					this.chosenSkills = new Array();
					this.racialSkills = new Array();
					this.panelTitles = new Array();
					this.playerArray = new Array();
					break;
				case "contentArray":
					this.contentArray.length = 0;
					break;
				case "stepArray":
					this.stepArray.length = 0;
					break;
				case "skillArray":
					this.skillArray.length = 0;
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
				case "skillSchoolString":
					this.skillSchoolString.length = 0;
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
				case "chosenSkills":
					this.chosenSkills.length = 0;
					break;
				case "racialSkills":
					this.racialSkills.length = 0;
					break;
				case "panelTitles":
					this.panelTitles.length = 0;
					break;
				case "playerArray":
					this.playerArray.length = 0;
					break;
				default:
					ExternalInterface.call("UIAssert","[characterCreation:clearArray] name ("+String(name)+") isn't valid.");
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
			this.CCPanel_mc.abilities_mc.updateAbilities(this.abilityArray);
			this.abilityArray = new Array();
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
			this.CCPanel_mc.setTextField(param1,param2,param3);
		}
		
		public function setClassEditTabLabel(param1:uint, param2:String) : *
		{
			switch(param1)
			{
				case 0:
					this.CCPanel_mc.class_mc.attributeTab_mc.setLabel(param2.toUpperCase());
					this.CCPanel_mc.attributes_mc.title_txt.htmlText = param2;
					break;
				case 1:
					this.CCPanel_mc.abilities_mc.title_txt.htmlText = param2;
				case 2:
					this.CCPanel_mc.abilities_mc.title2_txt.htmlText = param2;
					break;
				case 3:
					this.CCPanel_mc.class_mc.skillsTab_mc.setLabel(param2.toUpperCase());
					break;
				case 6:
					this.CCPanel_mc.class_mc.abilityTab_mc.setLabel(param2.toUpperCase());
			}
		}
		
		public function setGM(htmlText:String) : *
		{
			this.back_mc.visible = false;
			this.CCPanel_mc.setPanel(9,0);
			this.header_mc.setGM(htmlText);
		}
		
		public function setBackButtonVisible(visible:Boolean, htmlText:String) : *
		{
			this.back_mc.visible = visible;
			this.back_mc.setText(htmlText);
		}
		
		public function creationDone(startText:String, backText:String, visible:Boolean = true) : *
		{
			if(!this.isGM)
			{
				this.CCPanel_mc.visible = false;
				this.header_mc.visible = false;
			}
			this.start_mc.btn_mc.setText(startText.toUpperCase());
			this.start_mc.btn_mc.setEnabled(false);
			this.isFinished = true;
			this.back_mc.visible = visible;
			this.back_mc.setText(backText.toUpperCase());
		}
		
		public function setInstrument(id:uint) : *
		{
			this.CCPanel_mc.instruments_mc.setInstrument(id);
		}
		
		public function clearPanelSelectors(id:uint) : *
		{
			this.CCPanel_mc.clearPanelSelectors(id);
		}
		
		public function setFreeClassPoints(pointId:uint, amount:int) : *
		{
			//LeaderLib
			if(!this.initialized)
			{
				ExternalInterface.call("characterCreationStarted");
				this.initialized = true;
			}
			switch(pointId)
			{
				case 0:
					this.availableAttributePoints = amount;
					break;
				case 1:
					this.availableAbilityPoints = amount;
					break;
				case 2:
					this.availableCivilPoints = amount;
					break;
				case 3:
					this.availableSkillPoints = amount;
					break;
				case 4:
					this.availableTalentPoints = amount;
			}
		}
		
		public function onDragDown(e:MouseEvent) : *
		{
			ExternalInterface.call("rotateCharacter");
		}
		
		public function setAvailableSkillSlots(numberOfSlots:uint) : *
		{
			var skill_mc:MovieClip = null;
			this.numberOfSlots = numberOfSlots;
			this.CCPanel_mc.skills_mc.chosenSkillList.clearElements();
			var val2:int = 0;
			while(val2 < numberOfSlots)
			{
				skill_mc = new Skill();
				skill_mc.Init();
				skill_mc.slotPos = val2;
				this.CCPanel_mc.skills_mc.chosenSkillList.addElement(skill_mc,true);
				val2++;
			}
			this.CCPanel_mc.skills_mc.chosenSkillList.positionElements();
		}
		
		public function updatePortraits() : *
		{
			this.portraits_mc.updatePortraits(this.playerArray);
			this.playerArray = new Array();
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

		//LeaderLib
		//Just a tweak so we can pass the id parameter to use.
		public function showCustomTooltipForMC(mc:MovieClip, externalCall:String, id:*, align:String = "left") : *
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
				ExternalInterface.call(externalCall, id, globalPos.x + offsetX,globalPos.y + offsetY,tWidth,mc.height,mc.tooltipAlign != null ? mc.tooltipAlign : align);
			}
		}
		
		public function frame1() : *
		{
			this.events = new Array("IE ToggleInGameMenu");
			this.numberOfSlots = 3;
			this.layout = "fitVertical";
			this.alignment = "none";
			this.contentArray = new Array();
			this.stepArray = new Array();
			this.attributeArray = new Array();
			this.abilityArray = new Array();
			this.skillArray = new Array();
			this.skillSchoolString = new Array();
			this.talentArray = new Array();
			this.racialTalentArray = new Array();
			this.tagArray = new Array();
			this.racialTagArray = new Array();
			this.chosenSkills = new Array();
			this.racialSkills = new Array();
			this.panelTitles = new Array();
			this.playerArray = new Array();
			this.createOrigin = false;
			this.start_mc.addEventListener(MouseEvent.ROLL_OVER,this.onOverScrollEat,false);
			this.start_mc.addEventListener(MouseEvent.ROLL_OUT,this.onOutScrollEat,false);
			this.header_mc.addEventListener(MouseEvent.ROLL_OVER,this.onOverScrollEat,false);
			this.header_mc.addEventListener(MouseEvent.ROLL_OUT,this.onOutScrollEat,false);
			this.CCPanel_mc.addEventListener(MouseEvent.ROLL_OVER,this.onOverScrollEat,false);
			this.CCPanel_mc.addEventListener(MouseEvent.ROLL_OUT,this.onOutScrollEat,false);
			this.textArray = new Array(this.header_mc.title_txt,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,this.CCPanel_mc.tags_mc.tagTitle_txt,this.CCPanel_mc.tags_mc.summaryTitle_txt,this.CCPanel_mc.instruments_mc.title_txt,null,null,null,null,null,null,null,null,this.letterB_mc.stopOriginText_txt,this.CCPanel_mc.skills_mc.noSkill_txt,this.CCPanel_mc.class_mc.presetCaption_mc,null);
			this.enableOrigin = true;
		}
	}
}
