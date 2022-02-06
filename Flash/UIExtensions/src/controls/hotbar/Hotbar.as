package controls.hotbar
{
	import LS_Classes.tooltipHelper;
	import LS_Classes.textEffect;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.geom.Rectangle;
	import LS_Classes.horizontalList;
	import flash.geom.Point;
	import flash.display.DisplayObject;
	import interfaces.IInputHandler;
	import controls.BaseDraggableObject;

	public class Hotbar extends BaseDraggableObject implements IInputHandler
	{
		public var id:int;
		public var maxSlots:int = 29;
		public var cToAlpha:Number = 0.65;

		public var lockButton_mc:LockButton;
		public var basebar_mc:MovieClip;
		public var cycleHotBar_mc:CycleButtonsContainer;
		public var slotholder_mc:SlotHolder;
		public var hotkeys_mc:SkillSlotNumbers;
		public var sourceHolder_mc:MovieClip;

		public var sourceList:horizontalList;

		public var isSkillBarShown:Boolean;
		private var _hotkeysEnabled:Boolean = false;
		public var visualElements:Array;

		public function get hotkeysEnabled() : Boolean
		{
			return this._hotkeysEnabled;
		}

		public function set hotkeysEnabled(b:Boolean) : void
		{
			this._hotkeysEnabled = b;
			this.hotkeys_mc.visible = b;
		}

		public function get currentHotBarIndex():uint
		{
			return this.cycleHotBar_mc.currentHotBarIndex;
		}

		public override function get canDrag():Boolean
		{
			if(this.lockButton_mc.bIsLocked == true)
			{
				return false;
			}
			return true;
		}

		public function Hotbar()
		{
			super();

			this.addFrameScript(0,this.frame1);
		}

		public function onInit() : void
		{
			var indicator:MovieClip = null;
			// this.basebar_mc.mouseEnabled = false;
			// this.basebar_mc.mouseChildren = false;
			this.hotkeys_mc.mouseEnabled = false;
			this.hotkeys_mc.mouseChildren = false;
			this.sourceHolder_mc.mouseEnabled = false;
			this.sourceHolder_mc.mouseChildren = false;
			this.hotkeys_mc.filters = textEffect.createStrokeFilter(0,1.2,0.8,1,3);
			this.slotholder_mc.initSlots();
			this.lockButton_mc.onInit();
			this.lockButton_mc.setLocked(true);
			this.sourceList = new horizontalList();
			this.sourceList.EL_SPACING = 0;
			this.sourceHolder_mc.addChild(this.sourceList);
			this.sourceList.canPositionInvisibleElements = true;
			var i:uint = 0;
			while(i < this.maxSlots)
			{
				indicator = new SourceIndicator();
				indicator.visible = false;
				this.sourceList.addElement(indicator,false);
				i++;
			}
			this.sourceList.positionElements();
			this.cycleHotBar_mc.onInit();
			//this.lockButton_mc.toAlpha = this.cToAlpha;
			MainTimeline.Instance.addInputHandler(this);
			this.hotkeysEnabled = false;
		}

		public function showSkillBar(b:Boolean) : void
		{
			this.isSkillBarShown = b;
			var mc:MovieClip = null;
			for each(mc in this.visualElements)
			{
				mc.visible = b;
			}
		}
		
		public function setAllText(targetArray:Array) : void
		{
			var i:uint = 0;
			var length:Number = this.hotkeys_mc.textArray.length;
			if(targetArray.length <= length)
			{
				while(i < length)
				{
					this.hotkeys_mc.setText(i,targetArray[i]);
					i++;
				}
			}
			else
			{
				Registry.ExtCall("UIAssert","text array is bigger then the number of textfields.");
			}
		}
		
		public function showBtnTooltip(mc:MovieClip, tooltip:String = "") : void
		{
			var pos:Point = new Point(0,0);
			pos = mc.localToGlobal(pos);
			if(tooltip == "" && mc.tooltip != null)
			{
				tooltip = mc.tooltip;
			}
			if(tooltip != "")
			{
				MainTimeline.Instance.setHasTooltip(true, tooltip);
				Registry.ExtCall("showTooltip",tooltip,pos.x - root.x,pos.y - root.y,mc.width,mc.height,"top");
			}
		}
		
		public function setSlotAmount(index:Number, amount:Number) : void
		{
			this.slotholder_mc.setSlotAmount(index,amount);
		}
		
		public function setSlotPreviewEnabled(index:Number, isEnabled:Boolean) : void
		{
			this.slotholder_mc.setSlotPreviewEnabled(index,isEnabled);
		}
		
		public function setAllSlotsPreviewEnabled(isEnabled:Boolean) : void
		{
			this.slotholder_mc.setAllSlotsPreviewEnabled(isEnabled);
		}
		
		public function setSlotEnabled(index:Number, isEnabled:Boolean) : void
		{
			this.slotholder_mc.setSlotEnabled(index,isEnabled);
		}
		
		public function setAllSlotsEnabled(isEnabled:Boolean) : void
		{
			this.slotholder_mc.setAllSlotsEnabled(isEnabled);
			this.setAllSlotsPreviewEnabled(true);
		}
		
		public function setSlotImage(index:Number, name:String) : void
		{
			this.slotholder_mc.setSlotImage(index,name);
		}
		
		public function setSlot(slotNum:Number, tooltip:String, isEnabled:Boolean, handle:Number, slotType:Number, amount:Number) : void
		{
			this.slotholder_mc.setSlot(slotNum,tooltip,isEnabled,handle,slotType,amount);
		}
		
		public function setSlotCoolDown(index:Number, cd:Number) : void
		{
			this.slotholder_mc.setSlotCoolDown(index,cd);
		}
		
		public function getGlobalPositionOfMC(mc:MovieClip) : Point
		{
			var pos:Point = new Point(mc.x,mc.y);
			var mcParent:DisplayObject = mc.parent;
			while(mcParent && (mcParent != root || mcParent != stage))
			{
				pos.x = pos.x + mcParent.x;
				pos.y = pos.y + mcParent.y;
				mcParent = mcParent.parent;
			}
			return pos;
		}

		public function startsWith(checkVal:String, compareVal:String) : Boolean
		{
			checkVal = checkVal.toLowerCase();
			compareVal = compareVal.toLowerCase();
			return compareVal == checkVal.substr(0,compareVal.length);
		}

		public function OnDestroying() : void
		{
			MainTimeline.Instance.removeInputHandler(this);
		}

		public function get IsInputEnabled():Boolean
		{
			return this.visible && this.isSkillBarShown && this.hotkeysEnabled;
		}

		public function OnInputDown(id:String) : Boolean
		{
			var slot_mc:MovieClip = null;
			var isHandled:Boolean = false;
			var slotStr:String = "";
			var slotNum:Number = -1;

			if(this.isSkillBarShown)
			{
				if(this.startsWith(id,"IE UISelectSlot") && !MainTimeline.Instance.isDragging)
				{
					slotStr = id.substr(15,id.length - 15);
					if(slotStr != "" && slotStr != null)
					{
						slotNum = Number(slotStr) - 1;
						if(slotNum == -1)
						{
							slotNum = 9;
						}
						slot_mc = this.slotholder_mc.getSlot(slotNum);
						if(slot_mc)
						{
							slot_mc.onClick(null);
							isHandled = true;
						}
					}
				}
				else if(id == "IE UIHotBarPrev" && !MainTimeline.Instance.isDragging)
				{
					this.cycleHotBar_mc.cycleHotBar(true);
					isHandled = true;
				}
				else if(id == "IE UIHotBarNext" && !MainTimeline.Instance.isDragging)
				{
					this.cycleHotBar_mc.cycleHotBar(false);
					isHandled = true;
				}
			}
			return isHandled;
		}

		public function OnInputUp(id:String) : Boolean
		{
			return false;
		}

		public function frame1() : void
		{
			this.isSkillBarShown = true;
			this.visualElements = new Array(this.hotkeys_mc,this.lockButton_mc,this.basebar_mc,this.slotholder_mc,this.sourceHolder_mc,this.cycleHotBar_mc);
			this.initializeDrag(this.basebar_mc);
		}
	}
}