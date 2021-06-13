if Ext.Version() < 55 then
	-- Intermediate update workaround - Still working on this system
	CustomStatSystem = {}
	function CustomStatSystem:OnToggleCharacterPane() end
	function CustomStatSystem:OnRequestTooltip() end
	function CustomStatSystem:UpdateStatTooltipArray() end
	function CustomStatSystem:AddAvailablePoints() end
	function CustomStatSystem:SyncData() end
	function CustomStatSystem:GetStatByDouble() end
	function CustomStatSystem:OnTooltip() end
	function CustomStatSystem:RegisterAvailablePointsChangedListener() end
	function CustomStatSystem:RegisterStatValueChangedListener() end
	function CustomStatSystem:RegisterCanAddPointsHandler() end
	function CustomStatSystem:RegisterCanRemovePointsHandler() end

	CustomStatSystem.__index = function(tbl,k)
		return function() end
	end
end