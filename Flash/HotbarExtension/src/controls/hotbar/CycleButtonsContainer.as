package controls.hotbar
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class CycleButtonsContainer extends MovieClip
	{
		public var downBtn_mc:BrowseButtonDown;
		public var text_txt:TextField;
		public var upBtn_mc:BrowseButtonUp;
		private var _currentHotBarIndex:uint = 1;
		public var maxHotbarIndex:uint = 5;

		private var _hotbar:Hotbar;
		public function get hotbar():Hotbar
		{
			if(!_hotbar) {
				_hotbar = parent as Hotbar;
			}
			return _hotbar;
		}

		public function get currentHotBarIndex():uint
		{
			return this._currentHotBarIndex;
		}

		public function set currentHotBarIndex(v:uint):void
		{
			if (this._currentHotBarIndex != v) {
				this._currentHotBarIndex = v;
				Registry.ExtCall("LeaderLib_Hotbars_CycleHotbar", this.hotbar.id, this._currentHotBarIndex);
			}
		}
		
		public function CycleButtonsContainer()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function showUpTooltip() : *
		{
			if(this.upBtn_mc.tooltip != "")
			{
				Registry.ExtCall("showTooltip",this.upBtn_mc.tooltip);
				MainTimeline.Instance.setHasTooltip(true, this.upBtn_mc.tooltip);
			}
		}
		
		public function showDownTooltip() : *
		{
			if(this.downBtn_mc.tooltip != "")
			{
				Registry.ExtCall("showTooltip",this.downBtn_mc.tooltip);
				MainTimeline.Instance.setHasTooltip(true, this.downBtn_mc.tooltip);
			}
		}
		
		public function hideTooltip() : *
		{
			Registry.ExtCall("hideTooltip");
			MainTimeline.Instance.setHasTooltip(false);
		}
		
		public function onInit() : *
		{
			this.upBtn_mc.initialize("",this.cycleHotBar,false);
			this.downBtn_mc.initialize("",this.cycleHotBar,true);
			this.setCurrentBar(1);
			this.upBtn_mc.onOverFunc = this.showUpTooltip;
			this.downBtn_mc.onOverFunc = this.showDownTooltip;
			this.upBtn_mc.onOutFunc = this.hideTooltip;
			this.downBtn_mc.onOutFunc = this.hideTooltip;
		}
		
		public function setCurrentBar(index:uint) : *
		{
			this.text_txt.htmlText = String(this.currentHotBarIndex);
			this.currentHotBarIndex = index;
		}
		
		public function setMaxBarIndex(maxIndex:uint) : *
		{
			this.maxHotbarIndex = maxIndex;
		}
		
		public function cycleHotBar(previous:Boolean = false) : *
		{
			if(previous)
			{
				this._currentHotBarIndex--;
				if(this._currentHotBarIndex < 1)
				{
					this._currentHotBarIndex = maxHotbarIndex;
				}
			}
			else
			{
				this._currentHotBarIndex++;
				if(this._currentHotBarIndex > maxHotbarIndex)
				{
					this._currentHotBarIndex = 1;
				}
			}
			this.text_txt.htmlText = String(this._currentHotBarIndex);
			Registry.ExtCall("LeaderLib_Hotbars_CycleHotbar", this.hotbar.id, this._currentHotBarIndex);
		}
		
		public function frame1() : *
		{
			this.text_txt.mouseEnabled = false;
		}
	}
}
