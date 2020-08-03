---@class FlagData
local FlagData = {
	Type = "FlagData",
	Flag = "",
	FlagType = "Global",
	Target = nil,
	Enabled = false
}

FlagData.__index = FlagData

---@param flag string
---@param flagType string Global|User|Character
function FlagData:Create(flag, flagType)
    local this =
    {
		Flag = flag or "",
		FlagType = flagType or "Global",
		Enabled = false
	}
	if Ext.OsirisIsCallable() and this.FlagType == "Global" then
		this.Enabled = GlobalGetFlag(flag) == 1
	end
	setmetatable(this, self)
    return this
end

---@class VariableData
local VariableData = {
	Type = "VariableData",
	Name = "",
	Value = "",
	Target = nil,
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
		VarType = varType or type(varType)
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

---@param flags table<string, FlagData>
---@param variables table<string, VariableData>
function SettingsData:Create(flags, variables)
    local this =
    {
		Flags = flags or {},
		Variables = variables or {}
	}
	setmetatable(this, self)
    return this
end

---@param flag string
---@param flagType string Global|User|Character
function SettingsData:AddFlag(flag, flagType)
	if self.Flags[flag] == nil then
		local flagVar = FlagData:Create(flag, flagType)
		self.Flags[flag] = flagVar
	end
end

---@param name string
---@param value string|integer|number|number[]
---@param varType string string|integer|float|float3
function SettingsData:AddVariable(name, value, varType)
	if self.Variables[name] == nil then
		local varData = VariableData:Create(name, value, varType)
		self.Variables[name] = varData
	end
end

---@param flags string[]
function SettingsData:AddGlobalFlags(flags)
	for i,flag in pairs(flags) do
		self:AddFlag(flag)
	end
end

function SettingsData:UpdateFlags()
	for flag,data in pairs(self.Flags) do
		if data.FlagType == "Global" then
			data.Enabled = GlobalGetFlag(flag) == 1
		elseif data.Target ~= nil then
			if data.FlagType == "User" then
				local userid = tonumber(data.Target)
				local character = GetCurrentCharacter(userid)
				if character ~= nil then
					data.Enabled = UserGetFlag(character, flag) == 1
				else
					data.Enabled = false
				end
			elseif data.FlagType == "Character" then
				data.Enabled = ObjectGetFlag(data.Target, flag) == 1
			end
		end
	end
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
	Global = nil,
	Version = -1
}

ModSettings.__index = ModSettings

---@param uuid string The mod's UUID.
---@param globalSettings SettingsData|nil Default global settings.
function ModSettings:Create(uuid, globalSettings)
    local this =
    {
		UUID = uuid,
		Name = "",
		Profiles = {},
		Global = globalSettings or SettingsData:Create()
	}
	local info = Ext.GetModInfo(uuid)
	if info ~= nil then
		this.Name = info.Name
		this.Version = info.Version
	end
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

function ModSettings:Update()
	self.Global:UpdateFlags()
	for i,v in pairs(self.Profiles) do
		v.Settings:UpdateFlags()
	end
end

Classes.ModSettingsClasses = {
	FlagData = FlagData,
	VariableData = VariableData,
	SettingsData = SettingsData,
	ProfileSettings = ProfileSettings,
	ModSettings = ModSettings,
}