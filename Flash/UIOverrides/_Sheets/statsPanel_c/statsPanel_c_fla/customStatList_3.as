package statsPanel_c_fla
{
	import LS_Classes.scrollList;
	import flash.display.MovieClip;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class customStatList_3 extends MovieClip
	{
		public var container_mc:empty;
		public const elementDist:Number = 53;
		public var savedSelection:int;
		public var statList:scrollList;
		public var base:MovieClip;
		public var hintContainer:MovieClip;
		public var stats_array:Array;
		
		public function customStatList_3()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function setListSort() : *
		{
		}
		
		public function init() : *
		{
			this.savedSelection = -1;
			this.stats_array = new Array();
		}
		
		public function updateHints() : *
		{
		}
		
		public function addStat(statId:Number, label:String, value:String, textColor:uint) : *
		{
			var stat_mc:MovieClip = this.statList.getElementByNumber("id",statId);
			if(!stat_mc)
			{
				stat_mc = new CustomStat();
				stat_mc.statId = statId;
				stat_mc.id = this.statList.length;
				this.statList.addElement(stat_mc,true);
				stat_mc.isStat = true;
				stat_mc.label_txt.autoSize = TextFieldAutoSize.LEFT;
				stat_mc.label_txt.wordWrap = true;
				stat_mc.label_txt.multiline = true;
				stat_mc.hl_mc.visible = false;

				stat_mc.statIndex = this.stats_array.length;
				this.stats_array.push(stat_mc);
			}
			stat_mc.label_txt.htmlText = label;
			stat_mc.textStr = stat_mc.label_txt.text;
			stat_mc.val_txt.htmlText = value;
			stat_mc.label_txt.textColor = textColor;
			stat_mc.val_txt.textColor = textColor;
			stat_mc.heightOverride = Math.ceil(stat_mc.label_txt.textHeight / this.elementDist) * this.elementDist;
			stat_mc.hl_mc.height = stat_mc.label_txt.textHeight + stat_mc.label_txt.y;
			stat_mc.line_mc.y = stat_mc.hl_mc.height - Math.round(stat_mc.line_mc.height * 0.5) - 3;

			ExternalInterface.call("customStatAdded", statId, cstat_mc.statIndex);
		}
		
		public function removeStats() : *
		{
			this.savedSelection = this.statList.currentSelection;
			this.statList.clearElements();
		}
		
		public function selectStat(statId:Number) : *
		{
			var stat_mc:MovieClip = this.statList.getElementByNumber("statId",id);
			if(stat_mc)
			{
				this.statList.selectMC(stat_mc);
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
		
		public function setListLoopable(b:Boolean) : *
		{
			this.statList.m_cyclic = b;
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
			this.refreshPos();
			if(this.statList.length > 0)
			{
				if(this.savedSelection >= 0)
				{
					this.savedSelection = Math.min(this.savedSelection,this.statList.length - 1);
					this.statList.select(this.savedSelection,true);
				}
				else
				{
					this.statList.select(0,true);
				}
			}
		}
		
		public function getCurrentElement() : MovieClip
		{
			return this.statList.getCurrentMovieClip();
		}
		
		private function frame1() : *
		{
			this.statList = new scrollList("empty","empty");
			this.statList.m_scrollbar_mc.ScaleBG = true;
			this.statList.EL_SPACING = 0;
			this.statList.TOP_SPACING = 0;
			this.statList.SB_SPACING = -394;
			this.statList.m_customElementHeight = this.elementDist;
			this.statList.m_scrollbar_mc.m_scrollOverShoot = this.elementDist;
			this.container_mc.addChild(this.statList);
			this.statList.setFrame(380,725);
			this.statList.m_cyclic = true;
			this.setListSort();
			this.base = parent as MovieClip;
		}
	}
}
