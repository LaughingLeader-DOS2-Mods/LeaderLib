package controls.contextMenu
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import LS_Classes.listDisplay;
	import flash.geom.Point;
	import flash.events.Event;
	import LS_Symbols.IggyIcon;
	
	public dynamic class ContextMenuEntry extends MovieClip
	{
		public var arrow_mc:MovieClip;
		public var hl_mc:MovieClip;
		public var text_txt:TextField;
		public var iggy_mc:IggyIcon;

		public var parentContextMenu:ContextMenuMC;
		public var childContextMenu:ContextMenuMC;

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
		
		public function ContextMenuEntry(parentCM:ContextMenuMC)
		{
			super();
			this.iggy_mc.visible = false;
			this.parentContextMenu = parentCM;
			this.addFrameScript(0,this.frame1);
		}

		public function get isParentOpen():Boolean
		{
			return parentContextMenu && parentContextMenu.isOpen;
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
			this.openSubmenu();
		}

		public function clearHovered() : void
		{
			this.hl_mc.alpha = 0;
			this.text_txt.textColor = this.deSelectedColor;
			this.text_txt.htmlText = this.text;
			this.closeSubmenu();
		}
		
		public function deselectElement() : void
		{
			this.clearHovered();
			if(!isParentOpen)
			{
				Registry.ExtCall("PlaySound","UI_Generic_Over");	
			}
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
				Registry.ExtCall("LeaderLib_ContextMenu_EntryPressed",this.list_pos,this.actionID,this.handle);
				if(!this.stayOpen)
				{
					this.closeSubmenu(true);
					this.parentContextMenu.close();
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

		public function isMouseOverlappingSubmenu() : Boolean
		{
			return this.childContextMenu.isMouseHovering();
		}

		public function closeSubmenu(force:Boolean = false) : void
		{
			if(this.childContextMenu && this.childContextMenu.isOpen)
			{
				if(force && !this.isMouseOverlappingSubmenu())
				{
					MainTimeline.Instance.removeChild(childContextMenu);
					this.childContextMenu.close();
				}
			}
		}

		public function onContextMenuSelectionCleared(e:Event) : void
		{
			this.closeSubmenu(true);
		}

		public function openSubmenu() : void
		{
			if(this.childContextMenu && !this.childContextMenu.isOpen)
			{
				MainTimeline.Instance.addChild(childContextMenu);
				var xPos:Number = Math.max(this.parentContextMenu.bg_mc.mouseX, this.parentContextMenu.bg_mc.width);
				var yPos:Number = this.parentContextMenu.bg_mc.y;
				var pos:Point = this.parentContextMenu.bg_mc.localToGlobal(new Point(xPos, yPos));
				this.childContextMenu.open(pos.x, pos.y);
				//this.parentContextMenu.addEventListener(Event.CLEAR, this.onContextMenuSelectionCleared);
			}
		}

		public function createSubmenu(openImmediately:Boolean = false) : void
		{
			this.arrow_mc.visible = true;
			if(this.childContextMenu == null)
			{
				this.childContextMenu = new ContextMenuMC();
				this.childContextMenu.bg_mc.top_mc.visible = false;
				this.childContextMenu.bg_mc.bottom_mc.visible = false;
				this.childContextMenu.parentObject = this;
				this.childContextMenu.init();
				this.childContextMenu.visible = false;
			}
			if(openImmediately)
			{
				this.openSubmenu();
			}
		}
		
		private function frame1() : void
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN,this.buttonDown);
			this.addEventListener(MouseEvent.ROLL_OVER,this.buttonOver);
			this.addEventListener(MouseEvent.MOUSE_OUT,this.buttonOut);
		}
	}
}