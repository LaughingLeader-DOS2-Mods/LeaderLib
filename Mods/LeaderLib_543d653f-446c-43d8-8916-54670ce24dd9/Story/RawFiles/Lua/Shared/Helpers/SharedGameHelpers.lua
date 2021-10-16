local isClient = Ext.IsClient()

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
---@param fallback number|integer
---@param asInteger boolean|nil If true, return the result as an integer.
---@return number|integer
function GameHelpers.GetExtraData(key, fallback, asInteger)
	local value = Ext.ExtraData[key]
	if value then
		if asInteger then
			return math.tointeger(value) or fallback
		end
		return value
	end
	return fallback
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

if not GameHelpers.Item then
	GameHelpers.Item = {}
end

---@param item EsvItem|EclItem|string
---@return boolean
function GameHelpers.Item.IsObject(item)
	local t = type(item)
	if t == "userdata" then
		if GameHelpers.Ext.ObjectIsItem(item) then
			if Data.ObjectStats[item.StatsId] or item.ItemType == "Object" then
				return true
			end
			if not item.Stats then
				return true
			end
		elseif GameHelpers.Ext.ObjectIsStatItem(item) then
			if Data.ObjectStats[item.Name] then
				return true
			end
		end
	elseif t == "string" then
		return Data.ObjectStats[item] == true
	end
	return false
end

---@param item EsvItem|EclItem|UUID|NETID
---@param returnNilUUID boolean|nil
---@return UUID
function GameHelpers.Item.GetOwner(item, returnNilUUID)
	local item = GameHelpers.GetItem(item)
	if item then
		if item.OwnerHandle ~= nil then
			local object = Ext.GetGameObject(item.OwnerHandle)
			if object ~= nil then
				return object.MyGuid
			end
		end
		if Ext.OsirisIsCallable() then
			local inventory = StringHelpers.GetUUID(GetInventoryOwner(item.MyGuid))
			if not StringHelpers.IsNullOrEmpty(inventory) then
				return inventory
			end
		else
			if item.InventoryHandle then
				local object = Ext.GetGameObject(item.InventoryHandle)
				if object ~= nil then
					return object.MyGuid
				end
			end
		end
	end
	if returnNilUUID then
		return StringHelpers.NULL_UUID
	end
	return nil
end

---@param statItem StatItem
---@param tag string|string[]
function GameHelpers.StatItemHasTag(statItem, tag)
	local t = type(tag)
	if t == "string" then
		if StringHelpers.DelimitedStringContains(statItem.Tags, ";", tag) then
			return true
		end
		if statItem.DynamicStats then
			for _,v in pairs(statItem.DynamicStats) do
				if not StringHelpers.IsNullOrWhitespace(v.ObjectInstanceName) then
					local tags = Ext.StatGetAttribute(v.ObjectInstanceName, "Tags")
					if tags and StringHelpers.DelimitedStringContains(tags, ";", tag) then
						return true
					end
				end
			end
		end
	elseif t == "table" then
		for _,v in pairs(tag) do
			if GameHelpers.StatItemHasTag(statItem, v) then
				return true
			end
		end
	end
	return false
end

---@param item EsvItem|EclItem
---@param tag string|string[]
---@param statItem StatItem|nil
function GameHelpers.ItemHasStatsTag(item, tag, statItem)
	if statItem or not GameHelpers.Item.IsObject(item) then
		statItem = statItem or item.Stats
		return GameHelpers.StatItemHasTag(statItem, tag)
	end
	return false
end

---@param item EsvItem|EclItem
---@param tag string|string[]
function GameHelpers.ItemHasTag(item, tag)
	local t = type(tag)
	if t == "table" then
		for i=1,#tag do
			if GameHelpers.ItemHasTag(item, tag[i]) then
				return true
			end
		end
	elseif t == "string" then
		if type(item) == "table" then
			if item.HasTag and item.HasTag(item, tag) == true then
				return true
			end
		elseif GameHelpers.Ext.ObjectIsItem(item) then
			if item:HasTag(tag) then
				return true
			end
			if GameHelpers.ItemHasStatsTag(item, tag) then
				return true
			end
		elseif GameHelpers.Ext.ObjectIsStatItem(item) then
			if GameHelpers.ItemHasStatsTag(item, tag) then
				return true
			end
		end
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

---@param character EsvCharacter|EclCharacter|UUID|NETID|ObjectHandle
---@param tag string
function GameHelpers.CharacterOrEquipmentHasTag(character, tag)
	if type(character) ~= "userdata" then
		character = Ext.GetCharacter(character)
		if not character then
			error("GameHelpers.CharacterOrEquipmentHasTag requires a uuid, netid, ObjectHandle, or EsvCharacter/EclCharacter", 1)
			return false
		end
	end
	if character:HasTag(tag) then
		return true
	end
	for _,slot in Data.VisibleEquipmentSlots:Get() do
		if not isClient and Ext.OsirisIsCallable() then
			local uuid = CharacterGetEquippedItem(character.MyGuid, slot)
			if not StringHelpers.IsNullOrEmpty(uuid) then
				local item = Ext.GetItem(uuid)
				if item and GameHelpers.ItemHasTag(item, tag) then
					return true
				end
			end
		else
			if isClient then
				local uuid = character:GetItemBySlot(slot)
				if not StringHelpers.IsNullOrEmpty(uuid) then
					local item = Ext.GetItem(uuid)
					if item and GameHelpers.ItemHasTag(item, tag) then
						return true
					end
				end
			else
				local items = character:GetInventoryItems()
				local count = math.min(#items, 14)
				for i=1,count do
					local item = Ext.GetItem(items[i])
					if item and Data.VisibleEquipmentSlots[item.Slot] and GameHelpers.ItemHasTag(item, tag) then
						return true
					end
				end
			end
		end
	end
	return false
end

---Tries to get a string UUID from whatever variable type object is.
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

---Tries to get a NetID from whatever variable type object is.
---@param object EsvGameObject|EclGameObject|string|number
---@return NETID
function GameHelpers.GetNetID(object)
	local t = type(object)
	if t == "userdata" and object.NetID then
		return object.NetID
	elseif t == "string" then
		local obj = Ext.GetGameObject(object)
		if obj then
			return obj.NetID
		end
	elseif t == "number" then
		return object
	end
	return nil
end

---Tries to get a UUID on the server or NetID on the client.
---@param object EsvCharacter|EclCharacter|string|number
---@return UUID|NETID
function GameHelpers.GetCharacterID(object)
	local t = type(object)
	if t == "userdata" and object.NetID then
		if not isClient then
			return object.MyGuid
		else
			return object.NetID
		end
	elseif t == "string" or t == "number" then
		local obj = Ext.GetCharacter(object)
		if obj then
			if not isClient then
				return obj.MyGuid
			else
				return obj.NetID
			end
		end
	end
	return nil
end

---Tries to get an Esv/EclCharacter from whatever the value is.
---@param object EsvGameObject|EclGameObject|string|number
---@return EsvCharacter|EclCharacter
function GameHelpers.GetCharacter(object)
	local t = type(object)
	if t == "userdata" and GameHelpers.Ext.ObjectIsCharacter(object) then
		return object
	elseif t == "string" or t == "number" then
		local obj = Ext.GetCharacter(object)
		if obj then
			return obj
		end
	end
	return nil
end

---Tries to get an Esv/EclItem from whatever the value is.
---@param object EsvGameObject|EclGameObject|string|number
---@return EsvItem|EclItem
function GameHelpers.GetItem(object)
	local t = type(object)
	if t == "userdata" and GameHelpers.Ext.ObjectIsItem(object) then
		return object
	elseif t == "string" or t == "number" then
		local obj = Ext.GetItem(object)
		if obj then
			return obj
		end
	end
	return nil
end

---Checks if a character or item exists.
---@param object EsvGameObject|EclGameObject|string|number
---@return false
function GameHelpers.ObjectExists(object, returnNullId)
	local t = type(object)
	if t == "string" and StringHelpers.IsNullOrWhitespace(object) then
		return false
	end
	if Ext.OsirisIsCallable() then
		if t == "userdata" and object.MyGuid then
			return ObjectExists(object.MyGuid) == 1
		elseif t == "string" and not StringHelpers.IsNullOrWhitespace(object) then
			return ObjectExists(object) == 1
		elseif t == "number" then
			local obj = Ext.GetGameObject(object)
			if obj then
				return ObjectExists(obj.MyGuid) == 1
			end
		end
	else
		if t == "userdata" then
			return true
		elseif (t == "string" and not StringHelpers.IsNullOrWhitespace(object)) or t == "number" then
			local obj = GameHelpers.TryGetObject(object, true)
			if obj then
				return true
			end
		end
	end
	return false
end


local function TryGetObject(id)
	local t = type(id)
	local isHandle = t == "userdata" and getmetatable(id) == nil
	if Ext.OsirisIsCallable() and t == "string" then
		if ObjectExists(id) == 0 then 
			return nil
		end
		if ObjectIsCharacter(id) == 1 then
			return Ext.GetCharacter(id)
		elseif ObjectIsItem(id) == 1 then
			return Ext.GetItem(id)
		end
	elseif isHandle or t == "number" then
		local char = Ext.GetCharacter(id)
		if char then
			return char
		end
		local item = Ext.GetItem(id)
		if item then
			return item
		end
		return Ext.GetGameObject(id)
	elseif t == "userdata" then
		return id
	end
	return nil
end

---Tries to get a game object if the target exists, otherwise returns nil.
---@param id string|integer|ObjectHandle
---@param returnNil boolean|nil Return nil if failed. Defaults to false, so the id value is returned.
---@return EsvCharacter|EsvItem|nil
function GameHelpers.TryGetObject(id, returnNil)
	local b,result = xpcall(TryGetObject, debug.traceback, id)
	if not b then
		if Vars.DebugMode then
			fprint(LOGLEVEL.ERROR, "[GameHelpers.TryGetObject] Error getting object from id (%s):\n%s", id, result)
		end
		return returnNil ~= true and id or nil
	end
	if result == nil and returnNil ~= true then
		return id
	end
	return result
end