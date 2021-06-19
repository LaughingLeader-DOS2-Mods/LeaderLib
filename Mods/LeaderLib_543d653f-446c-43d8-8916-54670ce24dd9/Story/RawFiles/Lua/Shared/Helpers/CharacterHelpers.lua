if GameHelpers.Character == nil then
	GameHelpers.Character = {}
end

local isClient = Ext.IsClient()

---@param character EsvCharacter|EclCharacter|string|number
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
				character = Ext.GetCharacter(character)
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
			character = Ext.GetCharacter(character)
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

---@param character EsvCharacter|EclCharacter|string|number
---@return boolean
function GameHelpers.Character.IsPlayerOrPartyMember(character)
	if GameHelpers.Character.IsPlayer(character) then
		return true
	end
	if not isClient then
		return CharacterIsPartyMember(character) == 1
	end
	return false
end

function GameHelpers.Character.IsOrigin(uuid)
	if not isClient then
		return GameHelpers.DB.HasUUID("DB_Origins", uuid)
	else
		if type(uuid) ~= "userdata" then
			uuid = Ext.GetCharacter(uuid)
		end
		if uuid then
			return uuid.PlayerCustomData and not StringHelpers.IsNullOrWhitespace(uuid.PlayerCustomData.OriginName)
		end
	end
	return false
end

---@param character EsvCharacter|EclCharacter
function GameHelpers.Character.IsSummonOrPartyFollower(character)
	if not isClient then
		if type(character) == "userdata" then
			return character.Summon or character.PartyFollower
		elseif type(character) == "string" then
			return CharacterIsSummon(character) == 1 or CharacterIsPartyFollower(character) == 1
		end
	else
		if type(character) ~= "userdata" then
			character = Ext.GetCharacter(character)
		end
		if character then
			return character.Summon or character.PartyFollower
		end
	end
	return false
end

function GameHelpers.Character.IsAllyOfParty(uuid)
	if not isClient then
		uuid = GameHelpers.GetUUID(uuid)
		for player in GameHelpers.Character.GetPlayers(false) do
			if CharacterIsAlly(uuid, player.MyGuid) == 1 then
				return true
			end
		end
	end
	return false
end

function GameHelpers.Character.IsEnemyOfParty(uuid)
	if not isClient then
		uuid = GameHelpers.GetUUID(uuid)
		for player in GameHelpers.Character.GetPlayers(false) do
			if CharacterIsEnemy(uuid, player.MyGuid) == 1 then
				return true
			end
		end
	end
	return false
end

function GameHelpers.Character.IsEnemy(obj1, obj2)
	if not isClient then
		local a = GameHelpers.GetUUID(obj1)
		local b = GameHelpers.GetUUID(obj2)
		return CharacterIsEnemy(a,b) == 1
	end
	return false
end

function GameHelpers.Character.IsNeutralToParty(uuid)
	if not isClient then
		uuid = GameHelpers.GetUUID(uuid)
		for player in GameHelpers.Character.GetPlayers(false) do
			if CharacterIsNeutral(uuid, player.MyGuid) == 1 then
				return true
			end
		end
	end
	return false
end

function GameHelpers.Character.IsInCombat(uuid)
	if not isClient then
		if CharacterIsInCombat(uuid) == 1 then
			return true
		elseif GameHelpers.DB.HasUUID("DB_CombatCharacters", uuid, 2, 1) then
			return true
		end
	end
	return false
end

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

---@param character string|EsvCharacter|EclCharacter
---@return boolean
function GameHelpers.Character.IsUndead(character)
	if type(character) ~= "userdata" then
		character = Ext.GetCharacter(character)
	end
	if character and character.HasTag then
		if character:HasTag("UNDEAD") or character.Stats.TALENT_Zombie then
			return true
		end
	end
	return false
end

---@param character string|EsvCharacter|EclCharacter
---@return boolean
function GameHelpers.Character.GetDisplayName(character)
	if not character then
		return ""
	end
	if type(character) ~= "userdata" then
		character = Ext.GetCharacter(character)
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

if not isClient then

---@param character EsvCharacter|string|integer
---@param level integer
function GameHelpers.Character.SetLevel(character, level)
	if type(character) ~= "userdata" then
		character = Ext.GetCharacter(character)
	end
	if character and character.Stats then
		local xpNeeded = Data.LevelExperience[level]
		if xpNeeded then
			if xpNeeded == 0 then
				character.Stats.Experience = 1
				Timer.StartOneshot("", 250, function()
					character.Stats.Experience = 0
				end)
			else
				character.Stats.Experience = xpNeeded
			end
		end
	end
end

end

---@param includeSummons boolean|nil
---@return fun():EsvCharacter|EclCharacter
function GameHelpers.Character.GetPlayers(includeSummons)
	local players = {}
	if not isClient then
		for _,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
			local player = Ext.GetCharacter(db[1])
			players[#players+1] = player
			if includeSummons == true then
				local summons = PersistentVars.Summons[player.MyGuid]
				if summons then
					for i,v in pairs(summons) do
						if ObjectIsCharacter(v) == 1 then
							local summon = Ext.GetCharacter(v)
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
				gm = Ext.GetCharacter(gm)
				if not Common.TableHasValue(players, gm) then
					players[#players+1] = gm
				end
			end
		end
	else
		for mc in StatusHider.PlayerInfo:GetCharacterMovieClips(not includeSummons) do
			local character = Ext.GetCharacter(Ext.DoubleToHandle(mc.characterHandle))
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

function GameHelpers.Character.GetPartySize(includeSummons)
	local count = 0
	local players = {}
	if not isClient then
		for _,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
			local player = Ext.GetCharacter(db[1])
			if player then
				count = count + 1
			end
			if includeSummons == true then
				local summons = PersistentVars.Summons[player.MyGuid]
				if summons then
					for i,v in pairs(summons) do
						if ObjectIsCharacter(v) == 1 then
							local summon = Ext.GetCharacter(v)
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

---@param owner EsvCharacter|EclCharacter|string|number|nil
---@param getItems boolean|nil If on the server, item summons can be grabbed as well.
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
				for i,uuid in pairs(tbl) do
					if getItems == true or ObjectIsItem(uuid) == false then
						local summon = Ext.GetGameObject(uuid)
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
			local character = Ext.GetCharacter(Ext.DoubleToHandle(mc.characterHandle))
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