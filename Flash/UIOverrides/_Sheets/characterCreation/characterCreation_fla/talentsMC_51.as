package characterCreation_fla
{
	import LS_Classes.scrollList;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class talentsMC_51 extends MovieClip
	{
		public var availablePoints_txt:TextField;
		public var backBtn_mc:brownBtn;
		public var nextBtn_mc:greenBtn;
		public var talentHolder_mc:MovieClip;
		public var title_txt:TextField;
		public var root_mc:MovieClip;
		public var talentList:scrollList;
		
		public function talentsMC_51()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onInit(rootMovieClip:MovieClip) : *
		{
			this.root_mc = rootMovieClip;
			this.backBtn_mc.init(this.root_mc.CCPanel_mc.prevPanel);
			this.nextBtn_mc.init(this.root_mc.CCPanel_mc.nextPanel);
			this.title_txt.wordWrap = this.title_txt.multiline = false;
			this.title_txt.autoSize = TextFieldAutoSize.CENTER;
			this.availablePoints_txt.wordWrap = this.availablePoints_txt.multiline = false;
			this.availablePoints_txt.autoSize = TextFieldAutoSize.CENTER;
			this.talentList = new scrollList();
			this.talentList.setFrame(354,612);
			this.talentList.m_scrollbar_mc.m_hideWhenDisabled = false;
			this.talentList.m_scrollbar_mc.setLength(563);
			this.talentList.m_scrollbar_mc.y = -14;
			this.talentList.mouseWheelWhenOverEnabled = true;
			this.talentList.sortOn(["isRacial","isActive","choosable","talName"],[Array.NUMERIC | Array.DESCENDING,Array.NUMERIC | Array.DESCENDING,Array.NUMERIC | Array.DESCENDING,null]);
			this.talentHolder_mc.addChild(this.talentList);
		}
		
		public function toggleTalent(talent_mc:MovieClip) : *
		{
			if(talent_mc.choosable)
			{
				ExternalInterface.call("toggleTalent",talent_mc.talentID);
			}
		}
		
		public function updateTalents(talentArray:Array, racialtalentArray:Array) : *
		{
			var index:uint = 0;
			var talentID:uint = 0;
			var talentLabel:String = null;
			var isUnlocked:Boolean = false;
			var choosable:Boolean = false;
			if(talentArray.length > 0)
			{
				this.root_mc.availableTalentPoints = talentArray[0];
				this.availablePoints_txt.htmlText = this.root_mc.textArray[15] + " " + this.root_mc.availableTalentPoints;
				index = 1;
				while(index < talentArray.length)
				{
					talentID = talentArray[index++];
					talentLabel = talentArray[index++];
					isUnlocked = talentArray[index++];
					choosable = talentArray[index++];
					this.addTalentElement(talentID,talentLabel,isUnlocked,choosable,false);
				}
			}
			if(racialtalentArray.length > 0)
			{
				index = 0;
				while(index < racialtalentArray.length)
				{
					talentID = racialtalentArray[index++];
					talentLabel = racialtalentArray[index++];
					this.addTalentElement(talentID,talentLabel,true,false,true);
				}
			}
			this.positionLists();
		}
		
		public function addTalentElement(talentID:uint, talentLabel:String, isUnlocked:Boolean, isChoosable:Boolean, isRacial:Boolean) : *
		{
			var talent_mc:MovieClip = this.talentList.getElementByNumber("talentID",talentID);
			if(!talent_mc)
			{
				talent_mc = new talentEl();
				talent_mc.onInit(this.root_mc,isRacial);
				talent_mc.setText(talentLabel);
				talent_mc.talName = talentLabel;
				talent_mc.talentID = talentID;
				this.talentList.addElement(talent_mc,false);
			}
			talent_mc.dColour = !!isChoosable?0:12910617;
			talent_mc.choosable = isChoosable;
			talent_mc.setState(isUnlocked);
			talent_mc.isUpdated = true;
		}

		public function addCustomTalentElement(customTalentId:String, talentLabel:String, isUnlocked:Boolean, isChoosable:Boolean, isRacial:Boolean) : *
		{
			var talent_mc:MovieClip = this.talentList.getElementByString("customTalentId", customTalentId);
			if(!talent_mc)
			{
				talent_mc = new talentEl();
				talent_mc.onInit(this.root_mc,isRacial);
				talent_mc.setText(talentLabel);
				talent_mc.talName = talentLabel;
				talent_mc.isCustom = true;
				talent_mc.customTalentId = customTalentId;
				this.talentList.addElement(talent_mc,false);
			}
			talent_mc.dColour = !!isChoosable?0:12910617;
			talent_mc.choosable = isChoosable;
			talent_mc.setState(isUnlocked);
			talent_mc.isUpdated = true;
		}
		
		public function positionLists() : *
		{
			this.talentList.cleanUpElements();
		}
		
		private function frame1() : * {}
	}
}
