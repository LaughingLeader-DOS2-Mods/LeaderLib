
---@class CharacterSheetWrapper:LeaderLibUIWrapper
local CharacterSheet = Classes.UIWrapper:CreateFromType(Data.UIType.characterSheet, {ControllerID = Data.UIType.statsPanel_c, IsControllerSupported = true})
local self = CharacterSheet

---@private
---@param ui UIObject
function CharacterSheet.Update(ui, method, updateTalents, updateAbilities, updateCivil)
	print("CharacterSheet.Update", method, updateTalents, updateAbilities, updateCivil)
	local this = self.Root
	--this.clearArray("talentArray")
	local player = Ext.GetCharacter(Ext.DoubleToHandle(this.characterHandle)) or Client:GetCharacter()

	local updatedAbilities,updatedCombat,updatedTalents = false,false,false

	-- if method == "setAvailableCombatAbilityPoints" then
	-- 	availableCombatPoints[id] = amount
	-- 	setAvailablePoints[id] = true
	-- elseif method == "setAvailableCivilAbilityPoints" then
	-- 	availableCivilPoints[id] = amount
	-- 	setAvailablePoints[id] = true
	-- end
	
	if updateTalents then
		local points = this.stats_mc.pointsWarn[3].avPoints
	
		for talent in SheetManager.Talents.GetVisible(player) do
			local canAdd = false
			local canRemove = false
			updatedTalents = true
			if not talent.IsRacial then
				if not talent.HasTalent and points > 0 and talent.State == SheetManager.Talents.Data.TalentState.Selectable then
					canAdd = true
				elseif talent.HasTalent then
					canRemove = GameHelpers.Client.IsGameMaster(ui, this)
				end
			end
			if not Vars.ControllerEnabled then
				this.stats_mc.addTalent(talent.DisplayName, talent.ID, talent.State, canAdd, canRemove, talent.IsCustom)
			else
				this.mainpanel_mc.stats_mc.talents_mc.addTalent(talent.DisplayName, talent.ID, talent.State, canAdd, canRemove, talent.IsCustom)
			end
		end
		this.stats_mc.addCustomTalent("Test", "testTalent", 0, true, false, true)
	end

	if updateAbilities then
		for ability in SheetManager.Abilities.GetVisible(player, updateCivil, this) do
			this.stats_mc.addAbility(ability.IsCivil, ability.GroupID, ability.ID, ability.DisplayName, ability.Value, ability.AddPointsTooltip, "", ability.CanAdd, ability.CanRemove, ability.IsCustom)
			updatedAbilities = true
		end
	end

	if not Vars.ControllerEnabled then
		if updatedTalents then
			this.stats_mc.talentHolder_mc.list.positionElements()
		end
		if updatedAbilities then
			if updateCivil then
				this.stats_mc.civicAbilityHolder_mc.list.positionElements()
				this.stats_mc.recountAbilityPoints(true)
			else
				this.stats_mc.combatAbilityHolder_mc.list.positionElements()
				this.stats_mc.recountAbilityPoints(false)
			end
		end
	else
		if updatedTalents then
			this.mainpanel_mc.stats_mc.talents_mc.updateDone()
		end
		if updatedAbilities then
			if updateCivil then
				this.mainpanel_mc.stats_mc.civilAbilities_mc.updateDone()
			else
				this.mainpanel_mc.stats_mc.combatAbilities_mc.updateDone()
			end
		end
	end
end

Ext.RegisterUITypeCall(Data.UIType.characterSheet, "characterSheetUpdateDone", CharacterSheet.Update)
Ext.RegisterUITypeCall(Data.UIType.statsPanel_c, "characterSheetUpdateDone", CharacterSheet.Update)