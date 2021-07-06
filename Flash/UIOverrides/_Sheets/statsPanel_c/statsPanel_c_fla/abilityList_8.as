package statsPanel_c_fla
{
	import LS_Classes.scrollListGrouped;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class abilityList_8 extends MovieClip
	{
		public var container_mc:empty;
		public var pointsLabel_txt:TextField;
		public var pointsValue_txt:TextField;
		public const elementDist:Number = 53;
		public var statList:scrollListGrouped;
		public var prevSelectedElemId:Number;
		public var prevSelectedGroupId:Number;
		public var prevY:Number;
		public var hintContainer:MovieClip;
		
		public function abilityList_8()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function init() : *
		{
			this.pointsLabel_txt.autoSize = TextFieldAutoSize.LEFT;
		}
		
		public function addAbility(groupID:Number, statID:Number, displayName:String, value:String, textColor:uint) : *
		{
			var ability_mc:MovieClip = this.getAbility(groupID,statID);
			if(!ability_mc)
			{
				ability_mc = new Ability();
				ability_mc.statID = statID;
				this.statList.addGroupElement(groupID,ability_mc,false);
				ability_mc.isStat = true;
				ability_mc.id = statID;
				ability_mc.plus_mc.visible = false;
				ability_mc.min_mc.visible = false;
				ability_mc.label_txt.autoSize = TextFieldAutoSize.LEFT;
				ability_mc.hl_mc.visible = false;
			}
			ability_mc.label_txt.htmlText = displayName;
			ability_mc.textStr = ability_mc.label_txt.text;
			ability_mc.val_txt.htmlText = value;
			ability_mc.label_txt.textColor = textColor;
			ability_mc.val_txt.textColor = textColor;
			ability_mc.heightOverride = Math.ceil(ability_mc.label_txt.textHeight / this.elementDist) * this.elementDist;
			ability_mc.icon_mc.visible = Boolean(ability_mc.val_txt.text != "0");
		}
		
		public function getAbility(groupID:Number, statID:Number) : MovieClip
		{
			var group:MovieClip = this.statList.getElementByNumber("groupId",groupID);
			if(group)
			{
				return group.list.getElementByNumber("statID",statID);
			}
			return null;
		}
		
		public function addCustomAbility(groupID:Number, customID:String, displayName:String, value:String, textColor:uint) : *
		{
			var ability_mc:MovieClip = this.getCustomAbility(groupID,customID);
			if(!ability_mc)
			{
				ability_mc = new Ability();
				ability_mc.customID = customID;
				ability_mc.isCustom = true;
				this.statList.addGroupElement(groupID,ability_mc,false);
				ability_mc.isStat = true;
				//ability_mc.id = statID;
				ability_mc.plus_mc.visible = false;
				ability_mc.min_mc.visible = false;
				ability_mc.label_txt.autoSize = TextFieldAutoSize.LEFT;
				ability_mc.hl_mc.visible = false;
			}
			ability_mc.label_txt.htmlText = displayName;
			ability_mc.textStr = ability_mc.label_txt.text;
			ability_mc.val_txt.htmlText = value;
			ability_mc.label_txt.textColor = textColor;
			ability_mc.val_txt.textColor = textColor;
			ability_mc.heightOverride = Math.ceil(ability_mc.label_txt.textHeight / this.elementDist) * this.elementDist;
			ability_mc.icon_mc.visible = Boolean(ability_mc.val_txt.text != "0");
		}
		
		public function getCustomAbility(groupID:Number, customID:String) : MovieClip
		{
			var group:MovieClip = this.statList.getElementByNumber("groupId",groupID);
			if(group)
			{
				return group.list.getElementByString("customID",customID);
			}
			return null;
		}
		
		public function addAbilityGroup(param1:Number, param2:String) : *
		{
			var val3:MovieClip = this.statList.addGroup(param1,param2,false);
			if(val3)
			{
				val3.gName = param2;
				val3.heightOverride = this.elementDist;
				val3.list.m_customElementHeight = this.elementDist;
				val3.list.EL_SPACING = 0;
				val3.list.TOP_SPACING = 0;
			}
		}
		
		public function updateHints() : *
		{
			var val1:* = this.getCurrentElement();
			if(this.statList.getCurrentGroup() != this.statList.getCurrentMovieClip())
			{
				if(val1 && val1.plus_mc)
				{
					this.hintContainer.toggleHint(2,val1.plus_mc.visible);
					this.hintContainer.toggleHint(3,val1.min_mc.visible);
				}
			}
			else
			{
				this.hintContainer.toggleHint(2,false);
				this.hintContainer.toggleHint(3,false);
			}
		}
		
		public function setBtnVisible(param1:Number, param2:Number, param3:Boolean, param4:Boolean) : *
		{
			var val5:MovieClip = this.getAbility(param1,param2);
			if(val5)
			{
				if(param3)
				{
					val5.plus_mc.visible = param4;
				}
				else
				{
					val5.min_mc.visible = param4;
				}
			}
		}
		
		public function removeStats() : *
		{
			this.saveSelection();
			this.statList.clearGroupElements();
		}
		
		public function saveSelection() : *
		{
			var val2:MovieClip = null;
			var val1:MovieClip = this.statList.getCurrentGroup();
			if(val1)
			{
				this.prevSelectedGroupId = val1.groupId;
				val2 = val1.list.getCurrentMovieClip();
				if(val2)
				{
					this.prevSelectedElemId = val2.id;
				}
			}
			this.prevY = this.statList.scrolledY;
		}
		
		public function updateDone() : *
		{
			var val1:MovieClip = null;
			var val2:Boolean = false;
			var val3:MovieClip = null;
			if(this.prevSelectedGroupId != -1)
			{
				val1 = this.statList.getElementByNumber("groupId",this.prevSelectedGroupId);
				if(val1)
				{
					val2 = true;
					if(this.prevSelectedElemId != -1)
					{
						val3 = val1.list.getElementByNumber("id",this.prevSelectedElemId);
						if(val3)
						{
							val1.list.selectMC(val3,true);
							val2 = false;
							val1.deselectElement();
						}
					}
					if(val2)
					{
						this.statList.selectMC(val1,true);
					}
				}
				this.statList.m_scrollbar_mc.scrollTo(this.prevY);
				this.prevSelectedElemId = -1;
				this.prevSelectedGroupId = -1;
			}
			if(this.statList.currentSelection == -1)
			{
				this.statList.select(0,true);
			}
		}
		
		public function selectStat(param1:Number) : *
		{
			var val2:MovieClip = this.statList.getElementByNumber("id",param1);
			if(val2)
			{
				this.statList.selectMC(val2);
				this.refreshPos();
			}
		}
		
		public function previous() : *
		{
			this.statList.previous();
			if(this.statList.getCurrentGroup())
			{
				if(this.statList.getCurrentGroup() != this.statList.getCurrentMovieClip())
				{
					this.statList.getCurrentGroup().hl_mc.visible = false;
				}
				else
				{
					this.statList.getCurrentGroup().hl_mc.visible = true;
				}
			}
		}
		
		public function next() : *
		{
			this.statList.next();
			if(this.statList.getCurrentGroup())
			{
				if(this.statList.getCurrentGroup() != this.statList.getCurrentMovieClip())
				{
					this.statList.getCurrentGroup().hl_mc.visible = false;
				}
				else
				{
					this.statList.getCurrentGroup().hl_mc.visible = true;
				}
			}
		}
		
		public function setListLoopable(param1:Boolean) : *
		{
			this.statList.m_cyclic = param1;
		}
		
		public function clearSelection() : *
		{
			this.statList.clearSelection();
		}
		
		public function refreshPos() : *
		{
			this.statList.positionElements();
		}
		
		public function getCurrentElement() : MovieClip
		{
			return this.statList.getCurrentMovieClip();
		}
		
		public function setPoints(param1:String) : *
		{
			this.pointsValue_txt.autoSize = TextFieldAutoSize.LEFT;
			this.pointsValue_txt.htmlText = param1;
			this.centerPoints();
		}
		
		public function centerPoints() : *
		{
			var val1:Number = 406;
			var val2:Number = this.pointsLabel_txt.textWidth + this.pointsValue_txt.textWidth;
			this.pointsLabel_txt.x = Math.round((val1 - val2) * 0.5);
			this.pointsValue_txt.x = this.pointsLabel_txt.textWidth + this.pointsLabel_txt.x + 10;
		}
		
		function frame1() : *
		{
			this.statList = new scrollListGrouped("empty","empty");
			this.prevSelectedElemId = -1;
			this.prevSelectedGroupId = -1;
			this.prevY = -1;
			this.statList.m_scrollbar_mc.ScaleBG = true;
			this.statList.SB_SPACING = -396;
			this.statList.EL_SPACING = 0;
			this.statList.m_scrollbar_mc.m_hideWhenDisabled = false;
			this.container_mc.addChild(this.statList);
			this.statList.setFrame(384,636);
			this.statList.TOP_SPACING = 0;
			this.statList.setGroupMC("StatCategory");
			this.statList.elementsSortOn("textStr");
			this.statList.groupedScroll = false;
			this.statList.m_GroupHeaderHeight = this.elementDist;
			this.statList.m_cyclic = true;
			this.statList.m_ScrollOverShoot = this.elementDist;
			this.statList.m_ScrollUnderShoot = this.elementDist;
		}
	}
}
