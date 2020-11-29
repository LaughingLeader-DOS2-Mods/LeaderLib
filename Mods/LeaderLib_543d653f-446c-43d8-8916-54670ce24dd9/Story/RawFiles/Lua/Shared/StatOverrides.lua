local boost_stats = {
	["StoryPlayer"] = true,
	["CasualPlayer"] = true,
	["NormalPlayer"] = true,
	["HardcorePlayer"] = true,
	["CasualNPC"] = true,
	["NormalNPC"] = true,
	["HardcoreNPC"] = true,
}

local player_stats = {
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
	["Player_Ifan"] = true,
	["Player_Lohse"] = true,
	["Player_RedPrince"] = true,
	["Player_Sebille"] = true,
	["Player_Beast"] = true,
	["Player_Fane"] = true,
}

local ignore_skill_names = {
	Enemy = true,
	Quest = true,
	QUEST = true,
	NPC = true
}

local ignoreSkills = {
	-- ArmorSets skill with a tier set. Unused
	Projectile_CON00_SetBonus = true
}

local function CanChangeSkillTier(stat, tier)
	if ignoreSkills[stat] == true then
		return false
	end
	if Ext.StatGetAttribute(stat, "ForGameMaster") == "Yes" and Ext.StatGetAttribute(stat, "Ability") ~= "None" then
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
	end
	return false
end

-- Adds more alignment entities
Ext.AddPathOverride("Mods/DivinityOrigins_1301db3d-1f54-4e98-9be5-5094030916e4/Story/Alignments/Alignment.lsx", "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Overrides/OriginsAlignments.lsx")

---Modifies a stat if it differs from the desired value.
---@param stat string
---@param attribute string
---@param nextVal number|integer|string|table
---@param syncMode boolean
local function AdjustStat(stat, attribute, nextVal, syncMode, forceSync)
	local currentValue = Ext.StatGetAttribute(stat, attribute)
	if currentValue ~= nil and currentValue ~= nextVal then
		if syncMode ~= true then
			Ext.StatSetAttribute(stat, attribute, nextVal)
		else
			local statObj = Ext.GetStat(stat)
			statObj[attribute] = nextVal
			Ext.SyncStat(stat, false)
		end
	elseif syncMode == true and forceSync == true then
		local statObj = Ext.GetStat(stat)
		statObj[attribute] = nextVal
		Ext.SyncStat(stat, false)
	end
end

---@param syncMode boolean
---@param data LeaderLibGameSettings
local function OverrideStats(syncMode, data, forceSync)
	Ext.Print("[LeaderLib:SyncStatOverrides] Syncing stat overrides from GameSettings. SyncMode:", syncMode)
	if data == nil then
		data = LoadGameSettings()
	end
	--Ext.IsModLoaded("88d7c1d3-8de9-4494-be12-a8fcbc8171e9")
	if data.Settings.StarterTierSkillOverrides == true then
		local originalSkillTiers = {}
		if Ext.IsServer() then
			originalSkillTiers = PersistentVars["OriginalSkillTiers"] or {}
		end
		local total = 0
		--Ext.Print("[LeaderLib:StatOverrides.lua] Enabling skill tier overrides.")
		for _,stat in pairs(Ext.GetStatEntries("SkillData")) do
			local tier = Ext.StatGetAttribute(stat, "Tier")
			if syncMode then
				if originalSkillTiers[stat] ~= nil then
					tier = originalSkillTiers[stat]
				end
			end
			if CanChangeSkillTier(stat, tier) then
				originalSkillTiers[stat] = tier
				total = total + 1
				if syncMode ~= true then
					Ext.StatSetAttribute(stat, "Tier", "Starter")
				else
					local statObj = Ext.GetStat(stat)
					statObj.Tier = "Starter"
					Ext.SyncStat(stat, false)
				end
				--PrintDebug("LeaderLib:StatOverrides.lua] Change Tier for skill ("..stat..") "..tier.." => Starter.")
			end
			if data.Settings.LowerMemorizationRequirements == true then
				---@type StatRequirement[]
				local memorizationReq = Ext.StatGetAttribute(stat, "MemorizationRequirements")
				local changed = false
				if memorizationReq ~= nil then
					for i,v in pairs(memorizationReq) do
						if Data.AbilityEnum[v.Requirement] ~= nil and v.Param > 1 then
							v.Param = 1
							changed = true
						end
					end
				end
				if changed then
					if syncMode ~= true then
						Ext.StatSetAttribute(stat, "MemorizationRequirements", memorizationReq)
					else
						local statObj = Ext.GetStat(stat)
						statObj.MemorizationRequirements = memorizationReq
						Ext.SyncStat(stat, false)
					end
				end
			end
		end
		if total > 0 then
			Ext.Print("LeaderLib:StatOverrides.lua] Change skill tier to Starter for ("..tostring(total)..") skills.")
		else
			Ext.PrintWarning("LeaderLib:StatOverrides.lua] No skills that need Tier changes found.")
		end
		if Ext.IsServer() then
			PersistentVars["OriginalSkillTiers"] = originalSkillTiers
		end
	else
		if data.Settings.LowerMemorizationRequirements == true then
			for _,stat in pairs(Ext.GetStatEntries("SkillData")) do
				---@type StatRequirement[]
				local memorizationReq = Ext.StatGetAttribute(stat, "MemorizationRequirements")
				local changed = false
				if memorizationReq ~= nil then
					for i,v in pairs(memorizationReq) do
						if Data.AbilityEnum[v.Requirement] ~= nil and v.Param > 1 then
							v.Param = 1
							changed = true
						end
					end
				end
				if changed then
					if syncMode ~= true then
						Ext.StatSetAttribute(stat, "MemorizationRequirements", memorizationReq)
					else
						local statObj = Ext.GetStat(stat)
						statObj.MemorizationRequirements = memorizationReq
						Ext.SyncStat(stat, false)
					end
				end
			end
		end
		if Ext.IsServer() then
			PersistentVars["OriginalSkillTiers"] = nil
		end
	end

	if data.Settings.APSettings.Player.Enabled then
		local settings = data.Settings.APSettings.Player
		for stat,_ in pairs(player_stats) do
			if settings.Start > 0 then
				AdjustStat(stat, "APStart", settings.Start, syncMode)
			end
			if settings.Max > 0 then
				AdjustStat(stat, "APMaximum", settings.Max, syncMode)
			end
			if settings.Recovery > 0 then
				AdjustStat(stat, "APRecovery", settings.Recovery, syncMode)
			end
		end
	end
	if data.Settings.APSettings.NPC.Enabled then
		local settings = data.Settings.APSettings.NPC
		for _,stat in pairs(Ext.GetStatEntries("Character")) do
			local skip = player_stats[stat] == true or boost_stats[stat] == true
			if not skip then
				if settings.Start > 0 then
					AdjustStat(stat, "APStart", settings.Start, syncMode, forceSync)
				end
				if settings.Max > 0 then
					AdjustStat(stat, "APMaximum", settings.Max, syncMode, forceSync)
				end
				if settings.Recovery > 0 then
					AdjustStat(stat, "APRecovery", settings.Recovery, syncMode, forceSync)
				end
			end
		end
	end
	OverrideWings(syncMode)
end
Ext.RegisterListener("StatsLoaded", OverrideStats)

function SyncStatOverrides(data, forceSync)
	OverrideStats(Ext.IsServer(), data, forceSync)
end