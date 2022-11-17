local _ISCLIENT = Ext.IsClient()

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
		if v.Type == "Status" and not _loadedStatuses[v.Action] then
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
	--Original: "EMPTY". This isn't a status.
	Target_Quest_DemonicPossession_Kill = {
		--Divinity: Original Sin 2 Campaign
		Mod = "1301db3d-1f54-4e98-9be5-5094030916e4",
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

	--Displays the wrong damage range
	Target_FlamingCrescendo = {
		CanChange = function (stat)
			return stat.StatsDescriptionParams == "Weapon:Skill_FlamingCrescendo:Damage"
		end,
		Changes = {
			StatsDescriptionParams = "Skill:Projectile_FlamingCrescendo_Explosion:Damage"
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
			VitalityBoost = 20,
		}
	},
}

StatFixes.Target_EnemyFlamingCrescendo = StatFixes.Target_FlamingCrescendo

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

Ext.IO.AddPathOverride("Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Stats/Generated/Data/LeaderLib_Skills_Force.txt", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Stats/Overrides/LeaderLib_Skills_SafeForce.txt")

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

local function OverrideForce(shouldSync)
	for i,statId in pairs(forceStatuses) do
		local stat = Ext.Stats.Get(statId, nil, false)
		if stat then
			stat.LeaveAction = ""
			if shouldSync then
				Ext.Stats.Sync(statId, false)
			end
		end
	end
	--[[ if Vars.DebugMode and Ext.GetGameState() == "Running" then
		for stat in GameHelpers.Stats.GetSkills(true) do
			---@type StatProperty[]
			local props = GameHelpers.Stats.GetSkillProperties(stat)
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
							Context = TableHelpers.Clone(prop.Context)
						}
						props[i] = extProp
					end
				end
				if hasForce then
					stat.SkillProperties = props
					if shouldSync then
						Ext.Stats.Sync(stat.Name, false)
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

---@param gameSettings LeaderLibGameSettings|nil
---@param statsLoadedState boolean|nil
local function _OverrideStats(gameSettings, statsLoadedState)
	local shouldSync = not _ISCLIENT and not statsLoadedState
	--fprint(LOGLEVEL.TRACE, "[LeaderLib:SyncStatOverrides:%s] Syncing stat overrides from GameSettings.", isClient and "CLIENT" or "SERVER")
	if gameSettings == nil then
		gameSettings = GameSettingsManager.GetSettings()
	end
	if not gameSettings then
		ferror("[LeaderLib:OverrideStats:%s] Failed to load game settings.", _ISCLIENT and "CLIENT" or "SERVER")
	end
	--Ext.Mod.IsModLoaded("88d7c1d3-8de9-4494-be12-a8fcbc8171e9")
	if gameSettings.StarterTierSkillOverrides or gameSettings.LowerMemorizationRequirements then
		local originalSkillTiers = {}
		if not _ISCLIENT then
			originalSkillTiers = _PV["OriginalSkillTiers"] or {}
		end
		local total = 0
		--Ext.Utils.Print("[LeaderLib:StatOverrides.lua] Enabling skill tier overrides.")
		for id in GameHelpers.Stats.GetSkills() do
			local stat = Ext.Stats.Get(id, nil, false)
			if stat then
				local tier = stat.Tier
				if gameSettings.StarterTierSkillOverrides == true then
					if not _ISCLIENT then
						if originalSkillTiers[stat] ~= nil then
							tier = originalSkillTiers[stat]
						end
					end
					if CanChangeSkillTier(id, tier) then
						originalSkillTiers[id] = tier
						total = total + 1
						stat.Tier = "Starter"
						if shouldSync then
							Ext.Stats.Sync(id, false)
						end
					end
				else
					originalSkillTiers[id] = tier
				end
				if gameSettings.LowerMemorizationRequirements == true then
					---@type StatRequirement[]
					local memorizationReq = stat.MemorizationRequirements
					local changed = false
					if memorizationReq ~= nil then
						for i,v in pairs(memorizationReq) do
							if Data.Ability[v.Requirement] ~= nil and type(v.Param) == "number" and v.Param > 1 then
								v.Param = 1
								changed = true
							end
						end
					end
					if changed then
						stat.MemorizationRequirements = memorizationReq
						if shouldSync then
							Ext.Stats.Sync(id, false)
						end
					end
				end
			end
		end
		if not _ISCLIENT then
			---@private
			_PV["OriginalSkillTiers"] = originalSkillTiers
		end
	end

	if Vars.Overrides.SPIRIT_VISION_PROPERTY ~= nil then
		--LeaderLib_PermanentSpiritVisionEnabled
		local spiritVision = Ext.Stats.Get("Shout_SpiritVision", nil, false)
		if spiritVision then
			local toggleProp = Vars.Overrides.SPIRIT_VISION_PROPERTY
			local properties = GameHelpers.Stats.GetSkillProperties(spiritVision)
			local newProps = {toggleProp}
			if properties and #properties > 0 then
				for _,v in pairs(properties) do
					if v.Type == "Status" and v.Action == "SPIRIT_VISION" then
						toggleProp.Arg5 = v.Duration
					end
					if (v.Type ~= "Status" or v.Action ~= "SPIRIT_VISION") and v.Action ~= toggleProp.Action then
						newProps[#newProps+1] = v
					end
				end
			end
			spiritVision.SkillProperties = newProps
			--Safeguard
			if spiritVision.SkillProperties == nil or #spiritVision.SkillProperties == 0 then
				spiritVision.SkillProperties = properties
			end
			spiritVision.Stealth = "Yes" -- Let the status be toggled on/off while in stealth
			if shouldSync then
				Ext.Stats.Sync("Shout_SpiritVision", false)
			end
		end
	end

	if gameSettings.APSettings.Player.Enabled then
		local settings = gameSettings.APSettings.Player
		for id,b in pairs(playerStats) do
			if b == true or (type(b) == "string" and Ext.Mod.IsModLoaded(b)) then
				---@type StatEntryCharacter
				local stat = Ext.Stats.Get(id, nil, false)
				if stat then
					local changedStat = AdjustAP(stat, settings)
					if changedStat and shouldSync then
						Ext.Stats.Sync(id, false)
					end
				end
			end
		end
	end
	if gameSettings.APSettings.NPC.Enabled then
		-- local base = {
		-- 	Max = Ext.StatGetAttribute("_Base", "APMaximum"),
		-- 	Start = Ext.StatGetAttribute("_Base", "APStart"),
		-- 	Recovery = Ext.StatGetAttribute("_Base", "APRecovery"),
		-- }
		local settings = gameSettings.APSettings.NPC
		for _,id in pairs(Ext.Stats.GetStats("Character")) do
			local stat = Ext.Stats.Get(id, nil, false)
			local skip = skipCharacterStats[id] == true or playerStats[id] ~= nil
			if not skip then
				local max = stat.APMaximum
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
				local changedStat = AdjustAP(stat, settings)
				if changedStat then
					if shouldSync then
						Ext.Stats.Sync(id, false)
					end
				end
			end
		end
	end

	for _,v in pairs(Ext.Stats.GetStats("StatusData")) do
		_loadedStatuses[v] = true
		local statusType = Ext.Stats.GetAttribute(v, "StatusType")
		if statusType then
			Data.StatusToType[v] = statusType
		end
	end

	OverrideWings(shouldSync)
	OverrideForce(shouldSync)

	if not Ext.Mod.IsModLoaded(Data.ModID.UnofficialPatch) then
		for statId,data in pairs(StatFixes) do
			if not data.Mod or Ext.Mod.IsModLoaded(data.Mod) then
				local stat = Ext.Stats.Get(statId, nil, false)
				if stat and data.CanChange(stat) then
					for attribute,value in pairs(data.Changes) do
						stat[attribute] = value
					end
					if shouldSync then
						Ext.Stats.Sync(statId, false)
					end
				end
			end
		end
	end

	_loadedStatuses = {}
end

Ext.Events.StatsLoaded:Subscribe(function (e)
	_OverrideStats(nil, true)
end, {Priority=0})

---@param gameSettings LeaderLibGameSettings|nil
function SyncStatOverrides(gameSettings)
	_OverrideStats(gameSettings, false)
	--Run here so users connecting to a host will get the host's stat changes
	QOL.StatChangesConfig:Run()
end