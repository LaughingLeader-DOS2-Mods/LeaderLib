local CHARACTER_PARAMS = {
	NetID = "String",
	MyGuid = "String",
	WorldPos = "Vector3",
	CurrentLevel = "String",
	Scale = "Integer",
	AnimationOverride = "Integer",
	WalkSpeedOverride = "Integer",
	NeedsUpdateCount = "Integer",
	ScriptForceUpdateCount = "Integer",
	ForceSynchCount = "Integer",
	InventoryHandle = "Integer",
	SkillBeingPrepared = "String",
	LifeTime = "Float",
	OwnerHandle = "Handle",
	PartialAP = "Integer",
	AnimType = "String",
	DelayDeathCount = "Integer",
	AnimationSetOverride = "String",
	CustomTradeTreasure = "String",
	Archetype = "String",
	EquipmentColor = "Integer",
	Stats = "Table",
}

local CHARACTER_STATS_PARAMS = {
	Level = "Integer",
	Name = "String",
	AIFlags = "Integer",
	InstanceId = "String",
	CurrentVitality = "Integer",
	CurrentArmor = "Integer",
	CurrentMagicArmor = "Integer",
	ArmorAfterHitCooldownMultiplier = "Integer",
	MagicArmorAfterHitCooldownMultiplier = "Integer",
	MPStart = "Integer",
	CurrentAP = "Integer",
	BonusActionPoints = "Integer",
	Experience = "Integer",
	Reputation = "Integer",
	Flanked = "Integer",
	Karma = "Integer",
	MaxResistance = "Integer",
	HasTwoHandedWeapon = "Integer",
	IsIncapacitatedRefCount = "Integer",
	MaxVitality = "Integer",
	BaseMaxVitality = "Integer",
	MaxArmor = "Integer",
	BaseMaxArmor = "Integer",
	MaxMagicArmor = "Integer",
	BaseMaxMagicArmor = "Integer",
	Sight = "Integer",
	BaseSight = "Integer",
	MaxSummons = "Integer",
	BaseMaxSummons = "Integer",
	MaxMpOverride = "Integer",
	Rotation = "table",
	Position = "table",
	MyGuid = "Integer",
	NetID = "Integer",
}

local function TraceType(character, attribute, attribute_type)
	if attribute_type == "Integer" or attribute_type == "Flag" or attribute_type == "Integer64" or attribute_type == "Enum" then
		fprint(LOGLEVEL.TRACE, "[LeaderLib_SharedDebug.lua:TraceCharacter] ["..attribute.."] = "..tostring(character[attribute]).."")
	elseif attribute_type == "Real" then
		fprint(LOGLEVEL.TRACE, "[LeaderLib_SharedDebug.lua:TraceCharacter] ["..attribute.."] = "..tostring(character[attribute]).."")
	elseif attribute_type == "String" then
		fprint(LOGLEVEL.TRACE, "[LeaderLib_SharedDebug.lua:TraceCharacter] ["..attribute.."] = "..tostring(character[attribute]).."")
	elseif attribute_type == "table" then
		fprint(LOGLEVEL.TRACE, "[LeaderLib_SharedDebug.lua:TraceCharacter] ["..attribute.."] = "..Common.Dump(character[attribute]).."")
	else
		fprint(LOGLEVEL.TRACE, "[LeaderLib_SharedDebug.lua:TraceCharacter] ["..attribute.."] = "..tostring(character[attribute]).."")
	end
end

function Debug_TraceCharacter(character)
	if character == nil then
		return
	end
	if type(character) == "string" then
		character = GameHelpers.GetCharacter(character)
	end

	local characterObject = nil
	local characterStats = nil

	if character.Level ~= nil then
		characterStats = character
		if character.Character ~= nil then
			characterObject = character.Character
		end
	else
		characterObject = character
		if character.Stats ~= nil then
			characterStats = character.Stats
		end
	end

	fprint(LOGLEVEL.TRACE, "=======================")
	fprint(LOGLEVEL.TRACE, "===TRACING: "..tostring(characterObject.MyGuid).."====")
	fprint(LOGLEVEL.TRACE, "=======================")
	if characterObject ~= nil then
		fprint(LOGLEVEL.TRACE, "=======================")
		fprint(LOGLEVEL.TRACE, "===Character Params====")
		fprint(LOGLEVEL.TRACE, "=======================")
		for attribute,attribute_type in pairs(CHARACTER_PARAMS) do
			TraceType(characterObject, attribute, attribute_type)
		end
		fprint(LOGLEVEL.TRACE, "=======================")
	end
	if characterStats ~= nil then
		fprint(LOGLEVEL.TRACE, "=======================")
		fprint(LOGLEVEL.TRACE, "====Character Stats====")
		fprint(LOGLEVEL.TRACE, "=======================")
		for attribute,attribute_type in pairs(CHARACTER_STATS_PARAMS) do
			TraceType(characterStats, attribute, attribute_type)
		end
		fprint(LOGLEVEL.TRACE, "=======================")
	end
end

local SKILLPROTOTYPE_PARAMS = {
	SkillId = "String",
	PrepareAnimationInit = "String",
	PrepareAnimationLoop = "String",
	IsFinished = "String",
	IsEntered = "String",
}