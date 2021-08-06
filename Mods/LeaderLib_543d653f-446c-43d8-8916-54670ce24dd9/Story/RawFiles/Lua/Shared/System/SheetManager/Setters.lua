local self = SheetManager
local isClient = Ext.IsClient()

local function ErrorMessage(prefix, txt, ...)
	if #{...} > 0 then
		return prefix .. string.format(txt, ...)
	else
		return prefix .. txt
	end
end

if not isClient then
	
	local function GetPoints(uuid, t, isCivil)
		if t == "PrimaryStat" then
			return CharacterGetAttributePoints(uuid) or 0
		elseif t == "Ability" then
			if isCivil == true then
				return CharacterGetCivilAbilityPoints(uuid) or 0
			else
				return CharacterGetAbilityPoints(uuid) or 0
			end
		elseif t == "Talent" then
			return CharacterGetTalentPoints(uuid) or 0
		end
	end
---Changes available points by a value, such as adding -1 to attribute points.
---@param entry SheetStatData|SheetAbilityData|SheetTalentData
---@param character EsvCharacter|UUID|NETID
---@param amount integer
---@return boolean
function SheetManager:ModifyAvailablePointsForEntry(entry, character, amount)
	if amount == 0 then
		return true
	end
	local errorMessage = function(...) ErrorMessage("[SheetManager:ModifyAvailablePointsForEntry] ", ...) end

	assert(entry ~= nil and not StringHelpers.IsNullOrEmpty(entry.StatType), errorMessage("entry is isn't a SheetBaseData!"))
	assert(type(amount) == "number" and not GameHelpers.Math.IsNaN(amount), errorMessage("entry(%s) character(%s) amount(%s) - Amount is not a number!", entry.ID, character, amount))
	assert(character ~= nil, errorMessage("A valid character target is needed."))

	local entryType = entry.StatType
	local isCivil = entryType == "Ability" and entry.IsCivil
	local characterId = GameHelpers.GetCharacterID(character)

	if characterId then
		local points = GetPoints(characterId, entryType, isCivil)
		if entryType == "PrimaryStat" then
			CharacterAddAttributePoint(characterId, amount)
		elseif entryType == "Ability" then
			if isCivil == true then
				CharacterAddCivilAbilityPoint(characterId, amount)
			else
				CharacterAddAbilityPoint(characterId, amount)
			end
		elseif entryType == "Talent" then
			CharacterAddTalentPoint(characterId, amount)
		end
		assert(points ~= GetPoints(characterId, entryType, isCivil), errorMessage("Failed to alter character(%s)'s (%s) points.", characterId, (entryType and isCivil) and "CivilAbility" or entryType))
		return true
	end
	return false
end


end