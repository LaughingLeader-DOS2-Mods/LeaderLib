local isClient = Ext.IsClient()

---@class SheetCustomStatBase
local SheetCustomStatBase = {
	Type="SheetCustomStatBase",
	---@type TooltipType
	TooltipType = "Stat",
	ID = "",
	---@type MOD_UUID
	Mod = "",
	DisplayName = "",
	Description = "",
	Visible = true,
	---@type integer If set, this is the sort value number to use when the list of stats get sorted for display.
	SortValue = nil,
	---@type string If set, this is the name to use instead of DisplayName when the list of stats get sorted for display. 
	SortName = nil,
	---Optional setting to force the string key conversion for DisplayName, in case the value doesn't have an underscore.
	LoadStringKey = false,
	Icon = "",
	IconWidth = 128,
	IconHeight = 128,
	ValueType = "number",
}
SheetCustomStatBase.__index = SheetCustomStatBase

local defaults = {
	TooltipType = SheetCustomStatBase.TooltipType,
	ID = SheetCustomStatBase.ID,
	Mod = SheetCustomStatBase.Mod,
	DisplayName = SheetCustomStatBase.DisplayName,
	Description = SheetCustomStatBase.Description,
	Visible = SheetCustomStatBase.Visible,
	SortValue = SheetCustomStatBase.SortValue,
	SortName = SheetCustomStatBase.SortName,
	LoadStringKey = SheetCustomStatBase.LoadStringKey,
	Icon = SheetCustomStatBase.Icon,
	IconWidth = SheetCustomStatBase.IconWidth,
	IconHeight = SheetCustomStatBase.IconWidth,
}

---@protected
function SheetCustomStatBase.SetDefaults(data)
	for k,v in pairs(defaults) do
		if data[k] == nil then
			if type(v) == "table" then
				data[k] = {}
			else
				data[k] = v
			end
		end
	end
end

local function FormatText(txt, forceCheckForStringKey)
	if forceCheckForStringKey or string.find(txt, "_", 1, true) then
		txt = GameHelpers.GetStringKeyText(txt)
	end
	return GameHelpers.Tooltip.ReplacePlaceholders(txt)
end

function SheetCustomStatBase:GetDisplayName()
	if self.DisplayName then
		return FormatText(self.DisplayName, self.LoadStringKey)
	end
	return self.ID
end

function SheetCustomStatBase:GetDescription()
	if self.Description then
		return FormatText(self.Description, self.LoadStringKey)
	end
	return ""
end

Classes.SheetCustomStatBase = SheetCustomStatBase