local MessageData = Classes.MessageData

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
			for i,attribute in ipairs(dynamicStatsVars) do
				local val = v[attribute]
				if val ~= nil then
					Ext.Print(string.format("  [%s] = (%s)", attribute, val))
				end
			end
			if v.StatsType ~= "Weapon" then
				for i,attribute in ipairs(armorBoostProps) do
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

Ext.RegisterConsoleCommand("printitemstats", function(command, slot)
	local target = CharacterGetHostCharacter()
	---@type EsvCharacter
	local characterObject = Ext.GetCharacter(target)
	if slot == nil then
		for i,item in ipairs(characterObject:GetInventoryItems()) do
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

Ext.RegisterConsoleCommand("pos", function()
	---@type StatCharacter
	local character = CharacterGetHostCharacter()
	print("Pos:", GetPosition(character))
	print("Rot:", GetRotation(character))
end)

Ext.RegisterConsoleCommand("pos2", function()
	---@type StatCharacter
	local character = Ext.GetCharacter(CharacterGetHostCharacter()).Stats
	print("Position:", Ext.JsonStringify(character.Position))
	print("Rotation:", Ext.JsonStringify(character.Rotation))
end)

Ext.RegisterConsoleCommand("printuuids", function(call, radiusVal)
	local radius = 6.0
	if radiusVal ~= nil then
		radius = tonumber(radiusVal)
	end
	local host = CharacterGetHostCharacter()
	for i,v in pairs(Ext.GetCharacter(host):GetNearbyCharacters(radius)) do
		Debug_Iterator_PrintCharacter(v)
		NRD_CharacterSetPermanentBoostTalent(v, "AttackOfOpportunity", 1)
		CharacterAddAttribute(v, "Dummy", 0)
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
 
Ext.RegisterConsoleCommand("luareset", function(command)
	TimerCancel("Timers_LeaderLib_Debug_LuaReset")
	TimerLaunch("Timers_LeaderLib_Debug_LuaReset", 500)
	print("[LeaderLib:luareset] Reseting lua.")
	NRD_LuaReset(1,1,1)
	Vars.JustReset = true
end)

Ext.RegisterConsoleCommand("movie", function(command,movie)
	if movie == nil then
		movie = "Splash_Logo_Larian"
	end
	local host = CharacterGetHostCharacter()
	MoviePlay(host,movie)
end)

-- !statusapply LLLICH_DOMINATED 18.0 1 145810cc-7e46-43e7-9fdf-ab9bb8ffcdc0 host
-- !statusapply LLLICH_DOMINATED_BEAM_FX 0.0 1 145810cc-7e46-43e7-9fdf-ab9bb8ffcdc0 host
-- !statusapply MADNESS 12.0 1 319_31dc549d-dfc0-4558-821a-5e3d468e5b1a host
Ext.RegisterConsoleCommand("statusapply", function(command,status,duration,force,target,source)
	local host = CharacterGetHostCharacter()
	if target == nil or target == "host" then
		target = host
	end
	if source == nil or source == "host" then
		source = host
	end
	if duration == nil then
		duration = 18.0
	else
		duration = tonumber(duration)
	end
	if force == nil then
		force = 1
	else
		force = tonumber(force)
	end
	if status == nil then
		status = "HASTED"
	end
	print(command,status,target,source,duration,force)
	ApplyStatus(target,status,duration,force,source)
end)

-- !removestatus LLLICH_DOMINATED_BEAM_FX 145810cc-7e46-43e7-9fdf-ab9bb8ffcdc0
Ext.RegisterConsoleCommand("statusremove", function(command,status,target)
	local host = CharacterGetHostCharacter()
	if target == nil or target == "host" then
		target = host
	end
	if status == nil then
		status = "HASTED"
	end
	if status == "ALL" then
		RemoveHarmfulStatuses(target)
	else
		RemoveStatus(target,status)
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

Ext.RegisterConsoleCommand("clearinventory", function(command)
	local host = CharacterGetHostCharacter()
	local x,y,z = GetPosition(host)
	--local backpack = CreateItemTemplateAtPosition("LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
	for i,item in pairs(Ext.GetCharacter(host):GetInventoryItems()) do
		if ItemIsStoryItem(item) == 0 and ItemIsDestructible(item) and not GameHelpers.Item.ItemIsEquipped(host, item) then
			ItemRemove(item)
		end
	end
end)

local treasureChest = nil
Ext.RegisterConsoleCommand("addtreasure", function(command, treasure, identifyItems)
	if treasure == nil then
		treasure = "ArenaMode_ArmsTrader"
	end
	local host = CharacterGetHostCharacter()
	local x,y,z = GetPosition(host)
	if treasureChest == nil or ObjectExists(treasureChest) == 0 then
		treasureChest = CreateItemTemplateAtPosition("219f6175-312b-4520-afce-a92c7fadc1ee", x, y, z)
	end
	local tx,ty,tz = FindValidPosition(x,y,z, 8.0, treasureChest)
	ItemMoveToPosition(treasureChest, tx,ty,tz,16.0,20.0,"",0)
	GenerateTreasure(treasureChest, treasure, CharacterGetLevel(host), host)
	if identifyItems ~= 0 then
		ContainerIdentifyAll(treasureChest)
	end
end)

--!addreward ST_LLWEAPONEX_RunebladesRare
Ext.RegisterConsoleCommand("addreward", function(command, treasure, identifyItems)
	if treasure == nil then
		treasure = "ST_WeaponRare"
	end
	local host = CharacterGetHostCharacter()
	local identified = identifyItems ~= 0
	CharacterGiveReward(host, treasure, identified)
end)

Ext.RegisterConsoleCommand("questreward", function(command, treasure)
	if treasure == nil then
		treasure = "RC_GY_RykersContract"
	end
	local host = CharacterGetHostCharacter()
	CharacterGiveQuestReward(host, treasure, "QuestReward")
end)

Ext.RegisterConsoleCommand("addskill", function(command, skill)
	local host = CharacterGetHostCharacter()
	CharacterAddSkill(host, skill, 1)
end)

--!additemstat ARM_UNIQUE_LLWEAPONEX_ThiefGloves_A Unique fe0754e3-5f0b-409e-a856-31e646201ee4
Ext.RegisterConsoleCommand("additemstat", function(command, stat, rarity, template)
	if rarity == nil then
		if Ext.StatGetAttribute(stat, "Unique") == 1 then
			rarity = "Unique"
		else
			rarity = "Epic"
		end
	end
	local host = CharacterGetHostCharacter()
	local item = GameHelpers.Item.CreateItemByStat(stat, CharacterGetLevel(host), rarity, true, 1, 1)
	ItemToInventory(item, host, 1, 1, 1)
end)

Ext.RegisterConsoleCommand("additemtemplate", function(command, template, count)
	if count == nil then 
		count = 1
	else
		count = math.tointeger(tonumber(count))
	end
	local host = CharacterGetHostCharacter()
	ItemTemplateAddTo(template, host, count, 1)
end)

Ext.RegisterConsoleCommand("printdeltamods", function(command, ...)
	local host = CharacterGetHostCharacter()
	---@type EsvCharacter
	local character = Ext.GetCharacter(host)
	for i,slot in LeaderLib.Data.EquipmentSlots:Get() do
		---@type StatItem
		--local item = character.Stats:GetItemBySlot(slot)
		local itemUUID = CharacterGetEquippedItem(host, slot)
		if itemUUID ~= nil then
			---@type EsvItem
			local item = Ext.GetItem(itemUUID)
			if item ~= nil then
				print(slot, itemUUID)
				print("Stat:", item.StatsId)
				print("=======")
				print("Item Boost Stats:")
				print("=======")
				for i,stat in ipairs(item.Stats.DynamicStats) do
					if not StringHelpers.IsNullOrEmpty(stat.BoostName) then
						print(i,stat.BoostName)
					end
				end
				print("=======")
				NRD_ItemIterateDeltaModifiers(itemUUID, "LLWEAPONEX_Debug_PrintDeltamod")
			end
		end
	end
end)

Ext.RegisterConsoleCommand("combatlog", function(command, text)
	local host = CharacterGetHostCharacter()
	if text == nil then
		local name = Ext.GetCharacter(host).DisplayName
		text = "<font color='#CCFF00'>Test</font> did <font color='#FF0000'>TONS</font> of damage to " .. name
	end
	GameHelpers.UI.CombatLog(text, 0)
end)

Ext.RegisterConsoleCommand("clearcombatlog", function(command, text)
	local host = CharacterGetHostCharacter()
	Ext.PostMessageToClient(host, "LeaderLib_ClearCombatLog", "0")
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
		GameHelpers.UI.ShowMessageBox(string.format("<font  color='#FF00CC'>One or more players are missing the script extender.</font><br>Please help:<br>* %s", "LaughingLeader"), host, 0, "<font color='#FF0000'>Script Extender Missing!</font>")
	end)
end)

Ext.RegisterConsoleCommand("printrespentags", function(command)
	print("Data.ResistancePenetrationTags = {")
	for damageType,_ in pairs(Data.DamageTypeToResistance) do
		print("\t"..damageType.." = {")
		for i,entry in ipairs(Data.ResistancePenetrationTags[damageType]) do
			print(string.format("\t\t[%i] = {Tag=\"%s\", Amount=%i},", i, entry.Tag, entry.Amount))
		end
		print("\t},")
	end
	print("}")
end)

Ext.RegisterConsoleCommand("refreshskill", function(command, skill, enabled)
	SetSkillEnabled(CharacterGetHostCharacter(), skill, false)
end)

Ext.RegisterConsoleCommand("heal", function(command, t)
	local target = t or CharacterGetHostCharacter()
	CharacterSetHitpointsPercentage(target, 100.0)
end)

Ext.RegisterConsoleCommand("resurrectparty", function(command)
	for i,v in pairs(Osi.DB_IsPlayer:Get(nil)) do
		if CharacterIsDead(v[1]) == 1 then
			CharacterResurrect(v[1])
		end
	end
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
				value = Ext.JsonParse(value)
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