local _ISCLIENT = Ext.IsClient()
local _EXTVERSION = Ext.Version()
local _type = type
local _pcall = pcall

local _getGameObject = Ext.GetGameObject
local _getCharacter = Ext.GetCharacter
local _getItem = Ext.GetItem
local _getTrigger = Ext.GetTrigger
local _isValidHandle = nil
local _osirisIsCallable = Ext.OsirisIsCallable
local _round = Ext.Round

if _EXTVERSION >= 56 then
	_getGameObject = Ext.Entity.GetGameObject
	_getCharacter = Ext.Entity.GetCharacter
	_getItem = Ext.Entity.GetItem
	_getTrigger = Ext.Entity.GetTrigger
	_isValidHandle = Ext.Utils.IsValidHandle
	if not _ISCLIENT then
		_osirisIsCallable = Ext.Osiris.IsCallable
	end
	_round = Ext.Utils.Round
end

---@param pickpocketSkill integer
---@return number
function GameHelpers.GetPickpocketPricing(pickpocketSkill)
	local expLevel = _round(pickpocketSkill * Ext.ExtraData.PickpocketExperienceLevelsPerPoint)
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
	return 50 * _round(price / 50.0)
end

--- Get an ExtraData entry, with an optional fallback value if the key does not exist.
---@param key string
---@param fallback number|integer
---@param asInteger boolean|nil If true, return the result as an integer.
---@return number|integer
function GameHelpers.GetExtraData(key, fallback, asInteger)
	if Ext.ExtraData then
		local value = Ext.ExtraData[key]
		if value then
			if asInteger then
				return math.tointeger(value) or fallback
			end
			return value
		end
	end
	return fallback
end

---@param v userdata
---@return boolean
local function IsHandle(v)
	if _EXTVERSION >= 56 then
		return _isValidHandle(v)
	else
		return v ~= nil and getmetatable(v) == nil
	end
end

GameHelpers.IsValidHandle = IsHandle

local getFuncs = {
	_getCharacter,
	_getItem,
	_getGameObject,
	_getTrigger
}

local function TryGetObject(id)
	local t = _type(id)
	local isHandle = t == "userdata" and IsHandle(id) == true
	if _osirisIsCallable() and t == "string" then
		if ObjectExists(id) == 0 then
			return nil
		end
		if ObjectIsCharacter(id) == 1 then
			local b,obj = _pcall(_getCharacter, id)
			if b and obj then
				return obj
			end
		elseif ObjectIsItem(id) == 1 then
			local b,obj = _pcall(_getItem, id)
			if b and obj then
				return obj
			end
		else
			local b,obj = _pcall(_getGameObject, id)
			if b and obj then
				return obj
			end
		end
	elseif isHandle then
		local b,obj = _pcall(_getGameObject, id)
		if b and obj then
			return obj
		end
	elseif t == "number" then
		--Assuming id is a NetID, try Character first, then Item
		for i=1,3 do
			local func = getFuncs[i]
			local b,result = _pcall(func, id)
			if b and result then
				return result
			end
		end
	elseif t == "userdata" then
		return id
	end
	return nil
end

---Tries to get a game object if the target exists, otherwise returns nil.
---@param id string|integer|ObjectHandle
---@param returnOriginal boolean|nil Return the original value if failed. Defaults to false, so nil is returned.
---@return EsvCharacter|EsvItem|nil
local function _tryGetObject(id, returnOriginal)
	local b,result = _pcall(TryGetObject, id)
	if not b then
		if Vars.DebugMode then
			fprint(LOGLEVEL.ERROR, "[GameHelpers.TryGetObject] Error getting object from id (%s):\n%s", id, result)
		end
		return returnOriginal == true and id or nil
	end
	if result == nil and returnOriginal == true then
		return id
	end
	return result
end

GameHelpers.TryGetObject = _tryGetObject

local _UNSET_USERID = -65536

---Get a character's user id, if any.
---@param obj UUID|EsvCharacter|EclCharacter
---@return integer|nil
function GameHelpers.GetUserID(obj)
	local t = _type(obj)
	local id = nil
	if t == "number" then
		return obj
	elseif t == "string" then
		local character = GameHelpers.GetCharacter(obj)
		if character then
			id = math.max(character.UserID, character.ReservedUserID)
		end
	elseif (t == "userdata" or t == "table") and obj.UserID and obj.ReservedUserID then
		id = math.max(obj.UserID, obj.ReservedUserID)
	end
	if id and id ~= _UNSET_USERID then
		return id
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

	local t1 = _type(char1)
	local t2 = _type(char2)

	if not _ISCLIENT then
		if t1 == "string" and t2 == t1 then
			return CharacterGetReservedUserID(char1) == CharacterGetReservedUserID(char2)
		end
	end

	if t1 == "string" or t1 == "number" then
		character1 = _getCharacter(char1)
	end
	if t2 == "string" or t2 == "number" then
		character2 = _getCharacter(char2)
	end

	if not _ISCLIENT then
		return character1 ~= nil and character2 ~= nil and character1.ReservedUserID == character2.ReservedUserID
	else
		Ext.PrintWarning("[LeaderLib:SharedGameHelpers.lua:GameHelpers.CharacterUsersMatch] This check probably won't work on the client since UserID gets unset when a character isn't controlled, and ReservedUserID is not set/accessible.")
		return character1 ~= nil and character2 ~= nil and character1.UserID == character2.UserID
	end
end

---@param statItem StatItem
---@param tag string|string[]
function GameHelpers.StatItemHasTag(statItem, tag)
	local t = _type(tag)
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

---@param item EsvItem|EclItem|UUID
---@param tag string|string[]
function GameHelpers.ItemHasTag(item, tag)
	local t = _type(tag)
	if t == "table" then
		for i=1,#tag do
			if GameHelpers.ItemHasTag(item, tag[i]) then
				return true
			end
		end
	elseif t == "string" then
		if _type(item) == "string" then
			item = GameHelpers.GetItem(item)
		end
		if _type(item) == "table" then
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
	if _type(character) ~= "userdata" then
		character = GameHelpers.GetCharacter(character)
		if not character then
			fprint(LOGLEVEL.ERROR, "GameHelpers.CharacterOrEquipmentHasTag requires a uuid, netid, ObjectHandle, or EsvCharacter/EclCharacter. Values provided: character(%s) tag(%s)", character, tag)
			return false
		end
	end
	if character:HasTag(tag) then
		return true
	end
	for item in GameHelpers.Character.GetEquipment(character) do
		if GameHelpers.ItemHasTag(item, tag) then
			return true
		end
	end
	return false
end

---Gather all tags for an object and store them in a table.
---@param object EsvCharacter|EsvItem|EclCharacter|EclItem The character or item to get tags from.
---@param inDictionaryFormat boolean|nil If true, tags will be set as tbl[tag] = true, for easier checking.
---@param addEquipmentTags boolean|nil If the object is a character, all tags found on equipped items will be added to the table.
---@return string[]|table<string,boolean>
function GameHelpers.GetAllTags(object, inDictionaryFormat, addEquipmentTags)
	local tags = {}
	local t = _type(object)
	if (t == "userdata" or t == "table") and object.GetTags then
		for _,v in pairs(object:GetTags()) do
			if inDictionaryFormat then
				tags[v] = true
			else
				tags[#tags+1] = v
			end
		end
		if GameHelpers.Ext.ObjectIsItem(object) and not GameHelpers.Item.IsObject(object) then
			for tag,b in pairs(GameHelpers.GetItemTags(object, true, false)) do
				if inDictionaryFormat then
					tags[tag] = true
				else
					tags[#tags+1] = tag
				end
			end
		end
	end
	if addEquipmentTags and GameHelpers.Ext.ObjectIsCharacter(object) then
		local items = {}
		for _,slot in Data.VisibleEquipmentSlots:Get() do
			if _ISCLIENT then
				local uuid = object:GetItemBySlot(slot)
				if not StringHelpers.IsNullOrEmpty(uuid) then
					local item = _getItem(uuid)
					if item then
						items[#items+1] = item
					end
				end
			else
				if _osirisIsCallable() then
					local uuid = CharacterGetEquippedItem(object.MyGuid, slot)
					if not StringHelpers.IsNullOrEmpty(uuid) then
						local item = _getItem(uuid)
						if item then
							items[#items+1] = item
						end
					end
				else
					items = GameHelpers.Character.GetEquipment(object, true)
				end
			end
		end
		for i=1,#items do
			local item = items[i]
			for tag,b in pairs(GameHelpers.GetItemTags(item, true, false)) do
				if inDictionaryFormat then
					tags[tag] = true
				else
					tags[#tags+1] = tag
				end
			end
		end
	end
	if not inDictionaryFormat then
		table.sort(tags)
	end
	return tags
end

local function _GetMyGuid(obj)
	return obj.MyGuid
end

---Tries to get a string UUID from whatever variable type object is.
---@param object EsvGameObject|EclGameObject|string|number
---@param returnNullId boolean|nil If true, returns NULL_00000000-0000-0000-0000-000000000000 if a UUID isn't found.
---@return UUID
function GameHelpers.GetUUID(object, returnNullId)
	local t = _type(object)
	if t == "userdata" then
		local b,uuid = _pcall(_GetMyGuid, object)
		if uuid then
			return uuid
		end
	elseif t == "string" then
		return StringHelpers.GetUUID(object)
	elseif t == "number" then
		local obj = _getGameObject(object)
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
	local t = _type(object)
	if t == "userdata" and object.NetID then
		return object.NetID
	elseif t == "string" then
		local obj = _getGameObject(object)
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
	local t = _type(object)
	if t == "userdata" and object.NetID then
		if not _ISCLIENT then
			return object.MyGuid
		else
			return object.NetID
		end
	elseif t == "string" or t == "number" then
		local obj = GameHelpers.GetCharacter(object)
		if obj then
			if not _ISCLIENT then
				return obj.MyGuid
			else
				return obj.NetID
			end
		end
	end
	return nil
end

---Tries to get an Esv/EclCharacter from whatever the value is.
---@param object EsvGameObject|EclGameObject|string|number|StatCharacter
---@return EsvCharacter|EclCharacter
function GameHelpers.GetCharacter(object)
	local t = _type(object)
	local isHandle = t == "userdata" and IsHandle(object) == true
	if isHandle or t == "string" or t == "number" then
		local b,obj = _pcall(_getCharacter, object)
		if b and obj then
			return obj
		end
	elseif t == "userdata" then
		if GameHelpers.Ext.ObjectIsCharacter(object) then
			return object
		elseif GameHelpers.Ext.ObjectIsStatCharacter(object) then
			return object.Character
		elseif IsHandle(object) then
			local b,obj = _pcall(_getCharacter, object)
			if b then
				return obj
			end
		end
	end
	return nil
end

---Tries to get an Esv/EclItem from whatever the value is.
---@param object EsvGameObject|EclGameObject|string|number
---@return EsvItem|EclItem
function GameHelpers.GetItem(object)
	local t = _type(object)
	local isHandle = t == "userdata" and IsHandle(object) == true
	if t == "userdata" and GameHelpers.Ext.ObjectIsItem(object) then
		return object
	elseif isHandle or t == "string" or t == "number" then
		local b,obj = _pcall(_getItem, object)
		if b and obj then
			return obj
		end
	end
	return nil
end

---Checks if a character or item exists.
---@param object EsvGameObject|EclGameObject|string|number
---@return boolean
function GameHelpers.ObjectExists(object)
	local t = _type(object)
	if t == "string" and StringHelpers.IsNullOrWhitespace(object) then
		return false
	end
	if _osirisIsCallable() then
		if t == "userdata" then
			if IsHandle(object) then
				return _tryGetObject(object) ~= nil
			elseif object.MyGuid then
				return ObjectExists(object.MyGuid) == 1
			end
		elseif t == "string" then
			return ObjectExists(object) == 1
		elseif t == "number" then
			return _tryGetObject(object) ~= nil
		end
	end
	if t == "userdata" then
		if IsHandle(object) then
			return _tryGetObject(object) ~= nil
		else
			return GameHelpers.Ext.ObjectIsAnyType(object)
		end
	elseif t == "string" or t == "number" then
		return _tryGetObject(object) ~= nil
	end
	return false
end

---@param object UUID|NETID|EsvGameObject|ObjectHandle
---@return boolean
function GameHelpers.ObjectIsDead(object)
	local object = _tryGetObject(object)
	if object then
		if GameHelpers.Ext.ObjectIsCharacter(object) then
			if _ISCLIENT then
				return object.Stats.CurrentVitality == 0
			else
				return object.Dead
			end
		elseif GameHelpers.Ext.ObjectIsItem(object) then
			if _ISCLIENT then
				return object.RootTemplate.Destroyed
			else
				return object.Destroyed
			end
		end
	end
	return false
end

---@return GameDifficulty
function GameHelpers.GetGameDifficulty()
	--int to string
	return Data.Difficulty(Ext.GetDifficulty())	
end

---@param obj EsvCharacter|EsvItem|UUID|NETID
---@param flag string
function GameHelpers.ObjectHasFlag(obj, flag)
	if not _ISCLIENT and _osirisIsCallable() then
		local uuid = GameHelpers.GetUUID(obj)
		if uuid then
			return ObjectGetFlag(uuid, flag) == 1
			or (ObjectIsCharacter(uuid) == 1
			and PartyGetFlag(uuid, flag) == 1
			or UserGetFlag(uuid, flag) == 1)
		end
	end
	return false
end

---Get an object's root template UUID.
---@param obj EsvCharacter|EclCharacter|EsvItem|EclItem|UUID|NETID
---@return string
function GameHelpers.GetTemplate(obj)
	if not _ISCLIENT and _osirisIsCallable() then
		local uuid = GameHelpers.GetUUID(obj)
		if uuid then
			return StringHelpers.GetUUID(GetTemplate(uuid))
		end
	end
	local object = _tryGetObject(obj)
	if object and object.RootTemplate then
		if _EXTVERSION < 56 then
			if object.RootTemplate.TemplateName ~= "" then
				return object.RootTemplate.TemplateName
			else
				return object.RootTemplate.Id
			end
		else
			if object.RootTemplate.RootTemplate ~= "" then
				return object.RootTemplate.RootTemplate
			else
				return object.RootTemplate.Id
			end
		end
	end
	return nil
end

local _cachedLevels = {}
local _ranCachedLevels = false

local NonGameLevelTypes = {
	LobbyLevel = true,
	MenuLevel = true,
	PhotoBoothLevel = true,
	CharacterCreationLevel = true,
}

local LevelAttributeNames = {
	"LobbyLevel",
	"MenuLevel",
	"PhotoBoothLevel",
	"CharacterCreationLevel",
	"StartLevel",
}

local function _cacheAllModLevels()
	local manager = _ISCLIENT and Ext.Client.GetModManager() or not _ISCLIENT and Ext.Server.GetModManager()
	if manager then
		_ranCachedLevels = true
		local adventureMod = manager.BaseModule
		for i=1,5 do
			local att = LevelAttributeNames[i]
			local levelName = adventureMod.Info[att]
			if not StringHelpers.IsNullOrEmpty(levelName) then
				if _cachedLevels[levelName] == nil then
					_cachedLevels[levelName] = {}
				end
				_cachedLevels[levelName][att] = true
			end
		end
		-- for _,data in pairs(manager.AvailableMods) do
		-- 	for i=1,5 do
		-- 		local att = LevelAttributeNames[i]
		-- 		local levelName = data.Info[att]
		-- 		if not StringHelpers.IsNullOrEmpty(levelName) then
		-- 			if _cachedLevels[levelName] == nil then
		-- 				_cachedLevels[levelName] = {}
		-- 			end
		-- 			_cachedLevels[levelName][att] = true
		-- 		end
		-- 	end
		-- end
	end
end

---@param levelName string
---@return LEVELTYPE
function GameHelpers.GetLevelType(levelName)
	if _EXTVERSION >= 56 then
		if not _ranCachedLevels then
			if Ext.GetGameState() == "Running" then
				_cacheAllModLevels()
			else
				if levelName == "SYS_Character_Creation_A" then
					return LEVELTYPE.CHARACTER_CREATION
				elseif levelName == "ARENA_Menu" then
					return LEVELTYPE.LOBBY
				end
			end
		end
		local levelData = _cachedLevels[levelName]
		if levelData then
			if levelData.CharacterCreationLevel then
				return LEVELTYPE.CHARACTER_CREATION
			elseif levelData.LobbyLevel then
				return LEVELTYPE.LOBBY
			end
		end
	elseif _osirisIsCallable() then
		if IsGameLevel(levelName) == 1 then
			return LEVELTYPE.GAME
		elseif IsCharacterCreationLevel(levelName) == 1 then
			return LEVELTYPE.CHARACTER_CREATION
		else
			return LEVELTYPE.LOBBY
		end
	end
	return LEVELTYPE.GAME
end

---@param levelType LEVELTYPE
---@param levelName string|nil Optional level to use when checking.
---@return boolean
function GameHelpers.IsLevelType(levelType, levelName)
	--Assuming levelType is actually levelName and levelName is LEVELTYPE, swap the params
	if not LEVELTYPE[levelType] and LEVELTYPE[levelName] then
		local lt = levelName
		levelName = levelType
		levelType = lt
	end
	if levelName == nil then
		if _EXTVERSION >= 56 then
			local level = Ext.Entity.GetCurrentLevel()
			if level then
				levelName = level.LevelDesc.LevelName
			end
		else
			levelName = SharedData.RegionData.Current
		end
	end
	if not StringHelpers.IsNullOrEmpty(levelName) then
		return GameHelpers.GetLevelType(levelName) == levelType
	end
	return false
end

local TAG_PREFIX = "LeaderLib_ResistancePenetration_"

---@param tag string A tag such as LeaderLib_ResistancePenetration_Poison50
---@return string damageType
---@return integer amount
function GameHelpers.ParseResistancePenetrationTag(tag)
	if string.find(tag, TAG_PREFIX) then
		local strippedTag = string.gsub(tag, TAG_PREFIX, "")
		local damageType = string.match(strippedTag, "%a+")
		local amount = tonumber(string.match(strippedTag, "%d+"))
		if damageType and amount and Data.DamageTypeEnums[damageType] then
			return damageType,amount
		end
	end
end

--local amt = 3; local dl = Ext.NewDamageList(); dl:Add("Fire", 4); dl:Add("Water", 3); local ndl = Mods.LeaderLib.GameHelpers.Damage.DivideDamage(dl, amt); local pdl = {}; for _,v in pairs(ndl) do table.insert(pdl, v:ToTable()) end; Ext.Dump(pdl)

---@param damageList DamageList
---@param divider integer
---@return DamageList[] damages
function GameHelpers.Damage.DivideDamage(damageList, divider)
	damageList:AggregateSameTypeDamages()
    local damages = damageList:ToTable()
	local damagePerType = {}
	local totalDamagePerType = {}
	local totalDamage = 0
    for _,v in pairs(damages) do
		totalDamage = totalDamage + v.Amount
		if not totalDamagePerType[v.DamageType] then
			totalDamagePerType[v.DamageType] = 0
		end
        totalDamagePerType[v.DamageType] = totalDamagePerType[v.DamageType] + v.Amount 
		damagePerType[v.DamageType] = math.floor(v.Amount / divider)
    end
    if totalDamage > 0 then
		local newDamages = {}
        local remainingDamage = totalDamage
        for i=1,divider do
            if remainingDamage > 0 then
				local newDamageList = Ext.NewDamageList()
				for damageType,amount in pairs(damagePerType) do
					local addDamage = math.min(totalDamagePerType[damageType], amount)
					if addDamage > 0 then
						totalDamagePerType[damageType] = totalDamagePerType[damageType] - addDamage
						remainingDamage = remainingDamage - addDamage
						newDamageList:Add(damageType, addDamage)
					end
				end
				if remainingDamage > 0 and i == divider then
					for damageType,amount in pairs(totalDamagePerType) do
						if amount > 0 then
							newDamageList:Add(damageType, amount)
						end
					end
				end
				newDamages[#newDamages+1] = newDamageList
            end
        end
        return newDamages
    else
        return {damageList}
    end
end

---@param obj CharacterParam|ItemParam
function GameHelpers.GetDisplayName(obj)
	local obj = _tryGetObject(obj)
	if obj then
		if GameHelpers.Ext.ObjectIsCharacter(obj) then
			return GameHelpers.Character.GetDisplayName(obj)
		elseif GameHelpers.Ext.ObjectIsItem(obj) then
			if _EXTVERSION >= 56 then
				if string.find(obj.DisplayName, "|") or obj.RootTemplate.DisplayName.Handle == nil then
					if GameHelpers.Item.IsObject(obj) and not StringHelpers.IsNullOrEmpty(obj.StatsId) and not Data.ItemRarity[obj.StatsId] then
						local name = GameHelpers.GetStringKeyText(obj.StatsId, "")
						if not StringHelpers.IsNullOrEmpty(name) then
							return name
						end
					end
					return GameHelpers.GetTranslatedStringValue(obj.RootTemplate.DisplayName, obj.DisplayName)
				end
			end
			return obj.DisplayName
		end
	end
	return ""
end

---Calculates Movement and MovementSpeedBoost from DynamicStats.
---@param obj ObjectParam|StatCharacter|StatItemDynamic
---@param asFullAmount boolean|nil Return Movement in the full amount (like 500), instead of multiplying it by 0.01 and rounding the result.
---@return number
function GameHelpers.GetMovement(obj, asFullAmount)
	local stats = nil
	if GameHelpers.Ext.ObjectIsStatCharacter(obj) or GameHelpers.Ext.ObjectIsStatItem(obj) then
		stats = obj
	else
		local t = _type(obj)
		if t == "userdata" or t == "table" and obj.Stats then
			stats = obj.Stats
		end
	end
	if not stats then
		return 0
	end
	local movement = 0
	local boost = 0
	for i=1,#stats.DynamicStats do
		local v = stats.DynamicStats[i]
		if v then
			movement = movement + v.Movement
			boost = boost + v.MovementSpeedBoost
		end
	end
	if movement == 0 then
		return 0
	end

	if asFullAmount then
		if boost ~= 0 then
			local boostMult = boost * 0.01
			if movement > 0 then
				return _round(movement * boostMult)
			else
				return _round(movement * math.abs(boostMult))
			end
		else
			return movement
		end
	else
		if boost ~= 0 then
			local boostMult = boost * 0.01
			if movement > 0 then
				return _round((movement * boostMult) * 0.01)
			else
				return _round((movement * math.abs(boostMult)) * 0.01)
			end
		else
			return _round(movement * 0.01)
		end
	end
end

---Set an item or character's scale, and sync it to clients.
---@param object EsvCharacter|string
---@param scale number
---@param persist boolean|nil
function GameHelpers.SetScale(object, scale, persist)
	object = GameHelpers.TryGetObject(object)
	if object and object.Scale then
		if _EXTVERSION < 56 then
			if object.SetScale then
				object:SetScale(scale)
			end
		else
			object.Scale = scale
		end
		if not _ISCLIENT then
			GameHelpers.SyncScale(object)
			if persist == true then
				PersistentVars.ScaleOverride[object.MyGuid] = scale
			end
		end
	end
end