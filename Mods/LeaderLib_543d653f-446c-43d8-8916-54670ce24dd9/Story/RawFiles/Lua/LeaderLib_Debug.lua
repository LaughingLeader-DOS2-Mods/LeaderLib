local HIT_ATTRIBUTE = {
	Equipment = "Integer",
	DeathType = "Enum",
	DamageType = "Enum",
	AttackDirection = "Enum",
	ArmorAbsorption = "Integer",
	LifeSteal = "Integer",
	HitWithWeapon = "Integer",
	Hit = "Flag",
	Blocked = "Flag",
	Dodged = "Flag",
	Missed = "Flag",
	CriticalHit = "Flag",
	AlwaysBackstab = "Flag",
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
	if attribute_type == "Integer" or attribute_type == "Flag" or attribute_type == "Integer64" then
		Ext.Print("[LeaderLib_Debug.lua] ["..attribute.."] = "..tostring(NRD_StatusGetInt(obj, handle, attribute)).."")
	elseif attribute_type == "Real" then
		Ext.Print("[LeaderLib_Debug.lua] ["..attribute.."] = "..tostring(NRD_StatusGetReal(obj, handle, attribute)).."")
	elseif attribute_type == "String" then
		Ext.Print("[LeaderLib_Debug.lua] ["..attribute.."] = "..tostring(NRD_StatusGetString(obj, handle, attribute)).."")
	elseif attribute_type == "Enum" then
		local val = NRD_StatusGetString(obj, handle, attribute)
		if val == nil then val = NRD_StatusGetInt(obj, handle, attribute) end
		Ext.Print("[LeaderLib_Debug.lua] ["..attribute.."] = "..tostring(val).."")
	elseif attribute_type == "GuidString" or attribute_type == "Handle" then
		Ext.Print("[LeaderLib_Debug.lua] ["..attribute.."] = "..NRD_StatusGetGuidString(obj, handle, attribute).."")
	end
end

function LeaderLib_Ext_Debug_TraceStatus(obj, status, handle)
	Ext.Print("[LeaderLib_Debug.lua:TraceStatus] === "..obj.." || "..status.." ("..tostring(handle)..") === ")
	for attribute,attribute_type in pairs(STATUS_ATTRIBUTE) do
		TraceType(obj, handle, attribute, attribute_type)
	end
	Ext.Print("[LeaderLib_Debug.lua:TraceHit] Trying to get StatusType...")
	local status_type = Ext.StatGetAttribute(status, "StatusType")
	if status_type == "HEAL" then
		Ext.Print("[LeaderLib_Debug.lua:TraceStatus] ===== HEAL TYPE ===== ")
		for attribute,attribute_type in pairs(STATUS_HEAL_ATTRIBUTE) do
			TraceType(obj, handle, attribute, attribute_type)
		end
	elseif status_type == "HEALING" then
		Ext.Print("[LeaderLib_Debug.lua:TraceStatus] ===== HEALING TYPE ===== ")
		for attribute,attribute_type in pairs(STATUS_HEALING_ATTRIBUTE) do
			TraceType(obj, handle, attribute, attribute_type)
		end
	end
end

function LeaderLib_Ext_Debug_TraceHitPrepare(obj, handle)
	Ext.Print("[LeaderLib_Debug.lua:TraceHit] === "..obj.." || HIT ("..tostring(handle)..") === ")
	for attribute,attribute_type in pairs(HIT_ATTRIBUTE) do
		TraceType(obj, handle, attribute, attribute_type)
	end
	for attribute,attribute_type in pairs(STATUS_HIT) do
		TraceType(obj, handle, attribute, attribute_type)
	end
	local status = NRD_StatusGetString(obj, handle, "StatusId")
	if status ~= nil then
		LeaderLib_Ext_Debug_TraceStatus(obj, status, handle)
	end
end

function LeaderLib_Ext_Debug_TraceOnHit(obj, handle)
	Ext.Print("[LeaderLib_Debug.lua:TraceHit] === "..obj.." || HIT ("..tostring(handle)..") === ")
	for attribute,attribute_type in pairs(HIT_ATTRIBUTE) do
		TraceType(obj, handle, attribute, attribute_type)
	end
	for attribute,attribute_type in pairs(STATUS_HIT) do
		TraceType(obj, handle, attribute, attribute_type)
	end
	Ext.Print("[LeaderLib_Debug.lua:TraceHit] Trying to get StatusId...")
	local status = NRD_StatusGetString(obj, handle, "StatusId")
	if status ~= nil then
		LeaderLib_Ext_Debug_TraceStatus(obj, status, handle)
	end
end