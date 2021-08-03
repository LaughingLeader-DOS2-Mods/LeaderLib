SheetManager.Listeners = {
	Loaded = {},
	---@type table<string, OnSheetStatChangedCallback|OnSheetAbilityChangedCallback|OnSheetTalentChangedCallback[]>
	OnEntryChanged = {All = {}},
	---@type table<string, OnSheetCanAddStatCallback|OnSheetCanAddAbilityCallback|OnSheetCanAddTalentCallback[]>
	CanAdd = {All = {}},
	---@type table<string, OnSheetCanRemoveStatCallback|OnSheetCanRemoveAbilityCallback|OnSheetCanRemoveTalentCallback[]>
	CanRemove = {All = {}},
}

local self = SheetManager
local isClient = Ext.IsClient()

---@alias OnSheetStatChangedCallback fun(id:string, stat:SheetStatData, character:EsvCharacter, lastValue:integer, value:integer, isClientSide:boolean):void
---@alias OnSheetAbilityChangedCallback fun(id:string, stat:SheetAbilityData, character:EsvCharacter, lastValue:integer, value:integer, isClientSide:boolean):void
---@alias OnSheetTalentChangedCallback fun(id:string, stat:SheetTalentData, character:EsvCharacter, lastValue:boolean, value:boolean, isClientSide:boolean):void

---@alias OnSheetCanAddStatCallback fun(id:string, stat:SheetStatData, character:EsvCharacter, currentValue:integer, canAdd:boolean):boolean
---@alias OnSheetCanAddAbilityCallback fun(id:string, stat:SheetAbilityData, character:EsvCharacter, currentValue:integer, canAdd:boolean):boolean
---@alias OnSheetCanAddTalentCallback fun(id:string, stat:SheetTalentData, character:EsvCharacter, currentValue:boolean, canAdd:boolean):boolean

---@alias OnSheetCanRemoveStatCallback fun(id:string, stat:SheetStatData, character:EsvCharacter, currentValue:integer, canRemove:boolean):boolean
---@alias OnSheetCanRemoveAbilityCallback fun(id:string, stat:SheetAbilityData, character:EsvCharacter, currentValue:integer, canRemove:boolean):boolean
---@alias OnSheetCanRemoveTalentCallback fun(id:string, stat:SheetTalentData, character:EsvCharacter, currentValue:boolean, canRemove:boolean):boolean

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

---Generic version for stat/ability/talent entries.
---@param id string|string[]|number|number[]
---@param callback OnSheetStatChangedCallback|OnSheetAbilityChangedCallback|OnSheetTalentChangedCallback
function SheetManager:RegisterEntryChangedListener(id, callback)
	if StringHelpers.Equals(id, "All", true) then
		id = "All"
	end
	self:RegisterListener(self.Listeners.CanAdd, callback, id)
end

---Called when a registered stat changes.
---Use this vs. RegisterEntryChangedListener for stat-related auto-completion.
---@param id string|string[]|number|number[]
---@param callback OnSheetStatChangedCallback
function SheetManager:RegisterStatChangedListener(id, callback)
	if StringHelpers.Equals(id, "All", true) then
		id = "All"
	end
	self:RegisterEntryChangedListener(id, callback)
end

---Called when a registered ability changes.
---Use this vs. RegisterEntryChangedListener for ability-related auto-completion.
---@param id string|string[]|number|number[]
---@param callback OnSheetAbilityChangedCallback
function SheetManager:RegisterAbilityChangedListener(id, callback)
	if StringHelpers.Equals(id, "All", true) then
		id = "All"
	end
	self:RegisterEntryChangedListener(id, callback)
end

---Called when a registered talent changes.
---Use this vs. RegisterEntryChangedListener for talent-related auto-completion.
---@param id string|string[]|number|number[]
---@param callback OnSheetTalentChangedCallback
function SheetManager:RegisterTalentChangedListener(id, callback)
	if StringHelpers.Equals(id, "All", true) then
		id = "All"
	end
	self:RegisterEntryChangedListener(id, callback)
end

---@param id string|string[]|number|number[]
---@param callback OnSheetCanAddStatCallback|OnSheetCanAddAbilityCallback|OnSheetCanAddStatCallback
function SheetManager:RegisterCanAddListener(id, callback)
	if StringHelpers.Equals(id, "All", true) then
		id = "All"
	end
	self:RegisterListener(self.Listeners.CanAdd, callback, id)
end

---@param id string|string[]|number|number[]
---@param callback OnSheetCanAddStatCallback|OnSheetCanAddAbilityCallback|OnSheetCanAddStatCallback
function SheetManager:RegisterCanRemoveListener(id, callback)
	if StringHelpers.Equals(id, "All", true) then
		id = "All"
	end
	self:RegisterListener(self.Listeners.CanRemove, callback, id)
end

if Vars.DebugMode then
	SheetManager:RegisterEntryChangedListener("All", function(id, entry, character, lastValue, value, isClientSide)
		fprint(LOGLEVEL.TRACE, "[SheetManager:EntryChanged] id(%s) character(%s) lastValue(%s) value(%s) [%s]\n%s", id, character, lastValue, value, isClientSide, isClientSide and "CLIENT" or "SERVER", Lib.inspect(entry))
	end)
	SheetManager:RegisterCanAddListener("All", function(id, entry, character, current, b)
		return true
	end)
	SheetManager:RegisterCanRemoveListener("All", function(id, entry, character, current, b)
		return true
	end)
end

---@param character EclCharacter
---@param entry SheetStatData|SheetAbilityData|SheetTalentData
---@param defaultValue boolean
---@param entryValue integer|boolean|nil The entry's current value. Provide one here to skip having to retrieve it.
function SheetManager:GetIsPlusVisible(character, entry, defaultValue, entryValue)
	if defaultValue == nil then
		defaultValue = false
	end
	if entryValue == nil then
		entryValue = entry:GetValue(character)
	end
	local bResult = defaultValue
	for listener in self:GetListenerIterator(self.Listeners.CanAdd[entry.ID], self.Listeners.CanAdd.All) do
		local b,result = xpcall(listener, debug.traceback, entry.ID, entry, character, entryValue, bResult)
		if not b then
			fprint(LOGLEVEL.ERROR, "[LeaderLib.SheetManager:GetIsPlusVisible] Error calling CanAdd listener for entry (%s):\n%s", entry.ID, result)
		elseif result ~= nil then
			bResult = result
		end
	end
	return bResult
end

---@param character EclCharacter
---@param entry SheetStatData|SheetAbilityData|SheetTalentData
---@param defaultValue boolean
---@param entryValue integer|boolean|nil The entry's current value. Provide one here to skip having to retrieve it.
function SheetManager:GetIsMinusVisible(character, entry, defaultValue, entryValue)
	if defaultValue == nil then
		defaultValue = false
	end
	if entryValue == nil then
		entryValue = entry:GetValue(character)
	end
	local bResult = defaultValue
	for listener in self:GetListenerIterator(self.Listeners.CanRemove[entry.ID], self.Listeners.CanRemove.All) do
		local b,result = xpcall(listener, debug.traceback, entry.ID, entry, character, entryValue, bResult)
		if not b then
			fprint(LOGLEVEL.ERROR, "[LeaderLib.SheetManager:GetIsMinusVisible] Error calling CanRemove listener for entry (%s):\n%s", entry.ID, result)
		elseif result ~= nil then
			bResult = result
		end
	end
	return bResult
end