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
				if ObjectIsCharacter(character.MyGuid) == 1 and character.IsPlayer then
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
			return character.Summon or character.PartyFollower
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

---@param includeSummons boolean|nil
---@return fun():EsvCharacter|EclCharacter
function GameHelpers.Character.GetPlayers(includeSummons)
	local players = {}
	if not isClient then
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

	local i = 0
	local count = #players
	return function ()
		i = i + 1
		if i <= count then
			return players[i]
		end
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
						local summon = Ext.GetGameObject(character)
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