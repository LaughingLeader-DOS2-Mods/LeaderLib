package optionsSettings_fla
{
	import LS_Classes.larTween;
	import LS_Classes.listDisplay;
	import LS_Classes.scrollList;
	import LS_Classes.textEffect;
	import fl.motion.easing.Sine;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	//LeaderLib Changes: Added controlAdded calls whenever a control is created.
	public dynamic class overview_mc_1 extends MovieClip
	{
		public var Xclose_mc:MovieClip;
		public var apply_mc:MovieClip;
		public var applyCopy:MovieClip;
		public var cancel_mc:MovieClip;
		public var listHolder_mc:emptyBG;
		public var menuButtonContainer_mc:emptyBG;
		public var ok_mc:MovieClip;
		public var title_txt:TextField;
		public var toptitle_txt:TextField;
		public const hlColour:uint = 0;
		public const defaultColour:uint = 14077127;
		public const menuButtonContainerCenterPos:Point = new Point(176,156);
		public var closeTimeLine:larTween;
		public var opened:Boolean;
		public var Root:MovieClip;
		public var selectedID:Number;
		public var totalHeight:Number;
		public var maxWidth:Number;
		public var factor:Number;
		public var elementHeight:Number;
		public var topDist:Number;
		public var list:scrollList;
		public var menuBtnList:listDisplay;
		public var base:MovieClip;
		public var HLCounter:Number;
		public const elementX:Number = 0;
		public const WidthSpacing:Number = 80;
		public const HeightSpacing:Number = 40;
		public var elementHSpacing:Number;
		public var minWidth:Number;
		
		public function overview_mc_1()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function setMainScrolling(param1:Boolean) : *
		{
			this.list.mouseWheelEnabled = param1;
		}
		
		public function moveOptionButtonTo(id:Number, index:Number = 0) : *
		{
			var btn:MovieClip = this.menuBtnList.getElementByNumber("buttonID", id);
			if (btn != null)
			{
				this.menuBtnList.content_array.splice(btn.list_pos, 1);
				if (index <= 0)
				{
					this.menuBtnList.content_array.unshift(btn);
				}
				else
				{
					this.menuBtnList.content_array.splice(index, 1, btn);
				}
				btn.list_pos = index;
				var i:uint = 0;
				while(i < this.menuBtnList.content_array.length)
				{
					btn = this.menuBtnList.content_array[i];
					if (btn != null)
					{
						btn.list_pos = i;
					}
					i++;
				}
			}
		}

		public function addOptionButton(label:String, actionID:String, buttonID:Number, isCurrent:Boolean, addToStart:Boolean = false, setDisabled:Boolean = false) : *
		{
			var btn:MovieClip = this.menuBtnList.getElementByNumber("buttonID", buttonID);
			if (btn == null)
			{
				btn = new menuButton();
				btn.interactiveTextOnClick = true;
				btn.SND_Click = "UI_Gen_BigButton_Click";
				btn.initialize(label.toUpperCase(),function(arr:Array):*
				{
					ExternalInterface.call(actionID,buttonID);
				},null,isCurrent,-1,isCurrent);
				btn.buttonID = buttonID;
				if(addToStart) {
					this.menuBtnList.addElementToFront(btn, true);
					btn.list_id = 0;
				} else {
					this.menuBtnList.addElement(btn,true);
				}
				this.menuButtonContainer_mc.x = this.menuButtonContainerCenterPos.x - this.menuBtnList.width * 0.5;
				this.menuButtonContainer_mc.y = this.menuButtonContainerCenterPos.y;
				ExternalInterface.call("controlAdded", "optionButton", btn.buttonID, btn.list_pos, "menuBtnList", !setDisabled);
			}
			else
			{
				//btn.text_txt.htmlText = label.toUpperCase();
				btn.initialize(label.toUpperCase(),function(arr:Array):*
				{
					ExternalInterface.call(actionID,buttonID);
				},null,isCurrent,-1,isCurrent);
			}

			if(btn && setDisabled)
			{
				btn.bg_mc.visible = true;
				btn.activeBG_mc.visible = false;
				btn.m_Active = false;
				btn.setEnabled(false);
			}
		}
		
		public function cancelPressed() : *
		{
			ExternalInterface.call("requestCloseUI");
		}
		
		public function applyPressed() : *
		{
			if(base.currentMenuID == base.MOD_MENU_ID)
			{
				//Prevent the engine from commiting changes from other menus
				ExternalInterface.call("applyModMenuChanges");

				if (this.applyCopy && this.applyCopy.bg_mc.visible)
				{
					this.applyCopy.onOut();
				}
			}
			else
			{
				this.apply_mc.onOut();
				ExternalInterface.call("applyPressed");
			}
			
			ExternalInterface.call("PlaySound","UI_Gen_Apply");
		}
		
		public function okPressed() : *
		{
			if(base.currentMenuID == base.MOD_MENU_ID)
			{
				//Prevent the engine from commiting changes from other menus
				ExternalInterface.call("commitModMenuChanges");
			}
			else
			{
				ExternalInterface.call("acceptPressed");
			}
			ExternalInterface.call("PlaySound","UI_Gen_Accept");
		}
		
		public function openMenu() : *
		{
			ExternalInterface.call("soundEvent","UI_Generic_Open");
			this.closeTimeLine = new larTween(this,"alpha",Sine.easeOut,NaN,1,0.3);
		}
		
		public function closeMenu() : *
		{
			ExternalInterface.call("PlaySound","UI_Gen_Back");
			this.closeTimeLine = new larTween(this,"alpha",Sine.easeIn,NaN,0,0.2,this.destroyMenu);
		}
		
		public function destroyMenu() : *
		{
			ExternalInterface.call("requestCloseUI");
		}
		
		public function setTitle(param1:String) : *
		{
			this.title_txt.htmlText = param1.toUpperCase();
		}
		
		public function addMenuCheckbox(id:Number, label:String, enabled:Boolean, state:Number, filterBool:Boolean, tooltip:String) : *
		{
			var checkbox_mc:MovieClip = new Checkbox();
			checkbox_mc.x = this.elementX;
			checkbox_mc.label_txt.htmlText = label;
			checkbox_mc.id = id;
			checkbox_mc.name = "item" + this.list.length + "_mc";
			checkbox_mc.mHeight = 30;
			checkbox_mc.filterBool = filterBool;
			checkbox_mc.stateID = state;
			checkbox_mc.tooltip = tooltip;
			checkbox_mc.bg_mc.gotoAndStop(state * 3 + 1);
			this.totalHeight = this.totalHeight + (checkbox_mc.mHeight + this.elementHSpacing);
			if(checkbox_mc.label_txt.textWidth > this.minWidth)
			{
				if(this.maxWidth < checkbox_mc.label_txt.textWidth)
				{
					this.maxWidth = checkbox_mc.label_txt.textWidth;
				}
			}
			else
			{
				this.maxWidth = this.minWidth;
			}
			checkbox_mc.enable = enabled;
			if(enabled == false)
			{
				checkbox_mc.alpha = 0.3;
			}
			this.list.addElement(checkbox_mc);
			checkbox_mc.formHL_mc.alpha = 0;
			this.HLCounter = this.HLCounter + 1;
			ExternalInterface.call("controlAdded", "checkbox", checkbox_mc.id, checkbox_mc.list_pos, "list", enabled);
		}
		
		public function setMenuCheckbox(param1:Number, param2:Boolean, param3:Number) : *
		{
			var val4:MovieClip = this.getElementByID(param1);
			if(val4)
			{
				val4.enable = param2;
				if(param2 == false)
				{
					val4.alpha = 0.3;
				}
				else
				{
					val4.alpha = 1;
				}
				val4.setState(param3);
			}
		}
		
		public function addMenuInfoLabel(id:Number, displayName:String, infoText:String) : *
		{
			var label_mc:MovieClip = this.getElementByID(id);
			if(!label_mc)
			{
				label_mc = new LabelInfo();
				label_mc.id = id;
				label_mc.info_txt.autoSize = TextFieldAutoSize.LEFT;
			}
			if(label_mc)
			{
				label_mc.x = this.elementX;
				label_mc.label_txt.htmlText = displayName;
				label_mc.info_txt.htmlText = infoText;
				label_mc.name = "item" + this.list.length + "_mc";
				this.totalHeight = this.totalHeight + (label_mc.mHeight + this.elementHSpacing);
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
				this.list.addElement(label_mc);
				this.HLCounter = 0;
				ExternalInterface.call("controlAdded", "menuInfoLabel", label_mc.id, label_mc.list_pos, "list");
			}
		}
		
		public function addMenuLabel(text:String, tooltip:String="", fixedHeight:Number = -1) : *
		{
			var label_mc:MovieClip = new Label();
			label_mc.x = this.elementX;
			label_mc.tooltip = tooltip;
			if(fixedHeight > -1) {
				label_mc.mHeight = fixedHeight;
			}
			label_mc.label_txt.htmlText = text;
			label_mc.name = "item" + this.list.length + "_mc";
			//val2.mHeight = 40;
			this.totalHeight = this.totalHeight + (label_mc.mHeight + this.elementHSpacing);
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
			this.list.addElement(label_mc);
			this.HLCounter = 0;
			ExternalInterface.call("controlAdded", "menuLabel", label_mc.name, label_mc.list_pos, "list", text);
		}
		
		public function addMenuSelector(param1:Number, param2:String) : *
		{
		}
		
		public function addMenuSelectorEntry(id:Number, label:String) : *
		{
			var select_mc:MovieClip = null;
			var selector_mc:MovieClip = this.getElementByID(id);
			if(selector_mc)
			{
				select_mc = new SelectElement();
				select_mc.label_txt.htmlText = label;
				selector_mc.selList.addElement(select_mc);
				ExternalInterface.call("controlAdded", "menuLabel", select_mc.id, select_mc.list_pos, "selList", id);
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
			var val2:MovieClip = this.getElementByID(id);
			if(val2 && val2.combo_mc)
			{
				val2.combo_mc.removeAll();
			}
		}
		
		public function setMenuDropDownEnabled(id:Number, enabled:Boolean) : *
		{
			var dropdown_mc:MovieClip = this.getElementByID(id);
			if(dropdown_mc && dropdown_mc.combo_mc)
			{
				dropdown_mc.combo_mc.enabled = enabled;
				if(enabled)
				{
					dropdown_mc.combo_mc.alpha = 1;
				}
				else
				{
					dropdown_mc.combo_mc.alpha = 0.3;
				}
			}
		}
		
		public function setMenuDropDownDisabledTooltip(id:Number, tooltip:String) : *
		{
			var val3:MovieClip = this.getElementByID(id);
			if(val3 && val3.combo_mc)
			{
				val3.combo_mc.tooltip = tooltip;
				if(tooltip != "")
				{
					val3.combo_mc.onOver = this.ddShowTooltip;
					val3.combo_mc.onOut = this.ddHideTooltip;
				}
				else
				{
					val3.combo_mc.onOver = null;
					val3.combo_mc.onOut = null;
				}
			}
		}
		
		public function ddShowTooltip(e:MouseEvent) : *
		{
			var val2:MovieClip = e.currentTarget.parent as MovieClip;
			if(val2 && !val2.enabled)
			{
				if(val2.tooltip != null && val2.tooltip != "")
				{
					this.base.curTooltip = val2.tooltip;
					ExternalInterface.call("showTooltip",val2.tooltip);
					this.base.hasTooltip = true;
				}
			}
		}
		
		public function ddHideTooltip(e:MouseEvent) : *
		{
			var val2:MovieClip = e.currentTarget.parent as MovieClip;
			if(val2 && !val2.enabled && val2.tooltip && val2.tooltip != "")
			{
				if(this.base.hasTooltip)
				{
					ExternalInterface.call("hideTooltip");
					this.base.hasTooltip = false;
					this.base.curTooltip = "";
				}
			}
		}
		
		public function addMenuDropDown(id:Number, label:String, tooltip:String) : *
		{
			var dropdown_mc:MovieClip = new DropDown();
			dropdown_mc.combo_mc.bgTopSizeDiff = -20;
			dropdown_mc.customElHeight = this.elementHeight;
			dropdown_mc.x = this.elementX;
			dropdown_mc.label_txt.htmlText = label;
			dropdown_mc.id = id;
			dropdown_mc.name = "item" + this.list.length + "_mc";
			dropdown_mc.mHeight = 30;
			dropdown_mc.tooltip = tooltip;
			this.totalHeight = this.totalHeight + (dropdown_mc.mHeight + this.elementHSpacing);
			dropdown_mc.combo_mc.addEventListener(Event.CLOSE,this.onComboClose);
			dropdown_mc.combo_mc.addEventListener(Event.OPEN,this.onComboOpen);
			dropdown_mc.combo_mc.addEventListener("Scrolled",this.onComboScrolled);
			if(dropdown_mc.label_txt.textWidth > this.minWidth)
			{
				if(this.maxWidth < dropdown_mc.label_txt.textWidth)
				{
					this.maxWidth = dropdown_mc.label_txt.textWidth;
				}
			}
			else
			{
				this.maxWidth = this.minWidth;
			}
			this.list.addElement(dropdown_mc);
			dropdown_mc.formHL_mc.alpha = 0;
			this.HLCounter = this.HLCounter + 1;
			ExternalInterface.call("controlAdded", "dropdown", dropdown_mc.id, dropdown_mc.list_pos, "list");
		}
		
		public function addMenuDropDownEntry(param1:Number, param2:String) : *
		{
			var val3:MovieClip = this.getElementByID(param1);
			if(val3 && val3.combo_mc)
			{
				val3.combo_mc.addItem({"label":param2});
			}
		}
		
		public function selectMenuDropDownEntry(param1:Number, param2:Number) : *
		{
			var val3:MovieClip = this.getElementByID(param1);
			if(val3 && val3.combo_mc)
			{
				val3.combo_mc.selectedIndex = param2;
			}
		}
		
		public function roundFloat(param1:Number) : Number
		{
			return Math.round(param1 * 100) / 100;
		}
		
		public function addMenuSlider(id:Number, label:String, value:Number, min:Number, max:Number, interval:Number, disabled:Boolean, tooltip:String) : *
		{
			var val10:Number = NaN;
			var slider_mc:MovieClip = new SliderComp();
			slider_mc.x = this.elementX;
			slider_mc.label_txt.htmlText = label;
			slider_mc.id = id;
			slider_mc.name = "item" + this.list.length + "_mc";
			slider_mc.mHeight = 30;
			slider_mc.tooltip = tooltip;
			slider_mc.slider_mc.maximum = this.roundFloat(max);
			slider_mc.slider_mc.minimum = this.roundFloat(min);
			slider_mc.min_txt.htmlText = String(this.roundFloat(min));
			slider_mc.max_txt.htmlText = String(this.roundFloat(max));
			slider_mc.slider_mc.snapInterval = this.roundFloat(interval);
			slider_mc.amount_txt.visible = !disabled;
			slider_mc.min_txt.visible = !disabled;
			slider_mc.max_txt.visible = !disabled;
			if(interval != 0)
			{
				val10 = (max - min) / interval;
				if(val10 <= 10)
				{
					slider_mc.slider_mc.useNotches = true;
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
			slider_mc.slider_mc.bgToWidthDiff = -6;
			this.totalHeight = this.totalHeight + (slider_mc.mHeight + this.elementHSpacing);
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
			slider_mc.label_txt.y = 26 - Math.round(slider_mc.label_txt.textHeight * 0.5);
			this.list.addElement(slider_mc);
			slider_mc.formHL_mc.alpha = 0;
			this.HLCounter = this.HLCounter + 1;
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
		
		public function addMenuButton(id:Number, label:String, clickSound:String, enabled:Boolean, tooltip:String) : *
		{
			var button_mc:MovieClip = new Menu_button();
			button_mc.x = this.elementX;
			button_mc.label_txt.htmlText = label;
			button_mc.id = id;
			button_mc.name = "item" + this.list.length + "_mc";
			button_mc.mHeight = 70;
			button_mc.tooltip = tooltip;
			this.totalHeight = this.totalHeight + (button_mc.mHeight + this.elementHSpacing);
			if(button_mc.label_txt.textWidth > this.minWidth)
			{
				if(this.maxWidth < button_mc.label_txt.textWidth)
				{
					this.maxWidth = button_mc.label_txt.textWidth;
				}
			}
			else
			{
				this.maxWidth = this.minWidth;
			}
			button_mc.disable_mc.visible = !enabled;
			button_mc.bg_mc.visible = enabled;
			this.list.addElement(button_mc);
			button_mc.formHL_mc.alpha = 0;
			if(clickSound.length > 0)
			{
				button_mc.snd_onUp = clickSound;
			}
			else
			{
				button_mc.snd_onUp = "UI_Gen_XButton_Click";
			}
			this.HLCounter = this.HLCounter + 1;
			ExternalInterface.call("controlAdded", "button", button_mc.id, button_mc.list_pos, "list", enabled);
		}
		
		public function setButtonEnabled(param1:Number, param2:Boolean) : *
		{
			var val3:MovieClip = this.getElementByID(param1);
			if(val3)
			{
				val3.disable_mc.visible = !param2;
				val3.bg_mc.visible = param2;
			}
		}
		
		public function moveCursor(param1:Boolean) : *
		{
			if(param1)
			{
				this.list.previous();
			}
			else
			{
				this.list.next();
			}
		}
		
		public function setCursorPosition(param1:Number) : *
		{
			var val2:MovieClip = this.getElementByID(param1);
			if(val2)
			{
				this.list.selectMC(val2);
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
		
		public function resetMenuButtons(activeButtonID:Number) : *
		{
			var i:uint = 0;
			var btn:MovieClip = null;
			var length:Number = this.menuBtnList.length;
			if(length > 0)
			{
				i = 0;
				while(i < length)
				{
					btn = this.menuBtnList.getAt(i);
					if(btn && btn.buttonID != activeButtonID)
					{
						btn.setActive(false);
					}
					i++;
				}
			}
		}

		//LeaderLib Addition
		public function setupApplyCopy(copy:MovieClip, bVisible:Boolean=false):*
		{
			this.applyCopy = copy;
			this.applyCopy.text_txt.filters = textEffect.createStrokeFilter(0,2,0.75,1.4,3);
			this.applyCopy.pressedFunc = this.applyPressed;
			this.applyCopy.textY = this.apply_mc.textY;
			this.applyCopy.text_txt.defaultTextFormat = this.apply_mc.text_txt.defaultTextFormat;
			this.applyCopy.text_txt.htmlText = this.apply_mc.text_txt.htmlText;
			//this.applyCopy.text_txt.text = this.apply_mc.text_txt.text;
			this.applyCopy.disable_mc.visible = false;
			this.applyCopy.bg_mc.visible = bVisible;
			this.applyCopy.text_txt.visible = bVisible;

			this.applyCopy.x = this.apply_mc.x;
			this.applyCopy.y = this.apply_mc.y;
			this.applyCopy.disable_mc.x = this.apply_mc.disable_mc.x;
			this.applyCopy.bg_mc.x = this.apply_mc.bg_mc.x;
			this.applyCopy.text_txt.x = this.apply_mc.text_txt.x;
			this.applyCopy.disable_mc.y = this.apply_mc.disable_mc.y;
			this.applyCopy.bg_mc.y = this.apply_mc.bg_mc.y;
			this.applyCopy.text_txt.y = this.apply_mc.text_txt.y;
			this.addChild(this.applyCopy);
		}

		//LeaderLib Addition
		public function removeApplyCopy():*
		{
			if (this.applyCopy)
			{
				this.removeChild(this.applyCopy);
				this.applyCopy = null;
			}
		}
		
		public function frame1() : *
		{
			this.title_txt.filters = textEffect.createStrokeFilter(0,2,0.75,1.4,3);
			this.cancel_mc.text_txt.filters = textEffect.createStrokeFilter(0,2,0.75,1.4,3);
			this.ok_mc.text_txt.filters = textEffect.createStrokeFilter(0,2,0.75,1.4,3);
			this.apply_mc.text_txt.filters = textEffect.createStrokeFilter(0,2,0.75,1.4,3);
			this.toptitle_txt.filters = textEffect.createStrokeFilter(0,2,0.75,1.4,3);
			this.opened = false;
			this.Root = this;
			this.selectedID = 0;
			this.totalHeight = 0;
			this.maxWidth = 0;
			this.factor = 30;
			this.elementHeight = 50;
			this.topDist = 20;
			this.list = new scrollList("down_id","up_id","handle_id","scrollBg_id");
			this.list.m_forceDepthReorder = true;
			this.list.TOP_SPACING = 20;
			this.list.EL_SPACING = 2;
			this.list.setFrame(900,791);
			this.list.m_scrollbar_mc.m_SCROLLSPEED = 40;
			this.list.m_scrollbar_mc.m_hideWhenDisabled = false;
			this.list.m_scrollbar_mc.y = 16;
			this.list.SB_SPACING = -3;
			this.list.m_scrollbar_mc.setLength(682);
			this.menuBtnList = new listDisplay();
			this.menuBtnList.EL_SPACING = 2;
			this.menuButtonContainer_mc.addChild(this.menuBtnList);
			this.base = root as MovieClip;
			this.HLCounter = 0;
			this.listHolder_mc.addChild(this.list);
			this.cancel_mc.pressedFunc = this.cancelPressed;
			this.ok_mc.pressedFunc = this.okPressed;
			this.apply_mc.pressedFunc = this.applyPressed;
			this.elementHSpacing = 2;
			this.minWidth = 400;
		}
	}
}