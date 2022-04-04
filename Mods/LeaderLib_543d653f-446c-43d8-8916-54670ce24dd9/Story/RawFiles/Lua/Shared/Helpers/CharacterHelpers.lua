if GameHelpers.Character == nil then
	GameHelpers.Character = {}
end

local isClient = Ext.IsClient()

---@param character EsvCharacter|EclCharacter|UUID|NETID
---@return boolean
function GameHelpers.Character.IsPlayer(character)
	if not character then
		return false
	end
	local t = type(character)
	if t == "userdata" and GameHelpers.Ext.ObjectIsItem(character) then
		return false
	end
	if not isClient then
		if not Ext.OsirisIsCallable() then
			if t == "string" or t == "number" then
				character = GameHelpers.GetCharacter(character)
			end
			if character and (character.IsPlayer or character.IsGameMaster) then
				return true
			end
		else
			if t == "userdata" then
				if ObjectIsCharacter(character.MyGuid) == 1 and (character.IsPlayer or character.IsGameMaster) then
					return true
				end
				character = character.MyGuid
			end
			if type(character) == "string" then
				return CharacterIsPlayer(character) == 1 or CharacterGameMaster(character) == 1 or GameHelpers.DB.HasUUID("DB_IsPlayer", character) 
			end
		end
	else
		if t ~= "userdata" then
			character = GameHelpers.GetCharacter(character)
		end
		---@type EclCharacter
		local clientCharacter = character
		if clientCharacter then
			if Client.Character.NetID == clientCharacter.NetID then
				if Client.Character.IsPlayer or Client.Character.IsGameMaster then
					return true
				end
			end
			return clientCharacter.PlayerCustomData ~= nil
		end
	end
	return false
end

---Returns true if the character IsGameMaster or IsPossessed
---@param character EsvCharacter|EclCharacter|UUID|NETID
---@param ignorePossessed ?boolean
---@return boolean
function GameHelpers.Character.IsGameMaster(character, ignorePossessed)
	if not character then
		return false
	end
	local t = type(character)
	if t == "userdata" and GameHelpers.Ext.ObjectIsItem(character) then
		return false
	end
	character = GameHelpers.GetCharacter(character)
	if not character then
		return false
	end
	if not isClient then
		return character.IsGameMaster or (not ignorePossessed and character.IsPossessed)
	else
		for uuid,data in pairs(SharedData.CharacterData) do
			if data.NetID == character.NetID and (data.IsGameMaster or (not ignorePossessed and data.IsPossessed)) then
				return true
			end
		end
		local gm = GameHelpers.Client.GetGameMaster()
		if gm and gm.NetID == character.NetID then
			return true
		end
	end
	return false
end

---@param character EsvCharacter|EclCharacter|UUID|NETID
---@return boolean
function GameHelpers.Character.IsPlayerOrPartyMember(character)
	if GameHelpers.Character.IsPlayer(character) then
		return true
	end
	if not isClient and Ext.OsirisIsCallable() then
		return CharacterIsPartyMember(character) == 1
	end
	return false
end

---@param character EsvCharacter|EclCharacter|UUID|NETID
function GameHelpers.Character.IsOrigin(character)
	if not isClient and Ext.OsirisIsCallable() then
		character = GameHelpers.GetUUID(character)
		if not character then return false end
		return GameHelpers.DB.HasUUID("DB_Origins", character)
	else
		character = GameHelpers.GetCharacter(character)
		if type(character) == "userdata" then
			return character.PlayerCustomData and not StringHelpers.IsNullOrWhitespace(character.PlayerCustomData.OriginName)
		end
	end
	return false
end

---@param character EsvCharacter|EclCharacter|UUID|NETID
function GameHelpers.Character.IsInCharacterCreation(character)
	if not isClient and Ext.OsirisIsCallable() then
		character = GameHelpers.GetUUID(character)
		if not character then return false end
		if GameHelpers.DB.HasUUID("DB_Illusionist", character, 2, 1) then
			return true
		end
		if SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION then
			return GameHelpers.DB.HasUUID("DB_AssignedDummyForUser", character, 2, 2)
		end
	else
		---@type EclCharacter
		local player = GameHelpers.GetCharacter(character)
		if type(player) == "userdata" then
			local currentCC = GameHelpers.Client.GetCharacterCreationCharacter()
			if currentCC and currentCC.NetID == player.NetID then
				return true
			end
		end
	end
	return false
end

---@param character EsvCharacter|EclCharacter|UUID|NETID
function GameHelpers.Character.IsSummonOrPartyFollower(character)
	if not isClient then
		if type(character) == "userdata" then
			return character.Summon or character.PartyFollower
		elseif type(character) == "string" then
			return CharacterIsSummon(character) == 1 or CharacterIsPartyFollower(character) == 1
		end
	else
		if type(character) ~= "userdata" then
			character = GameHelpers.GetCharacter(character)
		end
		if character then
			return character.HasOwner or character.PartyFollower
		end
	end
	return false
end

---@param character EsvCharacter|EclCharacter|UUID|NETID
function GameHelpers.Character.IsAllyOfParty(character)
	if not isClient and Ext.OsirisIsCallable() then
		character = GameHelpers.GetUUID(character)
		if not character then return false end
		for player in GameHelpers.Character.GetPlayers(false) do
			if CharacterIsAlly(character, player.MyGuid) == 1 then
				return true
			end
		end
	end
	return false
end

---@param character EsvCharacter|EclCharacter|UUID|NETID
function GameHelpers.Character.IsEnemyOfParty(character)
	if not isClient and Ext.OsirisIsCallable() then
		character = GameHelpers.GetUUID(character)
		if not character then return false end
		for player in GameHelpers.Character.GetPlayers(false) do
			if CharacterIsEnemy(character, player.MyGuid) == 1 then
				return true
			end
		end
	end
	return false
end

---@param char1 UUID|NETID|EsvCharacter
---@param char2 UUID|NETID|EsvCharacter
function GameHelpers.Character.IsEnemy(char1, char2)
	if not isClient and Ext.OsirisIsCallable() then
		local a = GameHelpers.GetUUID(char1)
		local b = GameHelpers.GetUUID(char2)
		if not a or not b then return false end
		return CharacterIsEnemy(a,b) == 1
	end
	return false
end

---@param character EsvCharacter|EclCharacter|UUID|NETID
function GameHelpers.Character.IsNeutralToParty(character)
	if not isClient and Ext.OsirisIsCallable() then
		character = GameHelpers.GetUUID(character)
		if not character then return false end
		for player in GameHelpers.Character.GetPlayers(false) do
			if CharacterIsNeutral(character, player.MyGuid) == 1 then
				return true
			end
		end
	end
	return false
end

---@param character EsvCharacter|EclCharacter|UUID|NETID
function GameHelpers.Character.IsInCombat(character)
	if not isClient and Ext.OsirisIsCallable() then
		character = GameHelpers.GetUUID(character)
		if not character then return false end
		if CharacterIsInCombat(character) == 1 then
			return true
		elseif GameHelpers.DB.HasUUID("DB_CombatCharacters", character, 2, 1) then
			return true
		end
	else
		character = GameHelpers.GetCharacter(character)
		return character and character:GetStatus("COMBAT") ~= nil
	end
	return false
end

---@return integer
function GameHelpers.Character.GetHighestPlayerLevel()
	local level = 1
	if not isClient then
		for player in GameHelpers.Character.GetPlayers(false) do
			if player.Stats.Level > level then
				level = player.Stats.Level
			end
		end
	else
		for profile,data in pairs(SharedData.CharacterData) do
			local character = data:GetCharacter()
			if character and character.Stats and character.Stats.Level > level then
				level = character.Stats.Level
			end
		end
	end
	return level
end

---@param character EsvCharacter|EclCharacter|UUID|NETID
---@return boolean
function GameHelpers.Character.IsUndead(character)
	if type(character) ~= "userdata" then
		character = GameHelpers.GetCharacter(character)
	end
	if character and character.HasTag then
		if character:HasTag("UNDEAD") or character.Stats.TALENT_Zombie then
			return true
		end
	end
	return false
end

---Returns true if the character is one of the regular humanoid races.
---@param character EsvCharacter|EclCharacter|UUID|NETID
---@return boolean
function GameHelpers.Character.IsHumanoid(character)
	character = GameHelpers.GetCharacter(character)
	if character and character.HasTag then
		for raceId,raceData in pairs(Vars.RaceData) do
			if character:HasTag(raceData.Tag) 
			or character:HasTag(raceData.BaseTag)
			or string.find(character.RootTemplate.TemplateName, raceId)
			or (character.PlayerCustomData and character.PlayerCustomData.Race == raceId) then
				return true
			end
		end
	end
	return false
end

---@param character EsvCharacter|EclCharacter|UUID|NETID
---@return boolean
function GameHelpers.Character.GetDisplayName(character)
	if not character then
		return ""
	end
	if type(character) ~= "userdata" then
		character = GameHelpers.GetCharacter(character)
	end
	if character then
		local name = character.DisplayName
		if StringHelpers.IsNullOrWhitespace(name) or string.find(name, "|", 1, true) then
			if not isClient then
				local handle,ref = CharacterGetDisplayName(character.MyGuid)
				return Ext.GetTranslatedString(handle, not StringHelpers.IsNullOrWhitespace(name) and name or ref)
			else
				return name
			end
		else
			return name
		end
	end
	return ""
end

---@param includeSummons ?boolean
---@param asTable ?boolean if true, a regular table is returned, which needs to be used with pairs/ipairs.
---@return fun():EsvCharacter|EclCharacter
function GameHelpers.Character.GetPlayers(includeSummons, asTable)
	local players = {}
	if not isClient then
		if SharedData.RegionData.LevelType == LEVELTYPE.GAME and Ext.OsirisIsCallable() then
			for _,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
				local player = GameHelpers.GetCharacter(db[1])
				players[#players+1] = player
				if includeSummons == true then
					local summons = PersistentVars.Summons[player.MyGuid]
					if summons then
						for i,v in pairs(summons) do
							if ObjectIsCharacter(v) == 1 then
								local summon = GameHelpers.GetCharacter(v)
								if summon then
									players[#players+1] = summon
								end
							end
						end
					end
				end
			end
		else
			local isCC = SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION
			for _,v in pairs(Ext.GetAllCharacters()) do
				local character = GameHelpers.GetCharacter(v)
				if character and character.IsPlayer and not isCC or (isCC and character.CharacterControl) then
					players[#players+1] = character
				end
			end
		end
		if SharedData.GameMode == GAMEMODE.GAMEMASTER then
			local gm = StringHelpers.GetUUID(CharacterGetHostCharacter())
			if not StringHelpers.IsNullOrEmpty(gm) then
				gm = GameHelpers.GetCharacter(gm)
				if not Common.TableHasValue(players, gm) then
					players[#players+1] = gm
				end
			end
		end
	else
		for mc in StatusHider.PlayerInfo:GetCharacterMovieClips(not includeSummons) do
			local character = GameHelpers.GetCharacter(Ext.DoubleToHandle(mc.characterHandle))
			if character then
				players[#players+1] = character
			end
		end
	end

	if not asTable then
		local i = 0
		local count = #players
		return function ()
			i = i + 1
			if i <= count then
				return players[i]
			end
		end
	else
		return players
	end
end

---@param includeSummons boolean|nil
---@return integer
function GameHelpers.Character.GetPartySize(includeSummons)
	local count = 0
	local players = {}
	if not isClient then
		for _,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
			local player = GameHelpers.GetCharacter(db[1])
			if player then
				count = count + 1
			end
			if includeSummons == true then
				local summons = PersistentVars.Summons[player.MyGuid]
				if summons then
					for i,v in pairs(summons) do
						if ObjectIsCharacter(v) == 1 then
							local summon = GameHelpers.GetCharacter(v)
							if summon then
								count = count + 1
							end
						end
					end
				end
			end
		end
	else
		for mc in StatusHider.PlayerInfo:GetCharacterMovieClips(not includeSummons) do
			count = count + 1
		end
	end

	return count
end

---Gets all the active summons of a character.
---@param owner EsvCharacter|EclCharacter|UUID|NETID
---@param getItems boolean|nil If on the server, item summons can be fetched as well.
---@return fun():EsvCharacter|EclCharacter
function GameHelpers.Character.GetSummons(owner, getItems)
	local summons = {}

	local matchId = nil

	if not isClient then
		if type(owner) == "userdata" then
			matchId = owner.MyGuid
		elseif type(owner) == "string" then
			matchId = owner
		end
		for ownerId,tbl in pairs(PersistentVars.Summons) do
			if not matchId or ownerId == matchId then
				for i,character in pairs(tbl) do
					if getItems == true or ObjectIsItem(character) == false then
						local summon = GameHelpers.TryGetObject(character)
						if summon then
							summons[#summons+1] = summon
						end
					end
				end
			end
		end
	else
		if type(owner) == "userdata" then
			matchId = Ext.HandleToDouble(owner.Handle)
		else
			matchId = owner
		end
		for mc in StatusHider.PlayerInfo:GetSummonMovieClips(matchId) do
			local character = GameHelpers.GetCharacter(Ext.DoubleToHandle(mc.characterHandle))
			if character then
				summons[#summons+1] = character
			end
		end
	end

	local i = 0
	local count = #summons
	return function ()
		i = i + 1
		if i <= count then
			return summons[i]
		end
	end
end

---@param character EsvCharacter|EclCharacter
---@param asMeters boolean|nil If true, the range is returned as meters (WeaponRange/100).
---@return number
function GameHelpers.Character.GetWeaponRange(character, asMeters)
	local range = Ext.GetStat("NoWeapon").WeaponRange
	character = GameHelpers.GetCharacter(character)
	if character then
		if isClient then
			local mainhand = character:GetItemBySlot("Weapon")
			local offhand = character:GetItemBySlot("Shield")
			if mainhand then
				range = mainhand.Stats.WeaponRange
			end
			if offhand then
				if offhand.Stats.WeaponRange > range or mainhand == nil then
					range = offhand.Stats.WeaponRange
				end
			end
		else
			local mainhand = GameHelpers.Item.GetItemInSlot(character, "Weapon")
			local offhand = GameHelpers.Item.GetItemInSlot(character, "Shield")
			if mainhand then
				range = mainhand.Stats.WeaponRange
			end
			if offhand then
				if offhand.Stats.WeaponRange > range or mainhand == nil then
					range = offhand.Stats.WeaponRange
				end
			end
		end
	end
	if asMeters then
		return GameHelpers.Math.Round(range/100, 2)
	end
	return range
end

---@param character EsvCharacter|EclCharacter
---@param target EsvCharacter|EsvItem|number[]
---@return boolean
function GameHelpers.Character.IsWithinWeaponRange(character, target)
	local weaponRange = GameHelpers.Character.GetWeaponRange(target, true)
	return GameHelpers.Math.GetDistance(character, target) <= weaponRange
end

---@param character EsvCharacter|EclCharacter|UUID|NETID
function GameHelpers.Character.IsUnsheathed(character)
	if not isClient and Ext.OsirisIsCallable() then
		character = GameHelpers.GetUUID(character)
		if not character then return false end
		return HasActiveStatus(character, "UNSHEATHED") == 1 or CharacterIsInFightMode(character) == 1
	else
		---@type EclCharacter
		local character = GameHelpers.GetCharacter(character)
		if character then
			return character:GetStatus("UNSHEATHED") ~= nil
		end
	end
	return false
end

---Returns true if the character is disabled by a status.
---@param character EsvCharacter|string
---@param checkForLoseControl boolean
---@return boolean
function GameHelpers.Character.IsDisabled(character, checkForLoseControl)
	if type(character) == "string" then
		character = Ext.GetCharacter(character)
	end
	if character == nil then
		return false
	end
	if GameHelpers.Status.HasStatusType(character.MyGuid, {"KNOCKED_DOWN", "INCAPACITATED"}) then
		return true
	elseif checkForLoseControl == true then -- LoseControl on items is a good way to crash
		for _,status in pairs(character:GetStatusObjects()) do
			if status.StatusId == "CHARMED" then
				return GameHelpers.Status.IsFromEnemy(status, character)
			end
			if Data.EngineStatus[status.StatusId] ~= true then
				local stat = Ext.GetStat(status.StatusId)
				if stat and stat.LoseControl == "Yes" then
					if GameHelpers.Status.IsFromEnemy(status, character) then
						return true
					end
				end
			end
		end
	end
	return false
end

GameHelpers.Status.IsDisabled = GameHelpers.Character.IsDisabled

---Returns true if the object is sneaking or has an INVISIBLE type status.
---@param character EsvCharacter|UUID|NETID
---@return boolean
function GameHelpers.Character.IsSneakingOrInvisible(character)
	if GameHelpers.Status.IsActive(character, "SNEAKING")
	or GameHelpers.Status.IsActive(character, "INVISIBLE")
	or GameHelpers.Status.HasStatusType(character, "INVISIBLE")
	then
		return true
	end
    return false
end

if not isClient then
	Ext.NewQuery(GameHelpers.Character.IsSneakingOrInvisible, "LeaderLib_Ext_QRY_IsSneakingOrInvisible", "[in](GUIDSTRING)_Object, [out](INTEGER)_Bool")
end

GameHelpers.Status.IsSneakingOrInvisible = GameHelpers.Character.IsSneakingOrInvisible

---Shortcut for GameHelpers.Surface.HasSurface, using the character's position.
---@param character EsvCharacter|EclCharacter
---@param matchNames string|string[] Surface names to look for.
---@param maxRadius number|nil
---@param containingName boolean Look for surfaces containing the name, instead of explicit matching.
---@param onlyLayer integer Look only on layer 0 (ground) or 1 (clouds).
---@param grid AiGrid|nil
---@return boolean
function GameHelpers.Character.IsInSurface(character, matchNames, maxRadius, containingName, onlyLayer, grid)
	local pos = GameHelpers.Math.GetPosition(character, false, false)
	if pos then
		if containingName == nil then
			containingName = true
		end
		return GameHelpers.Surface.HasSurface(pos[1], pos[3], matchNames, maxRadius or 6.0, containingName, onlyLayer, grid)
	end
	return false
end

---Equips an item to its stats Slot using NRD_CharacterEquipItem, and moves any existing item in that slot to the character's inventory.
---@param character EsvCharacter|UUID
---@param item EclItem|UUID
---@return boolean
function GameHelpers.Character.EquipItem(character, item)
	if not isClient then
		local uuid = GameHelpers.GetUUID(character)
		fassert(not StringHelpers.IsNullOrEmpty(uuid) and ObjectExists(uuid) == 1, "Character (%s) must be a valid UUID or EsvCharacter", character)
		item = GameHelpers.GetItem(item)
		fassert(item ~= nil and not GameHelpers.Item.IsObject(item), "Item (%s) must be a non-object item.", item and item.StatsId or "nil")
		fassert(ItemIsEquipable(item.MyGuid) == 1, "Item (%s) is not equipable.", item.StatsId)
		if item.Stats.Slot == "Weapon" then
			local mainhand = GameHelpers.Item.GetItemInSlot(uuid, "Weapon")
			local offhand = GameHelpers.Item.GetItemInSlot(uuid, "Shield")
			if item.Stats.IsTwoHanded then
				if mainhand then
					ItemLockUnEquip(mainhand.MyGuid, 0)
					ItemToInventory(mainhand.MyGuid, uuid, 1, 0, 0)
				end
				if offhand then
					ItemLockUnEquip(offhand.MyGuid, 0)
					ItemToInventory(offhand.MyGuid, uuid, 1, 0, 0)
				end
				NRD_CharacterEquipItem(uuid, item.MyGuid, "Weapon", 0, 0, 1, 1)
				return true
			else
				if mainhand then
					if not offhand then
						NRD_CharacterEquipItem(uuid, item.MyGuid, "Shield", 0, 0, 1, 1)
						return true
					else
						ItemLockUnEquip(mainhand.MyGuid, 0)
						ItemToInventory(mainhand.MyGuid, uuid, 1, 0, 0)
						NRD_CharacterEquipItem(uuid, item.MyGuid, "Weapon", 0, 0, 1, 1)
						return true
					end
				else
					NRD_CharacterEquipItem(uuid, item.MyGuid, "Weapon", 0, 0, 1, 1)
					return true
				end
			end
		elseif item.Stats.Slot == "Shield" then
			local offhand = GameHelpers.Item.GetItemInSlot(uuid, "Shield")
			if offhand then
				ItemLockUnEquip(offhand.MyGuid, 0)
				ItemToInventory(offhand.MyGuid, uuid, 1, 0, 0)
			end
			NRD_CharacterEquipItem(uuid, item.MyGuid, "Shield", 0, 0, 1, 1)
			return true
		else
			local existing = GameHelpers.Item.GetItemInSlot(uuid, item.Stats.Slot)
			if existing then
				ItemLockUnEquip(existing.MyGuid, 0)
				ItemToInventory(existing.MyGuid, uuid, 1, 0, 0)
			end
			NRD_CharacterEquipItem(uuid, item.MyGuid, item.Stats.Slot, 0, 0, 1, 1)
			return true
		end
	end
	return false
end

---@param character EsvCharacter|EclCharacter|UUID|NETID
function GameHelpers.Character.IsImmobile(character)
	local character = GameHelpers.GetCharacter(character)
	if character then
		if character.Stats.Movement <= 0 then
			return true
		end
	end
	return false
end

---Checks if a character has a specific object/party/user flag.
---@param character EsvCharacter|EclCharacter|UUID|NETID
---@param flag string|string[]
---@return boolean
function GameHelpers.Character.HasFlag(character, flag)
	if not isClient and Ext.OsirisIsCallable() then
		local uuid = GameHelpers.GetUUID(character)
		if uuid then
			local t = type(flag)
			if t == "table" then
				for k,v in pairs(flag) do
					if GameHelpers.Character.HasFlag(character, v) then
						return true
					end
				end
			elseif t == "string" then
				return ObjectGetFlag(uuid, flag) == 1
				or PartyGetFlag(uuid, flag) == 1
				or UserGetFlag(uuid, flag) == 1
			else
				error("flag parameter must be a string or table of strings.", 2)
			end
		end
	end
	return false
end

---Returns true if the target is an enemy or Friendly Fire is enabled.
---@param target UUID|NETID|EsvCharacter|EclCharacter
---@param attacker ?UUID|NETID|EsvCharacter|EclCharacter If not specified, then this will return true if the target is an enemy of the party.
---@param allowItems ?boolean If true, this will return true if target is an item.
---@return boolean
function GameHelpers.Character.CanAttackTarget(target, attacker, allowItems)
	target = GameHelpers.TryGetObject(target)
	if allowItems and GameHelpers.Ext.ObjectIsItem(target) then
		return true
	end
	assert(GameHelpers.Ext.ObjectIsCharacter(target), "target parameter must be a UUID, NetID, or Esv/EclCharacter")
	if target:HasTag("LeaderLib_FriendlyFireEnabled") then
		return true
	end
	if not attacker then
		return GameHelpers.Character.IsEnemyOfParty(target)
	end
	attacker = GameHelpers.GetCharacter(attacker)
	assert(GameHelpers.Ext.ObjectIsCharacter(attacker), "attacker parameter must be a UUID, NetID, or Esv/EclCharacter")
	return GameHelpers.Character.IsEnemy(target, attacker)
end