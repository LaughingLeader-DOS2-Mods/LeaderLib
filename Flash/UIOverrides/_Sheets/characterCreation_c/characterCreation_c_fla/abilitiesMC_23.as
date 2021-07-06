package characterCreation_c_fla
{
	import LS_Classes.scrollList;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.text.TextField;
	
	public dynamic class abilitiesMC_23 extends MovieClip
	{
		public var abilitiesContainer_mc:empty;
		public var base_mc:MovieClip;
		public var title_txt:TextField;
		public var root_mc:MovieClip;
		public var abilityGroupList:scrollList;
		public var selectedEl:Point;
		public var canLoop:Boolean;
		
		public function abilitiesMC_23()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onInit(param1:MovieClip) : *
		{
			this.root_mc = param1;
			this.abilityGroupList = new scrollList();
			this.abilitiesContainer_mc.addChild(this.abilityGroupList);
			this.abilityGroupList.setFrame(731,636);
			this.abilityGroupList.EL_SPACING = 44;
			this.abilityGroupList.m_allowKeepIntoView = false;
			this.abilityGroupList.m_scrollbar_mc.ScaleBG = true;
			this.abilityGroupList.SB_SPACING = -20;
			this.abilityGroupList.m_scrollbar_mc.y = -1;
			this.abilityGroupList.m_cyclic = true;
			this.abilitiesContainer_mc.x = -133;
			this.abilitiesContainer_mc.y = 205;
			this.selectedEl = new Point(0,0);
		}
		
		public function applySelection() : *
		{
			this.abilityGroupList.select(this.selectedEl.x,true);
			var val1:MovieClip = this.abilityGroupList.getCurrentMovieClip();
			if(val1 && val1.length > this.selectedEl.y)
			{
				val1.selectElement(this.selectedEl.y,true);
			}
		}
		
		public function delegateUp(param1:String) : Boolean
		{
			switch(param1)
			{
				case "IE UIUp":
				case "IE UIDown":
					this.canLoop = true;
					return true;
				default:
					return false;
			}
		}
		
		public function delegateDown(param1:String, param2:Number) : Boolean
		{
			var val10:Boolean = false;
			var val11:MovieClip = null;
			var val12:Boolean = false;
			var val3:MovieClip = this.abilityGroupList.getCurrentMovieClip();
			var val4:Number = val3.list_pos;
			var val5:int = val3.currentIdx;
			var val6:Boolean = false;
			var val7:MovieClip = null;
			var val8:Boolean = false;
			switch(param1)
			{
				case "IE UIUp":
					val10 = true;
					if(!val3.previous() && val4 > 0)
					{
						val3.clear();
						this.abilityGroupList.previous();
						val11 = this.abilityGroupList.getCurrentMovieClip();
						val11.selectElement(val11.length - 1);
					}
					else if(this.canLoop && val5 == 0 && this.abilityGroupList.currentSelection == 0)
					{
						val3.clear();
						this.abilityGroupList.selectLastElement();
						this.abilityGroupList.getCurrentMovieClip().selectLast();
						val10 = false;
					}
					if(val10)
					{
						this.abilityGroupList.getCurrentMovieClip().keepIntoView(true);
					}
					this.canLoop = false;
					val8 = true;
					break;
				case "IE UIDown":
					val12 = true;
					if(!val3.next() && val4 < this.abilityGroupList.length - 1)
					{
						val3.clear();
						this.abilityGroupList.next();
						this.abilityGroupList.getCurrentMovieClip().selectElement(0);
					}
					else if(this.canLoop && this.abilityGroupList.currentSelection >= this.abilityGroupList.length - 1 && val5 >= val3.length - 1)
					{
						val3.clear();
						this.abilityGroupList.selectFirstVisible(true);
						this.abilityGroupList.getCurrentMovieClip().selectFirst();
						val12 = false;
					}
					if(val12)
					{
						this.abilityGroupList.getCurrentMovieClip().keepIntoView(false);
					}
					ExternalInterface.call("PlaySound","UI_Gen_CursorMove");
					this.canLoop = false;
					val8 = true;
					break;
				case "IE UILeft":
					val7 = val3.abilityList.getCurrentMovieClip();
					if(val7)
					{
						ExternalInterface.call("PlaySound","UI_Gen_XButton_Click");
						if(val7.min_mc.visible)
						{
							ExternalInterface.call("minAbility",val7.statID,val3.isCivil);
						}
					}
					val8 = true;
					break;
				case "IE UIRight":
					val7 = val3.abilityList.getCurrentMovieClip();
					if(val7)
					{
						ExternalInterface.call("PlaySound","UI_Gen_XButton_Click");
						if(val7.plus_mc.visible)
						{
							ExternalInterface.call("plusAbility",val7.statID,val3.isCivil);
						}
					}
					val8 = true;
			}
			var val9:int = this.abilityGroupList.currentSelection;
			this.selectedEl = new Point(val9,this.abilityGroupList.getAt(val9).currentIdx);
			return val8;
		}
		
		public function postUpdateAbilities() : *
		{
			var val1:MovieClip = null;
			this.cleanUpElements();
			if(this.root_mc && this.root_mc.currentPanel == this.panelID)
			{
				this.abilityGroupList.select(this.selectedEl.x);
				val1 = this.abilityGroupList.getCurrentMovieClip().abilityList;
				val1.select(this.selectedEl.y);
			}
			this.base_mc.setFreePointsLabel(this.classEditID);
		}
		
		public function cleanUpElements() : *
		{
			var val1:MovieClip = null;
			for each(val1 in this.abilityGroupList.content_array)
			{
				val1.positionElements();
			}
			this.abilityGroupList.cleanUpElements();
		}

		public function addAbility(groupID:uint, groupTitle:String, statID:uint, abilityLabel:String, abilityValue:Number, abilityDelta:Number, isCivil:Boolean) : *
		{
			var abilityGroup_mc:MovieClip = this.findGroup(groupID,groupTitle,isCivil);
			abilityGroup_mc.addAbility(statID,abilityLabel,abilityValue,abilityDelta,isCivil);
		}

		public function addCustomAbility(groupID:uint, groupTitle:String, customID:String, abilityLabel:String, abilityValue:Number, abilityDelta:Number, isCivil:Boolean) : *
		{
			var abilityGroup_mc:MovieClip = this.findGroup(groupID,groupTitle,isCivil);
			abilityGroup_mc.addCustomAbility(customID,abilityLabel,abilityValue,abilityDelta,isCivil);
		}
		
		public function findGroup(groupID:uint, groupTitle:String, isCivil:Boolean) : MovieClip
		{
			var abilityGroup_mc:MovieClip = this.abilityGroupList.getElementByNumber("groupId",groupID);
			if(!abilityGroup_mc)
			{
				abilityGroup_mc = new abilityGroup();
				this.abilityGroupList.addElement(abilityGroup_mc,false);
				abilityGroup_mc.onInit(this.root_mc);
				abilityGroup_mc.setTitle(groupTitle,false);
				abilityGroup_mc.groupId = groupID;
				abilityGroup_mc.isCivil = isCivil;
			}
			abilityGroup_mc.isUpdated = true;
			return abilityGroup_mc;
		}
		
		public function frame1() : * {}
	}
}
