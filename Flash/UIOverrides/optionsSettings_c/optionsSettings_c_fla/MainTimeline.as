package optionsSettings_c_fla
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class MainTimeline extends MovieClip
	{
		public var mainMenu_mc:MovieClip;
		public var selectedInfo_txt:TextField;
		public var events:Array;
		public var layout:String;
		public var curTooltip:String;
		public var hasTooltip:Boolean;
		public var update_Array:Array;
		public const anchorId:String = "optionsSettingsMenu_c";
		public const anchorPos:String = "center";
		public const anchorTPos:String = "center";
		public const anchorTarget:String = "screen";
		
		public function MainTimeline()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onEventInit() : *
		{
			this.selectedInfo_txt.autoSize = TextFieldAutoSize.LEFT;
			this.selectedInfo_txt.visible = false;
			this.selectedInfo_txt.mouseEnabled = false;
			this.mainMenu_mc.setMainScrolling(true);
			this.mainMenu_mc.init();
		}
		
		public function onEventResize() : *
		{
		}
		
		public function onEventUp(id:Number) : Boolean
		{
			var isHandled:Boolean = false;
			var mc:MovieClip = this.mainMenu_mc.list.getCurrentMovieClip();
			if(mc && mc.handleEvent)
			{
				isHandled = mc.handleEvent(this.events[id],false);
			}
			if(!isHandled)
			{
				switch(this.events[id])
				{
					case "IE UIShowInfo":
						ExternalInterface.call("PlaySound","UI_Gen_Reset");
						ExternalInterface.call("autoDetect");
						isHandled = true;
						break;
					case "IE UISetSlot":
						ExternalInterface.call("PlaySound","UI_Gen_Reset");
						ExternalInterface.call("pressedDefaults");
						isHandled = true;
						break;
					case "IE UIAccept":
						ExternalInterface.call("PlaySound","UI_Gen_Accept");
						ExternalInterface.call("acceptPressed");
						isHandled = true;
						break;
					case "IE UIUp":
					case "IE UIDown":
						this.mainMenu_mc.setListLoopable(true);
						isHandled = true;
						break;
					case "IE UICancel":
						isHandled = true;
				}
			}
			return isHandled;
		}
		
		public function addingDone() : *
		{
			this.mainMenu_mc.addingDone();
		}
		
		public function addCheckBoxOptions(param1:String) : *
		{
			this.mainMenu_mc.addCheckBoxOptions(param1);
		}
		
		public function onEventDown(id:Number) : Boolean
		{
			var isHandled:Boolean = false;
			var mc:MovieClip = this.mainMenu_mc.list.getCurrentMovieClip();
			if(mc && mc.handleEvent)
			{
				isHandled = mc.handleEvent(this.events[id],true);
			}
			if(!isHandled)
			{
				switch(this.events[id])
				{
					case "IE UIShowInfo":
					case "IE UISetSlot":
					case "IE UIAccept":
						isHandled = true;
						break;
					case "IE UIUp":
						this.mainMenu_mc.moveCursor(true);
						isHandled = true;
						break;
					case "IE UIDown":
						this.mainMenu_mc.moveCursor(false);
						isHandled = true;
						break;
					case "IE UICancel":
						this.mainMenu_mc.destroyMenu();
						isHandled = true;
				}
			}
			return isHandled;
		}
		
		public function addBtnHint(param1:Number, param2:Number, param3:String) : *
		{
			this.mainMenu_mc.buttonHint_mc.addBtnHint(param1,param3,param2);
		}
		
		public function clearBtnHints() : *
		{
			this.mainMenu_mc.buttonHint_mc.clearBtnHints();
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
		
		public function setX(param1:Number) : void
		{
			this.mainMenu_mc.x = param1;
		}
		
		public function setY(param1:Number) : void
		{
			this.mainMenu_mc.y = param1;
		}
		
		public function setPos(param1:Number, param2:Number) : void
		{
			this.mainMenu_mc.x = param1;
			this.mainMenu_mc.y = param2;
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
		}
		
		public function closeMenu() : *
		{
			this.mainMenu_mc.closeMenu();
		}
		
		public function addMenuLabel(param1:String) : *
		{
			this.mainMenu_mc.addMenuLabel(param1);
		}
		
		public function addMenuInfoLabel(param1:Number, param2:String, param3:String) : *
		{
			this.mainMenu_mc.addMenuInfoLabel(param1,param2,param3);
		}
		
		public function setTitle(param1:String) : *
		{
			this.mainMenu_mc.setTitle(param1);
		}
		
		public function setTopTitle(param1:String) : *
		{
			this.mainMenu_mc.toptitle_txt.htmlText = param1;
		}
		
		public function parseUpdateArray() : *
		{
			var val2:uint = 0;
			var val3:Number = NaN;
			var val4:String = null;
			var val5:Boolean = false;
			var val6:Number = NaN;
			var val7:Boolean = false;
			var val8:String = null;
			var val9:Number = NaN;
			var val10:Number = NaN;
			var val11:Number = NaN;
			var val12:Number = NaN;
			var val13:Number = NaN;
			var val14:Number = NaN;
			var val15:Boolean = false;
			var val16:Number = NaN;
			var val17:String = null;
			var val18:String = null;
			var val19:Number = NaN;
			var val1:Number = this.update_Array.length;
			if(val1 > 0)
			{
				val2 = 0;
				while(val2 < val1)
				{
					switch(this.update_Array[val2++])
					{
						case 0:
							val3 = this.update_Array[val2++];
							val4 = this.update_Array[val2++];
							val5 = this.update_Array[val2++];
							val6 = this.update_Array[val2++];
							val7 = this.update_Array[val2++];
							val8 = this.update_Array[val2++];
							this.mainMenu_mc.addMenuCheckbox(val3,val4,val5,val6,val7,val8);
							continue;
						case 1:
							val9 = this.update_Array[val2++];
							val4 = this.update_Array[val2++];
							val8 = this.update_Array[val2++];
							this.addMenuDropDown(val9,val4,val8);
							continue;
						case 2:
							val9 = this.update_Array[val2++];
							val4 = this.update_Array[val2++];
							this.addMenuDropDownEntry(val9,val4);
							continue;
						case 3:
							val9 = this.update_Array[val2++];
							val10 = this.update_Array[val2++];
							this.selectMenuDropDownEntry(val9,val10);
							continue;
						case 4:
							val11 = this.update_Array[val2++];
							val4 = this.update_Array[val2++];
							val10 = this.update_Array[val2++];
							val12 = this.update_Array[val2++];
							val13 = this.update_Array[val2++];
							val14 = this.update_Array[val2++];
							val15 = this.update_Array[val2++];
							val8 = this.update_Array[val2++];
							this.addMenuSlider(val11,val4,val10,val12,val13,val14,val15,val8);
							continue;
						case 5:
							val16 = this.update_Array[val2++];
							val4 = this.update_Array[val2++];
							val17 = this.update_Array[val2++];
							val5 = this.update_Array[val2++];
							this.addMenuButton(val16,val4,val5);
							continue;
						case 6:
							val4 = this.update_Array[val2++];
							this.addMenuLabel(val4);
							continue;
						case 7:
							val18 = this.update_Array[val2++];
							this.setTitle(val18);
							continue;
						case 8:
							val9 = this.update_Array[val2++];
							val5 = this.update_Array[val2++];
							this.setMenuDropDownEnabled(val9,val5);
							continue;
						case 9:
							val3 = this.update_Array[val2++];
							val5 = this.update_Array[val2++];
							val19 = !!this.update_Array[val2++]?Number(1):Number(0);
							this.setMenuCheckbox(val3,val5,val19);
							continue;
						case 10:
							//LeaderLib Addition
							val3 = this.update_Array[val2++];
							val4 = this.update_Array[val2++];
							val8 = this.update_Array[val2++];
							this.mainMenu_mc.addMenuInfoLabel(val3, val4, val8);
							continue;
						default:
							continue;
					}
				}
			}
			this.update_Array = new Array();
			//LeaderLib Addition
			ExternalInterface.call("arrayParsed", "update_Array");
		}
		
		public function addMenuCheckbox(param1:Number, param2:String, param3:Boolean, param4:Number, param5:Boolean, param6:String = "") : *
		{
			this.mainMenu_mc.addMenuCheckbox(param1,param2,param3,param4,param5,param6);
		}
		
		public function setMenuCheckbox(param1:Number, param2:Boolean, param3:Number) : *
		{
			this.mainMenu_mc.setMenuCheckbox(param1,param2,param3);
		}
		
		public function addMenuSelector(param1:Number, param2:String) : *
		{
			this.mainMenu_mc.addMenuSelector(param1,param2);
		}
		
		public function addMenuSelectorEntry(param1:Number, param2:String) : *
		{
			this.mainMenu_mc.addMenuSelectorEntry(param1,param2);
		}
		
		public function selectMenuSelectorEntry(param1:Number, param2:Number) : *
		{
			this.mainMenu_mc.selectMenuSelectorEntry(param1,param2);
		}
		
		public function addMenuDropDown(param1:Number, param2:String, param3:String = "") : *
		{
			this.mainMenu_mc.addMenuSelector(param1,param2,param3);
		}
		
		public function addMenuDropDownEntry(param1:Number, param2:String) : *
		{
			this.mainMenu_mc.addMenuSelectorEntry(param1,param2);
		}
		
		public function selectMenuDropDownEntry(param1:Number, param2:Number) : *
		{
			this.mainMenu_mc.selectMenuSelectorEntry(param1,param2);
		}
		
		public function clearMenuDropDownEntries(param1:Number) : *
		{
			this.mainMenu_mc.clearMenuDropDownEntries(param1);
		}
		
		public function setMenuDropDownEnabled(param1:Number, param2:Boolean) : *
		{
			this.mainMenu_mc.setMenuDropDownEnabled(param1,param2);
		}
		
		public function setMenuDropDownDisabledTooltip(param1:Number, param2:String) : *
		{
			this.mainMenu_mc.setMenuDropDownDisabledTooltip(param1,param2);
		}
		
		public function addMenuSlider(param1:Number, param2:String, param3:Number, param4:Number, param5:Number, param6:Number = 1, param7:Boolean = false, param8:String = "") : *
		{
			this.mainMenu_mc.addMenuSlider(param1,param2,param3,param4,param5,param6,param7,param8);
		}
		
		public function setMenuSlider(param1:Number, param2:Number) : *
		{
			this.mainMenu_mc.setMenuSlider(param1,param2);
		}
		
		public function addMenuButton(param1:Number, param2:String, param3:Boolean) : *
		{
			this.mainMenu_mc.addMenuButton(param1,param2,param3);
		}
		
		public function setButtonEnabled(param1:Number, param2:Boolean) : *
		{
		}
		
		public function setButtonText(param1:Number, param2:String) : *
		{
		}
		
		public function removeItems() : *
		{
			this.mainMenu_mc.removeItems();
		}
		
		public function setButtonDisable(param1:Number, param2:Boolean) : *
		{
		}
		
		public function resetMenuButtons() : *
		{
		}

		// LeaderLib Addition
		public function getElementHeight(id:Number) : *
		{
			var mc:MovieClip = this.mainMenu_mc.getElementByID(id);
			if(!mc)
			{
				mc = this.mainMenu_mc.list.content_array[id];
			}
			if(mc)
			{
				return this.mainMenu_mc.list.getElementHeight(mc);
			}
			return -1;
		}

		// LeaderLib Addition
		public function positionElements() : *
		{
			this.mainMenu_mc.list.positionElements();
		}

		// LeaderLib Addition
		public function setTextFormat(id:Number, underline:Boolean = false, bold:Boolean = false, italic:Boolean = false, size:uint=-1, color:Object = null) : *
		{
			var tf:TextFormat = null;
			var mc:MovieClip = this.mainMenu_mc.getElementByID(id);
			if(!mc)
			{
				mc = this.mainMenu_mc.list.content_array[id];
			}
			if(mc && mc.label_txt)
			{
				tf = mc.label_txt.getTextFormat();
				if (tf)
				{
					tf.underline = underline;
					tf.bold = bold;
					tf.italic = italic;
					if (size > -1)
					{
						tf.size = size
					}
					if(color) {
						tf.color = color
					}
					mc.label_txt.setTextFormat(tf);
					return true;
				}
			}
			return false;
		}

		// LeaderLib Addition
		public function clearAll():*
		{
			this.update_Array = new Array();
			this.removeItems();
		}
		
		function frame1() : *
		{
			this.events = new Array("IE UIUp","IE UIDown","IE UICancel","IE UIAccept","IE UILeft","IE UIRight","IE UIShowInfo","IE UISetSlot");
			this.layout = "fitVertical";
			this.curTooltip = "";
			this.hasTooltip = false;
			this.update_Array = new Array();
		}
	}
}
