package
{
	import controls.*;
	import LS_Classes.tooltipHelper;

	import controls.bars.BarHolder;
	import controls.contextMenu.ContextMenuMC;
	import controls.panels.DraggablePanelDark;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	import interfaces.IInputHandler;

	import system.DropdownManager;
	import system.KeyCodeNames;
	import system.PanelManager;

	import util.ClientTimer;
	import controls.bars.HealthBarHolder;
	import controls.contextMenu.ContextMenuMain;
	import flash.utils.Timer;
	
	public class MainTimeline extends MovieClip
	{		
		//Engine variables
		public var layout:String;
		public var alignment:String;
		public var events:Array;
		public var anchorId:String;
		public var anchorPos:String;
		public var anchorTPos:String;
		public var anchorTarget:String;
		public var uiScaling:Number = 1.0;
		public var autoPosition:Boolean = false;

		public const designResolution:Point = new Point(1920,1080);
		
		public var mainPanel_mc:MainPanel;

		public var controlManagers:MovieClip;
		public var panels_mc:PanelManager;
		public var dropdowns_mc:DropdownManager;

		public var contextMenuMC:ContextMenuMain;
		//public var screenScaleHelper:MovieClip;
		
		public var curTooltip:String;
	  	public var hasTooltip:Boolean;
	  	public var tooltipWidthOverride:Number = 0;

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

		private static var instance:MainTimeline;

		public var inputHandlers:Array;

		public var isDragging:Boolean = false;
		
		public function MainTimeline()
		{
			super();
			Registry.Init();
			instance = this;
			this.addFrameScript(0,this.frame1);
		}

		public static function get Instance():MainTimeline
		{
			return instance;
		}

		public function addInputHandler(obj:IInputHandler) : void
		{
			this.inputHandlers.push(obj);
		}

		public function removeInputHandler(obj:IInputHandler) : void
		{
			var checkObj:IInputHandler = null;
			for (var i:uint = this.inputHandlers.length; i--;)
			{
				checkObj = this.inputHandlers[i];
				if(checkObj == obj)
				{
					this.inputHandlers.splice(i, 1);
				}
			}
		}

		public function invokeInputCallbacks(inputId:String, isUp:Boolean = false) : Boolean
		{
			var isHandled:Boolean = false;
			var handler:IInputHandler = null;
			for(var i:int = 0; i < this.inputHandlers.length; i++)
			{
				handler = this.inputHandlers[i] as IInputHandler;
				if (handler && handler.IsInputEnabled) {
					if (!isUp) {
						if (handler.OnInputDown(inputId)) {
							isHandled = true;
							break;
						}
					} else {
						if (handler.OnInputUp(inputId)) {
							isHandled = true;
							break;
						}
					}
				}
			}
			return isHandled;
		}
		
		public function onEventUp(id:Number) : Boolean
		{
			var isHandled:Boolean = false;
			var input:String = this.events[id];
			if (input != null)
			{
				Registry.ExtCall("LeaderLib_UIExtensions_InputEvent", false, input, id);
				if(isInCharacterCreation)
				{
					switch(input)
					{
						case "IE UICreationTabPrev":
							this.UICreationTabPrevPressed = false;
							break;
					}
				}
				if(!isHandled) {
					isHandled = this.invokeInputCallbacks(input, true);
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
				Registry.ExtCall("LeaderLib_UIExtensions_InputEvent", true, input, id);
				if(!controllerEnabled)
				{
					// if(!isInCharacterCreation)
					// {
					// 	switch(input)
					// 	{
					// 		case "IE UICopy":
					// 			this.CtrlDown = true;
					// 			isHandled = true;
					// 			Registry.ExtCall("LeaderLib_ToggleChainGroup");
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
				if(!isHandled) {
					isHandled = this.invokeInputCallbacks(input, false);
				}
			}

			return isHandled;
		}
		
		public function onEventInit() : void
		{
			Registry.ExtCall("registeranchorId", this.anchorId);
			Registry.ExtCall("setAnchor",this.anchorPos, this.anchorTarget, this.anchorTPos);

			this.contextMenuMC.init();
			this.contextMenuMC.playSounds = false;
		}

		public function onEventResize() : void
		{
			if (this.autoPosition) {
				Registry.ExtCall("setPosition",this.anchorPos,this.anchorTarget,this.anchorTPos);
			}
			Registry.ExtCall("LeaderLib_UIExtensions_OnEventResize");
		}

		public function onEventResolution(w:Number, h:Number) : void
		{
			this.OnRes(w,h);
		}

		public function OnRes(w:Number, h:Number) : void
		{
			if(this.screenWidth != w || this.screenHeight != h)
			{
				if (this.autoPosition) {
					Registry.ExtCall("setPosition",this.anchorPos,this.anchorTarget,this.anchorPos);
				}
				this.screenWidth = w;
				this.screenHeight = h;
				this.uiScaling = h / this.designResolution.y;
				// if(this.screenScaleHelper.visible) {
				// 	this.screenScaleHelper.scaleX = 1 + (w / this.designResolution.x);
				// 	this.screenScaleHelper.scaleY = 1 + (h / this.designResolution.y);
				// }
				Registry.ExtCall("LeaderLib_UIExtensions_OnEventResolution", w, h);
			}
		}

		public function removeControl(id:Number) : Boolean
		{
			return mainPanel_mc.removeElementWithID(id);
		}

		public function clearElements() : void 
		{
			//mainPanel_mc.list.clearElements();
			mainPanel_mc.clearElements();
		}

		public function setHasTooltip(isEnabled:Boolean, text:String = "") : void
		{
			this.hasTooltip = isEnabled;
			this.curTooltip = text;
		}

		private function onMouseOverTooltip(e:MouseEvent) : void
		{
			var obj:MovieClip = e.target as MovieClip;
			if(obj.tooltip != null && obj.tooltip != "")
			{
				var side:String = obj.tooltipSide == null ? "top" : obj.tooltipSide;
				tooltipHelper.ShowTooltipForMC(obj,this,side,this.hasTooltip == false);
				MainTimeline.Instance.setHasTooltip(true, obj.tooltip);
			}
		}

		public function onMouseOutTooltip(e:MouseEvent) : void
		{
			if(this.curTooltip == e.target.tooltip && this.hasTooltip)
			{
				Registry.ExtCall("hideTooltip");
			}
			MainTimeline.Instance.setHasTooltip(false);
		}

		public function setupControlForTooltip(obj:MovieClip) : void
		{
			obj.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverTooltip);
			obj.addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOutTooltip);
		}

		public function clearControlForTooltip(obj:MovieClip) : void
		{
			obj.removeEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverTooltip);
			obj.removeEventListener(MouseEvent.MOUSE_OUT, this.onMouseOutTooltip);
		}
		
		public function addCheckbox(id:Number, label:String, tooltip:String, stateID:Number=0, x:Number=0, y:Number=0, filterBool:Boolean = false, enabled:Boolean = true) : uint
		{
			var checkbox:Checkbox = new Checkbox();
			checkbox.x = x;
			checkbox.y = y;
			checkbox.setText(label);
			checkbox.id = id;
			checkbox.mHeight = 30;
			checkbox.filterBool = filterBool;
			checkbox.stateID = stateID;
			checkbox.tooltip = tooltip;
			checkbox.bg_mc.gotoAndStop(stateID * 3 + 1);
			checkbox.enable = enabled;
			if(enabled == false)
			{
				checkbox.alpha = 0.3;
			}
			mainPanel_mc.addElement(checkbox);
			Registry.ExtCall("LeaderLib_UIExtensions_ControlAdded", "checkbox", id, checkbox.list_id);
			return checkbox.list_id;
		}

		public function setCheckboxState(id:Number, state:Number): void
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

		public function toggleCheckbox(id:Number): void
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

		public function addBar(id:String, label:String, tooltip:String = "", x:Number=0, y:Number=0, percentage:Number = 1.0, doTween:Boolean = false, color:Number=NaN) : uint
		{
			var bar:HealthBarHolder = new HealthBarHolder();
			bar.id = id;
			bar.x = x;
			bar.y = y;
			bar.tooltip = tooltip;
			bar.setBar(percentage, doTween);
			if (!isNaN(color)) {
				bar.setBarColour(color);
			}
			//setupControlForTooltip(bar);
			var index:uint = mainPanel_mc.addElement(bar);
			Registry.ExtCall("LeaderLib_UIExtensions_ControlAdded", "bar", id, index);
			return index;
		}

		public function setBar(id:Number, percentage:Number = 1.0, doTween:Boolean = false, color:Number=NaN) : void
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

		public function setGlobalToLocalPosition(x:Number, y:Number) : void
		{
			var globalPt:Point = new Point(x,y);
			var localPt:Point = this.globalToLocal(globalPt);
			globalToLocalX = localPt.x;
			globalToLocalY = localPt.y;
		}

		public function setLocalToGlobalPosition(x:Number, y:Number) : void
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

		public function removeTimer(timer:ClientTimer, removeFromArray:Boolean = false) : void
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

		public function destroyTimers() : void 
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

		public function launchTimer(delay:Number, name:String, repeat:int=1) : void
		{
			var timer:ClientTimer = new ClientTimer(name, delay, repeat, this);
			this.timers.push(timer);
			timer.start();
		}

		public function fireOnMouseClick(e:MouseEvent) : void
		{
			Registry.ExtCall("LeaderLib_UIExtensions_MouseClicked", e.stageX, e.stageY);
			Registry.ExtCall("LeaderLib_UIExtensions_SetModifierKeys", e.shiftKey, e.altKey, e.ctrlKey);
		}
		
		public function fireOnMouseMove(e:MouseEvent) : void
		{
			Registry.ExtCall("LeaderLib_UIExtensions_MouseMoved", e.stageX, e.stageY);
			Registry.ExtCall("LeaderLib_UIExtensions_SetModifierKeys", e.shiftKey, e.altKey, e.ctrlKey);
		}

		public function onRightMouseDown(e:Event) : void
		{
			Registry.ExtCall("LeaderLib_UIExtensions_RightMouseDown", stage.mouseX, stage.mouseY);
		}

		public function onRightMouseUp(e:Event) : void
		{
			Registry.ExtCall("LeaderLib_UIExtensions_RightMouseUp", stage.mouseX, stage.mouseY);
		}

		public function fireMouseClicked(eventName:String = "") : void
		{
			Registry.ExtCall("LeaderLib_UIExtensions_MouseClicked", stage.mouseX, stage.mouseY);
		}

		public function dispose(): void
		{
			if (this.listeningForMouse) {
				stage.removeEventListener(MouseEvent.CLICK,this.fireOnMouseClick);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.fireOnMouseMove);
				this.listeningForMouse = false;
			}
			destroyTimers();
			this.disableKeyboardListeners();
		}

		public function enableMouseListeners(b:Boolean) : void {
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
				stage.addEventListener("rightMouseUp",this.onRightMouseUp);
			}
			this.listeningForMouse = b;
		}

		public function showContextMenu(b:Boolean = true, xPos:Number=-9999, yPos:Number=-9999) : void
		{
			if (b)
			{
				if(xPos == -9999) xPos = mouseX;
				if(yPos == -9999) yPos = mouseY;
				contextMenuMC.playSounds = true;
				contextMenuMC.open(mouseX, mouseY);
			}
			else
			{
				contextMenuMC.close();
				contextMenuMC.playSounds = false;
			}
		}

		private function onKeyboardDown(e:KeyboardEvent) : void
		{
			var inputName:String = workingKeys[e.keyCode];
			if(inputName != null)
			{
				Registry.ExtCall("LeaderLib_UIExtensions_KeyboardEvent", e.keyCode, inputName, true);
			}
			else
			{
				Registry.ExtCall("LeaderLib_UIExtensions_KeyboardEvent", e.keyCode, KeyCodeNames.GetName(e.keyCode), true);
			}
			Registry.ExtCall("LeaderLib_UIExtensions_SetModifierKeys", e.shiftKey, e.altKey, e.ctrlKey);
		}

		private function onKeyboardUp(e:KeyboardEvent) : void
		{
			var inputName:String = workingKeys[e.keyCode];
			if(inputName != null)
			{
				Registry.ExtCall("LeaderLib_UIExtensions_KeyboardEvent", e.keyCode, inputName, false);
			}
			else
			{
				Registry.ExtCall("LeaderLib_UIExtensions_KeyboardEvent", e.keyCode, KeyCodeNames.GetName(e.keyCode), false);
			}
			Registry.ExtCall("LeaderLib_UIExtensions_SetModifierKeys", e.shiftKey, e.altKey, e.ctrlKey);
		}

		private var workingKeys:Dictionary = new Dictionary();

		public function enableKeyboardListeners() : void
		{
			//Experimental, doesn't quite seem to work yet.
			//Registry.ExtCall("inputFocus");
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyboardDown);
			this.stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyboardUp);
			//this.stage.focus = this;
		}

		public function disableKeyboardListeners() : void
		{
			//Registry.ExtCall("inputFocusLost");
			this.stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyboardDown);
			this.stage.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyboardUp);
		}

		public function addDarkPanel(id:String, panelX:Number=0, panelY:Number=0, title:String="") : int
		{
			var panel:DraggablePanelDark = new DraggablePanelDark();
			panel.id = id;
			panel.x = panelX;
			panel.y = panelY;
			panel.init(title);
			return this.panels_mc.add(panel);
		}

		public function onContextMenuMouseOver(e:MouseEvent) : void
		{
			
		}

		private var contextMenuHoverTimer:Timer;

		public function onContextMenuMouseOut(e:MouseEvent) : void
		{
			this.contextMenuMC.closeSubmenus();
			// if (!this.contextMenuMC.isMouseHoveringAny)
			// {
			// 	this.contextMenuMC.closeSubmenus();
			// }
		}
		
		public function frame1() : void
		{
			this.anchorId = "LeaderLib_UIExtensions";
			this.anchorPos = "topleft";
			this.anchorTPos = "topleft";
			this.anchorTarget = "screen";
			this.alignment = "center";
			//fixed, fitVertical, fitHorizontal, fit, fill, fillVFit
			this.layout = "fillVFit";
			this.curTooltip = "";
		 	this.hasTooltip = false;
			this.uiScaling = 1;

			//this.stage.scaleMode = StageScaleMode.EXACT_FIT;
			//this.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE; 

			this.timers = new Array();
			this.inputHandlers = new Array();

			KeyCodeNames.Init();
			workingKeys[8] = "FlashBackspace";
			workingKeys[9] = "FlashTab";
			workingKeys[13] = "FlashEnter";
			workingKeys[17] = "FlashCtrl";
			workingKeys[18] = "FlashAlt";
			workingKeys[33] = "FlashPgUp";
			workingKeys[34] = "FlashPgDn";
			workingKeys[35] = "FlashEnd";
			workingKeys[36] = "FlashHome";
			workingKeys[37] = "FlashArrowLeft";
			workingKeys[38] = "FlashArrowUp";
			workingKeys[39] = "FlashArrowRight";
			workingKeys[40] = "FlashArrowDown";
			workingKeys[46] = "FlashDelete";

			this.screenWidth = this.width;
			this.screenHeight = this.height;

			this.contextMenuMC = new ContextMenuMain();
			this.addChild(contextMenuMC);
			this.contextMenuMC.visible = false;

			this.controlManagers = new MovieClip();
			this.addChild(controlManagers);

			this.panels_mc = new PanelManager();
			this.dropdowns_mc = new DropdownManager();

			this.controlManagers.addChild(this.dropdowns_mc);
			this.controlManagers.addChild(this.panels_mc);

			// this.screenScaleHelper.visible = true;
			// this.screenScaleHelper.alpha = 0.5;
			// this.screenScaleHelper.mouseEnabled = false;
			// this.screenScaleHelper.mouseChildren = false;
			// this.screenScaleHelper.buttonMode = false;
			// this.screenScaleHelper.enabled = false;
			// this.screenScaleHelper.doubleClickEnabled = false;
			// this.screenScaleHelper.tabEnabled = false;
			// this.screenScaleHelper.tabChildren = false;

			this.contextMenuMC.addEventListener(MouseEvent.MOUSE_OVER, this.onContextMenuMouseOver, false);
			this.contextMenuMC.addEventListener(MouseEvent.ROLL_OUT, this.onContextMenuMouseOut, false);
			
			// this.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void
			// {
			// 	trace("KEY_DOWN", e.keyCode, keyCodeNames.keyName(e.keyCode), e.altKey, e.ctrlKey, e.shiftKey);
			// });
			// this.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent):void
			// {
			// 	trace("KEY_UP", e.keyCode, keyCodeNames.keyName(e.keyCode), e.altKey, e.ctrlKey, e.shiftKey);
			// });
			
			this.events = new Array("IE Action1","IE ActionCancel","IE ActionMenu","IE AreaPickup","IE Benchmark","IE CCZoomIn","IE CCZoomOut","IE CameraBackward","IE CameraCenter","IE CameraForward","IE CameraLeft","IE CameraRight","IE CameraRotateLeft","IE CameraRotateRight","IE CameraZoomIn","IE CameraZoomOut","IE CancelSelectorMode","IE CharacterCreationAccept","IE CharacterCreationRotateLeft","IE CharacterCreationRotateRight","IE CharacterMoveBackward","IE CharacterMoveForward","IE CharacterMoveLeft","IE CharacterMoveRight","IE CloseApplication","IE Combine","IE ConnectivityMenu","IE ContextMenu","IE ControllerContextMenu","IE CycleCharactersNext","IE CycleCharactersPrev","IE DefaultCameraBackward","IE DefaultCameraCaptureInput","IE DefaultCameraFast","IE DefaultCameraForward","IE DefaultCameraFrontView","IE DefaultCameraLeft","IE DefaultCameraLeftView","IE DefaultCameraPanCamera","IE DefaultCameraRight","IE DefaultCameraRotateDown","IE DefaultCameraRotateLeft","IE DefaultCameraRotateRight","IE DefaultCameraRotateUp","IE DefaultCameraSlow","IE DefaultCameraSpecialPanCamera1","IE DefaultCameraSpecialPanCamera2","IE DefaultCameraTopView","IE DefaultCameraZoomIn","IE DefaultCameraZoomOut","IE DestructionToggle","IE DragSingleToggle","IE FlashAlt","IE FlashArrowDown","IE FlashArrowLeft","IE FlashArrowRight","IE FlashArrowUp","IE FlashBackspace","IE FlashCancel","IE FlashCtrl","IE FlashDelete","IE FlashEnd","IE FlashEnter","IE FlashHome","IE FlashPgDn","IE FlashPgUp","IE FlashScrollDown","IE FlashScrollUp","IE FlashTab","IE FreeCameraFoVDec","IE FreeCameraFoVInc","IE FreeCameraFreezeGameTime","IE FreeCameraHeightDec","IE FreeCameraHeightInc","IE FreeCameraMoveBackward","IE FreeCameraMoveForward","IE FreeCameraMoveLeft","IE FreeCameraMoveRight","IE FreeCameraRotSpeedDec","IE FreeCameraRotSpeedInc","IE FreeCameraRotateControllerDown","IE FreeCameraRotateControllerLeft","IE FreeCameraRotateControllerRight","IE FreeCameraRotateControllerUp","IE FreeCameraSlowdown","IE FreeCameraSpeedDec","IE FreeCameraSpeedInc","IE FreeCameraSpeedReset","IE GMKillResurrect","IE GMNormalAlignMode","IE GMSetHealth","IE HighlightCharacters","IE Interact","IE MoveCharacterUpInGroup","IE NextObject","IE PanelSelect","IE PartyManagement","IE Pause","IE Ping","IE PrevObject","IE QueueCommand","IE QuickLoad","IE QuickSave","IE ReloadInputConfig","IE RotateItemLeft","IE RotateItemRight","IE Screenshot","IE SelectorMoveBackward","IE SelectorMoveForward","IE SelectorMoveLeft","IE SelectorMoveRight","IE ShowChat","IE ShowSneakCones","IE ShowWorldTooltips","IE SkipVideo","IE SplitItemToggle","IE SwitchGMMode","IE ToggleCharacterPane","IE ToggleCombatMode","IE ToggleCraft","IE ToggleEquipment","IE ToggleFullscreen","IE ToggleGMInventory","IE ToggleGMItemGeneratorPane","IE ToggleGMMiniMap","IE ToggleGMMoodPanel","IE ToggleGMPause","IE ToggleGMRewardPanel","IE ToggleGMShroud","IE ToggleHomestead","IE ToggleInGameMenu","IE ToggleInfo","IE ToggleInputMode","IE ToggleInventory","IE ToggleJournal","IE ToggleManageTarget","IE ToggleMap","IE ToggleMonsterSelect","IE ToggleOverviewMap","IE TogglePartyManagement","IE TogglePresentation","IE ToggleRecipes","IE ToggleReputationPanel","IE ToggleRollPanel","IE ToggleSetStartPoint","IE ToggleSkills","IE ToggleSneak","IE ToggleSplitscreen","IE ToggleStatusPanel","IE ToggleSurfacePainter","IE ToggleTacticalCamera","IE ToggleVignette","IE UIAccept","IE UIAddPoints","IE UIAddonDown","IE UIAddonUp","IE UIBack","IE UICancel","IE UICompareItems","IE UIContextMenuModifier","IE UICopy","IE UICreateProfile","IE UICreationAddSkill","IE UICreationEditClassNext","IE UICreationEditClassPrev","IE UICreationNext","IE UICreationPrev","IE UICreationRemoveSkill","IE UICreationTabNext","IE UICreationTabPrev","IE UICut","IE UIDelete","IE UIDeleteProfile","IE UIDialogRPSPaper","IE UIDialogRPSRock","IE UIDialogRPSScissors","IE UIDialogTextDown","IE UIDialogTextUp","IE UIDown","IE UIEditCharacter","IE UIEndTurn","IE UIFilter","IE UIHotBarNext","IE UIHotBarPrev","IE UIInvite","IE UILeft","IE UIMapDown","IE UIMapLeft","IE UIMapRemoveMarker","IE UIMapReset","IE UIMapRight","IE UIMapUp","IE UIMapZoomIn","IE UIMapZoomOut","IE UIMarkWares","IE UIMessageBoxA","IE UIMessageBoxB","IE UIMessageBoxX","IE UIMessageBoxY","IE UIModNext","IE UIModPrev","IE UIPaste","IE UIRadialDown","IE UIRadialLeft","IE UIRadialRight","IE UIRadialUp","IE UIRefresh","IE UIRemoveItemSelection","IE UIRemovePoints","IE UIRename","IE UIRequestTrade","IE UIRight","IE UISelectChar1","IE UISelectChar2","IE UISelectChar3","IE UISelectChar4","IE UISelectSlot0","IE UISelectSlot1","IE UISelectSlot11","IE UISelectSlot12","IE UISelectSlot2","IE UISelectSlot3","IE UISelectSlot4","IE UISelectSlot5","IE UISelectSlot6","IE UISelectSlot7","IE UISelectSlot8","IE UISelectSlot9","IE UISend","IE UISetSlot","IE UIShowInfo","IE UIShowTooltip","IE UIStartGame","IE UISwitchDown","IE UISwitchLeft","IE UISwitchRight","IE UISwitchUp","IE UITabNext","IE UITabPrev","IE UITakeAll","IE UIToggleActions","IE UIToggleEquipment","IE UIToggleHelmet","IE UIToggleMultiselection","IE UIToggleTutorials","IE UITooltipDown","IE UITooltipUp","IE UITradeBalance","IE UITradeRemoveOffer","IE UITradeSwitchWindow","IE UIUp","IE WidgetButtonA","IE WidgetButtonBackSpace","IE WidgetButtonC","IE WidgetButtonDelete","IE WidgetButtonDown","IE WidgetButtonEnd","IE WidgetButtonEnter","IE WidgetButtonEscape","IE WidgetButtonHome","IE WidgetButtonLeft","IE WidgetButtonPageDown","IE WidgetButtonPageUp","IE WidgetButtonRight","IE WidgetButtonSpace","IE WidgetButtonTab","IE WidgetButtonUp","IE WidgetButtonV","IE WidgetButtonX","IE WidgetButtonY","IE WidgetButtonZ","IE WidgetScreenshot","IE WidgetScreenshotVideo","IE WidgetScrollDown","IE WidgetScrollUp","IE WidgetToggleDebugConsole","IE WidgetToggleDevComments","IE WidgetToggleEffectStats","IE WidgetToggleGraphicsDebug","IE WidgetToggleHierarchicalProfiler","IE WidgetToggleOptions","IE WidgetToggleOutput","IE WidgetToggleStats");
		}
	}
}