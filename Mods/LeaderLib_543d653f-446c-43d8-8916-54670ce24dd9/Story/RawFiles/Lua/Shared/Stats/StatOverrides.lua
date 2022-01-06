local isClient = Ext.IsClient()

local skipCharacterStats = {
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

local playerStats = {
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
	["Player_Ifan"] = "1301db3d-1f54-4e98-9be5-5094030916e4",
	["Player_Lohse"] = "1301db3d-1f54-4e98-9be5-5094030916e4",
	["Player_RedPrince"] = "1301db3d-1f54-4e98-9be5-5094030916e4",
	["Player_Sebille"] = "1301db3d-1f54-4e98-9be5-5094030916e4",
	["Player_Beast"] = "1301db3d-1f54-4e98-9be5-5094030916e4",
	["Player_Fane"] = "1301db3d-1f54-4e98-9be5-5094030916e4",
}

local _loadedStatuses = {}

---@param stat StatEntrySkillData
local _SkillPropertiesActionMissing = function (stat)
	for i,v in pairs(stat.SkillProperties) do
		if not _loadedStatuses[v.Action] then
			return true
		end
	end
	return false
end

local StatFixes = {
	--Original: "Burning,0,2;Melt" - Seems like it was meant to not apply BURNING, but Burning isn't a status.
	Projectile_TrapEarthballNoIgnite = {
		---@param stat StatEntrySkillData
		CanChange = _SkillPropertiesActionMissing,
		Changes = {
			SkillProperties = {{
				Action = "Melt",
				Context = {"AoE", "Target"},
				Lifetime = 0.0,
				Radius = -1.0,
				StatusChance = 0.0,
				SurfaceChance = 1.0,
				Type = "SurfaceChange",
			}}
		}
	},
	--Original: "EMPTY". This isn't a status.
	Rain_EnemyWater_Blessed = {
		CanChange = _SkillPropertiesActionMissing,
		Changes = {
			SkillProperties = {}
		}
	},
	--Original: OILED,100,1 - OILED isn't a status.
	Rain_Oil = {
		CanChange = _SkillPropertiesActionMissing,
		Changes = {
			SkillProperties = {{
				Type = "Status",
				Action = "SLOWED",
				Context = {"AoE", "Target"},
				Duration = 6.0,
				StatusChance = 1.0,
				StatsId = "",
				Arg4 = -1,
				Arg5 = -1,
				SurfaceBoost = false
			}}
		}
	},
	--Original: MARK_OF_DEATH,100,3. This isn't a status that exists, so we swap to LIVING_BOMB.
	Target_EnemyMarkOfDeath = {
		CanChange = _SkillPropertiesActionMissing,
		Changes = {
			SkillProperties = {{
				Type = "Status",
				Action = "LIVING_BOMB",
				Context = {"AoE", "Target"},
				Duration = 18.0,
				StatusChance = 1.0,
				StatsId = "",
				Arg4 = -1,
				Arg5 = -1,
				SurfaceBoost = false
			}}
		}
	},
	--Original: "_Vitality_ShieldBoost". This isn't a status that exists.
	WPN_UNIQUE_WithermooreShield = {
		CanChange = function (stat)
			for i,v in pairs(stat.ExtraProperties) do
				if not _loadedStatuses[v.Action] then
					return true
				end
			end
			return false
		end,
		Changes = {
			ExtraProperties = {},
			VitalityBoost = "20",
		}
	},
}

Vars.StatFixes = StatFixes

local ignoreSkillNames = {
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
		for str,b in pairs(ignoreSkillNames) do
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
Ext.AddPathOverride("Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Stats/Generated/Data/LeaderLib_Skills_SafeForce.txt", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Stats/Overrides/LeaderLib_Skills_SafeForce.txt")

---Modifies a stat if it differs from the desired value.
---@param stat StatEntryCharacter
---@param attribute string
---@param nextVal number|integer|string|table
---@param force boolean
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
	--[[ if Vars.DebugMode then
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
						---@type StatPropertyExtender
						local extProp = {
							Type = "Extender",
							Action = "SafeForce",
							Arg1 = 1,
							Arg2 =  Ext.Round(dist * 6),
							Arg3 =  "",
							Arg4 =  -1,
							Arg5 =  -1,
							Context = {
								"Target",
								"AoE",
							}
						}
						props[i] = extProp
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
	end ]]
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

---@param data LeaderLibGameSettings
---@param statsLoadedState boolean
local function OverrideStats(data, statsLoadedState)
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
					if not isClient and not statsLoadedState then
						Ext.SyncStat(id, false)
					else
						Ext.StatSetAttribute(id, "Tier", "Starter")
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
						if Data.AbilityEnum[v.Requirement] ~= nil and type(v.Param) == "number" and v.Param > 1 then
							v.Param = 1
							changed = true
						end
					end
				end
				if changed then
					stat.MemorizationRequirements = memorizationReq
					if not isClient and not statsLoadedState then
						Ext.SyncStat(id, false)
					else
						Ext.StatSetAttribute(id, "MemorizationRequirements", memorizationReq)
					end
				end
			end
		end
		if not isClient then
			---@private
			PersistentVars["OriginalSkillTiers"] = originalSkillTiers
		end
	end

	if data.Settings.APSettings.Player.Enabled then
		local settings = data.Settings.APSettings.Player
		for id,b in pairs(playerStats) do
			if b == true or (type(b) == "string" and Ext.IsModLoaded(b)) then
				---@type StatEntryCharacter
				local stat = Ext.GetStat(id)
				if stat then
					local changedStat = AdjustAP(stat, settings)
					if changedStat then
						if not isClient and not statsLoadedState then
							Ext.SyncStat(id, false)
						else
							Ext.StatSetAttribute(id, "APStart", stat.APStart)
							Ext.StatSetAttribute(id, "APRecovery", stat.APRecovery)
							Ext.StatSetAttribute(id, "APRecovery", stat.APMaximum)
						end
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
			local skip = skipCharacterStats[id] == true or playerStats[id] ~= nil
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
				if changedStat then
					if not isClient and not statsLoadedState then
						Ext.SyncStat(id, false)
					else
						Ext.StatSetAttribute(id, "APStart", stat.APStart)
						Ext.StatSetAttribute(id, "APRecovery", stat.APRecovery)
						Ext.StatSetAttribute(id, "APRecovery", stat.APMaximum)
					end
				end
			end
		end
	end

	for _,v in pairs(Ext.GetStatEntries("StatusData")) do
		_loadedStatuses[v] = true
		local statusType = Ext.StatGetAttribute(v, "StatusType")
		if statusType then
			Data.StatusToType[v] = statusType
		end
	end

	OverrideWings(not isClient and not statsLoadedState)
	OverrideForce(not isClient and not statsLoadedState, skills)

	for statId,data in pairs(StatFixes) do
		local stat = Ext.GetStat(statId)
		if stat and data.CanChange(stat) then
			for attribute,value in pairs(data.Changes) do
				if not isClient and not statsLoadedState then
					stat[attribute] = value
				else
					Ext.StatSetAttribute(statId, attribute, value)
				end
			end
			if not isClient and not statsLoadedState then
				Ext.SyncStat(statId, false)
			end
		end
	end

	_loadedStatuses = {}
end

Ext.RegisterListener("StatsLoaded", function()
	OverrideStats(nil, false)
end)

function SyncStatOverrides(data, force)
	OverrideStats(data)
end