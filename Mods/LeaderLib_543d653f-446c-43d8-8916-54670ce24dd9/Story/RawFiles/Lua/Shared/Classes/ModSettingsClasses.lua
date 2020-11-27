---@class FlagData
local FlagData = {
	Type = "FlagData",
	FlagType = "Global",
	ID = "",
	Targets = nil,
	Enabled = false,
	Default = false,
	DisplayName = nil,
	Tooltip = nil,
	DebugOnly = false,
	CanExport = true,
	IsFromFile = false
}

FlagData.__index = FlagData

---@param flag string
---@param flagType string Global|User|Character
---@param enabled boolean
function FlagData:Create(flag, flagType, enabled, displayName, tooltip, isFromFile)
    local this =
    {
		ID = flag,
		FlagType = flagType or "Global",
		Enabled = enabled or false,
		IsFromFile = false
	}
	if isFromFile ~= nil then
		this.IsFromFile = isFromFile
	end
	if string.find(string.lower(flag), "disable") then
		this.Default = true
	elseif string.find(string.lower(flag), "enable") then
		this.Default = false
	else
		this.Default = this.Enabled
	end
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
	Default = "",
	Targets = nil,
	DisplayName = nil,
	Tooltip = nil,
	Min = 0,
	Max = 999,
	Interval = 1,
	DebugOnly = false,
	CanExport = true,
	IsFromFile = false
}

VariableData.__index = VariableData

---@param id string
---@param value string|integer|number|number[]
---@param displayName string
---@param tooltip string
---@param min any
---@param max any
---@param interval any
function VariableData:Create(id, value, displayName, tooltip, min, max, interval, isFromFile)
    local this =
    {
		ID = id,
		Value = value or "",
		IsFromFile = false
	}
	if isFromFile ~= nil then
		this.IsFromFile = isFromFile
	end
	this.Default = this.Value
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
		Variables = variables or {},
	}
	setmetatable(this, self)
    return this
end

--- Shortcut to get the string key text without handle.
local function skey(key)
	local text,_ = Ext.GetTranslatedStringFromKey(key)
	if text ~= nil and text ~= "" then
		text = GameHelpers.Tooltip.ReplacePlaceholders(text)
	end
	return text
end

---@param flag string
---@param flagType string Global|User|Character
---@param enabled boolean|nil
---@param displayName string|nil
---@param tooltip string|nil
---@param canExport boolean|nil
---@param isFromFile boolean|nil
function SettingsData:AddFlag(flag, flagType, enabled, displayName, tooltip, canExport, isFromFile)
	if self.Flags[flag] == nil then
		self.Flags[flag] = FlagData:Create(flag, flagType, enabled, displayName, tooltip, isFromFile)
		if canExport then
			self.Flags[flag].CanExport = canExport
		end
	else
		local existing = self.Flags[flag]
		existing.ID = flag
		existing.Enabled = enabled or existing.Enabled
		existing.FlagType = flagType or existing.FlagType
		existing.DisplayName = displayName or existing.DisplayName
		existing.Tooltip = tooltip or existing.Tooltip
		existing.CanExport = canExport or existing.CanExport
	end
end

---@param flags string[]
---@param flagType string Global|User|Character
---@param enabled boolean|nil
---@param canExport boolean|nil
function SettingsData:AddFlags(flags, flagType, enabled, canExport)
	for i,flag in pairs(flags) do
		self:AddFlag(flag, flagType, enabled, nil, nil, canExport)
	end
end

---Adds a flag that uses the flag name and Flag_Description as the DisplayName and Tooltip.
---@param flag string
---@param flagType string Global|User|Character
---@param enabled boolean|nil
---@param tooltipKey string|nil A string key to use for the tooltip. Will default to Flag_Description.
---@param canExport boolean|nil
function SettingsData:AddLocalizedFlag(flag, flagType, enabled, key, tooltipKey, canExport)
	key = key or flag
	tooltipKey = tooltipKey or key.."_Description"
	self:AddFlag(flag, flagType, enabled, skey(key), skey(tooltipKey), canExport)
end

---Same thing as AddFlags, but assumes each flag is its own DisplayName key.
---@param flags string[]
---@param flagType string Global|User|Character
---@param enabled boolean|nil
---@param canExport boolean|nil
function SettingsData:AddLocalizedFlags(flags, flagType, enabled, canExport)
	for i,flag in pairs(flags) do
		self:AddLocalizedFlag(flag, flagType, enabled, nil, nil, canExport)
	end
end

---@param name string
---@param value string|integer|number|number[]
---@param displayName string
---@param tooltip string
---@param min any
---@param max any
---@param interval any
---@param canExport boolean|nil
function SettingsData:AddVariable(name, value, displayName, tooltip, min, max, interval, canExport, isFromFile)
	if self.Variables[name] == nil then
		self.Variables[name] = VariableData:Create(name, value, displayName, tooltip, min, max, interval, isFromFile)
		if canExport then
			self.Variables[name].CanExport = canExport
		end
	else
		local existing = self.Variables[name]
		existing.Value = value
		existing.DisplayName = displayName or existing.DisplayName
		existing.Tooltip = tooltip or existing.Tooltip
		existing.Min = min or existing.Min
		existing.Max = max or existing.Max
		existing.Interval = interval or existing.Interval
		existing.CanExport = canExport or existing.CanExport
	end
end

---@param name string
---@param key string The string key to use.
---@param value string|integer|number|number[]
---@param min any
---@param max any
---@param interval any
---@param tooltipKey string|nil A string key to use for the tooltip. Will default to Key_Description.
---@param canExport boolean|nil
function SettingsData:AddLocalizedVariable(name, key, value, min, max, interval, tooltipKey, canExport)
	tooltipKey = tooltipKey or key.."_Description"
	self:AddVariable(name, value, skey(key), skey(tooltipKey), min, max, interval, canExport)
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

function SettingsData:ApplyVariables(uuid, callback)
	for name,data in pairs(self.Variables) do
		if data ~= nil then
			if callback ~= nil then
				pcall(callback, uuid, name, data)
			end
			if type(data.Value) == "number" then
				local intVal = math.tointeger(data.Value) or math.ceil(data.Value)
				if intVal ~= nil then
					--print("Osi.LeaderLib_GlobalSettings_SetIntegerVariable", uuid, name, intVal)
					Osi.LeaderLib_GlobalSettings_SetIntegerVariable(uuid, name, intVal)
				else
					Ext.PrintError("[LeaderLib:ModSettingsClasses.lua:ApplyVariables] Error converting variable",name,"to integer.")
				end
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

function SettingsData:FlagEquals(id, b, target)
	local data = self.Flags[id]
	if data ~= nil then
		if data.FlagType == "Global" then
			return data.Enabled == b
		elseif data.FlagType == "User" or data.FlagType == "Character" then
			if target ~= nil then
				local enabled = false
				if data.FlagType == "User" then
					enabled = UserGetFlag(target, data.ID) == 1
				elseif data.FlagType == "Character" then
					enabled = ObjectGetFlag(target, data.ID) == 1
				end
				return enabled == b
			else
				for _,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
					local uuid = GetUUID(db[1])
					if data.FlagType == "User" then
						if UserGetFlag(uuid, data.ID) == 1 then
							if b then
								return true
							end
						end
					elseif data.FlagType == "Character" then
						local enabled = ObjectGetFlag(uuid, flag) == 1
						if enabled and b then
							return true
						end
					end
				end
			end
		end
	end
	return b == false -- Flag doesn't exist, so it's not set
end

function SettingsData:Export(forSyncing)
	local export = {Flags = {}, Variables = {}}
	for name,v in pairs(self.Flags) do
		if forSyncing == true or v.CanExport ~= false then
			local data = {Enabled = v.Enabled, FlagType = v.FlagType}
			if forSyncing == true then
				data.ID = v.ID
				data.IsFromFile = v.IsFromFile
			end
			if v.Targets ~= nil then
				data.Targets = v.Targets
			end
			export.Flags[name] = data
		end
	end
	for name,v in pairs(self.Variables) do
		if forSyncing == true or v.CanExport ~= false then
			local data = {Value = v.Value}
			if forSyncing == true then
				data.ID = v.ID
				data.IsFromFile = v.IsFromFile
			end
			if v.Targets ~= nil then
				data.Targets = v.Targets
			end
			export.Variables[name] = data
		end
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
		self:AddFlag(name, v.FlagType, v.Enabled, v.DisplayName, v.Tooltip, nil, v.IsFromFile)
	end
	for name,v in pairs(source.Variables) do
		self:AddVariable(name, v.Value, v.DisplayName, v.Tooltip, v.Min, v.Max, v.Interval, nil, v.IsFromFile)
	end
	self:SetMetatables()
end

function SettingsData:SetFlag(id, enabled)
	local entry = self.Flags[id]
	if entry ~= nil then
		entry.Enabled = enabled
		return true
	end
	return false
end

function SettingsData:SetVariable(id, value)
	local entry = self.Variables[id]
	if entry ~= nil then
		entry.Value = value
		return true
	end
	return false
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
	TitleColor = "#FFFFFF",
	UUID = "",
	Name = "",
	---@type table<string, ProfileSettings>
	Profiles = {},
	---@type SettingsData
	Global = {},
	Version = -1,
	---@type function<SettingaData,string,any>
	UpdateVariable = nil,
	OnVariableSet = nil,
	LoadedExternally = false,
	---@type function<string, table<string, string[]>>
	GetMenuOrder = nil,
}

ModSettings.__index = ModSettings

---@param uuid string The mod's UUID.
---@param globalSettings SettingsData|nil Default global settings.
---@return ModSettings
function ModSettings:Create(uuid, globalSettings)
    local this =
    {
		UUID = uuid,
		Name = "",
		Profiles = {},
		Global = globalSettings or SettingsData:Create(),
		Version = -1,
		UpdateVariable = nil,
		OnVariableSet = nil,
		LoadedExternally = false,
		GetMenuOrder = nil,
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
	self.Global:ApplyVariables(self.UUID, self.OnVariableSet)
	for i,v in pairs(self.Profiles) do
		v.Settings:ApplyVariables(self.UUID, self.OnVariableSet)
	end
end

function ModSettings:ApplyToGame()
	self:ApplyFlags()
	self:ApplyVariables()
end

function ModSettings:SetFlag(id, enabled, profile)
	if profile ~= nil then
		local profileSettings = self.Profiles[profile]
		if profileSettings ~= nil then
			profileSettings.Settings:SetFlag(id, enabled)
		end
	else
		if not self.Global:SetFlag(id, enabled) then
			-- Try and find the active profile for this option
			if Ext.IsServer() then
				profile = GetUserProfileID(CharacterGetReservedUserID(CharacterGetHostCharacter()))
				local profileSettings = self.Profiles[profile]
				if profileSettings ~= nil then
					profileSettings.Settings:SetFlag(id, enabled)
				end
			end
		end
	end
end

function ModSettings:SetVariable(id, value, profile)
	if profile ~= nil then
		local profileSettings = self.Profiles[profile]
		if profileSettings ~= nil then
			profileSettings.Settings:SetVariable(id, value)
		end
	else
		if not self.Global:SetVariable(id, value) then
			-- Try and find the active profile for this option
			if Ext.IsServer() then
				profile = GetUserProfileID(CharacterGetReservedUserID(CharacterGetHostCharacter()))
				local profileSettings = self.Profiles[profile]
				if profileSettings ~= nil then
					profileSettings.Settings:SetVariable(id, value)
				end
			end
		end
	end
end

function ModSettings:GetEntry(id, profile)
	if profile ~= nil then
		local profileSettings = self.Profiles[profile]
		if profileSettings ~= nil then
			local entry = profileSettings.Settings.Variables[id] or profileSettings.Settings.Flags[id]
			if entry ~= nil then
				return entry
			end
		end
	end
	local entry = self.Global.Variables[id] or self.Global.Flags[id]
	return entry
end

function ModSettings:GetAllEntries(profile)
	local entries = {}
	for _,v in pairs(self.Global.Flags) do
		if not v.IsFromFile then
			table.insert(entries, v)
		end
	end
	for _,v in pairs(self.Global.Variables) do
		if not v.IsFromFile then
			table.insert(entries, v)
		end
	end
	if profile ~= nil and profile ~= "" then
		local data = self.Profiles[profile]
		if data ~= nil and data.Settings ~= nil then
			for _,v in pairs(data.Settings.Flags) do
				if not v.IsFromFile then
					table.insert(entries, v)
				end
			end
			for _,v in pairs(data.Settings.Variables) do
				if not v.IsFromFile then
					table.insert(entries, v)
				end
			end
		end
	end
	return entries
end

function ModSettings:Copy(forSyncing)
	local copy = {
		UUID = self.UUID,
		Name = self.Name,
		Profiles = {},
		Global = self.Global:Export(forSyncing),
		Version = self.Version
	}
	for k,v in pairs(self.Profiles) do
		copy.Profiles[k] = {
			ID = v.ID,
			Settings = v.Settings:Export(forSyncing)
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