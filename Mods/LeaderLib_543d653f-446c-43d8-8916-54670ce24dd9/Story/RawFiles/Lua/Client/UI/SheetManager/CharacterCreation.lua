
---@class CharacterCreationWrapper:LeaderLibUIWrapper
local CharacterCreation = Classes.UIWrapper:CreateFromType(Data.UIType.characterCreation, {ControllerID = Data.UIType.characterCreation_c, IsControllerSupported = true})
local self = CharacterCreation

---@class FlashCharacterCreationTalentsMC:FlashMovieClip
---@field addTalentElement fun(talentID:integer, talentLabel:string, isUnlocked:boolean, isChoosable:boolean, isRacial:boolean):void
---@field addCustomTalentElement fun(customID:string, talentLabel:string, isUnlocked:boolean, isChoosable:boolean, isRacial:boolean):void

---@private
---@param ui UIObject
function CharacterCreation.UpdateTalents(ui, method)
	local this = self.Root
	--this.clearArray("talentArray")
	local player = Ext.GetCharacter(Ext.DoubleToHandle(this.characterHandle)) or Client:GetCharacter()

	---@type FlashCharacterCreationTalentsMC
	local talentsMC = this.CCPanel_mc.talents_mc

	for talent in SheetManager.TalentManager.GetVisible(player) do
		talentsMC.addTalentElement(talent.IntegerID, talent.DisplayName, talent.HasTalent, talent.IsChoosable, talent.IsRacial, talent.IsCustom)
	end

	if not Vars.ControllerEnabled then
		talentsMC.positionLists()
	else
		talentsMC.talents_mc.setupLists()
	end
end

---@private
---@param ui UIObject
function CharacterCreation.UpdateAbilities(ui, method)
	local this = self.Root
	--this.clearArray("abilityArray")

	local player = Ext.GetCharacter(Ext.DoubleToHandle(this.characterHandle)) or Client:GetCharacter()

	local abilities_mc = this.CCPanel_mc.abilities_mc
	
	local class_mc = this.root_mc.CCPanel_mc.class_mc
	local classEdit = class_mc.classEditList[1]
	classEdit.contentList.clearElements()
	for ability in SheetManager.AbilityManager.GetVisible(player) do
		if not ability.IsCustom then
			classEdit.addContentString(1,ability.IntegerID,ability.DisplayName)
			abilities_mc.addAbility(ability.Group.ID, ability.Group.DisplayName, ability.IntegerID, ability.DisplayName, ability.Value, ability.Delta, ability.IsCivil)
		else
			abilities_mc.addCustomAbility(ability.Group.ID, ability.Group.DisplayName, ability.ID, ability.DisplayName, ability.Value, ability.Delta, ability.IsCivil)
		end
	end
	classEdit.contentList.positionElements()

	if not Vars.ControllerEnabled then
		abilities_mc.updateComplete()
	else
		abilities_mc.talents_mc.setupLists()
	end
end

--Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation, "updateTalents", CharacterCreation.UpdateTalents)
--Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation_c, "updateTalents", CharacterCreation.UpdateTalents)
-- Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation, "updateAbilities", CharacterCreation.UpdateAbilities)
-- Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation_c, "updateAbilities", CharacterCreation.UpdateAbilities)