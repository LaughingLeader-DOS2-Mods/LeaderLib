local combatAbilityGroupID = {
	[0] = "Weapons",
	[1] = "Defense",
	[2] = "Skills",
}

local civilAbilityGroupID = {
	[0] = "Personality",
	[1] = "Craftsmanship",
	[2] = "Nasty Deeds",
}

local missingAbilities = {
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
}

AbilityManager = {
	RegisteredAbilities = {},
	RegisteredCount = {}
}
AbilityManager.__index = AbilityManager

for name,v in pairs(missingAbilities) do
	AbilityManager.RegisteredCount[name] = 0
end

function AbilityManager.EnableAbility(abilityName, modID)
	if AbilityManager.RegisteredAbilities[abilityName] == nil then
		AbilityManager.RegisteredAbilities[abilityName] = {}
	end
	if AbilityManager.RegisteredAbilities[abilityName][modID] ~= true then
		AbilityManager.RegisteredAbilities[abilityName][modID] = true
		AbilityManager.RegisteredCount[abilityName] = (AbilityManager.RegisteredCount[abilityName] or 0) + 1
	end
end

if Ext.IsDeveloperMode() then
	for k,v in pairs(missingAbilities) do
		AbilityManager.EnableAbility(k, "7e737d2f-31d2-4751-963f-be6ccc59cd0c")
	end
end

function AbilityManager.DisableAbility(abilityName, modID)
	local data = AbilityManager.RegisteredAbilities[abilityName]
	if data ~= nil then
		if AbilityManager.RegisteredAbilities[abilityName][modID] ~= nil then
			AbilityManager.RegisteredAbilities[abilityName][modID] = nil
			AbilityManager.RegisteredCount[abilityName] = AbilityManager.RegisteredCount[abilityName] - 1
		end
		if AbilityManager.RegisteredCount[abilityName] <= 0 then
			AbilityManager.RegisteredAbilities[abilityName] = nil
			AbilityManager.RegisteredCount[abilityName] = 0
		end
	end
end

if Ext.IsClient() then
	local function GetArrayIndexStart(ui, array, offset)
		local total = #array
		if total > 0 then
			local i = 0
			while i < total do
				local arrayValue = array[i]
				if arrayValue == nil then
					return i
				end
				i = i + offset
			end
		end
		return -1
	end

	--[[ 
	ability_array Mapping:
	0 = isCivilAbility:boolean
	1 = groupId:number, 
	2 = statId:number
	3 = displayName:string
	4 = valueText:string
	5 = addTooltipText:string
	6 = removeTooltipText:string
	]]

	---@param ui UIObject
	local function addMissingAbilities(ui, main)
		---@type EclCharacter
		local character = Client:GetCharacter()
		local ability_array = main.ability_array
		if ability_array ~= nil then
			local i = #ability_array
			local total = 0
			for abilityName,data in pairs(missingAbilities) do
				if AbilityManager.RegisteredCount[abilityName] > 0 then
					local abilityID = Data.AbilityEnum[abilityName]
					ability_array[i] = data.Civil -- isCivilAbility
					ability_array[i+1] = data.Group -- groupId
					ability_array[i+2] = abilityID -- statId
					ability_array[i+3] = GameHelpers.GetAbilityName(abilityName) -- displayName
					if character ~= nil then
						ability_array[i+4] = character.Stats[abilityName] or 0 -- valueText
					else
						ability_array[i+4] = 0
					end
					ability_array[i+5] = LocalizedText.UI.AbilityPlusTooltip:ReplacePlaceholders(Ext.ExtraData.CombatAbilityLevelGrowth) -- addTooltipText
					ability_array[i+6] = "" -- removeTooltipText
					--PrintDebug(string.format("[LeaderLib:addMissingAbilities] Added ability [%s] = (%s)", abilityID, abilityName))
					i = i + 7
					total = total + 1
				end
			end
			PrintDebug(string.format("[LeaderLib:addMissingAbilities] Added abilities to the character sheet. i[%s] Total(%s)", i, total))
		else
			--Ext.PrintError("[LeaderLib:addMissingAbilities] Failed to finding starting index for ability_array!")
		end
	end

	--[[ 
	Array Mapping:
	0 - hasPoints:boolean
	1 = isCivilAbility:boolean
	2 = groupId:number, 
	3 = statId:number
	4 = isVisible:boolean
	]]
	---@param ui UIObject
	---@param hasPoints boolean
	local function toggleAbilityButtonVisibility(ui, main)
		local lvlBtnAbility_array = main.lvlBtnAbility_array
		if lvlBtnAbility_array ~= nil and lvlBtnAbility_array[0] ~= nil then
			local abilityPoints = main.stats_mc.pointsWarn[1].avPoints
			local civilPoints = main.stats_mc.pointsWarn[2].avPoints
			--print("abilityPoints", abilityPoints, "civilPoints", civilPoints)
			local i = #lvlBtnAbility_array
			for abilityName,data in pairs(missingAbilities) do
				if AbilityManager.RegisteredCount[abilityName] > 0 then
					local hasPoints = (data.Civil and civilPoints > 0) or (not data.Civil and abilityPoints > 0)
					local abilityID = Data.AbilityEnum[abilityName]
					lvlBtnAbility_array[i] = hasPoints -- hasPoints
					lvlBtnAbility_array[i+1] = data.Civil -- isCivilAbility
					lvlBtnAbility_array[i+2] = data.Group -- groupId
					lvlBtnAbility_array[i+3] = abilityID -- statId
					lvlBtnAbility_array[i+4] = hasPoints -- isVisible
					--PrintDebug(string.format("[LeaderLib:addMissingAbilities] Enabled point button for [%s] = (%s)", abilityID, abilityName))
					i = i + 5
					--main.stats_mc.setAbilityPlusVisible(data.Civil,data.Group,abilityID,hasPoints)
				end
			end
		else
			if Vars.DebugMode then
				Ext.PrintError("[LeaderLib:addMissingAbilities] Failed to finding starting index for ability_array!")
			end
		end
	end

	---@param ui UIObject
	function AbilityManager.OnCharacterSheetUpdating(ui, main, hasArrayValues)
		if hasArrayValues then
			addMissingAbilities(ui, main)
		end
		toggleAbilityButtonVisibility(ui, main)
	end
end