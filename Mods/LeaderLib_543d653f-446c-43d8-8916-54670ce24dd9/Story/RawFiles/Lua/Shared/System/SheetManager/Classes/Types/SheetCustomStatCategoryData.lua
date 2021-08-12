---@class SheetCustomStatCategoryData:SheetCustomStatBase
local SheetCustomStatCategoryData = {
	Type="SheetCustomStatCategoryData",
	ID = "",
	Mod = "",
	DisplayName = "",
	Description = "",
	Icon = "",
	ShowAlways = false,
	HideTotalPoints = false,
	TooltipType = "Stat",
	GroupId = nil,
}

SheetCustomStatCategoryData.__index = function(t,k)
	local v = Classes.SheetCustomStatBase[k]
	if v then
		t[k] = v
	end
	return v
end

--setmetatable(SheetCustomStatCategoryData, SheetCustomStatCategoryData)
Classes.SheetCustomStatCategoryData = SheetCustomStatCategoryData