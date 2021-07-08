
---@class CharacterSheetWrapper:LeaderLibUIWrapper
local CharacterSheet = Classes.UIWrapper:CreateFromType(Data.UIType.characterSheet, {ControllerID = Data.UIType.statsPanel_c, IsControllerSupported = true})
local self = CharacterSheet

---@private
---@param ui UIObject
function CharacterSheet.PreUpdate(ui, method, updateTalents, updateAbilities, updateCivil)
	local this = self.Root
	local secStat_array = this.secStat_array
	for i=0,#secStat_array-1,7 do
		if not secStat_array[i] then
			local label = this.secStat_array[i + 2]
			if LocalizedText.Base.Experience:Equals(label) then
				secStat_array[i+2] = LocalizedText.Base.Total.Value
				break
			end
		end
	end
end
---@private
---@param ui UIObject
function CharacterSheet.Update(ui, method, updateTalents, updateAbilities, updateCivil)
	PrintDebug("CharacterSheet.Update", method, updateTalents, updateAbilities, updateCivil)
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
	
		for talent in SheetManager.TalentManager.GetVisible(player) do
			local canAdd = false
			local canRemove = false
			updatedTalents = true
			if not talent.IsRacial then
				if not talent.HasTalent and points > 0 and talent.State == SheetManager.TalentManager.Data.TalentState.Selectable then
					canAdd = true
				elseif talent.HasTalent then
					canRemove = GameHelpers.Client.IsGameMaster(ui, this)
				end
			end
			if not Vars.ControllerEnabled then
				this.stats_mc.addTalent(talent.DisplayName, talent.SheetID, talent.State, canAdd, canRemove, talent.IsCustom)
			else
				this.mainpanel_mc.stats_mc.talents_mc.addTalent(talent.DisplayName, talent.SheetID, talent.State, canAdd, canRemove, talent.IsCustom)
			end
		end
		this.stats_mc.addTalent("Test", 404, 1, true, false, true)
	end

	if updateAbilities then
		for ability in SheetManager.AbilityManager.GetVisible(player, updateCivil, this) do
			this.stats_mc.addAbility(ability.IsCivil, ability.GroupID, ability.SheetID, ability.DisplayName, ability.Value, ability.AddPointsTooltip, "", ability.CanAdd, ability.CanRemove, ability.IsCustom)
			updatedAbilities = true
		end
		this.stats_mc.addAbility(false, 1, 77, "Test Ability", "0", "", "", false, false, true)
		this.stats_mc.addAbility(true, 3, 78, "Test Ability2", "0", "", "", false, false, true)
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

Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", CharacterSheet.PreUpdate)
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "characterSheetUpdateDone", CharacterSheet.Update)
Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "setTitle", function(ui, method)
	local this = ui:GetRoot()
	if this then
		this = this.stats_mc
		this.setMainStatsGroupName(this.GROUP_MAIN_ATTRIBUTES, Ext.GetTranslatedString("h15c226f2g54dag4f0eg80e6g121098c0766e", "Attributes"))
		this.setMainStatsGroupName(this.GROUP_MAIN_STATS, Ext.GetTranslatedString("h3d70a7c1g6f19g4f28gad0cgf0722eea9850", "Stats"))
		this.setMainStatsGroupName(this.GROUP_MAIN_EXPERIENCE, Ext.GetTranslatedString("he50fce4dg250cg4449g9f33g7706377086f6", "Experience"))
		this.setMainStatsGroupName(this.GROUP_MAIN_RESISTANCES, Ext.GetTranslatedString("h5a0c9b53gd3f7g4e01gb43ege4a255e1c8ee", "Resistances"))
	end
end)
Ext.RegisterUITypeCall(Data.UIType.statsPanel_c, "characterSheetUpdateDone", CharacterSheet.Update)