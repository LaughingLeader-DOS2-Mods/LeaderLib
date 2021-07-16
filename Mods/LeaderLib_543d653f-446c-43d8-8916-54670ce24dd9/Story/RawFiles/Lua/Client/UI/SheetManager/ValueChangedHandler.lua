local function OnPointsAdded(statType, ui, event, generatedId, ...)
	print(statType, event, generatedId, ...)
	local stat = SheetManager:GetStatByGeneratedID(generatedId, statType)
	if stat then
		if statType ~= "Talent" then
			stat:ModifyValue(Client:GetCharacter(), 1)
		else
			stat:SetValue(Client:GetCharacter(), true)
		end
	end
	-- if statType == "PrimaryStat" then
	-- elseif statType == "SecondaryStat" then
	-- elseif statType == "Ability" then
	-- elseif statType == "Talent" then
	-- end
end

local function OnPointsRemove(statType, ui, event, generatedId, ...)
	print(statType, event, generatedId, ...)
	local stat = SheetManager:GetStatByGeneratedID(generatedId, statType)
	if stat then
		if statType ~= "Talent" then
			stat:ModifyValue(Client:GetCharacter(), -1)
		else
			stat:SetValue(Client:GetCharacter(), false)
		end
	end
end

for t,v in pairs(SheetManager.Config.Calls.PointAdded) do
	local func = function(...)
		OnPointsAdded(t, ...)
	end
	Ext.RegisterUITypeCall(Data.UIType.characterSheet, v, func, "Before")
	Ext.RegisterUITypeCall(Data.UIType.characterCreation, v, func, "Before")
end
for t,v in pairs(SheetManager.Config.Calls.PointRemoved) do
	local func = function(...)
		OnPointsRemove(t, ...)
	end
	Ext.RegisterUITypeCall(Data.UIType.statsPanel_c, v, func, "Before")
	Ext.RegisterUITypeCall(Data.UIType.characterCreation_c, v, func, "Before")
end