local MessageData = Classes.MessageData

local _EXTVERSION = Ext.Utils.Version()

if Debug == nil then
	Debug = {}
end

Ext.RegisterConsoleCommand("adddeltamod", function(command, slot, deltamod)
	if slot == nil then
		slot = "Weapon"
	end
	if deltamod == nil then
		deltamod = "Boost_Weapon_Status_Set_Petrify_Sword"
	end
	local target = Osi.CharacterGetHostCharacter()
	local item = Osi.CharacterGetEquippedItem(target, slot)
	fprint(LOGLEVEL.TRACE, slot,deltamod,item,target)
	if item ~= nil then
		Osi.ItemAddDeltaModifier(item, deltamod)
		fprint(LOGLEVEL.TRACE, string.format("[LeaderLib] Added deltamod %s to item (%s) in slot %s", deltamod, item, slot))
	end
end)

Ext.RegisterConsoleCommand("listenskill", function (call, skill)
	if skill ~= nil then
		---@diagnostic disable-next-line
		RegisterSkillListener(skill, function(skill, uuid, state, ...)
			fprint(LOGLEVEL.TRACE, "[LeaderLib:DebugMain.lua:SkillListener] skill(",skill,") caster(",uuid,") state(",state,") params(",Common.JsonStringify({...}),")")
		end)
	fprint(LOGLEVEL.TRACE, "[LeaderLib:listenskill] Registered listener function for skill ", skill)
	else
		Ext.Utils.PrintWarning("[LeaderLib:listenskill] Please provide a valid skill ID to listen for!")
	end
end)

Ext.RegisterConsoleCommand("testrespen", function(command, level)
	local host = Osi.CharacterGetHostCharacter()
	local x,y,z = Osi.GetPosition(host)
	if level ~= nil then
		level = math.tointeger(tonumber(level))
	else
		level = Osi.CharacterGetLevel(host)
	end
	local item = Osi.CreateItemTemplateAtPosition("537a06a5-0619-4d57-b77d-b4c319eab3e6", x, y, z)
	Osi.SetTag(item, "LeaderLib_HasResistancePenetration")
	local tag = Data.ResistancePenetrationTags["Fire"][4].Tag
	Osi.SetTag(item, tag)
	Osi.ItemLevelUpTo(item, level)
	fprint(LOGLEVEL.TRACE, "[LeaderLib:testrespen] Added tag",tag,"to item",item)
	Osi.ItemToInventory(item, host, 1, 1, 0)
end)

Ext.RegisterConsoleCommand("testrespen2", function(...)
	local host = Osi.CharacterGetHostCharacter()
	Osi.ApplyStatus(host, "LADY_VENGEANCE", -1.0, 0, host)
	Timer.StartOneshot("Timers_LeaderLib_Debug_ResPenTest", 3000, function()
		--ApplyDamage(CharacterGetHostCharacter(), 50, "Fire", CharacterGetHostCharacter())
		--ApplyDamage(CharacterGetHostCharacter(), 1, "Physical")
		--Osi.ApplyDamage(host, 10, "Water")
		local x,y,z = Osi.GetPosition(host)
		Osi.CreateExplosionAtPosition(x, y, z, "Projectile_EnemyIceShard", 1)
		Osi.CharacterStatusText(host, "Took Damage?")
	end)
end)

Ext.RegisterConsoleCommand("combatlog", function(command, text)
	local host = Osi.CharacterGetHostCharacter()
	if text == nil then
		local name = GameHelpers.GetCharacter(host).DisplayName
		text = "<font color='#CCFF00'>Test</font> did <font color='#FF0000'>TONS</font> of damage to " .. name
	end
	GameHelpers.UI.CombatLog(text, 0)
end)
	

Ext.RegisterConsoleCommand("leaderlib_statustext", function(command, text)
	if text == nil then
		text = "Test Status Text!"
	end
	local host = Osi.CharacterGetHostCharacter()
	GameHelpers.Net.Broadcast("LeaderLib_DisplayStatusText", MessageData:CreateFromTable("StatusTextData", {
		UUID = host,
		Text = text,
		Duration = 5.0,
		IsItem = false
	}):ToString(), nil)
	-- Timer.StartOneshot("Timers_LeaderLib_Debug_StatusTextTest", 2000, function()
		
	-- end)
end)

Ext.RegisterConsoleCommand("leaderlib_messageboxtest", function(command, text)
	Timer.StartOneshot("Timers_LeaderLib_Debug_MessageBoxTest", 2000, function()
		local host = Osi.CharacterGetHostCharacter()
		GameHelpers.UI.ShowMessageBox(string.format("<font  color='#FF00CC'>One or more players are missing the script extender.</font><br>Please help:<br>* %s", "LaughingLeader"), host, 1, "<font color='#FF0000'>Script Extender Missing!</font>")
	end)
end)

Ext.RegisterConsoleCommand("printrespentags", function(command)
	Ext.Utils.Print(Lib.serpent.block(Data.ResistancePenetrationTags))
end)


Ext.RegisterConsoleCommand("setarmoroption", function(command, param)
	local host = Osi.CharacterGetHostCharacter()
	local state = 2
	if param ~= nil then
		state = math.tointeger(tonumber(param)) or 2
	end
	Ext.Utils.Print("[setarmoroption]",host,state)
	GameHelpers.Net.PostToUser(host, "LeaderLib_SetArmorOption", MessageData:CreateFromTable("ArmorOption", {UUID = host, State = state}):ToString())
end)

Ext.RegisterConsoleCommand("llshoot", function(cmd, forceHit, source, target, skill)
	if source == nil then
		source = Osi.CharacterGetHostCharacter()
	end
	if target == nil then
		for i,v in pairs(GameHelpers.GetCharacter(source):GetNearbyCharacters(12.0)) do
			if Osi.CharacterCanSee(v, source) == 1 and Osi.GetDistanceTo(v, source) >= 3.0 then
				target = v
				break
			end
		end
	end
	
	if skill == nil then
		skill = "Projectile_EnemyTotemWater"
	end
	
	Osi.NRD_ProjectilePrepareLaunch()
	
	Osi.NRD_ProjectileSetString("SkillId", skill)
	Osi.NRD_ProjectileSetInt("CasterLevel", Osi.CharacterGetLevel(source))
	
	Osi.NRD_ProjectileSetGuidString("Caster", source)
	Osi.NRD_ProjectileSetGuidString("Source", source)
	
	local x,y,z = Osi.GetPosition(source)
	Osi.NRD_ProjectileSetVector3("SourcePosition", x,y+2,z)
	
	if forceHit ~= nil then
		Osi.NRD_ProjectileSetGuidString("HitObject", target)
		Osi.NRD_ProjectileSetGuidString("HitObjectPosition", target)
	end
	Osi.NRD_ProjectileSetGuidString("TargetPosition", target)
	Osi.NRD_ProjectileLaunch()
end)


-- function h()
	-- 	return CharacterGetHostCharacter()
-- end

local changedSkillAttributes = {}

Ext.RegisterConsoleCommand("flurrytest", function(cmd, skill, attribute, value)
	local stat = Ext.Stats.Get("Target_DualWieldingAttack", nil, false)
	if stat ~= nil then
		local newSkill = Ext.Stats.Get("Projectile_Test_FlurryDamage") or Ext.Stats.Create("Projectile_Test_FlurryDamage", "SkillData", "_Projectile_LeaderLib_LeaveAction_DamageBase")
		newSkill.SkillProperties = {
		{
		Type = "Custom",
		Action = "CanBackstab",
		Context = {"Target", "AoE"}
		}
		}
		newSkill["Damage Multiplier"]= 41
		newSkill.UseWeaponDamage = "Yes"
		newSkill.UseWeaponProperties = "Yes"
		Ext.Stats.Sync("Projectile_Test_FlurryDamage", false)
		
		stat.UseWeaponDamage = "No"
		stat.UseWeaponProperties = "No"
		stat["Damage Multiplier"]= 0
		
		---@type StatPropertyStatus
		local prop = {
			Type = "Status",
			Action = "EXPLODE",
			Context = {"Target", "AoE"},
			Duration = 0,
			StatusChance = 1.0,
			StatsId = "Projectile_Test_FlurryDamage",
			SurfaceBoost = false,
			SurfaceBoosts = {},
			Arg4 = -1,
			Arg5 = -1,
		}
		stat.SkillProperties = {prop}
		stat.Requirement = "MeleeWeapon"
		Ext.Stats.Sync("Target_DualWieldingAttack", false)
	end
	local stat = Ext.Stats.Get("Projectile_EnemyThrowingKnife")
	if stat ~= nil then
		stat.Requirement = "MeleeWeapon"
		Ext.Stats.Sync("Projectile_EnemyThrowingKnife", false)
	end
end)

--!lleditskill Projectile_LLWEAPONEX_ArmCannon_Disperse_Explosion Template 04bdf5e2-3c6a-4711-b516-1a275ccbd720
--!lleditskill Projectile_LLWEAPONEX_ArmCannon_Disperse_Explosion Template 1945ebb4-c7c5-447e-a40e-aa59b8952be9

Ext.RegisterConsoleCommand("lleditskill", function(cmd, skill, attribute, value)
	fprint(LOGLEVEL.TRACE, attribute, value)
	local stat = Ext.Stats.Get(skill)
	if stat ~= nil then
		local curVal = stat[attribute]
		local attType = type(curVal)
		if attType ~= nil then
			if attType == "number" then
				value = tonumber(value)
				if math.floor(stat[attribute]) == stat[attribute] then
					value = math.floor(value)
				end
				stat[attribute] = value
			elseif attType == "string" then
				stat[attribute] = value
			elseif attType == "table" then
				value = Common.JsonParse(value)
				if value ~= nil then
					stat[attribute] = value
				end
			end
			if changedSkillAttributes[skill] == nil then
				changedSkillAttributes[skill] = {}
			end
			changedSkillAttributes[skill][attribute] = value
			Ext.Stats.Sync(skill, false)
			fprint(LOGLEVEL.TRACE, "[lleditskill] Changed skill attribute",attribute, curVal, "=>", value)
		end
	end
end)


Ext.RegisterConsoleCommand("llprintskilledits", function(cmd, skill)
	local changes = changedSkillAttributes[skill]
	if changes ~= nil then
		fprint(LOGLEVEL.TRACE, "[llprintskilledits]", skill, Common.JsonStringify(changedSkillAttributes))
	end
end)
	
local skillAttributes = {
["SkillType"] = "FixedString",
["Level"] = "ConstantInt",
["Ability"] = "SkillAbility",
["Element"] = "SkillElement",
["Requirement"] = "SkillRequirement",
["Requirements"] = "Requirements",
["DisplayName"] = "FixedString",
["DisplayNameRef"] = "FixedString",
["Description"] = "FixedString",
["DescriptionRef"] = "FixedString",
["StatsDescription"] = "FixedString",
["StatsDescriptionRef"] = "FixedString",
["StatsDescriptionParams"] = "FixedString",
["Icon"] = "FixedString",
["FXScale"] = "ConstantInt",
["PrepareAnimationInit"] = "FixedString",
["PrepareAnimationLoop"] = "FixedString",
["PrepareEffect"] = "FixedString",
["PrepareEffectBone"] = "FixedString",
["CastAnimation"] = "FixedString",
["CastTextEvent"] = "FixedString",
["CastAnimationCheck"] = "CastCheckType",
["CastEffect"] = "FixedString",
["CastEffectTextEvent"] = "FixedString",
["TargetCastEffect"] = "FixedString",
["TargetHitEffect"] = "FixedString",
["TargetEffect"] = "FixedString",
["SourceTargetEffect"] = "FixedString",
["TargetTargetEffect"] = "FixedString",
["LandingEffect"] = "FixedString",
["ImpactEffect"] = "FixedString",
["MaleImpactEffects"] = "FixedString",
["FemaleImpactEffects"] = "FixedString",
["OnHitEffect"] = "FixedString",
["SelectedCharacterEffect"] = "FixedString",
["SelectedObjectEffect"] = "FixedString",
["SelectedPositionEffect"] = "FixedString",
["DisappearEffect"] = "FixedString",
["ReappearEffect"] = "FixedString",
["ReappearEffectTextEvent"] = "FixedString",
["RainEffect"] = "FixedString",
["StormEffect"] = "FixedString",
["FlyEffect"] = "FixedString",
["SpatterEffect"] = "FixedString",
["ShieldMaterial"] = "FixedString",
["ShieldEffect"] = "FixedString",
["ContinueEffect"] = "FixedString",
["SkillEffect"] = "FixedString",
["Template"] = "FixedString",
["TemplateCheck"] = "CastCheckType",
["TemplateOverride"] = "FixedString",
["TemplateAdvanced"] = "FixedString",
["Totem"] = "YesNo",
["Template1"] = "FixedString",
["Template2"] = "FixedString",
["Template3"] = "FixedString",
["WeaponBones"] = "FixedString",
["TeleportSelf"] = "YesNo",
["CanTargetCharacters"] = "YesNo",
["CanTargetItems"] = "YesNo",
["CanTargetTerrain"] = "YesNo",
["ForceTarget"] = "YesNo",
["TargetProjectiles"] = "YesNo",
["UseCharacterStats"] = "YesNo",
["UseWeaponDamage"] = "YesNo",
["UseWeaponProperties"] = "YesNo",
["SingleSource"] = "YesNo",
["ContinueOnKill"] = "YesNo",
["Autocast"] = "YesNo",
["AmountOfTargets"] = "ConstantInt",
["AutoAim"] = "YesNo",
["AddWeaponRange"] = "YesNo",
["Memory Cost"] = "ConstantInt",
["Magic Cost"] = "ConstantInt",
["ActionPoints"] = "ConstantInt",
["Cooldown"] = "ConstantInt",
["CooldownReduction"] = "ConstantInt",
["ChargeDuration"] = "ConstantInt",
["CastDelay"] = "ConstantInt",
["Offset"] = "ConstantInt",
["Lifetime"] = "ConstantInt",
["Duration"] = "Qualifier",
["TargetRadius"] = "ConstantInt",
["ExplodeRadius"] = "ConstantInt",
["AreaRadius"] = "ConstantInt",
["HitRadius"] = "ConstantInt",
["RadiusMax"] = "ConstantInt",
["Range"] = "ConstantInt",
["MaxDistance"] = "ConstantInt",
["Angle"] = "ConstantInt",
["TravelSpeed"] = "ConstantInt",
["Acceleration"] = "ConstantInt",
["Height"] = "ConstantInt",
["Damage"] = "DamageSourceType",
["Damage Multiplier"] = "ConstantInt",
["Damage Range"] = "ConstantInt",
["DamageType"] = "Damage Type",
["DamageMultiplier"] = "PreciseQualifier",
["DeathType"] = "Death Type",
["BonusDamage"] = "Qualifier",
["Chance To Hit Multiplier"] = "ConstantInt",
["HitPointsPercent"] = "ConstantInt",
["MinHitsPerTurn"] = "ConstantInt",
["MaxHitsPerTurn"] = "ConstantInt",
["HitDelay"] = "ConstantInt",
["MaxAttacks"] = "ConstantInt",
["NextAttackChance"] = "ConstantInt",
["NextAttackChanceDivider"] = "ConstantInt",
["EndPosRadius"] = "ConstantInt",
["JumpDelay"] = "ConstantInt",
["TeleportDelay"] = "ConstantInt",
["PointsMaxOffset"] = "ConstantInt",
["RandomPoints"] = "ConstantInt",
["ChanceToPierce"] = "ConstantInt",
["MaxPierceCount"] = "ConstantInt",
["MaxForkCount"] = "ConstantInt",
["ForkLevels"] = "ConstantInt",
["ForkChance"] = "ConstantInt",
["HealAmount"] = "PreciseQualifier",
["StatusClearChance"] = "ConstantInt",
["SurfaceType"] = "Surface Type",
["SurfaceLifetime"] = "ConstantInt",
["SurfaceStatusChance"] = "ConstantInt",
--["SurfaceTileCollision"] = "SurfaceCollisionFlags",
["SurfaceGrowInterval"] = "ConstantInt",
["SurfaceGrowStep"] = "ConstantInt",
["SurfaceRadius"] = "ConstantInt",
["TotalSurfaceCells"] = "ConstantInt",
["SurfaceMinSpawnRadius"] = "ConstantInt",
["MinSurfaces"] = "ConstantInt",
["MaxSurfaces"] = "ConstantInt",
["MinSurfaceSize"] = "ConstantInt",
["MaxSurfaceSize"] = "ConstantInt",
["GrowSpeed"] = "ConstantInt",
--["GrowOnSurface"] = "SurfaceCollisionFlags",
["GrowTimeout"] = "ConstantInt",
["SkillBoost"] = "FixedString",
--["SkillAttributeFlags"] = "AttributeFlags",
["SkillProperties"] = "Properties",
["CleanseStatuses"] = "FixedString",
["AoEConditions"] = "Conditions",
["TargetConditions"] = "Conditions",
["ForkingConditions"] = "Conditions",
["CycleConditions"] = "Conditions",
["ShockWaveDuration"] = "ConstantInt",
["TeleportTextEvent"] = "FixedString",
["SummonEffect"] = "FixedString",
["ProjectileCount"] = "ConstantInt",
["ProjectileDelay"] = "ConstantInt",
["StrikeCount"] = "ConstantInt",
["StrikeDelay"] = "ConstantInt",
["PreviewStrikeHits"] = "YesNo",
["SummonLevel"] = "ConstantInt",
["Damage On Jump"] = "YesNo",
["Damage On Landing"] = "YesNo",
["StartTextEvent"] = "FixedString",
["StopTextEvent"] = "FixedString",
["Healing Multiplier"] = "ConstantInt",
["Atmosphere"] = "AtmosphereType",
["ConsequencesStartTime"] = "ConstantInt",
["ConsequencesDuration"] = "ConstantInt",
["HealthBarColor"] = "ConstantInt",
["Skillbook"] = "FixedString",
["PreviewImpactEffect"] = "FixedString",
["IgnoreVisionBlock"] = "YesNo",
["HealEffectId"] = "FixedString",
["AddRangeFromAbility"] = "Ability",
["DivideDamage"] = "YesNo",
["OverrideMinAP"] = "YesNo",
["OverrideSkillLevel"] = "YesNo",
["Tier"] = "SkillTier",
["GrenadeBone"] = "FixedString",
["GrenadeProjectile"] = "FixedString",
["GrenadePath"] = "FixedString",
["MovingObject"] = "FixedString",
["SpawnObject"] = "FixedString",
["SpawnEffect"] = "FixedString",
["SpawnFXOverridesImpactFX"] = "YesNo",
["SpawnLifetime"] = "ConstantInt",
["ProjectileTerrainOffset"] = "YesNo",
["ProjectileType"] = "ProjectileType",
["HitEffect"] = "FixedString",
["PushDistance"] = "ConstantInt",
["ForceMove"] = "YesNo",
["Stealth"] = "YesNo",
["Distribution"] = "ProjectileDistribution",
["Shuffle"] = "YesNo",
["PushPullEffect"] = "FixedString",
["Stealth Damage Multiplier"] = "ConstantInt",
["Distance Damage Multiplier"] = "ConstantInt",
["BackStart"] = "ConstantInt",
["FrontOffset"] = "ConstantInt",
["TargetGroundEffect"] = "FixedString",
["PositionEffect"] = "FixedString",
["BeamEffect"] = "FixedString",
["PreviewEffect"] = "FixedString",
["CastSelfAnimation"] = "FixedString",
["IgnoreCursed"] = "YesNo",
["IsEnemySkill"] = "YesNo",
["DomeEffect"] = "FixedString",
["AuraSelf"] = "FixedString",
["AuraAllies"] = "FixedString",
["AuraEnemies"] = "FixedString",
["AuraNeutrals"] = "FixedString",
["AuraItems"] = "FixedString",
["AIFlags"] = "AIFlags",
["Shape"] = "FixedString",
["Base"] = "ConstantInt",
["AiCalculationSkillOverride"] = "FixedString",
["TeleportSurface"] = "YesNo",
["ProjectileSkills"] = "FixedString",
["SummonCount"] = "ConstantInt",
["LinkTeleports"] = "YesNo",
["TeleportsUseCount"] = "ConstantInt",
["HeightOffset"] = "ConstantInt",
["ForGameMaster"] = "YesNo",
["IsMelee"] = "YesNo",
["MemorizationRequirements"] = "MemorizationRequirements",
["IgnoreSilence"] = "YesNo",
["IgnoreHeight"] = "YesNo",
}

Ext.RegisterConsoleCommand("llprintskill", function(cmd, skill, printEmpty)
	local stat = Ext.Stats.Get(skill)
	if stat ~= nil then
		local skillProps = {}
		for att,attType in pairs(skillAttributes) do
			local val = stat[att]
			if val ~= nil then
				if printEmpty ~= nil then
					skillProps[att] = val
				elseif val ~= "" then
					skillProps[att] = val
				end
			end
		end
		fprint(LOGLEVEL.TRACE, "[llprintskill]")
		fprint(LOGLEVEL.TRACE, Common.JsonStringify(skillProps))
	end
end)

local defaultRules = Ext.Json.Parse(Ext.Require("Server/Debug/DefaultSurfaceTransformationRules.lua"))

Ext.RegisterConsoleCommand("llupdaterules", function(cmd)
	GameHelpers.Surface.UpdateRules()
	local rules = Ext.Surface.GetTransformRules()
	fprint(LOGLEVEL.TRACE, Common.JsonStringify(rules["Fire"]))
	fprint(LOGLEVEL.TRACE, Common.JsonStringify(rules["Poison"]))
end)

Ext.RegisterConsoleCommand("llresetrules", function(cmd)
	Ext.Surface.UpdateTransformRules(defaultRules)
	fprint(LOGLEVEL.TRACE, "[llresetrules] Reset surface rules.")
	fprint(LOGLEVEL.TRACE, Common.JsonStringify(Ext.Surface.GetTransformRules()["Fire"][1]))
end)


local dynamicStatsVars = {
"AccuracyBoost",
"AirResistance",
"APRecovery",
"AttackAPCost",
"Bodybuilding",
"BoostName",
"ChanceToHitBoost",
"CleaveAngle",
"CleavePercentage",
"ConstitutionBoost",
"CorrosiveResistance",
"CriticalChance",
"CriticalDamage",
"CustomResistance",
"DamageBoost",
"DamageFromBase",
"DamageType",
"DodgeBoost",
"Durability",
"DurabilityDegradeSpeed",
"EarthResistance",
"FinesseBoost",
"FireResistance",
"HearingBoost",
"Initiative",
"IntelligenceBoost",
"ItemColor",
"LifeSteal",
"MaxAP",
"MaxDamage",
"MaxSummons",
"MemoryBoost",
"MinDamage",
"ModifierType",
"Movement",
"MovementSpeedBoost",
"ObjectInstanceName",
"PhysicalResistance",
"PiercingResistance",
"PoisonResistance",
"RuneSlots_V1",
"RuneSlots",
"ShadowResistance",
"SightBoost",
"Skills",
"SourcePointsBoost",
"StartAP",
"StatsType",
"StrengthBoost",
"Value",
"VitalityBoost",
"WaterResistance",
"WeaponRange",
"Weight",
"Willpower",
"WitsBoost",
}

local armorBoostProps = {
"ArmorBoost",
"ArmorValue",
"Blocking",
"MagicArmorBoost",
"MagicArmorValue",
"MagicResistance",
}

local function PrintDynamicStats(dynamicStats)
	for i,v in pairs(dynamicStats) do
		Ext.Utils.Print("["..tostring(i) .. "]")
		if v ~= nil and v.DamageFromBase > 0 then
			for i,attribute in pairs(dynamicStatsVars) do
				local val = v[attribute]
				if val ~= nil then
					Ext.Utils.Print(string.format("  [%s] = (%s)", attribute, val))
				end
			end
			if v.StatsType ~= "Weapon" then
				for i,attribute in pairs(armorBoostProps) do
					local val = v[attribute]
					if val ~= nil then
						Ext.Utils.Print(string.format("  [%s] = (%s)", attribute, val))
					end
				end
			end
		end
	end
end

---@param uuid string An item's GUIDSTRING/ITEMGUID.
local function PrintItemStats(uuid)
	---@type EsvItem
	local item = GameHelpers.GetItem(uuid)
	if item ~= nil and item.Stats ~= nil then
		Ext.Utils.Print("Item:", uuid, item.Stats.Name)
		Ext.Utils.Print("Boost Stats:")
		Ext.Utils.Print("------")
		---@type StatItemDynamic[]
		local stats = item.Stats.DynamicStats
		PrintDynamicStats(item.Stats.DynamicStats)
		Ext.Utils.Print("------")
		Ext.Utils.Print("")
	end
end

Debug.PrintItemStats = PrintItemStats

Ext.RegisterConsoleCommand("printitemstats", function(command, slot)
	local target = Osi.CharacterGetHostCharacter()
	---@type EsvCharacter
	local characterObject = GameHelpers.GetCharacter(target)
	if slot == nil then
		for i,item in pairs(characterObject:GetInventoryItems()) do
			PrintItemStats(item)
		end
	else
		local item = Osi.CharacterGetEquippedItem(target, slot)
		if item ~= nil then
			PrintItemStats(item)
		else
			Ext.Utils.PrintError("[LeaderLib:printitemstats] Item as slot", slot, "does not exist!")
		end
	end
end)

Ext.RegisterConsoleCommand("refreshui", function(cmd)
	local host = Osi.CharacterGetHostCharacter()
	GameHelpers.Net.PostToUser(host, "LeaderLib_UI_RefreshAll", host)
end)

Ext.RegisterConsoleCommand("permaboosttest", function(cmd)
	local host = GameHelpers.GetCharacter(Osi.CharacterGetHostCharacter())
	local weapon = GameHelpers.GetItem(Osi.CharacterGetEquippedItem(host.MyGuid, "Weapon"))
	Osi.NRD_ItemSetPermanentBoostInt(weapon.MyGuid, "StrengthBoost", Ext.Utils.Random(1,30))
	
	fprint(LOGLEVEL.TRACE, weapon.Stats.StatsEntry.StrengthBoost, Osi.NRD_ItemGetPermanentBoostInt(weapon.MyGuid, "StrengthBoost"))
	for i,v in pairs(weapon.Stats.DynamicStats) do
		if v ~= nil and v.ObjectInstanceName ~= nil then
			fprint(LOGLEVEL.TRACE, i,v.ObjectInstanceName,v.StrengthBoost)
		else
			fprint(LOGLEVEL.TRACE, i, "nil")
		end
	end
	for i,v in pairs(weapon:GetGeneratedBoosts()) do
		fprint(LOGLEVEL.TRACE, i,v)
	end
	GameHelpers.Net.PostToUser(host.MyGuid, "LeaderLib_UI_RefreshAll", host.MyGuid)
end)


Ext.RegisterConsoleCommand("heal", function(command, t)
	local target = t or Osi.CharacterGetHostCharacter()
	local data = Classes.CharacterData:Create(target)
	data:FullRestore(true)
end)

Ext.RegisterConsoleCommand("healall", function(command)
	for player in GameHelpers.Character.GetPlayers(true) do
		local data = Classes.CharacterData:Create(player.MyGuid)
		data:FullRestore(true)
	end
end)

Ext.RegisterConsoleCommand("mostlydead", function(command, t)
	local target = t or Osi.CharacterGetHostCharacter()
	Osi.CharacterSetHitpointsPercentage(target, 1.0)
	Osi.CharacterSetArmorPercentage(target, 0.0)
	Osi.CharacterSetMagicArmorPercentage(target, 0.0)
end)

Ext.RegisterConsoleCommand("resurrectparty", function(command)
	for player in GameHelpers.Character.GetPlayers() do
		if player.Dead then
			--CharacterResurrect(player.MyGuid)
			Osi.CharacterResurrectCustom(player.MyGuid, "Dance_01")
		end
	end
end)

Ext.RegisterConsoleCommand("levelup", function(command, amount)
	amount = amount or "1"
	amount = tonumber(amount)
	local host = GameHelpers.GetCharacter(Osi.CharacterGetHostCharacter())
	local nextLevel = math.min(Ext.ExtraData.LevelCap, host.Stats.Level + amount)
	if amount > 0 then
		Osi.CharacterLevelUpTo(host.MyGuid, nextLevel)
	else
		GameHelpers.Character.SetLevel(host, nextLevel)
	end
	Osi.CharacterLeveledUp(host.MyGuid)
end)

Ext.RegisterConsoleCommand("setlevel", function(command, level)
	level = level or "1"
	level = tonumber(level)
	local host = GameHelpers.GetCharacter(Osi.CharacterGetHostCharacter())
	GameHelpers.Character.SetLevel(host, level)
	Osi.CharacterLeveledUp(host.MyGuid)
end)

local function sleep(timeInMilliseconds)
		---This blocks the server thread while running, so best leave this only for debug mode
		if Vars.DebugMode then
			local time = Ext.Utils.MonotonicTime()
		while Ext.Utils.MonotonicTime() - time <= timeInMilliseconds do end
	end
end

Ext.RegisterConsoleCommand("sleeptest", function(command, delay)
	Osi.ApplyStatus(Osi.CharacterGetHostCharacter(), "HASTED", 6.0, 1, Osi.CharacterGetHostCharacter())
	Timer.StartOneshot("Timers_Commands_sleeptest", 500, function()
		delay = delay and tonumber(delay) or 6000
		local timeStart = Ext.Utils.MonotonicTime()
		fprint(LOGLEVEL.TRACE, "Sleeping Start(%s)", timeStart)
		sleep(delay)
		fprint(LOGLEVEL.TRACE, "Sleep done. Took %s ms", Ext.Utils.MonotonicTime() - timeStart)
	end)
end)

local function RemoveTempChar(v)
	Ext.Utils.Print("Removing", v)
	Osi.SetCanJoinCombat(v, 0)
	Osi.SetCanFight(v, 0)
	Osi.CharacterSetDetached(v, 1)
	Osi.LeaveCombat(v)
	Timer.StartOneshot(string.format("Timers_DebugRemoveTemp%s", v), 250, function()
		Osi.RemoveTemporaryCharacter(v)
	end)
end

Ext.RegisterConsoleCommand("removetemporycharacters", function(command, radius)
	if radius then
		local radius = tonumber(radius) or 24.0
		local host = GameHelpers.GetCharacter(Osi.CharacterGetHostCharacter())
		for i,v in pairs(host:GetNearbyCharacters(radius)) do
			if Osi.IsTagged(v, "LeaderLib_TemporaryCharacter") == 1 then
				RemoveTempChar(v)
			else
				local char = GameHelpers.GetCharacter(v)
				if char and char.Temporary then
					RemoveTempChar(v)
				end
			end
		end
	else
		for i,v in pairs(Ext.Entity.GetAllCharacterGuids(SharedData.RegionData.Current)) do
			if Osi.IsTagged(v, "LeaderLib_TemporaryCharacter") == 1 then
				RemoveTempChar(v)
			else
				local char = GameHelpers.GetCharacter(v)
				if char and char.Temporary then
					RemoveTempChar(v)
				end
			end
		end
	end
end)

if SceneManager then
	Ext.RegisterConsoleCommand("scenetest", function(command, id)
		local testScene = SceneManager.CreateScene("TestScene")
		testScene:CreateState("TestState1", function(self)
				local startTime = Ext.Utils.MonotonicTime()
				print("Hello!", startTime, self.ID)
				self:Wait(3000)
				print("Waiting done", Ext.Utils.MonotonicTime() - startTime, self.ID)
		end)
		testScene:CreateState("TestState2", function(self)
				local startTime = Ext.Utils.MonotonicTime()
				print("Hello2!", startTime, self.ID)
				self:Wait(1000)
				print("Waiting done", Ext.Utils.MonotonicTime() - startTime, self.ID)
		end)
		testScene:CreateState("TestState3", function(self)
			local host = StringHelpers.GetUUID(Osi.CharacterGetHostCharacter())
			local x,y,z = table.unpack(GameHelpers.Math.GetForwardPosition(host, 3.0))
			self:MoveToPosition(host, self.ID .. "Move" .. host, x, y, z, true)
			self:Wait(500)
			Osi.PlayEffect(host, "RS3_FX_Skills_Divine_Shout_Cast_01", "")
			self:Wait(2000)
			self:WaitForDialogEnd("GEB_AD_CannotPickpocket", true, host)
			self:PlayAnimation(host, "Dance_01")
			Ext.Utils.Print("All done!", self.ID)
		end)
		SceneManager.AddScene(testScene, true)
		id = id or "TestScene"
		SceneManager.SetSceneByID(id)
		
		Timer.StartOneshot("Timers_TestState3ShouldBeDone", 30000, function()
			SceneManager.Signal("TestState3ShouldBeDone")
			SceneManager.RemoveScene(testScene)
		end)
	end)
end

Ext.RegisterConsoleCommand("ap", function(command, amountStr)
	local host = Osi.CharacterGetHostCharacter()
	local amount = GameHelpers.GetCharacter(host).Stats.APMaximum
	if amountStr ~= nil then
		amount = math.tointeger(tonumber(amountStr))
	end
	fprint(LOGLEVEL.TRACE, "CharacterAddActionPoints(\"%s\", %s)", host, amount)
	Osi.CharacterAddActionPoints(host, amount)
end)

Ext.RegisterConsoleCommand("anim", function(command, name)
	local host = Osi.CharacterGetHostCharacter()
	name = name or "Dance_01"
	Osi.PlayAnimation(host, name, "")
end)

Ext.RegisterConsoleCommand("lldebug_surfacetransform", function(command, amountStr)
	local host = GameHelpers.GetCharacter(Osi.CharacterGetHostCharacter())
	local x,y,z = table.unpack(host.WorldPos)
	
	-- TransformSurfaceAtPosition(x, y, z, "Bloodify", "Ground", 6.0, 6.0, host)
	-- Timer.StartOneshot("Timers_Test_Freeze", 1500, function()
		-- 	TransformSurfaceAtPosition(x, y, z, "Freeze", "Ground", 6.0, 6.0, host)
	-- end)
	
	GameHelpers.Surface.Transform({x,2.0,z}, "Bloodify", 0, 18.0, host.Handle, "Water", 1.0)
	
	-- local surfaceData = GameHelpers.Grid.GetSurfaces(x, z, nil, 3.0)
	-- --print(Common.Dump(surfaceData.SurfaceMap))
	-- --print(surfaceData.HasSurface("Water", true, 0))
	-- if surfaceData then
		-- 	for _,v in pairs(surfaceData.Ground) do
			-- 		local surface = v.Surface
			-- 		if string.find(string.lower(surface.SurfaceType), "water") then
				-- 			GameHelpers.Surface.Transform(v.Position, "Bloodify", 0, surface.LifeTime, surface.OwnerHandle, surface.SurfaceType, surface.StatusChance)
				-- 			GameHelpers.Surface.Transform(v.Position, "Freeze", 0, surface.LifeTime, surface.OwnerHandle, surface.SurfaceType, surface.StatusChance)
			-- 		end
		-- 	end
	-- end
	
	-- Timer.StartOneshot("Timers_Test_Freeze", 1500, function()
		-- 	local host = GameHelpers.GetCharacter(host)
		-- 	--GameHelpers.Surface.Transform(host.WorldPos, "Freeze", 0, 6.0, host.Handle, "Water", 1.0)
		
		-- 	local surf = Ext.CreateSurfaceAction("TransformSurfaceAction")
		-- 	surf.SurfaceTransformAction = "Freeze"
		-- 	surf.Position = host.WorldPos
		-- 	--surf.OriginSurface = "Water"
		-- 	surf.SurfaceLayer = 0
		-- 	surf.GrowCellPerSecond = 4.0
		-- 	surf.SurfaceLifetime = 6.0
		-- 	surf.SurfaceStatusChance = 1.0
		-- 	surf.OwnerHandle = host.Handle
		-- 	Ext.ExecuteSurfaceAction(surf)
	-- end)
end)

Ext.RegisterConsoleCommand("lldebug_tornadotest", function(command)
	local host = GameHelpers.GetCharacter(Osi.CharacterGetHostCharacter())
	local x,y,z = table.unpack(host.WorldPos)
	local tx,ty,tz = table.unpack(GameHelpers.Math.ExtendPositionWithForwardDirection(host, 10.0, x, y, z))
	local handle = Osi.NRD_CreateTornado(host.MyGuid, "Tornado_EnemyAir", x, y, z, tx, ty, tz)
	Timer.StartOneshot(nil, 20000, function()
		Osi.NRD_GameActionDestroy(handle)
	end)
end)

Ext.RegisterConsoleCommand("lldebug_keepAlive", function(command)
	local host = GameHelpers.GetCharacter(Osi.CharacterGetHostCharacter())
	Osi.ApplyStatus(host.MyGuid, "HASTED", -1.0, 1, host.MyGuid)
	Timer.StartOneshot(nil, 250, function()
		local status = host:GetStatus("HASTED")
		if status then
			status.KeepAlive = true
			status.CurrentLifeTime = 6.0
			status.LifeTime = 6.0
			status.RequestClientSync = true
			fprint(LOGLEVEL.TRACE, status.KeepAlive, status.CurrentLifeTime)
		end
	end)
end)

--Ext.Audio.SetState("Music_Type", "Stop"); Mods.LeaderLib.Timer.StartOneshot("", 10000, function() Ext.Audio.SetState("Music_Type", "Fight"); Ext.Audio.SetState("Music_Theme", "Boss_Theme_01") end)

Ext.RegisterConsoleCommand("lldebug_music", function(command, mType, theme)
	GameHelpers.Net.Broadcast("LeaderLib_Debug_MusicTest", Common.JsonStringify({
		Type = mType or "Explo",
		Theme = theme or "Fort_Joy"
	}))
end)

Ext.RegisterConsoleCommand("lldebug_customstat", function(command, mType, theme)
	local id = Osi.NRD_CreateCustomStat("Test", "TestDescription")
	Osi.NRD_CharacterSetCustomStat(Osi.CharacterGetHostCharacter(), id, 10)
end)

-- Ext.Osiris.RegisterListener("NRD_OnActionStateEnter", Data.OsirisEvents.NRD_OnActionStateEnter, "after", function(char, state)
	-- 	print("NRD_OnActionStateEnter", char, state)
	-- 	-- Timer.StartOneshot(nil, 2000, function()
		-- 	-- 	local action = NRD_CharacterGetCurrentAction(char)
		-- 	-- 	fprint(LOGLEVEL.TRACE, "NRD_CharacterGetCurrentAction(%s) = (%s)", char, action)
	-- 	-- end)
-- end)

-- Ext.Osiris.RegisterListener("NRD_OnActionStateExit", Data.OsirisEvents.NRD_OnActionStateExit, "after", function(char, state)
	-- 	print("NRD_OnActionStateExit", char, state)
-- end)

-- RegisterSkillListener("All", function(skill, caster, state, data)
	-- 	fprint(LOGLEVEL.TRACE, "[Skill(%s)] state(%s) caster(%s) (%s)", skill, state, caster, data == nil and "" or data)
	-- 	-- if data and data.PrintTargets then
		-- 	-- 	data:PrintTargets()
	-- 	-- end
	-- 	if skill == "Tornado_EnemyAir" then
		-- 		if state == SKILL_STATE.PREPARE then
			-- 			ApplyStatus(caster, "HASTED", -1.0, 0, caster)
		-- 		elseif state == SKILL_STATE.CANCEL or state == SKILL_STATE.CAST then
			-- 			RemoveStatus(caster, "HASTED")
		-- 		end
	-- 	end
-- end)

local printFunctionsBase = {}
local printFunctions = {}
local printedTable = {}

local function PrintFunction(k,v,prefix,level)
	if type(v) == "function" then
		if level == 0 then
			printFunctionsBase[#printFunctionsBase+1] = string.format("%s%s", prefix, k)
		else
			printFunctions[#printFunctions+1] = string.format("%s%s", prefix, k)
		end
	elseif type(v) == "table" then
		for k2,v2 in pairs(v) do
			PrintFunction(k2,v2,prefix..k..".",level+1)
		end
	end
end

local function printHelperTable(name, tbl)
	if not printedTable[name] then
		printedTable[name] = true
		printFunctionsBase = {}
		printFunctions = {}
		for k,v in pairs(tbl) do
			PrintFunction(k,v,name..".",0)
		end
		table.sort(printFunctionsBase)
		for _,v in ipairs(printFunctionsBase) do
			fprint(LOGLEVEL.TRACE, v)
		end
		table.sort(printFunctions)
		for _,v in ipairs(printFunctions) do
			fprint(LOGLEVEL.TRACE, v)
		end
	end
end

local ignoreImports = {
	--lua base
	["_G"] = true,
	tonumber = true,
	pairs = true,
	ipairs = true,
	table = true,
	tostring = true,
	math = true,
	type = true,
	print = true,
	error = true,
	next = true,
	string = true,
	--ositools base
	Sandboxed = true,
	ModuleUUID = true,
	Game = true,
	Ext = true,
	Osi = true,
	PersistentVars = true,
	LoadPersistentVars = true,
	--LeaderLib ignores
	Debug = true,
	Vars = true,
	Listeners = true,
	SkillListeners = true,
	ModListeners = true,
	Settings = true,
}

Ext.RegisterConsoleCommand("help", function(command, text)
	if text == "leaderlib" then
		printedTable = {}
		printHelperTable("GameHelpers", GameHelpers)
		printHelperTable("StringHelpers", StringHelpers)
		printHelperTable("TableHelpers", TableHelpers)
		printHelperTable("Common", Common)
		printFunctionsBase = {}
		printFunctions = {}
		for k,v in pairs(Mods.LeaderLib) do
			if not ignoreImports[k] and type(v) == "function" then
				PrintFunction(k,v,"LeaderLib.",0)
			end
		end
		table.sort(printFunctionsBase)
		for _,v in ipairs(printFunctionsBase) do
			local name = string.gsub(v, "LeaderLib.", "")
			fprint(LOGLEVEL.TRACE, name)
		end
		table.sort(printFunctions)
		for _,v in ipairs(printFunctions) do
			local name = string.gsub(v, "LeaderLib.", "")
			fprint(LOGLEVEL.TRACE, name)
		end
	end
end)

Ext.RegisterConsoleCommand("setcustomstat", function(cmd, id, amount)
	amount = amount or "1"
	amount = tonumber(amount) or 1
	if Mods.CharacterExpansionLib then
		Mods.CharacterExpansionLib.CustomStatSystem:SetStat(Osi.CharacterGetHostCharacter(), id, amount)
	end
end)

Ext.RegisterConsoleCommand("testchaoswand", function(cmd)
	local stat = Ext.Stats.Get("WPN_Wand_Chaos") or Ext.Stats.Create("WPN_Wand_Chaos", "Weapon", "WPN_Wand_Air")
	stat["Damage Type"] = "Chaos"
	stat.ObjectCategory = "WandChaos"
	stat.Projectile = "6770f065-df9b-4a0b-a6cb-bfa5e5c28c0e"
	stat.ExtraProperties = {
	{
	Action = "CreateSurface",
	Arg1 = 1.0,
	Arg2 = 0.0,
	Arg3 = "DamageType",
	Arg4 = 1.0,
	Arg5 = 1.0,
	Context = 
	{
	"Target",
	"AoE"
	},
	StatusHealType = "None",
	Type = "GameAction"
	}
	}
	Ext.Stats.Sync("WPN_Wand_Chaos", false)
	local item = GameHelpers.Item.CreateItemByStat("WPN_Wand_Chaos", {
	StatsLevel = math.min(10, Osi.CharacterGetLevel(Osi.CharacterGetHostCharacter())),
	ItemType = "Epic",
	GMFolding = false,
	IsIdentified = true
	})
	if item ~= nil then
		Osi.ItemToInventory(item, Osi.CharacterGetHostCharacter(), 1, 1, 1)
	else
		error("Failed to create WPN_Wand_Chaos")
	end
end)

local StatEntryArmor = {
ArmorBoost = "integer",
MagicArmorBoost = "integer",
Movement = "integer",
Initiative = "integer",
--Value = "integer",
Fire = "integer",
Air = "integer",
Water = "integer",
Earth = "integer",
Poison = "integer",
Piercing = "integer",
Physical = "integer",
StrengthBoost = "Penalty Qualifier",
FinesseBoost = "Penalty Qualifier",
IntelligenceBoost = "Penalty Qualifier",
ConstitutionBoost = "Penalty Qualifier",
MemoryBoost = "Penalty Qualifier",
WitsBoost = "Penalty Qualifier",
SingleHanded = "integer",
TwoHanded = "integer",
Ranged = "integer",
DualWielding = "integer",
RogueLore = "integer",
WarriorLore = "integer",
RangerLore = "integer",
FireSpecialist = "integer",
WaterSpecialist = "integer",
AirSpecialist = "integer",
EarthSpecialist = "integer",
Sourcery = "integer",
Necromancy = "integer",
Polymorph = "integer",
Summoning = "integer",
PainReflection = "integer",
Perseverance = "integer",
Leadership = "integer",
Telekinesis = "integer",
Sneaking = "integer",
Thievery = "integer",
Loremaster = "integer",
Repair = "integer",
Barter = "integer",
Persuasion = "integer",
Luck = "integer",
SightBoost = "Penalty Qualifier",
HearingBoost = "Penalty Qualifier",
VitalityBoost = "integer",
MagicPointsBoost = "Penalty Qualifier",
ChanceToHitBoost = "integer",
APMaximum = "integer",
APStart = "integer",
APRecovery = "integer",
AccuracyBoost = "integer",
DodgeBoost = "integer",
CriticalChance = "integer",
--Weight = "integer",
--Flags = "string See AttributeFlags enumeration",
--ArmorType = "string See ArmorType enumeration",
--Boosts = "string",
--Skills = "string",
--ItemColor = "string",
Reflection = "string",
MaxSummons = "integer",
-- RuneSlots = "integer",
-- RuneSlots_V1 = "integer",
MaxCharges = "integer",
--Talents = "string",
}

Ext.RegisterConsoleCommand("createitemtest", function()
	local deltamods = {
	"Boost_Armor_All_Armour_Physical_Base_Large_Leather",
	"Boost_Armor_Helmet_Ability_Fire",
	"Boost_Armor_Helmet_Ability_Rogues",
	"Boost_Armor_Helmet_Primary_Finesse",
	"Boost_Armor_Helmet_Skill_Water",
	}
	local uuid,item = GameHelpers.Item.CreateItemByStat("ARM_Light_Helmet", {
	StatsLevel = 10,
	ItemType = "Legendary",
	GMFolding = false,
	IsIdentified = true,
	--DeltaMods = deltamods,
	HasGeneratedStats = false,
	RootTemplate = "6bbd09df-f19c-463a-a12a-ab8ac2111b47",
	OriginalRootTemplate = "6bbd09df-f19c-463a-a12a-ab8ac2111b47",
	})
	if item ~= nil then
		local boosts = {}
		if item.Stats then
			fprint(LOGLEVEL.TRACE, Lib.inspect(item.Stats.DynamicStats))
			-- for i,v in pairs(deltamods) do
				-- 	local data = Ext.GetDeltaMod(v, "Armor")
				-- 	if data then
					-- 		for _,boostData in pairs(data.Boosts) do
						-- 			local boost = Ext.Stats.Get(boostData.Boost, 10)
						-- 			if boost then
							-- 				for k,typeName in pairs(StatEntryArmor) do
								-- 					print(k)
							-- 					local b,existing = xpcall(function() return item.Stats.DynamicStats[1][k] end, debug.traceback)
							-- 					local value = boost[k]
							-- 					print(value,existing)
							-- 					if value and b and existing then
								-- 						local t = type(value)
								-- 						if t == "number" then
									-- 							if value ~= 0 then
										-- 								item.Stats.DynamicStats[1][k] = value + existing
									-- 							end
								-- 						elseif t == "string" and string.find(typeName, "Qualifier") and value ~= "None" then
									-- 							local v = tonumber(value)
									-- 							if v ~= 0 then
										-- 								existing = existing == "None" and 0 or tonumber(existing)
										-- 								item.Stats.DynamicStats[1][k] = tostring(value + existing)
									-- 							end
								-- 						end
							-- 					end
						-- 				end
					-- 			end
					-- 			--boosts[#boosts+1] = boost.Boost
				-- 		end
			-- 	end
		-- end
	end
	--item:SetGeneratedBoosts(boosts)
	--print(Lib.inspect(item:GetGeneratedBoosts()))
	--print(Common.JsonStringify(boosts))
	--item:SetDeltaMods(deltamods)
	Osi.ItemToInventory(uuid, Osi.CharacterGetHostCharacter(), 1, 1, 1)
else
	error("Failed to create ARM_Light_Helmet")
end
end)

Ext.RegisterConsoleCommand("partyrestore", function(cmd)
	for player in GameHelpers.Character.GetPlayers(true) do
		fprint(LOGLEVEL.TRACE, player.MyGuid)
		if player.Dead then
			Osi.CharacterResurrect(player.MyGuid)
		end
		player.Stats.CurrentVitality = player.Stats.MaxVitality
		fprint(LOGLEVEL.TRACE, player.Stats.CurrentVitality, player.Stats.MaxVitality)
		Osi.CharacterSetHitpointsPercentage(player.MyGuid, 100.0)
		Osi.CharacterSetArmorPercentage(player.MyGuid, 100.0)
		Osi.CharacterSetMagicArmorPercentage(player.MyGuid, 100.0)
		Osi.ApplyStatus(player.MyGuid, "LEADERLIB_RECALC", 0.0, 1, player.MyGuid)
	end
end)

local cooldownsDisabled_AddedListener = false

function Debug.SetCooldownMode(b)
	if not cooldownsDisabled_AddedListener then
		Ext.Osiris.RegisterListener("SkillCast", 4, "after", function(char,...)
			if Vars.Commands.CooldownsDisabled then
				Osi.CharacterResetCooldowns(char)
			end
		end)
		cooldownsDisabled_AddedListener = true
	end
	if b then
		Osi.CharacterResetCooldowns(Osi.CharacterGetHostCharacter())
	end
end

Ext.RegisterConsoleCommand("nocd", function(command)
	Vars.Commands.CooldownsDisabled = not Vars.Commands.CooldownsDisabled
	print(Vars.Commands.CooldownsDisabled and "Cooldowns disabled." or "Cooldowns enabled.")
	Debug.SetCooldownMode(Vars.Commands.CooldownsDisabled)
end)

Ext.RegisterConsoleCommand("refreshcd", function(command)
	local host = Osi.CharacterGetHostCharacter()
	GameHelpers.UI.RefreshSkillBarCooldowns(host)
end)


---@param params EocItemDefinition
local function AddItemStat(stat, params)
	if not params then
		params = {}
	else
		if params.Level then
			params.StatsLevel = params.Level
			params.Level = nil
		end
		if params.Rarity then
			params.ItemType = params.Rarity
			params.Rarity = nil
		end
	end
	if GameHelpers.Stats.Exists(stat) then
		local statObj = Ext.Stats.Get(stat)
		if statObj.Unique == 1 then
			params.HasGeneratedStats = nil
			params.ItemType = "Unique"
		end
	end
	if params.StatsLevel == nil then
		params.StatsLevel = Osi.CharacterGetLevel(Osi.CharacterGetHostCharacter())
	end
	if params.ItemType == nil then
		params.ItemType = "Epic"
	end
	if params.IsIdentified == nil then
		params.IsIdentified = true
	end
	if params.GMFolding == nil then
		params.GMFolding = false
	end

	-- local item,obj = GameHelpers.Item.CreateItemByStat("ARM_Metamorph_UpperBody", { GenerationLevel=20, StatsLevel = 1, GenerationItemType = "Divine", ItemType = "Common", IsIdentified = true, GMFolding = false, HasGeneratedStats = true,}); ItemToInventory(item, CharacterGetHostCharacter(), 1, 0, 0); ItemDrop(item); SetOnStage(item); print("OffStage", obj.OffStage);

	--local item = GameHelpers.Item.CreateItemByStat("ARM_Metamorph_UpperBody", { StatsLevel = 4, GenerationItemType = "Rare", ItemType = "Rare", IsIdentified = true, GMFolding = false, HasGeneratedStats = true,}); ItemToInventory(item, CharacterGetHostCharacter(), 1, 0, 0)
	--local item = GameHelpers.Item.CreateItemByStat("WPN_Sword", { StatsLevel = 4, GenerationItemType = "Rare", ItemType = "Rare", IsIdentified = true, GMFolding = false, HasGeneratedStats = true,}); ItemToInventory(item, CharacterGetHostCharacter(), 1, 0, 0)
	--local item = GameHelpers.Item.CreateItemByStat("Status_LLTEST_BonusWeapon", { StatsLevel = 4, GenerationItemType = "Rare", ItemType = "Rare", IsIdentified = true, GMFolding = false, HasGeneratedStats = true, RootTemplate = "67e45b64-be99-407e-a08a-8ce60b64e289"}); ItemToInventory(item, CharacterGetHostCharacter(), 1, 0, 0)

	local item = GameHelpers.Item.CreateItemByStat(stat, params)
	if item ~= nil then
		Osi.ItemToInventory(item, Osi.CharacterGetHostCharacter(), 1, 1, 1)
		return true
	end
	return false
end

--!additemstat ARM_UNIQUE_LLWEAPONEX_ThiefGloves_A Unique fe0754e3-5f0b-409e-a856-31e646201ee4
Ext.RegisterConsoleCommand("additemstat", function(command, stat, rarity, levelstr, template)
	if stat == nil then
		stat = "WPN_Sword_2H"
	end
	if rarity == nil then
		if GameHelpers.Stats.GetAttribute(stat, "Unique") == 1 then
			rarity = "Unique"
		else
			rarity = "Epic"
		end
	end
	local level = Osi.CharacterGetLevel(Osi.CharacterGetHostCharacter())
	if levelstr ~= nil then
		level = math.tointeger(tonumber(levelstr)) or level
	end
	if not AddItemStat(stat, {StatsLevel = level, RootTemplate=template, GenerationLevel = level, ItemType = rarity, GenerationItemType = rarity, HasGeneratedStats = rarity ~= "Unique"}) then
		fprint(LOGLEVEL.TRACE, "[additemstat] Failed to generate item!", stat, {})
	end
end)

AddConsoleVariable("additemstat", AddItemStat)

Ext.RegisterConsoleCommand("additemtemplate", function(command, template, count)
	if count == nil then 
		count = 1
	else
		count = math.tointeger(tonumber(count))
	end
	local host = Osi.CharacterGetHostCharacter()
	Osi.ItemTemplateAddTo(template, host, count, 1)
end)

Ext.RegisterConsoleCommand("dumpallcharacters", function (cmd, ...)
	local function _getName(c) 
		local name = GameHelpers.GetDisplayName(c)
		return name ~= "" and name or c.RootTemplate.Name
	end
	local function _getStats(c) 
		local s = {Stat=c.Stats.Name, Ancestors={}} 
		local p = GameHelpers.Stats.GetAttribute(c.Stats.Name, "Using")
		local ancestorLevel = 1
		while p ~= nil do 
			s.Ancestors[#s.Ancestors+1] = {Index=ancestorLevel, Stat=p}
			p = GameHelpers.Stats.GetAttribute(p, "Using") 
			ancestorLevel = ancestorLevel + 1
		end
		return s
	end
	local region = Ext.Entity.GetCurrentLevel().LevelDesc.LevelName;
	local data = {} 
	for _,v in pairs(Ext.Entity.GetAllCharacterGuids()) do 
		local c = Ext.Entity.GetCharacter(v); 
		if not c.Dead then 
			data[#data+1] = {
				UUID=c.MyGuid, 
				Name=_getName(c),
				Stats=_getStats(c),
				RootTemplate = GameHelpers.GetTemplate(c),
				Tags = TableHelpers.MakeUnique(c:GetTags(), true),
				IsBoss = c.RootTemplate.CombatComponent.IsBoss,
				Position = c.WorldPos,
			}
		end 
	end
	table.sort(data, function(a,b) return a.Name < b.Name end)
	local filename = "Dumps/Characters_"..region..".json"
	GameHelpers.IO.SaveFile(filename, Ext.DumpExport(data))
	fprint(LOGLEVEL.DEFAULT, "Saved data to %s", filename)
end)

Ext.RegisterConsoleCommand("statustooltiptest", function (cmd, ...)
	local host = Ext.Entity.GetCharacter(Osi.CharacterGetHostCharacter())
	GameHelpers.Status.Apply(host, {"HASTED", "CLEAR_MINDED", "ENCOURAGED"}, 600, true, host)
	GameHelpers.Status.Apply(host, "INVISIBLE", -1, true, host)
end)

Ext.RegisterConsoleCommand("spawncharactertemplate", function (cmd, template)
	local host = Ext.Entity.GetCharacter(Osi.CharacterGetHostCharacter())
	template = template or "a3caf91b-3d65-4013-8f54-fb12b593972d"
	local x,y,z = GameHelpers.Grid.GetValidPositionInRadius(host.WorldPos, 8, nil, true)
	local character = Osi.TemporaryCharacterCreateAtPosition(x,y,z, template, 1)
	GameHelpers.Character.SetLevel(character, 1)
	Osi.CharacterConsume(character, "SKILLBOOST_SparkmasterWeakenAttack")
	Events.BeforeLuaReset:Subscribe(function (e)
		Osi.RemoveTemporaryCharacter(character)
	end)
end)

Ext.RegisterConsoleCommand("tplevel", function (cmd, region)
	local triggers = {
		_TMPL_Sandbox = "7b4d93b9-5526-4922-a41a-aaa65360ac0a",
		SYS_CHARACTER_CREATION_A = "c9c5e1d7-1998-4d4e-aacb-3970e8823674",
		TUT_TUTORIAL_A = "fe2995bf-aa16-8ce7-33a2-8cb8cf228152",
		FJ_FORTJOY_MAIN = "34d67d87-441c-427d-97bb-4cc506b42fe0",
		LV_HOE_MAIN = "ce65a666-74e4-4903-bbcf-200251975965",
		RC_MAIN = "e30fe0c4-9b40-4040-9670-e8edd53a34ce",
		COS_MAIN = "8c00afb8-43af-4de7-953a-a7456f996a4c",
		ARX_MAIN = "fb573f96-d837-0033-4143-3bf31d88ae49",
		ARX_ENDGAME = "bd166e2a-7623-490e-94df-78079e7cbacc",
		TESTLEVEL_LL_LEADERLIB = "a5918303-c5da-87b6-19bb-d55f16f2025c",
		LLAPOC_TEST = "dde72a37-0176-8dab-4430-992e60ef79f3",
	}
	--Shortcut names
	triggers.CC = triggers.SYS_CHARACTER_CREATION_A
	triggers.SANDBOX = triggers._TMPL_Sandbox
	local trigger = triggers[string.upper(region or "")]
	if trigger then
		Osi.CharacterTeleportPartiesToTrigger(trigger, "")
	else
		fprint(LOGLEVEL.ERROR, "[tplevel] No trigger set for region [%s]", region)
	end
end)