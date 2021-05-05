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
local function OnUIListener(self, ui, event, ...)
	if self.Enabled then
		fprint(LOGLEVEL.TRACE, "[UI:%s(%s)] %s(%s)", self.Name, ui:GetTypeId(), event, Common.Dump({...}))

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
		CustomCallback = {}
	}

	this.Name = Data.UITypeToName[id] or ""

	setmetatable(this, UIListenerWrapper)

	for _,v in pairs(this.Calls) do
		Ext.RegisterUITypeCall(id, v, function(...)
			OnUIListener(this, ...)
		end)
	end

	for _,v in pairs(this.Methods) do
		Ext.RegisterUITypeInvokeListener(id, v, function(...)
			OnUIListener(this, ...)
		end)
	end

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

UIListenerWrapper:Create(Data.UIType.examine, examineCalls, examineMethods)

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