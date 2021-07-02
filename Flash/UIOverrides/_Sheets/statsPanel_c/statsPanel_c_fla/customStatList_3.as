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
		}
		
		public function updateHints() : *
		{
		}
		
		public function addStat(param1:Number, param2:String, param3:String, param4:uint) : *
		{
			var val5:MovieClip = this.statList.getElementByNumber("id",param1);
			if(!val5)
			{
				val5 = new CustomStat();
				val5.statId = param1;
				this.statList.addElement(val5,true);
				val5.isStat = true;
				val5.id = param1;
				val5.label_txt.autoSize = TextFieldAutoSize.LEFT;
				val5.label_txt.wordWrap = true;
				val5.label_txt.multiline = true;
				val5.hl_mc.visible = false;
			}
			val5.label_txt.htmlText = param2;
			val5.textStr = val5.label_txt.text;
			val5.val_txt.htmlText = param3;
			val5.label_txt.textColor = param4;
			val5.val_txt.textColor = param4;
			val5.heightOverride = Math.ceil(val5.label_txt.textHeight / this.elementDist) * this.elementDist;
			val5.hl_mc.height = val5.label_txt.textHeight + val5.label_txt.y;
			val5.line_mc.y = val5.hl_mc.height - Math.round(val5.line_mc.height * 0.5) - 3;
		}
		
		public function removeStats() : *
		{
			this.savedSelection = this.statList.currentSelection;
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
		
		function frame1() : *
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
