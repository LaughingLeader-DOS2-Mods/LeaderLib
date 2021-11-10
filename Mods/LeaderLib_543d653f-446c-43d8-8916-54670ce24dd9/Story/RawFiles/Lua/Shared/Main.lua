Ext.RegisterListener("SessionLoading", function()
	if Ext.IsServer() then
		if PersistentVars["OriginalSkillTiers"] ~= nil then
			Data.OriginalSkillTiers = PersistentVars["OriginalSkillTiers"]
		end
	end
end)

Ext.RegisterListener("SessionLoaded", function()
	Vars.LeaderDebugMode = Ext.LoadFile("LeaderDebug") ~= nil
	local count = #TranslatedStringEntries
	if TranslatedStringEntries ~= nil and count > 0 then
		for i,v in pairs(TranslatedStringEntries) do
			if v == nil then
				table.remove(TranslatedStringEntries, i)
			else
				local status,err = xpcall(function()
					v:Update()
				end, debug.traceback)
				if not status then
					Ext.PrintError("[LeaderLib:SessionLoaded] Error updating TranslatedString entry:")
					Ext.PrintError(err)
				end
			end
		end
		PrintDebug(string.format("[LeaderLib_Shared_SessionLoaded] Updated %s TranslatedString entries.", count))
	end
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