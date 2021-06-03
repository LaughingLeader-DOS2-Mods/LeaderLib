---@class CustomStatDataBase
local CustomStatDataBase = {
	Type="CustomStatDataBase",
	DisplayName = "",
	Description = ""
}
CustomStatDataBase.__index = CustomStatDataBase

local function FormatText(txt)
	if string.find(txt, "_", 1, true) then
		txt = GameHelpers.GetStringKeyText(txt)
	end
	return GameHelpers.Tooltip.ReplacePlaceholders(txt)
end

function CustomStatDataBase:GetDisplayName()
	if self.DisplayName then
		return FormatText(self.DisplayName)
	end
	return self.ID
end

function CustomStatDataBase:GetDescription()
	if self.Description then
		return FormatText(self.Description)
	end
	return ""
end

Classes.CustomStatDataBase = CustomStatDataBase