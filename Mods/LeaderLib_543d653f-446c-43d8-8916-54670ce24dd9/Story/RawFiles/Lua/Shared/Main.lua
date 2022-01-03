Ext.RegisterListener("SessionLoading", function()
	if Ext.IsServer() then
		if PersistentVars["OriginalSkillTiers"] ~= nil then
			Data.OriginalSkillTiers = PersistentVars["OriginalSkillTiers"]
		end
	end
end)

Ext.RegisterListener("SessionLoaded", function()
	Vars.LeaderDebugMode = Ext.LoadFile("LeaderDebug") ~= nil
	for _,stat in pairs(Ext.GetStatEntries("Object")) do
		Data.ObjectStats[stat] = true
	end
	--Potions items work like object types in the EsvItem, where it doesn't have Stats set.
	for _,stat in pairs(Ext.GetStatEntries("Potion")) do
		if not StringHelpers.IsNullOrWhitespace(Ext.StatGetAttribute(stat, "RootTemplate")) then
			Data.ObjectStats[stat] = true
		end
	end
end)

---@param uuid string
---@return ModSettings
function CreateModSettings(uuid)
	return SettingsManager.GetMod(uuid, true)
end