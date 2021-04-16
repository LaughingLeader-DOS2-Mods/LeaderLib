package
{
	import fl.motion.Color;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import Controls.Checkbox;
	import flash.events.TimerEvent;
	import flash.events.Event;
	
	public dynamic class MainTimeline extends MovieClip
	{		
		public var layout:String;
		public var events:Array;
		public var mainPanel_mc:MovieClip;
		
		public var curTooltip:String;
	  	public var hasTooltip:Boolean;

	  	public var controllerEnabled:Boolean = false;
		public var UICreationTabPrevPressed:Boolean = false;
		public var isInCharacterCreation:Boolean = false;

		public var timers:Array;
		
		public function MainTimeline()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onEventUp(id:Number) : *
		{
			ExternalInterface.call("LeaderLib_InputEvent", false, this.events[id], id);
			if(isInCharacterCreation)
			{
				switch(this.events[id])
				{
					case "IE UICreationTabPrev":
						this.UICreationTabPrevPressed = false;
						break;
				}
			}
			return false;
		}
		
		public function onEventDown(id:Number) : Boolean
		{
			ExternalInterface.call("LeaderLib_InputEvent", true, this.events[id], id);
			if(controllerEnabled && isInCharacterCreation)
			{
				var isHandled:Boolean = false;
				switch(this.events[id])
				{
					case "IE UICreationTabPrev":
						this.UICreationTabPrevPressed = true;
						break;
					case "IE ConnectivityMenu":
						// Prevents "ConnectivityMenu" from opening the connectivity menu in CC if UICreationTabPrevPressed is held
						isHandled = this.UICreationTabPrevPressed;
						break;
				}
				return isHandled;
			}
			return false;
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

		public function removeControl(id:Number): Boolean
		{
			return mainPanel_mc.removeElementWithID(id);
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
			//mainPanel_mc.list.addElement(checkbox);
			mainPanel_mc.addElement(checkbox);
			checkbox.label_bg_mc.width = (checkbox.label_txt.textWidth*1.2) + 12;
			//this.mainPanel_mc.addChild(checkbox);
			//checkbox.formHL_mc.alpha = 0;
			ExternalInterface.call("LeaderLib_ControlAdded", "checkbox", checkbox.id, id, checkbox.label_txt.textWidth, checkbox.label_txt.width, checkbox.label_bg_mc.width);
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

		public function clearElements() : * 
		{
			//mainPanel_mc.list.clearElements();
			mainPanel_mc.clearElements();
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
		
		function frame1() : *
		{
			this.layout = "fixed";
			//this.events = new Array("IE UICreationTabPrev", "IE UIStartGame", "IE ConnectivityMenu");
			this.curTooltip = "";
		 	this.hasTooltip = false;
			this.mousEnabled = false;
			this.timers = new Array();
			this.events = new Array("IE Action1","IE Action2","IE Action3","IE ActionCancel","IE ActionMenu","IE AreaPickup","IE Benchmark","IE CCZoomIn","IE CCZoomOut","IE CameraBackward","IE CameraCenter","IE CameraForward","IE CameraLeft","IE CameraRight","IE CameraRotateLeft","IE CameraRotateMouseLeft","IE CameraRotateMouseRight","IE CameraRotateRight","IE CameraToggleMouseRotate","IE CameraZoomIn","IE CameraZoomOut","IE CancelSelectorMode","IE CharacterCreationAccept","IE CharacterCreationRotateLeft","IE CharacterCreationRotateRight","IE CharacterMoveBackward","IE CharacterMoveForward","IE CharacterMoveLeft","IE CharacterMoveRight","IE CloseApplication","IE Combine","IE ConnectivityMenu","IE ContextMenu","IE ControllerContextMenu","IE CycleCharactersNext","IE CycleCharactersPrev","IE DefaultCameraBackward","IE DefaultCameraCaptureInput","IE DefaultCameraFast","IE DefaultCameraForward","IE DefaultCameraFrontView","IE DefaultCameraLeft","IE DefaultCameraLeftView","IE DefaultCameraMouseDown","IE DefaultCameraMouseLeft","IE DefaultCameraMouseRight","IE DefaultCameraMouseUp","IE DefaultCameraPanCamera","IE DefaultCameraRight","IE DefaultCameraRotateDown","IE DefaultCameraRotateLeft","IE DefaultCameraRotateRight","IE DefaultCameraRotateUp","IE DefaultCameraSlow","IE DefaultCameraSpecialPanCamera1","IE DefaultCameraSpecialPanCamera2","IE DefaultCameraToggleMouseRotation","IE DefaultCameraTopView","IE DefaultCameraZoomIn","IE DefaultCameraZoomOut","IE DestructionToggle","IE DragSingleToggle","IE FlashAlt","IE FlashArrowDown","IE FlashArrowLeft","IE FlashArrowRight","IE FlashArrowUp","IE FlashBackspace","IE FlashCancel","IE FlashCtrl","IE FlashDelete","IE FlashEnd","IE FlashEnter","IE FlashHome","IE FlashLeftMouse","IE FlashMiddleMouse","IE FlashPerfmonButton1","IE FlashPerfmonButton2","IE FlashPerfmonButton3","IE FlashPerfmonButton4","IE FlashPerfmonDown","IE FlashPerfmonLShoulder","IE FlashPerfmonLTrigger","IE FlashPerfmonLeft","IE FlashPerfmonRShoulder","IE FlashPerfmonRTrigger","IE FlashPerfmonRight","IE FlashPerfmonUp","IE FlashPgDn","IE FlashPgUp","IE FlashRightMouse","IE FlashScrollDown","IE FlashScrollUp","IE FlashTab","IE FreeCameraFoVDec","IE FreeCameraFoVInc","IE FreeCameraFreezeGameTime","IE FreeCameraHeightDec","IE FreeCameraHeightInc","IE FreeCameraMoveBackward","IE FreeCameraMoveForward","IE FreeCameraMoveLeft","IE FreeCameraMoveRight","IE FreeCameraRotSpeedDec","IE FreeCameraRotSpeedInc","IE FreeCameraRotateControllerDown","IE FreeCameraRotateControllerLeft","IE FreeCameraRotateControllerRight","IE FreeCameraRotateControllerUp","IE FreeCameraRotateMouseDown","IE FreeCameraRotateMouseLeft","IE FreeCameraRotateMouseRight","IE FreeCameraRotateMouseUp","IE FreeCameraSlowdown","IE FreeCameraSpeedDec","IE FreeCameraSpeedInc","IE FreeCameraSpeedReset","IE FreeCameraToggleMouseRotate","IE GMKillResurrect","IE GMNormalAlignMode","IE GMSetHealth","IE HighlightCharacters","IE Interact","IE LinkDevice","IE MoveCharacterUpInGroup","IE NextObject","IE PanelSelect","IE PartyManagement","IE Pause","IE Ping","IE PrevObject","IE QueueCommand","IE QuickLoad","IE QuickSave","IE ReloadInputConfig","IE RotateItemLeft","IE RotateItemRight","IE Screenshot","IE SelectorMoveBackward","IE SelectorMoveForward","IE SelectorMoveLeft","IE SelectorMoveRight","IE ShowChat","IE ShowSneakCones","IE ShowWorldTooltips","IE SkipVideo","IE SplitItemToggle","IE SwitchGMMode","IE ToggleCharacterPane","IE ToggleCombatMode","IE ToggleCraft","IE ToggleEquipment","IE ToggleFullscreen","IE ToggleGMInventory","IE ToggleGMItemGeneratorPane","IE ToggleGMMiniMap","IE ToggleGMMoodPanel","IE ToggleGMPause","IE ToggleGMRewardPanel","IE ToggleGMShroud","IE ToggleHomestead","IE ToggleInGameMenu","IE ToggleInfo","IE ToggleInputMode","IE ToggleInventory","IE ToggleJournal","IE ToggleManageTarget","IE ToggleMap","IE ToggleMonsterSelect","IE ToggleOverviewMap","IE TogglePartyManagement","IE TogglePause","IE TogglePresentation","IE ToggleRecipes","IE ToggleReputationPanel","IE ToggleRollPanel","IE ToggleSetStartPoint","IE ToggleSkills","IE ToggleSneak","IE ToggleSplitscreen","IE ToggleStatusPanel","IE ToggleSurfacePainter","IE ToggleTacticalCamera","IE ToggleVignette","IE UIAccept","IE UIAddPoints","IE UIAddonDown","IE UIAddonUp","IE UIBack","IE UICancel","IE UICompareItems","IE UIContextMenuModifier","IE UICopy","IE UICreateProfile","IE UICreationAddSkill","IE UICreationEditClassNext","IE UICreationEditClassPrev","IE UICreationNext","IE UICreationPrev","IE UICreationRemoveSkill","IE UICreationTabNext","IE UICreationTabPrev","IE UICut","IE UIDelete","IE UIDeleteProfile","IE UIDialogRPSPaper","IE UIDialogRPSRock","IE UIDialogRPSScissors","IE UIDialogTextDown","IE UIDialogTextUp","IE UIDown","IE UIEditCharacter","IE UIEndTurn","IE UIFilter","IE UIHotBarNext","IE UIHotBarPrev","IE UIInvite","IE UILeft","IE UIMapDown","IE UIMapLeft","IE UIMapRemoveMarker","IE UIMapReset","IE UIMapRight","IE UIMapUp","IE UIMapZoomIn","IE UIMapZoomOut","IE UIMarkWares","IE UIMessageBoxA","IE UIMessageBoxB","IE UIMessageBoxX","IE UIMessageBoxY","IE UIModNext","IE UIModPrev","IE UIPaste","IE UIRPSAutoResolve","IE UIRadialDown","IE UIRadialLeft","IE UIRadialRight","IE UIRadialUp","IE UIRefresh","IE UIRemoveItemSelection","IE UIRemovePoints","IE UIRename","IE UIRequestTrade","IE UIRight","IE UISelectChar1","IE UISelectChar2","IE UISelectChar3","IE UISelectChar4","IE UISelectSlot0","IE UISelectSlot1","IE UISelectSlot11","IE UISelectSlot12","IE UISelectSlot2","IE UISelectSlot3","IE UISelectSlot4","IE UISelectSlot5","IE UISelectSlot6","IE UISelectSlot7","IE UISelectSlot8","IE UISelectSlot9","IE UISend","IE UISetSlot","IE UIShowInfo","IE UIShowTooltip","IE UIStartGame","IE UISwitchDown","IE UISwitchLeft","IE UISwitchRight","IE UISwitchUp","IE UITabNext","IE UITabPrev","IE UITakeAll","IE UIToggleActions","IE UIToggleEquipment","IE UIToggleHelmet","IE UIToggleMultiselection","IE UIToggleTutorials","IE UITooltipDown","IE UITooltipUp","IE UITradeBalance","IE UITradeConfirmOffer","IE UITradeMarkOffer","IE UITradeRemoveOffer","IE UITradeSwitchWindow","IE UIUp","IE WidgetButtonA","IE WidgetButtonBackSpace","IE WidgetButtonC","IE WidgetButtonDelete","IE WidgetButtonDown","IE WidgetButtonEnd","IE WidgetButtonEnter","IE WidgetButtonEscape","IE WidgetButtonHome","IE WidgetButtonLeft","IE WidgetButtonPageDown","IE WidgetButtonPageUp","IE WidgetButtonRight","IE WidgetButtonSpace","IE WidgetButtonTab","IE WidgetButtonUp","IE WidgetButtonV","IE WidgetButtonX","IE WidgetButtonY","IE WidgetButtonZ","IE WidgetMouseLeft","IE WidgetMouseMotion","IE WidgetMouseRight","IE WidgetScreenshot","IE WidgetScreenshotVideo","IE WidgetScrollDown","IE WidgetScrollUp","IE WidgetSliderDecrease","IE WidgetSliderIncrease","IE WidgetToggleDebugConsole","IE WidgetToggleDevComments","IE WidgetToggleEffectStats","IE WidgetToggleGraphicsDebug","IE WidgetToggleHierarchicalProfiler","IE WidgetToggleOptions","IE WidgetToggleOutput","IE WidgetToggleStats");
		}
	}
}