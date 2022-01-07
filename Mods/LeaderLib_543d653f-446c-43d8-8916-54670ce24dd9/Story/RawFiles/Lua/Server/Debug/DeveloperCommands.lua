local MessageData = Classes.MessageData

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
	local target = CharacterGetHostCharacter()
	local item = CharacterGetEquippedItem(target, slot)
	PrintDebug(slot,deltamod,item,target)
	if item ~= nil then
		ItemAddDeltaModifier(item, deltamod)
		PrintDebug(string.format("[LeaderLib] Added deltamod %s to item (%s) in slot %s", deltamod, item, slot))
	end
end)

Ext.RegisterConsoleCommand("listenskill", function (call, skill)
	if skill ~= nil then
		RegisterSkillListener(skill, function(skill, uuid, state, ...)
			PrintDebug("[LeaderLib:DebugMain.lua:SkillListener] skill(",skill,") caster(",uuid,") state(",state,") params(",Common.JsonStringify({...}),")")
		end)
		PrintDebug("[LeaderLib:listenskill] Registered listener function for skill ", skill)
		else
			Ext.PrintWarning("[LeaderLib:listenskill] Please provide a valid skill ID to listen for!")
		end
	end)
	
	local function ResetLua()
		local varData = {
			_PrintSettings = Vars.Print,
			_CommandSettings = Vars.Commands,
		}
		
		for name,data in pairs(Mods) do
			if data.PersistentVars ~= nil then
				varData[name] = TableHelpers.SanitizeTable(data.PersistentVars)
			end
		end
		if varData ~= nil then
			Ext.SaveFile("LeaderLib_Debug_PersistentVars.json", Common.JsonStringify(varData))
		end
		TimerCancel("Timers_LeaderLib_Debug_LuaReset")
		TimerLaunch("Timers_LeaderLib_Debug_LuaReset", 500)
		PrintDebug("[LeaderLib:luareset] Reseting lua.")
		NRD_LuaReset(1,1,1)
		Vars.JustReset = true
	end
	
	local function OnLuaResetCommand(cmd, delay)
		if delay == "" then
			delay = nil
		end
		InvokeListenerCallbacks(Listeners.BeforeLuaReset)
		GameHelpers.Net.Broadcast("LeaderLib_Client_InvokeListeners", "BeforeLuaReset")
		delay = delay or 1000
		if delay ~= nil then
			delay = tonumber(delay)
			if delay > 0 then
				Timer.StartOneshot("Timers_LeaderLib_Debug_ResetLua", delay, ResetLua)
			else
				ResetLua()
			end
		else
			ResetLua()
		end
	end
	
	Ext.RegisterConsoleCommand("luareset", OnLuaResetCommand)
	Ext.RegisterNetListener("LeaderLib_Client_RequestLuaReset", OnLuaResetCommand)
	
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
		Timer.StartOneshot("Timers_LeaderLib_Debug_ResPenTest", 3000, function()
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
			local host = CharacterGetHostCharacter()
			GameHelpers.UI.ShowMessageBox(string.format("<font  color='#FF00CC'>One or more players are missing the script extender.</font><br>Please help:<br>* %s", "LaughingLeader"), host, 1, "<font color='#FF0000'>Script Extender Missing!</font>")
		end)
	end)
	
	Ext.RegisterConsoleCommand("printrespentags", function(command)
		PrintDebug("Data.ResistancePenetrationTags = {")
		for damageType,_ in pairs(Data.DamageTypeToResistance) do
			PrintDebug("\t"..damageType.." = {")
			for i,entry in pairs(Data.ResistancePenetrationTags[damageType]) do
				PrintDebug(string.format("\t\t[%i] = {Tag=\"%s\", Amount=%i},", i, entry.Tag, entry.Amount))
			end
			PrintDebug("\t},")
		end
		PrintDebug("}")
	end)
	
	
	Ext.RegisterConsoleCommand("setarmoroption", function(command, param)
		local host = CharacterGetHostCharacter()
		local state = 2
		if param ~= nil then
			state = math.tointeger(tonumber(param))
		end
		PrintDebug("[setarmoroption]",host,state)
		GameHelpers.Net.PostToUser(host, "LeaderLib_SetArmorOption", MessageData:CreateFromTable("ArmorOption", {UUID = host, State = state}):ToString())
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
		PrintDebug(attribute, value)
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
				PrintDebug("[lleditskill] Changed skill attribute",attribute, curVal, "=>", value)
			end
		end
	end)
	
	
	Ext.RegisterConsoleCommand("llprintskilledits", function(cmd, skill)
		local changes = changedSkillAttributes[skill]
		if changes ~= nil then
			PrintDebug("[llprintskilledits]", skill, Common.JsonStringify(changedSkillAttributes))
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
			PrintDebug("[llprintskill]")
			PrintDebug(Common.JsonStringify(skillProps))
		end
	end)
	
	local defaultRules = Ext.JsonParse(Ext.Require("Server/Debug/DefaultSurfaceTransformationRules.lua"))
	
	Ext.RegisterConsoleCommand("llupdaterules", function(cmd)
		GameHelpers.Surface.UpdateRules()
		local rules = Ext.GetSurfaceTransformRules()
		PrintDebug(Common.JsonStringify(rules["Fire"]))
		PrintDebug(Common.JsonStringify(rules["Poison"]))
	end)
	
	Ext.RegisterConsoleCommand("llresetrules", function(cmd)
		Ext.UpdateSurfaceTransformRules(defaultRules)
		PrintDebug("[llresetrules] Reset surface rules.")
		PrintDebug(Common.JsonStringify(Ext.GetSurfaceTransformRules()["Fire"][1]))
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
		GameHelpers.Net.PostToUser(host, "LeaderLib_UI_RefreshAll", host)
	end)
	
	Ext.RegisterConsoleCommand("permaboosttest", function(cmd)
		local host = Ext.GetCharacter(CharacterGetHostCharacter())
		local weapon = Ext.GetItem(CharacterGetEquippedItem(host.MyGuid, "Weapon"))
		NRD_ItemSetPermanentBoostInt(weapon.MyGuid, "StrengthBoost", Ext.Random(1,30))
		
		PrintDebug(weapon.Stats.StrengthBoost, NRD_ItemGetPermanentBoostInt(weapon.MyGuid, "StrengthBoost"))
		for i,v in pairs(weapon.Stats.DynamicStats) do
			if v ~= nil and v.ObjectInstanceName ~= nil then
				PrintDebug(i,v.ObjectInstanceName,v.StrengthBoost)
			else
				PrintDebug(i, "nil")
			end
		end
		for i,v in pairs(weapon:GetGeneratedBoosts()) do
			PrintDebug(i,v)
		end
		GameHelpers.Net.PostToUser(host.MyGuid, "LeaderLib_UI_RefreshAll", host.MyGuid)
	end)
	
	
	Ext.RegisterConsoleCommand("heal", function(command, t)
		local target = t or CharacterGetHostCharacter()
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
		local target = t or CharacterGetHostCharacter()
		CharacterSetHitpointsPercentage(target, 1.0)
		CharacterSetArmorPercentage(target, 0.0)
		CharacterSetMagicArmorPercentage(target, 0.0)
	end)
	
	Ext.RegisterConsoleCommand("resurrectparty", function(command)
		for player in GameHelpers.Character.GetPlayers() do
			if player.Dead then
				--CharacterResurrect(player.MyGuid)
				CharacterResurrectCustom(player.MyGuid, "Dance_01")
			end
		end
	end)
	
	Ext.RegisterConsoleCommand("levelup", function(command, amount)
		amount = amount or "1"
		amount = tonumber(amount)
		local host = Ext.GetCharacter(CharacterGetHostCharacter())
		local nextLevel = math.min(Ext.ExtraData.LevelCap, host.Stats.Level + amount)
		if amount > 0 then
			CharacterLevelUpTo(host.MyGuid, nextLevel)
		else
			GameHelpers.Character.SetLevel(host, nextLevel)
		end
		Osi.CharacterLeveledUp(host.MyGuid)
	end)
	
	Ext.RegisterConsoleCommand("setlevel", function(command, level)
		level = level or "1"
		level = tonumber(level)
		local host = Ext.GetCharacter(CharacterGetHostCharacter())
		GameHelpers.Character.SetLevel(host, level)
		Osi.CharacterLeveledUp(host.MyGuid)
	end)
	
	local function sleep(timeInMilliseconds)
		---This blocks the server thread while running, so best leave this only for debug mode
		if Vars.DebugMode then
			local time = Ext.MonotonicTime()
		while Ext.MonotonicTime() - time <= timeInMilliseconds do end
	end
end

Ext.RegisterConsoleCommand("sleeptest", function(command, delay)
	ApplyStatus(CharacterGetHostCharacter(), "HASTED", 6.0, 1, CharacterGetHostCharacter())
	Timer.StartOneshot("Timers_Commands_sleeptest", 500, function()
		delay = delay and tonumber(delay) or 6000
		local timeStart = Ext.MonotonicTime()
		fprint(LOGLEVEL.TRACE, "Sleeping Start(%s)", timeStart)
		sleep(delay)
		fprint(LOGLEVEL.TRACE, "Sleep done. Took %s ms", Ext.MonotonicTime() - timeStart)
	end)
end)

local function RemoveTempChar(v)
	PrintDebug("Removing", v)
	SetCanJoinCombat(v, 0)
	SetCanFight(v, 0)
	CharacterSetDetached(v, 1)
	LeaveCombat(v)
	Timer.StartOneshot(string.format("Timers_DebugRemoveTemp%s", v), 250, function()
		RemoveTemporaryCharacter(v)
	end)
end

Ext.RegisterConsoleCommand("removetemporycharacters", function(command, radius)
	if radius then
		local radius = tonumber(radius) or 24.0
		local host = Ext.GetCharacter(CharacterGetHostCharacter())
		for i,v in pairs(host:GetNearbyCharacters(radius)) do
			if IsTagged(v, "LeaderLib_TemporaryCharacter") == 1 then
				RemoveTempChar(v)
			else
				local char = Ext.GetCharacter(v)
				if char and char.Temporary then
					RemoveTempChar(v)
				end
			end
		end
	else
		for i,v in pairs(Ext.GetAllCharacters(SharedData.RegionData.Current)) do
			if IsTagged(v, "LeaderLib_TemporaryCharacter") == 1 then
				RemoveTempChar(v)
			else
				local char = Ext.GetCharacter(v)
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
				local startTime = Ext.MonotonicTime()
				print("Hello!", startTime, self.ID)
				self:Wait(3000)
				print("Waiting done", Ext.MonotonicTime() - startTime, self.ID)
		end)
		testScene:CreateState("TestState2", function(self)
				local startTime = Ext.MonotonicTime()
				print("Hello2!", startTime, self.ID)
				self:Wait(1000)
				print("Waiting done", Ext.MonotonicTime() - startTime, self.ID)
		end)
		testScene:CreateState("TestState3", function(self)
			local host = StringHelpers.GetUUID(CharacterGetHostCharacter())
			local x,y,z = table.unpack(GameHelpers.Math.GetForwardPosition(host, 3.0))
			self:MoveToPosition(host, self.ID .. "Move" .. host, x, y, z, true)
			self:Wait(500)
			PlayEffect(host, "RS3_FX_Skills_Divine_Shout_Cast_01", "")
			self:Wait(2000)
			self:WaitForDialogEnd("GEB_AD_CannotPickpocket", true, host)
			self:PlayAnimation(host, "Dance_01")
			PrintDebug("All done!", self.ID)
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
	local host = CharacterGetHostCharacter()
	local amount = Ext.GetCharacter(host).Stats.APMaximum
	if amountStr ~= nil then
		amount = math.tointeger(tonumber(amountStr))
	end
	fprint(LOGLEVEL.TRACE, "CharacterAddActionPoints(\"%s\", %s)", host, amount)
	CharacterAddActionPoints(host, amount)
end)

Ext.RegisterConsoleCommand("animation", function(command, name)
	local host = CharacterGetHostCharacter()
	name = name or "Dance_01"
	PlayAnimation(host, name, "")
end)

Ext.RegisterConsoleCommand("lldebug_surfacetransform", function(command, amountStr)
	local host = Ext.GetCharacter(CharacterGetHostCharacter())
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
		-- 	local host = Ext.GetCharacter(host)
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
	local host = Ext.GetCharacter(CharacterGetHostCharacter())
	local x,y,z = table.unpack(host.WorldPos)
	local tx,ty,tz = table.unpack(GameHelpers.Math.ExtendPositionWithForwardDirection(host, 10.0, x, y, z))
	local handle = NRD_CreateTornado(host.MyGuid, "Tornado_EnemyAir", x, y, z, tx, ty, tz)
	Timer.StartOneshot(nil, 20000, function()
		NRD_GameActionDestroy(handle)
	end)
end)

Ext.RegisterConsoleCommand("lldebug_keepAlive", function(command)
	local host = Ext.GetCharacter(CharacterGetHostCharacter())
	ApplyStatus(host.MyGuid, "HASTED", -1.0, 1, host.MyGuid)
	Timer.StartOneshot(nil, 250, function()
		local status = host:GetStatus("HASTED")
		if status then
			status.KeepAlive = true
			status.CurrentLifeTime = 6.0
			status.LifeTime = 6.0
			status.RequestClientSync = true
			PrintDebug(status.KeepAlive, status.CurrentLifeTime)
		end
	end)
end)

Ext.RegisterConsoleCommand("lldebug_music", function(command, mType, theme)
	GameHelpers.Net.Broadcast("LeaderLib_Debug_MusicTest", Common.JsonStringify({
		Type = mType or "Explo",
		Theme = theme or "Fort_Joy"
	}))
end)

Ext.RegisterConsoleCommand("lldebug_customstat", function(command, mType, theme)
	local id = NRD_CreateCustomStat("Test", "TestDescription")
	NRD_CharacterSetCustomStat(CharacterGetHostCharacter(), id, 10)
end)

-- Ext.RegisterOsirisListener("NRD_OnActionStateEnter", Data.OsirisEvents.NRD_OnActionStateEnter, "after", function(char, state)
	-- 	print("NRD_OnActionStateEnter", char, state)
	-- 	-- Timer.StartOneshot(nil, 2000, function()
		-- 	-- 	local action = NRD_CharacterGetCurrentAction(char)
		-- 	-- 	fprint(LOGLEVEL.TRACE, "NRD_CharacterGetCurrentAction(%s) = (%s)", char, action)
	-- 	-- end)
-- end)

-- Ext.RegisterOsirisListener("NRD_OnActionStateExit", Data.OsirisEvents.NRD_OnActionStateExit, "after", function(char, state)
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
			PrintDebug(v)
		end
		table.sort(printFunctions)
		for _,v in ipairs(printFunctions) do
			PrintDebug(v)
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
			PrintDebug(name)
		end
		table.sort(printFunctions)
		for _,v in ipairs(printFunctions) do
			local name = string.gsub(v, "LeaderLib.", "")
			PrintDebug(name)
		end
	end
end)

--for i,v in pairs(Ext.GetItem(CharacterGetEquippedItem(CharacterGetHostCharacter(), "Breast")).Stats.DynamicStats) do print(i,v.ObjectInstanceName) end
--local pa,b1,ma,b2 = 0,0,0,0; for i,v in pairs(Ext.GetItem(CharacterGetEquippedItem(CharacterGetHostCharacter(), "Breast")).Stats.DynamicStats) do pa=pa+v.ArmorValue;b1=b1 + v.ArmorBoost *0.01;ma=ma+v.MagicArmorValue;b2=b2 + v.MagicArmorBoost *0.01; end print("Physical Armor:", pa * (1 + b1));print("Magic Armor:", ma * (1 + b2))
--Public\WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f\Stats\Generated\Data\Data.txt
--for _,uuid in ipairs(Ext.GetModLoadOrder()) do local info = Ext.GetModInfo(uuid); if info.Name ~= "Shared" then print(info.Name); print(Ext.LoadFile(string.format("Public/%s/Stats/Generated/Data/Data.txt", info.Directory), "data")); end end
--local totalBad = 0; for _,v in pairs(Ext.GetStatEntries("Weapon")) do if string.sub(v, 1, 1) ~= "_" and not string.find(v, "Status_") and not string.find(v, "Damage_") then local stat = Ext.GetStat(v); if stat.AttackAPCost ~= 4 then print(v, stat.AttackAPCost); totalBad = totalBad + 1; end end end;print("Total bad:", totalBad)

Ext.RegisterConsoleCommand("setcustomstat", function(cmd, id, amount)
	amount = amount or "1"
	amount = tonumber(amount) or 1
	if Mods.CharacterExpansionLib then
		Mods.CharacterExpansionLib.CustomStatSystem:SetStat(CharacterGetHostCharacter(), id, amount)
	end
end)

Ext.RegisterConsoleCommand("testchaoswand", function(cmd)
	local stat = Ext.GetStat("WPN_Wand_Chaos") or Ext.CreateStat("WPN_Wand_Chaos", "Weapon", "WPN_Wand_Air")
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
	Ext.SyncStat("WPN_Wand_Chaos", false)
	local item = GameHelpers.Item.CreateItemByStat("WPN_Wand_Chaos", {
	StatsLevel = math.min(10, CharacterGetLevel(CharacterGetHostCharacter())),
	ItemType = "Epic",
	GMFolding = false,
	IsIdentified = true
	})
	if item ~= nil then
		ItemToInventory(item, CharacterGetHostCharacter(), 1, 1, 1)
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
			PrintDebug(Lib.inspect(item.Stats.DynamicStats))
			-- for i,v in pairs(deltamods) do
				-- 	local data = Ext.GetDeltaMod(v, "Armor")
				-- 	if data then
					-- 		for _,boostData in pairs(data.Boosts) do
						-- 			local boost = Ext.GetStat(boostData.Boost, 10)
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
	ItemToInventory(uuid, CharacterGetHostCharacter(), 1, 1, 1)
else
	error("Failed to create ARM_Light_Helmet")
end
end)

Ext.RegisterConsoleCommand("partyrestore", function(cmd)
	for player in GameHelpers.Character.GetPlayers(true) do
		PrintDebug(player.MyGuid)
		if player.Dead then
			CharacterResurrect(player.MyGuid)
		end
		player.Stats.CurrentVitality = player.Stats.MaxVitality
		PrintDebug(player.Stats.CurrentVitality, player.Stats.MaxVitality)
		CharacterSetHitpointsPercentage(player.MyGuid, 100.0)
		CharacterSetArmorPercentage(player.MyGuid, 100.0)
		CharacterSetMagicArmorPercentage(player.MyGuid, 100.0)
		ApplyStatus(player.MyGuid, "LEADERLIB_RECALC", 0.0, 1, player.MyGuid)
	end
end)

local cooldownsDisabled_AddedListener = false

function Debug.SetCooldownMode(b)
	if b then
		CharacterResetCooldowns(CharacterGetHostCharacter()) 
		if not cooldownsDisabled_AddedListener then
			Ext.RegisterOsirisListener("SkillCast", 4, "after", function(char,...)
				if Vars.Commands.CooldownsDisabled then
					CharacterResetCooldowns(char)
				end
			end)
			cooldownsDisabled_AddedListener = true
		end
	end
end

Ext.RegisterConsoleCommand("nocd", function(command)
	Vars.Commands.CooldownsDisabled = not Vars.Commands.CooldownsDisabled
	print(Vars.Commands.CooldownsDisabled and "Cooldowns disabled." or "Cooldowns enabled.")
	Debug.SetCooldownMode(Vars.Commands.CooldownsDisabled)
end)

Ext.RegisterConsoleCommand("refreshcd", function(command)
	local host = CharacterGetHostCharacter()
	GameHelpers.UI.RefreshSkillBarCooldowns(host)
end)


---@param params ItemDefinition
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
	if params.StatsLevel == nil then
		params.StatsLevel = CharacterGetLevel(CharacterGetHostCharacter())
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

	local item = GameHelpers.Item.CreateItemByStat(stat, params)
	if item ~= nil then
		ItemToInventory(item, CharacterGetHostCharacter(), 1, 1, 1)
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
		if Ext.StatGetAttribute(stat, "Unique") == 1 then
			rarity = "Unique"
		else
			rarity = "Epic"
		end
	end
	local level = CharacterGetLevel(CharacterGetHostCharacter())
	if levelstr ~= nil then
		level = math.tointeger(tonumber(levelstr)) or level
	end
	if not AddItemStat(stat, {StatsLevel = level, GenerationLevel = level, ItemType = rarity, GenerationItemType = rarity, HasGeneratedStats = rarity ~= "Unique"}) then
		PrintDebug("[additemstat] Failed to generate item!", stat, {})
	end
end)

AddConsoleVariable("additemstat", AddItemStat)

Ext.RegisterConsoleCommand("additemtemplate", function(command, template, count)
	if count == nil then 
		count = 1
	else
		count = math.tointeger(tonumber(count))
	end
	local host = CharacterGetHostCharacter()
	ItemTemplateAddTo(template, host, count, 1)
end)