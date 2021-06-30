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

local isClient = Ext.IsClient()

if Vars.DebugMode then
	--CustomStatSystem.DebugEnabled = true
	if not isClient then
		Ext.RegisterConsoleCommand("clearavailablepoints", function()
			PersistentVars.CustomStatAvailablePoints = {}
			CustomStatSystem:SyncData()
		end)
	end

	local specialStats = {
		"Lucky",
		"Fear",
		"Pure",
		"RNGesus"
	}
	CustomStatSystem:RegisterAvailablePointsChangedListener("All", function(id, stat, character, previousPoints, currentPoints, isClientSide)
		fprint(LOGLEVEL.DEFAULT, "[OnAvailablePointsChanged:%s] Stat(%s) Character(%s) %s => %s [%s]", id, stat.UUID, character.DisplayName, previousPoints, currentPoints, isClientSide and "CLIENT" or "SERVER")
	end)
	CustomStatSystem:RegisterStatValueChangedListener("All", function(id, stat, character, previousPoints, currentPoints, isClientSide)
		fprint(LOGLEVEL.DEFAULT, "[OnStatValueChanged:%s] Stat(%s) Character(%s) %s => %s [%s]", id, stat.UUID, character.DisplayName, previousPoints, currentPoints, isClientSide and "CLIENT" or "SERVER")
	end)
	if isClient then
		CustomStatSystem:RegisterCanAddPointsHandler(specialStats, function(id, stat, character, current, availablePoints, canAdd)
			return canAdd or (availablePoints > 0 and current < 5)
		end)
		CustomStatSystem:RegisterCanRemovePointsHandler("Lucky", function(id, stat, character, current, canRemove)
			return canRemove or current > 0
		end)
		-- CustomStatSystem:RegisterCanAddPointsHandler("All", function(id, stat, character, current, availablePoints, canAdd)
		-- 	return true
		-- end)
		-- CustomStatSystem:RegisterCanRemovePointsHandler("All", function(id, stat, character, current, canRemove)
		-- 	return true
		-- end)
	end
end

--CustomStatSystem.DebugEnabled = true