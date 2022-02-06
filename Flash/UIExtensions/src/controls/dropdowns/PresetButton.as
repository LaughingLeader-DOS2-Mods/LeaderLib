package controls.dropdowns
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import LS_Classes.tooltipHelper;
	import controls.scrollbar.scrollbarDivider;
	import flash.geom.Point;

	public dynamic class PresetButton extends MovieClip
	{
		public var graphics_mc:PresetButtonGraphic;
		public var combo_mc:HiddenDropdown;
		public var tooltip:String;
		public var id:Number;
		public var tooltipOverrideW:Number;
		public var tooltipYOffset:Number;
		public var divider:MovieClip;

		public function PresetButton()
		{
			super();
			this.addFrameScript(0, this.frame1);
		}

		public function init() : void
		{
			this.combo_mc = new HiddenDropdown(this.graphics_mc);
			this.combo_mc.positionListFunc = this.positionList;
			//this.combo_mc.m_selectContainer.x = -this.combo_mc.m_selectContainer.width;
			this.combo_mc.m_dropOutYDisplacement = -2;
			this.combo_mc.bgHSpacing = -3;
			this.addChild(combo_mc);
		}

		public function setText(tooltipText:String = "") : *
		{
			this.tooltip = tooltipText;
			this.graphics_mc.tooltip = this.tooltip;
		}
		
		public function onOpen(e:Event) : *
		{
			Registry.ExtCall("hideTooltip");
		}
		
		public function onChange(e:Event) : *
		{
			var entry:MovieClip = this.combo_mc.selectedMc;
			Registry.ExtCall("LeaderLib_UIExtensions_PresetSelected", entry.id, this.combo_mc.selectedIndex);
		}
		
		public function deselectElement() : *
		{
		}
		
		public function selectElement() : *
		{
			Registry.ExtCall("PlaySound","UI_Generic_Over");
		}
		
		public function onMouseOver(e:MouseEvent) : *
		{
			if(this.tooltip != null && this.tooltip != "" && !this.combo_mc.m_isOpen)
			{
				this.tooltipYOffset = -4;
				this.tooltipOverrideW = MainTimeline.Instance.tooltipWidthOverride;
				tooltipHelper.ShowTooltipForMC(this,root,"left",MainTimeline.Instance.hasTooltip == false);
				MainTimeline.Instance.setHasTooltip(true, this.tooltip);
			}
		}

		public function addEntry(label:String, id:Number, tooltip:String = "") : int
		{
			var entryData:DropdownItemData = new DropdownItemData(label, id, tooltip);
			this.combo_mc.addItem(entryData);
			return this.combo_mc.m_scrollList.length - 1;
		}

		public function selectItemByID(id:Number, skipCallback:Boolean = false) : Boolean
		{
			return this.combo_mc.selectItemByID(id, skipCallback);
		}

		public function positionList(selectContainer:MovieClip) : void
		{
			var pos:Point = this.localToGlobal(new Point(0, 0));
			selectContainer.x = pos.x - selectContainer.width;
            selectContainer.y = Math.round(pos.y);
		}
		
		public function frame1() : void
		{
			this.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT,MainTimeline.Instance.onMouseOutTooltip);
			this.combo_mc.addEventListener(Event.CHANGE,this.onChange);
			this.combo_mc.addEventListener(Event.OPEN,this.onOpen);
			// this.divider = new scrollbarDivider();
			// this.divider.x = 241;
			// this.divider.y = 2;
			// this.combo_mc.divider = this.divider;
		}
	}
}