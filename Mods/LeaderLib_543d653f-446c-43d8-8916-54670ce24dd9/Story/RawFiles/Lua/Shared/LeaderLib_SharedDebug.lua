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
}

local function TraceType(character, attribute, attribute_type)
	if attribute_type == "Integer" or attribute_type == "Flag" or attribute_type == "Integer64" or attribute_type == "Enum" then
		Ext.Print("[LeaderLib_SharedDebug.lua:TraceCharacter] ["..attribute.."] = "..tostring(character[attribute]).."")
	elseif attribute_type == "Real" then
		Ext.Print("[LeaderLib_SharedDebug.lua:TraceCharacter] ["..attribute.."] = "..tostring(character[attribute]).."")
	elseif attribute_type == "String" then
		Ext.Print("[LeaderLib_SharedDebug.lua:TraceCharacter] ["..attribute.."] = "..tostring(character[attribute]).."")
	else
		Ext.Print("[LeaderLib_SharedDebug.lua:TraceCharacter] ["..attribute.."] = "..tostring(character[attribute]).."")
	end
end

function LeaderLib_Ext_Debug_TraceCharacter(character)
	if type(character) == "string" then
		character = Ext.GetCharacter(character)
	end

	if character.MyGuid ~= nil then
		for attribute,attribute_type in pairs(CHARACTER_PARAMS) do
			TraceType(character, attribute, attribute_type)
		end
	end

	local characterStats = nil
	if character.Stats ~= nil then
		characterStats = character.Stats
	elseif character.MyGuid == nil then
		characterStats = character
	end

	if characterStats ~= nil then
		for attribute,attribute_type in pairs(CHARACTER_STATS_PARAMS) do
			TraceType(character, attribute, attribute_type)
		end
	end
end