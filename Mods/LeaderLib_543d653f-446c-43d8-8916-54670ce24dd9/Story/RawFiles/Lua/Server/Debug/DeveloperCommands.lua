local MessageData = Classes.MessageData

Ext.RegisterConsoleCommand("adddeltamod", function(command, slot, deltamod)
	if slot == nil then
		slot = "Weapon"
	end
	if deltamod == nil then
		deltamod = "Boost_Weapon_Status_Set_Petrify_Sword"
	end
	local target = CharacterGetHostCharacter()
	local item = CharacterGetEquippedItem(target, slot)
	print(slot,deltamod,item,target)
	if item ~= nil then
		ItemAddDeltaModifier(item, deltamod)
		print(string.format("[LeaderLib] Added deltamod %s to item (%s) in slot %s", deltamod, item, slot))
	end
end)

Ext.RegisterConsoleCommand("listenskill", function (call, skill)
	if skill ~= nil then
		RegisterSkillListener(skill, function(skill, uuid, state, ...)
			print("[LeaderLib:DebugMain.lua:SkillListener] skill(",skill,") caster(",uuid,") state(",state,") params(",Ext.JsonStringify({...}),")")
		end)
		print("[LeaderLib:listenskill] Registered listener function for skill ", skill)
	else
		Ext.PrintWarning("[LeaderLib:listenskill] Please provide a valid skill ID to listen for!")
	end
end)

local function ResetLua()
	local varData = {}
	for name,data in pairs(Mods) do
		if data.PersistentVars ~= nil then
			varData[name] = data.PersistentVars
		end
	end
	if varData ~= nil then
		Ext.SaveFile("LeaderLib_Debug_PersistentVars.json", Ext.JsonStringify(varData))
	end
	TimerCancel("Timers_LeaderLib_Debug_LuaReset")
	TimerLaunch("Timers_LeaderLib_Debug_LuaReset", 500)
	print("[LeaderLib:luareset] Reseting lua.")
	NRD_LuaReset(1,1,1)
	Vars.JustReset = true
end
 
Ext.RegisterConsoleCommand("luareset", function(command, delay)
	InvokeListenerCallbacks(Listeners.BeforeLuaReset)
	delay = delay or 1000
	if delay ~= nil then
		delay = tonumber(delay)
		if delay > 0 then
			StartOneshotTimer("Timers_LeaderLib_Debug_ResetLua", delay, ResetLua)
		else
			ResetLua()
		end
	else
		ResetLua()
	end
end)


Ext.RegisterConsoleCommand("testrespen", function(command, level)
	local host = CharacterGetHostCharacter()
	local x,y,z = GetPosition(host)
	if level ~= nil then
		level = math.tointeger(tonumber(level))
	else
		level = CharacterGetLevel(host)
	end
	local item = CreateItemTemplateAtPosition("537a06a5-0619-4d57-b77d-b4c319eab3e6", x, y, z)
	SetTag(item, "LeaderLib_HasResistancePenetration")
	local tag = Data.ResistancePenetrationTags["Fire"][4].Tag
	SetTag(item, tag)
	ItemLevelUpTo(item, level)
	PrintDebug("[LeaderLib:testrespen] Added tag",tag,"to item",item)
	ItemToInventory(item, host, 1, 1, 0)
end)

Ext.RegisterConsoleCommand("testrespen2", function(...)
	local host = CharacterGetHostCharacter()
	ApplyStatus(host, "LADY_VENGEANCE", -1.0, 0, host)
	StartOneshotTimer("Timers_LeaderLib_Debug_ResPenTest", 3000, function()
		--ApplyDamage(CharacterGetHostCharacter(), 50, "Fire", CharacterGetHostCharacter())
		--ApplyDamage(CharacterGetHostCharacter(), 1, "Physical")
		--Osi.ApplyDamage(host, 10, "Water")
		local x,y,z = GetPosition(host)
		CreateExplosionAtPosition(x, y, z, "Projectile_EnemyIceShard", 1)
		CharacterStatusText(host, "Took Damage?")
	end)
end)

Ext.RegisterConsoleCommand("combatlog", function(command, text)
	local host = CharacterGetHostCharacter()
	if text == nil then
		local name = Ext.GetCharacter(host).DisplayName
		text = "<font color='#CCFF00'>Test</font> did <font color='#FF0000'>TONS</font> of damage to " .. name
	end
	GameHelpers.UI.CombatLog(text, 0)
end)


Ext.RegisterConsoleCommand("leaderlib_statustext", function(command, text)
	if text == nil then
		text = "Test Status Text!"
	end
	local host = CharacterGetHostCharacter()
	Ext.BroadcastMessage("LeaderLib_DisplayStatusText", MessageData:CreateFromTable("StatusTextData", {
		UUID = host,
		Text = text,
		Duration = 5.0,
		IsItem = false
	}):ToString(), nil)
	-- StartOneshotTimer("Timers_LeaderLib_Debug_StatusTextTest", 2000, function()
		
	-- end)
end)

Ext.RegisterConsoleCommand("leaderlib_messageboxtest", function(command, text)
	StartOneshotTimer("Timers_LeaderLib_Debug_MessageBoxTest", 2000, function()
		local host = CharacterGetHostCharacter()
		GameHelpers.UI.ShowMessageBox(string.format("<font  color='#FF00CC'>One or more players are missing the script extender.</font><br>Please help:<br>* %s", "LaughingLeader"), host, 1, "<font color='#FF0000'>Script Extender Missing!</font>")
	end)
end)

Ext.RegisterConsoleCommand("printrespentags", function(command)
	print("Data.ResistancePenetrationTags = {")
	for damageType,_ in pairs(Data.DamageTypeToResistance) do
		print("\t"..damageType.." = {")
		for i,entry in pairs(Data.ResistancePenetrationTags[damageType]) do
			print(string.format("\t\t[%i] = {Tag=\"%s\", Amount=%i},", i, entry.Tag, entry.Amount))
		end
		print("\t},")
	end
	print("}")
end)


Ext.RegisterConsoleCommand("setarmoroption", function(command, param)
	local host = CharacterGetHostCharacter()
	local state = 2
	if param ~= nil then
		state = math.tointeger(tonumber(param))
	end
	print("[setarmoroption]",host,state)
	Ext.PostMessageToClient(host, "LeaderLib_SetArmorOption", MessageData:CreateFromTable("ArmorOption", {UUID = host, State = state}):ToString())
end)

Ext.RegisterConsoleCommand("llshoot", function(cmd, forceHit, source, target, skill)
	if source == nil then
		source = CharacterGetHostCharacter()
	end
	if target == nil then
		for i,v in pairs(Ext.GetCharacter(source):GetNearbyCharacters(12.0)) do
			if CharacterCanSee(v, source) == 1 and GetDistanceTo(v, source) >= 3.0 then
				target = v
				break
			end
		end
	end

	if skill == nil then
		skill = "Projectile_EnemyTotemWater"
	end

    NRD_ProjectilePrepareLaunch()

    NRD_ProjectileSetString("SkillId", skill)
    NRD_ProjectileSetInt("CasterLevel", CharacterGetLevel(source))

    NRD_ProjectileSetGuidString("Caster", source)
    NRD_ProjectileSetGuidString("Source", source)

    local x,y,z = GetPosition(source)
    NRD_ProjectileSetVector3("SourcePosition", x,y+2,z)

    if forceHit ~= nil then
		NRD_ProjectileSetGuidString("HitObject", target)
		NRD_ProjectileSetGuidString("HitObjectPosition", target)
	end
	NRD_ProjectileSetGuidString("TargetPosition", target)
    NRD_ProjectileLaunch()
end)


-- function h()
-- 	return CharacterGetHostCharacter()
-- end

local changedSkillAttributes = {}

Ext.RegisterConsoleCommand("flurrytest", function(cmd, skill, attribute, value)
	local stat = Ext.GetStat("Target_DualWieldingAttack")
	if stat ~= nil then
		local newSkill = Ext.GetStat("Projectile_Test_FlurryDamage") or Ext.CreateStat("Projectile_Test_FlurryDamage", "SkillData", "_Projectile_LeaderLib_LeaveAction_DamageBase")
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
		Ext.SyncStat("Projectile_Test_FlurryDamage", false)

		stat.UseWeaponDamage = "No"
		stat.UseWeaponProperties = "No"
		stat["Damage Multiplier"]= 0

		---@type StatusStatProperty
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
		Ext.SyncStat("Target_DualWieldingAttack", false)
	end
	local stat = Ext.GetStat("Projectile_EnemyThrowingKnife")
	if stat ~= nil then
		stat.Requirement = "MeleeWeapon"
		Ext.SyncStat("Projectile_EnemyThrowingKnife", false)
	end
end)

--!lleditskill Projectile_LLWEAPONEX_ArmCannon_Disperse_Explosion Template 04bdf5e2-3c6a-4711-b516-1a275ccbd720
--!lleditskill Projectile_LLWEAPONEX_ArmCannon_Disperse_Explosion Template 1945ebb4-c7c5-447e-a40e-aa59b8952be9

Ext.RegisterConsoleCommand("lleditskill", function(cmd, skill, attribute, value)
	local stat = Ext.GetStat(skill)
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
			Ext.SyncStat(skill, false)
			print("[lleditskill] Changed skill attribute",attribute, curVal, "=>", value)
		end
	end
end)


Ext.RegisterConsoleCommand("llprintskilledits", function(cmd, skill)
	local changes = changedSkillAttributes[skill]
	if changes ~= nil then
		print("[llprintskilledits]", skill, Ext.JsonStringify(changedSkillAttributes))
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
["SurfaceTileCollision"] = "SurfaceCollisionFlags",
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
["GrowOnSurface"] = "SurfaceCollisionFlags",
["GrowTimeout"] = "ConstantInt",
["SkillBoost"] = "FixedString",
["SkillAttributeFlags"] = "AttributeFlags",
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
	local stat = Ext.GetStat(skill)
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
		print("[llprintskill]")
		print(Ext.JsonStringify(skillProps))
	end
end)

local defaultRules = Ext.JsonParse(Ext.Require("Server/Debug/DefaultSurfaceTransformationRules.lua"))

Ext.RegisterConsoleCommand("llupdaterules", function(cmd)
	GameHelpers.Surface.UpdateRules()
	local rules = Ext.GetSurfaceTransformRules()
	print(Ext.JsonStringify(rules["Fire"]))
	print(Ext.JsonStringify(rules["Poison"]))
end)

Ext.RegisterConsoleCommand("llresetrules", function(cmd)
	Ext.UpdateSurfaceTransformRules(defaultRules)
	print("[llresetrules] Reset surface rules.")
	print(Ext.JsonStringify(Ext.GetSurfaceTransformRules()["Fire"][1]))
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
		Ext.Print("["..tostring(i) .. "]")
		if v ~= nil and v.DamageFromBase > 0 then
			for i,attribute in pairs(dynamicStatsVars) do
				local val = v[attribute]
				if val ~= nil then
					Ext.Print(string.format("  [%s] = (%s)", attribute, val))
				end
			end
			if v.StatsType ~= "Weapon" then
				for i,attribute in pairs(armorBoostProps) do
					local val = v[attribute]
					if val ~= nil then
						Ext.Print(string.format("  [%s] = (%s)", attribute, val))
					end
				end
			end
		end
	end
end

---@param uuid string An item's GUIDSTRING/ITEMGUID.
local function PrintItemStats(uuid)
	---@type EsvItem
	local item = Ext.GetItem(uuid)
	if item ~= nil and item.Stats ~= nil then
		Ext.Print("Item:", uuid, item.Stats.Name)
		Ext.Print("Boost Stats:")
		Ext.Print("------")
		---@type StatItemDynamic[]
		local stats = item.Stats.DynamicStats
		PrintDynamicStats(item.Stats.DynamicStats)
		Ext.Print("------")
		Ext.Print("")
	end
end

if Debug == nil then
	Debug = {}
end
Debug.PrintItemStats = PrintItemStats

Ext.RegisterConsoleCommand("printitemstats", function(command, slot)
	local target = CharacterGetHostCharacter()
	---@type EsvCharacter
	local characterObject = Ext.GetCharacter(target)
	if slot == nil then
		for i,item in pairs(characterObject:GetInventoryItems()) do
			PrintItemStats(item)
		end
	else
		local item = CharacterGetEquippedItem(target, slot)
		if item ~= nil then
			PrintItemStats(item)
		else
			Ext.PrintError("[LeaderLib:printitemstats] Item as slot", slot, "does not exist!")
		end
	end
end)

Ext.RegisterConsoleCommand("refreshui", function(cmd)
	local host = CharacterGetHostCharacter()
	Ext.PostMessageToClient(host, "LeaderLib_UI_RefreshAll", host)
end)

Ext.RegisterConsoleCommand("permaboosttest", function(cmd)
	local host = Ext.GetCharacter(CharacterGetHostCharacter())
	local weapon = Ext.GetItem(CharacterGetEquippedItem(host.MyGuid, "Weapon"))
	NRD_ItemSetPermanentBoostInt(weapon.MyGuid, "StrengthBoost", Ext.Random(1,30))
	
	print(weapon.Stats.StrengthBoost, NRD_ItemGetPermanentBoostInt(weapon.MyGuid, "StrengthBoost"))
	for i,v in pairs(weapon.Stats.DynamicStats) do
		if v ~= nil and v.ObjectInstanceName ~= nil then
			print(i,v.ObjectInstanceName,v.StrengthBoost)
		else
			print(i, "nil")
		end
	end
	for i,v in pairs(weapon:GetGeneratedBoosts()) do
		print(i,v)
	end
	Ext.PostMessageToClient(host.MyGuid, "LeaderLib_UI_RefreshAll", host.MyGuid)
end)


Ext.RegisterConsoleCommand("heal", function(command, t)
	local target = t or CharacterGetHostCharacter()
	if CharacterIsDead(target) == 1 then
		CharacterResurrect(target)
	end
	CharacterSetHitpointsPercentage(target, 100.0)
end)

Ext.RegisterConsoleCommand("healall", function(command)
	for i,v in pairs(Osi.DB_IsPlayer:Get(nil)) do
		local uuid = uuid
		if CharacterIsDead(uuid) == 1 then
			CharacterResurrect(uuid)
		end
		CharacterSetHitpointsPercentage(uuid, 100.0)
	end
end)

Ext.RegisterConsoleCommand("mostlydead", function(command, t)
	local target = t or CharacterGetHostCharacter()
	CharacterSetHitpointsPercentage(target, 1.0)
	CharacterSetArmorPercentage(target, 0.0)
	CharacterSetMagicArmorPercentage(target, 0.0)
end)

Ext.RegisterConsoleCommand("resurrectparty", function(command)
	for i,v in pairs(Osi.DB_IsPlayer:Get(nil)) do
		if CharacterIsDead(v[1]) == 1 then
			CharacterResurrect(v[1])
		end
	end
end)