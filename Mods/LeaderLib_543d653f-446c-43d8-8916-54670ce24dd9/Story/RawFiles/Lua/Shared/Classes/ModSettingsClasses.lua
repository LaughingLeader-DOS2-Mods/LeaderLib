---@class FlagData
local FlagData = {
	Type = "FlagData",
	FlagType = "Global",
	ID = "",
	Targets = nil,
	Enabled = false,
	DisplayName = nil,
	Tooltip = nil,
}

FlagData.__index = FlagData

---@param flag string
---@param flagType string Global|User|Character
---@param enabled boolean
function FlagData:Create(flag, flagType, enabled, displayName, tooltip)
    local this =
    {
		ID = flag,
		FlagType = flagType or "Global",
		Enabled = enabled or false,
	}
	if displayName ~= nil then
		this.DisplayName = displayName
	end
	if tooltip ~= nil then
		this.Tooltip = tooltip
	end
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
	ID = "",
	Value = "",
	Targets = nil,
	DisplayName = nil,
	Tooltip = nil,
	Min = 0,
	Max = 999,
	Interval = 1,
}

VariableData.__index = VariableData

---@param id string
---@param value string|integer|number|number[]
---@param displayName string
---@param tooltip string
---@param min any
---@param max any
---@param interval any
function VariableData:Create(id, value, displayName, tooltip, min, max, interval)
    local this =
    {
		ID = id,
		Value = value or "",
	}
	if displayName ~= nil then
		this.DisplayName = displayName
	end
	if tooltip ~= nil then
		this.Tooltip = tooltip
	end
	if min ~= nil then
		this.Min = min
	end
	if max ~= nil then
		this.Max = max
	end
	if interval ~= nil then
		this.Interval = interval
	end
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

--- Shortcut to get the string key text without handle.
local function skey(key)
	local text,_ = Ext.GetTranslatedStringFromKey(key)
	return text
end

---@param flag string
---@param flagType string Global|User|Character
---@param enabled boolean|nil
---@param displayName string
---@param tooltip string
function SettingsData:AddFlag(flag, flagType, enabled, displayName, tooltip)
	if self.Flags[flag] == nil then
		self.Flags[flag] = FlagData:Create(flag, flagType, enabled, displayName, tooltip)
	else
		local existing = self.Flags[flag]
		existing.Enabled = enabled or existing.Enabled
		existing.FlagType = flagType or existing.FlagType
		existing.DisplayName = displayName or existing.DisplayName
		existing.Tooltip = tooltip or existing.Tooltip
	end
end

---@param flags string[]
function SettingsData:AddFlags(flags, flagType, enabled)
	for i,flag in pairs(flags) do
		self:AddFlag(flag, flagType, enabled)
	end
end

---Adds a flag that uses the flag name and Flag_Description as the DisplayName and Tooltip.
---@param flag string
---@param flagType string Global|User|Character
---@param enabled boolean|nil
---@param tooltipKey string|nil A string key to use for the tooltip. Will default to Flag_Description.
function SettingsData:AddLocalizedFlag(flag, flagType, enabled, key, tooltipKey)
	key = key or flag
	tooltipKey = tooltipKey or key.."_Description"
	self:AddFlag(flag, flagType, enabled, skey(key), skey(tooltipKey))
end

---Same thing as AddFlags, but assumes each flag is its own DisplayName key.
---@param flags string[]
function SettingsData:AddLocalizedFlags(flags, flagType, enabled)
	for i,flag in pairs(flags) do
		self:AddLocalizedFlag(flag, flagType, enabled)
	end
end

---@param name string
---@param value string|integer|number|number[]
---@param displayName string
---@param tooltip string
---@param min any
---@param max any
---@param interval any
function SettingsData:AddVariable(name, value, displayName, tooltip, min, max, interval)
	if self.Variables[name] == nil then
		self.Variables[name] = VariableData:Create(name, value, displayName, tooltip, min, max, interval)
	else
		local existing = self.Variables[name]
		existing.Value = value
		existing.DisplayName = displayName or existing.DisplayName
		existing.Tooltip = tooltip or existing.Tooltip
		existing.Min = min or existing.Min
		existing.Max = max or existing.Max
		existing.Interval = interval or existing.Interval
	end
end

---@param name string
---@param key string The string key to use.
---@param value string|integer|number|number[]
---@param min any
---@param max any
---@param interval any
---@param tooltipKey string|nil A string key to use for the tooltip. Will default to Key_Description.
function SettingsData:AddLocalizedVariable(name, key, value, min, max, interval, tooltipKey)
	tooltipKey = tooltipKey or key.."_Description"
	self:AddVariable(name, value, skey(key), skey(tooltipKey), min, max, interval)
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
		if data ~= nil and type(data.Value) == "number" then
			local intVal = math.tointeger(data.Value) or math.ceil(data.Value)
			if intVal ~= nil then
				Osi.LeaderLib_GlobalSettings_SetIntegerVariable(uuid, name, intVal)
			else
				Ext.PrintError("[LeaderLib:ModSettingsClasses.lua:ApplyVariables] Error converting variable",name,"to integer.")
			end
		elseif data == nil then
			Ext.PrintError("[LeaderLib:ModSettingsClasses.lua:ApplyVariables] Variable",name,"is nil.")
		end
	end
end

function SettingsData:GetVariable(name, fallback)
	local data = self.Variables[name]
	if data ~= nil then
		if type(fallback) == "number" and type(data.Value) == "string" then
			return tonumber(data.Value) or fallback
		end
		return data.Value or fallback
	end
	return fallback
end

function SettingsData:Export()
	local export = {Flags = {}, Variables = {}}
	for name,v in pairs(self.Flags) do
		local data = {Enabled = v.Enabled, FlagType = v.FlagType}
		if v.Targets ~= nil then
			data.Targets = v.Targets
		end
		export.Flags[name] = data
	end
	for name,v in pairs(self.Variables) do
		local data = {Value = v.Value}
		if v.Targets ~= nil then
			data.Targets = v.Targets
		end
		export.Variables[name] = data
	end
	return export
end

function SettingsData:SetMetatables()
	for _,v in pairs(self.Flags) do
		setmetatable(v, FlagData)
		if v.DisplayName ~= nil and v.DisplayName.Handle ~= nil then
			setmetatable(v.DisplayName, Classes.TranslatedString)
		end
		if v.Tooltip ~= nil and v.Tooltip.Handle ~= nil then
			setmetatable(v.Tooltip, Classes.TranslatedString)
		end
	end
	for _,v in pairs(self.Variables) do
		setmetatable(v, VariableData)
		if v.DisplayName ~= nil and v.DisplayName.Handle ~= nil then
			setmetatable(v.DisplayName, Classes.TranslatedString)
		end
		if v.Tooltip ~= nil and v.Tooltip.Handle ~= nil then
			setmetatable(v.Tooltip, Classes.TranslatedString)
		end
	end
	setmetatable(self, SettingsData)
end

---@param source SettingsData
function SettingsData:CopySettings(source)
	for name,v in pairs(source.Flags) do
		self:AddFlag(name, v.FlagType, v.Enabled, v.DisplayName, v.Tooltip)
	end
	for name,v in pairs(source.Variables) do
		self:AddVariable(name, v.Value, v.DisplayName, v.Tooltip, v.Min, v.Max, v.Interval)
	end
	self:SetMetatables()
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
	Global = {},
	Version = -1,
	---@type function<SettingaData,string,any>
	UpdateVariable = nil,
	LoadedExternally = false,
	---@type function<string, table<string, string[]>>
	GetMenuOrder = nil,
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
		Profiles = {},
		Global = self.Global:Export(),
		Version = self.Version
	}
	for k,v in pairs(self.Profiles) do
		copy.Profiles[k] = {
			ID = v.ID,
			Settings = v.Settings:Export()
		}
	end
	return copy
end

Classes.ModSettingsClasses = {
	FlagData = FlagData,
	VariableData = VariableData,
	SettingsData = SettingsData,
	ProfileSettings = ProfileSettings,
	ModSettings = ModSettings,
}