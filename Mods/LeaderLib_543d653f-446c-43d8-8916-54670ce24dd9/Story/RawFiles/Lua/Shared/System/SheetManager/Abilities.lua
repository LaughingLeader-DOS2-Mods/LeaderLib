local ts = Classes.TranslatedString

---@class AbilityManager
SheetManager.AbilityManager = {
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
SheetManager.AbilityManager.__index = SheetManager.AbilityManager

local missingAbilities = SheetManager.AbilityManager.Data.DOSAbilities
for name,v in pairs(missingAbilities) do
	SheetManager.AbilityManager.RegisteredCount[name] = 0
end

function SheetManager.AbilityManager.EnableAbility(abilityName, modID)
	if StringHelpers.Equals(abilityName, "all", true) then
		for ability,v in pairs(missingAbilities) do
			SheetManager.AbilityManager.EnableAbility(ability, modID)
		end
	else
		if SheetManager.AbilityManager.RegisteredAbilities[abilityName] == nil then
			SheetManager.AbilityManager.RegisteredAbilities[abilityName] = {}
		end
		if SheetManager.AbilityManager.RegisteredAbilities[abilityName][modID] ~= true then
			SheetManager.AbilityManager.RegisteredAbilities[abilityName][modID] = true
			SheetManager.AbilityManager.RegisteredCount[abilityName] = (SheetManager.AbilityManager.RegisteredCount[abilityName] or 0) + 1
		end
	end
end

-- if Vars.DebugMode then
-- 	for k,v in pairs(missingAbilities) do
-- 		SheetManager.AbilityManager.EnableAbility(k, "7e737d2f-31d2-4751-963f-be6ccc59cd0c")
-- 	end
-- end

function SheetManager.AbilityManager.DisableAbility(abilityName, modID)
	if StringHelpers.Equals(abilityName, "all", true) then
		for ability,v in pairs(missingAbilities) do
			SheetManager.AbilityManager.DisableAbility(ability, modID)
		end
		if not Vars.ControllerEnabled then
			GameHelpers.UI.TryInvoke(Data.UIType.characterSheet, "clearAbilities")
		end
	else
		local data = SheetManager.AbilityManager.RegisteredAbilities[abilityName]
		if data ~= nil then
			if SheetManager.AbilityManager.RegisteredAbilities[abilityName][modID] ~= nil then
				SheetManager.AbilityManager.RegisteredAbilities[abilityName][modID] = nil
				SheetManager.AbilityManager.RegisteredCount[abilityName] = SheetManager.AbilityManager.RegisteredCount[abilityName] - 1
			end
			if SheetManager.AbilityManager.RegisteredCount[abilityName] <= 0 then
				SheetManager.AbilityManager.RegisteredAbilities[abilityName] = nil
				SheetManager.AbilityManager.RegisteredCount[abilityName] = 0

				if not Vars.ControllerEnabled then
					GameHelpers.UI.TryInvoke(Data.UIType.characterSheet, "clearAbilities")
				end
			end
		end
	end
end

if Ext.IsClient() then
	function SheetManager.AbilityManager.CanAddAbility(id, player)
		if SheetManager.AbilityManager.Data.Abilities[id] then
			return true
		end
		if SheetManager.AbilityManager.Data.DOSAbilities[id] and SheetManager.AbilityManager.RegisteredCount[id] > 0 then
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

	function SheetManager.AbilityManager.UpdateCharacterSheetPoints(ui, method, main, amount)
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
			if SheetManager.AbilityManager.RegisteredCount[abilityName] > 0 then
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

	---@class SheetManager.AbilityManagerUIEntry
	---@field ID string
	---@field SheetID integer
	---@field DisplayName string
	---@field IsCivil boolean
	---@field GroupID integer
	---@field GroupTitle string
	---@field AddPointsTooltip string
	---@field Value integer
	---@field Delta integer
	---@field IsCustom boolean

	---@private
	---@param player EclCharacter
	---@param civilOnly boolean|nil
	---@return fun():SheetManager.AbilityManagerUIEntry
	function SheetManager.AbilityManager.GetVisible(player, civilOnly, this)
		local abilities = {}
		local tooltip = LocalizedText.UI.AbilityPlusTooltip:ReplacePlaceholders(Ext.ExtraData.CombatAbilityLevelGrowth)

		local abilityPoints = GetAvailablePoints("combat", this)
		local civilPoints = GetAvailablePoints("civil", this)
	
		local maxAbility = Ext.ExtraData.CombatAbilityCap or 10
		local maxCivil = Ext.ExtraData.CivilAbilityCap or 5

		for numId,id in Data.Ability:Get() do
			local data = SheetManager.AbilityManager.Data.Abilities[id] or SheetManager.AbilityManager.Data.DOSAbilities[id]
			if data ~= nil and (civilOnly == true and data.Civil) or (civilOnly == false and not data.Civil) then
				if SheetManager.AbilityManager.CanAddAbility(id, player) then
					local canAddPoints = false
					if civilOnly then
						canAddPoints = civilPoints > 0 and player.Stats[id] < maxCivil
					else
						canAddPoints = abilityPoints > 0 and player.Stats[id] < maxAbility
					end
					local name = GameHelpers.GetAbilityName(id)
					local isCivil = data.Civil == true
					local groupID = data.Group
					local statVal = player.Stats[id] or 0
					---@type TalentManagerUITalentEntry
					local data = {
						ID = id,
						SheetID = Data.AbilityEnum[id],
						DisplayName = name,
						IsCivil = isCivil,
						GroupID = groupID,
						IsCustom = false,
						Value = statVal,
						Delta = statVal,
						AddPointsTooltip = tooltip,
						CanAdd = canAddPoints,
						CanRemove = false,
					}
					abilities[#abilities+1] = data
				end
			end
		end
		local i = 0
		local count = #abilities
		return function ()
			i = i + 1
			if i <= count then
				return abilities[i]
			end
		end
	end
end