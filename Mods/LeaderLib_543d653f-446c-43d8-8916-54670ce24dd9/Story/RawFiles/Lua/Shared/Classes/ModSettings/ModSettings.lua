local SettingsData = Classes.ModSettingsClasses.SettingsData
local ProfileSettings = Classes.ModSettingsClasses.ProfileSettings

local isClient = Ext.IsClient()

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
	---@type fun(self:SettingsData, name:string, data:VariableData):void
	UpdateVariable = nil,
	---@type fun(uuid:string, name:string, data:VariableData):void
	OnVariableSet = nil,
	LoadedExternally = false,
	---@type function<string, table<string, string[]>>
	GetMenuOrder = nil,
}

ModSettings.__index = ModSettings

Classes.ModSettingsClasses.ModSettings = ModSettings

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
	end
	--For older mods, Let Osiris update the variable
	if not isClient and Ext.IsModLoaded(self.UUID) and Ext.OsirisIsCallable() then
		for name,v in pairs(self.Global.Variables) do
			Osi.LeaderLib_GlobalSettings_GetIntegerVariable(self.UUID, name)
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
	elseif not self.Global:SetVariable(id, value) then
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
	local entry = self.Global.Buttons[id]
	if entry then
		return entry
	end
	entry = self.Global.Variables[id] or self.Global.Flags[id]
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
	for _,v in pairs(self.Global.Buttons) do
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

function ModSettings:HasEntries()
	if Common.TableHasAnyEntry(self.Global.Flags) 
	or Common.TableHasAnyEntry(self.Global.Variables)
	or Common.TableHasAnyEntry(self.Global.Buttons)
	then
		return true
	end
	return false
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