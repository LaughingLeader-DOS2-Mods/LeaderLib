if Ext.IsServer() then
	Ext.Events.SessionLoading:Subscribe(function()
		if PersistentVars["OriginalSkillTiers"] ~= nil then
			Data.OriginalSkillTiers = PersistentVars["OriginalSkillTiers"]
		end
	end)
end

Ext.Events.SessionLoaded:Subscribe(function()
	Vars.LeaderDebugMode = GameHelpers.IO.LoadFile("LeaderDebug") ~= nil
	for stat in GameHelpers.Stats.GetStats("Object") do
		Data.ObjectStats[stat] = true
	end
	--Potions items work like object types in the EsvItem, where it doesn't have Stats set.
	for stat in GameHelpers.Stats.GetStats("Potion", true) do
		if not StringHelpers.IsNullOrWhitespace(stat.RootTemplate) then
			Data.ObjectStats[stat] = true
		end
	end
end, {Priority=400})

---@param uuid string
---@return ModSettings
function CreateModSettings(uuid)
	return SettingsManager.GetMod(uuid, true)
end