---@class FlagData
local FlagData = {
	Type = "FlagData",
	Flag = "",
	FlagType = "Global",
	Target = ""
}

FlagData.__index = FlagData

---@param flag string
---@param flagType string Global|User|Character
function FlagData:Create(flag, flagType)
    local this =
    {
		Flag = flag or "",
		FlagType = flagType or "Global",
		Target = ""
	}
	setmetatable(this, self)
    return this
end

---@class VariableData
local VariableData = {
	Type = "VariableData",
	Name = "",
	Value = "",
	Target = "",
	VarType = "",
}

VariableData.__index = VariableData

---@param name string
---@param value string|integer|number|number[]
---@param varType string string|integer|float|float3
function VariableData:Create(name, value, varType)
    local this =
    {
		Name = name or "",
		Value = value or "",
		VarType = varType or "",
		Target = ""
	}
	setmetatable(this, self)
    return this
end

---@class SettingsData
local SettingsData = {
	Type = "SettingsData",
	---@type table<string, FlagData>
	Flags = {},
	---@type table<string, VariableData>
	Variables = {}
}

SettingsData.__index = SettingsData

function SettingsData:Create()
    local this =
    {
		Flags = {},
		Variables = {}
	}
	setmetatable(this, self)
    return this
end

---@class ProfileSettings
local ProfileSettings = {
	Type = "ProfileSettings",
	ID = "",
	---@type SettingsData
	Settings = nll
}

ProfileSettings.__index = ProfileSettings

---@param id string
---@param settings SettingsData|nil
function ProfileSettings:Create(id, settings)
    local this =
    {
		ID = id,
		Settings = settings or SettingsData:Create()
	}
	setmetatable(this, self)
    return this
end

---@class ModSettings
local ModSettings = {
	Type = "ModSettings",
	UUID = "",
	Name = "",
	---@type table<string, ProfileSettings>
	Profiles = {},
	---@type SettingsData
	Global = nil
}

ModSettings.__index = ModSettings

---@param uuid string The mod's UUID.
---@param name string The mod's name, used for reference.
function ModSettings:Create(uuid, name)
    local this =
    {
		UUID = uuid,
		Name = name,
		Profiles = {},
		Global = SettingsData:Create()
	}
	setmetatable(this, self)
    return this
end

---@param id string The profile id.
---@param settings SettingsData
---@param overwriteExisting boolean
function ModSettings:AddProfile(id, settings, overwriteExisting)
	if self.Profiles[id] == nil then
		self.Profiles[id] = ProfileSettings:Create(id, settings)
	elseif overwriteExisting == true then
		self.Profiles[id].Settings = settings
	end
end