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

Classes.ModSettingsClasses.VariableData = VariableData