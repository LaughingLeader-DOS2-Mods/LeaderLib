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
	Value = 0
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