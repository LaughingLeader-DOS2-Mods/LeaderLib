local ts = Classes.TranslatedString

local isClient = Ext.IsClient()

---@alias TalentRequirementCheckCallback fun(talentId:string, player:EclCharacter):boolean

---@class TalentManager
SheetManager.TalentManager = {
	RegisteredTalents = {},
	RegisteredCount = {},
	---@type table<string, table<string, TalentRequirementCheckCallback>>
	RequirementHandlers = {},
	---@type table<string, StatRequirement[]>
	BuiltinRequirements = {},
	HiddenTalents = {},
	HiddenCount = {},
	Data = {}
}
SheetManager.TalentManager.__index = SheetManager.TalentManager

SheetManager.TalentManager.Data.TalentState = {
	Selected = 0,
	Selectable = 2,
	Locked = 3
}

SheetManager.TalentManager.Data.TalentStateColor = {
	[2] = "#403625",
	[3] = "#C80030"
}

SheetManager.TalentManager.Data.DOSTalents = {
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
	--WhatARush = "TALENT_WhatARush",
	--FaroutDude = "TALENT_FaroutDude",
	--Leech = "TALENT_Leech",
	--ElementalAffinity = "TALENT_ElementalAffinity",
	--FiveStarRestaurant = "TALENT_FiveStarRestaurant",
	Bully = "TALENT_Bully",
	--ElementalRanger = "TALENT_ElementalRanger",
	LightningRod = "TALENT_LightningRod",
	Politician = "TALENT_Politician",
	WeatherProof = "TALENT_WeatherProof",
	--LoneWolf = "TALENT_LoneWolf",
	--Zombie = "TALENT_Zombie",
	--Demon = "TALENT_Demon",
	--IceKing = "TALENT_IceKing",
	Courageous = "TALENT_Courageous",
	GoldenMage = "TALENT_GoldenMage",
	--WalkItOff = "TALENT_WalkItOff",
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
	--LivingArmor = "TALENT_LivingArmor",
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

SheetManager.TalentManager.Data.RacialTalents = {
	Human_Inventive = "TALENT_Human_Inventive",
	Human_Civil = "TALENT_Human_Civil",
	Elf_Lore = "TALENT_Elf_Lore",
	Elf_CorpseEating = "TALENT_Elf_CorpseEating",
	Dwarf_Sturdy = "TALENT_Dwarf_Sturdy",
	Dwarf_Sneaking = "TALENT_Dwarf_Sneaking",
	Lizard_Resistance = "TALENT_Lizard_Resistance",
	Lizard_Persuasion = "TALENT_Lizard_Persuasion",
	Zombie = "TALENT_Zombie",
}

SheetManager.TalentManager.Data.DivineTalents = {
	--Rager = "TALENT_Rager",
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

SheetManager.TalentManager.Data.TalentStatAttributes = {
	ItemMovement = "TALENT_ItemMovement",
	ItemCreation = "TALENT_ItemCreation",
	Flanking = "TALENT_Flanking",
	AttackOfOpportunity = "TALENT_AttackOfOpportunity",
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
	AnimalEmpathy = "TALENT_AnimalEmpathy",
	Escapist = "TALENT_Escapist",
	StandYourGround = "TALENT_StandYourGround",
	SurpriseAttack = "TALENT_SurpriseAttack",
	LightStep = "TALENT_LightStep",
	ResurrectToFullHealth = "TALENT_ResurrectToFullHealth",
	Scientist = "TALENT_Scientist",
	Raistlin = "TALENT_Raistlin",
	MrKnowItAll = "TALENT_MrKnowItAll",
	WhatARush = "TALENT_WhatARush",
	FaroutDude = "TALENT_FaroutDude",
	Leech = "TALENT_Leech",
	ElementalAffinity = "TALENT_ElementalAffinity",
	FiveStarRestaurant = "TALENT_FiveStarRestaurant",
	Bully = "TALENT_Bully",
	ElementalRanger = "TALENT_ElementalRanger",
	LightningRod = "TALENT_LightningRod",
	Politician = "TALENT_Politician",
	WeatherProof = "TALENT_WeatherProof",
	LoneWolf = "TALENT_LoneWolf",
	Zombie = "TALENT_Zombie",
	Demon = "TALENT_Demon",
	IceKing = "TALENT_IceKing",
	Courageous = "TALENT_Courageous",
	GoldenMage = "TALENT_GoldenMage",
	WalkItOff = "TALENT_WalkItOff",
	FolkDancer = "TALENT_FolkDancer",
	SpillNoBlood = "TALENT_SpillNoBlood",
	Stench = "TALENT_Stench",
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
	DualWieldingDodging = "TALENT_DualWieldingDodging",
	DualWieldingBlock = "TALENT_DualWieldingBlock",
	Human_Inventive = "TALENT_Human_Inventive",
	Human_Civil = "TALENT_Human_Civil",
	Elf_Lore = "TALENT_Elf_Lore",
	Elf_CorpseEating = "TALENT_Elf_CorpseEating",
	Dwarf_Sturdy = "TALENT_Dwarf_Sturdy",
	Dwarf_Sneaking = "TALENT_Dwarf_Sneaking",
	Lizard_Resistance = "TALENT_Lizard_Resistance",
	Lizard_Persuasion = "TALENT_Lizard_Persuasion",
	Perfectionist = "TALENT_Perfectionist",
	Executioner = "TALENT_Executioner",
	ViolentMagic = "TALENT_ViolentMagic",
	QuickStep = "TALENT_QuickStep",
	Quest_SpidersKiss_Str = "TALENT_Quest_SpidersKiss_Str",
	Quest_SpidersKiss_Int = "TALENT_Quest_SpidersKiss_Int",
	Quest_SpidersKiss_Per = "TALENT_Quest_SpidersKiss_Per",
	Quest_SpidersKiss_Null = "TALENT_Quest_SpidersKiss_Null",
	Memory = "TALENT_Memory",
	Quest_TradeSecrets = "TALENT_Quest_TradeSecrets",
	Quest_GhostTree = "TALENT_Quest_GhostTree",
	BeastMaster = "TALENT_BeastMaster",
	LivingArmor = "TALENT_LivingArmor",
	Torturer = "TALENT_Torturer",
	Ambidextrous = "TALENT_Ambidextrous",
	Unstable = "TALENT_Unstable",
	ResurrectExtraHealth = "TALENT_ResurrectExtraHealth",
	NaturalConductor = "TALENT_NaturalConductor",
	Quest_Rooted = "TALENT_Quest_Rooted",
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

SheetManager.TalentManager.Data.DefaultVisible = {
	Ambidextrous = "TALENT_Ambidextrous",
	AnimalEmpathy = "TALENT_AnimalEmpathy",
	AttackOfOpportunity = "TALENT_AttackOfOpportunity",
	Demon = "TALENT_Demon",
	DualWieldingDodging = "TALENT_DualWieldingDodging",
	ElementalAffinity = "TALENT_ElementalAffinity",
	ElementalRanger = "TALENT_ElementalRanger",
	Escapist = "TALENT_Escapist",
	Executioner = "TALENT_Executioner",
	ExtraSkillPoints = "TALENT_ExtraSkillPoints",
	ExtraStatPoints = "TALENT_ExtraStatPoints",
	FaroutDude = "TALENT_FaroutDude",
	FiveStarRestaurant = "TALENT_FiveStarRestaurant",
	IceKing = "TALENT_IceKing",
	Leech = "TALENT_Leech",
	LivingArmor = "TALENT_LivingArmor",
	LoneWolf = "TALENT_LoneWolf",
	Memory = "TALENT_Memory",
	NoAttackOfOpportunity = "TALENT_NoAttackOfOpportunity",
	Perfectionist = "TALENT_Perfectionist",
	QuickStep = "TALENT_QuickStep",
	Raistlin = "TALENT_Raistlin",
	RangerLoreArrowRecover = "TALENT_RangerLoreArrowRecover",
	ResistDead = "TALENT_ResistDead",
	Stench = "TALENT_Stench",
	SurpriseAttack = "TALENT_SurpriseAttack",
	Torturer = "TALENT_Torturer",
	Unstable = "TALENT_Unstable",
	ViolentMagic = "TALENT_ViolentMagic",
	WalkItOff = "TALENT_WalkItOff",
	WarriorLoreGrenadeRange = "TALENT_WarriorLoreGrenadeRange",
	WarriorLoreNaturalHealth = "TALENT_WarriorLoreNaturalHealth",
	WhatARush = "TALENT_WhatARush",
}

for name,v in pairs(SheetManager.TalentManager.Data.DOSTalents) do
	SheetManager.TalentManager.RegisteredCount[name] = 0
end

for talentId,enum in pairs(Data.TalentEnum) do
	SheetManager.TalentManager.HiddenTalents[talentId] = {}
end

---@param talentId string
---@return boolean
function SheetManager.TalentManager.IsRegisteredTalent(talentId)
	return SheetManager.TalentManager.RegisteredCount[talentId] and SheetManager.TalentManager.RegisteredCount[talentId] > 0
end

---@param player EclCharacter|EsvCharacter
---@param talentId string
---@return boolean
function SheetManager.TalentManager.HasTalent(player, talentId)
	local talentIdPrefixed = "TALENT_" .. talentId
	if player ~= nil and player.Stats ~= nil and player.Stats[talentIdPrefixed] == true then
		return true
	end
	return false
end

local function TryRequestRefresh()
	if isClient then
		if Vars.ControllerEnabled then
			GameHelpers.UI.TryInvoke(Data.UIType.characterSheet, "clearTalents")
		else
			GameHelpers.UI.TryInvoke(Data.UIType.statsPanel_c, "clearTalents")
		end
	end
end

--Requires a name and description to be manually set in the tooltip, as well as an icon
local ragerWasEnabled = false

---@param talentId string The talent id, i.e. Executioner
---@param modID string The registering mod's UUID.
---@param getRequirements TalentRequirementCheckCallback|nil A function that gets invoked when looking to see if a player has met the talent's requirements.
function SheetManager.TalentManager.EnableTalent(talentId, modID, getRequirements)
	if talentId == "Rager" then
		ragerWasEnabled = true
	end
	if talentId == "all" then
		for talent,v in pairs(SheetManager.TalentManager.Data.DOSTalents) do
			SheetManager.TalentManager.EnableTalent(talent, modID, getRequirements)
		end
	else
		if SheetManager.TalentManager.RegisteredTalents[talentId] == nil then
			SheetManager.TalentManager.RegisteredTalents[talentId] = {}
		end
		if SheetManager.TalentManager.RegisteredTalents[talentId][modID] ~= true then
			SheetManager.TalentManager.RegisteredTalents[talentId][modID] = true
			SheetManager.TalentManager.RegisteredCount[talentId] = (SheetManager.TalentManager.RegisteredCount[talentId] or 0) + 1
		end
		if getRequirements then
			if not SheetManager.TalentManager.RequirementHandlers[talentId] then
				SheetManager.TalentManager.RequirementHandlers[talentId] = {}
			end
			SheetManager.TalentManager.RequirementHandlers[talentId][modID] = getRequirements
		end
	end
end

---@param talentId string The talent id, i.e. Executioner
---@param modID string The registering mod's UUID.
function SheetManager.TalentManager.DisableTalent(talentId, modID)
	if talentId == "all" then
		for talent,v in pairs(SheetManager.TalentManager.Data.DOSTalents) do
			SheetManager.TalentManager.DisableTalent(talent, modID)
		end
		TryRequestRefresh()
	else
		local data = SheetManager.TalentManager.RegisteredTalents[talentId]
		if data ~= nil then
			if SheetManager.TalentManager.RegisteredTalents[talentId][modID] ~= nil then
				SheetManager.TalentManager.RegisteredTalents[talentId][modID] = nil
				SheetManager.TalentManager.RegisteredCount[talentId] = SheetManager.TalentManager.RegisteredCount[talentId] - 1
			end
			if SheetManager.TalentManager.RegisteredCount[talentId] <= 0 then
				SheetManager.TalentManager.RegisteredTalents[talentId] = nil
				SheetManager.TalentManager.RegisteredCount[talentId] = 0
				TryRequestRefresh()
			end
		end
	end
end

---Hides a talent from the UI, effectively disabling the ability to select it.
---@param talentId string
---@param modID string
function SheetManager.TalentManager.HideTalent(talentId, modID)
	if talentId == "all" then
		for talentId,enum in pairs(Data.TalentEnum) do
			SheetManager.TalentManager.HideTalent(talentId, modID)
		end
		TryRequestRefresh()
	else
		if SheetManager.TalentManager.HiddenTalents[talentId] == nil then
			SheetManager.TalentManager.HiddenTalents[talentId] = {}
		end
		if SheetManager.TalentManager.HiddenTalents[talentId][modID] ~= true then
			SheetManager.TalentManager.HiddenTalents[talentId][modID] = true
			SheetManager.TalentManager.HiddenCount[talentId] = (SheetManager.TalentManager.HiddenCount[talentId] or 0) + 1
			TryRequestRefresh()
		end
	end
end

---Stops hiding a talent from the UI.
---@param talentId string
---@param modID string
function SheetManager.TalentManager.UnhideTalent(talentId, modID)
	if talentId == "all" then
		for _,talent in pairs(Data.Talents) do
			SheetManager.TalentManager.UnhideTalent(talent, modID)
		end
	else
		local count = SheetManager.TalentManager.HiddenCount[talentId] or 0
		local data = SheetManager.TalentManager.HiddenTalents[talentId]
		if data ~= nil then
			if SheetManager.TalentManager.HiddenTalents[talentId][modID] ~= nil then
				SheetManager.TalentManager.HiddenTalents[talentId][modID] = nil
				count = count - 1
			end
		end
		if count <= 0 then
			SheetManager.TalentManager.HiddenTalents[talentId] = nil
			SheetManager.TalentManager.HiddenCount[talentId] = nil
		else
			SheetManager.TalentManager.HiddenCount[talentId] = count
		end
	end
end

---@param player EclCharacter
---@param id string
function SheetManager.TalentManager.HasRequirements(player, id)
	local getRequirementsHandlers = SheetManager.TalentManager.RequirementHandlers[id]
	if getRequirementsHandlers then
		for modid,handler in pairs(getRequirementsHandlers) do
			local b,result = xpcall(handler, debug.traceback, id, player)
			if b then
				if result == false then
					return false
				end
			else
				fprint(LOGLEVEL.ERROR, "[LeaderLib:SheetManager.TalentManager.HasRequirements] Error invoking requirement handler for talent [%s] modid[%s]", id, modid)
				Ext.PrintError(result)
			end
		end
	end
	local builtinRequirements = SheetManager.TalentManager.BuiltinRequirements[id]
	if builtinRequirements and #builtinRequirements > 0 then
		for _,req in pairs(builtinRequirements) do
			local playerValue = player.Stats[req.Requirement]
			local t = type(playerValue)
			if t == "boolean" then
				if req.Not and playerValue then
					return false
				elseif req.Not == false and not playerValue then
					return false
				end
			elseif t == "number" and playerValue < req.Param then
				return false
			end
		end
	end
	return true
end

---@param id string
---@param talentState integer
---@return string,boolean
function SheetManager.TalentManager.GetTalentDisplayName(id, talentState)
	local name = LocalizedText.TalentNames[id]
	if not name or StringHelpers.IsNullOrEmpty(name.Value) then
		name = id
	else
		name = name.Value
	end
	local color = SheetManager.TalentManager.Data.TalentStateColor[talentState]
	if color then
		return string.format("<font color='%s'>%s</font>", color, name)
	end
	return name
end

---@param player EclCharacter
---@param talentId string
---@param hasTalent boolean
---@return SheetManager.TalentManager.Data.TalentState
function SheetManager.TalentManager.GetTalentState(player, talentId, hasTalent)
	if hasTalent == true then 
		return SheetManager.TalentManager.Data.TalentState.Selected
	elseif not SheetManager.TalentManager.HasRequirements(player, talentId) then 
		return SheetManager.TalentManager.Data.TalentState.Locked
	else
		return SheetManager.TalentManager.Data.TalentState.Selectable
	end
end

function SheetManager.TalentManager.TalentIsHidden(talentId)
	local count = SheetManager.TalentManager.HiddenCount[talentId]
	return count and count > 0
end

local function CanDisplayDivineTalent(talentId)
	if not SheetManager.TalentManager.Data.DivineTalents[talentId] then
		return true
	end
	local name = LocalizedText.TalentNames[talentId]
	if not name or StringHelpers.IsNullOrEmpty(name.Value) then
		name = talentId
	else
		name = name.Value
	end
	if string.find(name, "|") then
		return false
	end
	if talentId == "Rager" then
		-- Seems to have no handles for its name/description
		return ragerWasEnabled
	elseif talentId == "Jitterbug" then
		local tooltip = Ext.GetTranslatedString("h758efe2fgb3bag4935g9500g2c789497e87a", "")
		if string.find(tooltip, "|") then
			return false
		end
	end
	return true
end

---@private
function SheetManager.TalentManager.CanAddTalent(talentId, hasTalent)
	local isGM = GameHelpers.Client.IsGameMaster()
	if (SheetManager.TalentManager.TalentIsHidden(talentId) and not isGM) then
		return false
	end
	if hasTalent == true then
		return true
	end
	if SheetManager.TalentManager.RegisteredCount[talentId] and SheetManager.TalentManager.RegisteredCount[talentId] > 0 and CanDisplayDivineTalent(talentId) then
		return true
	end
	if talentId == "RogueLoreDaggerBackStab" 
	and GameSettings.Settings.BackstabSettings.Player.Enabled
	and GameSettings.Settings.BackstabSettings.Player.TalentRequired
	then
		return true
	end
	if SheetManager.TalentManager.Data.DefaultVisible[talentId] then
		return true
	end
	if SheetManager.TalentManager.Data.RacialTalents[talentId] and isGM then
		return true
	end
	return false
end

if Vars.DebugMode then
	if isClient then
		RegisterListener("LuaReset", function()
			if not Vars.ControllerEnabled then

			else
				local ui = Ext.GetUIByType(Data.UIType.statsPanel_c)
				if ui then
					ui:GetRoot().mainpanel_mc.stats_mc.talents_mc.statList.clearElements()
				end
			end
		end)
	end
end

function SheetManager.TalentManager.ToggleDivineTalents(enabled)
	if true then return end
	if enabled then
		for talent,id in pairs(SheetManager.TalentManager.Data.DivineTalents) do
			SheetManager.TalentManager.EnableTalent(talent, ModuleUUID)
		end
	else
		for talent,id in pairs(SheetManager.TalentManager.Data.DivineTalents) do
			SheetManager.TalentManager.DisableTalent(talent, ModuleUUID)
		end
	end
end

local pointRequirement = "(.+) (%d+)"
local talentRequirement = "(%!*)(TALENT_.+)"

local function GetRequirementFromText(text)
	local requirementName,param = string.match(text, pointRequirement)
	if requirementName and param then
		return {
			Requirement = requirementName,
			Param = tonumber(param),
			Not = false
		}
	else
		local notParam,requirementName = string.match(text, talentRequirement)
		if requirementName then
			return {
				Requirement = requirementName,
				Param = "Talent",
				Not = notParam and true or false
			}
		end
	end
	return nil
end

function SheetManager.TalentManager.LoadRequirements()
	for _,uuid in pairs(Ext.GetModLoadOrder()) do
		local modInfo = Ext.GetModInfo(uuid)
		if modInfo and modInfo.Directory then
			local talentRequirementsText = Ext.LoadFile("Public/"..modInfo.Directory.."/Stats/Generated/Data/Requirements.txt", "data")
			if not StringHelpers.IsNullOrEmpty(talentRequirementsText) then
				for line in StringHelpers.GetLines(talentRequirementsText) do
					local talent,requirementText = string.match(line, 'requirement.*"(.+)",.*"(.*)"')
					if talent then
						SheetManager.TalentManager.BuiltinRequirements[talent] = {}
						if requirementText then
							for i,v in pairs(StringHelpers.Split(requirementText, ";")) do
								local req = GetRequirementFromText(v)
								if req then
									table.insert(SheetManager.TalentManager.BuiltinRequirements[talent], req)
								end
							end
						end
					end
				end
			end
		end
	end
end

if isClient then

---@private
function SheetManager.TalentManager.HideTalents(uiType)
	if uiType == Data.UIType.characterSheet or uiType == Data.UIType.statsPanel_c then
		SheetManager.TalentManager.Sheet.HideTalents()
	elseif uiType == Data.UIType.characterCreation or uiType == Data.UIType.characterCreation_c then
		SheetManager.TalentManager.CC.HideTalents()
	end
end

---@class SheetManager.TalentManagerUITalentEntry
---@field ID string
---@field SheetID integer
---@field Enum string
---@field HasTalent boolean
---@field DisplayName string
---@field IsRacial boolean
---@field IsChoosable boolean
---@field IsCustom boolean
---@field State integer

---@private
---@param player EclCharacter
---@return fun():SheetManager.TalentManagerUITalentEntry
function SheetManager.TalentManager.GetVisible(player)
	local talents = {}
	for numId,talentId in Data.Talents:Get() do
		local hasTalent = player.Stats[SheetManager.TalentManager.Data.TalentStatAttributes[talentId]] == true
		if SheetManager.TalentManager.CanAddTalent(talentId, hasTalent) then
			local talentState = SheetManager.TalentManager.GetTalentState(player, talentId, hasTalent)
			local name = SheetManager.TalentManager.GetTalentDisplayName(talentId, talentState)
			local isRacial = SheetManager.TalentManager.Data.RacialTalents[talentId] ~= nil
			local isChoosable = not isRacial and talentState ~= SheetManager.TalentManager.Data.TalentState.Locked
			if hasTalent then 
				fprint(LOGLEVEL.WARNING, "[%s] Name(%s) State(%s) hasTalent(%s) isChoosable(%s) isRacial(%s)", talentId, name, talentState, hasTalent, isChoosable, isRacial)
			end
			---@type SheetManager.TalentManagerUITalentEntry
			local data = {
				ID = talentId,
				SheetID = Data.TalentEnum[talentId],
				Enum = talentId,
				HasTalent = hasTalent,
				DisplayName = name,
				IsRacial = isRacial,
				IsChoosable = isChoosable,
				State = talentState,
				IsCustom = false,
			}
			talents[#talents+1] = data
		end
	end
	local i = 0
	local count = #talents
	return function ()
		i = i + 1
		if i <= count then
			return talents[i]
		end
	end
end

end