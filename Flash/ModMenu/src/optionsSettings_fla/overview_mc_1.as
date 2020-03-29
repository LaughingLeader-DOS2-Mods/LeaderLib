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
   
   public dynamic class overview_mc_1 extends MovieClip
   {
       
      
      public var Xclose_mc:MovieClip;
      
      public var apply_mc:MovieClip;
      
      public var cancel_mc:MovieClip;
      
      public var listHolder_mc:emptyBG;
      
      public var menuButtonContainer_mc:emptyBG;
      
      public var ok_mc:MovieClip;
      
      public var title_txt:TextField;
      
      public var toptitle_txt:TextField;
      
      public const hlColour:uint = 0;
      
      public const defaultColour:uint = 14077127;
      
      //public const menuButtonContainerCenterPos:Point = new Point(176,156);
      public const menuButtonContainerCenterPos:Point = new Point(139,156);
      
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
      //public var menuBtnList:scrollList;
      
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
      
      public function setMenuScrolling(enabled:Boolean) : *
      {
         this.menuBtnList.mouseWheelEnabled = enabled;
      }

      public function setMainScrolling(enabled:Boolean) : *
      {
         this.list.mouseWheelEnabled = enabled;
      }
      
      public function addOptionButton(text:String, callback:String, buttonID:Number, isCurrent:Boolean, fontSize:Number=-1) : *
      {
         var btn:MovieClip = new menuButton();
         btn.interactiveTextOnClick = true;
         btn.SND_Click = "UI_Gen_BigButton_Click";
         btn.initialize(text.toUpperCase(),function(pressedParams:Array):*
         {
            ExternalInterface.call(callback,buttonID);
         },null,isCurrent,fontSize,isCurrent);
         btn.buttonID = buttonID;
         this.menuBtnList.addElement(btn,true);
         this.menuButtonContainer_mc.x = this.menuButtonContainerCenterPos.x - this.menuBtnList.width * 0.5;
         //his.menuButtonContainer_mc.y = this.menuButtonContainerCenterPos.y;
         this.menuButtonContainer_mc.y = 100;
         //this.menuButtonContainer_mc.x = this.menuButtonContainerCenterPos.x - this.menuBtnList.width * 0.25;
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

      public function setTitle(text:String) : *
      {
         MainTimeline.SetTextFormat(this.title_txt, 22);
         this.title_txt.htmlText = text.toUpperCase();
      }
      
      public function addMenuCheckbox(id:Number, labelText:String, isEnabled:Boolean, state:Number, filterEnabled:Boolean, tooltip:String) : *
      {
         var checkbox:MovieClip = new Checkbox();
         checkbox.x = this.elementX;
         checkbox.label_txt.htmlText = labelText;
         MainTimeline.SetTextFormat(checkbox.label_txt, 16);
         checkbox.id = id;
         checkbox.name = "item" + this.list.length + "_mc";
         checkbox.mHeight = 30;
         checkbox.filterBool = filterEnabled;
         checkbox.stateID = state;
         checkbox.tooltip = tooltip;
         checkbox.bg_mc.gotoAndStop(state * 3 + 1);
         this.totalHeight = this.totalHeight + (checkbox.mHeight + this.elementHSpacing);
         if(checkbox.label_txt.textWidth > this.minWidth)
         {
            if(this.maxWidth < checkbox.label_txt.textWidth)
            {
               this.maxWidth = checkbox.label_txt.textWidth;
            }
         }
         else
         {
            this.maxWidth = this.minWidth;
         }
         checkbox.enable = isEnabled;
         if(isEnabled == false)
         {
            checkbox.alpha = 0.3;
         }
         this.list.addElement(checkbox);
         checkbox.formHL_mc.alpha = 0;
         this.HLCounter = this.HLCounter + 1;
      }
      
      public function setMenuCheckbox(id:Number, enabled:Boolean, state:Number) : *
      {
         var menu:MovieClip = this.getElementByID(id);
         if(menu)
         {
            menu.enable = enabled;
            if(enabled == false)
            {
               menu.alpha = 0.3;
            }
            else
            {
               menu.alpha = 1;
            }
            menu.setState(state);
         }
      }
      
      public function addMenuInfoLabel(id:Number, labelText:String, infoText:String) : *
      {
         var labelInfo:MovieClip = this.getElementByID(id);
         if(!labelInfo)
         {
            labelInfo = new LabelInfo();
            labelInfo.id = id;
            labelInfo.info_txt.autoSize = TextFieldAutoSize.LEFT;
         }
         if(labelInfo)
         {
            labelInfo.x = this.elementX;
            labelInfo.label_txt.htmlText = labelText;
            labelInfo.info_txt.htmlText = infoText;
            MainTimeline.SetTextFormat(labelInfo.label_txt, 16);
            MainTimeline.SetTextFormat(labelInfo.info_txt, 16);
            labelInfo.name = "item" + this.list.length + "_mc";
            this.totalHeight = this.totalHeight + (labelInfo.mHeight + this.elementHSpacing);
            if(labelInfo.label_txt.textWidth > this.minWidth)
            {
               if(this.maxWidth < labelInfo.label_txt.textWidth)
               {
                  this.maxWidth = labelInfo.label_txt.textWidth;
               }
            }
            else
            {
               this.maxWidth = this.minWidth;
            }
            this.list.addElement(labelInfo);
            this.HLCounter = 0;
         }
      }
      
      public function addMenuLabel(text:String) : *
      {
         var label:MovieClip = new Label();
         label.x = this.elementX;
         label.label_txt.htmlText = text;
         MainTimeline.SetTextFormat(label.label_txt, 22);
         label.name = "item" + this.list.length + "_mc";
         label.mHeight = 40;
         this.totalHeight = this.totalHeight + (label.mHeight + this.elementHSpacing);
         if(label.label_txt.textWidth > this.minWidth)
         {
            if(this.maxWidth < label.label_txt.textWidth)
            {
               this.maxWidth = label.label_txt.textWidth;
            }
         }
         else
         {
            this.maxWidth = this.minWidth;
         }
         this.list.addElement(label);
         this.HLCounter = 0;
      }
      
      public function addMenuSelector(id:Number, param2:String) : *
      {

      }
      
      public function addMenuSelectorEntry(id:Number, labelText:String) : *
      {
         var selectorEntry:MovieClip = null;
         var menu:MovieClip = this.getElementByID(id);
         if(menu)
         {
            selectorEntry = new SelectElement();
            MainTimeline.SetTextFormat(selectorEntry.label_txt, 16);
            selectorEntry.label_txt.htmlText = labelText;
            menu.selList.addElement(selectorEntry);
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
         var menu:MovieClip = this.getElementByID(id);
         if(menu && menu.combo_mc)
         {
            menu.combo_mc.removeAll();
         }
      }
      
      public function setMenuDropDownEnabled(id:Number, param2:Boolean) : *
      {
         var _loc3_:MovieClip = this.getElementByID(id);
         if(_loc3_ && _loc3_.combo_mc)
         {
            _loc3_.combo_mc.enabled = param2;
            if(param2)
            {
               _loc3_.combo_mc.alpha = 1;
            }
            else
            {
               _loc3_.combo_mc.alpha = 0.3;
            }
         }
      }
      
      public function setMenuDropDownDisabledTooltip(id:Number, param2:String) : *
      {
         var _loc3_:MovieClip = this.getElementByID(id);
         if(_loc3_ && _loc3_.combo_mc)
         {
            _loc3_.combo_mc.tooltip = param2;
            if(param2 != "")
            {
               _loc3_.combo_mc.onOver = this.ddShowTooltip;
               _loc3_.combo_mc.onOut = this.ddHideTooltip;
            }
            else
            {
               _loc3_.combo_mc.onOver = null;
               _loc3_.combo_mc.onOut = null;
            }
         }
      }
      
      public function ddShowTooltip(e:MouseEvent) : *
      {
         var _loc2_:MovieClip = e.currentTarget.parent as MovieClip;
         if(_loc2_ && !_loc2_.enabled)
         {
            if(_loc2_.tooltip != null && _loc2_.tooltip != "")
            {
               this.base.curTooltip = _loc2_.tooltip;
               ExternalInterface.call("showTooltip",_loc2_.tooltip);
               this.base.hasTooltip = true;
            }
         }
      }
      
      public function ddHideTooltip(e:MouseEvent) : *
      {
         var _loc2_:MovieClip = e.currentTarget.parent as MovieClip;
         if(_loc2_ && !_loc2_.enabled && _loc2_.tooltip && _loc2_.tooltip != "")
         {
            if(this.base.hasTooltip)
            {
               ExternalInterface.call("hideTooltip");
               this.base.hasTooltip = false;
               this.base.curTooltip = "";
            }
         }
      }
      
      public function addMenuDropDown(id:Number, labelText:String, tooltip:String) : *
      {
         var dropdown:MovieClip = new DropDown();
         dropdown.combo_mc.bgTopSizeDiff = -20;
         dropdown.customElHeight = this.elementHeight;
         dropdown.x = this.elementX;
         MainTimeline.SetTextFormat(dropdown.label_txt, 16);
         dropdown.label_txt.htmlText = labelText;
         dropdown.id = id;
         dropdown.name = "item" + this.list.length + "_mc";
         dropdown.mHeight = 30;
         dropdown.tooltip = tooltip;
         this.totalHeight = this.totalHeight + (dropdown.mHeight + this.elementHSpacing);
         dropdown.combo_mc.addEventListener(Event.CLOSE,this.onComboClose);
         dropdown.combo_mc.addEventListener(Event.OPEN,this.onComboOpen);
         dropdown.combo_mc.addEventListener("Scrolled",this.onComboScrolled);
         if(dropdown.label_txt.textWidth > this.minWidth)
         {
            if(this.maxWidth < dropdown.label_txt.textWidth)
            {
               this.maxWidth = dropdown.label_txt.textWidth;
            }
         }
         else
         {
            this.maxWidth = this.minWidth;
         }
         this.list.addElement(dropdown);
         dropdown.formHL_mc.alpha = 0;
         this.HLCounter = this.HLCounter + 1;
      }
      
      public function addMenuDropDownEntry(id:Number, labelText:String) : *
      {
         var dropdown:MovieClip = this.getElementByID(id);
         if(dropdown && dropdown.combo_mc)
         {
            dropdown.combo_mc.addItem({"label":labelText});
         }
      }
      
      public function selectMenuDropDownEntry(id:Number, selectedIndex:Number) : *
      {
         var menu:MovieClip = this.getElementByID(id);
         if(menu && menu.combo_mc)
         {
            menu.combo_mc.selectedIndex = selectedIndex;
         }
      }
      
      public function roundFloat(f:Number) : Number
      {
         return Math.round(f * 100) / 100;
      }
      
      public function addMenuSlider(sliderId:Number, labelText:String, selectedIndex:Number, min:Number, max:Number, snapInterval:Number, disabled:Boolean, tooltipText:String) : *
      {
         var intervalCheck:Number = NaN;
         var slider:MovieClip = new SliderComp();
         slider.x = this.elementX;
         slider.label_txt.htmlText = labelText;
         slider.id = sliderId;
         slider.name = "item" + this.list.length + "_mc";
         slider.mHeight = 30;
         slider.tooltip = tooltipText;
         slider.slider_mc.maximum = this.roundFloat(max);
         slider.slider_mc.minimum = this.roundFloat(min);
         slider.min_txt.htmlText = String(this.roundFloat(min));
         slider.max_txt.htmlText = String(this.roundFloat(max));
         slider.slider_mc.snapInterval = this.roundFloat(snapInterval);
         slider.amount_txt.visible = !disabled;
         slider.min_txt.visible = !disabled;
         slider.max_txt.visible = !disabled;
         if(snapInterval != 0)
         {
            intervalCheck = (max - min) / snapInterval;
            if(intervalCheck <= 10)
            {
               slider.slider_mc.useNotches = true;
            }
            else
            {
               slider.slider_mc.useNotches = false;
            }
         }
         slider.slider_mc.liveDragging = true;
         slider.amount_txt.htmlText = this.roundFloat(selectedIndex);
         if(max > 50)
         {
            slider.slider_mc.tickInterval = 10;
         }
         else if(max > 20)
         {
            slider.slider_mc.tickInterval = 5;
         }
         else
         {
            slider.slider_mc.tickInterval = 1;
         }
         slider.amount_txt.mouseEnabled = false;
         slider.min_txt.mouseEnabled = false;
         slider.max_txt.mouseEnabled = false;
         slider.slider_mc.bgToWidthDiff = -6;
         this.totalHeight = this.totalHeight + (slider.mHeight + this.elementHSpacing);
         if(slider.label_txt.textWidth > this.minWidth)
         {
            if(this.maxWidth < slider.label_txt.textWidth)
            {
               this.maxWidth = slider.label_txt.textWidth;
            }
         }
         else
         {
            this.maxWidth = this.minWidth;
         }
         slider.label_txt.y = 26 - Math.round(slider.label_txt.textHeight * 0.5);
         this.list.addElement(slider);
         slider.formHL_mc.alpha = 0;
         this.HLCounter = this.HLCounter + 1;
         slider.slider_mc.value = selectedIndex;
         slider.resetAmountPos();
         MainTimeline.SetTextFormat(slider.label_txt, 16);
         MainTimeline.SetTextFormat(slider.min_txt, 16);
         MainTimeline.SetTextFormat(slider.max_txt, 16);
         MainTimeline.SetTextFormat(slider.amount_txt, 16);
      }
      
      public function setMenuSlider(id:Number, sliderValue:Number) : *
      {
         var slider:MovieClip = this.getElementByID(id);
         if(slider && slider.slider_mc)
         {
            slider.slider_mc.value = sliderValue;
            slider.amount_txt.htmlText = this.roundFloat(param2);
            slider.resetAmountPos();
         }
      }
      
      public function getElementByID(id:Number) : MovieClip
      {
         return this.list.getElementByNumber("id",id);
      }
      
      public function addMenuButton(buttonId:Number, labelText:String, clickSound:String, isEnabled:Boolean, tooltipText:String) : *
      {
         var menuButton:MovieClip = new Menu_button();
         menuButton.x = this.elementX;
         MainTimeline.SetTextFormat(menuButton.label_txt, 16);
         menuButton.label_txt.htmlText = labelText;
         menuButton.id = buttonId;
         menuButton.name = "item" + this.list.length + "_mc";
         menuButton.mHeight = 70;
         menuButton.tooltip = tooltipText;
         this.totalHeight = this.totalHeight + (menuButton.mHeight + this.elementHSpacing);
         if(menuButton.label_txt.textWidth > this.minWidth)
         {
            if(this.maxWidth < menuButton.label_txt.textWidth)
            {
               this.maxWidth = menuButton.label_txt.textWidth;
            }
         }
         else
         {
            this.maxWidth = this.minWidth;
         }
         menuButton.disable_mc.visible = !isEnabled;
         menuButton.bg_mc.visible = isEnabled;
         this.list.addElement(menuButton);
         menuButton.formHL_mc.alpha = 0;
         if(clickSound.length > 0)
         {
            menuButton.snd_onUp = clickSound;
         }
         else
         {
            menuButton.snd_onUp = "UI_Gen_XButton_Click";
         }
         this.HLCounter = this.HLCounter + 1;
      }
      
      public function setButtonEnabled(id:Number, param2:Boolean) : *
      {
         var _loc3_:MovieClip = this.getElementByID(id);
         if(_loc3_)
         {
            _loc3_.disable_mc.visible = !param2;
            _loc3_.bg_mc.visible = param2;
         }
      }
      
      public function moveCursor(id:Boolean) : *
      {
         if(id)
         {
            this.list.previous();
         }
         else
         {
            this.list.next();
         }
      }
      
      public function setCursorPosition(id:Number) : *
      {
         var _loc2_:MovieClip = this.getElementByID(id);
         if(_loc2_)
         {
            this.list.selectMC(_loc2_);
         }
      }
      
      public function executeSelected() : *
      {
         var _loc1_:MovieClip = this.list.getCurrentMovieClip();
         if(_loc1_)
         {
            _loc1_.buttonPressed(null);
         }
      }
      
      public function removeItems() : *
      {
         this.list.clearElements();
         this.totalHeight = 0;
         this.maxWidth = 0;
      }
      
      public function resetMenuButtons(id:Number) : *
      {
         var index:uint = 0;
         var menuButton:MovieClip = null;
         var buttonCount:Number = this.menuBtnList.length;
         if(buttonCount > 0)
         {
            index = 0;
            while(index < buttonCount)
            {
               menuButton = this.menuBtnList.getAt(index);
               if(menuButton && menuButton.buttonID != id)
               {
                  menuButton.setActive(false);
               }
               index++;
            }
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
         // this.menuBtnList = new listDisplay();
         // this.menuBtnList.EL_SPACING = 2;
         // this.menuButtonContainer_mc.addChild(this.menuBtnList);
         this.menuBtnList = new scrollList("down_id","up_id","handle_id","scrollBg_id");
         this.menuBtnList.leftAligned = true;
         this.menuBtnList.m_forceDepthReorder = true;
         //this.menuBtnList.TOP_SPACING = 20;
         this.menuBtnList.EL_SPACING = 2;
         this.menuBtnList.setFrame(352,786);
         this.menuBtnList.m_scrollbar_mc.m_SCROLLSPEED = 54;
         this.menuBtnList.m_scrollbar_mc.m_hideWhenDisabled = false;
         this.menuBtnList.m_scrollbar_mc.y = 16;
         this.menuBtnList.SB_SPACING = -3;
         this.menuBtnList.m_scrollbar_mc.setLength(782);
         this.menuButtonContainer_mc.addChild(this.menuBtnList);
         this.base = root as MovieClip;
         this.HLCounter = 0;
         this.listHolder_mc.addChild(this.list);
         this.cancel_mc.pressedFunc = this.cancelPressed;
         this.ok_mc.pressedFunc = this.okPressed;
         this.apply_mc.pressedFunc = this.applyPressed;
         this.elementHSpacing = 10;
         this.minWidth = 400;

         MainTimeline.SetTextFormat(this.cancel_mc.text_txt, 22);
         this.cancel_mc.text_txt.htmlText = "Cancel";
         MainTimeline.SetTextFormat(this.ok_mc.text_txt, 22);
         this.ok_mc.text_txt.htmlText = "Confirm";
         MainTimeline.SetTextFormat(this.apply_mc.text_txt, 22);
         this.apply_mc.text_txt.htmlText = "Apply";
      }
   }
}
