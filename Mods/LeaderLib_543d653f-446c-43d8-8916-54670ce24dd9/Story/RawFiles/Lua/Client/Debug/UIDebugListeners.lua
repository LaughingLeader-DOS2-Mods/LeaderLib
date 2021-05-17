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
		if self.PrintParams then
			fprint(LOGLEVEL.TRACE, "[UI:%s(%s)] [%s] %s [%s]\n%s", self.Name, ui:GetTypeId(), eventType, event, Ext.MonotonicTime(), Common.Dump({...}))
		else
			fprint(LOGLEVEL.TRACE, "[UI:%s(%s)] [%s] %s [%s]", self.Name, ui:GetTypeId(), eventType, event, Ext.MonotonicTime())
		end

		if self.CustomCallback[event] then
			self.CustomCallback[event](self, ui, event, ...)
		end
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

	if type(id) == "table" then
		for k,id2 in pairs(id) do
			for _,v in pairs(this.Calls) do
				Ext.RegisterUITypeCall(id2, v, function(...)
					OnUIListener(this, "call", ...)
				end)
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
			end)
		end
	
		for _,v in pairs(this.Methods) do
			Ext.RegisterUITypeInvokeListener(id, v, function(...)
				OnUIListener(this, "method", ...)
			end)
		end

		this.Name = Data.UITypeToName[id] or ""
	end

	setmetatable(this, UIListenerWrapper)

	return this
end

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

local tooltipCalls = {
	"keepUIinScreen",
	"setTooltipSize",
}

local tooltipMethods = {
	"setGroupLabel",
	"setWindow",
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
}

--local tooltipDebug = UIListenerWrapper:Create(Data.UIType.tooltip, tooltipCalls, tooltipMethods)
-- tooltipDebug.CustomCallback["addFormattedTooltip"] = function(self, ui, call, ...)
-- 	local main = ui:GetRoot()
-- 	for i=0,#main.tooltip_array do
-- 		local obj = main.tooltip_array[i]
-- 		if obj then
-- 			print(i, obj)
-- 		end
-- 	end
-- end

local sheetCalls = {
	"showTooltip",
	"showStatusTooltip",
	"showItemTooltip",
}

local sheetMethods = {

}

local characterSheetDebug = UIListenerWrapper:Create(Data.UIType.characterSheet, sheetCalls, sheetMethods)

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
tooltipMain.PrintParams = false
tooltipMain.Enabled = false

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

local contextMenu = UIListenerWrapper:Create(Data.UIType.skills, {}, {
	"updateSkills",
})

---@param ui UIObject
-- contextMenu.CustomCallback["updateSkills"] = function(self, ui, method, b)
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

local hotbar = UIListenerWrapper:Create(Data.UIType.hotBar, {}, {
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
hotbar.Enabled = false

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