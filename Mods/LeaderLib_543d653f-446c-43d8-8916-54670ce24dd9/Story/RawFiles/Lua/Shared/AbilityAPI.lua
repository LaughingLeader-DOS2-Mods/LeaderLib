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
			print(i, arrayValue, offset)
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
local function addMissingAbilities(ui)
	---@type EclCharacter
	local character = nil
	if UI.ClientCharacter ~= nil then
		character = Ext.GetCharacter(UI.ClientCharacter)
	end
	local ability_array = ui:GetRoot().ability_array
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
local function toggleAbilityButtonVisibility(ui, hasPoints)
	local lvlBtnAbility_array = ui:GetRoot().lvlBtnAbility_array
	if lvlBtnAbility_array ~= nil then
		local i = #lvlBtnAbility_array
		for abilityName,data in pairs(missingAbilities) do
			if AbilityManager.RegisteredCount[abilityName] > 0 then
				local abilityID = Data.AbilityEnum[abilityName]
				lvlBtnAbility_array[i] = true -- hasPoints
				lvlBtnAbility_array[i+1] = data.Civil -- isCivilAbility
				lvlBtnAbility_array[i+2] = data.Group -- groupId
				lvlBtnAbility_array[i+3] = abilityID -- statId
				lvlBtnAbility_array[i+4] = true -- isVisible
				--PrintDebug(string.format("[LeaderLib:addMissingAbilities] Enabled point button for [%s] = (%s)", abilityID, abilityName))
				i = i + 5
			end
		end
	else
		Ext.PrintError("[LeaderLib:addMissingAbilities] Failed to finding starting index for ability_array!")
	end
end

---@param ui UIObject
function AbilityManager.OnCharacterSheetUpdating(ui, hasArrayValues, hasPoints)
	if hasArrayValues then
		addMissingAbilities(ui)
	end
	toggleAbilityButtonVisibility(ui, hasPoints)
end

end