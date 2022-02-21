package controls.contextMenu
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import interfaces.IContextMenuObject;
	import flash.text.TextField;
	import LS_Classes.listDisplay;
	import flash.geom.Point;
	import flash.events.Event;
	import LS_Symbols.IggyIcon;
	
	public class ContextMenuEntry extends BaseContextMenuObject implements IContextMenuObject
	{
		public var arrow_mc:MovieClip;
		public var hl_mc:MovieClip;
		public var text_txt:TextField;
		public var iggy_mc:IggyIcon;

		public var selectedColor:uint;
		public var deSelectedColor:uint;
		public var clickSound:Boolean = true;
		public var disabled:Boolean = false;
		public var legal:Boolean = true;
		public var stayOpen:Boolean = false;
		public var text:String;

		public var isButton:Boolean = true;
		public var actionID:String;
		public var handle:*;

		//listDisplay assigned variables
		public var list_pos:uint;
		public var list_id:uint;
		public var selectable:Boolean;
		public var m_filteredObject:Boolean;
		public var ownerList:listDisplay;
		public var tweenToY:Number;

		public var isActive:Boolean = false;
		public var openOnHover:Boolean = true;

		public var tooltip:String;
		public var tooltipSide:String = "top";
		public var tooltipEnabled:Boolean = false;
		public var tooltipYOffset:Number = -10;
		public var tooltipOverrideW:Number = 0;

		private var _side:String = "right";
		public function get side():String { return this._side; }
		public function set side(v:String):void
		{
			this._side = v;
			if(this._side == "left")
			{
				this.arrow_mc.rotation = -180;
			}
			else
			{
				this.arrow_mc.rotation = 0;
			}
		}

		public static var EntryHeight:Number = 33;
		public static var EntryWidth:Number = 245;
		
		public function ContextMenuEntry(parentCM:ContextMenuMC)
		{
			super();
			this.iggy_mc.visible = false;
			this.setHierarchy(parentCM);
			this.addFrameScript(0,this.frame1);
		}

		public function setTooltip(text:String = "") : Boolean
		{
			this.tooltip = text;
			var nextEnabled:Boolean = this.tooltip != "";
			if (nextEnabled)
			{
				if(!this.tooltipEnabled) MainTimeline.Instance.setupControlForTooltip(this);
			}
			else
			{
				if(this.tooltipEnabled) MainTimeline.Instance.clearControlForTooltip(this);
			}
			this.tooltipEnabled = nextEnabled;
			return this.tooltipEnabled;
		}

		public function setIcon(name:String) : void
		{
			this.iggy_mc.name = name;
			this.iggy_mc.visible = name != "";
		}

		public function setHovered() : void
		{
			this.hl_mc.alpha = 1;
			this.text_txt.textColor = this.selectedColor;
			this.text_txt.htmlText = this.text;
			if(openOnHover) this.open();
		}

		public function clearHovered() : void
		{
			this.hl_mc.alpha = 0;
			this.text_txt.textColor = this.deSelectedColor;
			this.text_txt.htmlText = this.text;
			this.close();
			//Registry.Log("[ContextMenuEntry.clearHovered] id(%s)", this.actionID);
		}
		
		public function deselectElement() : void
		{
			this.clearHovered();
			// if(!isParentOpen)
			// {
			// 	Registry.ExtCall("PlaySound","UI_Generic_Over");	
			// }
			this.removeEventListener(MouseEvent.MOUSE_UP,this.buttonUp);
		}
		
		public function selectElement() : void
		{
			this.setHovered();
			this.isActive = true;
		}
		
		public function pressedButton() : void
		{
			if(!this.disabled)
			{
				Registry.ExtCall("LeaderLib_ContextMenu_EntryPressed",this.list_pos,this.actionID,this.handle,false,this.stayOpen);
				if(!this.stayOpen)
				{
					this.close(true);
					if(this.parentCM)
					{
						this.parentCM.close();
					}
				}
			}
		}
		
		public function buttonUp(e:MouseEvent) : void
		{
			this.removeEventListener(MouseEvent.MOUSE_UP,this.buttonUp);
			if(this.clickSound && !isParentOpen)
			{
				Registry.ExtCall("PlaySound","UI_GM_Generic_Click");
			}
			this.pressedButton();
		}
		
		public function buttonDown(e:MouseEvent) : void
		{
			this.addEventListener(MouseEvent.MOUSE_UP,this.buttonUp);
		}
		
		public function buttonOver(e:MouseEvent) : void
		{
			this.setHovered();
			//this.parentContextMenu.selectButton(this, true);
		}

		public function buttonOut(e:MouseEvent) : void
		{
			this.clearHovered();
		}

		public function onContextMenuSelectionCleared(e:Event) : void
		{
			this.close(true);
		}

		public function close(force:Boolean = false) : void
		{
			if(this.childCM && this.childCM.isOpen)
			{
				if(force || !this.childCM.isMouseHovering)
				{
					this.childCM.close(true);
					this.isOpen = false;
				}
				this.arrow_mc.visible = this.isOpen;

				if(this.side == "left" && this.parentCM && this.parentCM == MainTimeline.Instance.contextMenuMC)
				{
					this.side = "right";
				}
			}
			else
			{
				this.arrow_mc.visible = false;
			}
			//Registry.Log("[%s] close(%s) isOpen(%s)", this, force, this.isOpen);
		}

		public function open(targetX:Number=0, targetY:Number=0) : void
		{
			//Registry.Log("[%s] open(%s, %s) ", this, targetX, targetY);
			if(this.childCM && !this.childCM.isOpen)
			{
				this.childCM.side = this.side;
				//var xPos:Number = Math.max(this.parentContextMenu.bg_mc.mouseX, this.parentContextMenu.bg_mc.width);
				//var yPos:Number = this.parentContextMenu.bg_mc.y;
				//var pos:Point = this.parentContextMenu.bg_mc.localToGlobal(new Point(xPos, yPos));
				//this.childCM.open(pos.x-30, pos.y);
				if(this.parentCM != MainTimeline.Instance.contextMenuMC)
				{
					var parent_mc:MovieClip = this.parentCM as MovieClip;
					this.childCM.open(parent_mc.x + targetX, parent_mc.y + targetY);
				}
				else
				{
					this.childCM.open(targetX, this.y + targetY);
				}
				
				this.isOpen = true;
				this.arrow_mc.visible = true;
				//this.parentContextMenu.addEventListener(Event.CLEAR, this.onContextMenuSelectionCleared);
			}
		}

		public function createSubmenu(openImmediately:Boolean = false) : void
		{
			this.arrow_mc.visible = false;
			if(this.childCM == null)
			{
				var subid:String = String(this.actionID + ".submenu");
				var cm:ContextMenuMC = new ContextMenuMC(subid);
				// cm.bg_mc.top_mc.visible = false;
				// cm.bg_mc.bottom_mc.visible = false;
				cm.setHierarchy(this);
				cm.init();
				cm.visible = false;
				cm.playSounds = false;
				this.setHierarchy(this.parentCM, cm);
			}
			this.childCM.depth = this.depth + 1;
			if(openImmediately)
			{
				this.open();
			}
		}
		
		private function frame1() : void
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN,this.buttonDown);
			this.addEventListener(MouseEvent.MOUSE_OVER,this.buttonOver);
			this.addEventListener(MouseEvent.MOUSE_OUT,this.buttonOut, false, 99);

			if(this.height > EntryHeight)
			{
				EntryHeight = this.height;
			}

			if(this.width > EntryWidth)
			{
				EntryWidth = this.width;
			}
		}

		override public function toString():String
		{
			return "ContextMenuEntry(" + this.actionID + ")";
		}
	}
}