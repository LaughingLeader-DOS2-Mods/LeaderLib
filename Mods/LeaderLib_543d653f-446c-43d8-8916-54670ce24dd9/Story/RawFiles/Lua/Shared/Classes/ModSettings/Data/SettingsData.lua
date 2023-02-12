local FlagData = Classes.ModSettingsClasses.FlagData
local VariableData = Classes.ModSettingsClasses.VariableData
local ButtonData = Classes.ModSettingsClasses.ButtonData

local isClient = Ext.IsClient()

---@class SettingsData
local SettingsData = {
	Type = "SettingsData",
	---@type table<string, FlagData>
	Flags = {},
	---@type table<string, VariableData>
	Variables = {},
	---@type table<string, ButtonData>
	Buttons = {},
}

SettingsData.__index = SettingsData

Classes.ModSettingsClasses.SettingsData = SettingsData

---@param flags table<string, FlagData>|nil
---@param variables table<string, VariableData>|nil
---@param buttons table<string, VariableData>|nil
function SettingsData:Create(flags, variables, buttons)
    local this =
    {
		Flags = flags or {},
		Variables = variables or {},
		Buttons = buttons or {}
	}
	setmetatable(this, self)
    return this
end

--- Shortcut to get the string key text without handle.
local function skey(key, autoReplace)
	return Classes.TranslatedString:CreateFromKey(key, key, {AutoReplacePlaceholders=autoReplace ~= false})
end

---@private
function SettingsData:CanExecuteOsiris()
	return not isClient and _OSIRIS()
end

---@alias LeaderLibGlobalSettingsFlagType string|"Global"|"User"|"Character"|"Object"

---@param flag string
---@param flagType LeaderLibGlobalSettingsFlagType
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
		Events.ModSettingsChanged:Invoke({ID=flag, Value=enabled, Data=self.Flags[flag], Settings = self})
	else
		local existing = self.Flags[flag]
		local changed = false
		existing.ID = flag
		if enabled ~= nil and (existing.Enabled == nil or isFromFile) then
			changed = existing.Enabled ~= enabled
			existing.Enabled = enabled
		end
		if canExport ~= nil then
			existing.CanExport = canExport
		end
		existing.FlagType = flagType or existing.FlagType
		existing.DisplayName = displayName or existing.DisplayName
		existing.Tooltip = tooltip or existing.Tooltip
		if isFromFile == false then
			existing.IsFromFile = false
		end
		if changed then
			Events.ModSettingsChanged:Invoke({ID=flag, Value=enabled, Data=existing, Settings = self})
		end
	end
end

---@param flags string[]
---@param flagType LeaderLibGlobalSettingsFlagType|nil Defaults to "Global".
---@param enabled boolean|nil
---@param canExport boolean|nil
function SettingsData:AddFlags(flags, flagType, enabled, canExport, isFromFile)
	for i,flag in pairs(flags) do
		self:AddFlag(flag, flagType, enabled, nil, nil, canExport, isFromFile)
	end
end

---Adds a flag that uses the flag name and Flag_Description as the DisplayName and Tooltip.
---@param flag string
---@param flagType LeaderLibGlobalSettingsFlagType|nil Defaults to "Global".
---@param enabled boolean|nil
---@param tooltipKey string|nil A string key to use for the tooltip. Will default to Flag_Description.
---@param canExport boolean|nil
function SettingsData:AddLocalizedFlag(flag, flagType, enabled, key, tooltipKey, canExport, isFromFile)
	if isFromFile == nil then
		isFromFile = false
	end
	key = key or flag
	tooltipKey = tooltipKey or key.."_Description"
	self:AddFlag(flag, flagType, enabled, skey(key), skey(tooltipKey, false), canExport, isFromFile)
end

---Same thing as AddFlags, but assumes each flag is its own DisplayName key.
---@param flags string[]
---@param flagType LeaderLibGlobalSettingsFlagType|nil Defaults to "Global".
---@param enabled boolean|nil
---@param canExport boolean|nil
function SettingsData:AddLocalizedFlags(flags, flagType, enabled, canExport, isFromFile)
	if isFromFile == nil then
		isFromFile = false
	end
	for i,flag in pairs(flags) do
		self:AddLocalizedFlag(flag, flagType, enabled, nil, nil, canExport, isFromFile)
	end
end

---@param name string
---@param value string|integer|number|number[]
---@param displayName string|nil
---@param tooltip string|nil
---@param min any|nil
---@param max any|nil
---@param interval any|nil
---@param canExport boolean|nil
function SettingsData:AddVariable(name, value, displayName, tooltip, min, max, interval, canExport, isFromFile)
	if self.Variables[name] == nil then
		self.Variables[name] = VariableData:Create(name, value, displayName, tooltip, min, max, interval, isFromFile)
		if canExport then
			self.Variables[name].CanExport = canExport
		end
		Events.ModSettingsChanged:Invoke({ID=name, Value=value, Data=self.Variables[name], Settings = self})
	else
		local existing = self.Variables[name]
		local changed = false
		if value and not isFromFile then
			existing.Default = value
		end
		if value ~= nil and (existing.Value == nil or isFromFile) then
			changed = existing.Value ~= value
			existing.Value = value
		end
		existing.DisplayName = displayName or existing.DisplayName
		existing.Tooltip = tooltip or existing.Tooltip
		existing.Min = min or existing.Min
		existing.Max = max or existing.Max
		existing.Interval = interval or existing.Interval
		if canExport ~= nil then
			existing.CanExport = canExport
		end
		if isFromFile == false then
			existing.IsFromFile = false
		end
		if changed then
			Events.ModSettingsChanged:Invoke({ID=name, Value=value, Data=existing, Settings = self})
		end
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
function SettingsData:AddLocalizedVariable(name, key, value, min, max, interval, tooltipKey, canExport, isFromFile)
	if isFromFile == nil then
		isFromFile = false
	end
	tooltipKey = tooltipKey or key.."_Description"
	self:AddVariable(name, value, skey(key), skey(tooltipKey, false), min, max, interval, canExport, isFromFile)
end

---@param id string
---@param callback ModMenuButtonCallback
---@param displayName string|nil
---@param tooltip string|nil
---@param enabled boolean|nil
---@param hostOnly boolean|nil
---@param isFromFile boolean|nil
function SettingsData:AddButton(id, callback, displayName, tooltip, enabled, hostOnly, isFromFile)
	if not self.Buttons then
		self.Buttons = {}
	end
	if self.Buttons[id] == nil then
		self.Buttons[id] = ButtonData:Create(id, callback, enabled, displayName, tooltip, hostOnly, isFromFile)
	else
		---@type ButtonData
		local existing = self.Buttons[id]
		existing.DisplayName = displayName or existing.DisplayName
		existing.Tooltip = tooltip or existing.Tooltip
		existing.Enabled = enabled ~= nil and enabled or existing.Enabled
		existing.HostOnly = hostOnly ~= nil and hostOnly or existing.HostOnly
		if isFromFile == false then
			existing.IsFromFile = false
		end
		if callback ~= nil and existing.Callback ~= callback then
			if type(existing.Callback) == "table" then
				if not Common.TableHasValue(existing.Callback, callback) then
					table.insert(existing.Callback, callback)
				end
			else
				local lastCallback = existing.Callback
				local callbacks = {}
				callbacks[#callbacks+1] = existing.Callback
				callbacks[#callbacks+1] = callback
				existing.Callback = callbacks
			end
		end
	end
end

---@param id string
---@param key string The string key to use.
---@param callback ModMenuButtonCallback
---@param enabled boolean|nil
---@param hostOnly boolean|nil
---@param tooltipKey string|nil
function SettingsData:AddLocalizedButton(id, key, callback, enabled, hostOnly, tooltipKey, isFromFile)
	if isFromFile == nil then
		isFromFile = false
	end
	tooltipKey = tooltipKey or key.."_Description"
	self:AddButton(id, callback, skey(key), skey(tooltipKey, false), enabled, hostOnly, isFromFile)
end

function SettingsData:UpdateFlags()
	if not self:CanExecuteOsiris() then
		return
	end
	for flag,data in pairs(self.Flags) do
		if not data.ClientSide then
			if data.FlagType == "Global" then
				data.Enabled = GlobalGetFlag(flag) == 1
			elseif data.FlagType == "User" or (data.FlagType == "Character" or data.FlagType == "Object") then
				for player in GameHelpers.Character.GetPlayers(false) do
					local uuid = player.MyGuid
					if data.FlagType == "User" then
						local id = CharacterGetReservedUserID(uuid)
						if id then
							local profileid = GetUserProfileID(id)
							if profileid then
								data:AddTarget(profileid, UserGetFlag(uuid, flag) == 1)
							end
						end
					elseif (data.FlagType == "Character" or data.FlagType == "Object") then
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
end

function SettingsData:UpdateVariables(func)
	for name,data in pairs(self.Variables) do
		pcall(func, self, name, data)
	end
end

function SettingsData:ApplyFlags()
	if not self:CanExecuteOsiris() then
		return
	end
	for flag,data in pairs(self.Flags) do
		if not data.ClientSide then
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
end

function SettingsData:ApplyVariables(uuid, callback)
	for name,data in pairs(self.Variables) do
		if data ~= nil and not data.ClientSide then
			if callback ~= nil then
				pcall(callback, uuid, name, data)
			end
			if type(data.Value) == "number" then
				if self:CanExecuteOsiris() then
					local intVal = math.tointeger(data.Value) or math.ceil(data.Value)
					if intVal ~= nil then
						--print("Osi.LeaderLib_GlobalSettings_SetIntegerVariable", uuid, name, intVal)
						Osi.LeaderLib_GlobalSettings_SetIntegerVariable(uuid, name, intVal)
					else
						Ext.Utils.PrintError("[LeaderLib:ModSettingsClasses.lua:ApplyVariables] Error converting variable",name,"to integer.")
					end
				end
			end
		elseif data == nil then
			Ext.Utils.PrintError("[LeaderLib:ModSettingsClasses.lua:ApplyVariables] Variable",name,"is nil.")
		end
	end
end

---@generic T:string|number
---Gets a variable's value.
---@param name string
---@param fallback T
---@return T
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

---Gets a flag's value.
---@param name string
---@param fallback boolean
---@return boolean
function SettingsData:GetFlag(name, fallback)
	local data = self.Flags[name]
	if data ~= nil then
		return data.Enabled
	end
	return fallback
end

---Gets a flag or variable's value.
---@param name string
---@param fallback boolean|number|string|nil
---@return boolean|number|string
function SettingsData:GetFlagOrVariableValue(name, fallback)
	local value = self:GetFlag(name) or self:GetVariable(name)
	if value == nil then
		return fallback
	end
	return value
end

---@param id string Flag id.
---@param b boolean Value to compare, i.e. true for "Flag Is Set"
---@param target Guid|nil Optional character UUID to check, for object or user flags.
function SettingsData:FlagEquals(id, b, target)
	local data = self.Flags[id]
	if data ~= nil then
		if data.FlagType == "Global" then
			return data.Enabled == b
		elseif data.FlagType == "User" or data.FlagType == "Character" then
			if not self:CanExecuteOsiris() or data.ClientSide then
				return data.ClientSide and data.Enabled
			end
			if target ~= nil then
				target = GameHelpers.GetUUID(target)
				if target then
					local enabled = false
					if data.FlagType == "User" then
						enabled = UserGetFlag(target, data.ID) == 1
					elseif data.FlagType == "Character" then
						enabled = ObjectGetFlag(target, data.ID) == 1
					end
					return enabled == b
				end
			else
				for player in GameHelpers.Character.GetPlayers() do
					if data.FlagType == "User" then
						if UserGetFlag(player.MyGuid, data.ID) == 1 then
							if b then
								return true
							end
						end
					elseif data.FlagType == "Character" then
						local enabled = ObjectGetFlag(player.MyGuid, data.ID) == 1
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

---Invoke the callback on a button.
---@param id string
---@vararg any
function SettingsData:InvokeButton(id, ...)
	local button = self.Buttons[id]
	if button then
		button:Invoke(...)
	end
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
	if not self.Flags then 
		self.Flags = {} 
	else
		for _,v in pairs(self.Flags) do
			setmetatable(v, FlagData)
			if Classes.TranslatedString:IsTranslatedString(v.DisplayName) then
				Classes.TranslatedString:SetMeta(v.DisplayName)
			end
			if Classes.TranslatedString:IsTranslatedString(v.Tooltip) then
				Classes.TranslatedString:SetMeta(v.Tooltip)
			end
		end
	end
	
	if not self.Variables then 
		self.Variables = {} 
	else
		for _,v in pairs(self.Variables) do
			setmetatable(v, VariableData)
			if Classes.TranslatedString:IsTranslatedString(v.DisplayName) then
				Classes.TranslatedString:SetMeta(v.DisplayName)
			end
			if Classes.TranslatedString:IsTranslatedString(v.Tooltip) then
				Classes.TranslatedString:SetMeta(v.Tooltip)
			end
		end
	end
	
	if not self.Buttons then 
		self.Buttons = {} 
	else
		for _,v in pairs(self.Buttons) do
			setmetatable(v, ButtonData)
			if Classes.TranslatedString:IsTranslatedString(v.DisplayName) then
				Classes.TranslatedString:SetMeta(v.DisplayName)
			end
			if Classes.TranslatedString:IsTranslatedString(v.Tooltip) then
				Classes.TranslatedString:SetMeta(v.Tooltip)
			end
		end
	end
	setmetatable(self, SettingsData)
end

---@param source SettingsData
function SettingsData:CopySettings(source)
	if source.Flags then
		for name,v in pairs(source.Flags) do
			self:AddFlag(name, v.FlagType, v.Enabled, v.DisplayName, v.Tooltip, nil, v.IsFromFile)
		end
	elseif not self.Flags then
		self.Flags = {}
	end
	if source.Variables then
		for name,v in pairs(source.Variables) do
			self:AddVariable(name, v.Value, v.DisplayName, v.Tooltip, v.Min, v.Max, v.Interval, nil, v.IsFromFile)
		end
	elseif not self.Variables then
		self.Variables = {}
	end
	if source.Buttons then
		for name,v in pairs(source.Buttons) do
			self:AddButton(name, v.Callback, v.DisplayName, v.Tooltip, v.Enabled, v.HostOnly, v.IsFromFile)
		end
	elseif not self.Buttons then
		self.Buttons = {}
	end
	self:SetMetatables()
end

function SettingsData:SetFlag(id, enabled)
	local entry = self.Flags[id]
	if entry ~= nil then
		entry.Enabled = enabled
		Events.ModSettingsChanged:Invoke({ID=id, Value=enabled, Data=entry, Settings = self})
		return true
	end
	return false
end

function SettingsData:SetVariable(id, value)
	local entry = self.Variables[id]
	if entry ~= nil then
		if type(entry.Value) == "table" and entry.Value.Entries ~= nil then
			entry.Value.Selected = value
		else
			entry.Value = value
		end
		Events.ModSettingsChanged:Invoke({ID=id, Value=value, Data=entry, Settings = self})
		return true
	end
	return false
end