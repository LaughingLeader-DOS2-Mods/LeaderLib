package statsPanel_c_fla
{
	import LS_Classes.scrollList;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class talentList_6 extends MovieClip
	{
		public var container_mc:empty;
		public var pointsLabel_txt:TextField;
		public var pointsValue_txt:TextField;
		public const elementDist:Number = 53;
		public var statList:scrollList;
		public var prevSelectedTalentId:Number;
		public var prevY:Number;
		public var base:MovieClip;
		public var hintContainer:MovieClip;
		public const defaultColour:uint = 0;
		
		public function talentList_6()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function setListSort() : *
		{
			this.statList.sortOn(["talentState","labelStr"],[Array.NUMERIC,0]);
		}
		
		public function init() : *
		{
			this.pointsLabel_txt.autoSize = TextFieldAutoSize.LEFT;
		}
		
		public function updateHints() : *
		{
			var val1:* = this.getCurrentElement();
			if(val1 && val1.plus_mc)
			{
				this.hintContainer.toggleHint(2,val1.plus_mc.visible);
				this.hintContainer.toggleHint(3,val1.min_mc.visible);
			}
			else
			{
				this.hintContainer.toggleHint(2,false);
				this.hintContainer.toggleHint(3,false);
			}
		}
		
		public function addTalent(param1:Number, param2:String, param3:Number) : *
		{
			var val4:MovieClip = this.statList.getElementByNumber("id",param1);
			if(val4 == null)
			{
				val4 = new Talent();
				val4.isStat = true;
				val4.hl_mc.visible = false;
				this.statList.addElement(val4,false);
				val4.id = param1;
			}
			val4.talentState = param3;
			val4.label_txt.htmlText = param2;
			val4.labelStr = val4.label_txt.text;
			val4.heightOverride = Math.ceil(val4.label_txt.textHeight / this.elementDist) * this.elementDist;
			switch(param3)
			{
				case 0:
				case 1:
					val4.bullet_mc.visible = true;
					val4.label_txt.textColor = this.defaultColour;
					val4.plus_mc.visible = false;
					break;
				case 2:
					val4.bullet_mc.visible = false;
					val4.label_txt.textColor = this.defaultColour;
					val4.plus_mc.visible = this.base.pointsMode;
					break;
				case 3:
					val4.bullet_mc.visible = false;
					val4.label_txt.textColor = 13312300;
					val4.plus_mc.visible = false;
			}
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
		
		public function setBtnVisible(param1:Boolean, param2:Number, param3:Boolean) : *
		{
			var val4:MovieClip = this.statList.getElementByNumber("id",param2);
			if(val4)
			{
				if(param1)
				{
					val4.plus_mc.visible = param3;
				}
				else
				{
					if(val4.talentState == 2)
					{
						if(param3)
						{
							val4.label_txt.textColor = 35130;
						}
						else
						{
							val4.label_txt.textColor = this.defaultColour;
						}
					}
					val4.min_mc.visible = param3;
				}
			}
		}
		
		public function removeStats() : *
		{
			this.saveSelection();
			this.statList.clearElements();
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
		}
		
		public function next() : *
		{
			this.statList.next();
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
		
		public function updateDone() : *
		{
			var val1:MovieClip = null;
			this.setListSort();
			this.refreshPos();
			if(this.statList.length <= 0)
			{
				return;
			}
			if(this.prevSelectedTalentId != -1)
			{
				val1 = this.statList.getElementByNumber("id",this.prevSelectedTalentId);
				if(val1)
				{
					this.statList.selectMC(val1,true);
					this.statList.m_scrollbar_mc.scrollTo(this.prevY);
					this.prevSelectedTalentId = -1;
				}
			}
			if(this.statList.currentSelection == -1)
			{
				this.statList.select(0,true);
			}
		}
		
		public function saveSelection() : *
		{
			var val1:MovieClip = this.getCurrentElement();
			if(val1)
			{
				this.prevSelectedTalentId = val1.id;
				this.prevY = this.statList.scrolledY;
			}
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
			this.statList = new scrollList("empty","empty");
			this.prevSelectedTalentId = -1;
			this.prevY = -1;
			this.statList.m_scrollbar_mc.ScaleBG = true;
			this.statList.EL_SPACING = 0;
			this.statList.TOP_SPACING = 0;
			this.statList.SB_SPACING = -394;
			this.statList.m_customElementHeight = this.elementDist;
			this.statList.m_scrollbar_mc.m_scrollOverShoot = this.elementDist;
			this.statList.m_cyclic = true;
			this.container_mc.addChild(this.statList);
			this.statList.setFrame(380,636);
			this.setListSort();
			this.base = parent as MovieClip;
		}
	}
}
