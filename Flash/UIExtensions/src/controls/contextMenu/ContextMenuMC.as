package controls.contextMenu
{
	import LS_Classes.listDisplay;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.events.MouseEvent;
	import interfaces.IInputHandler;
	import interfaces.IContextMenuObject;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.system.Capabilities;
	
	public class ContextMenuMC extends BaseContextMenuObject implements IInputHandler, IContextMenuObject
	{
		public var bg_mc:ContextMenuBG;
		public var list:listDisplay;

		public var id:String;
		public var closing:Boolean;
		public var playSounds:Boolean = false;
		public const offsetX:Number = 0;
		public const offsetY:Number = 0;
		public var tweenTime:Number;
		public var text_array:Array;
		public var buttonArr:Array;
		
		public var minHeight:Number = 300;

		private var _side:String = "right";
		public function get side():String { return this._side; }
		public function set side(v:String):void 
		{ 
			this._side = v;
			var sub:IContextMenuObject = null;
			for (var i:uint = this.list.content_array.length; i--;)
			{
				sub = this.list.content_array[i];
				if(sub)
				{
					sub.side = v;
				}
			}
		}
		
		public function ContextMenuMC(ID:String="")
		{
			super();
			this.id = ID;
		}

		public function init() : void
		{
			this.list = new listDisplay();
			this.list.EL_SPACING = 0;
			this.list.m_cyclic = true;
			this.bg_mc.container_mc.addChild(this.list);
			this.bg_mc.container_mc.y = 15;
			this.bg_mc.title_txt.visible = this.bg_mc.firstLine_mc.visible = false;

			this.closing = false;
			this.isOpen = false;
			this.tweenTime = 0.3;
			this.text_array = new Array();
			this.buttonArr = new Array();

			this.addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOut, false, 1);
		}
		
		public function setTitle(text:String) : void
		{
			this.bg_mc.title_txt.htmlText = text;
		}
		
		public function addEntry(actionID:String, clickSound:Boolean, text:String, disabled:Boolean, legal:Boolean, handle:*=null, tooltip:String = "") : uint
		{
			var entry:ContextMenuEntry = this.list.getElementByString("actionID",actionID) as ContextMenuEntry;
			if(entry == null)
			{
				entry = new ContextMenuEntry(this);
				this.list.addElement(entry,false);
				entry.mouseChildren = false;
				entry.actionID = actionID;
				entry.arrow_mc.visible = false;
				entry.hl_mc.alpha = 0;
				entry.isButton = true;
				entry.text_txt.autoSize = TextFieldAutoSize.LEFT;
			}
			else
			{
				entry.setHierarchy(this, entry.childCM);
			}
			entry.handle = handle;
			entry.legal = legal;
			entry.setTooltip(tooltip);
			entry.text_txt.alpha = !!disabled?0.5:1;
			entry.arrow_mc.alpha = !!disabled?0.5:1;
			entry.clickSound = clickSound;
			if(!legal)
			{
				entry.text_txt.textColor = 10354688;
				entry.selectedColor = 10354688;
				entry.deSelectedColor = 10354688;
			}
			else
			{
				entry.text_txt.textColor = 12103073;
				entry.selectedColor = 16777215;
				entry.deSelectedColor = 12103073;
			}
			entry.text = text;
			entry.disabled = disabled;
			entry.text_txt.htmlText = text;
			entry.hl_mc.height = Math.floor(entry.text_txt.textHeight) + 2;
			return entry.list_pos;
		}
		
		public function updateDone() : void
		{
			this.list.positionElements();
			this.bg_mc.setHeight(Math.max(this.minHeight, this.bg_mc.container_mc.height),this.list);
			this.list.scrollRect = new Rectangle(0,0,this.bg_mc.width,this.bg_mc.height);
			this.bg_mc.bottom_mc.y = this.bg_mc.mid_mc.y + this.bg_mc.mid_mc.height - this.bg_mc.bottomOffset;
			this.list.alpha = 1;
			if (MainTimeline.Instance.controllerEnabled) {
				this.list.select(0);
			}
			//Registry.ExtCall("setMcSize",this.x + this.bg_mc.x + this.bg_mc.width,this.y + this.bg_mc.y + this.bg_mc.container_mc.y + this.bg_mc.container_mc.height + this.bg_mc.bottom_mc.height);
		}

		public function setListLoopable(b:Boolean) : void
		{
			this.list.m_cyclic = b;
		}

		// Stuff that used to be in MainTimeline
		public function next() : void
		{
			if(this.playSounds) Registry.ExtCall("PlaySound","UI_Gen_CursorMove");
			this.list.next();
			this.setListLoopable(false);
		}
		
		public function previous() : void
		{
			if(this.playSounds) Registry.ExtCall("PlaySound","UI_Gen_CursorMove");
			this.list.previous();
			this.setListLoopable(false);
		}

		public function OnDestroying() : void
		{
			MainTimeline.Instance.removeInputHandler(this);
		}

		public function get IsInputEnabled():Boolean
		{
			return this.visible;
		}

		public function OnInputUp(input:String) : Boolean
		{
			var currentMC:MovieClip = null;
			var isHandled:Boolean = false;
			if(!this.visible)
			{
				return isHandled;
			}
			switch(input)
			{
				case "IE UIAccept":
					currentMC = this.list.getCurrentMovieClip();
					if(currentMC)
					{
						currentMC.pressedButton();
					}
					isHandled = true;
					break;
				case "IE UIUp":
					if (!MainTimeline.Instance.controllerEnabled) {
						this.previous();
						isHandled = true;
					} else {
						this.setListLoopable(true);
					}
					break;
				case "IE UIDown":
					if (!MainTimeline.Instance.controllerEnabled) {
						this.next();
						isHandled = true;
					} else {
						this.setListLoopable(true);
					}
					break;
				case "IE UILeft":
					Registry.ExtCall("LeaderLib_ContextMenu_PreviousContext");
					isHandled = true;
					break;
				case "IE UIRight":
					Registry.ExtCall("LeaderLib_ContextMenu_NextContext");
					isHandled = true;
					break;
				case "IE UIBack":
				case "IE UICancel":
					this.close();
					isHandled = true;
					break;
			}
			return isHandled;
		}

		public function OnInputDown(input:String) : Boolean
		{
			var isHandled:Boolean = false;
			if(!this.visible)
			{
				return isHandled;
			}
			if (MainTimeline.Instance.controllerEnabled) {
				switch(input)
				{
					case "IE UIUp":
						this.previous();
						isHandled = true;
						break;
					case "IE UIDown":
						this.next();
						isHandled = true;
						break;
					case "IE UIAccept":
					case "IE UIBack":
					case "IE UICancel":
						isHandled = true;
				}
			}
			else
			{
				switch(input)
				{
					case "IE FlashLeftMouse":
					case "IE FlashRightMouse":
						if(!this.list.isOverlappingPosition(MainTimeline.Instance.mouseX, MainTimeline.Instance.mouseY)) {
							return true;
						}
						break;
				}
			}
			return isHandled;
		}

		public function get totalWidth():Number
		{
			var w:Number = this.width;
			var c:MovieClip = this.childCM as MovieClip;
			while (c != null)
			{
				w += c.width;
				c = c.childCM as MovieClip;
			}
			return w;
		}

		public function get totalHeight():Number
		{
			var h:Number = this.height;
			var c:MovieClip = this.childCM as MovieClip;
			while (c != null)
			{
				h += c.height;
				c = c.childCM as MovieClip;
			}
			return h;
		}

		public function open(targetX:Number=0, targetY:Number=0) : void
		{
			this.x = targetX;

			if(this.isChild && !this.visible)
			{
				var parent_mc:MovieClip = (this.parentCM as MovieClip);
				var parentWidth:Number = parent_mc.width - 10;
				var nextX:Number = this.x + parent_mc.x + parentWidth;

				var nextSide:String = this.parentCM.side;
				var totalW:Number = this.width;
				var totalH:Number = this.height;

				var c:MovieClip = this.childCM as MovieClip;
				while (c != null)
				{
					totalH += c.height;
					totalW += c.width;
					c = c.childCM as MovieClip;
				}

				var globalPos:Point = parent_mc.localToGlobal(new Point(parent_mc.x + parentWidth + totalW + 20, parent_mc.y + totalH));

				if(this.depth == 1)
				{
					if (globalPos.x > MainTimeline.Instance.stage.stageWidth)
					{
						nextSide = "left";
					}
					if (globalPos.y > MainTimeline.Instance.stage.stageHeight)
					{
						//Offset the position so the bottom entry lines up with the parent menu
						targetY = (targetY - totalH) + (ContextMenuEntry.EntryHeight*2);
					}
				}

				if (nextSide == "left")
				{
					nextX = (this.x - this.width) + 20;
				}

				if(this.side != nextSide)
				{
					this.side = nextSide;

					if(this.parentCM.side != nextSide)
					{
						this.parentCM.side = nextSide;
					}
				}

				MainTimeline.Instance.contextMenuMC.setActiveSubmenu(this);
				this.x = nextX;
				//var index:int = MainTimeline.Instance.getChildIndex(MainTimeline.Instance.contextMenuMC);
				//MainTimeline.Instance.addChildAt(this, index-1);
				MainTimeline.Instance.contextMenuMC.children_mc.addChild(this);

				//Registry.Log("[%s] open(%s, %s) side(%s) x(%s) y(%s) edgeRight(%s) stageWidth(%s)", this, targetX, targetY, this.side, this.x, this.y, globalPos.x, MainTimeline.Instance.stage.stageWidth);
			}
			else
			{
				if((this.x + this.width + 20) > MainTimeline.Instance.stage.stageWidth)
				{
					this.x = MainTimeline.Instance.stage.stageWidth - this.width - 20
				}

				if((targetY + this.height + 20) > MainTimeline.Instance.stage.stageHeight)
				{
					targetY = MainTimeline.Instance.stage.stageHeight - this.height - 20
				}
			}

			this.y = targetY;
			
			if(this.playSounds) Registry.ExtCall("PlaySound","UI_GM_Generic_Slide_Open");
			this.visible = true;

			if(!this.isOpen)
			{
				MainTimeline.Instance.addInputHandler(this);
				//MainTimeline.Instance.stage.addEventListener("rightMouseDown",this.onCloseUI);
				MainTimeline.Instance.stage.addEventListener(MouseEvent.CLICK, this.onCloseUI);
				this.isOpen = true;
			}
			Registry.ExtCall("LeaderLib_ContextMenu_Opened", this.id);
		}

		public function close(force:Boolean = false) : void
		{
			if(this.isChild && this.parentCM)
			{
				if(this.visible)
				{
					try {
						MainTimeline.Instance.contextMenuMC.children_mc.removeChild(this);
					} catch (error:Error) {
						if (Capabilities.isDebugger) {
							trace(error.getStackTrace());
						} else {
							trace("MainTimeline.Instance.contextMenuMC.children_mc.removeChild error");
						}
					}
				}
			}
			if(this.visible)
			{
				this.visible = false;
				if(this.playSounds && !isParentOpen)
				{
					Registry.ExtCall("PlaySound","UI_GM_Generic_Slide_Close");
				}
			}
			if(this.isOpen)
			{
				MainTimeline.Instance.removeInputHandler(this);
				//MainTimeline.Instance.stage.removeEventListener("rightMouseDown",this.onCloseUI);
				MainTimeline.Instance.stage.removeEventListener(MouseEvent.CLICK, this.onCloseUI);
				this.isOpen = false;
			}
			if(this.childCM)
			{
				this.childCM.close(force);
			}
			if(this.parentCM)
			{
				this.parentCM.close(force);
			}
			Registry.ExtCall("LeaderLib_ContextMenu_Closed", this.id);
			//Registry.Log("[%s] close(%s) visible(%s) isOpen(%s)", this, force, this.visible, this.isOpen);
		}

		public function onCloseUI(e:MouseEvent) : void
		{
			if((this.isChild && !this.isParentOpen) || (!e.target.isButton && !e.target.stayOpen))
			{
				this.close();
			}
		}

		public function clearButtons() : void
		{
			this.list.clearElements();
		}
		
		public function selectButton(button:ContextMenuEntry, force:Boolean=false) : void
		{
			if(button == null)
			{
				this.list.clearSelection();
			}
			else
			{
				this.list.selectMC(button, force);
			}
		}

		public function updateButtons() : void
		{
			var id:Number = NaN;
			var actionID:String = "";
			var clickSound:Boolean = false;
			var unused:String = null;
			var text:String = null;
			var disabled:Boolean = false;
			var legal:Boolean = false;
			this.list.clearElements();
			var index:uint = 0;
			while(index < this.buttonArr.length)
			{
				if(this.buttonArr[index] != undefined)
				{
					id = Number(this.buttonArr[index]);
					actionID = String(this.buttonArr[index + 1]);
					clickSound = Boolean(this.buttonArr[index + 2]);
					unused = String(this.buttonArr[index + 3]);
					text = String(this.buttonArr[index + 4]);
					disabled = Boolean(this.buttonArr[index + 5]);
					legal = Boolean(this.buttonArr[index + 6]);
					this.addEntry(actionID,clickSound,text,disabled,legal);
				}
				index = index + 7;
			}
			this.updateDone();
			this.buttonArr = new Array();
		}

		public function onMouseOut(e:MouseEvent) : void
		{
			if(this.isChild && !this.isMouseHovering)
			{
				//Registry.Log("[ContextMenuMC(child).onMouseOut] id(%s)", this.id);
				this.close();
			}
		}

		override public function toString():String
		{
			return "ContextMenu(" + this.id + ")";
		}
	}
}