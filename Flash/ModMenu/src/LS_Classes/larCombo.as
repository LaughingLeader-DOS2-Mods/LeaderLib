package LS_Classes
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   
   public dynamic class larCombo extends MovieClip
   {
       
      
      public var SND_Over:String = "UI_Generic_Over";
      
      public var SND_Open:String = "UI_MainMenu_MenuDrop_Open";
      
      public var SND_Close:String = "UI_MainMenu_MenuDrop_Close";
      
      public var SND_Click:String = "UI_Gen_XButton_Click";
      
      private var m_selIndex:int;
      
      private var _rowCount:uint = 8;
      
      private var m_items_array:Array;
      
      private var m_scrollList:scrollList;
      
      public var m_isOpen:Boolean = false;
      
      private var _elH:Number = 30;
      
      private var _editable:Boolean = false;
      
      private var m_bg_mc:MovieClip;
      
      public var top_mc:MovieClip;
      
      public var bgTopSizeDiff:Number = -6;
      
      public var bgTopDisplacement:Number = 0;
      
      public var m_dropOutYDisplacement:Number = 0;
      
      public var m_forceUpdate:Boolean = false;
      
      private var m_enabled:Boolean;
      
      private var m_selectContainer:MovieClip;
      
      private var m_bgHSpacing:Number = 6;
      
      public var m_listTopHSpacing:Number = 4;
      
      private var cmbElement:Class;
      
      private var m_mouseWheelEnabledWhenClosed:Boolean = false;
      
      public var divider_mc;
      
      public var onOver:Function = null;
      
      public var onOut:Function = null;
      
      private var hasDeactivateListener:Boolean = false;
      
      private var pressedFunc:Function;
      
      public function larCombo(param1:String = "comboElement", param2:String = "comboDDBG")
      {
         var _loc4_:MovieClip = null;
         this.m_selectContainer = new MovieClip();
         super();
         this.m_items_array = new Array();
         this.m_scrollList = new scrollList("down_id_small","up_id_small","handle_id_small","scrollBg_id_small");
         this.m_scrollList.x = 2;
         this.cmbElement = getDefinitionByName(param1) as Class;
         this.m_scrollList.EL_SPACING = 1;
         this.m_scrollList.SB_SPACING = -(this.m_scrollList.m_scrollbar_mc.width + 9);
         var _loc3_:Class = getDefinitionByName(param2) as Class;
         this.m_bg_mc = new _loc3_();
         this.m_selectContainer.addChild(this.m_bg_mc);
         this.m_selectContainer.addChild(this.m_scrollList);
         this.m_scrollList.m_scrollbar_mc.addCustomStage(this.stage);
         this.m_scrollList.m_scrollbar_mc.ScaleBG = true;
         this.m_bg_mc.y = 0;
         this.m_scrollList.y = this.m_listTopHSpacing;
         this.m_enabled = true;
         if(this.top_mc)
         {
            this.top_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.topDown);
            this.top_mc.addEventListener(MouseEvent.ROLL_OUT,this.topOut);
            this.top_mc.addEventListener(MouseEvent.ROLL_OVER,this.topOver);
            _loc4_ = new this.cmbElement();
            this.m_scrollList.setFrame(this.top_mc.width + this.bgTopSizeDiff,_loc4_.height * this._rowCount);
            this.m_bg_mc.width = this.top_mc.width + this.bgTopSizeDiff;
            MainTimeline.SetTextFormat(this.top_mc.text_txt);
         }
         this.m_scrollList.addEventListener(MouseEvent.ROLL_OUT,this.scrollListOut);
         this.m_scrollList.addEventListener(Event.CHANGE,this.comboScrolled);

      }

      public function set divider(param1:MovieClip) : *
      {
         this.divider_mc = param1;
         if(this.divider_mc)
         {
            this.m_selectContainer.addChild(this.divider_mc);
            this.divider_mc.height = Math.round(this.m_bg_mc.height - this.divider_mc.y * 2);
            this.divider_mc.visible = this.m_scrollList.m_scrollbar_mc.visible;
         }
      }
      
      public function set bgHSpacing(param1:Number) : *
      {
         this.m_bgHSpacing = param1;
         this._resizeDDBg();
      }
      
      public function set SB_SPACING(param1:Number) : *
      {
         this.m_scrollList.SB_SPACING = param1;
      }
      
      public function get SB_SPACING() : Number
      {
         return this.m_scrollList.SB_SPACING;
      }
      
      public function init(param1:Function) : *
      {
         this.pressedFunc = param1;
      }
      
      public function next() : *
      {
         if(this.m_enabled)
         {
            this.m_scrollList.next();
         }
      }
      
      public function acceptSelection() : *
      {
         this.selectedIndex = this.m_scrollList.currentSelection;
      }
      
      private function comboScrolled(param1:Event) : *
      {
         dispatchEvent(new Event("Scrolled"));
      }
      
      public function previous() : *
      {
         if(this.m_enabled)
         {
            this.m_scrollList.previous();
         }
      }
      
      public function setElementClass(param1:String = "comboElement") : *
      {
         this.cmbElement = getDefinitionByName(param1) as Class;
         var _loc2_:MovieClip = new this.cmbElement();
         this.m_scrollList.setFrame(this.top_mc.width + this.bgTopSizeDiff,_loc2_.height * this._rowCount);
      }
      
      public function close() : *
      {
         ExternalInterface.call("PlaySound",this.SND_Close);
         this.m_isOpen = false;
         this.top_mc.button_mc.gotoAndStop(1);
         dispatchEvent(new Event(Event.CLOSE,true));
         if(this.hasDeactivateListener)
         {
            removeEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
            this.stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDeactivate);
            this.hasDeactivateListener = false;
         }
         this.m_scrollList.mouseWheelEnabled = false;
         if(this.m_mouseWheelEnabledWhenClosed)
         {
            this.stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.handlemouseWheelEnabledWhenClosed);
         }
         if(this.m_selectContainer)
         {
            if(this.m_selectContainer.parent)
            {
               this.m_selectContainer.parent.removeChild(this.m_selectContainer);
            }
         }
      }
      
      public function open() : *
      {
         var _loc1_:Point = null;
         var _loc2_:MovieClip = null;
         if(this.m_enabled)
         {
            ExternalInterface.call("PlaySound",this.SND_Open);
            this.m_isOpen = true;
            this.top_mc.button_mc.gotoAndStop(3);
            _loc1_ = this.localToGlobal(new Point(0,0));
            this.m_selectContainer.x = _loc1_.x;
            this.m_selectContainer.y = Math.round(this.top_mc.height + _loc1_.y + this.m_dropOutYDisplacement);
            if(this.stage)
            {
               this.stage.addChild(this.m_selectContainer);
            }
            dispatchEvent(new Event(Event.OPEN,true));
            if(this.stage && !this.hasDeactivateListener)
            {
               this.stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onDeactivate);
               this.hasDeactivateListener = true;
               addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
            }
            _loc2_ = this.m_scrollList.getElement(this.m_selIndex);
            if(_loc2_)
            {
               this.m_scrollList.select(_loc2_.list_pos);
            }
            this.m_scrollList.mouseWheelEnabled = true;
            if(this.m_mouseWheelEnabledWhenClosed)
            {
               this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL,this.handlemouseWheelEnabledWhenClosed);
            }
         }
      }
      
      private function removedFromStageHandler(param1:Event) : *
      {
         var _loc2_:DisplayObject = param1.currentTarget as DisplayObject;
         if(_loc2_)
         {
            _loc2_.removeEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
         }
         this.close();
      }
      
      public function get mouseWheelEnabledWhenClosed() : Boolean
      {
         return this.m_mouseWheelEnabledWhenClosed;
      }
      
      public function get scrolledY() : Number
      {
         return this.m_scrollList.scrolledY;
      }
      
      public function set mouseWheelEnabledWhenClosed(param1:Boolean) : *
      {
         if(this.m_mouseWheelEnabledWhenClosed != param1)
         {
            this.m_mouseWheelEnabledWhenClosed = param1;
            if(!this.m_isOpen)
            {
               this.stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.handlemouseWheelEnabledWhenClosed);
            }
         }
      }
      
      private function handlemouseWheelEnabledWhenClosed(param1:MouseEvent) : void
      {
         var _loc2_:Number = param1.delta;
         if(param1.delta < 0)
         {
            while(_loc2_ < 0)
            {
               this.next();
               _loc2_++;
            }
         }
         else
         {
            while(_loc2_ > 0)
            {
               this.previous();
               _loc2_--;
            }
         }
      }
      
      public function get selectedIndex() : int
      {
         return this.m_selIndex;
      }
      
      override public function get enabled() : Boolean
      {
         return this.m_enabled;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         this.m_enabled = param1;
         super.enabled = param1;
         if(param1)
         {
            this.alpha = 1;
         }
         else
         {
            this.alpha = 0.5;
            if(this.m_isOpen)
            {
               this.close();
            }
         }
      }
      
      public function set selectedIndex(param1:int) : *
      {
         var _loc2_:Boolean = false;
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = null;
         if(param1 > -1 && this.m_items_array.length > this.selectedIndex)
         {
            _loc2_ = false;
            _loc3_ = this.m_scrollList.getElement(this.m_selIndex);
            if(_loc3_)
            {
               _loc3_.sel_mc.visible = false;
               if(_loc3_.comboDeselect != null)
               {
                  _loc3_.comboDeselect();
               }
            }
            if(this.m_selIndex != param1)
            {
               _loc2_ = true;
            }
            this.m_selIndex = param1;
            _loc4_ = this.m_scrollList.getElement(this.m_selIndex);
            if(_loc4_)
            {
               _loc4_.sel_mc.visible = true;
               this.top_mc.text_txt.htmlText = this.m_items_array[this.m_selIndex].label;
               this.top_mc._item = this.m_items_array[this.m_selIndex];
               this.m_scrollList.select(_loc4_.list_pos);
               if(_loc4_.comboSelect != null)
               {
                  _loc4_.comboSelect();
               }
               if(this.top_mc.update != null)
               {
                  this.top_mc.update();
               }
            }
            else
            {
               this.top_mc.text_txt.htmlText = "";
            }
            if(this.m_enabled && _loc2_ || this.m_forceUpdate)
            {
               dispatchEvent(new Event(Event.CHANGE,true));
            }
         }
      }
      
      public function get selectedMc() : MovieClip
      {
         return this.m_scrollList.getCurrentMovieClip();
      }
      
      public function get rowCount() : uint
      {
         return this._rowCount;
      }
      
      public function set rowCount(param1:uint) : *
      {
         var _loc2_:MovieClip = null;
         this._rowCount = param1;
         if(this.top_mc)
         {
            _loc2_ = new this.cmbElement();
            this.m_scrollList.setFrame(this.top_mc.width + this.bgTopSizeDiff,(_loc2_.height + this.m_scrollList.EL_SPACING) * this._rowCount);
            this._resizeDDBg();
         }
      }
      
      public function get selectedLabel() : String
      {
         if(this.m_items_array.length > this.m_selIndex && this.m_selIndex > 0)
         {
            return this.m_items_array[this.m_selIndex].label;
         }
         return "";
      }
      
      public function get text() : String
      {
         return this.top_mc.text_txt.text;
      }
      
      public function set text(param1:String) : *
      {
         this.top_mc.text_txt.htmlText = param1;
      }
      
      public function get prompt() : String
      {
         return this.top_mc.text_txt.text;
      }
      
      public function set prompt(param1:String) : *
      {
         this.top_mc.text_txt.htmlText = param1;
      }
      
      public function get length() : int
      {
         return this.m_items_array.length;
      }
      
      public function get selectedItem() : Object
      {
         if(this.m_items_array.length > this.m_selIndex && this.m_selIndex >= 0)
         {
            return this.m_items_array[this.m_selIndex];
         }
         return null;
      }
      
      public function selectItemByID(param1:Number) : *
      {
         var _loc2_:* = undefined;
         for(_loc2_ in this.m_items_array)
         {
            if(this.m_items_array[_loc2_].id != null && this.m_items_array[_loc2_].id == param1)
            {
               this.selectedIndex = _loc2_;
               break;
            }
         }
      }
      
      public function selectItemByLabel(param1:String) : *
      {
         var _loc2_:* = undefined;
         for(_loc2_ in this.m_items_array)
         {
            if(this.m_items_array[_loc2_].label != null && this.m_items_array[_loc2_].label == param1)
            {
               this.selectedIndex = _loc2_;
               break;
            }
         }
      }
      
      public function addItem(entryObject:Object) : MovieClip
      {
         var comboEntry:MovieClip = new this.cmbElement();
         comboEntry.Combo = this;
         comboEntry._item = entryObject;
         comboEntry.text_txt.htmlText = entryObject.label;
         MainTimeline.SetTextFormat(comboEntry.text_txt);
         if(entryObject.id != null)
         {
            comboEntry.id = entryObject.id;
         }
         comboEntry.addEventListener(MouseEvent.MOUSE_UP,this.elUp);
         comboEntry.addEventListener(MouseEvent.ROLL_OVER,this.elOver);
         comboEntry.hl_mc.visible = false;
         comboEntry.sel_mc.visible = false;
         this.m_scrollList.addElement(comboEntry);
         this.m_items_array.push(entryObject);
         this._resizeDDBg();
         return comboEntry;
      }
      
      public function removeAll() : *
      {
         this.m_items_array = new Array();
         this.m_scrollList.clearElements();
         this.m_selIndex = 0;
         this._resizeDDBg();
      }
      
      public function removeItem(param1:Object) : void
      {
         var _loc2_:uint = 0;
         while(_loc2_ < this.m_items_array.length)
         {
            if(this.m_items_array[_loc2_] == param1)
            {
               this.m_items_array.splice(_loc2_,1);
               this.m_scrollList.removeElement(_loc2_);
               break;
            }
            _loc2_++;
         }
      }
      
      public function getItemAt(param1:uint) : Object
      {
         if(this.m_items_array.length > param1)
         {
            return this.m_items_array[this.m_selIndex];
         }
         return null;
      }
      
      public function getIndexByNumber(param1:String, param2:Number) : Number
      {
         var _loc3_:* = 0;
         while(_loc3_ < this.m_items_array.length)
         {
            if(this.m_items_array[_loc3_][param1] && this.m_items_array[_loc3_][param1] == param2)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return -1;
      }
      
      private function _resizeDDBg() : *
      {
         var _loc1_:MovieClip = null;
         if(this.m_items_array.length > 0)
         {
            _loc1_ = new this.cmbElement();
            if(this.m_items_array.length < this._rowCount)
            {
               this.m_bg_mc.height = Math.round(this.m_scrollList.y + (_loc1_.height + this.m_scrollList.EL_SPACING) * this.m_items_array.length - this.m_scrollList.EL_SPACING + this.m_bgHSpacing);
            }
            else
            {
               this.m_bg_mc.height = Math.round(this.m_scrollList.y + (_loc1_.height + this.m_scrollList.EL_SPACING) * this._rowCount - this.m_scrollList.EL_SPACING + this.m_bgHSpacing);
            }
         }
         else
         {
            this.m_bg_mc.height = 20;
            this.m_scrollList.checkScrollBar();
         }
         this.m_bg_mc.width = Math.round(this.top_mc.width + this.bgTopSizeDiff);
         this.m_bg_mc.x = Math.round(-this.bgTopSizeDiff * 0.5 + this.bgTopDisplacement);
         if(this.divider_mc)
         {
            this.divider_mc.height = Math.round(this.m_bg_mc.height - this.divider_mc.y * 2);
            this.divider_mc.visible = this.m_scrollList.m_scrollbar_mc.visible;
         }
      }
      
      private function topDown(param1:MouseEvent) : *
      {
         this.top_mc.addEventListener(MouseEvent.MOUSE_UP,this.topUp);
      }
      
      private function topUp(param1:MouseEvent) : *
      {
         if(this.m_isOpen)
         {
            this.close();
         }
         else
         {
            this.open();
         }
         this.top_mc.removeEventListener(MouseEvent.MOUSE_UP,this.topUp);
      }
      
      private function topOver(param1:MouseEvent) : *
      {
         if(this.onOver != null)
         {
            this.onOver(param1);
         }
         if(this.m_enabled && !this.m_isOpen)
         {
            ExternalInterface.call("PlaySound",this.SND_Over);
            this.top_mc.button_mc.gotoAndStop(2);
         }
      }
      
      private function topOut(param1:MouseEvent) : *
      {
         if(this.onOut != null)
         {
            this.onOut(param1);
         }
         if(this.m_enabled && !this.m_isOpen)
         {
            ExternalInterface.call("PlaySound",this.SND_Over);
            this.top_mc.button_mc.gotoAndStop(1);
         }
      }
      
      private function elUp(param1:MouseEvent) : *
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc2_)
         {
            ExternalInterface.call("PlaySound",this.SND_Click);
            this.selectedIndex = _loc2_.list_pos;
            if(this.pressedFunc != null)
            {
               this.pressedFunc();
            }
            this.close();
         }
      }
      
      private function elOver(param1:MouseEvent) : *
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         this.m_scrollList.select(_loc2_.list_pos);
         ExternalInterface.call("PlaySound",this.SND_Over);
      }
      
      private function scrollListOut(param1:MouseEvent) : *
      {
      }
      
      private function onDeactivate(param1:MouseEvent) : *
      {
         if(!this.contains(param1.target as DisplayObject) && !this.m_selectContainer.contains(param1.target as DisplayObject) && param1.target != param1.currentTarget)
         {
            this.close();
         }
      }
      
      private function GetScrollRectY() : Number
      {
         var _loc1_:Number = 0;
         var _loc2_:DisplayObject = this.parent;
         while(_loc2_)
         {
            if(_loc2_.scrollRect != null)
            {
               _loc1_ = _loc1_ - _loc2_.scrollRect.y;
            }
            _loc2_ = _loc2_.parent;
         }
         return _loc1_;
      }
   }
}
