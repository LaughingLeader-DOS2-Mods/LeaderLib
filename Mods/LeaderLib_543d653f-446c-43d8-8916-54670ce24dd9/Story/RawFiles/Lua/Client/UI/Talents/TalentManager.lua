local ts = Classes.TranslatedString

---@alias TalentRequirementCheckCallback fun(talentId:string, player:EclCharacter):boolean

local TalentState = {
	Selected = 0,
	Selectable = 2,
	Locked = 3
}

local TalentStateFormat = {
	[TalentState.Selected] = "%s",
	[TalentState.Selectable] = "<font color='#403625'>%s</font>",
	[TalentState.Locked] = "<font color='#C80030'>%s</font>"
}

TalentManager = {
	RegisteredTalents = {},
	RegisteredCount = {},
	---@type table<string, table<string, TalentRequirementCheckCallback>>
	RequirementHandlers = {},
	TalentState = TalentState,
	---@type table<string, StatRequirement[]>
	BuiltinRequirements = {}
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

local racialTalents = {
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

for name,v in pairs(missingTalents) do
	TalentManager.RegisteredCount[name] = 0
	-- if Vars.DebugMode then
	-- 	TalentManager.RegisteredCount[name] = 1
	-- end
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

---@param player EclCharacter
---@param id string
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
				fprint(LOGLEVEL.ERROR, "[LeaderLib:TalentManager.HasRequirements] Error invoking requirement handler for talent [%s] modid[%s]", id, modid)
				Ext.PrintError(result)
			end
		end
	end
	local builtinRequirements = TalentManager.BuiltinRequirements[id]
	if builtinRequirements and #builtinRequirements > 0 then
		for _,req in pairs(builtinRequirements) do
			local playerValue = player.Stats[req.Requirement]
			local t = type(playerValue)
			if t == "boolean" then
				if req.Not ~= playerValue then
					return false
				end
			elseif t == "number" and playerValue < req.Param then
				return false
			end
		end
	end
	return true
end

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
	return string.format(TalentStateFormat[talentState], name)
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
				local name = TalentManager.GetTalentDisplayName(player, talentId, talentState)
				talent_mc.addTalentElement(talentEnum, name, player.Stats[talentStat], talentState ~= TalentState.Locked, false)
				if Vars.ControllerEnabled then
					TalentManager.Gamepad.UpdateTalent_CC(ui, player, talentId, talentEnum)
				end
			end
		end
	end
	if Features.RacialTalentsDisplayFix then
		for talentId,talentStat in pairs(racialTalents) do
			local talentEnum = Data.TalentEnum[talentId]
			if not UI.IsInArray(ui, "talentArray", talentId, 1, 4) then
				local talentState = TalentManager.GetTalentState(player, talentId)
				local name = TalentManager.GetTalentDisplayName(player, talentId, talentState)
				talent_mc.addTalentElement(talentEnum, name, player.Stats[talentStat], talentState ~= TalentState.Locked, true)
				if Vars.ControllerEnabled then
					TalentManager.Gamepad.UpdateTalent_CC(ui, player, talentId, talentEnum)
				end
			end
		end
	end

	if player.Stats.TALENT_RogueLoreDaggerBackStab or 
	(GameSettings.Settings.BackstabSettings.Player.Enabled and GameSettings.Settings.BackstabSettings.Player.TalentRequired) then
		local talentEnum = Data.TalentEnum["RogueLoreDaggerBackStab"]
		if not UI.IsInArray(ui, "talentArray", "RogueLoreDaggerBackStab", 1, 4) then
			local talentState = TalentManager.GetTalentState(player, "RogueLoreDaggerBackStab")
			local name = TalentManager.GetTalentDisplayName(player, "RogueLoreDaggerBackStab", talentState)
			talent_mc.addTalentElement(talentEnum, name, player.Stats.TALENT_RogueLoreDaggerBackStab, talentState ~= TalentState.Locked, false)
			if Vars.ControllerEnabled then
				TalentManager.Gamepad.UpdateTalent_CC(ui, player, "RogueLoreDaggerBackStab", talentEnum)
			end
		end
	end
end

local function AddTalentToArray(ui, player, talent_array, talentId, lvlBtnTalent_array, i)
	local talentEnum = Data.TalentEnum[talentId]
	if not TalentManager.TalentIsInArray(talentEnum, talent_array) then
		local talentState = TalentManager.GetTalentState(player, talentId)
		local name = TalentManager.GetTalentDisplayName(player, talentId, talentState)
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
	return i
end

---@param ui UIObject
---@param player EclCharacter
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
			i = AddTalentToArray(ui, player, talent_array, talentId, lvlBtnTalent_array, i)
		end
	end

	if Features.RacialTalentsDisplayFix then
		i = #talent_array
		for talentId,talentStat in pairs(racialTalents) do
			if player.Stats[talentStat] == true then
				i = AddTalentToArray(ui, player, talent_array, talentId, lvlBtnTalent_array, i, true)
			end
		end
	end

	if player.Stats.TALENT_RogueLoreDaggerBackStab or 
	(GameSettings.Settings.BackstabSettings.Player.Enabled and GameSettings.Settings.BackstabSettings.Player.TalentRequired) then
		i = #talent_array
		AddTalentToArray(ui, player, talent_array, "RogueLoreDaggerBackStab", lvlBtnTalent_array, i)
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

RegisterListener("LuaReset", function()
	local ui = Ext.GetUIByType(Data.UIType.statsPanel_c)
	if ui then
		ui:GetRoot().mainpanel_mc.stats_mc.talents_mc.statList.clearElements()
	end
end)

local DivineTalents = {
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

function TalentManager.ToggleDivineTalents(enabled)
	if enabled then
		for talent,id in pairs(DivineTalents) do
			TalentManager.EnableTalent(talent, "DivineTalents")
		end
	else
		for talent,id in pairs(DivineTalents) do
			TalentManager.DisableTalent(talent, "DivineTalents")
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

function TalentManager.LoadRequirements()
	for _,uuid in pairs(Ext.GetModLoadOrder()) do
		local modInfo = Ext.GetModInfo(uuid)
		if modInfo and modInfo.Directory then
			local talentRequirementsText = Ext.LoadFile("Public/"..modInfo.Directory.."/Stats/Generated/Data/Requirements.txt", "data")
			if not StringHelpers.IsNullOrEmpty(talentRequirementsText) then
				for line in StringHelpers.GetLines(talentRequirementsText) do
					local talent,requirementText = string.match(line, 'requirement.*"(.+)",.*"(.*)"')
					if talent then
						TalentManager.BuiltinRequirements[talent] = {}
						if requirementText then
							for i,v in pairs(StringHelpers.Split(requirementText, ";")) do
								local req = GetRequirementFromText(v)
								if req then
									table.insert(TalentManager.BuiltinRequirements[talent], req)
								end
							end
						end
					end
				end
			end
		end
	end
end

Ext.RegisterListener("SessionLoaded", function()
	TalentManager.LoadRequirements()
	---Divine Talents
	if Ext.IsModLoaded("ca32a698-d63e-4d20-92a7-dd83cba7bc56") or GameSettings.Settings.Client.DivineTalentsEnabled then
		TalentManager.ToggleDivineTalents(true)
	end
end)