if Ext.Version() < 55 then
	-- Intermediate update workaround - Still working on this system

	--Prevent EmmyLua from pointing towards here
	---@type table
	local placeholder = {}
	function placeholder:OnToggleCharacterPane() end
	function placeholder:OnRequestTooltip() end
	function placeholder:UpdateStatTooltipArray() end
	function placeholder:AddAvailablePoints() end
	function placeholder:SyncData() end
	function placeholder:GetStatByDouble() end
	function placeholder:OnTooltip() end
	function placeholder:RegisterAvailablePointsChangedListener() end
	function placeholder:RegisterStatValueChangedListener() end
	function placeholder:RegisterCanAddPointsHandler() end
	function placeholder:RegisterCanRemovePointsHandler() end

	--Stop coming back here, EmmyLua!
	_G["CustomStatSystem"] = placeholder

	placeholder.__index = function(tbl,k)
		return function() end
	end
end

--CustomStatSystem.DebugEnabled = true