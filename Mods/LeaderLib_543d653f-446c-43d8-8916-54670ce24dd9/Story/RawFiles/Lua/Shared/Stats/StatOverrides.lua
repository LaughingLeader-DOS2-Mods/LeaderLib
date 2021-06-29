local isClient = Ext.IsClient()

local skip_stats = {
	["StoryPlayer"] = true,
	["CasualPlayer"] = true,
	["NormalPlayer"] = true,
	["HardcorePlayer"] = true,
	["CasualNPC"] = true,
	["NormalNPC"] = true,
	["HardcoreNPC"] = true,
	["_Base"] = true,
	["_Hero"] = true,
	["PlaceholderStatEntry"] = true,
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
	["Player_Ifan"] = Ext.IsModLoaded("1301db3d-1f54-4e98-9be5-5094030916e4"),
	["Player_Lohse"] = Ext.IsModLoaded("1301db3d-1f54-4e98-9be5-5094030916e4"),
	["Player_RedPrince"] = Ext.IsModLoaded("1301db3d-1f54-4e98-9be5-5094030916e4"),
	["Player_Sebille"] = Ext.IsModLoaded("1301db3d-1f54-4e98-9be5-5094030916e4"),
	["Player_Beast"] = Ext.IsModLoaded("1301db3d-1f54-4e98-9be5-5094030916e4"),
	["Player_Fane"] = Ext.IsModLoaded("1301db3d-1f54-4e98-9be5-5094030916e4"),
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
---@param stat StatEntryCharacter
---@param attribute string
---@param nextVal number|integer|string|table
---@param syncMode boolean
local function AdjustStat(stat, attribute, nextVal, force)
	if stat[attribute] and (stat[attribute] ~= nextVal or force) then
		stat[attribute] = nextVal
	end
end

local forceStatuses = {
	"LEADERLIB_FORCE_PUSH1",
	"LEADERLIB_FORCE_PUSH2",
	"LEADERLIB_FORCE_PUSH3",
	"LEADERLIB_FORCE_PUSH4",
	"LEADERLIB_FORCE_PUSH5",
	"LEADERLIB_FORCE_PUSH6",
	"LEADERLIB_FORCE_PUSH7",
	"LEADERLIB_FORCE_PUSH8",
	"LEADERLIB_FORCE_PUSH9",
	"LEADERLIB_FORCE_PUSH10",
	"LEADERLIB_FORCE_PUSH11",
	"LEADERLIB_FORCE_PUSH12",
	"LEADERLIB_FORCE_PUSH13",
	"LEADERLIB_FORCE_PUSH14",
	"LEADERLIB_FORCE_PUSH15",
	"LEADERLIB_FORCE_PUSH16",
	"LEADERLIB_FORCE_PUSH17",
	"LEADERLIB_FORCE_PUSH18",
	"LEADERLIB_FORCE_PUSH19",
	"LEADERLIB_FORCE_PUSH20",
}

local function OverrideForce(syncMode, skills)
	for i,stat in pairs(forceStatuses) do
		if syncMode ~= true then
			Ext.StatSetAttribute(stat, "LeaveAction", "")
		else
			local statObj = Ext.GetStat(stat)
			if statObj then
				statObj.LeaveAction = ""
				Ext.SyncStat(stat, false)
			end
		end
	end
	if Vars.DebugMode then
		for _,v in pairs(skills) do
			---@type StatProperty[]
			local props = nil
			local statObj = nil
			if syncMode ~= true then
				props = Ext.StatGetAttribute(v, "SkillProperties")
			else
				statObj = Ext.GetStat(v)
				if statObj then
					props = statObj.SkillProperties
				end
			end
			if props then
				local hasForce = false
				for i,prop in pairs(props) do
					if prop.Type == "Force" then
						local dist = prop.Distance or 1.0
						hasForce = true
						props[i] = {
							Type = "Extender",
							Action = "SafeForce",
							Arg1 = dist,
							Arg2 =  6.0,
							Arg3 =  "",
							Arg4 =  -1,
							Arg5 =  -1,
							Context = {
								"Target",
								"AoE",
							}
						}
					end
				end
				if hasForce then
					if syncMode ~= true then
						Ext.StatSetAttribute(v, "SkillProperties", props)
					else
						statObj.SkillProperties = props
						Ext.SyncStat(v, false)
					end
				end
			end
		end
	end
end

local function AdjustAP(stat, settings)
	local changedStat = false
	if settings.Start > 0 then
		if AdjustStat(stat, "APStart", settings.Start) then
			changedStat = true
		end
	end
	if settings.Max > 0 then
		if AdjustStat(stat, "APMaximum", settings.Max) then
			changedStat = true
		end
	end
	if settings.Recovery > 0 then
		if AdjustStat(stat, "APRecovery", settings.Recovery) then
			changedStat = true
		end
	end
	return changedStat
end

---@param isServer boolean
---@param data LeaderLibGameSettings
---@param forceSync boolean|nil
local function OverrideStats(data)
	fprint(LOGLEVEL.DEFAULT, "[LeaderLib:SyncStatOverrides:%s] Syncing stat overrides from GameSettings.", isClient and "CLIENT" or "SERVER")
	if data == nil then
		data = GameSettingsManager.Load()
	end
	local skills = Ext.GetStatEntries("SkillData")
	--Ext.IsModLoaded("88d7c1d3-8de9-4494-be12-a8fcbc8171e9")
	if data.Settings.StarterTierSkillOverrides or data.Settings.LowerMemorizationRequirements then
		local originalSkillTiers = {}
		if not isClient then
			originalSkillTiers = PersistentVars["OriginalSkillTiers"] or {}
		end
		local total = 0
		--Ext.Print("[LeaderLib:StatOverrides.lua] Enabling skill tier overrides.")
		for _,id in pairs(skills) do
			local stat = Ext.GetStat(id)
			local tier = stat.Tier
			if data.Settings.StarterTierSkillOverrides == true then
				if not isClient then
					if originalSkillTiers[stat] ~= nil then
						tier = originalSkillTiers[stat]
					end
				end
				if CanChangeSkillTier(id, tier) then
					originalSkillTiers[id] = tier
					total = total + 1
					stat.Tier = "Starter"
					if not isClient then
						Ext.SyncStat(id, false)
					end
				end
			else
				originalSkillTiers[id] = tier
			end
			if data.Settings.LowerMemorizationRequirements == true then
				---@type StatRequirement[]
				local memorizationReq = Ext.StatGetAttribute(id, "MemorizationRequirements")
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
					stat.MemorizationRequirements = memorizationReq
					if not isClient then
						Ext.SyncStat(id, false)
					end
				end
			end
		end
		if not isClient then
			PersistentVars["OriginalSkillTiers"] = originalSkillTiers
		end
	end

	if data.Settings.APSettings.Player.Enabled then
		local settings = data.Settings.APSettings.Player
		for id,b in pairs(player_stats) do
			if b then
				local stat = Ext.GetStat(id)
				if stat then
					local changedStat = AdjustAP(stat, settings)
					if not isClient and changedStat then
						Ext.SyncStat(id, false)
					end
				end
			end
		end
	end
	if data.Settings.APSettings.NPC.Enabled then
		-- local base = {
		-- 	Max = Ext.StatGetAttribute("_Base", "APMaximum"),
		-- 	Start = Ext.StatGetAttribute("_Base", "APStart"),
		-- 	Recovery = Ext.StatGetAttribute("_Base", "APRecovery"),
		-- }
		local settings = data.Settings.APSettings.NPC
		for _,id in pairs(Ext.GetStatEntries("Character")) do
			local skip = skip_stats[id] == true or player_stats[id] ~= nil
			if not skip then
				local max = Ext.StatGetAttribute(id, "APMaximum")
				--local start = Ext.StatGetAttribute(id, "APStart")
				--local recovery = Ext.StatGetAttribute(id, "APRecovery")
				--This stat is overriding a base AP value, so skip since it could be a totem or boss etc
				--if max ~= base.Max or start ~= base.Start or recovery ~= base.Recovery then
				--Skip totems etc
				if max <= 1 then
					skip = true
				end
			end
			if not skip then
				local stat = Ext.GetStat(id)
				local changedStat = AdjustAP(stat, settings)
				if not isClient and changedStat then
					Ext.SyncStat(id, false)
				end
			end
		end
	end
	OverrideWings(not isClient)
	OverrideForce(not isClient, skills)
end
Ext.RegisterListener("StatsLoaded", OverrideStats)

function SyncStatOverrides(data, force)
	OverrideStats(data, force)
end