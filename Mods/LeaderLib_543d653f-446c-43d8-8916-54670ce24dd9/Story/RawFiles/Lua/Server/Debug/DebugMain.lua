LeaderLib_DebugInitCalls = {}

local function Debug_TorturerBugTest()
	local host = CharacterGetHostCharacter()
	--CharacterGiveReward(host, "ST_LeaderLib_Debug_Cheats1", 1)
	CharacterAddTalent(host, "Torturer")
	CharacterAddAbility(host, "Telekinesis", 10)
	local x,y,z = GetPosition(host)
	--710e98d9-b9e2-4563-82e6-9e9ce90118c8
	--WPN_RC_UNIQUE_Chastity
	local item = CreateItemTemplateAtPosition("710e98d9-b9e2-4563-82e6-9e9ce90118c8", x, y, z)
	NRD_ItemCloneBegin(item)
	NRD_ItemCloneSetString("GenerationStatsId", "WPN_RC_UNIQUE_Chastity")
	NRD_ItemCloneSetString("StatsEntryName", "WPN_RC_UNIQUE_Chastity")
	NRD_ItemCloneSetString("CustomDisplayName", "Stabby Bleedy Dagger")
	NRD_ItemCloneSetInt("GenerationLevel", 1)
	NRD_ItemCloneSetInt("StatsLevel", 1)
	NRD_ItemCloneSetInt("IsIdentified", 1)
	local cloned = NRD_ItemClone()
	ItemRemove(item)
	ItemMoveToPosition(cloned, x,y,z, 20.0, 20.0, "", 0)
end

function AddDebugInitCall(func)
if LeaderLib_DebugInitCalls == nil then LeaderLib_DebugInitCalls {} end
LeaderLib_DebugInitCalls[#LeaderLib_DebugInitCalls+1] = func
end

function DebugInit()
	for i,func in pairs(LeaderLib_DebugInitCalls) do
		if func ~= nil and type(func) == "function" then
			pcall(func)
		end
	end
	
	if Vars.DebugMode then
		--Debug_TorturerBugTest()
	end
end

local HIT_ATTRIBUTE = {
Equipment = "Integer",
DeathType = "Enum",
DamageType = "Enum",
AttackDirection = "Integer",
ArmorAbsorption = "Integer",
LifeSteal = "Integer",
HitWithWeapon = "Integer",
Hit = "Flag",
Blocked = "Flag",
Dodged = "Flag",
Missed = "Flag",
CriticalHit = "Flag",
Backstab = "Flag",
FromSetHP = "Flag",
DontCreateBloodSurface = "Flag",
Reflection = "Flag",
NoDamageOnOwner = "Flag",
FromShacklesOfPain = "Flag",
DamagedMagicArmor = "Flag",
DamagedPhysicalArmor = "Flag",
DamagedVitality = "Flag",
PropagatedFromOwner = "Flag",
Surface = "Flag",
DoT = "Flag",
ProcWindWalker = "Flag",
CounterAttack = "Flag",
Poisoned = "Flag",
Bleeding = "Flag",
Burning = "Flag",
NoEvents = "Flag",
}

local STATUS_HIT = {
SkillId = "String",
HitByHandle = "GuidString",
HitWithHandle = "GuidString",
WeaponHandle = "GuidString",
HitReason = "Integer",
Interruption = "Flag",
AllowInterruptAction = "Flag",
ForceInterrupt = "Flag",
DecDelayDeathCount = "Flag",
ImpactPosition = "Vector3",
ImpactOrigin = "Vector3",
ImpactDirection = "Vector3",
}

local STATUS_ATTRIBUTE = {
StatusId = "String",
--StatusHandle = "Integer64",
TargetHandle = "Handle",
StatusSourceHandle = "Handle",
StartTimer = "Real",
LifeTime = "Real",
CurrentLifeTime = "Real",
TurnTimer = "Real",
Strength = "Real",
StatsMultiplier = "Real",
CanEnterChance = "Integer",
DamageSourceType = "Enum",
KeepAlive = "Flag",
IsOnSourceSurface = "Flag",
IsFromItem = "Flag",
Channeled = "Flag",
IsLifeTimeSet = "Flag",
InitiateCombat = "Flag",
Influence = "Flag",
BringIntoCombat = "Flag",
IsHostileAct = "Flag",
IsInvulnerable = "Flag",
IsResistingDeath = "Flag",
ForceStatus = "Flag",
ForceFailStatus = "Flag",
RequestDelete = "Flag",
RequestDeleteAtTurnEnd = "Flag",
Started = "Flag",
}

local STATUS_HEAL_ATTRIBUTE = {
EffectTime = "Real",
HealAmount = "Integer",
HealEffect = "Enum",
HealEffectId = "String",
HealType = "Enum",
AbsorbSurfaceRange = "Integer",
TargetDependentHeal = "Flag",
}

local STATUS_HEALING_ATTRIBUTE = {
HealAmount = "Integer",
TimeElapsed = "Real",
HealEffect = "Enum",
HealEffectId = "String",
SkipInitialEffect = "Flag",
HealingEvent = "Integer",
HealStat = "Enum",
AbsorbSurfaceRange = "Integer",
}

local function TraceType(obj, handle, attribute, attribute_type)
	if attribute_type == "Enum" then
		fprint(LOGLEVEL.TRACE, "["..attribute.."] = "..tostring(NRD_HitGetInt(handle, attribute)).."|"..NRD_HitGetString(handle,attribute))
	elseif attribute_type == "Integer" or attribute_type == "Flag" or attribute_type == "Integer64" then
		fprint(LOGLEVEL.TRACE, "["..attribute.."] = "..tostring(NRD_HitGetInt(handle, attribute)).."")
	elseif attribute_type == "Real" then
		fprint(LOGLEVEL.TRACE, "["..attribute.."] = "..tostring(NRD_HitGetInt(handle, attribute)).."")
	elseif attribute_type == "String" then
		fprint(LOGLEVEL.TRACE, "["..attribute.."] = "..tostring(NRD_HitGetString(handle, attribute)).."")
	else
		fprint(LOGLEVEL.TRACE, "["..attribute.."] = "..tostring(NRD_HitGetString(handle, attribute)).."")
	end
end

local function TraceStatusType(obj, handle, attribute, attribute_type)
	if attribute_type == "Integer" or attribute_type == "Flag" or attribute_type == "Integer64" then
		fprint(LOGLEVEL.TRACE, "["..attribute.."] = "..tostring(NRD_StatusGetInt(obj, handle, attribute)).."")
	elseif attribute_type == "Real" then
		fprint(LOGLEVEL.TRACE, "["..attribute.."] = "..tostring(NRD_StatusGetReal(obj, handle, attribute)).."")
	elseif attribute_type == "String" then
		fprint(LOGLEVEL.TRACE, "["..attribute.."] = "..tostring(NRD_StatusGetString(obj, handle, attribute)).."")
	elseif attribute_type == "Enum" then
		fprint(LOGLEVEL.TRACE, "["..attribute.."] = "..tostring(NRD_StatusGetInt(obj, handle, attribute)).."|"..tostring(NRD_StatusGetString(obj, handle, attribute)).."")
	elseif attribute_type == "GuidString" or attribute_type == "Handle" then
		fprint(LOGLEVEL.TRACE, "["..attribute.."] = "..tostring(NRD_StatusGetGuidString(obj, handle, attribute)).."")
	end
	if attribute == "SkillId" then
		local skillprototype = NRD_StatusGetString(obj, handle, "SkillId")
		if skillprototype ~= "" and skillprototype ~= nil then
			local skill = GetSkillEntryName(skillprototype)
			fprint(LOGLEVEL.TRACE, "["..attribute.."] = "..skillprototype.." => "..skill.."")
		end
	end
end

function Debug_TraceStatus(obj, status, handle)
	fprint(LOGLEVEL.TRACE, "[LeaderLib_Debug.lua:TraceStatus] === "..obj.." || "..status.." ("..tostring(handle)..") === ")
	for attribute,attribute_type in pairs(STATUS_ATTRIBUTE) do
		TraceType(obj, handle, attribute, attribute_type)
	end
	fprint(LOGLEVEL.TRACE, "[LeaderLib_Debug.lua:TraceHit] Trying to get StatusType...")
	local status_type = Ext.StatGetAttribute(status, "StatusType")
	if status_type == "HEAL" then
		fprint(LOGLEVEL.TRACE, "[LeaderLib_Debug.lua:TraceStatus] ===== HEAL TYPE ===== ")
		for attribute,attribute_type in pairs(STATUS_HEAL_ATTRIBUTE) do
			TraceType(obj, handle, attribute, attribute_type)
		end
	elseif status_type == "HEALING" then
		fprint(LOGLEVEL.TRACE, "[LeaderLib_Debug.lua:TraceStatus] ===== HEALING TYPE ===== ")
		for attribute,attribute_type in pairs(STATUS_HEALING_ATTRIBUTE) do
			TraceType(obj, handle, attribute, attribute_type)
		end
	end
end

function Debug_TraceHitPrepare(target,attacker,damage,handle,state)
	fprint(LOGLEVEL.TRACE, "[PrepareHit:%s] damage(%s)[%s] attacker(%s) target(%s) handle(%s)", state, damage, NRD_HitGetString(handle, "DamageType"), attacker,target,handle)
	fprint(LOGLEVEL.TRACE, "=======================")
	for i,damageType in Data.DamageTypes:Get() do
		local amount = NRD_HitGetDamage(handle, damageType)
		if amount then
			fprint(LOGLEVEL.TRACE, "[%s] = (%s)", damageType, amount)
		end
	end
	for attribute,attribute_type in pairs(HIT_ATTRIBUTE) do
		TraceType(target, handle, attribute, attribute_type)
	end
	fprint(LOGLEVEL.TRACE, "=======================")
end

function Debug_TraceOnHit(target,attacker,damage,handle,state)
	fprint(LOGLEVEL.TRACE, "[LeaderLib_Debug.lua:TraceOnHit] damage("..tostring(damage)..") attacker("..tostring(attacker)..") target("..tostring(target)..") handle("..tostring(handle)..")")
	fprint(LOGLEVEL.TRACE, "=======================")
	for i,damageType in Data.DamageTypes:Get() do
		local amount = NRD_HitStatusGetDamage(target,handle, damageType)
		if amount then
			fprint(LOGLEVEL.TRACE, "[%s] = (%s)", damageType, amount)
		end
	end
	--[[ fprint(LOGLEVEL.TRACE, "=======================")
	fprint(LOGLEVEL.TRACE, "==========HIT==========")
	fprint(LOGLEVEL.TRACE, "=======================")
	for attribute,attribute_type in pairs(HIT_ATTRIBUTE) do
		TraceStatusType(target, handle, attribute, attribute_type)
	end
	fprint(LOGLEVEL.TRACE, "=======================")
	fprint(LOGLEVEL.TRACE, "======HIT STATUS=======")
	fprint(LOGLEVEL.TRACE, "=======================")
	for attribute,attribute_type in pairs(STATUS_HIT) do
		TraceStatusType(target, handle, attribute, attribute_type)
	end
	fprint(LOGLEVEL.TRACE, "=======================")
	fprint(LOGLEVEL.TRACE, "========STATUS=========")
	fprint(LOGLEVEL.TRACE, "=======================")
	for attribute,attribute_type in pairs(STATUS_ATTRIBUTE) do
		TraceStatusType(target, handle, attribute, attribute_type)
	end
	fprint(LOGLEVEL.TRACE, "=======================")
	fprint(LOGLEVEL.TRACE, "[LeaderLib_Debug.lua:TraceHit] Trying to get StatusId...")
	local status = NRD_StatusGetString(target, handle, "StatusId")
	if status ~= nil and status ~= "HIT" then
		Debug_TraceStatus(target, status, handle)
	end ]]
	fprint(LOGLEVEL.TRACE, "=======================")
end

-- Ext.Osiris.RegisterListener("NRD_OnPrepareHit", 4, "before", function(target, attacker, damage, handle)
-- 	Debug_TraceHitPrepare(target, attacker, damage, handle, "before")
-- end)
-- Ext.Osiris.RegisterListener("NRD_OnPrepareHit", 4, "after", function(target, attacker, damage, handle)
-- 	Debug_TraceHitPrepare(target, attacker, damage, handle, "after")
-- end)

-- Ext.Osiris.RegisterListener("NRD_OnHit", 4, "before", function(target, attacker, damage, handle)
-- 	Debug_TraceOnHit(target, attacker, damage, handle)
-- end)

function PrintModDB()
	fprint(LOGLEVEL.TRACE, "[LeaderLib_Debug.lua:PrintDB] Printing database DB_LeaderLib_Mods_Registered.")
	local values = Osi.DB_LeaderLib_Mods_Registered:Get(nil, nil, nil, nil, nil, nil, nil, nil)
	fprint(LOGLEVEL.TRACE, Common.JsonStringify(values))
end

function PrintDB(name, arity)
	fprint(LOGLEVEL.TRACE, "[LeaderLib_Debug.lua:PrintDB] Printing database "..name.." ("..tostring(arity)..")")
end

function PrintTest(str)
	NRD_DebugLog("[LeaderLib:Lua:PrintTest] " .. str)
end

function LeaderLog(logType, ...)
	if Osi.LeaderLog_QRY_LogTypeEnabled(logType) then
		local text = StringHelpers.Join("", {...})
		Osi.LeaderLog_Internal_RunString(logType, text)
	end
end

function Debug_TestSkillScaleMath(level)
	local stat = Ext.Stats.Get("Damage_Burning")
	local dmgFromBase = stat.DamageFromBase * 0.01
	local damage = GameHelpers.Math.GetAverageLevelDamage(math.tointeger(level))
	local damageAdjusted = damage * dmgFromBase
	local damageRange = damageAdjusted * 0.3
	local minDamage = math.max(dmgFromBase * dmgFromBase * (damageAdjusted - damageRange), 1.0)
	local maxDamage = math.max(dmgFromBase * dmgFromBase * (damageAdjusted + damageRange), 1.0)
	
	if minDamage > 0 then
		maxDamage = math.max(maxDamage, minDamage + 1.0)
	end
	
	fprint(LOGLEVEL.TRACE, "[LeaderLib_Debug.lua:TestSkillScaleMath] Level("..level..") Range(30) Damage("..tostring(damage)..") FromBase("..tostring(damageAdjusted)..") Final Damage("..tostring(minDamage).." - "..tostring(maxDamage)..")" )
end

function Debug_Iterator_PrintCharacter(uuid)
	---@type EsvCharacter
	local character = GameHelpers.GetCharacter(uuid)
	---@type StatCharacter
	local characterStats = character.Stats
	
	Ext.Utils.Print("CHARACTER")
	Ext.Utils.Print("===============")
	Ext.Utils.Print(Lib.serpent.block({
		UUID = uuid,
		NetID = character.NetID,
		Name = GameHelpers.GetDisplayName(character),
		Stat = characterStats.Name,
		Archetype = character.Archetype,
		Pos = character.WorldPos,
		Rot = character.Rotation
	}, {sortkeys=false}))
	Ext.Utils.Print("===============")
end

local debug_DeltaModProperties = {
{Name="Name", Type="string"},
{Name="BoostType", Type="string"},
{Name="MinLevel", Type="integer"},
{Name="MaxLevel", Type="integer"},
{Name="Frequency", Type="integer"},
{Name="ModifierType", Type="string"},
{Name="SlotType", Type="string"},
{Name="WeaponType", Type="string"},
{Name="Handedness", Type="string"},
{Name="ArmorType", Type="string"},
{Name="Boosts", Type="table"},
}

function Debug_Iterator_PrintDeltamod(item, deltamod, isGenerated)
	local modifierType = NRD_StatGetType(NRD_ItemGetStatsId(item))
	---@type DeltaMod
	local deltamodObj = Ext.GetDeltaMod(deltamod, modifierType)
	Ext.Utils.Print("DELTAMOD")
	Ext.Utils.Print("===============")
	Ext.Utils.Print("Item:", item)
	Ext.Utils.Print("Item Stat:", GameHelpers.GetItem(item).Stats.Name)
	Ext.Utils.Print("Name:", deltamod)
	Ext.Utils.Print("ModifierType:", modifierType)
	Ext.Utils.Print("IsGenerated:", isGenerated)
	if deltamodObj ~= nil then
		for i,prop in pairs(debug_DeltaModProperties) do
			if prop.Name == "Boosts" then
				Ext.Utils.Print("-------")
				Ext.Utils.Print("Deltamod Boosts:")
				Ext.Utils.Print("-------")
				for i,boost in pairs(deltamodObj.Boosts) do
					Ext.Utils.Print(boost.Boost, boost.Count)
				end
				Ext.Utils.Print("-------")
			else
				Ext.Utils.Print(prop.Name, deltamodObj[prop.Name])
			end
		end
	end
end

Events.LuaReset:Subscribe(function()
	for player in GameHelpers.Character.GetPlayers(true) do
		CharacterResetCooldowns(player.MyGuid)
	end
end)

--[[ Ext.Events.OnPeekAiAction:Subscribe(function (e)
	local character = Ext.Entity.GetCharacter(e.CharacterHandle)
	if character and character.Stats.Name == "AMC_Stats_WarTower" then
		Ext.IO.SaveFile(string.format("Dumps/AI/AMC_Stats_WarTower_%s_OnAfterSortAiActions.json", Ext.Utils.MonotonicTime()), Ext.DumpExport(e.Request))
	end
end)
Ext.Events.OnAfterSortAiActions:Subscribe(function (e) local character = Ext.Entity.GetCharacter(e.CharacterHandle) if character and character.Stats.Name == "AMC_Stats_WarTower" then Ext.IO.SaveFile(string.format("Dumps/AI/AMC_Stats_WarTower_%s_OnAfterSortAiActions.json", Ext.Utils.MonotonicTime()), Ext.DumpExport(e.Request)) end end) ]]

-- Ext.Events.OnBeforeSortAiActions:Subscribe(function (e)
-- 	for _,v in pairs(e.Request.AiActions) do
-- 		if v.ActionType == "Skill" and string.find(v.SkillId, "Target_FirstAidEnemy") then
-- 			v.FinalScore = 1000
-- 			v.ActionFinalScore = 1000
-- 		end
-- 	end
-- end)

--[[ if Ext.Debug.IsDeveloperMode() then
	Ext.Events.OnPeekAiAction:Subscribe(function (e)
		if e.ActionType == "Skill" then
			for _,v in pairs(e.Request.AiActions) do
				if v.ActionType == "Skill" then
					v.SkillId = "Target_FirstAidEnemy_-1"
				end
			end
			for _,v in pairs(e.Request.Skills) do
				v.SkillId = "Target_FirstAidEnemy"
			end
		end
		Ext.IO.SaveFile(string.format("Dumps/AI/%s_OnPeekAiAction.json", Ext.Utils.MonotonicTime()), Ext.DumpExport(e))
	end)
	
	Ext.Events.OnBeforeSortAiActions:Subscribe(function (e)
		Ext.IO.SaveFile(string.format("Dumps/AI/%s_OnBeforeSortAiActions.json", Ext.Utils.MonotonicTime()), Ext.DumpExport(e))
	end)
	
	Ext.Events.OnAfterSortAiActions:Subscribe(function (e)
		for _,v in pairs(e.Request.AiActions) do
			if v.ActionType == "Skill" then
				v.SkillId = "Target_FirstAidEnemy_-1"
			end
		end
		for _,v in pairs(e.Request.Skills) do
			v.SkillId = "Target_FirstAidEnemy"
		end
		Ext.IO.SaveFile(string.format("Dumps/AI/%s_OnAfterSortAiActions.json", Ext.Utils.MonotonicTime()), Ext.DumpExport(e))
	end)
	
	Ext.Events.StatusDelete:Subscribe(function (e)
		if e.Status.StatusId == "HASTED" then
			Ext.IO.SaveFile("Dumps/StatusDelete_HASTED.json", Ext.DumpExport(e))
		end
	end)
end ]]


--S_Player_Fane_02a77f1f-872b-49ca-91ab-32098c443beb
--[[ local TARGET = "02a77f1f-872b-49ca-91ab-32098c443beb"
local aboutToPickUpItem = {}

Ext.Osiris.RegisterListener("ProcProcessPickupOfItem", 3, "before", function (charGUID, itemGUID, requestID)
	charGUID = GetUUID(charGUID)
	if charGUID == TARGET then
		return
	end
	itemGUID = GetUUID(itemGUID)
	local blockResult = Osi.DB_CustomPickupItemResponse:Get(charGUID, itemGUID, nil)
	if blockResult and blockResult[1] then
		if blockResult[1][3] == 0 then
			return
		end
	end
	aboutToPickUpItem[itemGUID] = charGUID
end)

Ext.Osiris.RegisterListener("ItemAddedToCharacter", 2, "after", function (itemGUID, charGUID)
	charGUID = GetUUID(charGUID)
	itemGUID = GetUUID(itemGUID)
	if aboutToPickUpItem[itemGUID] == charGUID then
		aboutToPickUpItem[itemGUID] = nil
		ItemToInventory(itemGUID, TARGET, ItemGetAmount(itemGUID), 1, 1)
	end
end) ]]

--[[ Events.CharacterDied:Subscribe(function (e)
	e:Dump()
end) ]]

--[[ Events.OnHeal:Subscribe(function (e)
	e:Dump()
end)

Events.OnStatus:Subscribe(function (e)
	e:Dump()
end, {Priority=0, MatchArgs={StatusId="HEAL"}}) ]]

--[[ local arrowSkills = {
	"Projectile_FireArrow",
	"Projectile_ExplosionArrow",
	"Projectile_FreezingArrow",
	"Projectile_WaterArrow",
	"Projectile_CursedFireArrow",
	"Projectile_BlessedWaterArrow",
	"Projectile_SlowDownArrow",
	"Projectile_StunningArrow",
	"Projectile_SteamCloudArrow",
	"Projectile_SmokescreenArrow",
	"Projectile_StaticCloudArrow",
	"Projectile_SilverArrow",
	"Projectile_BleedingArrow",
	"Projectile_KnockedOutArrow",
	"Projectile_PoisonedCloudArrow",
	"Projectile_CharmingArrow",
	"Projectile_PoisonArrow",
	"Projectile_DebuffAllArrow",
}

SkillManager.Register.BeforeProjectileShoot(arrowSkills, function (e)
    if e.Character:GetStatus("HASTED") then
		local lastSkill = e.Data.SkillId
		local _,_,level = string.find(e.Data.SkillId, "_(%-?%d+)$")
		if level then
			e.Data.SkillId = "Projectile_SmokescreenArrow" .. "_" .. level
		else
			e.Data.SkillId = "Projectile_SmokescreenArrow"
		end
		local newDamage = GameHelpers.Damage.GetSkillDamage("Projectile_SmokescreenArrow", e.Character)
		e.Data.DamageList:CopyFrom(newDamage)
		fprint(LOGLEVEL.DEFAULT, "[Test] Replaced projectile skill (%s) => (%s)", lastSkill, e.Data.SkillId)
    end
end) ]]


--[[
---@type EsvStatusPolymorphed
local status = Ext.PrepareStatus(target, "POLYMORPHED", -1.0)
status.PolymorphResult = "2429c3a4-e54b-4cea-add7-2bc53024935a"
status.OriginalTemplate = me.RootTemplate.Id;status.OriginalTemplateType = 1;status.DisableInteractions = false;status.TransformedRace = ""
Ext.ApplyStatus(status)

Ext.Events.BeforeStatusDelete:Subscribe(function(e) if e.Status.StatusType == "POLYMORPHED" then Ext.Dump({StatusId=e.Status.StatusId, PolymorphResult=e.Status.PolymorphResult, TransformedRace = e.Status.TransformedRace, OriginalTemplate = e.Status.OriginalTemplate, OriginalTemplateType = e.Status.OriginalTemplateType}) end end)

Mods.LeaderLib.StatusManager.Subscribe.Applied("POLYMORPHED", function(e) local status = e.Status; status.PolymorphResult = "2429c3a4-e54b-4cea-add7-2bc53024935a"; status.OriginalTemplate = e.Target.RootTemplate.Id;status.OriginalTemplateType = 1;status.DisableInteractions = false;status.TransformedRace = "" end)

local status = Ext.PrepareStatus(me.MyGuid, "POLYMORPHED", 12.0); status.ForceStatus = true; status.PolymorphResult = "2429c3a4-e54b-4cea-add7-2bc53024935a"; status.OriginalTemplate = me.RootTemplate.Id;status.OriginalTemplateType = 1;status.DisableInteractions = false;status.TransformedRace = ""; Ext.ApplyStatus(status)
]]

--[[ SkillManager.Register.Hit("Projectile_EnemyFireball", function (e)
	if e.Data.Success then
		--GameHelpers.Damage.ApplySkillDamage(e.Character, e.Data.TargetObject, "Projectile_Fireball")
		GameHelpers.Skill.Explode(e.Data.TargetObject, "Projectile_LLWEAPONEX_MasteryBonus_CripplingBlowPiercingDamage", e.Character)
		local dynDamageType = e.Character.Stats.MainWeapon.DynamicStats[1].DamageType
	end
end)

Events.OnHit:Subscribe(function (e)
	if GameHelpers.Character.IsPlayer(e.Source) then
		Ext.Utils.Print(e.Data.HitContext.HitType, e.Data.HitStatus.HitReason, Ext.DumpExport(e.Data.DamageList:ToTable()))
	end
	-- if e.Data.IsFromSkill then
	-- 	Ext.Utils.Print(e.Data.Skill, e.Data.HitRequest.TotalDamageDone, Ext.DumpExport(e.Data.DamageList:ToTable()))
	-- end
end)

Ext.RegisterConsoleCommand("llconetest", function (cmd, zoneAngle, mathAngle)
	local esvCaster = Ext.Entity.GetCharacter(CharacterGetHostCharacter())
	local skill = Ext.Stats.Get("Cone_GroundSmash")
	local length = -skill.Range
	mathAngle = not mathAngle and skill.Angle/2 or tonumber(mathAngle)
	zoneAngle = not zoneAngle and mathAngle or tonumber(zoneAngle)
	local angleDeg = mathAngle + 180

	local _,ry,_ = GetRotation(esvCaster.MyGuid)
	local angle1 = ry + angleDeg
	local angle2 = ry - angleDeg

	local rotMat1 = Ext.Math.BuildRotation3({0,1,0}, math.rad(angle1))
	local rotMat2 = Ext.Math.BuildRotation3({0,1,0}, math.rad(angle2))

	local px,py,pz = table.unpack(esvCaster.WorldPos)
	local tx,ty,tz = px - rotMat1[7] * length, py, pz - rotMat1[9] * length
	local ux,uy,uz = px - rotMat2[7] * length, py, pz - rotMat2[9] * length

	PlayEffectAtPositionAndRotation("RS3_FX_Skills_Warrior_GroundSmash_Cast_01", tx, ty, tz, angle1)
	PlayEffectAtPositionAndRotation("RS3_FX_Skills_Warrior_GroundSmash_Cast_01", ux, uy, uz, angle2)
	GameHelpers.Skill.ShootZoneAt("Cone_GroundSmash", esvCaster, esvCaster.WorldPos, {Position={tx,ty,tz}, Shape=0, SurfaceType="Water",AngleOrBase=zoneAngle})
	GameHelpers.Skill.ShootZoneAt("Cone_GroundSmash", esvCaster, esvCaster.WorldPos, {Position={ux,uy,uz}, Shape=0, SurfaceType="Water",AngleOrBase=zoneAngle})
end) ]]

-- Ext.Osiris.RegisterListener("NRD_OnActionStateEnter", 2, "after", function (guid, actionType)
-- 	if actionType == "Attack" then
-- 		local character = GameHelpers.GetCharacter(guid)
-- 		for _,v in pairs(character.ActionMachine.Layers) do
-- 			if v.State and v.State.Type == "Attack" then
-- 				local action = v.State --[[@as EsvASAttack]]
-- 				for _,dlist in pairs(action.OffHandDamageList) do
-- 					dlist.DamageList:ConvertDamageType("Water")
-- 				end
-- 			end
-- 		end
-- 	end
-- end)

-- Ext.Audio.PostEvent(_C().Handle, "Skill_Earth_Fortify_Impact_01", 0)

---@class CombatMovementManager
---@field _TickIndex integer|nil
--[[ local CombatMovementManager = {
	DIST_MIN = 0.5,
	TICKS_MIN = 10
}

local _totalTicks = 0

---@type table<ComponentHandle, vec3>
local _combatPositions = {}

local _getTurnManager = Ext.Combat.GetTurnManager

---@param checkTag boolean|nil
---@return fun():EsvCharacter
local function GetActiveTurnCharacters(checkTag)
	local characters = {}
	local count = 0
	local tm = _getTurnManager()
	if tm then
		local len = #tm.Combats
		for i=1,len do
			local combat = tm.Combats[i]
			if combat.IsActive then
				local team = tm.Combats[i]:GetCurrentTurnOrder()[1]
				if team and team.Character then
					if not checkTag or not team.Character:HasTag("MyMod_Moved") then
						count = count + 1
						characters[count] = team.Character
					end
				end
			end
		end
	end
	local i = 0
	return function ()
		i = i + 1
		if i <= count then
			return characters[i]
		end
	end
end

---@param character EsvCharacter
---@param lastPos vec3
function CombatMovementManager:OnCharacterMoved(character, lastPos)
	SetTag(character.MyGuid, "MyMod_Moved")
end

---@param character EsvCharacter
---@param skipCheck boolean|nil 
local function CharacterHasMoved(character, skipCheck)
	if not skipCheck then
		local last = _combatPositions[character.Handle]
		if last and Ext.Math.Distance(last, character.WorldPos) >= CombatMovementManager.DIST_MIN then
			CombatMovementManager:OnCharacterMoved(character, last)
			_combatPositions[character.Handle] = nil
			return true
		end
	end
	return false
end

---@param skipCheck boolean|nil Skip checking the distance from the last position.
---@return boolean isWaiting
function CombatMovementManager:UpdatePositions(skipCheck)
	local isWaiting = false
	for character in GetActiveTurnCharacters(true) do
		if not CharacterHasMoved(character, skipCheck) then
			_combatPositions[character.Handle] = character.WorldPos
			isWaiting = true
		end
	end
	return isWaiting
end

---@param e LuaEventBase|LuaTickEvent
function CombatMovementManager:Tick(e)
	_totalTicks = _totalTicks + 1
	if _totalTicks >= self.TICKS_MIN then
		if not self:UpdatePositions() then
			Ext.OnNextTick(function (e)
				CombatMovementManager:Toggle(false)
			end)
		else
			_totalTicks = 0
		end
	end
end

---@param b boolean
---@param skipClearPositions boolean|nil
function CombatMovementManager:Toggle(b, skipClearPositions)
	if b then
		if self._TickIndex == nil then
			_totalTicks = 0
			self._TickIndex = Ext.Events.Tick:Subscribe(function(e) self:Tick(e) end)
			self:UpdatePositions(true)
		end
	else
		if not skipClearPositions then
			_combatPositions = {}
		end
		_totalTicks = 0
		if self._TickIndex ~= nil then
			Ext.Events.Tick:Unsubscribe(self._TickIndex)
			self._TickIndex = nil
		end
	end
end

local function IsWaitingForActiveCharacter()
	for character in GetActiveTurnCharacters() do
		if not character:HasTag("MyMod_Moved") then
			return true
		end
	end
	return false
end

Events.Initialized:Subscribe(function (e)
	CombatMovementManager:Toggle(IsWaitingForActiveCharacter())
end)

Ext.Osiris.RegisterListener("ObjectTurnStarted", 1, "after", function (guid)
	CombatMovementManager:Toggle(true)
end)

Ext.Osiris.RegisterListener("ObjectTurnEnded", 1, "after", function (guid)
	CombatMovementManager:Toggle(false)
	ClearTag(guid, "MyMod_Moved")
end)

Ext.Osiris.RegisterListener("CombatEnded", 1, "after", function (id)
	Ext.OnNextTick(function (e)
		CombatMovementManager:Toggle(IsWaitingForActiveCharacter())
	end)
end)

Ext.Events.GameStateChanged:Subscribe(function (e)
	if e.ToState ~= "Running" then
		CombatMovementManager:Toggle(false, true)
	end
end) ]]


--[[
-- AOO bug test - AOO applying on your turn ends the turn
local obj = Ext.Entity.GetCharacter("08348b3a-bded-4811-92ce-f127aa4310e0"); GameHelpers.Status.Apply(obj, "AOO", 6.0, 1, nil, nil, nil, nil, {AoOTargetHandle=obj.Handle, SourceHandle=me.Handle, PartnerHandle=obj.Handle})
]]