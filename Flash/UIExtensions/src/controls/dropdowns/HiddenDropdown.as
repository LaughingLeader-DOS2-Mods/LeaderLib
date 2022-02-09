package controls.dropdowns {
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.external.ExternalInterface;
    import flash.geom.Point;
    import flash.system.Capabilities;
    import LS_Classes.scrollList;
    import interfaces.IDropdownButton;

	//Dropdown without any top_mc label.
    public dynamic class HiddenDropdown extends MovieClip {
        public var SND_Over:String = "UI_Generic_Over";
        public var SND_Open:String = "UI_MainMenu_MenuDrop_Open";
        public var SND_Close:String = "UI_MainMenu_MenuDrop_Close";
        public var SND_Click:String = "UI_Gen_XButton_Click";
        public var m_selIndex:int;
        public var _rowCount:uint = 8;
        public var m_items_array:Array;
        public var m_scrollList:scrollList;
        public var m_isOpen:Boolean = false;
        public var _elH:Number = 30;
        public var _editable:Boolean = false;
        public var m_bg_mc:MovieClip;
        public var bgTopSizeDiff:Number = -6;
        public var bgTopDisplacement:Number = 0;
        public var m_dropOutYDisplacement:Number = 0;
        public var m_forceUpdate:Boolean = false;
        public var m_enabled:Boolean;
        public var m_selectContainer:MovieClip;
        public var m_bgHSpacing:Number = 6;
        public var m_listTopHSpacing:Number = 4;
        public var cmbElement:Class;
        public var m_mouseWheelEnabledWhenClosed:Boolean = false;
        public var divider_mc:MovieClip;
        public var onOver:Function = null;
        public var onOut:Function = null;
        public var positionListFunc:Function = null;
        public var hasDeactivateListener:Boolean = false;
        public var pressedFunc:Function;
		public var button_mc:IDropdownButton;
		public var hovering:Boolean = false;
		public var skipNextChangeInvoke:Boolean = false;
        public var minWidth:Number = 265;

        public function HiddenDropdown(button_mc:IDropdownButton = null, elementClass:String = "LS_Symbols.comboElement", bgClass:String = "LS_Symbols.comboDDBG") {
            var comboElement_mc:MovieClip = null;
            this.m_selectContainer = new MovieClip();
            super();
            this.m_items_array = new Array();
            this.m_scrollList = new scrollList("LS_Symbols.down_id_small", "LS_Symbols.up_id_small", "LS_Symbols.handle_id_small", "LS_Symbols.scrollBg_id_small");
            this.m_scrollList.x = 2;
            this.cmbElement = Registry.GetClass(elementClass);
            this.m_scrollList.EL_SPACING = 1;
            this.m_scrollList.SB_SPACING = -(this.m_scrollList.m_scrollbar_mc.width + 9);
            var bgClassType:Class = Registry.GetClass(bgClass);
            this.m_bg_mc = new bgClassType();
            this.m_selectContainer.addChild(this.m_bg_mc);
            this.m_selectContainer.addChild(this.m_scrollList);
            this.m_scrollList.m_scrollbar_mc.addCustomStage(MainTimeline.Instance.stage);
            this.m_scrollList.m_scrollbar_mc.ScaleBG = true;
            this.m_bg_mc.y = 0;
            this.m_scrollList.y = this.m_listTopHSpacing;
            this.m_enabled = true;
            this.button_mc = button_mc;
            if (this.button_mc) {
				//this.button_mc.addEventListener(MouseEvent.MOUSE_UP, this.topUp);
                this.button_mc.addEventListener(MouseEvent.MOUSE_DOWN, this.topDown);
                this.button_mc.addEventListener(MouseEvent.ROLL_OUT, this.topOut);
                this.button_mc.addEventListener(MouseEvent.ROLL_OVER, this.topOver);
                comboElement_mc = new this.cmbElement();
                this.m_scrollList.setFrame(Math.max(this.minWidth, this.button_mc.width) + this.bgTopSizeDiff, (comboElement_mc.height * this._rowCount) - 4);
                this.m_bg_mc.width = Math.max(this.minWidth, this.button_mc.width) + this.bgTopSizeDiff;
            }
            this.m_scrollList.addEventListener(MouseEvent.ROLL_OUT, this.scrollListOut);
            this.m_scrollList.addEventListener(Event.CHANGE, this.comboScrolled);
        }

        public function set divider(mc:MovieClip):* {
            this.divider_mc = mc;
            if (this.divider_mc) {
                this.m_selectContainer.addChild(this.divider_mc);
                this.divider_mc.height = Math.round(this.m_bg_mc.height - this.divider_mc.y * 2);
                this.divider_mc.visible = this.m_scrollList.m_scrollbar_mc.visible;
            }
        }

        public function set bgHSpacing(value:Number):* {
            this.m_bgHSpacing = value;
            this._resizeDDBg();
        }

        public function set SB_SPACING(value:Number):* {
            this.m_scrollList.SB_SPACING = value;
        }

        public function get SB_SPACING():Number {
            return this.m_scrollList.SB_SPACING;
        }

        public function init(pressedCallback:Function):* {
            this.pressedFunc = pressedCallback;
        }

        public function next():* {
            if (this.m_enabled) {
                this.m_scrollList.next();
            }
        }

        public function acceptSelection():* {
            this.selectedIndex = this.m_scrollList.currentSelection;
        }

        public function comboScrolled(e:Event):* {
            this.dispatchEvent(new Event("Scrolled"));
        }

        public function previous():* {
            if (this.m_enabled) {
                this.m_scrollList.previous();
            }
        }

        public function setElementClass(elementClass:String = "LS_Symbols.comboElement"):* {
            this.cmbElement = Registry.GetClass(elementClass);
            var mc:MovieClip = new this.cmbElement();
			if(this.button_mc) {
				this.m_scrollList.setFrame(Math.max(this.minWidth, this.button_mc.width) + this.bgTopSizeDiff, mc.height * this._rowCount);
			} else {
				this.m_scrollList.setFrame(this.bgTopSizeDiff, mc.height * this._rowCount);
			}
        }

        public function close():* {
            Registry.ExtCall("PlaySound", this.SND_Close);
            this.m_isOpen = false;
            this.button_mc.onOut();
			this.button_mc.toggled = false;
            dispatchEvent(new Event(Event.CLOSE, true));
            if (this.hasDeactivateListener) {
                removeEventListener(Event.REMOVED_FROM_STAGE, this.removedFromStageHandler);
                MainTimeline.Instance.stage.removeEventListener(MouseEvent.MOUSE_DOWN, this.onDeactivate);
                this.hasDeactivateListener = false;
            }
            this.m_scrollList.mouseWheelEnabled = false;
            if (this.m_mouseWheelEnabledWhenClosed) {
                MainTimeline.Instance.stage.addEventListener(MouseEvent.MOUSE_WHEEL, this.handlemouseWheelEnabledWhenClosed);
            }
            if (this.m_selectContainer) {
                if (this.m_selectContainer.parent) {
                    this.m_selectContainer.parent.removeChild(this.m_selectContainer);
                }
            }
        }

        public function open():* {
            var pos:Point = null;
            var element:MovieClip = null;
            if (this.m_enabled) {
                Registry.ExtCall("PlaySound", this.SND_Open);
                this.m_isOpen = true;
                this.button_mc.onClick();
				this.button_mc.toggled = true;
                pos = this.localToGlobal(new Point(0, 0));
				if(this.positionListFunc != null) {
					this.positionListFunc(this.m_selectContainer);
				} else {
					this.m_selectContainer.x = pos.x - this.m_selectContainer.width;
                	this.m_selectContainer.y = Math.round(this.button_mc.height + pos.y + this.m_dropOutYDisplacement);
				}

                if (MainTimeline.Instance.stage) {
                    MainTimeline.Instance.stage.addChild(this.m_selectContainer);
                }
                dispatchEvent(new Event(Event.OPEN, true));
                if (MainTimeline.Instance.stage && !this.hasDeactivateListener) {
                    MainTimeline.Instance.stage.addEventListener(MouseEvent.MOUSE_DOWN, this.onDeactivate);
                    this.hasDeactivateListener = true;
                    addEventListener(Event.REMOVED_FROM_STAGE, this.removedFromStageHandler);
                }
                element = this.m_scrollList.getElement(this.m_selIndex);
                if (element) {
                    this.m_scrollList.select(element.list_pos);
                }
                this.m_scrollList.mouseWheelEnabled = true;
                if (this.m_mouseWheelEnabledWhenClosed) {
                    MainTimeline.Instance.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, this.handlemouseWheelEnabledWhenClosed);
                }
            }
        }

        public function removedFromStageHandler(param1:Event):* {
            var target:DisplayObject = param1.currentTarget as DisplayObject;
            if (target) {
                target.removeEventListener(Event.REMOVED_FROM_STAGE, this.removedFromStageHandler);
            }
            this.close();
        }

        public function get mouseWheelEnabledWhenClosed():Boolean {
            return this.m_mouseWheelEnabledWhenClosed;
        }

        public function get scrolledY():Number {
            return this.m_scrollList.scrolledY;
        }

        public function set mouseWheelEnabledWhenClosed(b:Boolean):* {
            if (this.m_mouseWheelEnabledWhenClosed != b) {
                this.m_mouseWheelEnabledWhenClosed = b;
                if (!this.m_isOpen) {
                    MainTimeline.Instance.stage.addEventListener(MouseEvent.MOUSE_WHEEL, this.handlemouseWheelEnabledWhenClosed);
                }
            }
        }

        public function handlemouseWheelEnabledWhenClosed(e:MouseEvent):void {
            var delta:Number = e.delta;
            if (e.delta < 0) {
                while (delta < 0) {
                    this.next();
                    delta++;
                }
            } else {
                while (delta > 0) {
                    this.previous();
                    delta--;
                }
            }
        }

        public function get selectedIndex():int {
            return this.m_selIndex;
        }


        public function set selectedIndex(index:int):* {
            var changed:Boolean = false;
            var current_mc:MovieClip = null;
            var next_mc:MovieClip = null;
            if (index > -1 && this.m_items_array.length > this.selectedIndex) {
                changed = false;
                current_mc = this.m_scrollList.getElement(this.m_selIndex);
                if (current_mc) {
                    current_mc.sel_mc.visible = false;
                    if (current_mc.comboDeselect != null) {
                        current_mc.comboDeselect();
                    }
                }
                if (this.m_selIndex != index) {
                    changed = true;
                }
                this.m_selIndex = index;
                next_mc = this.m_scrollList.getElement(this.m_selIndex);
                if (next_mc) {
                    next_mc.sel_mc.visible = true;
                    this.m_scrollList.select(next_mc.list_pos);
                    if (next_mc.comboSelect != null) {
                        next_mc.comboSelect();
                    }
                }
                if (!this.skipNextChangeInvoke && (this.m_enabled && changed || this.m_forceUpdate)) {
                    dispatchEvent(new Event(Event.CHANGE, true));
                }
            }
        }

        override public function get enabled():Boolean {
            return this.m_enabled;
        }

        override public function set enabled(b:Boolean):void {
            this.m_enabled = b;
            super.enabled = b;
            if (b) {
                this.alpha = 1;
            } else {
                this.alpha = 0.5;
                if (this.m_isOpen) {
                    this.close();
                }
            }
        }

        public function get selectedMc():MovieClip {
            return this.m_scrollList.getCurrentMovieClip();
        }

        public function get rowCount():uint {
            return this._rowCount;
        }

        public function set rowCount(value:uint):* {
            var element_mc:MovieClip = null;
            this._rowCount = value;
            if (this.button_mc) {
                element_mc = new this.cmbElement();
                this.m_scrollList.setFrame(Math.max(this.minWidth, this.button_mc.width) + this.bgTopSizeDiff, (element_mc.height + this.m_scrollList.EL_SPACING) * this._rowCount);
                this._resizeDDBg();
            }
        }

        public function get selectedLabel():String {
            if (this.m_items_array.length > this.m_selIndex && this.m_selIndex > 0) {
                return this.m_items_array[this.m_selIndex].label;
            }
            return "";
        }

        public function get length():int {
            return this.m_items_array.length;
        }

        public function get selectedItem():Object {
            if (this.m_items_array.length > this.m_selIndex && this.m_selIndex >= 0) {
                return this.m_items_array[this.m_selIndex];
            }
            return null;
        }

        public function selectItemByID(id:Number, skipCallback:Boolean = false):Boolean {
            if (skipCallback) {
                this.skipNextChangeInvoke = true;
            }
            var i:int = 0;
            while (i < this.m_items_array.length) {
                if (this.m_items_array[i].id != null && this.m_items_array[i].id == id) {
                    this.selectedIndex = i;
                    this.skipNextChangeInvoke = false;
                    return true;
                }
                i++;
            }
            this.skipNextChangeInvoke = false;
            return false;
        }

        public function selectItemByLabel(label:String):Boolean {
            var i:int = 0;
            while (i < this.m_items_array.length) {
                if (this.m_items_array[i].label != null && this.m_items_array[i].label == label) {
                    this.selectedIndex = i;
                    return true;
                }
                i++;
            }
            return false;
        }

        public function addItem(entryObject:Object):MovieClip {
            try {
                var comboEntry:MovieClip = new this.cmbElement();
                comboEntry.Combo = this;
                comboEntry._item = entryObject;
                comboEntry.text_txt.htmlText = entryObject.label;
                if (entryObject.id != null) {
                    comboEntry.id = entryObject.id;
                }
                if (entryObject.tooltip != null) {
                    comboEntry.tooltip = entryObject.tooltip;
                }
                comboEntry.addEventListener(MouseEvent.MOUSE_UP, this.elUp);
                comboEntry.addEventListener(MouseEvent.ROLL_OVER, this.elOver);
                comboEntry.sel_mc.visible = false;
                this.m_scrollList.addElement(comboEntry);
                this.m_items_array.push(entryObject);
                this._resizeDDBg();
                return comboEntry;
            } catch (error:Error) {
                if (Capabilities.isDebugger) {
                    trace(error.getStackTrace());
                }
            }
            return null;
        }

        public function removeAll():* {
            this.m_items_array = new Array();
            this.m_scrollList.clearElements();
            this.m_selIndex = 0;
            this._resizeDDBg();
        }

        public function removeItem(obj:Object):void {
            var i:uint = 0;
            while (i < this.m_items_array.length) {
                if (this.m_items_array[i] == obj) {
                    this.m_items_array.splice(i, 1);
                    this.m_scrollList.removeElement(i);
                    break;
                }
                i++;
            }
        }

        public function getItemAt(index:uint):Object {
            if (this.m_items_array.length > index) {
                return this.m_items_array[this.m_selIndex];
            }
            return null;
        }

        public function getIndexByNumber(propertyName:String, value:Number):int {
            var i:int = 0;
            while (i < this.m_items_array.length) {
                if (this.m_items_array[i][propertyName] && this.m_items_array[i][propertyName] == value) {
                    return i;
                }
                i++;
            }
            return -1;
        }

        public function _resizeDDBg():* {
            var element_mc:MovieClip = null;
            if (this.m_items_array.length > 0) {
                element_mc = new this.cmbElement();
                if (this.m_items_array.length < this._rowCount) {
                    this.m_bg_mc.height = Math.round(this.m_scrollList.y + (element_mc.height + this.m_scrollList.EL_SPACING) * this.m_items_array.length - this.m_scrollList.EL_SPACING + this.m_bgHSpacing);
                } else {
                    this.m_bg_mc.height = Math.round(this.m_scrollList.y + (element_mc.height + this.m_scrollList.EL_SPACING) * this._rowCount - this.m_scrollList.EL_SPACING + this.m_bgHSpacing);
                }
            } else {
                this.m_bg_mc.height = 20;
                this.m_scrollList.checkScrollBar();
            }
            this.m_bg_mc.width = Math.round(Math.max(this.minWidth, this.button_mc.width) + this.bgTopSizeDiff);
            this.m_bg_mc.x = Math.round(-this.bgTopSizeDiff * 0.5 + this.bgTopDisplacement);
            if (this.divider_mc) {
                this.divider_mc.height = Math.round(this.m_bg_mc.height - this.divider_mc.y * 2);
                this.divider_mc.visible = this.m_scrollList.m_scrollbar_mc.visible;
            }
        }

        public function topDown(e:MouseEvent):* {
			this.button_mc.addEventListener(MouseEvent.MOUSE_UP, this.topUp);
        }

        public function topUp(e:MouseEvent):* {
			trace("topUp", e.currentTarget);
            if (this.m_isOpen) {
                this.close();
            } else {
                this.open();
            }
            //this.button_mc.removeEventListener(MouseEvent.MOUSE_UP, this.topUp);
			this.button_mc.onUp();
			e.preventDefault();
        }

        public function topOver(e:MouseEvent):* {
			this.hovering = true;
            if (this.onOver != null) {
                this.onOver(e);
            }
            if (this.m_enabled && !this.m_isOpen) {
                Registry.ExtCall("PlaySound", this.SND_Over);
                this.button_mc.onHover();
            }
        }

        public function topOut(e:MouseEvent):* {
			this.hovering = false;
            if (this.onOut != null) {
                this.onOut(e);
            }
            if (this.m_enabled && !this.m_isOpen) {
                Registry.ExtCall("PlaySound", this.SND_Over);
                this.button_mc.onOut();
            }
        }

        public function elUp(e:MouseEvent):* {
            var target_mc:MovieClip = e.currentTarget as MovieClip;
            if (target_mc) {
                Registry.ExtCall("PlaySound", this.SND_Click);
                this.selectedIndex = target_mc.list_pos;
                if (this.pressedFunc != null) {
                    this.pressedFunc(this.selectedIndex);
                }
                this.close();
            }
        }

        public function elOver(e:MouseEvent):* {
            var target_mc:MovieClip = e.currentTarget as MovieClip;
            this.m_scrollList.select(target_mc.list_pos);
            Registry.ExtCall("PlaySound", this.SND_Over);
        }

        public function scrollListOut(e:MouseEvent):* {
        }

        public function onDeactivate(e:MouseEvent):* {
            if (e.target == null || e.target == this.stage || (!this.hovering && !this.contains(e.target as DisplayObject) 
			&& !this.m_selectContainer.contains(e.target as DisplayObject) 
			&& e.target != e.currentTarget)) {
                this.close();
				e.preventDefault();
            }
        }

        public function GetScrollRectY():Number {
            var yVal:Number = 0;
            var parent_obj:DisplayObject = this.parent;
            while (parent_obj) {
                if (parent_obj.scrollRect != null) {
                    yVal = yVal - parent_obj.scrollRect.y;
                }
                parent_obj = parent_obj.parent;
            }
            return yVal;
        }
    }
}
