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
	BuiltinRequirements = {},
	HiddenTalents = {},
	HiddenCount = {}
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

for talentId,enum in pairs(Data.TalentEnum) do
	TalentManager.HiddenTalents[talentId] = {}
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
	local talentIdPrefixed = "TALENT_" .. talentId
	if player ~= nil and player.Stats ~= nil and player.Stats[talentIdPrefixed] == true then
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

function TalentManager.DisableTalent(talentId, modID)
	if talentId == "all" then
		for talent,v in pairs(missingTalents) do
			TalentManager.DisableTalent(talent, modID)
		end
		GameHelpers.UI.TryInvoke(Data.UIType.characterSheet, "clearTalents")
	else
		local data = TalentManager.RegisteredTalents[talentId]
		if data ~= nil then
			if TalentManager.RegisteredTalents[talentId][modID] ~= nil then
				TalentManager.RegisteredTalents[talentId][modID] = nil
				TalentManager.RegisteredCount[talentId] = TalentManager.RegisteredCount[talentId] - 1
			end
			if TalentManager.RegisteredCount[talentId] <= 0 then
				TalentManager.RegisteredTalents[talentId] = nil
				TalentManager.RegisteredCount[talentId] = 0
				GameHelpers.UI.TryInvoke(Data.UIType.characterSheet, "clearTalents")
			end
		end
	end
end

---Hides a talent from the UI, effectively disabling the ability to select it.
---@param talentId string
---@param modID string
function TalentManager.HideTalent(talentId, modID)
	if talentId == "all" then
		for talentId,enum in pairs(Data.TalentEnum) do
			TalentManager.HideTalent(talentId, modID)
		end
		GameHelpers.UI.TryInvoke(Data.UIType.characterSheet, "clearTalents")
	else
		if TalentManager.HiddenTalents[talentId] == nil then
			TalentManager.HiddenTalents[talentId] = {}
		end
		if TalentManager.HiddenTalents[talentId][modID] ~= true then
			TalentManager.HiddenTalents[talentId][modID] = true
			TalentManager.HiddenCount[talentId] = (TalentManager.HiddenCount[talentId] or 0) + 1
			GameHelpers.UI.TryInvoke(Data.UIType.characterSheet, "clearTalents")
		end
	end
end

---Stops hiding a talent from the UI.
---@param talentId string
---@param modID string
function TalentManager.UnhideTalent(talentId, modID)
	if talentId == "all" then
		for _,talent in pairs(Data.Talents) do
			TalentManager.UnhideTalent(talent, modID)
		end
	else
		local count = TalentManager.HiddenCount[talentId] or 0
		local data = TalentManager.HiddenTalents[talentId]
		if data ~= nil then
			if TalentManager.HiddenTalents[talentId][modID] ~= nil then
				TalentManager.HiddenTalents[talentId][modID] = nil
				count = count - 1
			end
		end
		if count <= 0 then
			TalentManager.HiddenTalents[talentId] = nil
			TalentManager.HiddenCount[talentId] = nil
		else
			TalentManager.HiddenCount[talentId] = count
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

local function TalentIsHidden(talentId)
	local count = TalentManager.HiddenCount[talentId]
	return count and count > 0
end

---@class TalentMC_CC
---@field addTalentElement fun(id:int, name:string, isActive:boolean, isChooseable:boolean, isRacial:boolean):void 

---@param talent_mc TalentMC_CC
function TalentManager.Update_CC(ui, talent_mc, player)
	for talentId,talentStat in pairs(missingTalents) do
		--Same setup for CC in controller mode as well
		if TalentManager.RegisteredCount[talentId] > 0 and not TalentIsHidden(talentId) then
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
			if not TalentIsHidden(talentId) and not UI.IsInArray(ui, "talentArray", talentId, 1, 4) then
				local talentState = TalentManager.GetTalentState(player, talentId)
				local name = TalentManager.GetTalentDisplayName(player, talentId, talentState)
				talent_mc.addTalentElement(talentEnum, name, player.Stats[talentStat], talentState ~= TalentState.Locked, true)
				if Vars.ControllerEnabled then
					TalentManager.Gamepad.UpdateTalent_CC(ui, player, talentId, talentEnum)
				end
			end
		end
	end

	if not TalentIsHidden("RogueLoreDaggerBackStab") and player.Stats.TALENT_RogueLoreDaggerBackStab or 
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
		if not TalentIsHidden(talentId) and TalentManager.RegisteredCount[talentId] > 0 then
			i = AddTalentToArray(ui, player, talent_array, talentId, lvlBtnTalent_array, i)
		end
	end

	if Features.RacialTalentsDisplayFix then
		i = #talent_array
		for talentId,talentStat in pairs(racialTalents) do
			if not TalentIsHidden(talentId) and player.Stats[talentStat] == true then
				i = AddTalentToArray(ui, player, talent_array, talentId, lvlBtnTalent_array, i, true)
			end
		end
	end

	if not TalentIsHidden("RogueLoreDaggerBackStab") and player.Stats.TALENT_RogueLoreDaggerBackStab or 
	(GameSettings.Settings.BackstabSettings.Player.Enabled and GameSettings.Settings.BackstabSettings.Player.TalentRequired) then
		i = #talent_array
		AddTalentToArray(ui, player, talent_array, "RogueLoreDaggerBackStab", lvlBtnTalent_array, i)
	end
end

if Vars.DebugMode then
	RegisterListener("LuaReset", function()
		local ui = Ext.GetUIByType(Data.UIType.statsPanel_c)
		if ui then
			ui:GetRoot().mainpanel_mc.stats_mc.talents_mc.statList.clearElements()
		end
	end)
end

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

local function HideTalents(uiType)
	local ui = Ext.GetUIByType(uiType)
	if ui then
		local main = ui:GetRoot()
		if main then
			local hasEntries = true
			local removed = false
			local list = nil
			local idProperty = "id"
			if uiType == Data.UIType.characterSheet then
				list = main.stats_mc.talentHolder_mc.list
				idProperty = "statId"
			elseif uiType == Data.UIType.statsPanel_c then
				list = main.mainpanel_mc.stats_mc.talents_mc.statList
				idProperty = "id"
			elseif uiType == Data.UIType.characterCreation then
				list = main.CCPanel_mc.talents_mc.talentList
				idProperty = "talentID"
			elseif uiType == Data.UIType.characterCreation_c then
				list = main.CCPanel_mc.talents_mc.contentList
				idProperty = "contentID"
			end
			for talentId,count in pairs(TalentManager.HiddenCount) do
				if count > 0 then
					hasEntries = true
					local talentEnum = Data.TalentEnum[talentId]
					if uiType == Data.UIType.characterCreation_c then
						if racialTalents[talentId] then
							list = main.CCPanel_mc.talents_mc.racialList
						else
							list = main.CCPanel_mc.talents_mc.contentList
						end
					end
					for i=0,#list.content_array do
						local entry = list.content_array[i]
						if entry and entry[idProperty] == talentEnum then
							list.removeElement(i, false)
							removed = true
							break
						end
					end
				end
			end
			if removed then
				list.positionElements()
			elseif Vars.DebugMode and hasEntries then
				--Ext.PrintError("Failed to remove any talents", Ext.JsonStringify(TalentManager.HiddenCount))
			end
		end
	end
end

---@param ui UIObject
local function DisplayTalents(ui, call, ...)
	---@type EsvCharacter
	local player = nil
	local handle = ui:GetPlayerHandle()
	if handle ~= nil then
		player = Ext.GetCharacter(handle)
	elseif Client.Character ~= nil then
		player = Client:GetCharacter()
	end
	if player ~= nil then
		TalentManager.Update(ui, player)
		local length = #Listeners.OnTalentArrayUpdating
		if length > 0 then
			for i=1,length do
				local callback = Listeners.OnTalentArrayUpdating[i]
				local talentArrayStartIndex = UI.GetArrayIndexStart(ui, "talent_array", 3)
				local b,err = xpcall(callback, debug.traceback, ui, player, talentArrayStartIndex, Data.TalentEnum)
				if not b then
					Ext.PrintError("Error calling function for 'OnTalentArrayUpdating':\n", err)
				end
			end
		end

		local typeid = ui:GetTypeId()
		UIExtensions.StartTimer("LeaderLib_HideTalents_Sheet", 5, function(timerName, isComplete)
			HideTalents(typeid)
		end)
	end
end

-- addTalentElement(talentId:uint, talentName:String, state:Boolean, choosable:Boolean, isRacial:Boolean) : *

---@param ui UIObject
local function DisplayTalents_CC(ui, call, ...)
	if GameSettings.Default == nil then
		-- This function may run before the game is "Running" and the settings load normally.
		LoadGameSettings()
	end

	---@type EsvCharacter
	local player = nil
	local handle = ui:GetPlayerHandle()
	if handle ~= nil then
		player = Ext.GetCharacter(handle)
	elseif  Client.Character ~= nil then
		player = Client:GetCharacter()
	end
	if player ~= nil then
		local root = ui:GetRoot()
		local talent_mc = root.CCPanel_mc.talents_mc
		TalentManager.Update_CC(ui, talent_mc, player)
		local typeid = ui:GetTypeId()
		UIExtensions.StartTimer("LeaderLib_HideTalents_CharacterCreation", 5, function(timerName, isComplete)
			HideTalents(typeid)
		end)
	end
end

Ext.RegisterListener("SessionLoaded", function()
	Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", DisplayTalents)
	Ext.RegisterUITypeInvokeListener(Data.UIType.statsPanel_c, "updateArraySystem", DisplayTalents)
	--characterCreation.swf
	Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation, "updateTalents", DisplayTalents_CC)
	Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation_c, "updateTalents", DisplayTalents_CC)


	TalentManager.LoadRequirements()
	---Divine Talents
	if Ext.IsModLoaded("ca32a698-d63e-4d20-92a7-dd83cba7bc56") or GameSettings.Settings.Client.DivineTalentsEnabled then
		TalentManager.ToggleDivineTalents(true)
	end

	TalentManager.Gamepad.RegisterListeners()

	-- if Vars.DebugMode then
	-- 	TalentManager.HideTalent("all", "LeaderLib")
	-- 	--TalentManager.HideTalent("Raistlin", "LeaderLib")
	-- 	TalentManager.UnhideTalent("FaroutDude", "LeaderLib")
	-- end
end)