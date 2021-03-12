local ts = Classes.TranslatedString

---@alias TalentRequirementCheckCallback fun(talentId:string, player:EclCharacter):boolean

local TalentState = {
	Selected = 0,
	Selectable = 2,
	Locked = 3
}

TalentManager = {
	RegisteredTalents = {},
	RegisteredCount = {},
	---@type table<string, table<string, TalentRequirementCheckCallback>>
	RequirementHandlers = {},
	TalentState = TalentState
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

for name,v in pairs(missingTalents) do
	if not Vars.DebugMode then
		TalentManager.RegisteredCount[name] = 0
	else
		TalentManager.RegisteredCount[name] = 1
	end
end

---@param talentId string
---@return boolean
function TalentManager.IsRegisteredTalent(talentId)
	return TalentManager.RegisteredCount[talentId] and TalentManager.RegisteredCount[talentId] > 0
end

---@param player EclCharacter
---@param talentId string
---@return boolean
function TalentManager.HasTalent(player, talentId)
	local talentNamePrefixed = "TALENT_" .. talentId
	if player ~= nil and player.Stats ~= nil and player.Stats[talentNamePrefixed] == true then
		return true
	end
	return false
end

---@param talentId string The talent id, i.e. Executioner
---@param modID string The registering mod's UUID.
---@param getRequirements TalentRequirementCheckCallback|nil A function that gets invoked when looking to see if a player has met the talent's requirements.
function TalentManager.EnableTalent(talentId, modID, getRequirements)
	if talentId == "all" then
		for talent,v in pairs(missingTalents) do
			TalentManager.EnableTalent(talent, modID, getRequirements)
		end
	else
		if TalentManager.RegisteredTalents[talentId] == nil then
			TalentManager.RegisteredTalents[talentId] = {}
		end
		if TalentManager.RegisteredTalents[talentId][modID] ~= true then
			TalentManager.RegisteredTalents[talentId][modID] = true
			TalentManager.RegisteredCount[talentId] = (TalentManager.RegisteredCount[talentId] or 0) + 1
		end
		if getRequirements then
			if not TalentManager.RequirementHandlers[talentId] then
				TalentManager.RequirementHandlers[talentId] = {}
			end
			TalentManager.RequirementHandlers[talentId][modID] = getRequirements
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

function TalentManager.HasRequirements(player, id)
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

local TalentFontColor =
{
	Selectable = "#403625",
	Locked = "#C80030"
}

---@param player EclCharacter
---@param id string
---@return string,boolean
function TalentManager.GetTalentDisplayName(player, id, talentState)
	local name = LocalizedText.TalentNames[id]
	if not name or StringHelpers.IsNullOrEmpty(name.Value) then
		name = id
	else
		name = name.Value
	end
	if talentState == TalentState.Selectable then
		--name = string.format("<font color='%s'>%s</font>", TalentFontColor.Selectable, name)
	elseif talentState == TalentState.Locked then
		name = string.format("<font color='%s'>%s</font>", TalentFontColor.Locked, name)
	end
	return name
end

---@param player EclCharacter
---@param talentId string
---@return TalentState
function TalentManager.GetTalentState(player, talentId)
	if player.Stats["TALENT_" .. talentId] then 
		return TalentState.Selected
	elseif not TalentManager.HasRequirements(player, talentId) then 
		return TalentState.Locked
	else
		 return TalentState.Selectable
	end
end

---@class TalentMC_CC
---@field addTalentElement fun(id:int, name:string, isActive:boolean, isChooseable:boolean, isRacial:boolean):void 

---@param talent_mc TalentMC_CC
function TalentManager.Update_CC(ui, talent_mc, player)
	for talentId,talentStat in pairs(missingTalents) do
		--Same setup for CC in controller mode as well
		if TalentManager.RegisteredCount[talentId] > 0 then
			local talentEnum = Data.TalentEnum[talentId]
			if not UI.IsInArray(ui, "talentArray", talentId, 1, 4) then
				local talentState = TalentManager.GetTalentState(player, talentId)
				local name,requirementsMet = TalentManager.GetTalentDisplayName(player, talentId, talentState)
				talent_mc.addTalentElement(talentEnum, name, player.Stats[talentStat], requirementsMet, false)
				if Vars.ControllerEnabled then
					TalentManager.Gamepad.UpdateTalent_CC(ui, player, talentId, alentEnum)
				end
			end
		end
	end
end

RegisterListener("LuaReset", function()
	local ui = Ext.GetUIByType(Data.UIType.statsPanel_c)
	if ui then
		ui:GetRoot().mainpanel_mc.stats_mc.talents_mc.statList.clearElements()
	end
end)

function TalentManager.TalentIsInArray(talentEnum, talent_array)
	if not Vars.ControllerEnabled then
		for i=1,#talent_array,3 do
			local tEnum = talent_array[i]
			if tEnum == talentEnum then
				return true
			end
		end
	else
		for i=0,#talent_array,3 do
			local tEnum = talent_array[i]
			if tEnum == talentEnum then
				return true
			end
		end
	end

	return false
end

---@param ui UIObject
function TalentManager.Update(ui, player)
	local main = ui:GetRoot()
	local lvlBtnTalent_array = main.lvlBtnTalent_array
	local talent_array = main.talent_array

	if Vars.ControllerEnabled then
		TalentManager.Gamepad.PreUpdate(ui, main)
	end

	local i = #talent_array

	for talentId,talentStat in pairs(missingTalents) do
		if TalentManager.RegisteredCount[talentId] > 0 then
			local talentEnum = Data.TalentEnum[talentId]
			if not TalentManager.TalentIsInArray(talentEnum, talent_array) then
				local talentState = TalentManager.GetTalentState(player, talentId)
				local name,requirementsMet = TalentManager.GetTalentDisplayName(player, talentId, talentState)
				if not Vars.ControllerEnabled then
					--addTalent(displayName:String, id:Number, talentState:Number)
					talent_array[i] = name
					talent_array[i+1] = talentEnum
				else
					--addTalent(id:Number, displayName:String, talentState:Number)
					talent_array[i] = talentEnum
					talent_array[i+1] = name
				end
				talent_array[i+2] = talentState
				i = i + 3

				if Vars.ControllerEnabled then
					TalentManager.Gamepad.UpdateTalent(ui, player, talentId, talentEnum, lvlBtnTalent_array, talentState)
				end
			end
		end
	end
	-- if Vars.DebugMode then
	-- 	print("lvlBtnTalent_array")
	-- 	for i=0,#lvlBtnTalent_array,3 do
	-- 		local canChoose = lvlBtnTalent_array[i]
	-- 		if canChoose ~= nil then
	-- 			local talentID = lvlBtnTalent_array[i+1]
	-- 			local isRacial = lvlBtnTalent_array[i+2]
	-- 			local displayName = LocalizedText.TalentNames[Data.Talents[talentID]]
	-- 			if displayName then
	-- 				displayName = displayName.Value
	-- 			else
	-- 				displayName = talentID
	-- 			end
	-- 			print(string.format("[%s] %s", i, canChoose))
	-- 			print(string.format("[%s] %s (%s,%s)", i+1, talentID, Data.Talents[talentID], displayName))
	-- 			print(string.format("[%s] %s", i+2, isRacial))
	-- 		end
	-- 	end
	-- end
end