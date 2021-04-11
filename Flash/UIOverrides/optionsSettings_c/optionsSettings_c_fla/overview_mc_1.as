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
		public var buttonHint_mc:BtnHintContainer;
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
		
		public function addMenuCheckbox(param1:Number, param2:String, param3:Boolean, param4:Number, param5:Boolean, param6:String) : *
		{
			var val8:* = undefined;
			this.addMenuSelector(param1,param2,param6);
			var val7:MovieClip = this.getElementByID(param1);
			if(val7)
			{
				val7.isCheckBox = true;
				this.setMenuDropDownEnabled(param1,param3);
				this.setMenuDropDownTooltip(param1,param6,true);
				val8 = 0;
				while(val8 < this.checkBoxOptions.length)
				{
					this.addMenuSelectorEntry(param1,this.checkBoxOptions[val8]);
					val8++;
				}
				this.selectMenuSelectorEntry(param1,param4);

				ExternalInterface.call("controlAdded", "checkbox", val7.id, val7.list_pos, "list");
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
		
		public function addMenuInfoLabel(param1:Number, param2:String, param3:String) : *
		{
			var val4:MovieClip = this.getElementByID(param1);
			if(!val4)
			{
				val4 = new LabelInfo();
				val4.heightOverride = 104;
				val4.id = param1;
				val4.info_txt.autoSize = TextFieldAutoSize.LEFT;
				this.list.addElement(val4,true,false);
			}
			if(val4)
			{
				val4.x = this.elementX;
				val4.label_txt.htmlText = param2;
				val4.info_txt.htmlText = param3;
				val4.name = "item" + this.list.length + "_mc";
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
				ExternalInterface.call("controlAdded", "menuInfoLabel", val4.id, val4.list_pos, "list");
			}
			this.resetBG();
		}
		
		public function addMenuLabel(param1:String) : *
		{
			var val2:MovieClip = new Label();
			if(this.list.size != 0)
			{
				val2.heightOverride = this.elementHeight * 2;
			}
			else
			{
				val2.heightOverride = this.elementHeight;
				val2.label_txt.y = 0;
			}
			val2.x = this.elementX;
			val2.label_txt.htmlText = param1;
			val2.name = "item" + this.list.length + "_mc";
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
			this.list.addElement(val2,true,false);
			this.resetBG();
			ExternalInterface.call("controlAdded", "menuLabel", val2.name, val2.list_pos, "list", param1);
		}
		
		public function addMenuSelector(param1:Number, param2:String, param3:String) : *
		{
			var val4:MovieClip = new SelectorMC();
			this.list.addElement(val4);
			val4.selList = new selector();
			val4.cont_mc.addChild(val4.selList);
			val4.selList.align = "right";
			val4.selList.id = param1;
			val4.selList.centeredElements = true;
			val4.selList.TweenDuration = 0.01;
			val4.heightOverride = this.elementHeight;
			val4.x = this.elementX;
			val4.left_mc.visible = false;
			val4.right_mc.visible = false;
			val4.label_txt.htmlText = param2;
			val4.id = param1;
			val4.name = "item" + this.list.length + "_mc";
			val4.hl_mc.visible = false;
			val4.biggestWidth = 0;
			val4.isCheckBox = false;
			val4.enabled = true;
			this.setMenuDropDownTooltip(param1,param3,true);
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
			this.resetBG();
			ExternalInterface.call("controlAdded", "menuSelector", val4.id, val4.list_pos, "list");
		}
		
		public function addMenuSelectorEntry(param1:Number, param2:String) : *
		{
			var val5:MovieClip = null;
			var val3:Number = 300;
			var val4:MovieClip = this.getElementByID(param1);
			if(val4)
			{
				val5 = new SelectElementMC();
				val5.label_txt.autoSize = TextFieldAutoSize.LEFT;
				val5.label_txt.htmlText = param2;
				if(val3 < val5.label_txt.textWidth)
				{
					val5.label_txt.autoSize = TextFieldAutoSize.NONE;
					val5.label_txt.width = val3;
				}
				val5.container = val4;
				val5.label_txt.x = -Math.round(val5.label_txt.width * 0.5);
				val4.AddElement(val5);
				this.resetBG();
				ExternalInterface.call("controlAdded", "menuLabel", val4.id, val4.list_pos, "selList", param1);
			}
		}
		
		public function selectMenuSelectorEntry(param1:Number, param2:Number) : *
		{
			var val3:MovieClip = this.getElementByID(param1);
			if(val3)
			{
				val3.selList.select(param2);
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
			if(val2)
			{
				val2.selList.clearElements();
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
		
		public function addMenuSlider(param1:Number, param2:String, param3:Number, param4:Number, param5:Number, param6:Number, param7:Boolean, param8:String) : *
		{
			var val10:Number = NaN;
			var val9:MovieClip = new SliderComp();
			val9.x = this.elementX;
			val9.label_txt.htmlText = param2;
			val9.id = param1;
			val9.name = "item" + this.list.length + "_mc";
			val9.heightOverride = 104;
			val9.tooltip = param8;
			val9.slider_mc.maximum = this.roundFloat(param5);
			val9.slider_mc.minimum = this.roundFloat(param4);
			val9.min_txt.htmlText = String(this.roundFloat(param4));
			val9.max_txt.htmlText = String(this.roundFloat(param5));
			val9.slider_mc.snapInterval = this.roundFloat(param6);
			val9.hl_mc.visible = false;
			val9.amount_txt.visible = !param7;
			val9.min_txt.visible = !param7;
			val9.max_txt.visible = !param7;
			val9.slider_mc.bgToWidthDiff = -20;
			if(param6 != 0)
			{
				val10 = (param5 - param4) / param6;
				if(val10 <= 10)
				{
					val9.slider_mc.m_NotchLeftOffset = 9;
					val9.slider_mc.useNotches = true;
					val9.slider_mc.m_notches_mc.y = 11;
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
			this.list.addElement(val9);
			this.setMenuDropDownTooltip(param1,param8,true);
			this.resetBG();
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
		
		public function addMenuButton(param1:Number, param2:String, param3:Boolean) : *
		{
			var val4:MovieClip = new Menu_button();
			val4.heightOverride = this.elementHeight;
			val4.x = this.elementX;
			val4.label_txt.htmlText = param2;
			val4.id = param1;
			val4.name = "item" + this.list.length + "_mc";
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
			val4.disable_mc.visible = !param3;
			val4.bg_mc.visible = param3;
			this.list.addElement(val4);
			this.resetBG();
			ExternalInterface.call("controlAdded", "button", val4.id, val4.list_pos, "list");
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
			ExternalInterface.call("PlaySound","UI_Gen_CursorMove");
			if(param1)
			{
				this.list.previous();
			}
			else
			{
				this.list.next();
			}
			this.setListLoopable(false);
		}
		
		public function setListLoopable(param1:Boolean) : *
		{
			this.list.m_cyclic = param1;
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
		
		function frame1() : *
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
