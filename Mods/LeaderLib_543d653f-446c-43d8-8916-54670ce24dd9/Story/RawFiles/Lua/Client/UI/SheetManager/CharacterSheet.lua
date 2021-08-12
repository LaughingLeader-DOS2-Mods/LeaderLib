
---@class CharacterSheetWrapper:LeaderLibUIWrapper
local CharacterSheet = Classes.UIWrapper:CreateFromType(Data.UIType.characterSheet, {ControllerID = Data.UIType.statsPanel_c, IsControllerSupported = true})
local self = CharacterSheet

SheetManager.UI.CharacterSheet = CharacterSheet

---@private
---@class SheetUpdateTargets
local updateTargetsDefaults = {
	Abilities = false,
	Civil = false,
	Talents = false,
	PrimaryStats = false,
	SecondaryStats = false,
	Tags = false,
	CustomStats = false,
}

---@type SheetUpdateTargets
local updateTargets = TableHelpers.Clone(updateTargetsDefaults)

---@param this stats_1
---@param listHolder string
---@param id number
---@param groupID integer|nil
---@return FlashMovieClip,FlashArray,integer
local function TryGetMovieClip(this, listHolder, id, groupID)
	if this == nil then
		this = CharacterSheet.Root
		if this then
			this = this.stats_mc
		end
	end
	if this and not StringHelpers.IsNullOrWhitespace(listHolder) then
		local holder = this[listHolder]
		if holder then
			local list = holder
			if holder.list then
				list = holder.list
			end
			if groupID ~= nil then
				for i=0,#list.content_array-1 do
					local group = list.content_array[i]
					if group and group.groupId == groupID then
						list = group.list
						break
					end
				end
			end
			if list and list.content_array then
				local mc = nil
				local i = 0
				while i < #list.content_array do
					local obj = list.content_array[i]
					if obj and obj.statID == id then
						mc = obj
						break
					end
					i = i + 1
				end
				return mc,list.content_array,i
			end
		end
	end
end

---@param this stats_1
---@param listHolder string
---@param id number
---@param groupID integer|nil
---@return FlashMovieClip,FlashArray,integer
local function TryGetMovieClip_Controller(this, listHolder, id, groupID)
	--TODO
	if this == nil then
		this = CharacterSheet.Root
		if this then
			this = this.mainpanel_mc.stats_mc
		end
	end
	return TryGetMovieClip(this, listHolder, id, groupID)
end

---@param this stats_1
---@param listHolder string
---@param id number
---@param groupID integer|nil
---@return FlashMovieClip,FlashArray,integer
CharacterSheet.TryGetMovieClip = function(this, listHolder, id, groupID)
	local func = TryGetMovieClip
	if Vars.ControllerEnabled then
		func = TryGetMovieClip_Controller
	end
	local result = {xpcall(func, debug.traceback, this, listHolder, id, groupID)}
	if not result[1] then
		fprint(LOGLEVEL.ERROR, "[CharacterSheet.TryGetMovieClip] Error:\n%s", result[2])
		return nil
	end
	table.remove(result, 1)
	return table.unpack(result)
end

---@param entry SheetAbilityData|SheetStatData
---@return FlashMovieClip,FlashArray,integer
CharacterSheet.TryGetEntryMovieClip = function(entry, this)
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
	return CharacterSheet.TryGetMovieClip(this, entry.ListHolder, entry.GeneratedID, entry.GroupID)
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

local function getParamsValue(params, index, default)
	if params[index] ~= nil then
		return params[index]
	else
		return default
	end
end

local targetsUpdated = {}

local function SortLists(this)
	if not Vars.ControllerEnabled then
		if targetsUpdated.PrimaryStats or targetsUpdated.SecondaryStats then
			this.stats_mc.mainStatsList.positionElements()
		end
		if targetsUpdated.Talents then
			this.stats_mc.talentHolder_mc.list.positionElements()
		end
		if targetsUpdated.Abilities then
			this.stats_mc.combatAbilityHolder_mc.list.positionElements()
			this.stats_mc.recountAbilityPoints(false)
		end
		if targetsUpdated.Civil then
			this.stats_mc.civicAbilityHolder_mc.list.positionElements()
			this.stats_mc.recountAbilityPoints(true)
		end
		if targetsUpdated.CustomStats then
			this.stats_mc.customStats_mc.positionElements()
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

local function GetArrayValues(this,baseChanges,modChanges)
	local time = Ext.MonotonicTime()
	local arr = this.primStat_array
	for i=0,#arr-1,4 do
		local id = arr[i]
		if id ~= nil then
			local targetTable = modChanges
			if SheetManager.Stats.Data.Builtin.ID[id] then
				targetTable = baseChanges
			end
			targetTable.Stats[id] = {
				DisplayName = arr[i+1],
				Value = arr[i+2],
				TooltipID = arr[i+3],
				Type = "PrimaryStat",
				CanAdd = false,
				CanRemove = false
			}
		end
	end
	arr = this.secStat_array
	for i=0,#arr-1,7 do
		--Not spacing
		if not arr[i] then
			local id = arr[i+4]
			if id ~= nil then
				local targetTable = modChanges
				if SheetManager.Stats.Data.Builtin.ID[id] then
					targetTable = baseChanges
				end
				targetTable.Stats[id] = {
					DisplayName = arr[i+2],
					Value = arr[i+3],
					StatType = arr[i+1],
					Frame = arr[i+5],
					BoostValue = arr[i+6],
					Type = "SecondaryStat",
					CanAdd = false,
					CanRemove = false
				}
			end
		end
	end
	arr = this.talent_array
	for i=0,#arr-1,3 do
		local id = arr[i+1]
		if id ~= nil then
			local targetTable = modChanges
			if Data.Talents[id] then
				targetTable = baseChanges
			end
			targetTable.Talents[id] = {
				DisplayName = arr[i],
				State = arr[i+2],
				CanAdd = false,
				CanRemove = false
			}
		end
	end
	arr = this.ability_array
	for i=0,#arr-1,7 do
		local id = arr[i+2]
		if id ~= nil then
			local targetTable = modChanges
			if Data.Ability[id] then
				targetTable = baseChanges
			end
			local isCivil = arr[i] == true
			targetTable.Abilities[id] = {
				IsCivil = isCivil,
				DisplayName = arr[i+3],
				Value = arr[i+4],
				GroupID = arr[i+1],
				AddPointsTooltip = arr[i+5],
				RemovePointsTooltip = arr[i+6],
				CanAdd = false,
				CanRemove = false
			}
		end
	end
	arr = this.lvlBtnStat_array
	for i=0,#arr-1,3 do
		local canAddPoints = arr[i]
		local id = arr[i+1]
		local isVisible = arr[i+2]
		local entry = modChanges[id] or baseChanges[id]
		if entry then
			if canAddPoints then
				entry.CanAdd = isVisible
			else
				entry.CanRemove = isVisible
			end
		end
	end
	arr = this.lvlBtnSecStat_array
	local hasButtons = arr[0]
	for i=1,#arr-1,4 do
		local id = arr[i]
		local entry = modChanges[id] or baseChanges[id]
		if entry then
			if hasButtons then
				local showBothButtons = arr[i+1]
				entry.CanRemove = arr[i+2]
				entry.CanAdd = arr[i+3]
			else
				entry.CanRemove = false
				entry.CanAdd = false
			end
		end
	end
	arr = this.lvlBtnAbility_array
	for i=0,#arr-1,5 do
		local canAddPoints = arr[i]
		local id = arr[i+3]
		local isVisible = arr[i+4]
		local entry = modChanges[id] or baseChanges[id]
		if entry then
			if canAddPoints then
				entry.CanAdd = isVisible
			else
				entry.CanRemove = isVisible
			end
		end
	end
	arr = this.lvlBtnTalent_array
	for i=0,#arr-1,3 do
		local canAddPoints = arr[i]
		local id = arr[i+1]
		local isVisible = arr[i+2]
		local entry = modChanges[id] or baseChanges[id]
		if entry then
			if canAddPoints then
				entry.CanAdd = isVisible
			else
				entry.CanRemove = isVisible
			end
		end
	end
	fprint(LOGLEVEL.DEFAULT, "Took (%s)ms to parse character sheet arrays.", Ext.MonotonicTime() - time)
end

local function ParseArrayValues(this, skipSort)

	local modChanges = {Stats = {},Abilities = {},Talents = {}}
	local baseChanges = {Stats = {},Abilities = {},Talents = {}}

	pcall(GetArrayValues, this, baseChanges, modChanges)

	print("baseChanges",Lib.serpent.dump(baseChanges))
	print("modChanges",Lib.serpent.dump(modChanges))

	for id,entry in pairs(modChanges.Stats) do
		if entry.Type == "PrimaryStat" then
			targetsUpdated.PrimaryStats = true
			if not Vars.ControllerEnabled then
				this.stats_mc.addPrimaryStat(id, entry.DisplayName, entry.Value, entry.TooltipID, entry.CanAdd, entry.CanRemove)
			end
		else
			targetsUpdated.SecondaryStats = true
			if not Vars.ControllerEnabled then
				this.stats_mc.addSecondaryStat(entry.StatType, entry.DisplayName, entry.Value, id, entry.Frame or 0, entry.BoostValue, entry.CanAdd, entry.CanRemove)
			end
		end
	end

	for id,entry in pairs(modChanges.Talents) do
		targetsUpdated.Talents = true
		if not Vars.ControllerEnabled then
			this.stats_mc.addTalent(entry.DisplayName, id, entry.State, entry.CanAdd, entry.CanRemove)
		else
			this.mainpanel_mc.stats_mc.talents_mc.addTalent(entry.DisplayName, id, entry.State, entry.CanAdd, entry.CanRemove)
		end
	end

	for id,entry in pairs(modChanges.Abilities) do
		if entry.IsCivil then
			targetsUpdated.Civil = true
		else
			targetsUpdated.Abilities = true
		end
		if not Vars.ControllerEnabled then
			this.stats_mc.addAbility(entry.IsCivil, entry.GroupID, id, entry.DisplayName, entry.Value, entry.AddPointsTooltip, entry.RemovePointsTooltip, entry.CanAdd, entry.CanRemove)
		end
	end

	if skipSort ~= true then
		SortLists(this)
	end
end

---@private
---@param ui UIObject
function CharacterSheet.Update(ui, method, updateTalents, updateAbilities, updateCivil)
	updating = true
	---@type CharacterSheetMainTimeline
	local this = self.Root

	if not this or this.isExtended ~= true then
		return
	end

	--local currentPanelType = panelToTabType[this.stats_mc.currentOpenPanel]
	for method,b in pairs(requestedClear) do
		pcall(this[method], true)
		-- if clearPanelMethods[currentPanelType] ~= method then
		-- 	pcall(this[method], true)
		-- end
	end

	local player = CustomStatSystem:GetCharacter(ui, this)

	this.justUpdated = true

	updateTargets.Abilities = #this.ability_array > 0
	updateTargets.Civil = updateTargets.Abilities and this.ability_array[0] == true
	updateTargets.Talents = #this.talent_array > 0
	updateTargets.PrimaryStats = #this.primStat_array > 0
	updateTargets.SecondaryStats = #this.secStat_array > 0
	updateTargets.Tags = #this.tags_array > 0
	updateTargets.CustomStats = #this.customStats_array > 0

	---@type SheetUpdateTargets
	targetsUpdated = TableHelpers.Clone(updateTargetsDefaults)
	local isGM = GameHelpers.Client.IsGameMaster(ui, this)

	if updateTargets.PrimaryStats or updateTargets.SecondaryStats then
		--this.clearStats()
		for stat in SheetManager.Stats.GetVisible(player, false, isGM) do
			-- local arrayData = modChanges.Stats[stat.ID]
			-- if arrayData then
			-- 	if arrayData.Value ~= stat.Value then
			-- 		fprint(LOGLEVEL.WARNING, "Stat value differs from the array value Lua(%s) <=> Array(%s)", stat.Value, arrayData.Value)
			-- 	end
			-- end
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
		for id,entry in pairs(modChanges.Talents) do
			if not Vars.ControllerEnabled then
				this.stats_mc.addTalent(entry.DisplayName, id, entry.State, entry.CanAdd, entry.CanRemove)
			else
				this.mainpanel_mc.stats_mc.talents_mc.addTalent(entry.DisplayName, id, entry.State, entry.CanAdd, entry.CanRemove)
			end
		end
		--this.stats_mc.addTalent("Test", 404, 1, true, false, true)
	end

	if updateTargets.Abilities then
		--this.clearAbilities()
		for ability in SheetManager.Abilities.GetVisible(player, updateTargets.Civil, false, isGM) do
			this.stats_mc.addAbility(ability.IsCivil, ability.GroupID, ability.ID, ability.DisplayName, ability.Value, ability.AddPointsTooltip, ability.RemovePointsTooltip, ability.CanAdd, ability.CanRemove, ability.IsCustom)
			if ability.IsCivil then
				targetsUpdated.Civil = true
			else
				targetsUpdated.Abilities = true
			end
		end
		--this.stats_mc.addAbility(false, 1, 77, "Test Ability", "0", "", "", false, false, true)
		--this.stats_mc.addAbility(true, 3, 78, "Test Ability2", "0", "", "", false, false, true)
	end

	if updateTargets.CustomStats or this.stats_mc.currentOpenPanel == 8 then
		CustomStatSystem.Update(ui, method, this)
		targetsUpdated.CustomStats = true
	end
end

---@private
---@param ui UIObject
function CharacterSheet.PostUpdate(ui, method)
	---@type CharacterSheetMainTimeline
	local this = self.Root
	PrintDebug("CharacterSheet.Update", method, Lib.inspect(updateTargets))
	if not this or this.isExtended ~= true then
		return
	end

	local player = CustomStatSystem:GetCharacter(ui, this)

	SortLists(this)

	this.stats_mc.resetScrollBarsPositions()
	this.stats_mc.resetListPositions()
	this.stats_mc.recheckScrollbarVisibility()
end

---@private
function CharacterSheet.UpdateComplete(ui, method)
	---@type CharacterSheetMainTimeline
	local this = self.Root
	PrintDebug("CharacterSheet.Update", method, Lib.inspect(updateTargets))
	if not this or this.isExtended ~= true then
		return
	end

	ParseArrayValues(this, false)

	this.justUpdated = false
	targetsUpdated = {}
	updating = false
	requestedClear = {}
	this.clearArray("update")
end

Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", CharacterSheet.Update, "Before")
Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", CharacterSheet.PostUpdate, "After")
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "characterSheetUpdateDone", CharacterSheet.UpdateComplete)
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

--local mc = sheet.stats_mc.resistanceStatList.content_array[8]; print(mc.statID, mc.texts_mc.label_txt.htmlText)
--for i=5,9 do local mc = sheet.stats_mc.resistanceStatList.content_array[i]; print(mc.statID, mc.texts_mc.label_txt.htmlText) end

Ext.RegisterUITypeCall(Data.UIType.characterSheet, "entryAdded", function(ui, call, isCustom, statID, listProperty, groupID)
	--print(call, isCustom, statID, listProperty)
	if isCustom then
		local stat = SheetManager:GetStatByGeneratedID(statID)
		if stat then
			stat.ListHolder = listProperty
			-- local this = CharacterSheet.Root.stats_mc
			-- local mc,arr,index = TryGetEntryMovieClip(stat, this)
			-- if mc then
			-- 	mc.customID = stat.ID
			-- 	mc.customMod = stat.Mod
			-- end
		end
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
		local points = SheetManager:GetBuiltinAvailablePointsForType(entry.StatType, character, entry.IsCivil)
		local defaultCanAdd = (entry.UsePoints and points > 0) or GameHelpers.Client.IsGameMaster(CharacterSheet.Instance, this)

		this = this.stats_mc
		local mc,arr,index = CharacterSheet.TryGetEntryMovieClip(entry, this)
		--fprint(LOGLEVEL.TRACE, "Entry[%s](%s) statID(%s) ListHolder(%s) arr(%s) mc(%s)", entry.StatType, id, entry.GeneratedID, entry.ListHolder, arr, mc)
		if arr and mc then
			local plusVisible = SheetManager:GetIsPlusVisible(entry, character, defaultCanAdd, value)
			local minusVisible = SheetManager:GetIsMinusVisible(entry, character, defaultCanAdd, value)

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
				local name = string.format(SheetManager.Talents.GetTalentStateFontFormat(talentState), entry:GetDisplayName())
				mc.label_txt.htmlText = name
				mc.label = mc.label_txt.text
				mc.talentState = talentState
				mc.bullet_mc.gotoAndStop(this.getTalentStateFrame(talentState))

				if not Vars.ControllerEnabled then
					this.talentHolder_mc.list.positionElements()
				else
					this.mainpanel_mc.stats_mc.talents_mc.updateDone()
				end
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