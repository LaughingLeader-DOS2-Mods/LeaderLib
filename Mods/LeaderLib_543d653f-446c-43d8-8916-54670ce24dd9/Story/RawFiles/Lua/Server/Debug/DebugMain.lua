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

	if Ext.IsDeveloperMode() then
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
		PrintDebug("[LeaderLib_Debug.lua] ["..attribute.."] = "..tostring(NRD_HitGetInt(handle, attribute)).."|"..NRD_HitGetString(handle,attribute))
	elseif attribute_type == "Integer" or attribute_type == "Flag" or attribute_type == "Integer64" then
		PrintDebug("[LeaderLib_Debug.lua] ["..attribute.."] = "..tostring(NRD_HitGetInt(handle, attribute)).."")
	elseif attribute_type == "Real" then
		PrintDebug("[LeaderLib_Debug.lua] ["..attribute.."] = "..tostring(NRD_HitGetInt(handle, attribute)).."")
	elseif attribute_type == "String" then
		PrintDebug("[LeaderLib_Debug.lua] ["..attribute.."] = "..tostring(NRD_HitGetString(handle, attribute)).."")
	else
		PrintDebug("[LeaderLib_Debug.lua] ["..attribute.."] = "..tostring(NRD_HitGetString(handle, attribute)).."")
	end
end

local function TraceStatusType(obj, handle, attribute, attribute_type)
	if attribute_type == "Integer" or attribute_type == "Flag" or attribute_type == "Integer64" then
		PrintDebug("[LeaderLib_Debug.lua] ["..attribute.."] = "..tostring(NRD_StatusGetInt(obj, handle, attribute)).."")
	elseif attribute_type == "Real" then
		PrintDebug("[LeaderLib_Debug.lua] ["..attribute.."] = "..tostring(NRD_StatusGetReal(obj, handle, attribute)).."")
	elseif attribute_type == "String" then
		PrintDebug("[LeaderLib_Debug.lua] ["..attribute.."] = "..tostring(NRD_StatusGetString(obj, handle, attribute)).."")
	elseif attribute_type == "Enum" then
		PrintDebug("[LeaderLib_Debug.lua] ["..attribute.."] = "..tostring(NRD_StatusGetInt(obj, handle, attribute)).."|"..tostring(NRD_StatusGetString(obj, handle, attribute)).."")
	elseif attribute_type == "GuidString" or attribute_type == "Handle" then
		PrintDebug("[LeaderLib_Debug.lua] ["..attribute.."] = "..tostring(NRD_StatusGetGuidString(obj, handle, attribute)).."")
	end
end

function Debug_TraceStatus(obj, status, handle)
	PrintDebug("[LeaderLib_Debug.lua:TraceStatus] === "..obj.." || "..status.." ("..tostring(handle)..") === ")
	for attribute,attribute_type in pairs(STATUS_ATTRIBUTE) do
		TraceType(obj, handle, attribute, attribute_type)
	end
	PrintDebug("[LeaderLib_Debug.lua:TraceHit] Trying to get StatusType...")
	local status_type = Ext.StatGetAttribute(status, "StatusType")
	if status_type == "HEAL" then
		PrintDebug("[LeaderLib_Debug.lua:TraceStatus] ===== HEAL TYPE ===== ")
		for attribute,attribute_type in pairs(STATUS_HEAL_ATTRIBUTE) do
			TraceType(obj, handle, attribute, attribute_type)
		end
	elseif status_type == "HEALING" then
		PrintDebug("[LeaderLib_Debug.lua:TraceStatus] ===== HEALING TYPE ===== ")
		for attribute,attribute_type in pairs(STATUS_HEALING_ATTRIBUTE) do
			TraceType(obj, handle, attribute, attribute_type)
		end
	end
end

function Debug_TraceHitPrepare(target,attacker,damage,handle)
	PrintDebug("[LeaderLib_Debug.lua:TraceHitPrepare] damage("..tostring(damage)..") attacker("..tostring(attacker)..") target("..tostring(target)..") handle("..tostring(handle)..")")
	PrintDebug("=======================")
	for attribute,attribute_type in pairs(HIT_ATTRIBUTE) do
		TraceType(target, handle, attribute, attribute_type)
	end
	PrintDebug("=======================")
end

function Debug_TraceOnHit(target,attacker,damage,handle)
	PrintDebug("[LeaderLib_Debug.lua:TraceOnHit] damage("..tostring(damage)..") attacker("..tostring(attacker)..") target("..tostring(target)..") handle("..tostring(handle)..")")
	PrintDebug("=======================")
	PrintDebug("==========HIT==========")
	PrintDebug("=======================")
	for attribute,attribute_type in pairs(HIT_ATTRIBUTE) do
		TraceStatusType(target, handle, attribute, attribute_type)
	end
	PrintDebug("=======================")
	PrintDebug("======HIT STATUS=======")
	PrintDebug("=======================")
	for attribute,attribute_type in pairs(STATUS_HIT) do
		TraceStatusType(target, handle, attribute, attribute_type)
	end
	PrintDebug("=======================")
	PrintDebug("========STATUS=========")
	PrintDebug("=======================")
	for attribute,attribute_type in pairs(STATUS_ATTRIBUTE) do
		TraceStatusType(target, handle, attribute, attribute_type)
	end
	PrintDebug("=======================")
	PrintDebug("[LeaderLib_Debug.lua:TraceHit] Trying to get StatusId...")
	local status = NRD_StatusGetString(target, handle, "StatusId")
	if status ~= nil and status ~= "HIT" then
		Debug_TraceStatus(target, status, handle)
	end
	PrintDebug("=======================")
end

function PrintModDB()
	PrintDebug("[LeaderLib_Debug.lua:PrintDB] Printing database DB_LeaderLib_Mods_Registered.")
	local values = Osi.DB_LeaderLib_Mods_Registered:Get(nil, nil, nil, nil, nil, nil, nil, nil)
    PrintDebug(Ext.JsonStringify(values))
end

function PrintDB(name, arity)
	PrintDebug("[LeaderLib_Debug.lua:PrintDB] Printing database "..name.." ("..tostring(arity)..")")
end

function PrintTest(str)
	NRD_DebugLog("[LeaderLib:Lua:PrintTest] " .. str)
end

function Debug_TestSkillScaleMath(level)
	local stat = Ext.GetStat("Damage_Burning")
	local dmgFromBase = stat.DamageFromBase * 0.01
	local damage = Game.Math.GetAverageLevelDamage(math.tointeger(level))
	local damageAdjusted = damage * dmgFromBase
    local damageRange = damageAdjusted * 0.3
	local minDamage = math.max(dmgFromBase * dmgFromBase * (damageAdjusted - damageRange), 1.0)
	local maxDamage = math.max(dmgFromBase * dmgFromBase * (damageAdjusted + damageRange), 1.0)

	if minDamage > 0 then
		maxDamage = math.max(maxDamage, minDamage + 1.0)
	end

	PrintDebug("[LeaderLib_Debug.lua:TestSkillScaleMath] Level("..level..") Range(30) Damage("..tostring(damage)..") FromBase("..tostring(damageAdjusted)..") Final Damage("..tostring(minDamage).." - "..tostring(maxDamage)..")" )
end

function GenerateIdeHelpers()
	Ext.GenerateIdeHelpers()
end

--[[SkillProperties = {{
Type = "Status",
Action = "LLWEAPONEX_SUCKER_PUNCH",
Context = {"Target"},
Duration = 6.0,
StatusChance = 1.0,
Arg3 = "",
Arg4 = -1,
Arg5 = -1,
SurfaceBoost = false
}}
]]