package optionsSettings_c_fla
{
	import LS_Classes.scrollList;
	import LS_Classes.selector;
	import LS_Classes.textEffect;
	import com.flashdynamix.motion.TweensyTimelineZero;
	import com.flashdynamix.motion.TweensyZero;
	import fl.motion.easing.Sine;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class overview_mc_1 extends MovieClip
	{
		//public var buttonHint_mc:BtnHintContainer;
		public var buttonHint_mc:MovieClip;
		public var listHolderSB_mc:emptyBG;
		public var listHolder_mc:emptyBG;
		public var title_txt:TextField;
		public var tooltip_txt:TextField;
		public var closeTimeLine:TweensyTimelineZero;
		public var checkBoxOptions:Array;
		public var opened:Boolean;
		public var Root;
		public var selectedID:Number;
		public var totalHeight:Number;
		public var maxWidth:Number;
		public var factor:Number;
		public var elementHeight:Number;
		public var topDist:Number;
		public var list:scrollList;
		public var base:MovieClip;
		public const elementX:Number = 0;
		public const WidthSpacing:Number = 80;
		public const HeightSpacing:Number = 40;
		public var elementHSpacing:Number;
		public var minWidth:Number;
		public const infoH:Number = 70;
		public const infoW:Number = 775;
		public var tooltipTextScrollV:Number;
		public var tooltipTextScrollMax:Number;
		public var timeOut:Number;
		public var scrollDown:Boolean;
		public var hasListener:Boolean;
		public var InfoTimeOut:Number;
		
		public function overview_mc_1()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function setMainScrolling(param1:Boolean) : *
		{
			this.list.mouseWheelEnabled = param1;
		}
		
		public function addCheckBoxOptions(param1:String) : *
		{
			this.checkBoxOptions.push(param1);
		}
		
		public function cancelPressed() : *
		{
			this.closeMenu();
		}
		
		public function addingDone() : *
		{
			var val1:Number = NaN;
			var val2:MovieClip = null;
			if(this.list.length > 0)
			{
				this.list.select(0,true,true);
				this.list.m_scrollbar_mc.scrollbarVisible();
				val1 = 0;
				while(val1 < this.list.content_array.length)
				{
					val2 = this.list.content_array[val1];
					if(val2 && val2.selList)
					{
						val2.selList.TweenDuration = 0.3;
					}
					val1++;
				}
			}
		}
		
		public function applyPressed() : *
		{
			ExternalInterface.call("soundEvent","UI_Gen_Accept");
			ExternalInterface.call("applyPressed");
		}
		
		public function okPressed() : *
		{
			ExternalInterface.call("soundEvent","UI_Gen_Accept");
			ExternalInterface.call("acceptPressed");
		}
		
		public function openMenu() : *
		{
			ExternalInterface.call("soundEvent","UI_Generic_Open");
			TweensyZero.to(this,{"alpha":1},0.6);
		}
		
		public function closeMenu() : *
		{
			ExternalInterface.call("PlaySound","UI_Gen_Back");
			this.closeTimeLine = TweensyZero.to(this,{"alpha":0},0.3,Sine.easeIn);
			this.closeTimeLine.onComplete = this.destroyMenu;
		}
		
		public function destroyMenu() : *
		{
			ExternalInterface.call("requestCloseUI");
		}
		
		public function setTitle(param1:String) : *
		{
			this.title_txt.htmlText = param1.toUpperCase();
		}
		
		public function addMenuCheckbox(id:Number, label:String, enabled:Boolean, state:Number, param5:Boolean, tooltip:String) : *
		{
			var val8:* = undefined;
			this.addMenuSelector(id,label,tooltip);
			var val7:MovieClip = this.getElementByID(id);
			if(val7)
			{
				val7.isCheckBox = true;
				this.setMenuDropDownEnabled(id,enabled);
				this.setMenuDropDownTooltip(id,tooltip,true);
				val8 = 0;
				while(val8 < this.checkBoxOptions.length)
				{
					this.addMenuSelectorEntry(id,this.checkBoxOptions[val8]);
					val8++;
				}
				this.selectMenuSelectorEntry(id,state);

				ExternalInterface.call("controlAdded", "checkbox", val7.id, val7.list_pos, "list", enabled);
			}
		}
		
		public function resetBG() : *
		{
			var val1:MovieClip = null;
			if(this.list.length > 0)
			{
				val1 = this.list.content_array[this.list.length - 1];
				if(val1)
				{
					this.list.m_scrollbar_mc.customPaneHeight = val1.y + val1.heightOverride + this.topDist;
				}
			}
		}
		
		public function setMenuCheckbox(param1:Number, param2:Boolean, param3:Number) : *
		{
			this.selectMenuSelectorEntry(param1,param3);
			this.setMenuDropDownEnabled(param1,param2);
		}
		
		public function addMenuInfoLabel(id:Number, label:String, info:String, tooltip:String = "", fixedHeight:Number = -1) : *
		{
			var label_info_mc:MovieClip = this.getElementByID(id);
			if(!label_info_mc)
			{
				label_info_mc = new LabelInfo();
				label_info_mc.heightOverride = fixedHeight > -1 ? fixedHeight : 104;
				label_info_mc.id = id;
				label_info_mc.info_txt.autoSize = TextFieldAutoSize.LEFT;
				this.list.addElement(label_info_mc,true,false);
			}
			if(label_info_mc)
			{
				label_info_mc.x = this.elementX;
				label_info_mc.label_txt.htmlText = label;
				label_info_mc.info_txt.htmlText = info;
				label_info_mc.name = "item" + this.list.length + "_mc";
				if(label_info_mc.label_txt.textWidth > this.minWidth)
				{
					if(this.maxWidth < label_info_mc.label_txt.textWidth)
					{
						this.maxWidth = label_info_mc.label_txt.textWidth;
					}
				}
				else
				{
					this.maxWidth = this.minWidth;
				}
				ExternalInterface.call("controlAdded", "menuInfoLabel", label_info_mc.id, label_info_mc.list_pos, "list");
			}
			this.resetBG();
		}
		
		public function addMenuLabel(text:String, tooltip:String = "", fixedHeight:Number = -1, topSpacing:Number = 0) : *
		{
			var label_mc:Label = new Label();
			if(fixedHeight && fixedHeight > -1)
			{
				label_mc.heightOverride = fixedHeight;
			} 
			else
			{
				if(this.list.size != 0)
				{
					label_mc.heightOverride = this.elementHeight * 2;
				}
				else
				{
					label_mc.heightOverride = this.elementHeight;
					label_mc.label_txt.y = 0;
				}
			}
			if(topSpacing) {
				label_mc.heightOverride = label_mc.heightOverride + topSpacing;
				label_mc.label_txt.y = label_mc.label_txt.y + topSpacing;
			}
			label_mc.x = this.elementX;
			label_mc.label_txt.htmlText = text;
			label_mc.name = "item" + this.list.length + "_mc";
			if(label_mc.label_txt.textWidth > this.minWidth)
			{
				if(this.maxWidth < label_mc.label_txt.textWidth)
				{
					this.maxWidth = label_mc.label_txt.textWidth;
				}
			}
			else
			{
				this.maxWidth = this.minWidth;
			}
			label_mc.tooltip = tooltip;
			this.list.addElement(label_mc,true,false);
			this.resetBG();
			ExternalInterface.call("controlAdded", "menuLabel", label_mc.name, label_mc.list_pos, "list", text);
		}
		
		public function addMenuSelector(id:Number, label:String, tooltip:String, fixedHeight:Number = -1) : *
		{
			var selector_mc:MovieClip = new SelectorMC();
			this.list.addElement(selector_mc);
			selector_mc.selList = new selector();
			selector_mc.cont_mc.addChild(selector_mc.selList);
			selector_mc.selList.align = "right";
			selector_mc.selList.id = id;
			selector_mc.selList.centeredElements = true;
			selector_mc.selList.TweenDuration = 0.01;
			selector_mc.heightOverride = fixedHeight > -1 ? fixedHeight : this.elementHeight;
			selector_mc.x = this.elementX;
			selector_mc.left_mc.visible = false;
			selector_mc.right_mc.visible = false;
			selector_mc.label_txt.htmlText = label;
			selector_mc.id = id;
			selector_mc.name = "item" + this.list.length + "_mc";
			selector_mc.hl_mc.visible = false;
			selector_mc.biggestWidth = 0;
			selector_mc.isCheckBox = false;
			selector_mc.enabled = true;
			this.setMenuDropDownTooltip(id,tooltip,true);
			if(selector_mc.label_txt.textWidth > this.minWidth)
			{
				if(this.maxWidth < selector_mc.label_txt.textWidth)
				{
					this.maxWidth = selector_mc.label_txt.textWidth;
				}
			}
			else
			{
				this.maxWidth = this.minWidth;
			}
			this.resetBG();
			ExternalInterface.call("controlAdded", "menuSelector", selector_mc.id, selector_mc.list_pos, "list", true);
		}
		
		public function addMenuSelectorEntry(id:Number, text:String) : *
		{
			var select_element_mc:MovieClip = null;
			var w:Number = 300;
			var selector_mc:MovieClip = this.getElementByID(id);
			if(selector_mc)
			{
				select_element_mc = new SelectElementMC();
				select_element_mc.label_txt.autoSize = TextFieldAutoSize.LEFT;
				select_element_mc.label_txt.htmlText = text;
				if(w < select_element_mc.label_txt.textWidth)
				{
					select_element_mc.label_txt.autoSize = TextFieldAutoSize.NONE;
					select_element_mc.label_txt.width = w;
				}
				select_element_mc.container = selector_mc;
				select_element_mc.label_txt.x = -Math.round(select_element_mc.label_txt.width * 0.5);
				selector_mc.AddElement(select_element_mc);
				this.resetBG();
				ExternalInterface.call("controlAdded", "menuLabel", selector_mc.id, selector_mc.list_pos, "selList", id);
			}
		}
		
		public function selectMenuSelectorEntry(id:Number, entry_index:Number) : *
		{
			var selector_mc:MovieClip = this.getElementByID(id);
			if(selector_mc)
			{
				selector_mc.selList.select(entry_index);
			}
		}
		
		public function onComboClose(e:Event) : *
		{
			(root as MovieClip).selectedInfo_txt.visible = false;
			this.setMainScrolling(true);
		}
		
		public function onComboOpen(e:Event) : *
		{
			this.setMainScrolling(false);
		}
		
		public function onComboScrolled(e:Event) : *
		{
			(root as MovieClip).selectedInfo_txt.visible = false;
		}
		
		public function clearMenuDropDownEntries(id:Number) : *
		{
			var selector_mc:MovieClip = this.getElementByID(id);
			if(selector_mc)
			{
				selector_mc.selList.clearElements();
			}
		}
		
		public function setMenuDropDownEnabled(param1:Number, param2:Boolean) : *
		{
			var val3:MovieClip = this.getElementByID(param1);
			if(val3)
			{
				if(val3.left_mc)
				{
					val3.left_mc.alpha = !!param2?1:0;
					val3.right_mc.alpha = !!param2?1:0;
					val3.cont_mc.alpha = !!param2?1:0.3;
				}
				val3.enabled = param2;
			}
		}
		
		public function setMenuDropDownDisabledTooltip(param1:Number, param2:String) : *
		{
			this.setMenuDropDownTooltip(param1,param2,false);
		}
		
		public function setMenuDropDownTooltip(param1:Number, param2:String, param3:Boolean) : *
		{
			var val4:MovieClip = this.getElementByID(param1);
			if(val4)
			{
				if(param3)
				{
					val4.enabledTooltip = param2;
				}
				else
				{
					val4.disabledTooltip = param2;
				}
				val4.onOver = this.ddShowTooltip;
				val4.onOut = this.ddHideTooltip;
			}
		}
		
		public function ddShowTooltip(param1:MovieClip) : *
		{
			if(param1.enabled && param1.enabledTooltip)
			{
				this.tooltip_txt.htmlText = param1.enabledTooltip;
				this.tooltip_txt.textColor = 16777215;
			}
			if(!param1.enabled && param1.disabledTooltip)
			{
				this.tooltip_txt.htmlText = param1.disabledTooltip;
				this.tooltip_txt.textColor = 16646144;
			}
			this.checkInfoScrolling();
		}
		
		public function stopTooltipScrolling() : *
		{
			this.tooltipTextScrollV = 0;
			this.tooltip_txt.scrollRect = new Rectangle(0,this.tooltipTextScrollV,this.infoW,this.infoH);
			this.timeOut = 1;
			this.scrollDown = true;
			if(this.hasListener)
			{
				removeEventListener(Event.ENTER_FRAME,this.onTooltipFrameScroll);
				this.hasListener = false;
			}
		}
		
		public function init() : *
		{
			this.tooltip_txt.autoSize = TextFieldAutoSize.CENTER;
			this.InfoTimeOut = 160 * 60 / stage.frameRate;
			this.buttonHint_mc.centerButtons = true;
			this.buttonHint_mc.containerMaxWidth = 1000;
		}
		
		public function checkInfoScrolling() : *
		{
			if(this.infoH < this.tooltip_txt.textHeight)
			{
				this.tooltipTextScrollMax = this.tooltip_txt.textHeight - this.infoH;
				if(!this.hasListener)
				{
					addEventListener(Event.ENTER_FRAME,this.onTooltipFrameScroll);
					this.hasListener = true;
				}
			}
			else
			{
				this.stopTooltipScrolling();
			}
		}
		
		public function onTooltipFrameScroll(param1:Event) : *
		{
			if(this.timeOut > 0 && this.timeOut < this.InfoTimeOut)
			{
				this.timeOut++;
			}
			else if(this.scrollDown)
			{
				if(this.tooltipTextScrollV >= this.tooltipTextScrollMax)
				{
					this.scrollDown = false;
					this.timeOut = 1;
				}
				else
				{
					this.tooltipTextScrollV++;
					this.tooltip_txt.scrollRect = new Rectangle(0,this.tooltipTextScrollV,this.infoW,this.infoH);
				}
			}
			else if(this.tooltipTextScrollV <= 1)
			{
				this.timeOut = 1;
				this.scrollDown = true;
			}
			else
			{
				this.tooltipTextScrollV--;
				this.tooltip_txt.scrollRect = new Rectangle(0,this.tooltipTextScrollV,this.infoW,this.infoH);
			}
		}
		
		public function ddHideTooltip() : *
		{
			this.stopTooltipScrolling();
			this.tooltip_txt.htmlText = "";
		}
		
		public function roundFloat(param1:Number) : Number
		{
			return Math.round(param1 * 100) / 100;
		}
		
		public function addMenuSlider(id:Number, label:String, value:Number, min:Number, max:Number, interval:Number, disabled:Boolean, tooltip:String, fixedHeight:Number = -1) : *
		{
			var val10:Number = NaN;
			var slider_mc:MovieClip = new SliderComp();
			slider_mc.x = this.elementX;
			slider_mc.label_txt.htmlText = label;
			slider_mc.id = id;
			slider_mc.name = "item" + this.list.length + "_mc";
			slider_mc.heightOverride = fixedHeight > -1 ? fixedHeight : 104;
			slider_mc.tooltip = tooltip;
			slider_mc.slider_mc.maximum = this.roundFloat(max);
			slider_mc.slider_mc.minimum = this.roundFloat(min);
			slider_mc.min_txt.htmlText = String(this.roundFloat(min));
			slider_mc.max_txt.htmlText = String(this.roundFloat(max));
			slider_mc.slider_mc.snapInterval = this.roundFloat(interval);
			slider_mc.hl_mc.visible = false;
			slider_mc.amount_txt.visible = !disabled;
			slider_mc.min_txt.visible = !disabled;
			slider_mc.max_txt.visible = !disabled;
			slider_mc.slider_mc.bgToWidthDiff = -20;
			if(interval != 0)
			{
				val10 = (max - min) / interval;
				if(val10 <= 10)
				{
					slider_mc.slider_mc.m_NotchLeftOffset = 9;
					slider_mc.slider_mc.useNotches = true;
					slider_mc.slider_mc.m_notches_mc.y = 11;
				}
				else
				{
					slider_mc.slider_mc.useNotches = false;
				}
			}
			slider_mc.slider_mc.liveDragging = true;
			slider_mc.amount_txt.htmlText = this.roundFloat(value);
			if(max > 50)
			{
				slider_mc.slider_mc.tickInterval = 10;
			}
			else if(max > 20)
			{
				slider_mc.slider_mc.tickInterval = 5;
			}
			else
			{
				slider_mc.slider_mc.tickInterval = 1;
			}
			slider_mc.amount_txt.mouseEnabled = false;
			slider_mc.min_txt.mouseEnabled = false;
			slider_mc.max_txt.mouseEnabled = false;
			if(slider_mc.label_txt.textWidth > this.minWidth)
			{
				if(this.maxWidth < slider_mc.label_txt.textWidth)
				{
					this.maxWidth = slider_mc.label_txt.textWidth;
				}
			}
			else
			{
				this.maxWidth = this.minWidth;
			}
			this.list.addElement(slider_mc);
			this.setMenuDropDownTooltip(id,tooltip,true);
			this.resetBG();
			slider_mc.slider_mc.value = value;
			slider_mc.resetAmountPos();
			ExternalInterface.call("controlAdded", "slider", slider_mc.id, slider_mc.list_pos, "list", !disabled);
		}
		
		public function setMenuSlider(param1:Number, param2:Number) : *
		{
			var val3:MovieClip = this.getElementByID(param1);
			if(val3 && val3.slider_mc)
			{
				val3.slider_mc.value = param2;
				val3.amount_txt.htmlText = this.roundFloat(param2);
				val3.resetAmountPos();
			}
		}
		
		public function getElementByID(param1:Number) : MovieClip
		{
			return this.list.getElementByNumber("id",param1);
		}
		
		public function addMenuButton(id:Number, displayName:String, enabled:Boolean, tooltip:String = "", fixedHeight:Number = -1) : *
		{
			var button:MovieClip = this.list.getElementByNumber("id", id);
			if (button == null)
			{
				button = new Menu_button();
				button.heightOverride = fixedHeight > -1 ? fixedHeight : this.elementHeight;
				button.x = this.elementX;
				button.label_txt.htmlText = displayName;
				button.id = id;
				button.name = "item" + this.list.length + "_mc";
				if (tooltip != "") {
					button.enabledTooltip = tooltip;
					button.onOver = this.ddShowTooltip;
					button.onOut = this.ddHideTooltip;
				}
				if(button.label_txt.textWidth > this.minWidth)
				{
					if(this.maxWidth < button.label_txt.textWidth)
					{
						this.maxWidth = button.label_txt.textWidth;
					}
				}
				else
				{
					this.maxWidth = this.minWidth;
				}
				button.disable_mc.visible = !enabled;
				button.bg_mc.visible = enabled;
				this.list.addElement(button);
				this.resetBG();
				ExternalInterface.call("controlAdded", "button", button.id, button.list_pos, "list", enabled);
			}
			else
			{
				button.label_txt.htmlText = displayName;
				if (tooltip != "") {
					button.enabledTooltip = tooltip;
					button.onOver = this.ddShowTooltip;
					button.onOut = this.ddHideTooltip;
				}
				button.disable_mc.visible = !enabled;
				button.bg_mc.visible = enabled;
			}
		}
		
		public function setButtonEnabled(id:Number, b:Boolean) : *
		{
			var button_mc:MovieClip = this.getElementByID(id);
			if(button_mc)
			{
				button_mc.disable_mc.visible = !b;
				button_mc.bg_mc.visible = b;
			}
		}
		
		public function moveCursor(backwards:Boolean) : *
		{
			ExternalInterface.call("PlaySound","UI_Gen_CursorMove");
			if(backwards)
			{
				this.list.previous();
			}
			else
			{
				this.list.next();
			}
			this.setListLoopable(false);
		}
		
		public function setListLoopable(b:Boolean) : *
		{
			this.list.m_cyclic = b;
		}
		
		public function setCursorPosition(id:Number) : *
		{
			var mc:MovieClip = this.getElementByID(id);
			if(mc)
			{
				this.list.selectMC(mc);
			}
		}
		
		public function executeSelected() : *
		{
			var val1:MovieClip = this.list.getCurrentMovieClip();
			if(val1)
			{
				val1.buttonPressed(null);
			}
		}
		
		public function removeItems() : *
		{
			this.list.clearElements();
			this.totalHeight = 0;
			this.maxWidth = 0;
		}
		
		public function frame1() : *
		{
			this.title_txt.filters = textEffect.createStrokeFilter(0,1.2,1,1.4,3);
			this.checkBoxOptions = new Array();
			this.opened = false;
			this.Root = this;
			this.selectedID = 0;
			this.totalHeight = 0;
			this.maxWidth = 0;
			this.factor = 30;
			this.elementHeight = 52;
			this.topDist = 0;
			this.list = new scrollList();
			this.list.m_forceDepthReorder = true;
			this.list.SB_SPACING = 50;
			this.list.EL_SPACING = 0;
			this.list.setFrame(1092,676);
			this.listHolderSB_mc.addChild(this.list.m_scrollbar_mc);
			this.list.m_cyclic = true;
			this.list.m_scrollbar_mc.m_initialScrollDelay = 200;
			this.list.m_scrollbar_mc.m_SCROLLSPEED = this.elementHeight;
			this.list.m_scrollbar_mc.m_animateScrolling = true;
			this.list.m_scrollbar_mc.ScaleBG = true;
			this.list.m_scrollbar_mc.m_scrollOverShoot = this.list.m_scrollbar_mc.m_SCROLLSPEED;
			this.list.m_cyclic = true;
			this.base = root as MovieClip;
			this.listHolder_mc.addChild(this.list);
			this.elementHSpacing = 10;
			this.minWidth = 400;
			this.tooltipTextScrollV = 0;
			this.tooltipTextScrollMax = 0;
			this.timeOut = 1;
			this.scrollDown = true;
			this.hasListener = false;
		}
	}
}
