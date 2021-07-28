
---@class CharacterSheetWrapper:LeaderLibUIWrapper
local CharacterSheet = Classes.UIWrapper:CreateFromType(Data.UIType.characterSheet, {ControllerID = Data.UIType.statsPanel_c, IsControllerSupported = true})
local self = CharacterSheet

---@private
---@class SheetUpdateTargets
local updateTargetsDefaults = {
	Abilities = false,
	Civil = false,
	Talents = false,
	PrimaryStats = false,
	SecondaryStats = false,
	Tags = false,
}

---@type SheetUpdateTargets
local updateTargets = TableHelpers.Clone(updateTargetsDefaults)

---@private
---@param ui UIObject
function CharacterSheet.PreUpdate(ui, method, updateTalents, updateAbilities, updateCivil)
	---@type CharacterSheetMainTimeline
	local this = self.Root
	local secStat_array = this.secStat_array

	--Renaming "Experience" to "Total"
	for i=0,#secStat_array-1,7 do
		if not secStat_array[i] then
			local label = this.secStat_array[i + 2]
			if LocalizedText.Base.Experience:Equals(label) then
				secStat_array[i+2] = LocalizedText.Base.Total.Value
				break
			end
		end
	end

	-- for i=0,#this.primStat_array-1 do
	-- 	print("primStat_array",i,this.primStat_array[i])
	-- end

	updateTargets.Abilities = #this.ability_array > 0
	updateTargets.Civil = updateTargets.Abilities and this.ability_array[0] == true
	updateTargets.Talents = #this.talent_array > 0
	updateTargets.PrimaryStats = #this.primStat_array > 0
	updateTargets.SecondaryStats = #this.secStat_array > 0
	updateTargets.Tags = #this.tags_array > 0
end

local function getParamsValue(params, index, default)
	if params[index] ~= nil then
		return params[index]
	else
		return default
	end
end

---@private
---@param ui UIObject
function CharacterSheet.Update(ui, method, ...)
	PrintDebug("CharacterSheet.Update", method, ...)
	---@type CharacterSheetMainTimeline
	local this = self.Root
	if not this or not this.isExtended then
		return
	end

	--this.clearArray("talentArray")
	local player = CustomStatSystem:GetCharacter(ui, this)

	-- if method == "setAvailableCombatAbilityPoints" then
	-- 	availableCombatPoints[id] = amount
	-- 	setAvailablePoints[id] = true
	-- elseif method == "setAvailableCivilAbilityPoints" then
	-- 	availableCivilPoints[id] = amount
	-- 	setAvailablePoints[id] = true
	-- end

	---@type SheetUpdateTargets
	local targetsUpdated = TableHelpers.Clone(updateTargetsDefaults)
	local canRemove = GameHelpers.Client.IsGameMaster(ui, this)

	if updateTargets.PrimaryStats or updateTargets.SecondaryStats then
		--this.clearStats()
		for stat in SheetManager.Stats.GetVisible(player) do
			if not Vars.ControllerEnabled then
				if stat.IsPrimary then
					targetsUpdated.PrimaryStats = true
					this.stats_mc.addPrimaryStat(stat.ID, stat.DisplayName, stat.Value, stat.TooltipID, stat.CanAdd, canRemove, stat.IsCustom)
				else
					targetsUpdated.SecondaryStats = true
					if not stat.IsSpacing then
						this.stats_mc.addSecondaryStat(stat.ID, stat.DisplayName, stat.Value, stat.TooltipID, stat.Frame, stat.BoostValue, stat.CanAdd, canRemove, stat.IsCustom)
					else
						this.stats_mc.addSpacing(stat.ID, stat.Height)
					end
				end
			else
				--TODO
				--this.mainpanel_mc.stats_mc.addPrimaryStat(stat.ID, stat.DisplayName, stat.Value, stat.TooltipID, canAdd, canRemove, stat.IsCustom)
			end
		end
	end
	
	if updateTargets.Talents then
		--this.clearTalents()
		--local points = this.stats_mc.pointsWarn[3].avPoints
		local points = Client.Character.Points.Talent
		for talent in SheetManager.Talents.GetVisible(player) do
			local canAdd = false
			local canRemove = false
			targetsUpdated.Talents = true
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
		--this.stats_mc.addTalent("Test", 404, 1, true, false, true)
	end

	if updateTargets.Abilities then
		--this.clearAbilities()
		for ability in SheetManager.Abilities.GetVisible(player, updateTargets.Civil, this) do
			this.stats_mc.addAbility(ability.IsCivil, ability.GroupID, ability.ID, ability.DisplayName, ability.Value, ability.AddPointsTooltip, "", ability.CanAdd, ability.CanRemove, ability.IsCustom)
			targetsUpdated.Abilities = true
			targetsUpdated.Civil = updateTargets.Civil
		end
		--this.stats_mc.addAbility(false, 1, 77, "Test Ability", "0", "", "", false, false, true)
		--this.stats_mc.addAbility(true, 3, 78, "Test Ability2", "0", "", "", false, false, true)
	end

	if not Vars.ControllerEnabled then
		if targetsUpdated.Talents then
			this.stats_mc.talentHolder_mc.list.positionElements()
		end
		if targetsUpdated.Abilities then
			if targetsUpdated.Civil then
				this.stats_mc.civicAbilityHolder_mc.list.positionElements()
				this.stats_mc.recountAbilityPoints(true)
			else
				this.stats_mc.combatAbilityHolder_mc.list.positionElements()
				this.stats_mc.recountAbilityPoints(false)
			end
		end
	else
		if targetsUpdated.Talents then
			this.mainpanel_mc.stats_mc.talents_mc.updateDone()
		end
		if targetsUpdated.Abilities then
			if targetsUpdated.Civil then
				this.mainpanel_mc.stats_mc.civilAbilities_mc.updateDone()
			else
				this.mainpanel_mc.stats_mc.combatAbilities_mc.updateDone()
			end
		end
	end
end

Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", CharacterSheet.PreUpdate)
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "characterSheetUpdateDone", CharacterSheet.Update)
--Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "changeSecStatCustom", function(...) CharacterSheet:ValueChanged("SecondaryStat", ...))

Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "setTitle", function(ui, method)
	local this = CharacterSheet.Root
	if this and this.isExtended then
		local stats_mc = this.stats_mc
		stats_mc.setMainStatsGroupName(stats_mc.GROUP_MAIN_ATTRIBUTES, Ext.GetTranslatedString("h15c226f2g54dag4f0eg80e6g121098c0766e", "Attributes"))
		stats_mc.setMainStatsGroupName(stats_mc.GROUP_MAIN_STATS, Ext.GetTranslatedString("h3d70a7c1g6f19g4f28gad0cgf0722eea9850", "Stats"))
		stats_mc.setMainStatsGroupName(stats_mc.GROUP_MAIN_EXPERIENCE, Ext.GetTranslatedString("he50fce4dg250cg4449g9f33g7706377086f6", "Experience"))
		stats_mc.setMainStatsGroupName(stats_mc.GROUP_MAIN_RESISTANCES, Ext.GetTranslatedString("h5a0c9b53gd3f7g4e01gb43ege4a255e1c8ee", "Resistances"))
	end
end)
Ext.RegisterUITypeCall(Data.UIType.statsPanel_c, "characterSheetUpdateDone", CharacterSheet.Update)

if Vars.DebugMode then
	RegisterListener("BeforeLuaReset", function()
		local ui = CharacterSheet.Instance
		if ui then
			CharacterSheet.Instance:ExternalInterfaceCall("closeCharacterUIs")
			CharacterSheet.Instance:ExternalInterfaceCall("hideUI")
		end
	end)
	RegisterListener("LuaReset", function()
		local ui = CharacterSheet.Instance
		if ui then
			CharacterSheet.Instance:ExternalInterfaceCall("clearAbilities")
			CharacterSheet.Instance:ExternalInterfaceCall("clearTalents")
		end
	end)
end