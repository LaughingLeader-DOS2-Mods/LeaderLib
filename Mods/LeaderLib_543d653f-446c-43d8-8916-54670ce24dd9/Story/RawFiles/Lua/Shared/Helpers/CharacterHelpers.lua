if GameHelpers.Character == nil then
	GameHelpers.Character = {}
end

local isClient = Ext.IsClient()

function GameHelpers.Character.IsPlayer(uuid)
	if not isClient then
		if type(uuid) == "userdata" then
			uuid = uuid.MyGuid
		end
		return CharacterIsPlayer(uuid) == 1 or CharacterGameMaster(uuid) == 1 or GameHelpers.DB.HasUUID("DB_IsPlayer", uuid) 
	else
		if type(uuid) ~= "userdata" then
			uuid = Ext.GetCharacter(uuid)
		end
		if uuid then
			return uuid.PlayerCustomData ~= nil
		end
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
		for i,v in pairs(Osi.DB_IsPlayer:Get(nil)) do
			if CharacterIsAlly(uuid, v[1]) == 1 then
				return true
			end
		end
	end
	return false
end

function GameHelpers.Character.IsEnemyOfParty(uuid)
	if not isClient then
		for i,v in pairs(Osi.DB_IsPlayer:Get(nil)) do
			if CharacterIsEnemy(uuid, v[1]) == 1 then
				return true
			end
		end
	end
	return false
end

function GameHelpers.Character.IsNeutralToParty(uuid)
	if not isClient then
		for i,v in pairs(Osi.DB_IsPlayer:Get(nil)) do
			if CharacterIsNeutral(uuid, v[1]) == 1 then
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
		for i,entry in pairs(Osi.DB_IsPlayer:Get(nil)) do
			local v = CharacterGetLevel(entry[1])
			if v > level then
				level = v
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
	if type(character) ~= "userdata" then
		character = Ext.GetCharacter(character)
	end
	return character and character.DisplayName or ""
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
				StartOneshotTimer("", 250, function()
					character.Stats.Experience = 0
				end)
			else
				character.Stats.Experience = xpNeeded
			end
		end
	end
end

end

---@return fun():EsvCharacter|EclCharacter
function GameHelpers.Character.GetPlayers()
	local players = {}

	if not isClient then
		for _,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
			players[#players+1] = Ext.GetCharacter(db[1])
		end
	else
		for mc in StatusHider.PlayerInfo:GetCharacterMovieClips(true) do
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