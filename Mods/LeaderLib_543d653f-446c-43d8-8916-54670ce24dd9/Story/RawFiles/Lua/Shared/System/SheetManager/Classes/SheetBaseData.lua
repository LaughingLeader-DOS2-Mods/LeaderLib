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
end

Classes.SheetBaseData = SheetBaseData