local self = SheetManager
local isClient = Ext.IsClient()

local function ErrorMessage(prefix, txt, ...)
	if #{...} > 0 then
		return prefix .. string.format(txt, ...)
	else
		return prefix .. txt
	end
end


---@param stat SheetAbilityData|SheetStatData|SheetTalentData
---@param characterId UUID|NETID
---@param value integer|boolean
---@param skipListenerInvoke boolean|nil If true, Listeners.OnEntryChanged invoking is skipped.
---@param skipSync boolean|nil If on the client and this is true, the value change won't be sent to the server.
function SheetManager:SetEntryValue(stat, characterId, value, skipListenerInvoke, skipSync)
	local last = stat:GetValue(characterId)
	if last ~= value then
		---@type EsvCharacter|EclCharacter
		local character = characterId
		if type(characterId) ~= "userdata" then
			character = Ext.GetCharacter(characterId)
		else
			characterId = GameHelpers.GetCharacterID(characterId)
		end
		if not StringHelpers.IsNullOrWhitespace(stat.BoostAttribute) then
			if character and character.Stats then
				if not isClient then
					if stat.StatType == "Talent" then
						NRD_CharacterSetPermanentBoostTalent(characterId, string.gsub(stat.BoostAttribute, "TALENT_", ""), value)
						CharacterAddAttribute(characterId, "Dummy", 0)
						--character.Stats.DynamicStats[2][stat.BoostAttribute] = value
					else
						NRD_CharacterSetPermanentBoostInt(characterId, stat.BoostAttribute, value)
						--character.Stats.DynamicStats[2][stat.BoostAttribute] = value
					end
				else
					character.Stats.DynamicStats[2][stat.BoostAttribute] = value
				end
				local success = character.Stats.DynamicStats[2][stat.BoostAttribute] == value
				fprint(LOGLEVEL.DEFAULT, "[%s][SetEntryValue:%s] BoostAttribute(%s) Changed(%s) Current(%s) => Desired(%s)", isClient and "CLIENT" or "SERVER", stat.ID, stat.BoostAttribute, success, character.Stats.DynamicStats[2][stat.BoostAttribute], value)
			else
				fprint(LOGLEVEL.ERROR, "[%s][SetEntryValue:%s] Failed to get character from id (%s)", isClient and "CLIENT" or "SERVER", stat.ID, characterId)
			end
		else
			SheetManager.Save.SetEntryValue(characterId, stat, value)
		end
		if not skipListenerInvoke then
			for listener in self:GetListenerIterator(self.Listeners.OnEntryChanged[stat.ID], self.Listeners.OnEntryChanged.All) do
				local b,err = xpcall(listener, debug.traceback, stat.ID, stat, character, last, value, isClient)
				if not b then
					fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:OnStatPointAdded] Error calling OnAvailablePointsChanged listener for stat (%s):\n%s", stat.ID, err)
				end
			end
			if not isClient then
				if stat.StatType == "Ability" then
					Osi.CharacterBaseAbilityChanged(character.MyGuid, stat.ID, last, value)
				elseif stat.StatType == "Talent" then
					if value then
						Osi.CharacterUnlockedTalent(character.MyGuid, stat.ID)
					else
						Osi.CharacterLockedTalent(character.MyGuid, stat.ID)
					end
				end
			end
		end
		if not skipSync and isClient then
			--Server-side updating
			self:RequestValueChange(stat, characterId, value)
		end
	end
	if not skipSync and not isClient then
		Ext.BroadcastMessage("LeaderLib_SheetManager_EntryValueChanged", Ext.JsonStringify({
			ID = stat.ID,
			Mod = stat.Mod,
			NetID = GameHelpers.GetNetID(characterId),
			Value = value,
			StatType = stat.StatType
		}))
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