local self = SheetManager
local isClient = Ext.IsClient()


---Gets custom sheet data from a string id.
---@param id string
---@param mod string|nil
---@param statType SheetEntryType|nil Optional stat type.
---@return SheetAbilityData|SheetStatData|SheetTalentData
function SheetManager:GetEntryByID(id, mod, statType)
	local targetTable = nil
	if statType then
		if statType == "Stat" or statType == "PrimaryStat" or statType == "SecondaryStat" then
			targetTable = self.Data.Stats
		elseif statType == "Ability" then
			targetTable = self.Data.Abilities
		elseif statType == "Talent" then
			targetTable = self.Data.Talents
		end
	end
	if targetTable then
		if mod then
			return targetTable[mod][id]
		else
			for modId,tbl in pairs(targetTable) do
				if tbl[id] then
					return tbl[id]
				end
			end
		end
	end
	return nil
end

---Gets custom sheet data from a generated id.
---@param generatedId integer
---@param statType SheetEntryType|nil Optional stat type.
---@return SheetAbilityData|SheetStatData|SheetTalentData
function SheetManager:GetEntryByGeneratedID(generatedId, statType)
	if statType then
		if statType == "Stat" or statType == "PrimaryStat" or statType == "SecondaryStat" then
			return self.Data.ID_MAP.Stats.Entries[generatedId]
		elseif statType == "Ability" then
			return self.Data.ID_MAP.Abilities.Entries[generatedId]
		elseif statType == "Talent" then
			return self.Data.ID_MAP.Talents.Entries[generatedId]
		end
	end
	for t,tbl in pairs(self.Data.ID_MAP) do
		for checkId,data in pairs(tbl.Entries) do
			if checkId == generatedId then
				return data
			end
		end
	end
	return nil
end

---@param stat SheetAbilityData|SheetStatData|SheetTalentData
---@param characterId UUID|NETID
function SheetManager:GetValueByEntry(stat, characterId)
	if not StringHelpers.IsNullOrWhitespace(stat.BoostAttribute) then
		local character = GameHelpers.GetCharacter(characterId)
		if character and character.Stats then
			local charValue = character.Stats.DynamicStats[2][stat.BoostAttribute]
			if charValue ~= nil then
				return charValue
			end
		end
	else
		return SheetManager.Save.GetEntryValue(characterId, stat)
	end
	if stat.StatType == "Talent" then
		return false
	end
	return 0
end

---Checks if an entry with the provided ID has the provided value.
---@param id string
---@param character EsvCharacter|EclCharacter|UUID|NETID
---@param value integer|boolean
---@param mod string|nil
---@param statType SheetEntryType|nil Optional stat type.
---@return boolean
function SheetManager:EntryHasValue(id, character, value, mod, statType)
	local targetTable = nil
	if statType then
		if statType == "Stat" or statType == "PrimaryStat" or statType == "SecondaryStat" then
			targetTable = self.Data.Stats
		elseif statType == "Ability" then
			targetTable = self.Data.Abilities
		elseif statType == "Talent" then
			targetTable = self.Data.Talents
		end
	end
	if targetTable then
		if mod then
			local entry = targetTable[mod][id]
			if entry then
				return self:GetValueByEntry(entry, character) == value
			end
		else
			for modId,tbl in pairs(targetTable) do
				if tbl[id] then
					if self:GetValueByEntry(tbl[id], character) == value then
						return true
					end
				end
			end
		end
	end
	return false
end

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