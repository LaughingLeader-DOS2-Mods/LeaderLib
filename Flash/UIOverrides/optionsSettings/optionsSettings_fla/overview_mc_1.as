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
		public var Root;
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
		
		public function addOptionButton(param1:String, param2:String, param3:Number, param4:Boolean) : *
		{
			var text:String = param1;
			var callBack:String = param2;
			var buttonID:Number = param3;
			var isCurrent:Boolean = param4;
			var btn:MovieClip = new menuButton();
			btn.interactiveTextOnClick = true;
			btn.SND_Click = "UI_Gen_BigButton_Click";
			btn.initialize(text.toUpperCase(),function(param1:Array):*
			{
				ExternalInterface.call(callBack,buttonID);
			},null,isCurrent,-1,isCurrent);
			btn.buttonID = buttonID;
			this.menuBtnList.addElement(btn,true);
			this.menuButtonContainer_mc.x = this.menuButtonContainerCenterPos.x - this.menuBtnList.width * 0.5;
			this.menuButtonContainer_mc.y = this.menuButtonContainerCenterPos.y;
			ExternalInterface.call("controlAdded", "optionButton", btn.buttonID, btn.list_pos, "menuBtnList");
		}
		
		public function cancelPressed() : *
		{
			ExternalInterface.call("requestCloseUI");
		}
		
		public function applyPressed() : *
		{
			ExternalInterface.call("applyPressed");
			ExternalInterface.call("PlaySound","UI_Gen_Apply");
			this.apply_mc.onOut();
			if (this.applyCopy && this.applyCopy.bg_mc.visible)
			{
				this.applyCopy.onOut();
			}
		}
		
		public function okPressed() : *
		{
			ExternalInterface.call("acceptPressed");
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
		
		public function addMenuCheckbox(param1:Number, param2:String, param3:Boolean, param4:Number, param5:Boolean, param6:String) : *
		{
			var val7:MovieClip = new Checkbox();
			val7.x = this.elementX;
			val7.label_txt.htmlText = param2;
			val7.id = param1;
			val7.name = "item" + this.list.length + "_mc";
			val7.mHeight = 30;
			val7.filterBool = param5;
			val7.stateID = param4;
			val7.tooltip = param6;
			val7.bg_mc.gotoAndStop(param4 * 3 + 1);
			this.totalHeight = this.totalHeight + (val7.mHeight + this.elementHSpacing);
			if(val7.label_txt.textWidth > this.minWidth)
			{
				if(this.maxWidth < val7.label_txt.textWidth)
				{
					this.maxWidth = val7.label_txt.textWidth;
				}
			}
			else
			{
				this.maxWidth = this.minWidth;
			}
			val7.enable = param3;
			if(param3 == false)
			{
				val7.alpha = 0.3;
			}
			this.list.addElement(val7);
			val7.formHL_mc.alpha = 0;
			this.HLCounter = this.HLCounter + 1;
			ExternalInterface.call("controlAdded", "checkbox", val7.id, val7.list_pos, "list");
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
		
		public function addMenuInfoLabel(param1:Number, param2:String, param3:String) : *
		{
			var val4:MovieClip = this.getElementByID(param1);
			if(!val4)
			{
				val4 = new LabelInfo();
				val4.id = param1;
				val4.info_txt.autoSize = TextFieldAutoSize.LEFT;
			}
			if(val4)
			{
				val4.x = this.elementX;
				val4.label_txt.htmlText = param2;
				val4.info_txt.htmlText = param3;
				val4.name = "item" + this.list.length + "_mc";
				this.totalHeight = this.totalHeight + (val4.mHeight + this.elementHSpacing);
				if(val4.label_txt.textWidth > this.minWidth)
				{
					if(this.maxWidth < val4.label_txt.textWidth)
					{
						this.maxWidth = val4.label_txt.textWidth;
					}
				}
				else
				{
					this.maxWidth = this.minWidth;
				}
				this.list.addElement(val4);
				this.HLCounter = 0;
				ExternalInterface.call("controlAdded", "menuInfoLabel", val4.id, val4.list_pos, "list");
			}
		}
		
		public function addMenuLabel(text:String) : *
		{
			var val2:MovieClip = new Label();
			val2.x = this.elementX;
			val2.label_txt.htmlText = text;
			val2.name = "item" + this.list.length + "_mc";
			//val2.mHeight = 40;
			this.totalHeight = this.totalHeight + (val2.mHeight + this.elementHSpacing);
			if(val2.label_txt.textWidth > this.minWidth)
			{
				if(this.maxWidth < val2.label_txt.textWidth)
				{
					this.maxWidth = val2.label_txt.textWidth;
				}
			}
			else
			{
				this.maxWidth = this.minWidth;
			}
			this.list.addElement(val2);
			this.HLCounter = 0;
			ExternalInterface.call("controlAdded", "menuLabel", val2.name, val2.list_pos, "list", text);
		}
		
		public function addMenuSelector(param1:Number, param2:String) : *
		{
		}
		
		public function addMenuSelectorEntry(param1:Number, param2:String) : *
		{
			var val4:MovieClip = null;
			var val3:MovieClip = this.getElementByID(param1);
			if(val3)
			{
				val4 = new SelectElement();
				val4.label_txt.htmlText = param2;
				val3.selList.addElement(val4);
				ExternalInterface.call("controlAdded", "menuLabel", val4.id, val4.list_pos, "selList", param1);
			}
		}
		
		public function onComboClose(param1:Event) : *
		{
			(root as MovieClip).selectedInfo_txt.visible = false;
			this.setMainScrolling(true);
		}
		
		public function onComboOpen(param1:Event) : *
		{
			this.setMainScrolling(false);
		}
		
		public function onComboScrolled(param1:Event) : *
		{
			(root as MovieClip).selectedInfo_txt.visible = false;
		}
		
		public function clearMenuDropDownEntries(param1:Number) : *
		{
			var val2:MovieClip = this.getElementByID(param1);
			if(val2 && val2.combo_mc)
			{
				val2.combo_mc.removeAll();
			}
		}
		
		public function setMenuDropDownEnabled(param1:Number, param2:Boolean) : *
		{
			var val3:MovieClip = this.getElementByID(param1);
			if(val3 && val3.combo_mc)
			{
				val3.combo_mc.enabled = param2;
				if(param2)
				{
					val3.combo_mc.alpha = 1;
				}
				else
				{
					val3.combo_mc.alpha = 0.3;
				}
			}
		}
		
		public function setMenuDropDownDisabledTooltip(param1:Number, param2:String) : *
		{
			var val3:MovieClip = this.getElementByID(param1);
			if(val3 && val3.combo_mc)
			{
				val3.combo_mc.tooltip = param2;
				if(param2 != "")
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
		
		public function ddShowTooltip(param1:MouseEvent) : *
		{
			var val2:MovieClip = param1.currentTarget.parent as MovieClip;
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
		
		public function ddHideTooltip(param1:MouseEvent) : *
		{
			var val2:MovieClip = param1.currentTarget.parent as MovieClip;
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
		
		public function addMenuDropDown(param1:Number, param2:String, param3:String) : *
		{
			var val4:MovieClip = new DropDown();
			val4.combo_mc.bgTopSizeDiff = -20;
			val4.customElHeight = this.elementHeight;
			val4.x = this.elementX;
			val4.label_txt.htmlText = param2;
			val4.id = param1;
			val4.name = "item" + this.list.length + "_mc";
			val4.mHeight = 30;
			val4.tooltip = param3;
			this.totalHeight = this.totalHeight + (val4.mHeight + this.elementHSpacing);
			val4.combo_mc.addEventListener(Event.CLOSE,this.onComboClose);
			val4.combo_mc.addEventListener(Event.OPEN,this.onComboOpen);
			val4.combo_mc.addEventListener("Scrolled",this.onComboScrolled);
			if(val4.label_txt.textWidth > this.minWidth)
			{
				if(this.maxWidth < val4.label_txt.textWidth)
				{
					this.maxWidth = val4.label_txt.textWidth;
				}
			}
			else
			{
				this.maxWidth = this.minWidth;
			}
			this.list.addElement(val4);
			val4.formHL_mc.alpha = 0;
			this.HLCounter = this.HLCounter + 1;
			ExternalInterface.call("controlAdded", "dropdown", val4.id, val4.list_pos, "list");
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
		
		public function addMenuSlider(param1:Number, param2:String, param3:Number, param4:Number, param5:Number, param6:Number, param7:Boolean, param8:String) : *
		{
			var val10:Number = NaN;
			var val9:MovieClip = new SliderComp();
			val9.x = this.elementX;
			val9.label_txt.htmlText = param2;
			val9.id = param1;
			val9.name = "item" + this.list.length + "_mc";
			val9.mHeight = 30;
			val9.tooltip = param8;
			val9.slider_mc.maximum = this.roundFloat(param5);
			val9.slider_mc.minimum = this.roundFloat(param4);
			val9.min_txt.htmlText = String(this.roundFloat(param4));
			val9.max_txt.htmlText = String(this.roundFloat(param5));
			val9.slider_mc.snapInterval = this.roundFloat(param6);
			val9.amount_txt.visible = !param7;
			val9.min_txt.visible = !param7;
			val9.max_txt.visible = !param7;
			if(param6 != 0)
			{
				val10 = (param5 - param4) / param6;
				if(val10 <= 10)
				{
					val9.slider_mc.useNotches = true;
				}
				else
				{
					val9.slider_mc.useNotches = false;
				}
			}
			val9.slider_mc.liveDragging = true;
			val9.amount_txt.htmlText = this.roundFloat(param3);
			if(param5 > 50)
			{
				val9.slider_mc.tickInterval = 10;
			}
			else if(param5 > 20)
			{
				val9.slider_mc.tickInterval = 5;
			}
			else
			{
				val9.slider_mc.tickInterval = 1;
			}
			val9.amount_txt.mouseEnabled = false;
			val9.min_txt.mouseEnabled = false;
			val9.max_txt.mouseEnabled = false;
			val9.slider_mc.bgToWidthDiff = -6;
			this.totalHeight = this.totalHeight + (val9.mHeight + this.elementHSpacing);
			if(val9.label_txt.textWidth > this.minWidth)
			{
				if(this.maxWidth < val9.label_txt.textWidth)
				{
					this.maxWidth = val9.label_txt.textWidth;
				}
			}
			else
			{
				this.maxWidth = this.minWidth;
			}
			val9.label_txt.y = 26 - Math.round(val9.label_txt.textHeight * 0.5);
			this.list.addElement(val9);
			val9.formHL_mc.alpha = 0;
			this.HLCounter = this.HLCounter + 1;
			val9.slider_mc.value = param3;
			val9.resetAmountPos();
			ExternalInterface.call("controlAdded", "slider", val9.id, val9.list_pos, "list");
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
			var val6:MovieClip = new Menu_button();
			val6.x = this.elementX;
			val6.label_txt.htmlText = label;
			val6.id = id;
			val6.name = "item" + this.list.length + "_mc";
			val6.mHeight = 70;
			val6.tooltip = tooltip;
			this.totalHeight = this.totalHeight + (val6.mHeight + this.elementHSpacing);
			if(val6.label_txt.textWidth > this.minWidth)
			{
				if(this.maxWidth < val6.label_txt.textWidth)
				{
					this.maxWidth = val6.label_txt.textWidth;
				}
			}
			else
			{
				this.maxWidth = this.minWidth;
			}
			val6.disable_mc.visible = !enabled;
			val6.bg_mc.visible = enabled;
			this.list.addElement(val6);
			val6.formHL_mc.alpha = 0;
			if(clickSound.length > 0)
			{
				val6.snd_onUp = clickSound;
			}
			else
			{
				val6.snd_onUp = "UI_Gen_XButton_Click";
			}
			this.HLCounter = this.HLCounter + 1;
			ExternalInterface.call("controlAdded", "button", val6.id, val6.list_pos, "list");
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
		
		public function resetMenuButtons(param1:Number) : *
		{
			var val3:uint = 0;
			var val4:MovieClip = null;
			var val2:Number = this.menuBtnList.length;
			if(val2 > 0)
			{
				val3 = 0;
				while(val3 < val2)
				{
					val4 = this.menuBtnList.getAt(val3);
					if(val4 && val4.buttonID != param1)
					{
						val4.setActive(false);
					}
					val3++;
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
		
		function frame1() : *
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