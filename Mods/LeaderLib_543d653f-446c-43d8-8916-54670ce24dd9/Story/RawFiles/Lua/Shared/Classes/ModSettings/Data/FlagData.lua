---@class FlagData
local FlagData = {
	Type = "FlagData",
	---@type LeaderLibGlobalSettingsFlagType
	FlagType = "Global",
	ID = "",
	Targets = nil,
	Enabled = false,
	Default = false,
	DisplayName = nil,
	Tooltip = nil,
	DebugOnly = false,
	CanExport = true,
	ClientSide = false,
	IsFromFile = false
}

FlagData.__index = FlagData

---@param flag string
---@param flagType LeaderLibGlobalSettingsFlagType
---@param enabled boolean
function FlagData:Create(flag, flagType, enabled, displayName, tooltip, isFromFile)
    local this =
    {
		ID = flag,
		FlagType = flagType or "Global",
		Enabled = false,
		IsFromFile = false,
		DebugOnly = false,
		CanExport = true,
		ClientSide = false,
		Default = false
	}
	if enabled ~= nil then
		this.Enabled = enabled
	end
	if isFromFile ~= nil then
		this.IsFromFile = isFromFile
	end
	--An "inverse" flag. It'll display as being checked when the global flag isn't actually set.
	if string.find(string.lower(flag), "disable") then
		this.Default = true
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

---@param listener fun(e:ModSettingsFlagChangedEventArgs|LeaderLibSubscribableEventArgs)
function FlagData:Subscribe(listener)
	local t = type(listener)
	if t == "function" then
		Events.ModSettingsChanged:Subscribe(listener, {MatchArgs={ID=self.ID}})
	else
		error(string.format("[LeaderLib:FlagData:Subscribe(%s)] The listener param must be a function or table of functions. Type(%s)", self.ID, t))
	end
end

---@deprecated
---@param listener ModSettingsFlagDataChangedListener|ModSettingsFlagDataChangedListener[]
function FlagData:AddListener(listener)
	local t = type(listener)
	if t == "function" then
		Events.ModSettingsChanged:Subscribe(function (e)
			listener(e.ID, e.Value, e.Data, e.Settings)
		end, {MatchArgs={ID=self.ID}})
	else
		error(string.format("[LeaderLib:FlagData:AddListener(%s)] The listener param must be a function or table of functions. Type(%s)", self.ID, t))
	end
end

function FlagData:AddTarget(id, enabled)
	if not id then
		return
	end
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