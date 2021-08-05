
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

---@param entry SheetAbilityData|SheetStatData
local function TryGetEntryMovieClip(entry, this)
	if StringHelpers.IsNullOrWhitespace(entry.ListHolder) then
		if entry.StatType == "PrimaryStat" then
			entry.ListHolder = "primaryStatList"
		elseif entry.StatType == "SecondaryStat" then
			if entry.SecondaryStatType == SheetManager.Stats.Data.SecondaryStatType.Info then
				entry.ListHolder = "infoStatList"
			elseif entry.SecondaryStatType == SheetManager.Stats.Data.SecondaryStatType.Stat then
				entry.ListHolder = "secondaryStatList"
			elseif entry.SecondaryStatType == SheetManager.Stats.Data.SecondaryStatType.Resistance then
				entry.ListHolder = "resistanceStatList"
			elseif entry.SecondaryStatType == SheetManager.Stats.Data.SecondaryStatType.Experience then
				entry.ListHolder = "expStatList"
			end
		elseif entry.StatType == "Ability" then
			if entry.IsCivil then
				entry.ListHolder = "civicAbilityHolder_mc"
			else
				entry.ListHolder = "combatAbilityHolder_mc"
			end
		elseif entry.StatType == "Talent" then
			entry.ListHolder = "talentHolder_mc"
		end
	end

	if not StringHelpers.IsNullOrWhitespace(entry.ListHolder) then
		local holder = this[entry.ListHolder]
		if holder then
			local list = holder
			if holder.list then
				list = holder.list
			end
			if entry.StatType == "Ability" then
				for i=0,#list.content_array-1 do
					local group = list.content_array[i]
					if group and group.groupId == entry.GroupID then
						list = group.list
						break
					end
				end
			end
			if list and list.content_array then
				local mc = nil
				for i=0,#list.content_array-1 do
					local obj = list.content_array[i]
					if obj and obj.statID == entry.GeneratedID then
						mc = obj
						break
					end
				end
				return list.content_array,mc
			end
		end
	end
end

local function debugExportStatArrays(this)
	local saveData = {
		Default = {
			Primary={},
			Secondary={},
			Spacing={},
			Order={}
		}
	}
	for i=0,#this.primStat_array-1,4 do
		saveData.Default.Primary[this.primStat_array[i+1]] = {
			StatID = this.primStat_array[i],
			DisplayName = this.primStat_array[i+1],
			TooltipID = this.primStat_array[i+3]
		}
		table.insert(saveData.Default.Order, this.primStat_array[i+1])
	end
	for i=0,#this.secStat_array-1,7 do
		if this.secStat_array[i] then
			table.insert(saveData.Default.Spacing, {
				Type = "Spacing",
				StatType = this.secStat_array[i+1],
				Height = this.secStat_array[i+2]
			})
			table.insert(saveData.Default.Order, "Spacing")
		else
			saveData.Default.Secondary[this.secStat_array[i+2]] = {
				Type = "SecondaryStat",
				StatType = this.secStat_array[i+1],
				StatID = this.secStat_array[i+4],
				DisplayName = this.secStat_array[i+2],
				Frame = this.secStat_array[i+5]
			}
			table.insert(saveData.Default.Order, this.secStat_array[i+2])
		end
	end
	Ext.SaveFile("StatsArrayContents.lua", Lib.serpent.raw(saveData, {indent = '\t', sortkeys = false, comment = false}))
end

--local triggers = {}; for _,uuid in pairs(Ext.GetAllTriggers()) do local trigger = Ext.GetTrigger(uuid); triggers[#triggers+1] = trigger; end; Ext.SaveFile("Triggers.json", inspect(triggers))
--local triggers = {}; for _,uuid in pairs(Ext.GetAllTriggers()) do local trigger = Ext.GetTrigger(uuid); triggers[#triggers+1] = trigger; end; Ext.SaveFile("Triggers.lua", Mods.LeaderLib.Lib.serpent.block(triggers))

local updating = false
local requestedClear = {}

local panelToTabType = {
	[0] = "Stats",
	[1] = "Abilities",
	[2] = "Abilities",
	[3] = "Talents",
	[4] = "Tags",
	[5] = "Inventory",
	[6] = "Skills",
	[7] = "Visuals",
	[8] = "CustomStats",
}

local clearPanelMethods = {
	Stats = "clearStats",
	Abilities = "clearAbilities",
	Talents = "clearTalents",
}

local function clearRequested(ui, method, force)
	if not updating and force ~= true then
		requestedClear[method] = true
	end
end

Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "clearStats", clearRequested)
Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "clearAbilities", clearRequested)
Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "clearTalents", clearRequested)
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "selectedTab", function(ui, call, panel)
	
end, "Before")

---@private
---@param ui UIObject
function CharacterSheet.PreUpdate(ui, method, updateTalents, updateAbilities, updateCivil)
	updating = true
	---@type CharacterSheetMainTimeline
	local this = self.Root
	local secStat_array = this.secStat_array

	print(Lib.serpent.block(requestedClear))

	--local currentPanelType = panelToTabType[this.stats_mc.currentOpenPanel]
	for method,b in pairs(requestedClear) do
		pcall(this[method], true)
		-- if clearPanelMethods[currentPanelType] ~= method then
		-- 	pcall(this[method], true)
		-- end
	end

	this.justUpdated = true

	--Renaming "Experience" to "Total"
	-- for i=0,#secStat_array-1,7 do
	-- 	if not secStat_array[i] then
	-- 		local label = this.secStat_array[i + 2]
	-- 		if LocalizedText.Base.Experience:Equals(label) then
	-- 			secStat_array[i+2] = LocalizedText.Base.Total.Value
	-- 			break
	-- 		end
	-- 	end
	-- end

	-- for i=0,#this.primStat_array-1 do
	-- 	print("primStat_array",i,this.primStat_array[i])
	-- end

	updateTargets.Abilities = #this.ability_array > 0
	updateTargets.Civil = updateTargets.Abilities and this.ability_array[0] == true
	updateTargets.Talents = #this.talent_array > 0
	updateTargets.PrimaryStats = #this.primStat_array > 0
	updateTargets.SecondaryStats = #this.secStat_array > 0
	updateTargets.Tags = #this.tags_array > 0

	-- if updateTargets.PrimaryStats or updateTargets.SecondaryStats then
	-- 	this.clearStats(true)
	-- end
	-- if updateTargets.Abilities then
	-- 	this.clearAbilities(true)
	-- end
	-- if updateTargets.Talents then
	-- 	this.clearTalents(true)
	-- end

	CharacterSheet.Update(ui, method)
end

local function getParamsValue(params, index, default)
	if params[index] ~= nil then
		return params[index]
	else
		return default
	end
end

local targetsUpdated = {}

---@private
---@param ui UIObject
function CharacterSheet.Update(ui, method)
	---@type CharacterSheetMainTimeline
	local this = self.Root
	PrintDebug("CharacterSheet.Update", method, Lib.inspect(updateTargets))
	if not this or this.isExtended ~= true then
		return
	end

	local player = CustomStatSystem:GetCharacter(ui, this)

	-- if method == "setAvailableCombatAbilityPoints" then
	-- 	availableCombatPoints[id] = amount
	-- 	setAvailablePoints[id] = true
	-- elseif method == "setAvailableCivilAbilityPoints" then
	-- 	availableCivilPoints[id] = amount
	-- 	setAvailablePoints[id] = true
	-- end

	---@type SheetUpdateTargets
	targetsUpdated = TableHelpers.Clone(updateTargetsDefaults)
	local isGM = GameHelpers.Client.IsGameMaster(ui, this)

	if updateTargets.PrimaryStats or updateTargets.SecondaryStats then
		--this.clearStats()
		for stat in SheetManager.Stats.GetVisible(player, false, isGM) do
			print(stat.DisplayName, stat.Frame)
			if not Vars.ControllerEnabled then
				if stat.StatType == SheetManager.Stats.Data.StatType.PrimaryStat then
					targetsUpdated.PrimaryStats = true
					this.stats_mc.addPrimaryStat(stat.ID, stat.DisplayName, stat.Value, stat.ID, stat.CanAdd, stat.CanRemove, stat.IsCustom, stat.Frame, stat.IconClipName)
					if not StringHelpers.IsNullOrWhitespace(stat.IconClipName) then
						ui:SetCustomIcon(stat.IconDrawCallName, stat.Icon, stat.IconWidth, stat.IconHeight)
					end
				else
					targetsUpdated.SecondaryStats = true
					if stat.StatType == SheetManager.Stats.Data.StatType.Spacing then
						this.stats_mc.addSpacing(stat.ID, stat.SpacingHeight)
					else
						this.stats_mc.addSecondaryStat(stat.SecondaryStatTypeInteger, stat.DisplayName, stat.Value, stat.ID, stat.Frame, stat.BoostValue, stat.CanAdd, stat.CanRemove, stat.IsCustom, stat.IconClipName or "")
						if not StringHelpers.IsNullOrWhitespace(stat.IconClipName) then
							ui:SetCustomIcon(stat.IconDrawCallName, stat.Icon, stat.IconWidth, stat.IconHeight)
						end
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
		for talent in SheetManager.Talents.GetVisible(player, false, isGM) do
			targetsUpdated.Talents = true
			if not Vars.ControllerEnabled then
				this.stats_mc.addTalent(talent.DisplayName, talent.ID, talent.State, talent.CanAdd, talent.CanRemove, talent.IsCustom)
			else
				this.mainpanel_mc.stats_mc.talents_mc.addTalent(talent.DisplayName, talent.ID, talent.State, talent.CanAdd, talent.CanRemove, talent.IsCustom)
			end
		end
		--this.stats_mc.addTalent("Test", 404, 1, true, false, true)
	end

	if updateTargets.Abilities then
		--this.clearAbilities()
		for ability in SheetManager.Abilities.GetVisible(player, updateTargets.Civil, false, isGM) do
			this.stats_mc.addAbility(ability.IsCivil, ability.GroupID, ability.ID, ability.DisplayName, ability.Value, ability.AddPointsTooltip, ability.RemovePointsTooltip, ability.CanAdd, ability.CanRemove, ability.IsCustom)
			targetsUpdated.Abilities = true
			targetsUpdated.Civil = updateTargets.Civil
		end
		--this.stats_mc.addAbility(false, 1, 77, "Test Ability", "0", "", "", false, false, true)
		--this.stats_mc.addAbility(true, 3, 78, "Test Ability2", "0", "", "", false, false, true)
	end

	if not Vars.ControllerEnabled then
		if targetsUpdated.PrimaryStats or targetsUpdated.SecondaryStats then
			this.stats_mc.mainStatsList.positionElements()
		end
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

	this.stats_mc.resetScrollBarsPositions()
	this.stats_mc.resetListPositions()
	this.stats_mc.recheckScrollbarVisibility()
end

function CharacterSheet.PostUpdate(ui, method)
	---@type CharacterSheetMainTimeline
	local this = self.Root
	PrintDebug("CharacterSheet.Update", method, Lib.inspect(updateTargets))
	if not this or this.isExtended ~= true then
		return
	end

	this.justUpdated = false
	targetsUpdated = {}
	updating = false
	requestedClear = {}
	this.clearArray("update")
end

Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", CharacterSheet.PreUpdate)
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "characterSheetUpdateDone", CharacterSheet.PostUpdate)
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

Ext.RegisterUITypeCall(Data.UIType.characterSheet, "entryAdded", function(ui, call, isCustom, statID, listProperty)
	--print(call, isCustom, statID, listProperty)
	if isCustom then
		local stat = SheetManager:GetStatByGeneratedID(statID)
		if stat then
			stat.ListHolder = listProperty
			local arr,mc = TryGetEntryMovieClip(stat, ui:GetRoot())
			if mc then
				mc.customID = stat.ID
				mc.customMod = stat.Mod
			end
		end
	else
		-- local this = CharacterSheet.Root
		-- local arr = this.stats_mc[listProperty].list.content_array
		-- for i=0,#arr-1 do
		-- 	local mc = arr[i]
		-- 	if mc.statID == statID then
		-- 		mc.visible = true
		-- 		break
		-- 	end
		-- end
	end
end)

local function getTalentStateFrame(talentState)
	if talentState == 0 then
		return 2
	elseif talentState == 1 then
		return 3
	elseif talentState == 2 then
		return 1
	elseif talentState == 3 then
		return 1
	else
		return 1
	end
end

SheetManager:RegisterEntryChangedListener("All", function(id, entry, character, lastValue, value, isClientSide)
	---@type CharacterSheetMainTimeline
	local this = CharacterSheet.Root
	if this and this.isExtended then
		local isGM = GameHelpers.Client.IsGameMaster(CharacterSheet.Instance, this)

		this = this.stats_mc
		local content_array,mc = TryGetEntryMovieClip(entry, this)
		fprint(LOGLEVEL.TRACE, "Entry[%s](%s) statID(%s) ListHolder(%s) content_array(%s) mc(%s)", entry.StatType, id, entry.GeneratedID, entry.ListHolder, content_array, mc)
		if content_array and mc then
			local plusVisible = SheetManager:GetIsPlusVisible(entry, character, isGM, value)
			local minusVisible = SheetManager:GetIsMinusVisible(entry, character, isGM, value)
			if entry.StatType == "Ability" then
				mc.texts_mc.plus_mc.visible = plusVisible
				mc.texts_mc.minus_mc.visible = minusVisible
			else
				mc.plus_mc.visible = plusVisible
				mc.minus_mc.visible = minusVisible
			end

			if entry.StatType == "PrimaryStat" then
				mc.text_txt.htmlText = string.format("%i", value)
				mc.statBasePoints = value
				-- mc.statPoints = 0
			elseif entry.StatType == "SecondaryStat" then
				mc.boostValue = value
				mc.text_txt.htmlText = string.format("%i", value)
				mc.statBasePoints = value
				-- mc.statPoints = 0
			elseif entry.StatType == "Ability" then
				mc.am = value
				mc.texts_mc.text_txt.htmlText = string.format("%i", value)
				mc.statBasePoints = value
				-- mc.statPoints = 0
			elseif entry.StatType == "Talent" then
				local talentState = entry:GetState(character)
				local name = SheetManager.Talents.GetTalentDisplayName(entry.ID, talentState)
				mc.label_txt.htmlText = name
				mc.label = mc.label_txt.text
				mc.talentState = talentState
				mc.bullet_mc.gotoAndStop(this.getTalentStateFrame(talentState))
			end
		end
	end
end)

if Vars.DebugMode then
	RegisterListener("BeforeLuaReset", function()
		local ui = CharacterSheet.Instance
		if ui then
			CharacterSheet.Instance:ExternalInterfaceCall("closeCharacterUIs")
			CharacterSheet.Instance:ExternalInterfaceCall("hideUI")
		end
	end)
	RegisterListener("LuaReset", function()
		local this = CharacterSheet.Root
		if this then
			this.clearAbilities(true)
			this.clearTalents(true)
			this.clearStats(true)
		end
	end)
end