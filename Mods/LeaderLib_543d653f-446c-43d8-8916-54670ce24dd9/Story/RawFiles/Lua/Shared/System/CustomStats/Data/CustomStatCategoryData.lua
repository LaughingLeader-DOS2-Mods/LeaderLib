---@class CustomStatCategoryData:CustomStatDataBase
local CustomStatCategoryData = {
	Type="CustomStatCategoryData",
	ID = "",
	Mod = "",
	DisplayName = "",
	Description = "",
	Icon = "",
	ShowAlways = false,
	TooltipType = "Stat",
	GroupId = nil,
}

CustomStatCategoryData.__index = function(t,k)
	local v = Classes.CustomStatDataBase[k]
	if v then
		t[k] = v
	end
	return v
end

--setmetatable(CustomStatCategoryData, CustomStatCategoryData)
Classes.CustomStatCategoryData = CustomStatCategoryData