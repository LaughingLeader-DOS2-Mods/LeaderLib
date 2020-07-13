---An item boost to be used with NRD_ItemCloneAddBoost.
---@class DeltaModEntry
local DeltaModEntry = {
	Type = "DeltaModEntry",
	SlotType = "",
	WeaponType = "",
	TwoHanded = "",
	Boost = "",
	MinLevel = -1,
	MaxLevel = -1,
	Chance = 100
}
DeltaModEntry.__index = DeltaModEntry

---@param deltaMod DeltaModEntry
---@param vars table
local function SetVars(deltaMod, vars)
	if vars ~= nil then
		if vars.Type ~= nil then deltaMod.Type = vars.Type end
		if vars.MinLevel ~= nil then deltaMod.MinLevel = vars.MinLevel end
		if vars.MaxLevel ~= nil then deltaMod.MaxLevel = vars.MaxLevel end
		if vars.Chance ~= nil then deltaMod.Chance = vars.Chance end
		if vars.SlotType ~= nil then deltaMod.SlotType = vars.SlotType end
		if vars.TwoHanded ~= nil then deltaMod.TwoHanded = vars.TwoHanded end
		if vars.WeaponType ~= nil then deltaMod.WeaponType = vars.WeaponType end
	end
end

---@param boost string
---@param vars table
---@return DeltaModEntry
function DeltaModEntry:Create(boost, vars)
    local this =
    {
		Boost = boost,
		Type = "DeltaModEntry",
		MinLevel = -1,
		MaxLevel = -1,
		Chance = 100
	}
	setmetatable(this, self)
	SetVars(this, vars)
    return this
end

Classes["DeltaModEntry"] = DeltaModEntry
--local DeltaModEntry = Classes["DeltaModEntry"]

---A container for multiple DeltaModEntry entries.
---@class DeltaModEntryGroup
local DeltaModEntryGroup = {
	Entries = {}
}
DeltaModEntryGroup.__index = DeltaModEntryGroup

---@param entries table
---@param vars table
---@return DeltaModEntryGroup
function DeltaModEntryGroup:Create(entries, vars)
    local this =
    {
		Entries = entries
	}
	setmetatable(this, self)
	if vars ~= nil then
		for i,v in pairs(this.Entries) do
			SetVars(v, vars)
		end
	end
    return this
end

---@return table
function DeltaModEntryGroup:GetRandomEntry()
    return Common.GetRandomTableEntry(self.Entries)
end
Classes["DeltaModEntryGroup"] = DeltaModEntryGroup