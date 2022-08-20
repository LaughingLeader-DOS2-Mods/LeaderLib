---@class ButtonData
local ButtonData = {
	Type = "ButtonData",
	ID = "",
	Enabled = true,
	---@type ModMenuButtonCallback|ModMenuButtonCallback[]
	Callback = nil,
	HostOnly = false,
	DisplayName = nil,
	Tooltip = nil,
	IsFromFile = false
}

ButtonData.__index = ButtonData

---@param id string
---@param callback ModMenuButtonCallback|ModMenuButtonCallback[]
---@param enabled boolean
---@param displayName string|nil
---@param tooltip string|nil
---@param isFromFile boolean|nil
---@param hostOnly boolean|nil
function ButtonData:Create(id, callback, enabled, displayName, tooltip, hostOnly, isFromFile)
    local this =
    {
		ID = id,
		Callback = callback,
		Enabled = enabled,
		IsFromFile = false
	}
	if isFromFile ~= nil then
		this.IsFromFile = isFromFile
	end
	if displayName ~= nil then
		this.DisplayName = displayName
	end
	if tooltip ~= nil then
		this.Tooltip = tooltip
	end
	if hostOnly ~= nil then
		this.HostOnly = hostOnly
	end
	setmetatable(this, self)
    return this
end

--Supports a control's Value being either a function, or an array of functions.
---@param callback ModMenuButtonCallback|ModMenuButtonCallback[]
local function TryInvokeFunctions(callback, ...)
	local t = type(callback)
	if t == "function" then
		local b,result = xpcall(callback, debug.traceback, ...)
		if not b then
			Ext.Utils.PrintError(result)
		end
	elseif t == "table" then
		for _,c2 in pairs(callback) do
			TryInvokeFunctions(c2, ...)
		end
	end
end

-- Invokes any callbacks with whatever parameters passed in.
function ButtonData:Invoke(...)
    TryInvokeFunctions(self.Callback, ...)
end

Classes.ModSettingsClasses.ButtonData = ButtonData