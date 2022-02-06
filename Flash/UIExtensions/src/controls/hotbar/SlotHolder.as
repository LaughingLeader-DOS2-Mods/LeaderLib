package controls.hotbar
{
	import LS_Classes.larTween;
	import LS_Classes.textEffect;
	import fl.motion.easing.Cubic;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import LS_Classes.tooltipHelper;
	
	public class SlotHolder extends MovieClip
	{
		public var activeSkill_mc:MovieClip;
		public var iggy_slots:MovieClip;
		public var sel_mc:MovieClip;
		public var slotContainer_mc:MovieClip;
		public var slot_array:Array;
		public var tooltipSlot:Number;
		public var hasTooltip:Boolean;
		public var currentHLSlot:Number;
		public var activeSkillBarNr:Number;
		public var activeSkillSlotNr:Number;
		public var cellWidth:Number;
		public var cellHeight:Number;
		public var cellSpacing:Number;
		public var timeline:larTween;
		public var startDragDiff:Number;
		public var tutDragDiff:Number;
		public var startDragX:Number;
		public var startDragY:Number;
		public var downSlot:Number;
		
		public function SlotHolder()
		{
			super();

			this.slot_array = new Array();

			this.tooltipSlot = -1;
			this.hasTooltip = false;
			this.currentHLSlot = -1;
			this.activeSkillBarNr = -1;
			this.activeSkillSlotNr = -1;
			this.cellWidth = 50;
			this.cellHeight = 50;
			this.cellSpacing = 8;
			this.sel_mc.mouseEnabled = false;
			this.sel_mc.mouseChildren = false;
			this.startDragDiff = 10;
			this.tutDragDiff = 50;
			this.startDragX = 0;
			this.startDragY = 0;
			this.downSlot = -1;
			addFrameScript(0,this.frame1);
		}

		private var _hotbar:Hotbar;
		public function get hotbar():Hotbar
		{
			if(!_hotbar) {
				_hotbar = parent as Hotbar;
			}
			return _hotbar;
		}
		
		public function onCheckSlotsOver(e:MouseEvent) : void
		{
			var slot_mc:Slot = null;
			var slotIndex:Number = this.getSlotOnXY(mouseX,mouseY);
			if(this.currentHLSlot != slotIndex)
			{
				this.clearCurrentHL();
				this.currentHLSlot = slotIndex;
				slot_mc = this.getSlot(this.currentHLSlot);
				if(slot_mc)
				{
					slot_mc.onMouseOver();
					this.showSlotMCTooltip(slot_mc);
					if(slot_mc.isEnabled && slot_mc.inUse || MainTimeline.Instance.isDragging)
					{
						this.sel_mc.hl_mc.alpha = 0;
						this.sel_mc.hl_mc.x = slot_mc.x;
						this.sel_mc.hl_mc.visible = true;
						if(this.timeline)
						{
							this.timeline.stop();
						}
						this.timeline = new larTween(this.sel_mc.hl_mc,"alpha",Cubic.easeOut,NaN,0.3,0.2);
					}
				}
			}
		}
		
		public function startDragging(e:MouseEvent) : void
		{
			if(!this.hotbar.lockButton_mc.bIsLocked)
			{
				if(this.startDragX + this.startDragDiff < stage.mouseX || this.startDragY + this.startDragDiff < stage.mouseY || this.startDragX - this.startDragDiff > stage.mouseX || this.startDragY - this.startDragDiff > stage.mouseY)
				{
					stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.startDragging);
					Registry.ExtCall("startDragging",this.downSlot);
					this.downSlot = -1;
				}
			}
			else if(this.startDragX + this.tutDragDiff < stage.mouseX || this.startDragY + this.tutDragDiff < stage.mouseY || this.startDragX - this.tutDragDiff > stage.mouseX || this.startDragY - this.tutDragDiff > stage.mouseY)
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.startDragging);
				Registry.ExtCall("showLockTut");
			}
		}
		
		public function onSlotsOver(e:MouseEvent) : void
		{
			addEventListener(MouseEvent.ROLL_OUT,this.onSlotsOut);
			addEventListener(MouseEvent.MOUSE_DOWN,this.onSlotsDown);
			addEventListener(MouseEvent.MOUSE_MOVE,this.onCheckSlotsOver);
			addEventListener(MouseEvent.MOUSE_UP,this.onSlotsUp);
		}
		
		public function onSlotsOut(e:MouseEvent) : void
		{
			this.clearCurrentHL();
			this.clearSlotTooltip();
			this.currentHLSlot = -1;
			removeEventListener(MouseEvent.ROLL_OUT,this.onSlotsOut);
			removeEventListener(MouseEvent.MOUSE_DOWN,this.onSlotsDown);
			removeEventListener(MouseEvent.MOUSE_MOVE,this.onCheckSlotsOver);
			removeEventListener(MouseEvent.MOUSE_UP,this.onSlotsUp);
		}
		
		public function onSlotsDown(e:MouseEvent) : void
		{
			Registry.ExtCall("inputFocus");
			var slot_mc:Slot = this.getSlot(this.currentHLSlot);
			if(!MainTimeline.Instance.isDragging && slot_mc && slot_mc.inUse)
			{
				this.downSlot = this.currentHLSlot;
				this.startDragX = stage.mouseX;
				this.startDragY = stage.mouseY;
				stage.addEventListener(MouseEvent.MOUSE_MOVE,this.startDragging);
			}
		}
		
		public function onSlotsUp(e:MouseEvent) : void
		{
			var slot_mc:Slot = null;
			Registry.ExtCall("inputFocusLost");
			if(MainTimeline.Instance.isDragging)
			{
				if(this.currentHLSlot >= 0 && (!this.hotbar.lockButton_mc.bIsLocked || this.hotbar.lockButton_mc.bIsLocked && !this.slot_array[this.currentHLSlot].inUse))
				{
					Registry.ExtCall("stopDragging",this.currentHLSlot);
				}
				else
				{
					Registry.ExtCall("cancelDragging");
				}
			}
			if(this.currentHLSlot == this.downSlot)
			{
				this.downSlot = -1;
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.startDragging);
				slot_mc = this.getSlot(this.currentHLSlot);
				if(slot_mc && slot_mc.inUse)
				{
					slot_mc.onClick(null);
				}
			}
			Registry.ExtCall("slotUpEnd");
		}

		public function setSourceVisible(index:int, isVisible:Boolean) : void
		{
			var source_mc:MovieClip = this.hotbar.sourceList.getAt(index);
			if(source_mc)
			{
				source_mc.visible = isVisible;
			}
		}
		
		public function updateSlots(slotArr:Array) : void
		{
			var slotNum:Number = NaN;
			var amount:Number = NaN;
			var tooltip:String = null;
			var isEnabled:Boolean = false;
			var handle:Number = NaN;
			var slotType:Number = NaN;
			var sourceVisible:Boolean = false;
			var source_mc:MovieClip = null;
			var slotsChanged:Array = new Array();
			var i:uint = 0;
			while(i < slotArr.length)
			{
				if(slotArr[i] != undefined)
				{
					slotNum = Number(slotArr[i++]);
					amount = Number(slotArr[i++]);
					tooltip = String(slotArr[i++]);
					isEnabled = Boolean(slotArr[i++]);
					handle = Number(slotArr[i++]);
					slotType = Number(slotArr[i++]);
					sourceVisible = Boolean(slotArr[i++]);
					//slotNum:Number, tooltip:String, isEnabled:Boolean, handle:Number, slotType:Number, amount:Number
					this.setSlot(slotNum,tooltip,isEnabled,handle,slotType,amount);
					this.setSourceVisible(slotNum, sourceVisible);
					slotsChanged.push(slotNum);
				}
			}
			this.updateClearOldSlots();
		}
		
		public function updateSlotData(slotUpdateDataList:Array) : void
		{
			var slotIndex:Number = NaN;
			var slot_mc:Slot = null;
			var isEnabled:Boolean = false;
			var i:uint = 0;
			while(i < slotUpdateDataList.length)
			{
				if(slotUpdateDataList[i] != undefined)
				{
					slotIndex = Number(slotUpdateDataList[i]);
					slot_mc = this.getSlot(slotIndex);
					isEnabled = Boolean(slotUpdateDataList[i + 2]);
					if(slot_mc)
					{
						switch(Number(slotUpdateDataList[i + 1]))
						{
							case 0:
								slot_mc.isEnabled = isEnabled;
								slot_mc.disable_mc.visible = !slot_mc.isEnabled;
								break;
							case 1:
								this.setSlotPreviewEnabledMC(slot_mc,isEnabled);
								break;
							case 2:
								this.setSlotCoolDownMC(slot_mc,Number(slotUpdateDataList[i + 2]));
								break;
							case 3:
								this.setSlotAmountMC(slot_mc,Number(slotUpdateDataList[i + 2]));
						}
					}
				}
				i = i + 3;
			}
		}
		
		public function setSlotPreviewEnabledMC(slot_mc:Slot, isEnabled:Boolean) : void
		{
			if(slot_mc != null)
			{
				slot_mc.unavailable_mc.visible = !isEnabled;
			}
		}
		
		public function setSlotPreviewEnabled(index:Number, isEnabled:Boolean) : void
		{
			var slot_mc:Slot = this.getSlot(index);
			if(slot_mc != null)
			{
				this.setSlotPreviewEnabledMC(slot_mc,isEnabled);
			}
		}
		
		public function setAllSlotsPreviewEnabled(isEnabled:Boolean) : void
		{
			var slot_mc:Slot = null;
			var i:uint = 0;
			while(i < this.slot_array.length)
			{
				slot_mc = this.slot_array[i];
				if(slot_mc != null)
				{
					slot_mc.unavailable_mc.visible = !isEnabled;
				}
				i++;
			}
		}
		
		public function setSlotCoolDownMC(slot_mc:Slot, cd:Number) : void
		{
			if(slot_mc != null)
			{
				slot_mc.setCoolDown(cd);
			}
		}
		
		public function setSlotCoolDown(index:Number, cd:Number) : void
		{
			var slot_mc:Slot = this.getSlot(index);
			if(slot_mc != null)
			{
				this.setSlotCoolDownMC(slot_mc,cd);
			}
		}

		public function setSlotImage(index:Number, name:String) : void
		{
			var slot_mc:Slot = this.getSlot(index);
			if(slot_mc != null)
			{
				//TODO See which mc needs to be renamed for custom draw calls.
				slot_mc.name = name;
			}
		}
		
		public function showActiveSkill(index:Number) : void
		{
			var slot_mc:Slot = this.getSlot(index);
			if(slot_mc)
			{
				this.activeSkill_mc.x = slot_mc.x + 25;
				this.activeSkill_mc.visible = true;
				this.activeSkill_mc.play();
				this.activeSkillBarNr = MainTimeline.Instance.hotbars_mc.activeBar;
				this.activeSkillSlotNr = index;
			}
			else
			{
				this.activeSkill_mc.visible = false;
				this.activeSkill_mc.stop();
				this.activeSkillBarNr = -1;
				this.activeSkillSlotNr = -1;
			}
		}
		
		public function setAllSlotsEnabled(isEnabled:Boolean) : void
		{
			var slot_mc:Slot = null;
			var i:uint = 0;
			while(i < this.slot_array.length)
			{
				slot_mc = this.slot_array[i];
				if(slot_mc != null)
				{
					slot_mc.isEnabled = isEnabled;
					slot_mc.disable_mc.visible = !isEnabled;
				}
				i++;
			}
		}
		
		public function setSlotEnabled(index:Number, isEnabled:Boolean) : void
		{
			var slot_mc:Slot = this.getSlot(index);
			if(slot_mc != null)
			{
				slot_mc.isEnabled = isEnabled;
				slot_mc.disable_mc.visible = !isEnabled;
			}
		}
		
		public function clearCurrentHL() : void
		{
			var slot_mc:Slot = null;
			if(this.currentHLSlot != -1)
			{
				slot_mc = this.getSlot(this.currentHLSlot);
				if(slot_mc)
				{
					slot_mc.onMouseOut();
					this.timeline = new larTween(this.sel_mc.hl_mc,"alpha",Cubic.easeOut,NaN,0,0.1,this.hideHL);
				}
			}
		}
		
		public function hideHL() : void
		{
			this.sel_mc.hl_mc.visible = false;
		}
		
		public function clearAll() : void
		{
			var val1:uint = 0;
			while(val1 < this.slot_array.length)
			{
				this.clearSlotMC(this.slot_array[val1]);
				val1++;
			}
		}
		
		public function initSlots() : void
		{
			var slot_mc:Slot = null;
			var amountFilters:Array = textEffect.createStrokeFilter(1050888,1.4,1,1.8,3);
			var count:int = hotbar.maxSlots;
			for(var i:int = 0; i < count; i++)
			{
				slot_mc = new Slot();
				slot_mc.oldCD = 0;
				slot_mc.refreshSlot_mc.visible = false;
				slot_mc.refreshSlot_mc.stop();
				slot_mc.name = "slot" + i;
				slot_mc.slotHolder = this;
				slot_mc.id = i;
				slot_mc.x = i * (this.cellWidth + this.cellSpacing);
				slot_mc.y = 0;
				slot_mc.inUse = false;
				slot_mc.isEnabled = false;
				slot_mc.amount_mc.visible = false;
				slot_mc.disable_mc.visible = false;
				slot_mc.unavailable_mc.visible = false;
				slot_mc.cd_mc.rot = -90;
				slot_mc.cd_mc.cellSize = 50;
				slot_mc.cd_mc.visible = false;
				slot_mc.setIcon();
				this.slot_array.push(slot_mc);
				this.slotContainer_mc.addChild(slot_mc);
				slot_mc.amount_mc.filters = amountFilters;
			}
			this.activeSkill_mc.visible = false;
		}
		
		public function updateClearOldSlots() : void
		{
			var i:uint = 0;
			while(i < this.slot_array.length)
			{
				if(this.slot_array[i].isUpdated)
				{
					this.slot_array[i].isUpdated = false;
				}
				else
				{
					this.clearSlotMC(this.slot_array[i]);
					this.setSourceVisible(i, false);
				}
				i++;
			}
		}
		
		public function setSlot(slotNum:Number, tooltip:String, isEnabled:Boolean, handle:Number, slotType:Number, amount:Number = -1, iconName:String = "") : void
		{
			var slot_mc:Slot = this.getSlot(slotNum);
			if(slot_mc)
			{
				slot_mc.inUse = true;
				slot_mc.tooltip = tooltip;
				slot_mc.isEnabled = isEnabled;
				slot_mc.disable_mc.visible = !isEnabled;
				slot_mc.isUpdated = true;
				slot_mc.type = slotType;
				slot_mc.handle = handle;
				slot_mc.setIcon(iconName);
				if(this.tooltipSlot == slotNum)
				{
					this.showSlotMCTooltip(slot_mc);
				}
				if(slot_mc.oldCD != 0)
				{
					slot_mc.oldCD = 0;
					slot_mc.setCoolDown(0);
				}
				this.setSlotAmountMC(slot_mc,amount);
			}
		}
		
		public function getSlot(index:Number) : Slot
		{
			if(index >= 0 && index < this.slot_array.length)
			{
				return this.slot_array[index];
			}
			return null;
		}
		
		public function getSlotOnXY(xPos:Number, yPos:Number) : Number
		{
			var val3:int = int(xPos / (this.cellWidth + this.cellSpacing));
			if(xPos > (this.cellWidth + this.cellSpacing) * val3 + this.cellWidth)
			{
				val3 = -1;
			}
			return val3;
		}
		
		public function showSlotMCTooltip(mc:Slot) : void
		{
			if(mc)
			{
				if(mc.type == 1 || mc.type == 4)
				{
					tooltipHelper.ShowSkillTooltipForMC(mc, this.hotbar, mc.handle, mc.tooltip, "top");
					//Registry.ExtCall("showSkillTooltip",mc.handle, mc.tooltip, globalPos.x, globalPos.y, mc.width, mc.height);
					this.hasTooltip = true;
					this.tooltipSlot = this.currentHLSlot;
				}
				else if(mc.type == 2)
				{
					//var globalPos:Point = tooltipHelper.getGlobalPositionOfMC(mc, this.hotbar);
					//tooltipHelper.ShowItemTooltipForMC(mc, this.hotbar, mc.handle, "top");
					tooltipHelper.ShowTooltipForMC(mc, this.hotbar, "top", MainTimeline.Instance.hasTooltip == true);
					//Registry.ExtCall("showItemTooltip",mc.handle,globalPos.x,globalPos.y,mc.width,mc.height,-1,"none");
					//Registry.ExtCall("LeaderLib_Hotbar_ShowItemTooltip", mc.handle, globalPos.x, globalPos.y, mc.width, mc.height, -1, "none");
					MainTimeline.Instance.setHasTooltip(true, mc.name);
					this.hasTooltip = true;
					this.tooltipSlot = this.currentHLSlot;
				}
				else if(mc.tooltip != null && mc.tooltip != "")
				{
					tooltipHelper.ShowTooltipForMC(mc, this.hotbar, "top", MainTimeline.Instance.hasTooltip == true);
					this.hasTooltip = true;
					this.tooltipSlot = this.currentHLSlot;
				}
				else
				{
					this.clearSlotTooltip();
				}
			}
		}
		
		public function clearSlotTooltip() : void
		{
			if(this.hasTooltip)
			{
				Registry.ExtCall("hideTooltip");
				this.hasTooltip = false;
				this.tooltipSlot = -1;
				MainTimeline.Instance.setHasTooltip(false);
			}
		}
		
		public function clearSlotMC(mc:Slot) : void
		{
			if(mc != null)
			{
				if(this.tooltipSlot == mc.id)
				{
					this.clearSlotTooltip();
				}
				mc.refreshSlot_mc.visible = false;
				mc.refreshSlot_mc.stop();
				mc.inUse = false;
				mc.tooltip = "";
				mc.amount_mc.amount_txt.htmlText = "";
				mc.amount_mc.visible = false;
				mc.amount = 0;
				mc.isEnabled = false;
				mc.setIcon("");
				if(mc.oldCD != 0)
				{
					mc.oldCD = 0;
					mc.setCoolDown(0);
				}
				mc.cd_mc.visible = false;
				mc.unavailable_mc.visible = false;
				mc.disable_mc.visible = false;
				mc.disable_mc.alpha = 1;
				mc.type = 0;
				mc.handle = 0;
				if(this.activeSkillBarNr == MainTimeline.Instance.hotbars_mc.activeBar && this.activeSkillSlotNr == mc.id)
				{
					this.showActiveSkill(-1);
				}
			}
		}
		
		public function setSlotAmount(index:Number, amount:Number) : void
		{
			var slot_mc:Slot = this.getSlot(index);
			if(slot_mc != null)
			{
				this.setSlotAmountMC(slot_mc,amount);
			}
		}
		
		public function setSlotAmountMC(mc:Slot, amount:Number) : void
		{
			if(mc != null)
			{
				mc.amount = amount;
				if(amount <= 1)
				{
					mc.amount_mc.amount_txt.htmlText = "";
					mc.amount_mc.visible = false;
				}
				else
				{
					mc.amount_mc.amount_txt.htmlText = amount;
					mc.amount_mc.visible = true;
				}
			}
		}

		public function setSlotIcon(index:Number, icon:String="") : void
		{
			var slot_mc:Slot = this.getSlot(index);
			if(slot_mc != null)
			{
				slot_mc.setIcon(icon);
			}
		}
		
		public function frame1() : void
		{
			addEventListener(MouseEvent.ROLL_OVER,this.onSlotsOver);
		}
	}
}
