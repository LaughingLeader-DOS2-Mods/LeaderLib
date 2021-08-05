local ts = Classes.TranslatedString

---@alias SheetAbilityGroupID string |"Weapons"|"Defense"|"Skills"|"Personality"|"Craftsmanship"|"NastyDeeds"

---@class AbilityManager
SheetManager.Abilities = {
	RegisteredAbilities = {},
	RegisteredCount = {},
	Data = {
		GroupTitle = {
			Combat = {
				[0] = ts:Create("h5fb2ef9cg4258g446eg9522gd6be58f3ab23", "Weapons"), -- May be a different handle
				[1] = ts:Create("ha65cecedg819dg4d17g9f0ag1bf646ec4f6c", "Defence"),
				[2] = ts:Create("hb5277ad5gafbcg4f31g8022gaeedf7a516aa", "Skills"), -- May be a different handle
			},
			Civil = {
				[0] = ts:Create("h3df7f54fg51f4g4355g93ecgb0b7add14018", "Personality"), -- or h5b78d698gab2ag4423g88d5gbfb549b015f8
				[1] = ts:Create("h2890aceag6c58g41a7gb286g5044fc11d7f1", "Craftsmanship"), -- or h7cc0941cg4b22g43a6gae93g3f3b240741cd
				[2] = ts:Create("he920062fg4553g4b1eg9935gec94a4c1aa59", "Nasty Deeds"), -- or hc92a5451g8a18g40f4g9a80g40bb23b98a8a
			}
		},
		GroupID = {
			Weapons = 0,
			Defense = 1,
			Skills = 2,
			Personality = 3,
			Craftsmanship = 4,
			NastyDeeds = 5,
		},
		GroupIDInteger = {
			[0] = "Weapons",
			[1] = "Defense",
			[2] = "Skills",
			[3] = "Personality",
			[4] = "Craftsmanship",
			[5] = "NastyDeeds",
		},
		Abilities = {
			SingleHanded = {Group=0, Civil=false},
			TwoHanded = {Group=0, Civil=false},
			Ranged = {Group=0, Civil=false},
			DualWielding = {Group=0, Civil=false},
			PainReflection = {Group=1, Civil=false},
			Leadership = {Group=1, Civil=false},
			Perseverance = {Group=1, Civil=false},
			WarriorLore = {Group=2, Civil=false},
			RangerLore = {Group=2, Civil=false},
			RogueLore = {Group=2, Civil=false},
			FireSpecialist = {Group=2, Civil=false},
			WaterSpecialist = {Group=2, Civil=false},
			AirSpecialist = {Group=2, Civil=false},
			EarthSpecialist = {Group=2, Civil=false},
			Necromancy = {Group=2, Civil=false},
			Summoning = {Group=2, Civil=false},
			Polymorph = {Group=2, Civil=false},
			Barter = {Group=3, Civil=true},
			Persuasion = {Group=3, Civil=true},
			Luck = {Group=3, Civil=true},
			Telekinesis = {Group=4, Civil=true},
			Loremaster = {Group=4, Civil=true},
			Sneaking = {Group=5, Civil=true},
			Thievery = {Group=5, Civil=true},
		},
		DOSAbilities = {
			Shield = {Group=0, Civil=false},
			Reflexes = {Group=1, Civil=false},
			PhysicalArmorMastery = {Group=1, Civil=false},
			Sourcery = {Group=2, Civil=false},
			Sulfurology = {Group=2, Civil=false},
			Repair = {Group=1, Civil=true},
			Crafting = {Group=1, Civil=true},
			Charm = {Group=3, Civil=true},
			Intimidate = {Group=3, Civil=true},
			Reason = {Group=3, Civil=true},
			Wand = {Group=0, Civil=false},
			MagicArmorMastery = {Group=1, Civil=false},
			VitalityMastery = {Group=1, Civil=false},
			Runecrafting = {Group=4, Civil=true},
			Brewmaster = {Group=4, Civil=true},
			Pickpocket = {Group=5, Civil=true},
		}
	}
}
SheetManager.Abilities.__index = SheetManager.Abilities

local missingAbilities = SheetManager.Abilities.Data.DOSAbilities
for name,v in pairs(missingAbilities) do
	SheetManager.Abilities.RegisteredCount[name] = 0
end

if not AbilityManager then
	AbilityManager = SheetManager.Abilities
end

function SheetManager.Abilities.EnableAbility(abilityName, modID)
	if StringHelpers.Equals(abilityName, "all", true) then
		for ability,v in pairs(missingAbilities) do
			SheetManager.Abilities.EnableAbility(ability, modID)
		end
	else
		if SheetManager.Abilities.RegisteredAbilities[abilityName] == nil then
			SheetManager.Abilities.RegisteredAbilities[abilityName] = {}
		end
		if SheetManager.Abilities.RegisteredAbilities[abilityName][modID] ~= true then
			SheetManager.Abilities.RegisteredAbilities[abilityName][modID] = true
			SheetManager.Abilities.RegisteredCount[abilityName] = (SheetManager.Abilities.RegisteredCount[abilityName] or 0) + 1
		end
	end
end

-- if Vars.DebugMode then
-- 	for k,v in pairs(missingAbilities) do
-- 		SheetManager.Abilities.EnableAbility(k, "7e737d2f-31d2-4751-963f-be6ccc59cd0c")
-- 	end
-- end

function SheetManager.Abilities.DisableAbility(abilityName, modID)
	if StringHelpers.Equals(abilityName, "all", true) then
		for ability,v in pairs(missingAbilities) do
			SheetManager.Abilities.DisableAbility(ability, modID)
		end
		if not Vars.ControllerEnabled then
			GameHelpers.UI.TryInvoke(Data.UIType.characterSheet, "clearAbilities")
		end
	else
		local data = SheetManager.Abilities.RegisteredAbilities[abilityName]
		if data ~= nil then
			if SheetManager.Abilities.RegisteredAbilities[abilityName][modID] ~= nil then
				SheetManager.Abilities.RegisteredAbilities[abilityName][modID] = nil
				SheetManager.Abilities.RegisteredCount[abilityName] = SheetManager.Abilities.RegisteredCount[abilityName] - 1
			end
			if SheetManager.Abilities.RegisteredCount[abilityName] <= 0 then
				SheetManager.Abilities.RegisteredAbilities[abilityName] = nil
				SheetManager.Abilities.RegisteredCount[abilityName] = 0

				if not Vars.ControllerEnabled then
					GameHelpers.UI.TryInvoke(Data.UIType.characterSheet, "clearAbilities")
				end
			end
		end
	end
end

if Ext.IsClient() then
	function SheetManager.Abilities.CanAddAbility(id, player)
		if SheetManager.Abilities.Data.Abilities[id] then
			return true
		end
		if SheetManager.Abilities.Data.DOSAbilities[id] and SheetManager.Abilities.RegisteredCount[id] > 0 then
			return true
		end
		return false
	end

	local availableCombatPoints = {}
	local availableCivilPoints = {}
	local setAvailablePoints = {}

	local function SetAvailablePointsFromStored(main)
		if main == nil then
			if not Vars.ControllerEnabled then
				main = Ext.GetUIByType(Data.UIType.characterSheet):GetRoot()
			else
				main = Ext.GetUIByType(Data.UIType.statsPanel_c):GetRoot()
			end
		end
		local id = GameHelpers.Client.GetCharacterSheetCharacter(main).NetID
		if not Vars.ControllerEnabled then
			availableCombatPoints[id] = main.stats_mc.pointsWarn[1].avPoints
			availableCivilPoints[id] = main.stats_mc.pointsWarn[2].avPoints
		else
			availableCombatPoints[id] = tonumber(main.mainpanel_mc.stats_mc.combatAbilities_mc.pointsValue_txt.text) or 0
			availableCivilPoints[id] = tonumber(main.mainpanel_mc.stats_mc.civilAbilities_mc.pointsValue_txt.text) or 0
		end
	end

	local function GetAvailablePoints(pointType, main)
		local id = GameHelpers.Client.GetCharacterSheetCharacter(main).NetID
		if setAvailablePoints[id] ~= true then
			SetAvailablePointsFromStored(main)
		end
		local points = 0
		if pointType == "combat" then
			points = availableCombatPoints[id]
			if points == nil then
				if not Vars.ControllerEnabled then
					points = main.stats_mc.pointsWarn[1].avPoints
				else
					points = tonumber(main.mainpanel_mc.stats_mc.combatAbilities_mc.pointsValue_txt.text) or 0
				end
			end
		else
			points = availableCivilPoints[id]
			if points == nil then
				if not Vars.ControllerEnabled then
					points = main.stats_mc.pointsWarn[2].avPoints
				else
					points = tonumber(main.mainpanel_mc.stats_mc.civilAbilities_mc.pointsValue_txt.text) or 0
				end
			end
		end
		return points or 0
	end

	function SheetManager.Abilities.UpdateCharacterSheetPoints(ui, method, main, amount)
		local character = Client:GetCharacter()
		local id = character.NetID
		if method == "setAvailableCombatAbilityPoints" then
			availableCombatPoints[id] = amount
			setAvailablePoints[id] = true
		elseif method == "setAvailableCivilAbilityPoints" then
			availableCivilPoints[id] = amount
			setAvailablePoints[id] = true
		end

		local abilityPoints = GetAvailablePoints("combat", main)
		local civilPoints = GetAvailablePoints("civil", main)

		local maxAbility = Ext.ExtraData.CombatAbilityCap or 10
		local maxCivil = Ext.ExtraData.CivilAbilityCap or 5

		for abilityName,data in pairs(missingAbilities) do
			if SheetManager.Abilities.RegisteredCount[abilityName] > 0 then
				local abilityID = Data.AbilityEnum[abilityName]
				if not data.Civil then
					local canAddPoints = abilityPoints > 0 and character.Stats[abilityName] < maxAbility
					if not Vars.ControllerEnabled then
						main.stats_mc.setAbilityPlusVisible(false, data.Group, abilityID, abilityPoints > 0)
					else
						main.mainpanel_mc.stats_mc.combatAbilities_mc.setBtnVisible(data.Group, abilityID, true, canAddPoints)
					end
				else
					local canAddPoints = civilPoints > 0 and character.Stats[abilityName] < maxCivil
					if not Vars.ControllerEnabled then
						main.stats_mc.setAbilityPlusVisible(true, data.Group, abilityID, civilPoints > 0)
					else
						main.mainpanel_mc.stats_mc.civilAbilities_mc.setBtnVisible(data.Group, abilityID, true, canAddPoints)
					end
				end
			end
		end
	end

	if Vars.DebugMode then
		Ext.RegisterConsoleCommand("leaderlib_ap_resetfromstored", function()
			SetAvailablePointsFromStored()
		end)
	end

	---@class SheetManager.AbilitiesUIEntry
	---@field ID string
	---@field SheetID integer
	---@field DisplayName string
	---@field IsCivil boolean
	---@field GroupID integer
	---@field GroupTitle string
	---@field AddPointsTooltip string
	---@field RemovePointsTooltip string
	---@field Value integer
	---@field Delta integer
	---@field CanAdd boolean
	---@field CanRemove boolean
	---@field IsCustom boolean

	---@private
	---@param player EclCharacter
	---@param civilOnly boolean|nil
	---@param isCharacterCreation boolean|nil
	---@param isGM boolean|nil
	---@return fun():SheetManager.AbilitiesUIEntry
	function SheetManager.Abilities.GetVisible(player, civilOnly, isCharacterCreation, isGM)
		if isCharacterCreation == nil then
			isCharacterCreation = false
		end
		if isGM == nil then
			isGM = false
		end
		local entries = {}
		local tooltip = LocalizedText.UI.AbilityPlusTooltip:ReplacePlaceholders(Ext.ExtraData.CombatAbilityLevelGrowth)

		local abilityPoints = Client.Character.Points.Ability
		local civilPoints = Client.Character.Points.Civil
		--local abilityPoints = GetAvailablePoints("combat", this)
		--local civilPoints = GetAvailablePoints("civil", this)
	
		local maxAbility = Ext.ExtraData.CombatAbilityCap or 10
		local maxCivil = Ext.ExtraData.CivilAbilityCap or 5

		--Defaults
		for numId,id in Data.Ability:Get() do
			local data = SheetManager.Abilities.Data.Abilities[id] or SheetManager.Abilities.Data.DOSAbilities[id]
			if data ~= nil and (civilOnly == true and data.Civil) or (civilOnly == false and not data.Civil) then
				if SheetManager.Abilities.CanAddAbility(id, player) then
					local canAddPoints = isGM
					if not canAddPoints then
						if civilOnly then
							canAddPoints = civilPoints > 0 and player.Stats[id] < maxCivil
						else
							canAddPoints = abilityPoints > 0 and player.Stats[id] < maxAbility
						end
					end
					local name = GameHelpers.GetAbilityName(id)
					local isCivil = data.Civil == true
					local groupID = data.Group
					local statVal = player.Stats[id] or 0
					---@type TalentManagerUITalentEntry
					local data = {
						--ID = id,
						ID = Data.AbilityEnum[id],
						DisplayName = name,
						IsCivil = isCivil,
						GroupID = groupID,
						IsCustom = false,
						Value = statVal,
						Delta = statVal,
						AddPointsTooltip = tooltip,
						RemovePointsTooltip = "",
						CanAdd = canAddPoints,
						CanRemove = isCharacterCreation or isGM,
					}
					entries[#entries+1] = data
				end
			end
		end

		for mod,dataTable in pairs(SheetManager.Data.Abilities) do
			for id,data in pairs(dataTable) do
				local value = data:GetValue(player)
				if SheetManager:IsEntryVisible(data, player, value) then
					local canAddPoints = false
					if civilOnly then
						canAddPoints = civilPoints > 0
					else
						canAddPoints = abilityPoints > 0
					end
					---@type TalentManagerUITalentEntry
					local data = {
						ID = data.GeneratedID,
						DisplayName = data:GetDisplayName(),
						IsCivil = data.IsCivil,
						GroupID = data.GroupID,
						IsCustom = true,
						Value = string.format("%s", value) .. data.Suffix,
						Delta = value,
						AddPointsTooltip = tooltip,
						RemovePointsTooltip = "",
						CanAdd = SheetManager:GetIsPlusVisible(data, player, canAddPoints, value),
						CanRemove = SheetManager:GetIsMinusVisible(data, player, isCharacterCreation, value),
					}
					entries[#entries+1] = data
				end
			end
		end

		local i = 0
		local count = #entries
		return function ()
			i = i + 1
			if i <= count then
				return entries[i]
			end
		end
	end
end