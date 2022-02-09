package controls.buttons
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import LS_Classes.tooltipHelper;
	import flash.geom.Point;
	import controls.dropdowns.HiddenDropdown;
	import controls.dropdowns.DropdownItemData;
	import controls.dropdowns.TopHeader;
	import interfaces.IDropdownButton;

	public dynamic class ToggleDropdownButton extends MovieClip
	{
		public var button_graphic:IDropdownButton;
		public var combo_mc:HiddenDropdown;
		public var title_mc:TopHeader;
		public var tooltip:String;
		public var id:Number;
		public var callbackId:String;

		public var tooltipOverrideW:Number;
		public var tooltipYOffset:Number;
		public var tooltipSide:String = "left";

		private var _isEnabled:Boolean = false;
		
		public function get isEnabled():Boolean
		{
			return this._isEnabled;
		}

		public function set isEnabled(v:Boolean):void
		{
			this._isEnabled = v;
			this.combo_mc.m_enabled = v;
			if(this.disabled_mc)
			{
				this.disabled_mc.visible = !v;
			}
		}

		public function ToggleDropdownButton()
		{
			super();
		}

		public function _init(graphics_mc:IDropdownButton) : void
		{
			this.button_graphic = graphics_mc;

			this.title_mc = new TopHeader();
			this.title_mc.visible = false;
			this.title_mc.y = -this.title_mc.height;

			this.combo_mc = new HiddenDropdown(graphics_mc);
			this.combo_mc.positionListFunc = this.positionList;
			//this.combo_mc.m_selectContainer.x = -this.combo_mc.m_selectContainer.width;
			this.combo_mc.m_dropOutYDisplacement = -2;
			this.combo_mc.bgHSpacing = 24;
			this.combo_mc.header_mc = this.title_mc;

			this.addChild(combo_mc);
			combo_mc.m_selectContainer.addChild(title_mc);

			this.combo_mc.addEventListener(Event.CHANGE,this.onChange);
			this.combo_mc.addEventListener(Event.OPEN,this.onOpen);
			this.combo_mc.addEventListener(Event.CLOSE,this.onClose);

			this.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT,MainTimeline.Instance.onMouseOutTooltip);
		}

		public function setText(tooltipText:String = "") : *
		{
			this.tooltip = tooltipText;
			if(this.button_graphic)
			{
				(this.button_graphic as MovieClip).tooltip = this.tooltip;
			}
		}
		
		public function get length() : uint
		{
			if(this.combo_mc) {
				return this.combo_mc.m_scrollList.length;
			}
			return 0;
		}
		
		public function onOpen(e:Event) : *
		{
			if(MainTimeline.Instance.curTooltip == this.tooltip) {
				Registry.ExtCall("hideTooltip");
			}
			this.title_mc.visible = true;
		}
		
		public function onClose(e:Event) : *
		{
			this.title_mc.visible = false;
		}
		
		public function onChange(e:Event) : *
		{
			var entry:MovieClip = this.combo_mc.selectedMc;
			if(entry) {
				Registry.ExtCall(this.callbackId, entry.id, this.combo_mc.selectedIndex);
			}
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
			if(this.isEnabled && this.tooltip != null && this.tooltip != "" && !this.combo_mc.m_isOpen)
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
			// pos = this.title_mc.globalToLocal(new Point(0, 0));
            // this.title_mc.x = pos.x;
            // this.title_mc.y = pos.y - this.title_mc.height;
		}

		public function removeAll() : void
		{
			if(this.combo_mc) {
				this.combo_mc.removeAll();
			}
		}
	}
}