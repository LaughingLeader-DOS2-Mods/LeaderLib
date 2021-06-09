---@param pickpocketSkill integer
---@return number
function GameHelpers.GetPickpocketPricing(pickpocketSkill)
	local expLevel = Ext.Round(pickpocketSkill * Ext.ExtraData.PickpocketExperienceLevelsPerPoint)
	local priceGrowthExp = Ext.ExtraData.PriceGrowth ^ (expLevel - 1)
	if (expLevel >= Ext.ExtraData.FirstPriceLeapLevel) then
	  priceGrowthExp = priceGrowthExp * Ext.ExtraData.FirstPriceLeapGrowth / Ext.ExtraData.PriceGrowth;
	end
	if (expLevel >= Ext.ExtraData.SecondPriceLeapLevel) then
	  priceGrowthExp = priceGrowthExp * Ext.ExtraData.SecondPriceLeapGrowth / Ext.ExtraData.PriceGrowth;
	end
	if (expLevel >= Ext.ExtraData.ThirdPriceLeapLevel) then
	  priceGrowthExp = priceGrowthExp * Ext.ExtraData.ThirdPriceLeapGrowth / Ext.ExtraData.PriceGrowth
	end
	if (expLevel >= Ext.ExtraData.FourthPriceLeapLevel) then
	  priceGrowthExp = priceGrowthExp * Ext.ExtraData.FourthPriceLeapGrowth / Ext.ExtraData.PriceGrowth
	end
	local price = math.ceil(Ext.ExtraData.PickpocketGoldValuePerPoint * priceGrowthExp * Ext.ExtraData.GlobalGoldValueMultiplier)
	return 50 * round(price / 50.0)
end

--- Get an ExtraData entry, with an optional fallback value if the key does not exist.
---@param key string
---@param fallback number
---@return number
function GameHelpers.GetExtraData(key,fallback)
	return Ext.ExtraData[key] or fallback
end

--- Get all enemies within range.
---@param uuid string The character UUID.
---@param radius number
---@return number
function GameHelpers.GetEnemiesInRange(uuid,radius)
	if Ext.IsServer() then
		local character = Ext.GetCharacter(uuid)
		local totalEnemies = 0
		for i,v in pairs(character:GetNearbyCharacters(radius)) do
			if CharacterIsDead(v) == 0 and CharacterIsEnemy(uuid, v) == 1 then
				totalEnemies = totalEnemies + 1
			end
		end
		return totalEnemies
	end
	-- Client-side relation detection isn't a thing yet
	return 0
end

---Get a character's user id, if any.
---@param uuid string
---@return integer|nil
function GameHelpers.GetUserID(uuid)
	if Ext.IsServer() then
		local id = CharacterGetReservedUserID(uuid)
		if id ~= -65536 then
			return id
		end
	elseif Ext.IsClient() then
		local character = Ext.GetCharacter(uuid)
		if character ~= nil then
			if character.UserID ~= -65536 then
				return character.UserID
			elseif Ext.Version() >= 53 and character.ReservedUserID ~= nil and character.ReservedUserID ~= -65536 then
				return character.ReservedUserID
			end
		end
	end
	return nil
end

---@param char1 string|EsvCharacter|EclCharacter
---@param char2 string|EsvCharacter|EclCharacter
---@return boolean
function GameHelpers.CharacterUsersMatch(char1, char2)
	---@type EsvCharacter
	local character1 = char1
	---@type EsvCharacter
	local character2 = char2

	local t1 = type(char1)
	local t2 = type(char2)

	if Ext.IsServer() then
		if t1 == "string" and t2 == t1 then
			return CharacterGetReservedUserID(char1) == CharacterGetReservedUserID(char2)
		end
	end

	if t1 == "string" or t1 == "number" then
		character1 = Ext.GetCharacter(char1)
	end
	if t2 == "string" or t2 == "number" then
		character2 = Ext.GetCharacter(char2)
	end

	if Ext.IsServer() then
		return character1 ~= nil and character2 ~= nil and character1.ReservedUserID == character2.ReservedUserID
	else
		Ext.PrintWarning("[LeaderLib:SharedGameHelpers.lua:GameHelpers.CharacterUsersMatch] This check probably won't work on the client since UserID gets unset when a character isn't controlled, and ReservedUserID is not set/accessible.")
		return character1 ~= nil and character2 ~= nil and character1.UserID == character2.UserID
	end
end

---@param item EsvItem|EclItem
---@return boolean
function GameHelpers.Item.IsObject(item)
	if Data.ObjectStats[item.StatsId] or item.ItemType == "Object" then
		return true
	end
	if not item.Stats then
		return true
	end
	return false
end

---@param item EsvItem|EclItem
---@param tag string
function GameHelpers.ItemHasStatsTag(item, tag)
	if not GameHelpers.Item.IsObject(item) then
		if not StringHelpers.IsNullOrWhitespace(item.Stats.Tags) and 
		Common.TableHasValue(StringHelpers.Split(item.Stats.Tags, ";"), tag) then
			return true
		end
		for _,v in pairs(item.Stats.DynamicStats) do
			if not StringHelpers.IsNullOrWhitespace(v.ObjectInstanceName) then
				local tags = Ext.StatGetAttribute(v.ObjectInstanceName, "Tags")
				if not StringHelpers.IsNullOrWhitespace(tags) and Common.TableHasValue(StringHelpers.Split(tags, ";"), tag) then
					return true
				end
			end
		end
	end
	return false
end

---@param item EsvItem|EclItem
---@param tag string
function GameHelpers.ItemHasTag(item, tag)
	if item:HasTag(tag) then
		return true
	end
	if GameHelpers.ItemHasStatsTag(item, tag) then
		return true
	end
	return false
end

---@param item EsvItem|EclItem
---@param inDictionaryFormat boolean|nil
---@param skipStats boolean|nil
---@return string[]
function GameHelpers.GetItemTags(item, inDictionaryFormat, skipStats)
	local tags = {}
	for _,v in pairs(item:GetTags()) do
		tags[v] = true
	end
	if not skipStats and not GameHelpers.Item.IsObject(item) then
		if not StringHelpers.IsNullOrWhitespace(item.Stats.Tags) then
			for _,v in pairs(StringHelpers.Split(item.Stats.Tags, ";")) do
				tags[v] = true
			end
		end
		for _,v in pairs(item.Stats.DynamicStats) do
			if not StringHelpers.IsNullOrWhitespace(v.ObjectInstanceName) then
				local tagsText = Ext.StatGetAttribute(v.ObjectInstanceName, "Tags")
				if not StringHelpers.IsNullOrWhitespace(tagsText) then
					for _,v in pairs(StringHelpers.Split(tagsText, ";")) do
						tags[v] = true
					end
				end
			end
		end
	end
	if inDictionaryFormat then
		return tags
	end
	local tbl = {}
	for t,b in pairs(tags) do
		tbl[#tbl+1] = t
	end
	table.sort(tbl)
	return tbl
end

---@param character EsvCharacter|EclCharacter
---@param tag string
function GameHelpers.CharacterOrEquipmentHasTag(character, tag)
	if type(character) ~= "userdata" then
		character = Ext.GetCharacter(character)
		if not character then
			error("GameHelpers.CharacterOrEquipmentHasTag requires a uuid, netid, or EsvCharacter/EclCharacter", 1)
			return false
		end
	end
	if character:HasTag(tag) then
		return true
	end
	local isServer = Ext.IsServer()
	for _,slot in Data.VisibleEquipmentSlots:Get() do
		if isServer then
			local uuid = CharacterGetEquippedItem(character.MyGuid, slot)
			if not StringHelpers.IsNullOrEmpty(uuid) then
				local item = Ext.GetItem(uuid)
				if item and GameHelpers.ItemHasTag(item, tag) then
					return true
				end
			end
		else
			local uuid = character:GetItemBySlot(slot)
			if not StringHelpers.IsNullOrEmpty(uuid) then
				local item = Ext.GetItem(uuid)
				if item and GameHelpers.ItemHasTag(item, tag) then
					return true
				end
			end
		end
	end
	return false
end

---Tries and get a string UUID from whatever variable type object is.
---@param object EsvGameObject|EclGameObject|string|number
---@param returnNullId boolean|nil If true, returns NULL_00000000-0000-0000-0000-000000000000 if a UUID isn't found.
---@return UUID
function GameHelpers.GetUUID(object, returnNullId)
	local t = type(object)
	if t == "userdata" and object.MyGuid then
		return object.MyGuid
	elseif t == "string" then
		return StringHelpers.GetUUID(object)
	elseif t == "number" then
		local obj = Ext.GetGameObject(object)
		if obj then
			return obj.MyGuid
		end
	end
	return returnNullId and "NULL_00000000-0000-0000-0000-000000000000" or nil
end