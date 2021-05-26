---@class UIListenerWrapper
local UIListenerWrapper = {
	Type = "UIListenerWrapper",
	Name = "",
	Calls = {},
	Methods = {},
	ID = -1,
	Enabled = true,
	CustomCallback = {},
}
UIListenerWrapper.__index = UIListenerWrapper

---@param self UIListenerWrapper
---@param ui UIObject
local function OnUIListener(self, eventType, ui, event, ...)
	if self.Enabled then
		if event == "addTooltip" then
			local txt = table.unpack({...})
			if string.find(txt, "Experience:", 1, true) then
				return
			end
		end
		if self.PrintParams then
			fprint(LOGLEVEL.TRACE, "[UI:%s(%s)][%s] [%s] %s(%s)", self.Name, ui:GetTypeId(), eventType, Ext.MonotonicTime(), event, StringHelpers.DebugJoin(", ", {...}))
		else
			fprint(LOGLEVEL.TRACE, "[UI:%s(%s)] [%s] %s [%s]", self.Name, ui:GetTypeId(), eventType, event, Ext.MonotonicTime())
		end

		if self.CustomCallback[event] then
			self.CustomCallback[event](self, ui, event, ...)
		end
	end
end

local deferredRegistrations = {}

function UIListenerWrapper:RegisterListeners(ui)
	for _,v in pairs(self.Calls) do
		Ext.RegisterUICall(ui, v, function(...)
			OnUIListener(self, "call", ...)
		end)
	end
	
	for _,v in pairs(self.Methods) do
		Ext.RegisterUIInvokeListener(ui, v, function(...)
			OnUIListener(self, "method", ...)
		end)
	end
end

function UIListenerWrapper:Create(id, calls, methods)
	local this = {
		ID = id,
		Calls = calls or {},
		Methods = methods or {},
		Enabled = true,
		CustomCallback = {},
		PrintParams = true
	}

	if type(id) == "string" then
		local ui = Ext.GetBuiltinUI(id)

		if not ui then
			deferredRegistrations[id] = this
		else
			for _,v in pairs(this.Calls) do
				Ext.RegisterUICall(ui, v, function(...)
					OnUIListener(this, "call", ...)
				end, "Before")
			end
		
			for _,v in pairs(this.Methods) do
				Ext.RegisterUIInvokeListener(ui, v, function(...)
					OnUIListener(this, "method", ...)
				end)
			end
		end
	else
		if type(id) == "table" then
			for k,id2 in pairs(id) do
				for _,v in pairs(this.Calls) do
					Ext.RegisterUITypeCall(id2, v, function(...)
						OnUIListener(this, "call", ...)
					end, "Before")
				end
			
				for _,v in pairs(this.Methods) do
					Ext.RegisterUITypeInvokeListener(id2, v, function(...)
						OnUIListener(this, "method", ...)
					end)
				end
				this.Name = Data.UITypeToName[id2] or ""
			end
		else
			for _,v in pairs(this.Calls) do
				Ext.RegisterUITypeCall(id, v, function(...)
					OnUIListener(this, "call", ...)
				end, "Before")
			end
		
			for _,v in pairs(this.Methods) do
				Ext.RegisterUITypeInvokeListener(id, v, function(...)
					OnUIListener(this, "method", ...)
				end)
			end
	
			this.Name = Data.UITypeToName[id] or ""
		end
	end

	setmetatable(this, UIListenerWrapper)

	return this
end

---@param ui UIObject
Ext.RegisterListener("UIObjectCreated", function(ui)
	for path,data in pairs(deferredRegistrations) do
		local ui2 = Ext.GetBuiltinUI(path)
		if ui2 and (ui2:GetTypeId() == ui:GetTypeId() or ui == ui2) then
			data:RegisterListeners(ui)
			deferredRegistrations[path] = nil
		end
	end
end)

local enemyHealthBar = UIListenerWrapper:Create(Data.UIType.enemyHealthBar, {"hideTooltip"}, {"clearTweens","setHPBars","setHPColour","setArmourBar","setArmourBarColour","setMagicArmourBar","setMagicArmourBarColour","setText","requestAnchorCombatTurn","requestAnchorScreen","show","hide","hideHPMC","updateStatuses","setStatus","cleanupStatuses","clearStatusses","setIggyImage","removeChildrenOf"})
enemyHealthBar.Enabled = false

local worldTooltipMethods = {
	"updateTooltips",
	"setObjPos",
	"setTooltip",
	"setWindow",
	"setControllerMode",
	"removeNotUpdatedTooltips",
	"showTooltipLong",
	"removeTooltipLong",
	"removeTooltip",
	"clearAll",
	"removedTooltipMc",
	"getTooltip",
	"checkBoundaries",
	"checkTooltipBoundaries",
	"setToTop",
	"noOverlapAll",
	"cheaperCollisionCheck",
}

local worldTooltipCalls = {
	"tooltipClicked",
	"tooltipOver",
	"tooltipOut",
	"hideTooltip",
	"showItemTooltip",
	"showTooltip",
	"showStatusTooltip",
	"startDragging",
}

UIListenerWrapper:Create(Data.UIType.worldTooltip, worldTooltipCalls, worldTooltipMethods)

local examineCalls = {
	"cancelDragging",
	"cancelMoveWindow",
	"hideTooltip",
	"hideUI",
	--"PlaySound",
	"setPosition",
	"showItemTooltip",
	"showStatusTooltip",
	"showTooltip",
	"showUserInfo",
	"startMoveWindow",
}

local examineMethods = {
	"start",
	"setAnchor",
	"clearTooltip",
	"setText",
	"setPlayerProfile",
	"showPortrait",
	"addStat",
	"addTitle",
	"update",
	"updateStatusses",
	"addStatus",
	"setStatusTitle",
	"clearPanel",
	"selectStat",
	"addBtnHint",
	"clearBtnHints",
	"getGlobalPositionOfMC",
	"showTooltipForMC",
	"startsWith",
}

local examine = UIListenerWrapper:Create(Data.UIType.examine, examineCalls, examineMethods)
examine.Enabled = false

local characterSheetDebug = UIListenerWrapper:Create(Data.UIType.characterSheet, {
	"cancelDragging",
	"cancelMoveWindow",
	"centerCamOnCharacter",
	"changeSecStat",
	"closeCharacterUIs",
	"createCustomStat",
	"dollDown",
	"dollOut",
	"dollUp",
	"doubleClickItem",
	"dragSkill",
	"editCustomStat",
	"getItemList",
	"getStats",
	"hideTooltip",
	"hideUI",
	"inputFocus",
	"inputFocusLost",
	"onClearInventory",
	"onGenerateTreasure",
	"openContextMenu",
	--"PlaySound",
	"removeCustomStat",
	"renameCharacter",
	"rowsChanged",
	"selectAI",
	"selectAlignment",
	"selectCharacter",
	"selectedTab",
	"selectOption",
	"setHelmetOption",
	"setPosition",
	"showItemTooltip",
	"showSkillTooltip",
	"showStatusTooltip",
	"showCustomStatTooltip",
	"showTooltip",
	"slotDown",
	"slotOut",
	"slotOver",
	"slotUp",
	"startDragging",
	"startMoveWindow",
	"stopDragging",
	"stopDraggingEquipment",
	"stopDraggingOnChar",
	"UIAssert",
	"UnlearnSkill",
	"createCustomStatGroups",
}, {
	"addAbility",
	"addAbilityGroup",
	"addGoldWeight",
	"addPrimaryStat",
	"addSecondaryStat",
	"addSpacing",
	"addTag",
	"addTalent",
	"addText",
	"addTitle",
	"addVisual",
	"addVisualOption",
	"clearAbilities",
	"clearSecondaryStats",
	"clearStats",
	"clearTags",
	"clearTalents",
	"closeDropLists",
	"cycleCharList",
	"getGlobalPositionOfMC",
	"GMShowTargetSkills",
	"hideLevelUpAbilityButtons",
	"hideLevelUpStatButtons",
	"hideLevelUpTalentButtons",
	"onBtnClearInventory",
	"onBtnGenerateStock",
	"onChangeGenerationLevel",
	"onOpenDropList",
	"onSelectGenerationRarity",
	"onSelectTreasure",
	"onWheel",
	"pointsTextfieldChanged",
	"resetSkillDragging",
	"selectAI",
	"selectAllignment",
	"selectCharacter",
	"setAbilityMinusVisible",
	"setAbilityPlusVisible",
	"setActionsDisabled",
	"setAvailableCivilAbilityPoints",
	"setAvailableCombatAbilityPoints",
	"setAvailableLabels",
	"setAvailableStatPoints",
	"setAvailableTalentPoints",
	"setGameMasterMode",
	"setGenerationRarity",
	"setHelmetOptionState",
	"setHelmetOptionTooltip",
	"setPanelTitle",
	"setPlayerInfo",
	"setPossessedState",
	"setStatMinusVisible",
	"setStatPlusVisible",
	"setTalentMinusVisible",
	"setTalentPlusVisible",
	"setText",
	"setTitle",
	"setupRarity",
	"setupSecondaryStatsButtons",
	"setupStrings",
	"setupTreasures",
	"showAcceptAbilitiesAcceptButton",
	"showAcceptStatsAcceptButton",
	"showAcceptTalentAcceptButton",
	"ShowItemEquipAnim",
	"ShowItemUnEquipAnim",
	"showTooltipForMC",
	"startsWith",
	"updateAIList",
	"updateAllignmentList",
	"updateArraySystem",
	"updateCharList",
	"updateInventory",
	"updateItems",
	"updateSkills",
	"updateVisuals",
})

local sheetCalls = {
	"addPoints",
	"disablePointsAssign",
	"enablePointsAssign",
	"hideTooltip",
	"hideUI",
	"inputFocus",
	"inputFocusLost",
	"registerAnchorId",
	"removePoints",
	"selectAbility",
	"selectCustomStat",
	"selectedAttribute",
	"selectStat",
	"selectStatsTab",
	"selectStatus",
	"selectTag",
	"selectTalent",
	"setAnchor",
	"showEquipment",
	"showInventory",
	"showSkills",
	"showStatTooltip",
	"showAbilityTooltip",
	"showItemTooltip",
	"showCustomStatTooltip",
	"showTooltip",
	"showStatusTooltip",
	"showTalentTooltip",
}

local sheetMethods = {
	"setPanelTitle",
	"setAnchor",
	"setPlayer",
	"setHLOnRT",
	"setHLOnLT",
	"clearTooltip",
	"enableTooltip",
	"setTooltip",
	"showTooltip",
	"setText",
	"resetReputationPos",
	"addBtnHint",
	"clearBtnHints",
	"showPanel",
	"addInfoStat",
	"setInfoStatValue",
	"addInfoStatSpacing",
	"clearInfoStats",
	"setExperience",
	"setNextLevelStats",
	"setStatPoints",
	"showBreadcrumb",
	"setPointAssignMode",
	"selectTab",
	"updateStatuses",
	"selectFirstStatus",
	"setStatus",
	"clearStatuses",
	"updateArraySystem",
	"setAmountOfPlayers",
	"addAbility",
	"removeAbilities",
	"addAbilityGroup",
	"addTalent",
	"removeTalents",
	"addTag",
	"addCustomStat",
	"clearCustomStats",
	"clearTags",
	"addStatsTab",
	"removeStatsTabs",
	"selectStatsTab",
	"setMainInfoStats",
	"setAttribute",
	"setAttributeLabel",
	"setActionsDisabled",
	"startsWith",		
}

local statsPanelDebug = UIListenerWrapper:Create(Data.UIType.statsPanel_c, sheetCalls, sheetMethods)
statsPanelDebug.CustomCallback["updateArraySystem"] = function(self, ui, method)
	local arr = ui:GetRoot().customStats_array
	if arr then
		local length = #arr
		print("customStats_array", length)
		if length > 0 then
			for i=0,length do
				print(i, arr[i])
			end
		end
	end
end

local playerInfo = UIListenerWrapper:Create(Data.UIType.playerInfo, {
	"anchorSet",
	"centerCamOnCharacter",
	"charSel",
	"hideTooltip",
	"hidetooltip",
	"onCharOut",
	"onCharOver",
	"openCharInventory",
	"piAddFrontOfGroup",
	"piAddToGroupUnder",
	"piDetachOnTop",
	"piDetachUnder",
	--"PlaySound",
	"registerAnchorId",
	"setAnchor",
	"showCharTooltip",
	"showItemTooltip",
	"showRollTooltip",
	"showStatusTooltip",
	"showTooltip",
	"stopDragging",
	--"UIAssert",
}, {

	"addInfo",
	"addLinkers",
	"addRoll",
	"addRollResult",
	"addSummonInfo",
	"alphaResetPIs",
	"cleanupAllStatuses",
	"cleanupStatuses",
	"cleanupStatusesMC",
	"clearAllLinkers",
	"clearAllLinkPieces",
	"clearRolls",
	"dcTEnded",
	"fadeOutStatusComplete",
	"getClosestPlayer",
	"getGlobalPositionOfMC",
	"getObjectbyPlayerId",
	"getPlayerAbove",
	"getPlayerInfo",
	"getPlayerInfoByHandle",
	"getPlayerOrSummonByHandle",
	"handleItemTransferAnims",
	"onPIDragging",
	"playerInfoJumpBack",
	"playerInfoJumpBack2",
	"positionSummons",
	"removeAllInfos",
	"removeChildrenOf",
	"removeInfo",
	"removeSummonInfo",
	"reorderlist",
	"repositionPI",
	"repositionPIWider",
	"resetHPColour",
	"selectPlayer",
	"set isGMState",
	"setAllowMouseClicking",
	"setAmountOfPlayers",
	"setAnchor",
	"setArmourBar",
	"setArmourBarColour",
	"setControlledCharacter",
	"setControllerMode",
	"setCurrentActionState",
	"setDefaultHPColour",
	"setDisabled",
	"setEquipState",
	"setGUIStatus",
	"setGUIStatusLabel",
	"setHighlight",
	"setHPBar",
	"setHPColour",
	"setIggyImage",
	"setIsDead",
	"setLeft",
	"setLevelUp",
	"setMagicArmourBar",
	"setMagicArmourBarColour",
	"setMCCurrentActionState",
	"setMCEquipState",
	"setMCGUIStatus",
	"setMCLevelUp",
	"setSourcePoints",
	"setStatus",
	"setSummonTurnText",
	"setSummonTurnTextMC",
	"setTooltips",
	"setVisible",
	"showItemTransferAnim",
	"showStatusTooltipForMC",
	"showTooltipForMC",
	"startDragging",
	"startsWith",
	"stopDragging",
	"updateDone",
	"updateInfos",
	--"updateStatuses",
})
playerInfo.Enabled = true

local tooltipMain = UIListenerWrapper:Create(Data.UIType.tooltip, {
	"setTooltipSize",
	"keepUIinScreen",
	"inputFocus",
	"inputFocusLost",
	"setAnchor",
	"clearAnchor",
}, {
	"setGroupLabel",
	"setWindow",
	"onEventInit",
	"onEventResize",
	"strReplace",
	"traceArray",
	"addFormattedTooltip",
	"addStatusTooltip",
	"addTooltip",
	"swapCompare",
	"showFormattedTooltipAfterPos",
	"setCompare",
	"addCompareTooltip",
	"addCompareOffhandTooltip",
	"INTshowTooltip",
	"onShowCompareTooltip",
	"startModeTimer",
	"resetTooltipMode",
	"onMove",
	"INTRemoveTooltip",
	"removeTooltip",
	"fadeOutTooltip",
	"checkTooltipBoundaries",
	"getTooltipHeight",
	"getTooltipWidth",
})
--tooltipMain.PrintParams = true
tooltipMain.Enabled = true

-- tooltipMain.CustomCallback["addTooltip"] = function(ui, call, text, ...)

-- end

--Ext.RegisterUINameInvokeListener("addTooltip", function (ui, call, ...)
-- Ext.RegisterUINameCall("keepUIinScreen", function (ui, call, ...)
-- 	local this = ui:GetRoot()
-- 	if this and this.tf then
-- 		this.tf.shortDesc = "Replaced"
-- 		this.tf.text_txt.htmlText = "Replaced"
-- 		--this.tf.setText("Replaced",1)
-- 		--print(call, this.tf.text_txt.htmlText, Ext.MonotonicTime())
-- 	end
-- end)

local contextMenu = UIListenerWrapper:Create(Data.UIType.contextMenu, {
	"buttonPressed",
	"menuClosed",
	"PreviousContext",
	"NextContext",
	"setHeight",
}, {
	"addButton",
	"addButtonsDone",
	"clearButtons",
	"close",
	"getList",
	"next",
	"onCloseUI",
	"onWheel",
	"open",
	"previous",
	"removeChildrenOf",
	"resetSelection",
	"selectButton",
	"setIggyImage",
	"setPos",
	"setText",
	"setTitle",
	"updateButtons",
})

---@param ui UIObject
contextMenu.CustomCallback["updateButtons"] = function(self, ui, method)
	local this = ui:GetRoot()
	print("windowsMenu_mc", this.windowsMenu_mc.x, this.windowsMenu_mc.y)
	print("stage", this.x, this.y)
	local arr = this.buttonArr
	if arr then
		local length = #arr
		print("buttonArr", length)
		if length > 0 then
			for i=0,length do
				print(i, arr[i])
			end
		end
	end
end

local hotbar = UIListenerWrapper:Create(Data.UIType.hotBar, {
	"cancelDragging",
	"CombatLogBtnPressed",
	"hideTooltip",
	"hotbarBtnPressed",
	"inputFocus",
	"inputFocusLost",
	"nextHotbar",
	--"PlaySound",
	"prevHotbar",
	"registerAnchorId",
	"setAnchor",
	"setHotbarLocked",
	"showCharTooltip",
	"showExpTooltip",
	"showItemTooltip",
	"showLockTut",
	"showSkillTooltip",
	"showStatusTooltip",
	"showTooltip",
	"SlotHover",
	"SlotHoverOut",
	"SlotPressed",
	"slotUpEnd",
	"startDragging",
	"startDraggingAction",
	"stopDragging",
	"ToggleChatLog",
	"UIAssert",
	"updateSlots",
	"useAction",
}, {
	"allowActionsButton",
	"clearAll",
	"resizeExpBar",
	"setActionPreview",
	"setActionSkillHolderVisible",
	"setAllSlotsEnabled",
	"setAllText",
	"setButton",
	"setButtonActive",
	"setButtonDisabled",
	"setCurrentHotbar",
	"setExp",
	"setFixedBtnTooltips",
	"setHotbarLocked",
	"setLockBtnTooltips",
	"setLockButtonEnabled",
	"setPlayerHandle",
	"setText",
	"showActiveSkill",
	"showSkillBar",
	"toggleActionSkillHolder",
	"updateActionSkills",
	--"updateSlotData",
	--"updateSlots",
})
hotbar.Enabled = true

-- ---@param ui UIObject
-- hotbar.CustomCallback["updateSlotData"] = function(self, ui, method)
-- 	local this = ui:GetRoot()
-- 	local array = this.slotUpdateDataList
-- 	for i=0,#array do
-- 		local entry = array[i]
-- 		if entry then
-- 			print(i, entry)
-- 		else
-- 			print(i, "nil")
-- 		end
-- 	end
-- end

-- ---@param ui UIObject
-- hotbar.CustomCallback["updateSlots"] = function(self, ui, method)
-- 	local this = ui:GetRoot()
-- 	local array = this.slotUpdateList
-- 	for i=0,#array do
-- 		local entry = array[i]
-- 		if entry then
-- 			print(i, entry)
-- 		else
-- 			print(i, "nil")
-- 		end
-- 	end
-- end

--"Public/Game/GUI/dialog.swf"
local dialog = UIListenerWrapper:Create(Data.UIType.dialog, {
	"hideTooltip",
	"inputFocus",
	"inputFocusLost",
	"QuestionPressed",
	"registerAnchorId",
	"selectedId",
	"setPosition",
	"showItemTooltip",
	"showStatusTooltip",
	"showTooltip",
	"StopListening",
	"toggleInv",
	"TradeButtonPressed",
}, {
	"addAnswerHolder",
	"addAnswers",
	"addAnswersDone",
	"addKeywordAnswer",
	"addText",
	"chooseAnswer",
	"clearAll",
	"clearAnswers",
	"clearTexts",
	"disableRPSButtons",
	"discussionCountDownStart",
	"discussionShowBattle",
	"enableRPSButtons",
	"executeSelected",
	"getHeight",
	"getWidth",
	"hideDialog",
	"hideDiscussion",
	"hideWin",
	"highlightAnswer",
	"moveSelection",
	"removeAnswerHolder",
	"resetSelection",
	"setAlternativeScrollMode",
	"setAnchorId",
	"setDiscussionCounterText",
	"setDiscussionLabels",
	"setDiscussionLabelVisible",
	"setDiscussionPlayer",
	"setDiscussionPlayerGainsPoints",
	"setDiscussionPlayersPoints",
	"setDiscussionWaitingTextVisible",
	"setInvButtonKeyTooltip",
	"setPlayerWonText",
	"setStopListenBtnVisible",
	"setTradeBtnDisabled",
	"setTradeBtnTooltip",
	"setTradeBtnVisible",
	"setWaitingText",
	"setWaitingTextVisible",
	"setX",
	"setY",
	"showBufferedAnswer",
	"showDialog",
	"showDiscussion",
	"showWin",
	"skipDiscussionAnimation",
	"startsWith",
	"updateDialog",
})
dialog.Enabled = false

local possessionBar = UIListenerWrapper:Create(Data.UIType.possessionBar, {
	"centerCamOnCharacter",
	"charSel",
	"hideTooltip",
	"onCharOut",
	"onCharOver",
	"registerAnchorId",
	"setAnchor",
	"showHealthTooltip",
	"showItemTooltip",
	"showStatusTooltip",
	"showTooltip",
	"stopDragging",
	"toggleSkills",
	"UIAssert",
}, {
	"addInfo",
	"addSummonInfo",
	"centerPositions",
	"cleanupAllStatuses",
	"cleanupStatuses",
	"cleanupStatusesMC",
	"enabledPlayerButtons",
	"getPlayerInfo",
	"getPlayerInfoByHandle",
	"getPlayerOrSummonByHandle",
	"removeAllInfos",
	"removeChildrenOf",
	"removeInfo",
	"reorderlist",
	"repositionPI",
	"resetHPColour",
	"selectPlayer",
	"setActiveInCombat",
	"setAllowMouseClicking",
	"setArmourBar",
	"setArmourBarColour",
	"setControlledCharacter",
	"setControllerMode",
	"setCurrentActionState",
	"setDefaultHPColour",
	"setDisabled",
	"setEquipState",
	"setGold",
	"setGUIStatusLabel",
	"setHighlight",
	"setHPBar",
	"setHPColour",
	"setIggyImage",
	"setLevelUp",
	"setMagicArmourBar",
	"setMagicArmourBarColour",
	"setMCEquipState",
	"setMinified",
	"setMPBar",
	"setSourcePoints",
	"setStatus",
	"setSummonTurnText",
	"setTooltips",
	"setVisible",
	"showPlayerButtons",
	"showStatusTooltipForMC",
	"showTooltipForMC",
	"updateDone",
	"updateStatuses",
})

local gmPanelHUD = UIListenerWrapper:Create(Data.UIType.GMPanelHUD, {
	"addSticky",
	"buttonCallback_",
	"cancelDragging",
	"centerCharacter",
	"hideTooltip",
	--"PlaySound",
	"playSound",
	"possess",
	"registerAnchorId",
	"setPosition",
	"showCharTooltip",
	"showItemTooltip",
	"showStatusTooltip",
	"showTooltip",
	"stopDragOnPanel",
	"toggleStickiesPanel",
	"UIAssert",
}, {
	"addCompareOffhandTooltip",
	"addCompareTooltip",
	"addFormattedTooltip",
	"addStatusTooltip",
	"addTooltip",
	"checkTooltipBoundaries",
	"fadeOutTooltip",
	"getTooltipHeight",
	"getTooltipWidth",
	"INTRemoveTooltip",
	"INTshowTooltip",
	"onMove",
	"onShowCompareTooltip",
	"removeTooltip",
	"resetTooltipMode",
	"setCompare",
	"setGroupLabel",
	"setWindow",
	"showFormattedTooltipAfterPos",
	"startModeTimer",
	"strReplace",
	"swapCompare",
	"traceArray",
})

local statusConsole = UIListenerWrapper:Create(Data.UIType.statusConsole, {
	"animDone",
	"BackToGMPressed",
	"EndButtonPressed",
	"FleePressed",
	"GuardPressed",
	"hideTooltip",
	"registerAnchorId",
	"setAnchor",
	"showItemTooltip",
	"showStatusTooltip",
	"showTooltip",
	"UIAssert",
}, {

	"backToGM",
	"executeCachedHealth",
	"INTStopNotifTweens",
	"onIcoDown",
	"onIcoOut",
	"onIcoOver",
	"resetHPColour",
	"setActiveAp",
	"setAvailableAp",
	"setBonusAP",
	"setBtnDisabled",
	"setBtnText",
	"setBtnTooltip",
	"setBtnVisible",
	"setCombatTurnNotification",
	"setGreyAP",
	"setHealth",
	"setHPColour",
	"setMaxAp",
	"setOverrideEndTurn",
	"setSourcePoints",
	"setTurnTimer",
	"showNotification",
	"showTooltipForMC",
	"TurnNoticeAnimDone",
	"updateArmourBar",
	"yourTurnAnimation",
})

local skills = UIListenerWrapper:Create(Data.UIType.skills, {
	"cancelDragging",
	"cantUnlearn",
	"createHoverIcon",
	"dragActivate",
	"exclusiveFilter",
	"filterOnType",
	"hideTooltip",
	"hideUI",
	"inputFocus",
	"inputFocusLost",
	"registerAnchorId",
	"setAnchor",
	"showAllFilters",
	"showItemTooltip",
	"showSkillTooltip",
	"showStatusTooltip",
	"showTooltip",
	"startDragging",
	"stopDragging",
	"UIAssert"
}, {
	"addFilter",
	"clearDragging",
	"forceUpdate",
	"hideMemoryHighlight",
	"hideSkillPreview",
	"hideTooltip",
	"onTooltipTimerComplete",
	"resetFilters",
	"selectAllFilters",
	"selectSkillByID",
	"setButtonText",
	"setMemoryText",
	"setPlayer",
	"setPlayerMemory",
	"setTitle",
	"showMemoryHighlight",
	"showSkillPreview",
	"showTooltip",
	"updateCooldowns",
	"updateMemory",
	"updateMemoryHighlight",
	"updateSkills",
})

---@param ui UIObject
-- skills.CustomCallback["updateSkills"] = function(self, ui, method, b)
-- 	local this = ui:GetRoot()
-- 	local array = this.skillsUpdateList
-- 	for i=0,#array do
-- 		local entry = array[i]
-- 		if entry then
-- 			print(i, entry)
-- 			if type(entry) == "string" then
-- 				local stat = Ext.GetStat(entry)
-- 				if stat then
-- 					this.skillsUpdateList[i] = "Projectile_Fireball"
-- 				end
-- 			end
-- 		else
-- 			print(i, "nil")
-- 		end
-- 	end
-- end