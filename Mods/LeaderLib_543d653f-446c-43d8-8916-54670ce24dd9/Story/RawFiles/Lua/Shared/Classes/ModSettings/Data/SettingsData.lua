local FlagData = Classes.ModSettingsClasses.FlagData
local VariableData = Classes.ModSettingsClasses.VariableData
local ButtonData = Classes.ModSettingsClasses.ButtonData

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

---@param flags table<string, FlagData>
---@param variables table<string, VariableData>
---@param buttons table<string, VariableData>
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
		existing.Enabled = enabled ~= nil and enabled or existing.Enabled
		existing.FlagType = flagType or existing.FlagType
		existing.DisplayName = displayName or existing.DisplayName
		existing.Tooltip = tooltip or existing.Tooltip
		existing.CanExport = canExport ~= nil and canExport or existing.CanExport
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
		existing.Value = value ~= nil and value or existing.Value
		existing.DisplayName = displayName or existing.DisplayName
		existing.Tooltip = tooltip or existing.Tooltip
		existing.Min = min or existing.Min
		existing.Max = max or existing.Max
		existing.Interval = interval or existing.Interval
		existing.CanExport = canExport ~= nil and canExport or existing.CanExport
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

---@param name string
---@param key string The string key to use.
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
		existing.CanExport = isFromFile ~= nil and isFromFile or existing.IsFromFile
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

---@param name string
---@param key string The string key to use.
---@param callback ModMenuButtonCallback
---@param enabled boolean|nil
---@param hostOnly boolean|nil
---@param tooltipKey string|nil
function SettingsData:AddLocalizedButton(id, key, callback, enabled, hostOnly, tooltipKey)
	tooltipKey = tooltipKey or key.."_Description"
	self:AddButton(id, callback, skey(key), skey(tooltipKey), enabled, hostOnly)
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
	if not self.Flags then 
		self.Flags = {} 
	else
		for _,v in pairs(self.Flags) do
			setmetatable(v, FlagData)
			if v.DisplayName ~= nil and v.DisplayName.Handle ~= nil then
				setmetatable(v.DisplayName, Classes.TranslatedString)
			end
			if v.Tooltip ~= nil and v.Tooltip.Handle ~= nil then
				setmetatable(v.Tooltip, Classes.TranslatedString)
			end
		end
	end
	
	if not self.Variables then 
		self.Variables = {} 
	else
		for _,v in pairs(self.Variables) do
			setmetatable(v, VariableData)
			if v.DisplayName ~= nil and v.DisplayName.Handle ~= nil then
				setmetatable(v.DisplayName, Classes.TranslatedString)
			end
			if v.Tooltip ~= nil and v.Tooltip.Handle ~= nil then
				setmetatable(v.Tooltip, Classes.TranslatedString)
			end
		end
	end
	
	if not self.Buttons then 
		self.Buttons = {} 
	else
		for _,v in pairs(self.Buttons) do
			setmetatable(v, ButtonData)
			if v.DisplayName ~= nil and v.DisplayName.Handle ~= nil then
				setmetatable(v.DisplayName, Classes.TranslatedString)
			end
			if v.Tooltip ~= nil and v.Tooltip.Handle ~= nil then
				setmetatable(v.Tooltip, Classes.TranslatedString)
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
		return true
	end
	return false
end