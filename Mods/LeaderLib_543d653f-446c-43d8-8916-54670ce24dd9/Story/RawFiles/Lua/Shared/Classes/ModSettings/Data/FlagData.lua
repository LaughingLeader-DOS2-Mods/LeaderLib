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

---@param listener ModSettingsFlagDataChangedListener|ModSettingsFlagDataChangedListener[]
function FlagData:AddListener(listener)
	local t = type(listener)
	if t == "function" then
		if Listeners.ModSettingsChanged[self.ID] == nil then
			Listeners.ModSettingsChanged[self.ID] = {}
		end
		table.insert(Listeners.ModSettingsChanged[self.ID], listener)
	elseif t == "table" then
		for i,v in pairs(listener) do
			self:AddListener(v)
		end
	else
		error(string.format("[LeaderLib:FlagData:AddListener(%s)] The listener param must be a function or table of functions. Type(%s)", self.ID, t))
	end
end

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

Classes.ModSettingsClasses.FlagData = FlagData