if Debug == nil then
	Debug = {}
end

---@type UIListenerWrapper[]
local allListeners = {}
---@type table<integer,UIListenerWrapper>
local typeListeners = {}

Ext.RegisterConsoleCommand("uilogging", function(cmd, enabled)
	for i,v in pairs(allListeners) do
		if enabled == "false" then
			v.Enabled = false
		else
			v.Enabled = true
		end
	end
end)

---@class UIListenerWrapper
local UIListenerWrapper = {
	Type = "UIListenerWrapper",
	Name = "",
	Calls = {},
	Methods = {},
	ID = -1,
	Enabled = false,
	CustomCallback = {},
}
UIListenerWrapper.__index = UIListenerWrapper

Debug.UIListenerWrapper = UIListenerWrapper

local lastEvent = "";

---@param self UIListenerWrapper
---@param ui UIObject
local function OnUIListener(self, eventType, ui, event, ...)
	if self.Enabled and Vars.DebugMode and (Vars.Print.UI or Vars.LeaderDebugMode) and not self.Ignored[event] then
		if event == "addTooltip" then
			local txt = table.unpack({...})
			if string.find(txt, "Experience:", 1, true) then
				return
			end
		elseif lastEvent == event and Ext.GetGameState() ~= "Running" then
			return
		end
		if self.PrintParams then
			fprint(LOGLEVEL.TRACE2, "[%s(%s)][%s] [%s] %s(%s)", self.Name, ui:GetTypeId(), eventType, Ext.MonotonicTime(), event, StringHelpers.DebugJoin(", ", {...}))
		else
			fprint(LOGLEVEL.TRACE2, "[%s(%s)] [%s] %s [%s]", self.Name, ui:GetTypeId(), eventType, event, Ext.MonotonicTime())
		end

		if self.CustomCallback[event] then
			self.CustomCallback[event](self, ui, event, ...)
		end

		lastEvent = event
	end
end

local deferredRegistrations = {}

function UIListenerWrapper:Create(id, params)
	local this = {
		ID = id,
		Enabled = UIListenerWrapper.Enabled,
		CustomCallback = {},
		PrintParams = true,
		Initialized = nil,
		Ignored = {}
	}

	if params and type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end

	if type(id) == "string" then
		local ui = Ext.GetBuiltinUI(id)

		if not ui then
			deferredRegistrations[id] = this
		else
			if this.Initialized then
				local b,err = xpcall(this.Initialized, debug.traceback, ui)
				if not b then
					Ext.PrintError(err)
				end
			end
		end
	else
		if type(id) == "table" then
			for k,id2 in pairs(id) do
				this.Name = Data.UITypeToName[id2] or ""

				if this.Initialized then
					local ui = Ext.GetBuiltinUI(id2)
					if ui then
						local b,err = xpcall(this.Initialized, debug.traceback, ui)
						if not b then
							Ext.PrintError(err)
						end
					end
				end
			end
		else
			this.Name = Data.UITypeToName[id] or ""
			if this.Initialized then
				local ui = Ext.GetUIByType(id)
				if ui then
					local b,err = xpcall(this.Initialized, debug.traceback, ui)
					if not b then
						Ext.PrintError(err)
					end
				end
			end
		end
	end

	setmetatable(this, UIListenerWrapper)

	allListeners[#allListeners+1] = this
	typeListeners[this.ID] = this

	return this
end

local defaultIgnored = {
	hideTooltip = true,
	PlaySound = true,
	dollOut = true,
	slotUp = true,
	update = true,
	updateStatuses = true,
	removeLabel = true,
	LeaderLib_UIExtensions_InputEvent = true,
	setAllSlotsEnabled = true,
	setButtonEnable = true,
	updateSlotData = true,
	updateSlots = true,
	showExpTooltip = true,
	SlotHoverOut = true,
}

Ext.RegisterListener("UICall", function(ui, event, ...)
	if defaultIgnored[event] then
		return
	end
	local t = ui:GetTypeId()
	local listener = typeListeners[t]
	if listener then
		OnUIListener(listener, "call", ui, event, ...)
	end
end)

Ext.RegisterListener("UIInvoke", function(ui, event, ...)
	if defaultIgnored[event] then
		return
	end
	local t = ui:GetTypeId()
	local listener = typeListeners[t]
	if listener then
		OnUIListener(listener, "method", ui, event, ...)
	end
end)

---@param ui UIObject
Ext.RegisterListener("UIObjectCreated", function(ui)
	for path,data in pairs(deferredRegistrations) do
		local ui2 = Ext.GetBuiltinUI(path)
		if ui2 and (ui2:GetTypeId() == ui:GetTypeId() or ui == ui2) then
			data:RegisterListeners(ui)
			deferredRegistrations[path] = nil
			if data.Initialized then
				local b,err = xpcall(this.Initialized, debug.traceback, ui)
				if not b then
					Ext.PrintError(err)
				end
			end
		end
	end
end)

local enabledParam = {Enabled=true}

local enemyHealthBar = UIListenerWrapper:Create(Data.UIType.enemyHealthBar)
local worldTooltip = UIListenerWrapper:Create(Data.UIType.worldTooltip)
local examine = UIListenerWrapper:Create(Data.UIType.examine)
local characterCreation = UIListenerWrapper:Create(Data.UIType.characterCreation, enabledParam)
local characterSheetDebug = UIListenerWrapper:Create(Data.UIType.characterSheet, enabledParam)
local partyInventory = UIListenerWrapper:Create(Data.UIType.partyInventory, enabledParam)
local pyramid = UIListenerWrapper:Create(Data.UIType.pyramid, enabledParam)

characterCreation.CustomCallback.updateContent = function(self, ui, method)
	local this = ui:GetRoot()
	if this then
		local content = {}
		for i=0,#this.contentArray-1 do
			content[#content+1] = this.contentArray[i]
		end
		Ext.SaveFile("ConsoleDebug/characterCreation_updateContent.lua", TableHelpers.ToString(content))
	end
end

local printArrays = {
	"lvlBtnAbility_array",
	"lvlBtnStat_array",
	"lvlBtnTalent_array",
	"lvlBtnSecStat_array",
}

-- characterSheetDebug.CustomCallback.updateArraySystem = function(self, ui, method)
-- 	local this = ui:GetRoot()
-- 	for _,arrName in pairs(printArrays) do
-- 		local array = this[arrName]
-- 		if array and #array > 0 then
-- 			for i=0,#array-1 do
-- 				print(arrName, i, array[i])
-- 			end
-- 		end
-- 	end
-- end

local statsPanelDebug = UIListenerWrapper:Create(Data.UIType.statsPanel_c)
statsPanelDebug.CustomCallback["updateArraySystem"] = function(self, ui, method)
	local arr = ui:GetRoot().customStats_array
	if arr then
		local length = #arr
		PrintDebug("customStats_array", length)
		if length > 0 then
			for i=0,length do
			PrintDebug(i, arr[i])
			end
		end
	end
end

local playerInfo = UIListenerWrapper:Create(Data.UIType.playerInfo, {Enabled=true, Ignored={updateStatuses=true}})
local tooltipMain = UIListenerWrapper:Create(Data.UIType.tooltip)
local contextMenu = UIListenerWrapper:Create(Data.UIType.contextMenu)

---@param ui UIObject
contextMenu.CustomCallback["updateButtons"] = function(self, ui, method)
	local this = ui:GetRoot()
	PrintDebug("windowsMenu_mc", this.windowsMenu_mc.x, this.windowsMenu_mc.y)
	PrintDebug("stage", this.x, this.y)
	local arr = this.buttonArr
	if arr then
		local length = #arr
		PrintDebug("buttonArr", length)
		if length > 0 then
			for i=0,length do
				PrintDebug(i, arr[i])
			end
		end
	end
end

local hotbar = UIListenerWrapper:Create(Data.UIType.hotBar)
hotbar.Enabled = true
--[[
---@param ui UIObject
hotbar.CustomCallback["updateSlotData"] = function(self, ui, method)
	local this = ui:GetRoot()
	local array = this.slotUpdateDataList
	for i=0,#array-1 do
		local entry = array[i]
		if entry then
			PrintDebug(i, entry)
		else
			PrintDebug(i, "nil")
		end
	end
end

---@param ui UIObject
hotbar.CustomCallback["updateSlots"] = function(self, ui, method)
	local this = ui:GetRoot()
	local array = this.slotUpdateList
	for i=0,#array do
		local entry = array[i]
		if entry then
			PrintDebug(i, entry)
		else
			PrintDebug(i, "nil")
		end
	end
end
]]

--"Public/Game/GUI/dialog.swf"
local dialog = UIListenerWrapper:Create(Data.UIType.dialog)
local possessionBar = UIListenerWrapper:Create(Data.UIType.possessionBar)
local gmPanelHUD = UIListenerWrapper:Create(Data.UIType.GMPanelHUD)
local statusConsole = UIListenerWrapper:Create(Data.UIType.statusConsole)
local areaInteract_c = UIListenerWrapper:Create(Data.UIType.areaInteract_c)
local journal_csp = UIListenerWrapper:Create(Data.UIType.journal_csp)
local skills = UIListenerWrapper:Create(Data.UIType.skills)
local mainMenu = UIListenerWrapper:Create(Data.UIType.mainMenu)

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

local combatLog = UIListenerWrapper:Create(Data.UIType.combatLog, enabledParam)
local GMPanelHUD = UIListenerWrapper:Create(Data.UIType.GMPanelHUD,{
	---@param ui UIObject
	Initialized = function(ui)
		Ext.PrintError("GMPANELHUD")
		local this = ui:GetRoot()
		if this then
			local printArr = function(name, arr)
				PrintDebug(name, #arr)
				for i=0,#arr-1 do
					PrintDebug(name, i, arr[i].id)
				end
			end
			local arr = this.GMBar_mc.slotList.content_array
			printArr("GMBar_mc", this.GMBar_mc.slotList.content_array)
			printArr("targetBar_mc", this.targetBar_mc.slotList.content_array)
			printArr("secActionList", this.secActionList.content_array)
		end
	end
})
GMPanelHUD.Enabled = true

local roll = UIListenerWrapper:Create(Data.UIType.roll, {
	---@param ui UIObject
	Initialized = function(ui)
		Ext.PrintError("roll")
		local this = ui:GetRoot()
		if this then
			this.setIsGM(Client.Character.IsGameMaster)
		end
	end
})
roll.Enabled = true
roll.CustomCallback["updateRolls"] = function(self, ui, call, b)
	local this = ui:GetRoot()
	this.ownerCharacter = Ext.HandleToDouble(Client:GetCharacter().Handle)
	this.isGM = Client.Character.IsGameMaster
	this.Initialize()
end

--local char = Mods.LeaderLib.GameHelpers.Client.GetGMTargetCharacter(); local movement = {}; for i,v in ipairs(char.Stats.DynamicStats) do if v.Movement > 0 then table.insert(movement, {Index=i, Value=v.Movement}); end end print(Mods.LeaderLib.Lib.serpent.block(movement))