if GameHelpers.Character == nil then
	GameHelpers.Character = {}
end

local isClient = Ext.IsClient()

function GameHelpers.Character.IsPlayer(uuid)
	if not isClient then
		return CharacterIsPlayer(uuid) == 1 or GameHelpers.DB.HasUUID("DB_IsPlayer", uuid)
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