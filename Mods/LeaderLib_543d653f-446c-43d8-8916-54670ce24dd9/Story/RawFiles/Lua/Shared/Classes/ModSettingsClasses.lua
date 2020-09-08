---@class FlagData
local FlagData = {
	Type = "FlagData",
	FlagType = "Global",
	Targets = nil,
	Enabled = false
}

FlagData.__index = FlagData

---@param flag string
---@param flagType string Global|User|Character
---@param enabled boolean
function FlagData:Create(flag, flagType, enabled)
    local this =
    {
		FlagType = flagType or "Global",
		Enabled = enabled or false
	}
	setmetatable(this, self)
    return this
end

local totalFlagTargets = {}

function FlagData:AddTarget(id, enabled)
	if self.Targets == nil then
		self.Targets = {}
	end
	self.Targets[id] = enabled
end

function FlagData:RemoveTarget(id)
	if self.Targets ~= nil then
		self.Targets[id] = nil
		local hasTarget = false
		for i,v in pairs(self.Targets) do
			hasTarget = true
		end
		if not hasTarget then
			self.Targets = nil
		end
	end
	
end

---@class VariableData
local VariableData = {
	Type = "VariableData",
	Value = "",
	Targets = nil
}

VariableData.__index = VariableData

---@param value string|integer|number|number[]
function VariableData:Create(value)
    local this =
    {
		Value = value or ""
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
	Variables = {},
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
---@param enabled boolean|nil
function SettingsData:AddFlag(flag, flagType, enabled)
	if self.Flags[flag] == nil then
		local flagVar = FlagData:Create(flag, flagType, enabled)
		self.Flags[flag] = flagVar
	else
		self.Flags[flag].Enabled = enabled
	end
end

---@param flags string[]
function SettingsData:AddFlags(flags, flagType, enabled)
	for i,flag in pairs(flags) do
		self:AddFlag(flag, flagType, enabled)
	end
end

---@param name string
---@param value string|integer|number|number[]
function SettingsData:AddVariable(name, value)
	if self.Variables[name] == nil then
		local varData = VariableData:Create(value)
		self.Variables[name] = varData
	else
		self.Variables[name].Value = value
	end
end

function SettingsData:UpdateFlags()
	for flag,data in pairs(self.Flags) do
		if data.FlagType == "Global" then
			data.Enabled = GlobalGetFlag(flag) == 1
		elseif data.FlagType == "User" or data.FlagType == "Character" then
			for _,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
				local uuid = GetUUID(db[1])
				if data.FlagType == "User" then
					local id = CharacterGetReservedUserID(uuid)
					local profileid = GetUserProfileID(id)
					local username = GetUserName(id)
					data:AddTarget(profileid, UserGetFlag(uuid, flag) == 1)
				elseif data.FlagType == "Character" then
					local enabled = ObjectGetFlag(uuid, flag) == 1
					if enabled then
						data:AddTarget(uuid, true)
					else
						data:RemoveTarget(uuid)
					end
				end
			end
		end
	end
end

function SettingsData:UpdateVariables(func)
	for name,data in pairs(self.Variables) do
		pcall(func, self, name, data)
	end
end

function SettingsData:ApplyFlags()
	for flag,data in pairs(self.Flags) do
		if data.FlagType == "Global" then
			if data.Enabled then
				GlobalSetFlag(flag)
			else
				GlobalClearFlag(flag)
			end
		elseif data.Targets ~= nil then
			for target,enabled in pairs(data.Targets) do
				if data.FlagType == "User" then
					local userid = tonumber(target)
					if userid == nil then
						-- Username?
						userid = target
					end
					for _,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
						local uuid = db[1]
						local id = CharacterGetReservedUserID(uuid)
						local profileid = GetUserProfileID(id)
						local username = GetUserName(id)
						if profileid == userid or username == userid then
							if enabled then
								UserSetFlag(uuid, flag, 0)
							else
								UserClearFlag(uuid, flag, 0)
							end
						end
					end
				elseif data.FlagType == "Character" and ObjectExists(target) == 1 then
					if data.Enabled then
						ObjectSetFlag(target, flag, 0)
					else
						ObjectClearFlag(target, flag, 0)
					end
				end
			end
		end
	end
end

function SettingsData:ApplyVariables(uuid)
	for name,data in pairs(self.Variables) do
		if type(data.Value) == "number" then
			Osi.LeaderLib_GlobalSettings_SetIntegerVariable(uuid, name, math.tointeger(data.Value))
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
	Version = -1,
	---@type function<SettingaData,string,any>
	UpdateVariable = nil
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
	if self.UpdateVariable ~= nil then
		self.Global:UpdateVariables(self.UpdateVariable)
		for i,v in pairs(self.Profiles) do
			v.Settings:UpdateVariables(self.UpdateVariable)
		end
	else
		if Ext.IsModLoaded(self.UUID) then
			local last_pricemod = GetGlobalPriceModifier()
			for name,v in pairs(self.Global.Variables) do
				SetGlobalPriceModifier(123456)
				Osi.LeaderLib_GlobalSettings_Internal_GetIntegerVariable(self.UUID, name)
				local int_value = GetGlobalPriceModifier()
				if int_value ~= 123456 then
					v.Value = int_value
				end
			end
			SetGlobalPriceModifier(last_pricemod)
		end
	end
end

function ModSettings:ApplyFlags()
	self.Global:ApplyFlags()
	for i,v in pairs(self.Profiles) do
		v.Settings:ApplyFlags()
	end
end

function ModSettings:ApplyVariables()
	self.Global:ApplyVariables(self.UUID)
	for i,v in pairs(self.Profiles) do
		v.Settings:ApplyVariables(self.UUID)
	end
end

function ModSettings:Copy()
	local copy = {
		UUID = self.UUID,
		Name = self.Name,
		Profiles = self.Profiles,
		Global = self.Global,
		Version = self.Version
	}
	return copy
end

Classes.ModSettingsClasses = {
	FlagData = FlagData,
	VariableData = VariableData,
	SettingsData = SettingsData,
	ProfileSettings = ProfileSettings,
	ModSettings = ModSettings,
}