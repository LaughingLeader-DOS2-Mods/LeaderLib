local _ISCLIENT = Ext.IsClient()
local _EXTVERSION = Ext.Utils.Version()
local _type = type
local _pcall = pcall

local _getGameObject = Ext.Entity.GetGameObject
local _getCharacter = Ext.Entity.GetCharacter
local _getItem = Ext.Entity.GetItem
local _getTrigger = Ext.Entity.GetTrigger
local _getProjectile = Ext.Entity.GetProjectile
local _isValidHandle = Ext.Utils.IsValidHandle
local _getObjectType = Ext.Types.GetObjectType
local _osirisIsCallable = not _ISCLIENT and Ext.Osiris.IsCallable or function() return false end
local _round = Ext.Utils.Round

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

---@overload fun(key:string, fallback:integer, asInteger:boolean):integer
--- Get an ExtraData entry, with an optional fallback value if the key does not exist.
---@param key string
---@param fallback number|integer
---@param asInteger? boolean If true, return the result as an integer.
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

---@param v userdata|ComponentHandle|any
---@return boolean
local function IsHandle(v)
	if _isValidHandle(v) then
		return true
	end
	return type(v) == "userdata" and getmetatable(v) == nil
end

GameHelpers.IsValidHandle = IsHandle

local getFuncs = {
	_getCharacter,
	_getItem,
	_getGameObject,
	_getTrigger,
	_getProjectile
}

local _objectTypes = {
	["esv::Character"] = true,
	["ecl::Character"] = true,
	["esv::Item"] = true,
	["ecl::Item"] = true,
	["ecl::Scenery"] = true,
	["esv::Projectile"] = true,
	["ecl::Projectile"] = true,
	["Trigger"] = true,
	["AreaTrigger"] = true,
	["AtmosphereTrigger"] = true,
	["SoundVolumeTrigger"] = true,
	["esv::AreaTriggerBase"] = true,
	["esv::EocAreaTrigger"] = true,
	["esv::EventTrigger"] = true,
	["esv::CrimeAreaTrigger"] = true,
	["esv::CrimeRegionTrigger"] = true,
	["esv::MusicVolumeTrigger::Triggered"] = true,
	["esv::MusicVolumeTrigger"] = true,
	["esv::SecretRegionTrigger"] = true,
	["esv::RegionTrigger"] = true,
	["esv::ExplorationTrigger"] = true,
	["esv::PointTriggerBase"] = true,
	["esv::TeleportTrigger"] = true,
	["esv::StartTrigger"] = true,
	["esv::EocPointTrigger"] = true,
	["esv::AIHintAreaTrigger"] = true,
	["esv::StatsAreaTrigger"] = true,
	["esv::AtmosphereTrigger"] = true,
	["esv::SoundVolumeTrigger"] = true,
}

local function TryGetObject(id)
	local extType = _getObjectType(id)
	if _objectTypes[extType] then
		return id
	elseif extType == "CDivinityStats_Character" then
		---@cast id CDivinityStatsCharacter
		return id.Character --[[@as EsvCharacter|EclCharacter]]
	elseif extType == "CDivinityStatsItem" then
		---@cast id CDivinityStatsItem
		return id.GameObject --[[@as EsvItem|EclItem]]
	end
	local t = _type(id)
	if t == "string" and StringHelpers.IsNullOrEmpty(id) then
		return nil
	end
	if IsHandle(id) or t == "string" then
		local b,obj = _pcall(_getGameObject, id)
		if b and obj then
			return obj
		end
	elseif t == "number" then
		--Assuming id is a NetID, try Character first, then Item etc
		for i=1,5 do
			local func = getFuncs[i]
			local b,result = _pcall(func, id)
			if b and result then
				return result
			end
		end
	end
	return nil
end

---@overload fun(id:ObjectParam|ComponentHandle):EsvCharacter|EclCharacter|EsvItem|EclItem|nil
---Tries to get a game object if the target exists, otherwise returns nil.
---@generic T:EsvCharacter|EclCharacter|EsvItem|EclItem|nil
---@param id? ObjectParam|ComponentHandle
---@param castType? `T` The class type to return, for auto-completion, such as "EsvCharacter".
---@return T
function GameHelpers.TryGetObject(id, castType)
	local b,result = _pcall(TryGetObject, id)
	if not b and Vars.DebugMode then
		fprint(LOGLEVEL.ERROR, "[GameHelpers.TryGetObject] Error getting object from id (%s):\n%s", id, result)
	end
	return result
end

local _tryGetObject = GameHelpers.TryGetObject

---@overload fun(object:CharacterParam|StatCharacter|ComponentHandle):EsvCharacter|EclCharacter|nil
---Tries to get an Esv/EclCharacter from whatever the value is.
---@generic T:EsvCharacter|EclCharacter|nil
---@param object CharacterParam|StatCharacter|ComponentHandle
---@param castType `T` The class type to return, for auto-completion, such as "EsvCharacter".
---@return T
function GameHelpers.GetCharacter(object, castType)
	local extType = _getObjectType(object)
	if extType == "esv::Character" or extType == "ecl::Character" then
		return object --[[@as EsvCharacter|EclCharacter]]
	elseif extType == "CDivinityStats_Character" then
		---@cast object CDivinityStatsCharacter
		return object.Character --[[@as EsvCharacter|EclCharacter]]
	end
	local t = _type(object)
	if t == "string" and StringHelpers.IsNullOrEmpty(object) then
		return nil
	end
	if IsHandle(object) or t == "string" or t == "number" then
		local _,obj = _pcall(_getCharacter, object)
		return obj
	end
	return nil
end

---@overload fun(object:ItemParam|CDivinityStatsItem|ComponentHandle):EsvItem|EclItem|nil
---Tries to get an Esv/EclItem from whatever the value is.
---@generic T:EsvItem|EclItem|nil
---@param object ItemParam|CDivinityStatsItem|ComponentHandle
---@param castType `T` The class type to return, for auto-completion, such as "EsvItem".
---@return T
function GameHelpers.GetItem(object, castType)
	local extType = _getObjectType(object)
	if extType == "esv::Item" or extType == "ecl::Item" then
		return object --[[@as EsvItem|EclItem]]
	elseif extType == "CDivinityStatsItem" then
		---@cast object CDivinityStatsItem
		return object.GameObject --[[@as EsvItem|EclItem]]
	end
	local t = _type(object)
	if t == "string" and StringHelpers.IsNullOrEmpty(object) then
		return nil
	end
	if IsHandle(object) or t == "string" or t == "number" then
		local _,obj = _pcall(_getItem, object)
		return obj
	end
	return nil
end

---@overload fun(handle:ComponentHandle):ServerObject|ClientObject|nil
---Tries to get an object from a handle, skipping the Ext.Entity.GetGameObject call if it's invalid.
---@generic T
---@param handle ComponentHandle
---@param typeName? `T` This should be the lua class name as a string, so the return type automatically changes.
---@return T
function GameHelpers.GetObjectFromHandle(handle, typeName)
	if _isValidHandle(handle) then
		return _getGameObject(handle)
	end
	return nil
end


---@overload fun(object:ObjectParam|nil):Guid|nil
---Tries to get a string UUID from whatever variable type object is.
---@param object? ObjectParam
---@param returnNullId boolean If true, returns NULL_00000000-0000-0000-0000-000000000000 if a UUID isn't found.
---@return Guid|nil
function GameHelpers.GetUUID(object, returnNullId)
	local t = _type(object)
	if t == "userdata" then
		if IsHandle(object) then
			local obj = GameHelpers.TryGetObject(object)
			if obj then
				return obj.MyGuid
			end
		elseif object.MyGuid then
			return object.MyGuid
		end
	elseif t == "string" then
		return StringHelpers.GetUUID(object)
	elseif t == "number" then
		local obj = GameHelpers.TryGetObject(object)
		if obj then
			return obj.MyGuid
		end
	end
	if returnNullId then
		return StringHelpers.NULL_UUID
	end
	return nil
end

---Tries to get a NetID from whatever variable type object is.
---@param object ObjectParam
---@return NetId|nil
function GameHelpers.GetNetID(object)
	local t = _type(object)
	if t == "userdata" then
		if IsHandle(object) then
			local obj = GameHelpers.TryGetObject(object)
			if obj then
				return obj.NetID
			end
		elseif object.NetID then
			return object.NetID
		end
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

---Tries to get a `UUID` on the server side or `NetID` on the client side.
---@param object ObjectParam
---@return Guid|NetId|nil
function GameHelpers.GetObjectID(object)
	local t = _type(object)
	if t == "userdata" then
		if IsHandle(object) then
			local obj = GameHelpers.TryGetObject(object)
			if obj then
				if not _ISCLIENT then
					return obj.MyGuid
				else
					return obj.NetID
				end
			end
		elseif object.NetID then
			if not _ISCLIENT then
				return object.MyGuid
			else
				return object.NetID
			end
		end
	elseif t == "string" or t == "number" then
		local obj = GameHelpers.TryGetObject(object)
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

local _UNSET_USERID = -65536

---Get a character's user id, if any.
---@param obj Guid|EsvCharacter|EclCharacter
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

---@param char1 CharacterParam
---@param char2 CharacterParam
---@return boolean
function GameHelpers.CharacterUsersMatch(char1, char2)
	local character1 = char1
	local character2 = char2

	local t1 = _type(char1)
	local t2 = _type(char2)

	if not _ISCLIENT then
		if t1 == "string" and t2 == t1 then
			return Osi.CharacterGetReservedUserID(char1) == Osi.CharacterGetReservedUserID(char2)
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
		Ext.Utils.PrintWarning("[LeaderLib:SharedGameHelpers.lua:GameHelpers.CharacterUsersMatch] This check probably won't work on the client since UserID gets unset when a character isn't controlled, and ReservedUserID is not set/accessible.")
		return character1 ~= nil and character2 ~= nil and character1.UserID == character2.UserID
	end
end

---@param statItem CDivinityStatsItem
---@param tag string|string[]
function GameHelpers.StatItemHasTag(statItem, tag)
	local t = _type(tag)
	if t == "string" then
		local stat = Ext.Stats.Get(statItem.Name, nil, false)
		if stat and StringHelpers.DelimitedStringContains(stat.Tags, ";", tag) then
			return true
		end
		if statItem.DynamicStats then
			for _,v in pairs(statItem.DynamicStats) do
				if not StringHelpers.IsNullOrWhitespace(v.ObjectInstanceName) then
					local boost = Ext.Stats.Get(v.ObjectInstanceName, nil, false)
					if boost and not StringHelpers.IsNullOrEmpty(boost.Tags) and StringHelpers.DelimitedStringContains(boost.Tags, ";", tag) then
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

---@param item EsvItem|EclItem|Guid
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
		if _type(item) ~= "table" then
			if GameHelpers.Ext.ObjectIsStatItem(item) then
				---@cast item -string,-EclItem,-EsvItem,+CDivinityStatsItem
				return GameHelpers.StatItemHasTag(item, tag)
			else
				item = GameHelpers.GetItem(item)
				if item then
					return item:HasTag(tag) or (item.Stats and GameHelpers.StatItemHasTag(item.Stats, tag))
				end
			end
		elseif item.HasTag and item:HasTag(tag) == true then
			return true
		end
	end
	return false
end

---@overload fun(item:EsvItem|EclItem):string[]
---@overload fun(item:EsvItem|EclItem, inDictionaryFormat:nil, skipStats:boolean):string[]
---@param item EsvItem|EclItem
---@param inDictionaryFormat boolean
---@param skipStats boolean Skip checking the stat Tags attribute.
---@return table<string,boolean>
function GameHelpers.GetItemTags(item, inDictionaryFormat, skipStats)
	local tags = {}
	for _,v in pairs(item:GetTags()) do
		tags[v] = true
	end
	if not skipStats and item.Stats and item.StatsFromName and item.StatsFromName.StatsEntry then
		local tagsStr = item.StatsFromName.StatsEntry.Tags
		if not StringHelpers.IsNullOrWhitespace(tagsStr) then
			for _,v in pairs(StringHelpers.Split(tagsStr, ";")) do
				tags[v] = true
			end
		end
		for _,v in pairs(item.Stats.DynamicStats) do
			if not StringHelpers.IsNullOrWhitespace(v.ObjectInstanceName) then
				local dynamicStat = Ext.Stats.Get(v.ObjectInstanceName, nil, false)
				if dynamicStat then
					local tagsText = dynamicStat.Tags
					if not StringHelpers.IsNullOrWhitespace(tagsText) then
						for _,v in pairs(StringHelpers.Split(tagsText, ";")) do
							tags[v] = true
						end
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

---@param character CharacterParam
---@param tag string|string[]
function GameHelpers.CharacterOrEquipmentHasTag(character, tag)
	if _type(tag) == "table" then
		local _TAGS = GameHelpers.GetAllTags(character, true, true)
		for _,v in pairs(tag) do
			if _TAGS[v] then
				return true
			end
		end
		return false
	else
		---@cast tag string
		if _type(character) ~= "userdata" then
			character = GameHelpers.GetCharacter(character)
			if not character then
				fprint(LOGLEVEL.WARNING, "GameHelpers.CharacterOrEquipmentHasTag requires a uuid, netid, ObjectHandle, or EsvCharacter/EclCharacter. Values provided: character(%s) tag(%s)", character, tag)
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
	end
	return false
end

---@overload fun(object:ObjectParam):string[]
---Gather all tags for an object and store them in a table.
---@param object ObjectParam The character or item to get tags from.
---@param inDictionaryFormat? boolean If true, tags will be set as tbl[tag] = true, for easier checking.
---@param addEquipmentTags? boolean If the object is a character, all tags found on equipped items will be added to the table.
---@return table<string,boolean>
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
			---@cast object EsvItem|EclItem
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
		---@cast object EsvCharacter|EclCharacter
		local items = {}
		for _,slot in Data.VisibleEquipmentSlots:Get() do
			if _ISCLIENT then
				local item = object:GetItemObjectBySlot(slot)
				if item then
					items[#items+1] = item
				end
			else
				items = GameHelpers.Character.GetEquipment(object, true)
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

---Check if an object has a tag, or table of tags.
---@param object ObjectParam The character or item to get tags from.
---@param tags string|string[] Either a single tag, or an array of tags.
---@param requireAll? boolean If true, and tags is a table, all tags must be found.
---@param checkEquipmentTags? boolean If object is a character, included equipped items when checking for tags.
---@param cachedTags? table<string,boolean> If GameHelpers.GetAllTags has already been used, you can pass the dictionary table here to skip retrieving all tags again.
---@return boolean
function GameHelpers.ObjectHasTag(object, tags, requireAll, checkEquipmentTags, cachedTags)
	local object = GameHelpers.TryGetObject(object)
	if not object then
		return false
	end
	local _TAGS = cachedTags or GameHelpers.GetAllTags(object, true, checkEquipmentTags)
	local t = _type(tags)
	if t == "string" then
		if _TAGS[tags] then
			return true
		end
	elseif t == "table" then
		if requireAll then
			for i,v in pairs(tags) do
				if not _TAGS[v] then
					return false
				end
			end
			return true
		else
			for i,v in pairs(tags) do
				if _TAGS[v] then
					return true
				end
			end
		end
	end
	return false
end

---Checks if a character or item exists.
---@param object ObjectParam
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
				return Osi.ObjectExists(object.MyGuid) == 1
			end
		elseif t == "string" then
			return Osi.ObjectExists(object) == 1
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

---Checks if an item exists.
---@param item ItemParam
---@return boolean
function GameHelpers.ItemExists(item)
	local t = _type(item)
	if t == "string" and StringHelpers.IsNullOrWhitespace(item) then
		return false
	end
	if _osirisIsCallable() then
		if t == "userdata" then
			if IsHandle(item) then
				return _getItem(item) ~= nil
			elseif item.MyGuid then
				return Osi.ObjectExists(item.MyGuid) == 1
			end
		elseif t == "string" then
			return Osi.ObjectExists(item) == 1
		elseif t == "number" then
			return _getItem(item) ~= nil
		end
	end
	if t == "userdata" then
		if IsHandle(item) then
			return _getItem(item) ~= nil
		else
			return GameHelpers.Ext.ObjectIsItem(item)
		end
	elseif t == "string" or t == "number" then
		return _getItem(item) ~= nil
	end
	return false
end

---@param object ObjectParam
---@return boolean
function GameHelpers.ObjectIsDead(object)
	if _OSIRIS() then
		local GUID = GameHelpers.GetUUID(object)
		if not GUID then
			return false
		end
		if (Osi.ObjectIsCharacter(GUID) == 1 and Osi.CharacterIsDead(GUID) == 1) or (Osi.ObjectIsItem(GUID) == 1 and Osi.ItemIsDestroyed(GUID) == 1) then
			return true
		end
		return false
	end
	local object = _tryGetObject(object)
	if object then
		if GameHelpers.Ext.ObjectIsCharacter(object) then
			---@cast object EclCharacter|EsvCharacter
			return object.Dead == true or object:GetStatus("DYING") ~= nil
		elseif GameHelpers.Ext.ObjectIsItem(object) then
			---@cast object EclItem|EsvItem
			return object.Destroyed == true or (object.RootTemplate and object.RootTemplate.Destroyed == true)
		end
	end
	return false
end

---@return GameDifficulty
function GameHelpers.GetGameDifficulty()
	--int to string
	return Data.Difficulty(Ext.Utils.GetDifficulty())	
end

---@param obj ObjectParam
---@param flag string
function GameHelpers.ObjectHasFlag(obj, flag)
	if not _ISCLIENT and _osirisIsCallable() then
		local uuid = GameHelpers.GetUUID(obj)
		if uuid then
			return Osi.ObjectGetFlag(uuid, flag) == 1
			or (Osi.ObjectIsCharacter(uuid) == 1
			and Osi.PartyGetFlag(uuid, flag) == 1
			or Osi.UserGetFlag(uuid, flag) == 1)
		end
	end
	return false
end

---@param object ObjectParam
---@param ignorePolymorph? boolean
---@return string
local function _GetTemplateID(object, ignorePolymorph)
	local object = _tryGetObject(object, "EclCharacter")
	if object then
		local instanceData = object.CurrentTemplate or object.RootTemplate
		if instanceData then
			if ignorePolymorph then
				if not _ISCLIENT then
					for _,status in pairs(object:GetStatusObjects()) do
						if status.StatusType == "POLYMORPHED" then
							---@cast status EsvStatusPolymorphed
							if not StringHelpers.IsNullOrEmpty(status.OriginalTemplate)	then
								return status.OriginalTemplate
							end
						end
					end
				else
					if not StringHelpers.IsNullOrEmpty(object.RootTemplate.RootTemplate) and object.RootTemplate.RootTemplate ~= object.MyGuid then
						return object.RootTemplate.RootTemplate
					end
				end
			end
			--When not transformed, CurrentTemplate.Id is the character's MyGuid, and CurrentTemplate.RootTemplate is their root template.
			--When polymorphed etc, CurrentTemplate.Id is the polymorph root template, and CurrentTemplate.RootTemplate is empty.
			if instanceData.Id == object.MyGuid then
				if not StringHelpers.IsNullOrEmpty(instanceData.RootTemplate) then
					return instanceData.RootTemplate
				end
			elseif not StringHelpers.IsNullOrEmpty(instanceData.Id) then
				return instanceData.Id
			end
		end
	end
	return nil
end

--local t = Mods.LeaderLib.GameHelpers.GetTemplate(me.MyGuid, true, true); if t then print(t.Name) else print("nil") end

---@return CharacterTemplate|ItemTemplate
local _GetTemplateObject = Ext.Template.GetRootTemplate

if _EXTVERSION <= 59 and Ext.Utils.GameVersion() == Data.GameVersion.Editor then
	--Crashes when GetStaticSymbols().GetGlobalTemplateBank() is called in v58 of the extender, in the editor 
	_GetTemplateObject = function() return nil end
end

GameHelpers.GetTemplateObject = _GetTemplateObject

---@overload fun(obj:ObjectParam):Guid|nil
---Get an object's root template UUID.
---@param obj ObjectParam
---@param asGameObjectTemplate boolean Returns a GameObjectTemplate if true.
---@param ignorePolymorph? boolean Get the true root template if polymorphed.
---@return GameObjectTemplate|nil template
---@return Guid|nil templateGUID
function GameHelpers.GetTemplate(obj, asGameObjectTemplate, ignorePolymorph)
	local templateId = _GetTemplateID(obj, ignorePolymorph)
	if templateId and asGameObjectTemplate then
		return Ext.Template.GetRootTemplate(templateId), templateId
	end
	return templateId
end

---Get an object's owner, if any.
---@param obj CharacterObject|ItemObject
---@return CharacterObject|ItemObject|nil
function GameHelpers.GetOwner(object)
	if GameHelpers.Ext.ObjectIsItem(object) then
		return GameHelpers.Item.GetOwner(object)
	elseif GameHelpers.Ext.ObjectIsCharacter(object) then
		if not _ISCLIENT then
			---@cast object EsvCharacter
			if object.HasOwner then
				return GameHelpers.GetObjectFromHandle(object.OwnerHandle)
			end
		else
			---@cast object EclCharacter
			if object.HasOwner then
				return GameHelpers.GetObjectFromHandle(object.OwnerCharacterHandle)
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
	if not _ranCachedLevels then
		if _GS() == "Running" then
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
	return LEVELTYPE.GAME
end

---@param levelType LEVELTYPE|string|integer
---@param levelName? string Optional level to use when checking.
---@return boolean
function GameHelpers.IsLevelType(levelType, levelName)
	--Assuming levelType is actually levelName and levelName is LEVELTYPE, swap the params
	if not LEVELTYPE[levelType] and LEVELTYPE[levelName] then
		---@cast levelType string
		---@cast levelName LEVELTYPE
		local lt = levelName
		levelName = levelType
		levelType = lt
	end
	if levelName == nil then
		local level = Ext.Entity.GetCurrentLevel()
		if level then
			levelName = level.LevelDesc.LevelName
		end
	end
	if not StringHelpers.IsNullOrEmpty(levelName) then
		return GameHelpers.GetLevelType(levelName) == levelType
	end
	return false
end

local TAG_PREFIX = "LeaderLib_ResistancePenetration_"

---@deprecated
---@see GameHelpers.Stats.GetResistancePenetration
---@param tag string A tag such as LeaderLib_ResistancePenetration_Poison50
---@return string damageType
---@return integer amount
function GameHelpers.ParseResistancePenetrationTag(tag)
	if string.find(tag, TAG_PREFIX) then
		local strippedTag = string.gsub(tag, TAG_PREFIX, "")
		local damageType = string.match(strippedTag, "%a+")
		local amount = tonumber(string.match(strippedTag, "%d+"))
		if damageType and amount and Data.DamageTypes[damageType] then
			return damageType,amount
		end
	end
	return nil, 0
end

--local amt = 3; local dl = Ext.Stats.NewDamageList(); dl:Add("Fire", 4); dl:Add("Water", 3); local ndl = Mods.LeaderLib.GameHelpers.Damage.DivideDamage(dl, amt); local pdl = {}; for _,v in pairs(ndl) do table.insert(pdl, v:ToTable()) end; Ext.Dump(pdl)

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
				local newDamageList = Ext.Stats.NewDamageList()
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
---@return string
function GameHelpers.GetDisplayName(obj)
	local obj = _tryGetObject(obj)
	if obj then
		if GameHelpers.Ext.ObjectIsCharacter(obj) then
			return GameHelpers.Character.GetDisplayName(obj)
		elseif GameHelpers.Ext.ObjectIsItem(obj) then
			if string.find(obj.DisplayName, "|") or obj.RootTemplate.DisplayName.Handle == nil then
				if GameHelpers.Item.IsObject(obj) then
					if not StringHelpers.IsNullOrEmpty(obj.StatsId) and not Data.ItemRarity[obj.StatsId] then
						local name = GameHelpers.GetStringKeyText(obj.StatsId, "")
						if not StringHelpers.IsNullOrEmpty(name) then
							return name
						end
					end
				elseif obj.Stats.DisplayName then
					local name = GameHelpers.GetTranslatedStringValue(obj.Stats.DisplayName, "")
					if name ~= "" then
						return name
					end
				end
				return GameHelpers.GetTranslatedStringValue(obj.CurrentTemplate.DisplayName, obj.DisplayName)
			end
			return obj.DisplayName
		end
	end
	return ""
end

---Calculates Movement and MovementSpeedBoost from DynamicStats.
---@param obj ObjectParam|StatCharacter|StatItemDynamic
---@param asFullAmount? boolean Return Movement in the full amount (like 500), instead of multiplying it by 0.01 and rounding the result.
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
---@param persist? boolean
function GameHelpers.SetScale(object, scale, persist)
	object = GameHelpers.TryGetObject(object)
	if object and object.Scale then
		object.Scale = scale
		if not _ISCLIENT then
			GameHelpers.SyncScale(object)
			if persist == true then
				_PV.ScaleOverride[object.MyGuid] = scale
			end
		end
	end
end

---Converts an integer color to a hex code.
---@param int integer
---@return string
function GameHelpers.IntegerColorToHex(int)
	return string.format("#%06X", (0xFFFFFF & int))
end

---Get skill damage from registered Ext.Events.GetSkillDamage listeners, or Game.Math.GetSkillDamage.
---@param skillId string The skill ID, i.e "Projectile_Fireball".
---@param character? CharacterParam The character to use. Defaults to Client:GetCharacter if on the client-side, or the host otherwise.
---@param skillParams? StatEntrySkillData A table of attributes to set on the skill table before calculating the damage.
---@param noRandomization? boolean
---@return StatsDamagePairList|nil
function GameHelpers.Damage.GetSkillDamage(skillId, character, skillParams, noRandomization)
	if noRandomization == nil then
		noRandomization = true
	end
	if not StringHelpers.IsNullOrWhitespace(skillId) then
		local skill = GameHelpers.Ext.CreateSkillTable(skillId, nil, true)
		if skill ~= nil then
			if _type(skillParams) == "table" then
				for k,v in pairs(skillParams) do
					skill[k] = v
				end
			end
			if character then
				character = GameHelpers.GetCharacter(character)
			end
			if character == nil then
				if _ISCLIENT then
					character = Client:GetCharacter()
				elseif _OSIRIS() then
					character = GameHelpers.GetCharacter(Osi.CharacterGetHostCharacter())
				end
			end
			if character ~= nil and character.Stats ~= nil then
				local useDefaultSkillDamage = true
				if Ext.Events.GetSkillDamage then
					---@type {Attacker:StatCharacter, AttackerPosition:number[], DamageList:DamageList, DeathType:DeathType, IsFromItem:boolean, Level:integer, Skill:StatEntrySkillData, Stealthed:boolean, TargetPosition:number[]}
					local evt = GameHelpers.Ext.CreateEventTable("GetSkillDamage", {
						Attacker = character.Stats,
						AttackerPosition = character.WorldPos,
						DamageList = Ext.Stats.NewDamageList(),
						DeathType = "None",
						IsFromItem = false,
						Level = character.Stats.Level,
						NoRandomization = noRandomization == true,
						Skill = skill,
						Stealthed = character.Stats.IsSneaking == true,
						TargetPosition = character.WorldPos,
					})
					Ext.Events.GetSkillDamage:Throw(evt)
					if evt.DamageList then
						local hasDamage = false
						for _,v in pairs(evt.DamageList:ToTable()) do
							if v.Amount > 0 then
								hasDamage = true
								break
							end
						end
						if hasDamage then
							return evt.DamageList
						end
					end
				end

				if useDefaultSkillDamage then
					local damageList,deathType = Game.Math.GetSkillDamage(skill, character.Stats, false, character.Stats.IsSneaking == true, character.WorldPos, character.WorldPos, character.Stats.Level, noRandomization, nil, nil)
					return damageList
				end
			end
		end
	end
	return nil
end

---@param guid Guid The mod GUID.
---@param stripFont? boolean Strip all font tags.
---@return string name
function GameHelpers.GetModName(guid, stripFont)
	local mod = Ext.Mod.GetMod(guid)
	if mod and mod.Info then
		local name = GameHelpers.GetTranslatedStringValue(mod.Info.DisplayName, mod.Info.Name)
		if stripFont then
			name = StringHelpers.StripFont(name) or name
		end
		return name
	end
	return ""
end

---@param guid Guid The mod GUID.
---@param stripFont? boolean Strip all font tags.
---@return string description
function GameHelpers.GetModDescription(guid, stripFont)
	local mod = Ext.Mod.GetMod(guid)
	if mod and mod.Info then
		local desc = GameHelpers.Tooltip.ReplacePlaceholders(GameHelpers.GetTranslatedStringValue(mod.Info.DisplayDescription, mod.Info.Description))
		if stripFont then
			desc = StringHelpers.StripFont(desc) or desc
		end
		return desc
	end
	return ""
end

---@param guid Guid The mod GUID.
---@param asSingleInteger? boolean Return the combined version integer.
---@return string description
function GameHelpers.GetModVersion(guid, asSingleInteger)
	--[[ local mod = Ext.Mod.GetMod(guid)
	if mod and mod.Info then
		if asSingleInteger then
			local major,minor,revision,build = table.unpack(mod.Info.ModVersion)
			local versionInt = (major << 28) + (minor << 24) + (revision << 16) + (build)
			return versionInt
		else
			return table.unpack(mod.Info.ModVersion)
		end
	end ]]
	--Ext.Mod.GetMod().Info.ModVersion needs a fix in v57
	local info = Ext.Mod.GetModInfo(guid)
	if info then
		return info.Version
	end
	return -1
end

---@param obj ObjectParam
---@return boolean
function GameHelpers.IsInCombat(obj)
	if _OSIRIS() then
		local uuid = GameHelpers.GetUUID(obj)
		if not uuid then
			return false
		end
		if Osi.ObjectIsCharacter(uuid) == 1 and Osi.CharacterIsInCombat(uuid) == 1 then
			return true
		else
			local db = Osi.DB_CombatObjects:Get(uuid, nil)
			if db ~= nil and #db > 0 then
				return true
			end
		end
	else
		return GameHelpers.Status.IsActive(obj, "COMBAT")
	end
	return false
end

---Get a skill cooldown for a character. Defaults to 0 if the character doesn't have the skill.
---@param char CharacterParam
---@param skill FixedString
---@return number cooldown
function GameHelpers.Skill.GetCooldown(char, skill)
	local character = GameHelpers.GetCharacter(char)
	assert(character ~= nil, "A valid Esv/EclCharacter, NetID, or UUID is required.")
	local skillData = character.SkillManager.Skills[skill]
	if skillData then
		return skillData.ActiveCooldown
	end
	return 0
end

---Get the game's current language.
---@return "Amlatspanish"|"Chinese"|"Chinesetraditional"|"Czech"|"English"|"French"|"German"|"Italian"|"Japanese"|"Korean"|"Polish"|"Portuguesebrazil"|"Russian"|"Spanish"|string
function GameHelpers.GetLanguage()
	local switches = Ext.Utils.GetGlobalSwitches()
	if switches then
		return switches.ChatLanguage
	end
	return ""
end