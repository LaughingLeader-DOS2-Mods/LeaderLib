package contextMenu
{
	import LS_Classes.listDisplay;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.events.MouseEvent;
	
	public dynamic class ContextMenuMC extends MovieClip
	{
		public var bg_mc:MovieClip;
		public var list:listDisplay;
		public var base:MovieClip;

		//MainTimeline
		public var closing:Boolean;
		public var isOpen:Boolean;
		public const offsetX:Number = 0;
		public const offsetY:Number = 0;
		public var tweenTime:Number;
		public var text_array:Array;
		public var buttonArr:Array;
		
		public function ContextMenuMC()
		{
			super();
			addFrameScript(0,this.frame1);
		}

		private function frame1() : *
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

			this.base = root as MovieClip;
		}
		
		public function setTitle(text:String) : *
		{
			this.bg_mc.title_txt.htmlText = text;
		}
		
		public function addEntry(id:Number, actionID:String, clickSound:Boolean, text:String, disabled:Boolean, legal:Boolean) : *
		{
			var entry:MovieClip = this.list.getElementByNumber("id",id);
			if(entry == null)
			{
				entry = new ContextMenuEntry(this);
				this.list.addElement(entry,false);
				entry.mouseChildren = false;
				entry.id = id;
				entry.actionID = actionID;
				entry.handle = 0;
				entry.arrow_mc.visible = false;
				entry.hl_mc.alpha = 0;
				entry.isButton = true;
				entry.legal = legal;
				entry.text_txt.autoSize = TextFieldAutoSize.LEFT;
			}
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
		}
		
		public function updateDone() : *
		{
			this.list.positionElements();
			this.bg_mc.setHeight(this.bg_mc.container_mc.height,this.list);
			this.list.scrollRect = new Rectangle(0,0,this.bg_mc.width,this.bg_mc.height);
			this.bg_mc.bottom_mc.y = this.bg_mc.mid_mc.y + this.bg_mc.mid_mc.height - this.bg_mc.bottomOffset;
			this.list.alpha = 1;
			if (this.base.controllerEnabled) {
				this.list.select(0);
			}
			//ExternalInterface.call("setMcSize",this.x + this.bg_mc.x + this.bg_mc.width,this.y + this.bg_mc.y + this.bg_mc.container_mc.y + this.bg_mc.container_mc.height + this.bg_mc.bottom_mc.height);
		}

		public function setListLoopable(b:Boolean) : *
		{
			this.list.m_cyclic = b;
		}

		// Stuff that used to be in MainTimeline
		public function next() : *
		{
			ExternalInterface.call("PlaySound","UI_Gen_CursorMove");
			this.list.next();
			this.setListLoopable(false);
		}
		
		public function previous() : *
		{
			ExternalInterface.call("PlaySound","UI_Gen_CursorMove");
			this.list.previous();
			this.setListLoopable(false);
		}

		public function onInputUp(input:String) : Boolean
		{
			var currentMC:MovieClip = null;
			var isHandled:Boolean = false;
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
					if (!this.base.controllerEnabled) {
						this.previous();
						isHandled = true;
					} else {
						this.setListLoopable(true);
					}
					break;
				case "IE UIDown":
					if (!this.base.controllerEnabled) {
						this.next();
						isHandled = true;
					} else {
						this.setListLoopable(true);
					}
					break;
				case "IE UILeft":
					ExternalInterface.call("LeaderLib_ContextMenu_PreviousContext");
					isHandled = true;
					break;
				case "IE UIRight":
					ExternalInterface.call("LeaderLib_ContextMenu_NextContext");
					isHandled = true;
					break;
				case "IE UIBack":
				case "IE UICancel":
					this.close();
					isHandled = true;
			}
			return isHandled;
		}

		public function onInputDown(input:String) : Boolean
		{
			var isHandled:Boolean = false;
			if (this.base.controllerEnabled) {
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
			return isHandled;
		}

		public function open(targetX:Number=0, targetY:Number=0) : *
		{
			this.x = targetX;
			this.y = targetY;
			
			if(!this.visible)
			{
				ExternalInterface.call("PlaySound","UI_GM_Generic_Slide_Open");
				this.visible = true;
			}
			if(!this.isOpen)
			{
				stage.addEventListener(MouseEvent.CLICK,this.onCloseUI);
				this.isOpen = true;
				ExternalInterface.call("LeaderLib_ContextMenu_Opened");
			}
		}

		public function close() : *
		{
			if(this.visible)
			{
				this.visible = false;
				ExternalInterface.call("PlaySound","UI_GM_Generic_Slide_Close");
			}
			if(this.isOpen)
			{
				stage.removeEventListener("rightMouseDown",this.onCloseUI);
				stage.removeEventListener(MouseEvent.CLICK,this.onCloseUI);
				this.isOpen = false;
				ExternalInterface.call("LeaderLib_ContextMenu_Closed");
			}
		}

		public function onCloseUI(e:MouseEvent) : *
		{
			if(!e.target.isButton)
			{
				this.close();
			}
		}

		public function clearButtons() : *
		{
			this.list.clearElements();
		}
		
		public function selectButton(button:MovieClip) : *
		{
			this.list.selectMC(button);
		}

		public function updateButtons() : *
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
					this.addEntry(id,actionID,clickSound,text,disabled,legal);
				}
				index = index + 7;
			}
			this.updateDone();
			this.buttonArr = new Array();
		}
	}
}