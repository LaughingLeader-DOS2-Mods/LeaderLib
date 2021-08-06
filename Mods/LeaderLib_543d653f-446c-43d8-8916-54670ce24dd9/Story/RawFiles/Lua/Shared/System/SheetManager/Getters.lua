local self = SheetManager
local isClient = Ext.IsClient()

---@alias SheetEntryType string |"PrimaryStat"|"Ability"|"CivilAbility"|"Talent"

---Gets the builtin available points for a stat type, such as PrimaryStat (attribute points), Ability (ability points), and Talent (talent points).
---@param entryType SheetEntryType
---@param character EsvCharacter|EclCharacter|UUID|NETID
---@param isCivil boolean|nil
---@return integer
function SheetManager:GetBuiltinAvailablePointsForType(entryType, character, isCivil)
	if entryType == "CivilAbility" then
		entryType = "Ability"
		isCivil = true
	end
	if isClient then
		if entryType == "PrimaryStat" then
			return Client.Character.Points.Attribute
		elseif entryType == "Ability" then
			if isCivil == true then
				return Client.Character.Points.Civil
			else
				return Client.Character.Points.Ability
			end
		elseif entryType == "Talent" then
			return Client.Character.Points.Talent
		end
	elseif character then
		local characterId = GameHelpers.GetCharacterID(character)
		if characterId then
			if entryType == "PrimaryStat" then
				return CharacterGetAttributePoints(characterId) or 0
			elseif entryType == "Ability" then
				if isCivil == true then
					return CharacterGetCivilAbilityPoints(characterId) or 0
				else
					return CharacterGetAbilityPoints(characterId) or 0
				end
			elseif entryType == "Talent" then
				return CharacterGetTalentPoints(characterId) or 0
			end
		end
	end

	return 0
end

---Gets the builtin available points for a stat.
---@param entry SheetStatData|SheetAbilityData|SheetTalentData
---@param character EsvCharacter|EclCharacter|UUID|NETID
---@return integer
function SheetManager:GetBuiltinAvailablePointsForEntry(entry, character)
	local entryType = entry.StatType
	local isCivil = entryType == "Ability" and entry.IsCivil

	if isClient then
		if entryType == "PrimaryStat" then
			return Client.Character.Points.Attribute
		elseif entryType == "Ability" then
			if isCivil == true then
				return Client.Character.Points.Civil
			else
				return Client.Character.Points.Ability
			end
		elseif entryType == "Talent" then
			return Client.Character.Points.Talent
		end
	elseif character then
		local characterId = GameHelpers.GetCharacterID(character)
		if characterId then
			if entryType == "PrimaryStat" then
				return CharacterGetAttributePoints(characterId) or 0
			elseif entryType == "Ability" then
				if isCivil == true then
					return CharacterGetCivilAbilityPoints(characterId) or 0
				else
					return CharacterGetAbilityPoints(characterId) or 0
				end
			elseif entryType == "Talent" then
				return CharacterGetTalentPoints(characterId) or 0
			end
		end
	end

	return 0
end