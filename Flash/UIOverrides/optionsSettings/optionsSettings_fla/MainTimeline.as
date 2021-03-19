package optionsSettings_fla
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.external.ExternalInterface;
	
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
		
		public const anchorId:String = "optionsmenu";
		
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
			this.mainMenu_mc.ok_mc.snd_Click = "UI_Gen_Accept";
			this.mainMenu_mc.apply_mc.snd_Click = "UI_Gen_Apply";
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
							this.mainMenu_mc.addMenuDropDown(val9,val4,val8);
							continue;
						case 2:
							val9 = this.update_Array[val2++];
							val4 = this.update_Array[val2++];
							this.mainMenu_mc.addMenuDropDownEntry(val9,val4);
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
							this.mainMenu_mc.addMenuSlider(val11,val4,val10,val12,val13,val14,val15,val8);
							continue;
						case 5:
							val16 = this.update_Array[val2++];
							val4 = this.update_Array[val2++];
							val17 = this.update_Array[val2++];
							val5 = this.update_Array[val2++];
							val8 = this.update_Array[val2++];
							this.mainMenu_mc.addMenuButton(val16,val4,val17,val5,val8);
							continue;
						case 6:
							val4 = this.update_Array[val2++];
							this.mainMenu_mc.addMenuLabel(val4);
							continue;
						case 7:
							val18 = this.update_Array[val2++];
							this.mainMenu_mc.setTitle(val18);
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
			ExternalInterface.call("arrayParsed", "update_Array");
		}
		
		public function parseBaseUpdateArray() : *
		{
			var val2:uint = 0;
			var val3:Number = NaN;
			var val4:String = null;
			var val5:Boolean = false;
			var val6:Object = null;
			var val7:String = null;
			var val1:Number = this.baseUpdate_Array.length;
			if(val1 > 0)
			{
				val2 = 0;
				while(val2 < val1)
				{
					switch(this.baseUpdate_Array[val2++])
					{
						case 0:
							val3 = this.baseUpdate_Array[val2++];
							val4 = this.baseUpdate_Array[val2++];
							val5 = this.baseUpdate_Array[val2++];
							this.mainMenu_mc.addOptionButton(val4,"switchMenu",val3,val5);
							continue;
						case 1:
							val6 = this.baseUpdate_Array[val2++];
							val3 = val6 as Number;
							val4 = this.baseUpdate_Array[val2++];
							this.button_array[val3].text_txt.htmlText = val4.toUpperCase();
							if (this.button_array[val3] == this.mainMenu_mc.apply_mc && this.mainMenu_mc.applyCopy)
							{
								this.mainMenu_mc.applyCopy.text_txt.htmlText = this.button_array[val3].text_txt.htmlText;
							}
							continue;
						case 2:
							val7 = this.baseUpdate_Array[val2++];
							this.mainMenu_mc.toptitle_txt.htmlText = val7;
							continue;
						default:
							continue;
					}
				}
				this.baseUpdate_Array = new Array();
			}
			ExternalInterface.call("arrayParsed", "baseUpdate_Array");
		}
		
		public function onEventResize() : *
		{
		}
		
		public function onEventUp(param1:Number) : Boolean
		{
			return false;
		}
		
		public function onEventDown(param1:Number) : Boolean
		{
			var val2:Boolean = false;
			switch(this.events[param1])
			{
				case "IE UIUp":
					this.mainMenu_mc.moveCursor(true);
					val2 = true;
					break;
				case "IE UIDown":
					this.mainMenu_mc.moveCursor(false);
					val2 = true;
					break;
				case "IE UICancel":
					this.cancelChanges();
					val2 = true;
			}
			return val2;
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
		
		public function cancelChanges() : *
		{
			this.mainMenu_mc.cancelPressed();
		}
		
		public function addMenuInfoLabel(param1:Number, param2:String, param3:String) : *
		{
			this.mainMenu_mc.addMenuInfoLabel(param1,param2,param3);
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
		
		public function selectMenuDropDownEntry(param1:Number, param2:Number) : *
		{
			this.mainMenu_mc.selectMenuDropDownEntry(param1,param2);
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
		
		public function setMenuSlider(param1:Number, param2:Number) : *
		{
			this.mainMenu_mc.setMenuSlider(param1,param2);
		}
		
		public function addOptionButton(param1:String, param2:String, param3:Function, param4:Boolean) : *
		{
			this.mainMenu_mc.addOptionButton(param1,param2,param3,param4);
		}
		
		public function setButtonEnabled(param1:Number, param2:Boolean) : *
		{
			this.mainMenu_mc.setButtonEnabled(param1,param2);
		}
		
		public function removeItems() : *
		{
			this.mainMenu_mc.removeItems();
		}
		
		public function setButtonDisable(buttonId:Number, bDisabled:Boolean) : *
		{
			//ExternalInterface.call("onSetButtonDisable", buttonId, bDisabled);
			this.button_array[buttonId].disable_mc.visible = bDisabled;
			this.button_array[buttonId].bg_mc.visible = !bDisabled;
		}

		public function setApplyButtonCopyVisible(bVisible:Boolean=true) : *
		{
			if (this.mainMenu_mc.applyCopy)
			{
				this.mainMenu_mc.applyCopy.bg_mc.visible = bVisible;
				this.mainMenu_mc.applyCopy.text_txt.visible = bVisible;
				this.mainMenu_mc.applyCopy.disable_mc.visible = false;
			}
		}

		public function createApplyButton(bVisible:Boolean = false) : *
		{
			if (!this.mainMenu_mc.applyCopy)
			{
				var original:MovieClip = this.mainMenu_mc.apply_mc;
				//var sourceClass:Class = Object(this.mainMenu_mc.apply_mc).constructor;
				var applyButtonCopy:MovieClip = new AcceptButton_5();
				applyButtonCopy.x = original.x;
				applyButtonCopy.y = original.y;
				this.mainMenu_mc.setupApplyCopy(applyButtonCopy, bVisible);
				//this.button_array[3] = applyButtonCopy
			}
		}
		
		public function resetMenuButtons(param1:Number) : *
		{
			this.mainMenu_mc.resetMenuButtons(param1);
		}

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

		public function positionElements() : *
		{
			this.mainMenu_mc.list.positionElements();
		}

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

		public function clearAll():*
		{
			this.update_Array = new Array();
			this.removeItems();
			//this.baseUpdate_Array = new Array();
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
		}
	}
}
