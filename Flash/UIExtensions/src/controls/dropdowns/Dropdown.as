package controls.dropdowns
{
	import LS_Classes.tooltipHelper;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import LS_Symbols.comboBox;
	import controls.scrollbar.scrollbarDivider;
	
	public dynamic class Dropdown extends MovieClip
	{
		public var combo_mc:comboBox;
		public var label_txt:TextField;
		public var div:MovieClip;
		public var tooltip:String;
		public var id:Number;
		
		public function Dropdown()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function setText(comboText:String = "", topLabelText:String = "", tooltipText:String = "") : *
		{
			this.combo_mc.text = comboText;
			this.label_txt.htmlText = topLabelText;
			this.label_txt.visible = topLabelText == "";
			this.tooltip = tooltipText;
		}
		
		public function onOpen(e:Event) : *
		{
			ExternalInterface.call("hideTooltip");
		}
		
		public function onChange(e:Event) : *
		{
			var entry:MovieClip = this.combo_mc.selectedMc;
			ExternalInterface.call("LeaderLib_UIExtensions_OnControl", "Dropdown", this.id, this.combo_mc.selectedIndex, entry.id);
		}
		
		public function deselectElement(e:MouseEvent=null) : *
		{
		}
		
		public function selectElement(e:MouseEvent=null) : *
		{
			ExternalInterface.call("PlaySound","UI_Generic_Over");
		}
		
		public function onMouseOver(e:MouseEvent) : *
		{
			if(this.tooltip != null && this.tooltip != "" && !this.combo_mc.m_isOpen)
			{
				MainTimeline.Instance.curTooltip = this.tooltip;
				this.tooltipYOffset = -4;
				this.tooltipOverrideW = MainTimeline.Instance.ElW;
				tooltipHelper.ShowTooltipForMC(this,root,"bottom",MainTimeline.Instance.hasTooltip == false);
			}
		}

		public function addEntry(label:String, id:Number) : int
		{
			var entryData:DropdownItemData = new DropdownItemData(label, id);
			this.combo_mc.addItem(entryData);
			return this.combo_mc.m_scrollList.length - 1;
		}

		public function selectItemByID(id:Number) : Boolean
		{
			return this.combo_mc.selectItemByID(id);
		}
		
		public function frame1() : void
		{
			this.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT,MainTimeline.Instance.onMouseOutTooltip);
			this.combo_mc.addEventListener(Event.CHANGE,this.onChange);
			this.combo_mc.addEventListener(Event.OPEN,this.onOpen);
			this.combo_mc.m_dropOutYDisplacement = -2;
			this.combo_mc.bgHSpacing = -3;
			this.div = new scrollbarDivider();
			this.div.x = 241;
			this.div.y = 2;
			this.combo_mc.divider = this.div;
		}
	}
}
