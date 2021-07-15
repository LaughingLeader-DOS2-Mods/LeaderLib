if SheetManager == nil then
	---@class SheetManager
	SheetManager = {}
end

---@alias SHEET_ENTRY_ID string
---@alias OnSheetEntryValueChangedCallback fun(id:string, stat:CustomStatData, character:EsvCharacter, previousPoints:integer, currentPoints:integer, isClientSide:boolean):void

SheetManager.__index = SheetManager
SheetManager.Loaded = false
local isClient = Ext.IsClient()

Ext.Require("Shared/System/SheetManager/Data/SheetDataValues.lua")

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

SheetManager.Data = {
	---@type table<MOD_UUID, table<SHEET_ENTRY_ID, SheetAbilityData>>
	Abilities = {},
	---@type table<MOD_UUID, table<SHEET_ENTRY_ID, SheetTalentData>>
	Talents = {},
	---@type table<MOD_UUID, table<SHEET_ENTRY_ID, SheetStatData>>
	Stats = {},
	ID_MAP = {
		Abilities = {
			NEXT_ID = 1999,
			---@type table<integer, SheetAbilityData>
			Entries = {}
		},
		---@type table<integer, SheetTalentData>
		Talents = {
			NEXT_ID = 1999,
			Entries = {}
		},
		---@type table<integer, SheetTalentData>
		Stats = {
			NEXT_ID = 1999,
			Entries = {}
		},
	}
}

---@type fun():table<string, table<string, SheetAbilityData|SheetTalentData|SheetStatData>>
local loader = Ext.Require("Shared/System/SheetManager/ConfigLoader.lua")
--Ext.Require("Shared/System/SheetManager/DataSync.lua")
--Ext.Require("Shared/System/SheetManager/Getters.lua")
--Ext.Require("Shared/System/SheetManager/PointsHandler.lua")

local function LoadData()
	local b,data = xpcall(loader, debug.traceback)
	if b and data then
		for uuid,entryData in pairs(data) do
			if not SheetManager.Data.Abilities[uuid] then
				SheetManager.Data.Abilities[uuid] = {}
			end
			if not SheetManager.Data.Talents[uuid] then
				SheetManager.Data.Talents[uuid] = {}
			end
			if not SheetManager.Data.Stats[uuid] then
				SheetManager.Data.Stats[uuid] = {}
			end
			if data.Abilities then
				TableHelpers.AddOrUpdate(SheetManager.Data.Abilities[uuid], data.Abilities)
			end
			if data.Talents then
				TableHelpers.AddOrUpdate(SheetManager.Data.Talents[uuid], data.Talents)
			end
			if data.Stats then
				TableHelpers.AddOrUpdate(SheetManager.Data.Stats[uuid], data.Stats)
			end
		end
		
	else
		Ext.PrintError(data)
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