if SheetManager == nil then
	---@class SheetManager
	SheetManager = {}
end

---@alias SHEET_ENTRY_ID string
---@alias OnSheetEntryValueChangedCallback fun(id:string, stat:CustomStatData, character:EsvCharacter, previousPoints:integer, currentPoints:integer, isClientSide:boolean):void

SheetManager.__index = SheetManager
SheetManager.Loaded = false
local isClient = Ext.IsClient()


SheetManager.Listeners = {
	---@type table<string, OnSheetEntryValueChangedCallback[]>
	OnValueChanged = {All = {}},
	Loaded = {},
}

local self = SheetManager

---@private
function SheetManager:RegisterListener(tbl, callback, key)
	if callback == nil then
		return
	end
	local t = type(key)
	if t == "table" then
		for i=1,#key do
			self:RegisterListener(tbl, callback, key[i])
		end
	elseif t == "number" or t == "string" then
		if tbl[key] == nil then
			tbl[key] = {}
		end
		table.insert(tbl[key], callback)
	elseif key == nil then
		table.insert(tbl, callback)
	end
end

---@param callback fun(self:SheetManager):void
function SheetManager:RegisterLoadedListener(callback)
	self:RegisterListener(self.Listeners.Loaded, callback)
end

---@param id string|string[]|number|number[]
---@param callback OnSheetEntryValueChangedCallback
function SheetManager:RegisterValueChangedListener(id, callback)
	if StringHelpers.Equals(id, "All", true) then
		id = "All"
	end
	self:RegisterListener(self.Listeners.OnValueChanged, callback, id)
end

---@type table<SHEET_ENTRY_ID,table<UUID|NETID, integer|boolean>>
SheetManager.CurrentValues = {}
if not isClient then
	local Handler = {
		__index = function(tbl,k)
			return PersistentVars.CharacterSheetValues[k]
		end,
		__newindex = function(tbl,k,v)
			PersistentVars.CharacterSheetValues[k] = v
		end
	}
	setmetatable(SheetManager.CurrentValues, Handler)
end

---@type table<MOD_UUID, table<SHEET_ENTRY_ID, SheetEntryData>>
SheetManager.Entries = {}

---@type fun():table<string, table<string, SheetAbilityData|SheetTalentData|SheetStatData>>
local loader = Ext.Require("Shared/System/SheetManager/ConfigLoader.lua")
--Ext.Require("Shared/System/SheetManager/DataSync.lua")
--Ext.Require("Shared/System/SheetManager/Getters.lua")
--Ext.Require("Shared/System/SheetManager/PointsHandler.lua")

local function LoadData()
	local b,entries = xpcall(loader, debug.traceback)
	if b and entries then
		TableHelpers.AddOrUpdate(SheetManager.Entries, entries)
	else
		Ext.PrintError(entries)
	end

	SheetManager.Talents.LoadRequirements()

	--SheetManager.Talents.HideTalent("LoneWolf", ModuleUUID)

	if isClient then
		---Divine Talents
		if Ext.IsModLoaded("ca32a698-d63e-4d20-92a7-dd83cba7bc56") or GameSettings.Settings.Client.DivineTalentsEnabled then
			SheetManager.Talents.ToggleDivineTalents(true)
		end
	end

	SheetManager.Loaded = true
	InvokeListenerCallbacks(SheetManager.Listeners.Loaded, SheetManager)
end

if not isClient then
	RegisterListener("Initialized", LoadData)
else
	Ext.RegisterListener("SessionLoaded", LoadData)
	--Ext.Require("Shared/System/SheetManager/UI/_Init.lua")
end