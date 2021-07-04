
---@class CharacterSheetWrapper:LeaderLibUIWrapper
CharacterSheet = Classes.UIWrapper:CreateFromType(Data.UIType.characterSheet, {ControllerID = Data.UIType.statsPanel_c, IsControllerSupported = true})
local self = CharacterSheet

---@private
---@param ui UIObject
function CharacterSheet.Update(ui, method, updateTalents, updateAbilities, updateCivil)
	local this = self.Root
	--this.clearArray("talentArray")
	local player = Ext.GetCharacter(Ext.DoubleToHandle(this.characterHandle)) or Client:GetCharacter()

	local updatedCivil,updatedCombat,updatedTalents = false,false,false

	if updateTalents then
		for talent in TalentManager.GetVisibleTalents(player) do
			updatedTalents = true
			if not Vars.ControllerEnabled then
				if not talent.IsCustom then
					this.stats_mc.addTalent(talent.DisplayName, talent.IntegerID, talent.State)
				else
					this.stats_mc.addCustomTalent(talent.DisplayName, talent.ID, talent.State)
				end
			else
				if not talent.IsCustom then
					this.mainpanel_mc.stats_mc.talents_mc.addTalent(talent.DisplayName, talent.IntegerID, talent.State)
				else
					this.mainpanel_mc.stats_mc.talents_mc.addCustomTalent(talent.DisplayName, talent.ID, talent.State)
				end
			end
		end
	end

	if updateAbilities then
		if updateCivil then

		else

		end
	end

	if not Vars.ControllerEnabled then
		if updatedTalents then
			this.stats_mc.talentHolder_mc.list.positionElements()
		end
		if updatedCivil then
			this.stats_mc.civicAbilityHolder_mc.list.positionElements()
			this.stats_mc.recountAbilityPoints(true)
		end
		if updatedCombat then
			this.stats_mc.combatAbilityHolder_mc.list.positionElements()
			this.stats_mc.recountAbilityPoints(false)
		end
	else
		if updatedTalents then
			this.mainpanel_mc.stats_mc.talents_mc.updateDone()
		end
		if updatedCivil then
			this.mainpanel_mc.stats_mc.combatAbilities_mc.updateDone()
		end
		if updatedCombat then
			this.mainpanel_mc.stats_mc.civilAbilities_mc.updateDone()
		end
	end
end

Ext.RegisterUITypeCall(Data.UIType.characterSheet, "characterSheetUpdateDone", CharacterSheet.Update)
Ext.RegisterUITypeCall(Data.UIType.statsPanel_c, "characterSheetUpdateDone", CharacterSheet.Update)