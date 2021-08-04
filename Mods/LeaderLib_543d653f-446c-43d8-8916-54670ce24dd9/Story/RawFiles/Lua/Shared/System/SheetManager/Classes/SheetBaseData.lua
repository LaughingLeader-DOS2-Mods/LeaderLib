local isClient = Ext.IsClient()

---@class SheetBaseData:SheetBaseDataBase
local SheetBaseData = {
	Type="SheetBaseData",
	TooltipType = "Stat",
	ID = "",
	---@type MOD_UUID
	Mod = "",
	DisplayName = "",
	Description = "",
	Visible = true,
	Value = 0,
	---@type integer If set, this is the sort value number to use when the list of stats get sorted for display.
	SortValue = nil,
	---@type string If set, this is the name to use instead of DisplayName when the list of stats get sorted for display. 
	SortName = nil,
	---Optional setting to force the string key conversion for DisplayName, in case the value doesn't have an underscore.
	LoadStringKey = false,
	---A generated ID assigned by the SheetManager, used to associate a stat in the UI with this data.
	GeneratedID = -1
}

local defaults = {
	ID = "",
	Mod = "",
	DisplayName = "",
	Description = "",
	Icon = "",
	IconWidth = SheetBaseData.IconWidth,
	IconHeight = SheetBaseData.IconHeight,
	Visible = true,
	GeneratedID = -1
}

---@protected
function SheetBaseData.SetDefaults(data)
	for k,v in pairs(defaults) do
		if data[k] == nil then
			if type(v) == "table" then
				data[k] = {}
			else
				data[k] = v
			end
		end
	end
	if isClient then
		data.ListHolder = ""
	end
end

local function FormatText(txt, forceCheckForStringKey)
	if forceCheckForStringKey or string.find(txt, "_", 1, true) then
		txt = GameHelpers.GetStringKeyText(txt)
	end
	return GameHelpers.Tooltip.ReplacePlaceholders(txt)
end

function SheetBaseData:GetDisplayName()
	if self.DisplayName then
		return FormatText(self.DisplayName, self.LoadStringKey)
	end
	return self.ID
end

function SheetBaseData:GetDescription()
	if self.Description then
		local text = FormatText(self.Description, self.LoadStringKey)
		if self.Mod then
			local info = Ext.GetModInfo(self.Mod)
			if info and not StringHelpers.IsNullOrWhitespace(info.Name) then
				text = string.format("%s<br><font color='#2299FF' size='18'>(%s)</font>", text, info.Name)
			end
		end
		return text
	end
	return ""
end

Classes.SheetBaseData = SheetBaseData