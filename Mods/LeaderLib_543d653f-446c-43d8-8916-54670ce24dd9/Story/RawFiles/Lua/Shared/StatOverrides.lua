local player_stats = {
	--["_Base"] = true,
	["_Hero"] = true,
	["HumanFemaleHero"] = true,
	["HumanMaleHero"] = true,
	["DwarfFemaleHero"] = true,
	["DwarfMaleHero"] = true,
	["ElfFemaleHero"] = true,
	["ElfMaleHero"] = true,
	["LizardFemaleHero"] = true,
	["LizardMaleHero"] = true,
	["HumanUndeadFemaleHero"] = true,
	["HumanUndeadMaleHero"] = true,
	["DwarfUndeadFemaleHero"] = true,
	["DwarfUndeadMaleHero"] = true,
	["ElfUndeadFemaleHero"] = true,
	["ElfUndeadMaleHero"] = true,
	["LizardUndeadFemaleHero"] = true,
	["LizardUndeadMaleHero"] = true,
	["_Companions"] = true,
	["StoryPlayer"] = true,
	["CasualPlayer"] = true,
	["NormalPlayer"] = true,
	["HardcorePlayer"] = true,
	["Player_Ifan"] = true,
	["Player_Lohse"] = true,
	["Player_RedPrince"] = true,
	["Player_Sebille"] = true,
	["Player_Beast"] = true,
	["Player_Fane"] = true,
	--["Summon_Earth_Ooze_Player"] = true,
}

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
		if Ext.IsServer() then
			PersistentVars["OriginalSkillTiers"] = originalSkillTiers
		end
	else
		if Ext.IsServer() then
			PersistentVars["OriginalSkillTiers"] = nil
		end
	end

	if data.Settings.MaxAPForPlayers > 0 then
		
	end

	if data.Settings.MaxAP > 0 then
		local apGroups = data.Settings.MaxAPGroup:lower()
		if string.find(apGroups, "all") then
			Ext.Print("[LeaderLib:StatOverrides.lua] Enabled Max AP override ("..tostring(data.Settings.MaxAP)..") for all characters.")
			for _,stat in pairs(Ext.GetStatEntries("Character")) do
				local maxAP = Ext.StatGetAttribute(stat, "APMaximum")
				if maxAP < data.Settings.MaxAP then
					Ext.StatSetAttribute(stat, "APMaximum", data.Settings.MaxAP)
				end
			end
		else
			if string.find(apGroups, "player") then
				Ext.Print("[LeaderLib:StatOverrides.lua] Enabled Max AP override ("..tostring(data.Settings.MaxAP)..") for players.")
				for stat,_ in pairs(player_stats) do
					local maxAP = Ext.StatGetAttribute(stat, "APMaximum")
					if maxAP < data.Settings.MaxAP then
						Ext.StatSetAttribute(stat, "APMaximum", data.Settings.MaxAP)
					end
				end
			end
			if string.find(apGroups, "npc") then
				Ext.Print("[LeaderLib:StatOverrides.lua] Enabled Max AP override ("..tostring(data.Settings.MaxAP)..") for non-player characters.")
				for _,stat in pairs(Ext.GetStatEntries("Character")) do
					local skip = not string.find(apGroups, "player") and player_stats[stat] == true
					if not skip then
						local maxAP = Ext.StatGetAttribute(stat, "APMaximum")
						if maxAP < data.Settings.MaxAP then
							Ext.StatSetAttribute(stat, "APMaximum", data.Settings.MaxAP)
						end
					end
				end
			end
		end
	end
end
Ext.RegisterListener("ModuleLoading", OverrideStats)