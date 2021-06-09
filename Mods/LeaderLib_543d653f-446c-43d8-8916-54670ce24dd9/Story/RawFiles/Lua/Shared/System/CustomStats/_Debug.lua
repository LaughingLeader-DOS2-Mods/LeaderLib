if Ext.Version() < 55 then
	-- Intermediate update workaround - Still working on this system
	CustomStatSystem = {}
	CustomStatSystem.__index = CustomStatSystem
	function CustomStatSystem:OnToggleCharacterPane() end
	function CustomStatSystem:OnRequestTooltip() end
	function CustomStatSystem:UpdateStatTooltipArray() end
	function CustomStatSystem:AddAvailablePoints() end
	function CustomStatSystem:SyncData() end
	function CustomStatSystem:GetStatByDouble() end
	function CustomStatSystem:OnTooltip() end
end