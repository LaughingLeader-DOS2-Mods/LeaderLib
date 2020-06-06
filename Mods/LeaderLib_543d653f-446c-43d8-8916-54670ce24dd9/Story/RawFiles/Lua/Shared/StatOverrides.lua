local ignore_skill_names = {
	Enemy = true,
	Quest = true,
	QUEST = true,
	NPC = true
}

local function CanChangeSkillTier(stat, tier)
	if Ext.StatGetAttribute(stat, "ForGameMaster") == "Yes" then
		if tier == "" or tier == "Starter" or tier == "None" then
			return false
		end
		if Ext.StatGetAttribute(stat, "IsEnemySkill") == "Yes" then
			return false
		end
		for str,b in pairs(ignore_skill_names) do
			if string.find(stat, str) then
				return false
			end
		end
		return true
	else
		return false
	end
end

local function OverrideStats()
	---@type LeaderLibGameSettings
	local data = LoadGameSettings()
	--Ext.IsModLoaded("88d7c1d3-8de9-4494-be12-a8fcbc8171e9")
	if data.Settings.StarterTierSkillOverrides == true then
		local originalSkillTiers = {}
		Ext.Print("[LeaderLib:StatOverrides.lua] Enabling skill tier overrides.")
		for _,stat in pairs(Ext.GetStatEntries("SkillData")) do
			local tier = Ext.StatGetAttribute(stat, "Tier")
			if CanChangeSkillTier(stat, tier) then
				originalSkillTiers[stat] = tier
				Ext.StatSetAttribute(stat, "Tier", "Starter")
				--PrintDebug("LeaderLib:StatOverrides.lua] Change Tier for skill ("..stat..") "..tier.." => Starter.")
			end
		end
		PersistentVars["OriginalSkillTiers"] = originalSkillTiers
	else
		PersistentVars["OriginalSkillTiers"] = nil
	end
end
Ext.RegisterListener("ModuleLoading", OverrideStats)