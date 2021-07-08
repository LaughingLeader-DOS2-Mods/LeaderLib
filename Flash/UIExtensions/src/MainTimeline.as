package
{
	import fl.motion.Color;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import Controls.*;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	//import flash.ui.Keyboard;
	import LS_Classes.tooltipHelper;
	import contextMenu.ContextMenuMC;
	
	public dynamic class MainTimeline extends MovieClip
	{		
		public var layout:String;
		public var events:Array;
		public var anchorId:String;
		
		public var mainPanel_mc:MainPanel;
		public var context_menu:contextMenu.ContextMenuMC;
		
		public var curTooltip:String;
	  	public var hasTooltip:Boolean;

	  	public var controllerEnabled:Boolean = false;
		public var isInCharacterCreation:Boolean = false;
		public var UICreationTabPrevPressed:Boolean = false;
		public var CtrlDown:Boolean = false;

		public var timers:Array;

		public var listeningForMouse:Boolean = false;

		public var globalToLocalX:Number = 0;
		public var globalToLocalY:Number = 0;
		public var localToGlobalX:Number = 0;
		public var localToGlobalY:Number = 0;
		public var screenWidth:Number = 0;
		public var screenHeight:Number = 0;
		
		public function MainTimeline()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onEventUp(id:Number) : *
		{
			this.CtrlDown = false;
			var isHandled:Boolean = false;
			var input:String = this.events[id];
			if (input != null)
			{
				ExternalInterface.call("LeaderLib_UIExtensions_InputEvent", false, input, id);
				if(isInCharacterCreation)
				{
					switch(input)
					{
						case "IE UICreationTabPrev":
							this.UICreationTabPrevPressed = false;
							break;
					}
				}
				if (!isHandled && this.context_menu.visible)
				{
					isHandled = this.context_menu.onInputUp(input);
				}
			}

			return isHandled;
		}
		
		public function onEventDown(id:Number) : Boolean
		{
			var isHandled:Boolean = false;
			var input:String = this.events[id];
			if (input != null)
			{
				ExternalInterface.call("LeaderLib_UIExtensions_InputEvent", true, input, id);
				if(!controllerEnabled)
				{
					// if(!isInCharacterCreation)
					// {
					// 	switch(input)
					// 	{
					// 		case "IE UICopy":
					// 			this.CtrlDown = true;
					// 			isHandled = true;
					// 			ExternalInterface.call("LeaderLib_ToggleChainGroup");
					// 	}
					// }
				}
				else
				{
					if(isInCharacterCreation)
					{
						switch(input)
						{
							case "IE UICreationTabPrev":
								this.UICreationTabPrevPressed = true;
								break;
							case "IE ConnectivityMenu":
								// Prevents "ConnectivityMenu" from opening the connectivity menu in CC if UICreationTabPrevPressed is held
								isHandled = this.UICreationTabPrevPressed;
								break;
						}
						if (isHandled)
						{
							return true;
						}
					}
				}
				if (!isHandled && this.context_menu.visible)
				{
					isHandled = this.context_menu.onInputDown(input);
				}
			}

			return isHandled;
		}
		
		public function onEventInit() : *
		{
			ExternalInterface.call("registeranchorId","LeaderLib_UIExtensions");
			ExternalInterface.call("setAnchor","center","screen","center");
		}

		public function onEventResize() : *
		{
			ExternalInterface.call("setPosition","center","screen","center");
		}

		public function onEventResolution(w:Number, h:Number) : *
		{
			this.screenWidth = w;
			this.screenHeight = h;
		}

		public function removeControl(id:Number): Boolean
		{
			return mainPanel_mc.removeElementWithID(id);
		}

		public function clearElements() : * 
		{
			//mainPanel_mc.list.clearElements();
			mainPanel_mc.clearElements();
		}

		private function onMouseOverTooltip(e:MouseEvent) : *
		{
			var obj:MovieClip = e.target as MovieClip;
			if(obj.tooltip != null && obj.tooltip != "")
			{
				this.curTooltip = obj.name;
				obj.tooltipOverrideW = this.base.ElW;
				obj.tooltipYOffset = -4;
				tooltipHelper.ShowTooltipForMC(obj,this,"bottom",this.hasTooltip == false);
			}
		}

		private function onMouseOutTooltip(e:MouseEvent) : *
		{
			if(this.curTooltip == e.target.name && this.hasTooltip)
			{
				ExternalInterface.call("hideTooltip");
				this.hasTooltip = false;
			}
			this.curTooltip = "";
		}

		private function setupControlForTooltip(obj:MovieClip) : *
		{
			obj.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverTooltip);
			obj.addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOutTooltip);
		}
		
		public function addCheckbox(id:Number, label:String, tooltip:String, stateID:Number=0, x:Number=0, y:Number=0, filterBool:Boolean = false, enabled:Boolean = true) : *
		{
			var checkbox:MovieClip = new Checkbox();
			checkbox.x = x;
			checkbox.y = y;
			checkbox.label_txt.htmlText = label;
			checkbox.id = id;
			checkbox.mHeight = 30;
			checkbox.filterBool = filterBool;
			checkbox.stateID = stateID;
			checkbox.tooltip = tooltip;
			checkbox.bg_mc.gotoAndStop(stateID * 3 + 1);
			checkbox.enable = enabled;
			//checkbox.label_txt.width = checkbox.label_txt.textWidth;
			if(enabled == false)
			{
				checkbox.alpha = 0.3;
			}
			//setupControlForTooltip(checkbox);
			mainPanel_mc.addElement(checkbox);
			checkbox.label_bg_mc.width = (checkbox.label_txt.textWidth*1.2) + 12;
			ExternalInterface.call("LeaderLib_UIExtensions_ControlAdded", "checkbox", id, checkbox.list_id);
		}

		public function setCheckboxState(id:Number, state:Number): *
		{
			var obj:MovieClip = mainPanel_mc.elements[id];
			if(obj != null)
			{
				var checkbox:Checkbox = obj as Checkbox;
				if(checkbox != null)
				{
					checkbox.setState(state);
				}
			}
		}

		public function toggleCheckbox(id:Number): *
		{
			var obj:MovieClip = mainPanel_mc.elements[id];
			if(obj != null)
			{
				var checkbox:Checkbox = obj as Checkbox;
				if(checkbox != null)
				{
					checkbox.toggle();
				}
			}
		}

		public function addBar(id:Number, label:String, tooltip:String = "", x:Number=0, y:Number=0, percentage:Number = 1.0, doTween:Boolean = false, color:Number=NaN) : *
		{
			var bar:BarHolder = new BarHolder();
			bar.id = id;
			bar.x = x;
			bar.y = y;
			bar.tooltip = tooltip;
			bar.setBar(percentage, doTween);
			if (!isNaN(color)) {
				bar.setBarColour(color);
			}
			//setupControlForTooltip(bar);
			mainPanel_mc.addElement(bar);
			ExternalInterface.call("LeaderLib_UIExtensions_ControlAdded", "bar", id, bar.list_id);
		}

		public function setBar(id:Number, percentage:Number = 1.0, doTween:Boolean = false, color:Number=NaN) : *
		{
			var obj:MovieClip = mainPanel_mc.elements[id];
			if(obj != null)
			{
				var bar:BarHolder = obj as BarHolder;
				if(bar != null)
				{
					bar.setBar(percentage, doTween);
					if (!isNaN(color)) {
						bar.setBarColour(color);
					}
				}
			}
		}

		public function setGlobalToLocalPosition(x:Number, y:Number) : *
		{
			var globalPt:Point = new Point(x,y);
			var localPt:Point = this.globalToLocal(globalPt);
			globalToLocalX = localPt.x;
			globalToLocalY = localPt.y;
		}

		public function setLocalToGlobalPosition(x:Number, y:Number, width:Number, height:Number) : *
		{
			var localPt:Point = new Point(x,y);
			var globalPt:Point = this.localToGlobal(localPt);
			localToGlobalX = localPt.x;
			localToGlobalY = localPt.y;
		}

		public function globalToLocalTest(x:Number, y:Number) : Point
		{
			var globalPt:Point = new Point(x,y);
			return this.globalToLocal(globalPt);
		}

		public function removeTimer(timer:ClientTimer, removeFromArray:Boolean = false) : *
		{
			if(removeFromArray) {
				var index:uint = 0;
				while(index < this.timers.length)
				{
					if(this.timers[index] == timer)
					{
						this.timers.splice(index,1);
						break;
					}
					index++;
				}
			}

			timer = null;
		}

		public function destroyTimers() : * 
		{
			var index:uint = 0;
			while(index < this.timers.length)
			{
				var timer:ClientTimer = this.timers[index] as ClientTimer;
				if(timer != null) {
					timer.dispose();
					timer = null;
				}
				index++;
			}
			this.timers = new Array();
		}

		public function launchTimer(delay:Number, name:String, repeat:int=1) : *
		{
			var timer:ClientTimer = new ClientTimer(name, delay, repeat, this);
			this.timers.push(timer);
			timer.start();
		}

		public function fireOnMouseClick(e:MouseEvent) : *
		{
			ExternalInterface.call("LeaderLib_UIExtensions_MouseClicked", e.stageX, e.stageY);
		}
		
		public function fireOnMouseMove(e:MouseEvent) : *
		{
			ExternalInterface.call("LeaderLib_UIExtensions_MouseMoved", e.stageX, e.stageY);
		}

		public function onRightMouseDown(e:Event) : *
		{
			ExternalInterface.call("LeaderLib_UIExtensions_RightMouseDown", stage.mouseX, stage.mouseY);
		}

		public function onRightMouseUp(e:Event) : *
		{
			ExternalInterface.call("LeaderLib_UIExtensions_RightMouseUp", stage.mouseX, stage.mouseY);
		}

		public function fireMouseClicked(eventName:String = "") : *
		{
			ExternalInterface.call("LeaderLib_UIExtensions_MouseClicked", stage.mouseX, stage.mouseY);
		}

		public function dispose(): *
		{
			if (this.listeningForMouse) {
				stage.removeEventListener(MouseEvent.CLICK,this.fireOnMouseClick);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.fireOnMouseMove);
				this.listeningForMouse = false;
			}
			destroyTimers();
			this.disableKeyboardListeners();
		}

		public function enableMouseListeners(b:Boolean) : * {
			this.mouseChildren = b;
			this.mouseEnabled = b;
			if (!b && this.listeningForMouse) {
				stage.removeEventListener(MouseEvent.CLICK,this.fireOnMouseClick);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.fireOnMouseMove);
				stage.removeEventListener("rightMouseDown",this.onRightMouseDown);
				stage.removeEventListener("rightMouseUp",this.onRightMouseUp);
			} else if (b && !this.listeningForMouse) {
				stage.addEventListener(MouseEvent.CLICK,this.fireOnMouseClick);
				stage.addEventListener(MouseEvent.MOUSE_MOVE,this.fireOnMouseMove);
				stage.addEventListener("rightMouseDown",this.onRightMouseDown);
				stage.addEventListener("rightMouseUp",this.onRighMouseUp);
			}
			this.listeningForMouse = b;
		}

		public function showContextMenu(b:Boolean = true) : *
		{
			if (b)
			{
				context_menu.open(mouseX, mouseY);
			}
			else
			{
				context_menu.close();
			}
		}

		private function onKeyboardDown(e:KeyboardEvent) : *
		{
			trace("onKeyboardDown", e.keyCode, String.fromCharCode(e.charCode));
			ExternalInterface.call("LeaderLib_UIExtensions_KeyboardEvent", e.keyCode, String.fromCharCode(e.charCode), true);
		}

		private function onKeyboardUp(e:KeyboardEvent) : *
		{
			ExternalInterface.call("LeaderLib_UIExtensions_KeyboardEvent", e.keyCode, String.fromCharCode(e.charCode), false);
		}

		public function enableKeyboardListeners() : *
		{
			//Experimental, doesn't quite seem to work yet.
			ExternalInterface.call("inputFocus");
			stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyboardDown, true);
			stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyboardUp, true);
			trace("Enabled keyboard event listeners");
		}

		public function disableKeyboardListeners() : *
		{
			ExternalInterface.call("inputFocusLost");
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyboardDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyboardUp);
		}
		
		public function frame1() : *
		{
			this.anchorId = "LeaderLib_UIExtensions";
			this.layout = "fixed";
			//this.events = new Array("IE UICreationTabPrev", "IE UIStartGame", "IE ConnectivityMenu");
			this.curTooltip = "";
		 	this.hasTooltip = false;
			this.timers = new Array();

			this.screenWidth = this.width;
			this.screenHeight = this.height;

			context_menu = new contextMenu.ContextMenuMC();
			this.addChild(context_menu);
			context_menu.visible = false;

			//this.addEventListener(MouseEvent.CLICK,this.fireOnMouseClick, true);
			//this.addEventListener(MouseEvent.MOUSE_MOVE,this.fireOnMouseMove, true);

			this.events = new Array("IE Action1","IE ActionCancel","IE ActionMenu","IE AreaPickup","IE Benchmark","IE CCZoomIn","IE CCZoomOut","IE CameraBackward","IE CameraCenter","IE CameraForward","IE CameraLeft","IE CameraRight","IE CameraRotateLeft","IE CameraRotateMouseLeft","IE CameraRotateMouseRight","IE CameraRotateRight","IE CameraToggleMouseRotate","IE CameraZoomIn","IE CameraZoomOut","IE CancelSelectorMode","IE CharacterCreationAccept","IE CharacterCreationRotateLeft","IE CharacterCreationRotateRight","IE CharacterMoveBackward","IE CharacterMoveForward","IE CharacterMoveLeft","IE CharacterMoveRight","IE CloseApplication","IE Combine","IE ConnectivityMenu","IE ContextMenu","IE ControllerContextMenu","IE CycleCharactersNext","IE CycleCharactersPrev","IE DefaultCameraBackward","IE DefaultCameraCaptureInput","IE DefaultCameraFast","IE DefaultCameraForward","IE DefaultCameraFrontView","IE DefaultCameraLeft","IE DefaultCameraLeftView","IE DefaultCameraMouseDown","IE DefaultCameraMouseLeft","IE DefaultCameraMouseRight","IE DefaultCameraMouseUp","IE DefaultCameraPanCamera","IE DefaultCameraRight","IE DefaultCameraRotateDown","IE DefaultCameraRotateLeft","IE DefaultCameraRotateRight","IE DefaultCameraRotateUp","IE DefaultCameraSlow","IE DefaultCameraSpecialPanCamera1","IE DefaultCameraSpecialPanCamera2","IE DefaultCameraToggleMouseRotation","IE DefaultCameraTopView","IE DefaultCameraZoomIn","IE DefaultCameraZoomOut","IE DestructionToggle","IE DragSingleToggle","IE FlashAlt","IE FlashArrowDown","IE FlashArrowLeft","IE FlashArrowRight","IE FlashArrowUp","IE FlashBackspace","IE FlashCancel","IE FlashCtrl","IE FlashDelete","IE FlashEnd","IE FlashEnter","IE FlashHome","IE FlashLeftMouse","IE FlashMiddleMouse","IE FlashMouseMoveDown","IE FlashMouseMoveLeft","IE FlashMouseMoveRight","IE FlashMouseMoveUp","IE FlashPgDn","IE FlashPgUp","IE FlashRightMouse","IE FlashScrollDown","IE FlashScrollUp","IE FlashTab","IE FreeCameraFoVDec","IE FreeCameraFoVInc","IE FreeCameraFreezeGameTime","IE FreeCameraHeightDec","IE FreeCameraHeightInc","IE FreeCameraMoveBackward","IE FreeCameraMoveForward","IE FreeCameraMoveLeft","IE FreeCameraMoveRight","IE FreeCameraRotSpeedDec","IE FreeCameraRotSpeedInc","IE FreeCameraRotateControllerDown","IE FreeCameraRotateControllerLeft","IE FreeCameraRotateControllerRight","IE FreeCameraRotateControllerUp","IE FreeCameraRotateMouseDown","IE FreeCameraRotateMouseLeft","IE FreeCameraRotateMouseRight","IE FreeCameraRotateMouseUp","IE FreeCameraSlowdown","IE FreeCameraSpeedDec","IE FreeCameraSpeedInc","IE FreeCameraSpeedReset","IE FreeCameraToggleMouseRotate","IE GMKillResurrect","IE GMNormalAlignMode","IE GMSetHealth","IE HighlightCharacters","IE Interact","IE MoveCharacterUpInGroup","IE NextObject","IE PanelSelect","IE PartyManagement","IE Pause","IE Ping","IE PrevObject","IE QueueCommand","IE QuickLoad","IE QuickSave","IE ReloadInputConfig","IE RotateItemLeft","IE RotateItemRight","IE Screenshot","IE SelectorMoveBackward","IE SelectorMoveForward","IE SelectorMoveLeft","IE SelectorMoveRight","IE ShowChat","IE ShowSneakCones","IE ShowWorldTooltips","IE SkipVideo","IE SplitItemToggle","IE SwitchGMMode","IE ToggleCharacterPane","IE ToggleCombatMode","IE ToggleCraft","IE ToggleEquipment","IE ToggleFullscreen","IE ToggleGMInventory","IE ToggleGMItemGeneratorPane","IE ToggleGMMiniMap","IE ToggleGMMoodPanel","IE ToggleGMPause","IE ToggleGMRewardPanel","IE ToggleGMShroud","IE ToggleHomestead","IE ToggleInGameMenu","IE ToggleInfo","IE ToggleInputMode","IE ToggleInventory","IE ToggleJournal","IE ToggleManageTarget","IE ToggleMap","IE ToggleMonsterSelect","IE ToggleOverviewMap","IE TogglePartyManagement","IE TogglePresentation","IE ToggleRecipes","IE ToggleReputationPanel","IE ToggleRollPanel","IE ToggleSetStartPoint","IE ToggleSkills","IE ToggleSneak","IE ToggleSplitscreen","IE ToggleStatusPanel","IE ToggleSurfacePainter","IE ToggleTacticalCamera","IE ToggleVignette","IE UIAccept","IE UIAddPoints","IE UIAddonDown","IE UIAddonUp","IE UIBack","IE UICancel","IE UICompareItems","IE UIContextMenuModifier","IE UICopy","IE UICreateProfile","IE UICreationAddSkill","IE UICreationEditClassNext","IE UICreationEditClassPrev","IE UICreationNext","IE UICreationPrev","IE UICreationRemoveSkill","IE UICreationTabNext","IE UICreationTabPrev","IE UICut","IE UIDelete","IE UIDeleteProfile","IE UIDialogRPSPaper","IE UIDialogRPSRock","IE UIDialogRPSScissors","IE UIDialogTextDown","IE UIDialogTextUp","IE UIDown","IE UIEditCharacter","IE UIEndTurn","IE UIFilter","IE UIHotBarNext","IE UIHotBarPrev","IE UIInvite","IE UILeft","IE UIMapDown","IE UIMapLeft","IE UIMapRemoveMarker","IE UIMapReset","IE UIMapRight","IE UIMapUp","IE UIMapZoomIn","IE UIMapZoomOut","IE UIMarkWares","IE UIMessageBoxA","IE UIMessageBoxB","IE UIMessageBoxX","IE UIMessageBoxY","IE UIModNext","IE UIModPrev","IE UIPaste","IE UIRadialDown","IE UIRadialLeft","IE UIRadialRight","IE UIRadialUp","IE UIRefresh","IE UIRemoveItemSelection","IE UIRemovePoints","IE UIRename","IE UIRequestTrade","IE UIRight","IE UISelectChar1","IE UISelectChar2","IE UISelectChar3","IE UISelectChar4","IE UISelectSlot0","IE UISelectSlot1","IE UISelectSlot11","IE UISelectSlot12","IE UISelectSlot2","IE UISelectSlot3","IE UISelectSlot4","IE UISelectSlot5","IE UISelectSlot6","IE UISelectSlot7","IE UISelectSlot8","IE UISelectSlot9","IE UISend","IE UISetSlot","IE UIShowInfo","IE UIShowTooltip","IE UIStartGame","IE UISwitchDown","IE UISwitchLeft","IE UISwitchRight","IE UISwitchUp","IE UITabNext","IE UITabPrev","IE UITakeAll","IE UIToggleActions","IE UIToggleEquipment","IE UIToggleHelmet","IE UIToggleMultiselection","IE UIToggleTutorials","IE UITooltipDown","IE UITooltipUp","IE UITradeBalance","IE UITradeRemoveOffer","IE UITradeSwitchWindow","IE UIUp","IE WidgetButtonA","IE WidgetButtonBackSpace","IE WidgetButtonC","IE WidgetButtonDelete","IE WidgetButtonDown","IE WidgetButtonEnd","IE WidgetButtonEnter","IE WidgetButtonEscape","IE WidgetButtonHome","IE WidgetButtonLeft","IE WidgetButtonPageDown","IE WidgetButtonPageUp","IE WidgetButtonRight","IE WidgetButtonSpace","IE WidgetButtonTab","IE WidgetButtonUp","IE WidgetButtonV","IE WidgetButtonX","IE WidgetButtonY","IE WidgetButtonZ","IE WidgetMouseLeft","IE WidgetMouseMotion","IE WidgetMouseRight","IE WidgetScreenshot","IE WidgetScreenshotVideo","IE WidgetScrollDown","IE WidgetScrollUp","IE WidgetToggleDebugConsole","IE WidgetToggleDevComments","IE WidgetToggleEffectStats","IE WidgetToggleGraphicsDebug","IE WidgetToggleHierarchicalProfiler","IE WidgetToggleOptions","IE WidgetToggleOutput","IE WidgetToggleStats");
		}
	}
}