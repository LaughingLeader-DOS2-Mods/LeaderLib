---@class CustomStatDataBase
local CustomStatDataBase = {
	Type="CustomStatDataBase",
	DisplayName = "",
	Description = "",
	Visible = true,
	---@type integer If set, this is the sort value number to use when the list of stats get sorted for display.
	SortValue = nil,
	---@type string If set, this is the name to use instead of DisplayName when the list of stats get sorted for display. 
	SortName = nil,
	---Optional setting to force the string key conversion for DisplayName, in case the value doesn't have an underscore.
	LoadStringKey = false,
}
CustomStatDataBase.__index = CustomStatDataBase

local function FormatText(txt, forceCheckForStringKey)
	if forceCheckForStringKey or string.find(txt, "_", 1, true) then
		txt = GameHelpers.GetStringKeyText(txt)
	end
	return GameHelpers.Tooltip.ReplacePlaceholders(txt)
end

function CustomStatDataBase:GetDisplayName()
	if self.DisplayName then
		return FormatText(self.DisplayName, self.LoadStringKey)
	end
	return self.ID
end

function CustomStatDataBase:GetDescription()
	if self.Description then
		return FormatText(self.Description, self.LoadStringKey)
	end
	return ""
end

Classes.CustomStatDataBase = CustomStatDataBase