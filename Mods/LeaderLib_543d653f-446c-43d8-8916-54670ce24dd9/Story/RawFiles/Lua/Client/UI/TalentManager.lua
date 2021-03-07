local ts = Classes.TranslatedString

---@alias TalentRequirementCheckCallback fun(talentid:string, player:EclCharacter):boolean

TalentManager = {
	RegisteredTalents = {},
	RegisteredCount = {},
	---@type table<string, table<string, TalentRequirementCheckCallback>>
	RequirementHandlers = {}
}
TalentManager.__index = TalentManager

local missingTalents = {
	ItemMovement = "TALENT_ItemMovement",
	ItemCreation = "TALENT_ItemCreation",
	--Flanking = "TALENT_Flanking",
	--AttackOfOpportunity = "TALENT_AttackOfOpportunity",
	Backstab = "TALENT_Backstab",
	Trade = "TALENT_Trade",
	Lockpick = "TALENT_Lockpick",
	ChanceToHitRanged = "TALENT_ChanceToHitRanged",
	ChanceToHitMelee = "TALENT_ChanceToHitMelee",
	Damage = "TALENT_Damage",
	ActionPoints = "TALENT_ActionPoints",
	ActionPoints2 = "TALENT_ActionPoints2",
	Criticals = "TALENT_Criticals",
	IncreasedArmor = "TALENT_IncreasedArmor",
	Sight = "TALENT_Sight",
	ResistFear = "TALENT_ResistFear",
	ResistKnockdown = "TALENT_ResistKnockdown",
	ResistStun = "TALENT_ResistStun",
	ResistPoison = "TALENT_ResistPoison",
	ResistSilence = "TALENT_ResistSilence",
	ResistDead = "TALENT_ResistDead",
	Carry = "TALENT_Carry",
	Throwing = "TALENT_Throwing",
	Repair = "TALENT_Repair",
	ExpGain = "TALENT_ExpGain",
	ExtraStatPoints = "TALENT_ExtraStatPoints",
	ExtraSkillPoints = "TALENT_ExtraSkillPoints",
	Durability = "TALENT_Durability",
	Awareness = "TALENT_Awareness",
	Vitality = "TALENT_Vitality",
	FireSpells = "TALENT_FireSpells",
	WaterSpells = "TALENT_WaterSpells",
	AirSpells = "TALENT_AirSpells",
	EarthSpells = "TALENT_EarthSpells",
	Charm = "TALENT_Charm",
	Intimidate = "TALENT_Intimidate",
	Reason = "TALENT_Reason",
	Luck = "TALENT_Luck",
	Initiative = "TALENT_Initiative",
	InventoryAccess = "TALENT_InventoryAccess",
	AvoidDetection = "TALENT_AvoidDetection",
	--AnimalEmpathy = "TALENT_AnimalEmpathy",
	--Escapist = "TALENT_Escapist",
	StandYourGround = "TALENT_StandYourGround",
	--SurpriseAttack = "TALENT_SurpriseAttack",
	LightStep = "TALENT_LightStep",
	ResurrectToFullHealth = "TALENT_ResurrectToFullHealth",
	Scientist = "TALENT_Scientist",
	--Raistlin = "TALENT_Raistlin",
	MrKnowItAll = "TALENT_MrKnowItAll",
	WhatARush = "TALENT_WhatARush",
	FaroutDude = "TALENT_FaroutDude",
	--Leech = "TALENT_Leech",
	--ElementalAffinity = "TALENT_ElementalAffinity",
	--FiveStarRestaurant = "TALENT_FiveStarRestaurant",
	Bully = "TALENT_Bully",
	ElementalRanger = "TALENT_ElementalRanger",
	LightningRod = "TALENT_LightningRod",
	Politician = "TALENT_Politician",
	WeatherProof = "TALENT_WeatherProof",
	--LoneWolf = "TALENT_LoneWolf",
	--Zombie = "TALENT_Zombie",
	--Demon = "TALENT_Demon",
	--IceKing = "TALENT_IceKing",
	Courageous = "TALENT_Courageous",
	GoldenMage = "TALENT_GoldenMage",
	WalkItOff = "TALENT_WalkItOff",
	FolkDancer = "TALENT_FolkDancer",
	SpillNoBlood = "TALENT_SpillNoBlood",
	--Stench = "TALENT_Stench",
	Kickstarter = "TALENT_Kickstarter",
	WarriorLoreNaturalArmor = "TALENT_WarriorLoreNaturalArmor",
	WarriorLoreNaturalHealth = "TALENT_WarriorLoreNaturalHealth",
	WarriorLoreNaturalResistance = "TALENT_WarriorLoreNaturalResistance",
	RangerLoreArrowRecover = "TALENT_RangerLoreArrowRecover",
	RangerLoreEvasionBonus = "TALENT_RangerLoreEvasionBonus",
	RangerLoreRangedAPBonus = "TALENT_RangerLoreRangedAPBonus",
	RogueLoreDaggerAPBonus = "TALENT_RogueLoreDaggerAPBonus",
	RogueLoreDaggerBackStab = "TALENT_RogueLoreDaggerBackStab",
	RogueLoreMovementBonus = "TALENT_RogueLoreMovementBonus",
	RogueLoreHoldResistance = "TALENT_RogueLoreHoldResistance",
	NoAttackOfOpportunity = "TALENT_NoAttackOfOpportunity",
	WarriorLoreGrenadeRange = "TALENT_WarriorLoreGrenadeRange",
	RogueLoreGrenadePrecision = "TALENT_RogueLoreGrenadePrecision",
	WandCharge = "TALENT_WandCharge",
	--DualWieldingDodging = "TALENT_DualWieldingDodging",
	--DualWieldingBlock = "TALENT_DualWieldingBlock",
	--Human_Inventive = "TALENT_Human_Inventive",
	--Human_Civil = "TALENT_Human_Civil",
	--Elf_Lore = "TALENT_Elf_Lore",
	--Elf_CorpseEating = "TALENT_Elf_CorpseEating",
	--Dwarf_Sturdy = "TALENT_Dwarf_Sturdy",
	--Dwarf_Sneaking = "TALENT_Dwarf_Sneaking",
	--Lizard_Resistance = "TALENT_Lizard_Resistance",
	--Lizard_Persuasion = "TALENT_Lizard_Persuasion",
	Perfectionist = "TALENT_Perfectionist",
	--Executioner = "TALENT_Executioner",
	--ViolentMagic = "TALENT_ViolentMagic",
	--QuickStep = "TALENT_QuickStep",
	--Quest_SpidersKiss_Str = "TALENT_Quest_SpidersKiss_Str",
	--Quest_SpidersKiss_Int = "TALENT_Quest_SpidersKiss_Int",
	--Quest_SpidersKiss_Per = "TALENT_Quest_SpidersKiss_Per",
	--Quest_SpidersKiss_Null = "TALENT_Quest_SpidersKiss_Null",
	--Memory = "TALENT_Memory",
	--Quest_TradeSecrets = "TALENT_Quest_TradeSecrets",
	--Quest_GhostTree = "TALENT_Quest_GhostTree",
	BeastMaster = "TALENT_BeastMaster",
	LivingArmor = "TALENT_LivingArmor",
	--Torturer = "TALENT_Torturer",
	--Ambidextrous = "TALENT_Ambidextrous",
	--Unstable = "TALENT_Unstable",
	ResurrectExtraHealth = "TALENT_ResurrectExtraHealth",
	NaturalConductor = "TALENT_NaturalConductor",
	--Quest_Rooted = "TALENT_Quest_Rooted",
	PainDrinker = "TALENT_PainDrinker",
	DeathfogResistant = "TALENT_DeathfogResistant",
	Sourcerer = "TALENT_Sourcerer",
	-- Divine Talents
	Rager = "TALENT_Rager",
	Elementalist = "TALENT_Elementalist",
	Sadist = "TALENT_Sadist",
	Haymaker = "TALENT_Haymaker",
	Gladiator = "TALENT_Gladiator",
	Indomitable = "TALENT_Indomitable",
	WildMag = "TALENT_WildMag",
	Jitterbug = "TALENT_Jitterbug",
	Soulcatcher = "TALENT_Soulcatcher",
	MasterThief = "TALENT_MasterThief",
	GreedyVessel = "TALENT_GreedyVessel",
	MagicCycles = "TALENT_MagicCycles",
}

for name,v in pairs(missingTalents) do
	TalentManager.RegisteredCount[name] = 1
end

---@param talentid string The talent id, i.e. Executioner
---@param modID string The registering mod's UUID.
---@param getRequirements TalentRequirementCheckCallback|nil A function that gets invoked when looking to see if a player has met the talent's requirements.
function TalentManager.EnableTalent(talentid, modID, getRequirements)
	if talentid == "all" then
		for talent,v in pairs(missingTalents) do
			TalentManager.EnableTalent(talent, modID, getRequirements)
		end
	else
		if TalentManager.RegisteredTalents[talentid] == nil then
			TalentManager.RegisteredTalents[talentid] = {}
		end
		if TalentManager.RegisteredTalents[talentid][modID] ~= true then
			TalentManager.RegisteredTalents[talentid][modID] = true
			TalentManager.RegisteredCount[talentid] = (TalentManager.RegisteredCount[talentid] or 0) + 1
		end
		if getRequirements then
			if not TalentManager.RequirementHandlers[talentid] then
				TalentManager.RequirementHandlers[talentid] = {}
			end
			TalentManager.RequirementHandlers[talentid][modID] = getRequirements
		end
	end
end

-- if Vars.DebugMode then
-- 	for k,v in pairs(missingTalents) do
-- 		TalentManager.EnableTalent(k, "7e737d2f-31d2-4751-963f-be6ccc59cd0c")
-- 	end
-- end

function TalentManager.DisableTalent(talentName, modID)
	if talentName == "all" then
		for talent,v in pairs(missingTalents) do
			TalentManager.DisableTalent(talent, modID)
		end
	else
		local data = TalentManager.RegisteredTalents[talentName]
		if data ~= nil then
			if TalentManager.RegisteredTalents[talentName][modID] ~= nil then
				TalentManager.RegisteredTalents[talentName][modID] = nil
				TalentManager.RegisteredCount[talentName] = TalentManager.RegisteredCount[talentName] - 1
			end
			if TalentManager.RegisteredCount[talentName] <= 0 then
				TalentManager.RegisteredTalents[talentName] = nil
				TalentManager.RegisteredCount[talentName] = 0
			end
		end
	end
end

local function GetArrayIndexStart(ui, arrayName, offset)
	local i = 0
	while i < 9999 do
		local val = ui:GetValue(arrayName, "number", i)
		if val == nil then
			val = ui:GetValue(arrayName, "string", i)
			if val == nil then
				val = ui:GetValue(arrayName, "boolean", i)
			end
		end
		if val == nil then
			return i
		end
		i = i + offset
	end
	return -1
end

local function IsInArray(ui, arrayName, id, start, offset)
	local i = start
	while i < 200 do
		local check = ui:GetValue(arrayName,"number", i)
		if check ~= nil and math.tointeger(check) == id then
			return true
		end
		i = i + offset
	end
	return false
end

function TalentManager.HasRequirements(id, player)
	local getRequirementsHandlers = TalentManager.RequirementHandlers[id]
	if getRequirementsHandlers then
		for modid,handler in pairs(getRequirementsHandlers) do
			local b,result = xpcall(handler, debug.traceback, id, player)
			if b then
				if result == false then
					return false
				end
			else
				Ext.PrintError(string.format("[LeaderLib:TalentManager.HasRequirements] Error invoking requirement handler for talent [%s] modid[%s]", id, modid))
			end
		end
	end
	return true
end

---@param id string
---@param player EclCharacter
---@return string,boolean
function TalentManager.GetTalentName(id, player)
	local requirementsMet = TalentManager.HasRequirements(id, player)
	local name = LocalizedText.TalentNames[id]
	if not name or StringHelpers.IsNullOrEmpty(name.Value) then
		name = id
	else
		name = name.Value
	end
	if not requirementsMet then
		name = string.format("<font color='#C80030'>%s</font>", name)
	end
	return name,requirementsMet
end

function TalentManager.Update_CC(ui, talent_mc, player)
	for talentEnumName,talentStat in pairs(missingTalents) do
		if TalentManager.RegisteredCount[talentEnumName] > 0 then
			local talentid = Data.TalentEnum[talentEnumName]
			if not IsInArray(ui, "talentArray", talentid, 1, 4) then
				local name,requirementsMet = TalentManager.GetTalentName(talentEnumName, player)
				talent_mc.addTalentElement(talentid, name, player.Stats[talentStat], requirementsMet, false)
			end
		end
	end
end

function TalentManager.Update(ui, player)
	for talentEnumName,talentStat in pairs(missingTalents) do
		if TalentManager.RegisteredCount[talentEnumName] > 0 then
			local talentid = Data.TalentEnum[talentEnumName]
			if not IsInArray(ui, "talent_array", talentid, 1, 3) then
				local i = GetArrayIndexStart(ui, "talent_array", 3)
				local name,requirementsMet = TalentManager.GetTalentName(talentEnumName, player)
				ui:SetValue("talent_array", name, i)
				ui:SetValue("talent_array", talentid, i+1)
				if player.Stats[talentStat] == true then
					ui:SetValue("talent_array", 0, i+2)
				else
					if requirementsMet then
						ui:SetValue("talent_array", 2, i+2)
					else
						ui:SetValue("talent_array", 3, i+2)
					end
				end
			end
		end
	end
end