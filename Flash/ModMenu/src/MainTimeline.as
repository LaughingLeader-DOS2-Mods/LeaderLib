package
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.external.ExternalInterface;
   import font.UbutunuMonoRegular;
   
   public dynamic class MainTimeline extends MovieClip
   {
      public var mainMenu_mc:MovieClip;
      
      public var selectedInfo_txt:TextField;
      
      public var events:Array;
      
      public var layout:String;
      
      public var curTooltip:String;
      
      public var hasTooltip:Boolean;
      
      public const ElW:Number = 942;
      
      public var update_Array:Array;
      
      public var baseUpdate_Array:Array;
      
      public var button_array:Array;
      
      public const anchorId:String = "LeaderLibModMenu";
      
      public function MainTimeline()
      {
         super();
         addFrameScript(0,this.frame1);
      }

      private static var ubuntuFont:UbutunuMonoRegular = new UbutunuMonoRegular();

      public static function SetTextFormat(txt:TextField, size:Number = 16)
      {
         txt.defaultTextFormat.size = size;
         txt.defaultTextFormat.color = 0xFFFFFF;
         txt.defaultTextFormat.font = ubuntuFont.fontName;
         //txt.setTextFormat(txt.defaultTextFormat, 0, txt.htmlText.length);
      }

      public function setMenuScrolling(enabled:Boolean) : *
      {
         this.mainMenu_mc.setMenuScrolling(enabled);
      }
      
      public function onEventInit() : *
      {
         ExternalInterface.call("registerAnchorId", anchorId);
			ExternalInterface.call("setPosition","center","screen","center");
         this.selectedInfo_txt.autoSize = TextFieldAutoSize.LEFT;
         this.selectedInfo_txt.visible = false;
         this.selectedInfo_txt.mouseEnabled = false;
         this.mainMenu_mc.setMainScrolling(true);
         this.mainMenu_mc.ok_mc.snd_Click = "UI_Gen_Accept";
         this.mainMenu_mc.apply_mc.snd_Click = "UI_Gen_Apply";
      }

      public function modMenuSetTitle(text:String) : *
      {
         this.mainMenu_mc.setTitle(text);
      }

      public function modMenuSetTopTitle(text:String) : *
      {
         this.mainMenu_mc.toptitle_txt.htmlText = text;
      }

      public function modMenuAddMenuButton(buttonId:Number, text:String, clickSound:String, isEnabled:Boolean, tooltip:String) : *
      {
         this.mainMenu_mc.addMenuButton(buttonId,text,clickSound,isEnabled,tooltip);
      }

      public function modMenuAddMenuLabel(text:String) : *
      {
         this.mainMenu_mc.addMenuLabel(text);
      }

      public function modMenuAddCheckbox(id:Number, text:String, isEnabled:Boolean, stateId:Number, filterEnabled:Boolean, tooltip:String) : *
      {
         this.mainMenu_mc.addMenuCheckbox(id,text,isEnabled,stateId,filterEnabled,tooltip);
      }

      public function modMenuAddMenuDropDown(id:Number, text:String, tooltip:String) : *
      {
         this.mainMenu_mc.addMenuDropDown(id,text,tooltip);
      }
      
      public function modMenuAddMenuDropDownEntry(id:Number, text:String) : *
      {
         this.mainMenu_mc.addMenuDropDownEntry(id,text);
      }

      public function modMenuAddMenuSlider(id:Number, text:String, index:Number, min:Number, max:Number, snapInterval:Number, isDisabled:Boolean, tooltip:String) : *
      {
         this.mainMenu_mc.addMenuSlider(id,text,index,min,max,snapInterval,isDisabled,tooltip);
      }

      public function modMenuSetMenuDropDownEnabled(id:Number, isDisabled:Boolean) : *
      {
         this.setMenuDropDownEnabled(id,isDisabled);
      }

      public function modMenuSetMenuCheckbox(id:Number, isDisabled:Boolean, state:Number) : *
      {
         this.setMenuCheckbox(id,isDisabled,state);
      }
      
      public function parseUpdateArray() : *
      {
         var updateIndex:uint = 0;
         var movieClipId:Number = NaN;
         var htmlText:String = null;
         var controlDisabled:Boolean = false;
         var stateId:Number = NaN;
         var filterEnabled:Boolean = false;
         var tooltip:String = null;
         var controlId:Number = NaN;
         var selectedIndex:Number = NaN;
         var menuSliderId:Number = NaN;
         var sliderMin:Number = NaN;
         var sliderMax:Number = NaN;
         var sliderSnapInterval:Number = NaN;
         var isDisabled:Boolean = false;
         var buttonId:Number = NaN;
         var clickSound:String = null;
         var titleText:String = null;
         var checkboxState:Number = NaN;
         var updateArrayLength:Number = this.update_Array.length;
         if(updateArrayLength > 0)
         {
            updateIndex = 0;
            while(updateIndex < updateArrayLength)
            {
               switch(this.update_Array[updateIndex++])
               {
                  case 0:
                     movieClipId = this.update_Array[updateIndex++];
                     htmlText = this.update_Array[updateIndex++];
                     controlDisabled = this.update_Array[updateIndex++];
                     stateId = this.update_Array[updateIndex++];
                     filterEnabled = this.update_Array[updateIndex++];
                     tooltip = this.update_Array[updateIndex++];
                     this.mainMenu_mc.addMenuCheckbox(movieClipId,htmlText,controlDisabled,stateId,filterEnabled,tooltip);
                     continue;
                  case 1:
                     controlId = this.update_Array[updateIndex++];
                     htmlText = this.update_Array[updateIndex++];
                     tooltip = this.update_Array[updateIndex++];
                     this.mainMenu_mc.addMenuDropDown(controlId,htmlText,tooltip);
                     continue;
                  case 2:
                     controlId = this.update_Array[updateIndex++];
                     htmlText = this.update_Array[updateIndex++];
                     this.mainMenu_mc.addMenuDropDownEntry(controlId,htmlText);
                     continue;
                  case 3:
                     controlId = this.update_Array[updateIndex++];
                     selectedIndex = this.update_Array[updateIndex++];
                     this.selectMenuDropDownEntry(controlId,selectedIndex);
                     continue;
                  case 4:
                     menuSliderId = this.update_Array[updateIndex++];
                     htmlText = this.update_Array[updateIndex++];
                     selectedIndex = this.update_Array[updateIndex++];
                     sliderMin = this.update_Array[updateIndex++];
                     sliderMax = this.update_Array[updateIndex++];
                     sliderSnapInterval = this.update_Array[updateIndex++];
                     isDisabled = this.update_Array[updateIndex++];
                     tooltip = this.update_Array[updateIndex++];
                     this.mainMenu_mc.addMenuSlider(menuSliderId,htmlText,selectedIndex,sliderMin,sliderMax,sliderSnapInterval,isDisabled,tooltip);
                     continue;
                  case 5:
                     buttonId = this.update_Array[updateIndex++];
                     htmlText = this.update_Array[updateIndex++];
                     clickSound = this.update_Array[updateIndex++];
                     controlDisabled = this.update_Array[updateIndex++];
                     tooltip = this.update_Array[updateIndex++];
                     this.mainMenu_mc.addMenuButton(buttonId,htmlText,clickSound,controlDisabled,tooltip);
                     continue;
                  case 6:
                     htmlText = this.update_Array[updateIndex++];
                     this.mainMenu_mc.addMenuLabel(htmlText);
                     continue;
                  case 7:
                     titleText = this.update_Array[updateIndex++];
                     this.mainMenu_mc.setTitle(titleText);
                     continue;
                  case 8:
                     controlId = this.update_Array[updateIndex++];
                     controlDisabled = this.update_Array[updateIndex++];
                     this.setMenuDropDownEnabled(controlId,controlDisabled);
                     continue;
                  case 9:
                     movieClipId = this.update_Array[updateIndex++];
                     controlDisabled = this.update_Array[updateIndex++];
                     checkboxState = !!this.update_Array[updateIndex++]?Number(1):Number(0);
                     this.setMenuCheckbox(movieClipId,controlDisabled,checkboxState);
                     continue;
                  default:
                     continue;
               }
            }
         }
         this.update_Array = new Array();
      }

      public function updateAddBaseTopTitleText(topTitleText:String) : *
      {
         this.baseUpdate_Array.push(2);
         this.baseUpdate_Array.push(topTitleText);
      }

      public function updateAddBaseOptionButton(buttonId:Number, buttonText:String, isCurrent:Boolean) : *
      {
         this.baseUpdate_Array.push(0);
         this.baseUpdate_Array.push(buttonId);
         this.baseUpdate_Array.push(buttonText);
         this.baseUpdate_Array.push(isCurrent);
      }
      
      public function parseBaseUpdateArray() : *
      {
         var index:uint = 0;
         var buttonId:Number = NaN;
         var buttonText:String = null;
         var isCurrent:Boolean = false;
         var lastButton:Object = null;
         var topTitleText:String = null;
         var length:Number = this.baseUpdate_Array.length;
         if(length > 0)
         {
            index = 0;
            while(index < length)
            {
               switch(this.baseUpdate_Array[index++])
               {
                  case 0:
                     buttonId = this.baseUpdate_Array[index++];
                     buttonText = this.baseUpdate_Array[index++];
                     isCurrent = this.baseUpdate_Array[index++];
                     this.mainMenu_mc.addOptionButton(buttonText,"switchMenu",buttonId,isCurrent);
                     continue;
                  case 1:
                     lastButton = this.baseUpdate_Array[index++];
                     buttonId = lastButton as Number;
                     buttonText = this.baseUpdate_Array[index++];
                     this.button_array[buttonId].text_txt.htmlText = buttonText.toUpperCase();
                     continue;
                  case 2:
                     topTitleText = this.baseUpdate_Array[index++];
                     this.mainMenu_mc.toptitle_txt.htmlText = topTitleText;
                     continue;
                  default:
                     continue;
               }
            }
            this.baseUpdate_Array = new Array();
         }
      }
      
      public function onEventResize() : *
      {
      }
      
      public function onEventUp(id:Number) : Boolean
      {
         return false;
      }
      
      public function onEventDown(id:Number) : Boolean
      {
         var _loc2_:Boolean = false;
         switch(this.events[id])
         {
            case "IE UIUp":
               this.mainMenu_mc.moveCursor(true);
               _loc2_ = true;
               break;
            case "IE UIDown":
               this.mainMenu_mc.moveCursor(false);
               _loc2_ = true;
               break;
            case "IE UICancel":
               this.cancelChanges();
               _loc2_ = true;
         }
         return _loc2_;
      }
      
      public function hideWin() : void
      {
         this.mainMenu_mc.visible = false;
      }
      
      public function showWin() : void
      {
         this.mainMenu_mc.visible = true;
      }
      
      public function getHeight() : Number
      {
         return this.mainMenu_mc.height;
      }
      
      public function getWidth() : Number
      {
         return this.mainMenu_mc.width;
      }
      
      public function setX(x:Number) : void
      {
         this.mainMenu_mc.x = x;
      }
      
      public function setY(y:Number) : void
      {
         this.mainMenu_mc.y = y;
      }
      
      public function setPos(x:Number, y:Number) : void
      {
         this.mainMenu_mc.x = x;
         this.mainMenu_mc.y = y;
      }
      
      public function getX() : Number
      {
         return this.mainMenu_mc.x;
      }
      
      public function getY() : Number
      {
         return this.mainMenu_mc.y;
      }
      
      public function openMenu() : *
      {
         this.mainMenu_mc.openMenu();
         ExternalInterface.call("focus");
         ExternalInterface.call("inputFocus");
      }
      
      public function closeMenu() : *
      {
         this.mainMenu_mc.closeMenu();
         ExternalInterface.call("focusLost");
         ExternalInterface.call("inputFocusLost");
      }
      
      public function cancelChanges() : *
      {
         this.mainMenu_mc.cancelPressed();
      }
      
      public function addMenuInfoLabel(id:Number, labelText:String, infoText:String) : *
      {
         this.mainMenu_mc.addMenuInfoLabel(id,labelText,infoText);
      }
      
      public function setMenuCheckbox(id:Number, enabled:Boolean, state:Number) : *
      {
         this.mainMenu_mc.setMenuCheckbox(id,enabled,state);
      }
      
      public function addMenuSelector(id:Number, text:String) : *
      {
         this.mainMenu_mc.addMenuSelector(id,text);
      }
      
      public function addMenuSelectorEntry(id:Number, text:String) : *
      {
         this.mainMenu_mc.addMenuSelectorEntry(id,text);
      }
      
      public function selectMenuDropDownEntry(id:Number, index:Number) : *
      {
         this.mainMenu_mc.selectMenuDropDownEntry(id,index);
      }
      
      public function clearMenuDropDownEntries(id:Number) : *
      {
         this.mainMenu_mc.clearMenuDropDownEntries(id);
      }
      
      public function setMenuDropDownEnabled(id:Number, param2:Boolean) : *
      {
         this.mainMenu_mc.setMenuDropDownEnabled(id,param2);
      }
      
      public function setMenuDropDownDisabledTooltip(id:Number, param2:String) : *
      {
         this.mainMenu_mc.setMenuDropDownDisabledTooltip(id,param2);
      }
      
      public function setMenuSlider(id:Number, param2:Number) : *
      {
         this.mainMenu_mc.setMenuSlider(id,param2);
      }
      
      public function addOptionButton(text:String, callback:String, buttonId:Number, isCurrent:Boolean, fontSize:Number=-1) : *
      {
         this.mainMenu_mc.addOptionButton(text,callback,buttonId,isCurrent,fontSize);
      }
      
      public function setButtonEnabled(id:Number, enabled:Boolean) : *
      {
         this.mainMenu_mc.setButtonEnabled(id,enabled);
      }
      
      public function removeItems() : *
      {
         this.mainMenu_mc.removeItems();
      }
      
      public function setButtonDisable(id:Number, disabled:Boolean) : *
      {
         this.button_array[id].disable_mc.visible = disabled;
         this.button_array[id].bg_mc.visible = !disabled;
      }
      
      public function resetMenuButtons(id:Number) : *
      {
         this.mainMenu_mc.resetMenuButtons(id);
      }
      
      function frame1() : *
      {
         this.events = new Array("IE UIUp","IE UIDown","IE UICancel");
         this.layout = "fixed";
         this.curTooltip = "";
         this.hasTooltip = false;
         this.update_Array = new Array();
         this.baseUpdate_Array = new Array();
         this.button_array = new Array(this.mainMenu_mc.ok_mc,this.mainMenu_mc.cancel_mc,this.mainMenu_mc.apply_mc);
         this.selectedInfo_txt.defaultTextFormat.color = 0xFFFFFF;
         this.selectedInfo_txt.defaultTextFormat.font = "Ubuntu Mono";
      }
   }
}
