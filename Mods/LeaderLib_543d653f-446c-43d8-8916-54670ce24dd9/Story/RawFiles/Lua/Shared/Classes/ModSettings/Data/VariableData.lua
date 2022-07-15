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
	ClientSide = false,
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
		ClientSide = false,
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

---@param listener fun(e:ModSettingsChangedEventArgs|LeaderLibSubscribableEventArgs)
function VariableData:Subscribe(listener)
	local t = type(listener)
	if t == "function" then
		Events.ModSettingsChanged:Subscribe(listener, {MatchArgs={ID=self.ID}})
	else
		error(string.format("[LeaderLib:FlagData:Subscribe(%s)] The listener param must be a function. Type(%s)", self.ID, t))
	end
end

---@deprecated
---@param listener ModSettingsVariableDataChangedListener
function VariableData:AddListener(listener)
	local t = type(listener)
	if t == "function" then
		Events.ModSettingsChanged:Subscribe(function (e)
			listener(e.ID, e.Value, e.Data, e.Settings)
		end, {MatchArgs={ID=self.ID}})
	else
		error(string.format("[LeaderLib:VariableData:AddListener(%s)] The listener param must be a function. Type(%s)", self.ID, t))
	end
end

Classes.ModSettingsClasses.VariableData = VariableData