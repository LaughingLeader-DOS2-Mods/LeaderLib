if GameHelpers.Character == nil then
	GameHelpers.Character = {}
end

function GameHelpers.Character.IsPlayer(uuid)
	return CharacterIsPlayer(uuid) == 1 or GameHelpers.DB.HasUUID("DB_IsPlayer", uuid)
end

function GameHelpers.Character.IsOrigin(uuid)
	return GameHelpers.DB.HasUUID("DB_Origins", uuid)
end

function GameHelpers.Character.IsAllyOfParty(uuid)
	for i,v in pairs(Osi.DB_IsPlayer:Get(nil)) do
		if CharacterIsAlly(uuid, v[1]) == 1 then
			return true
		end
	end
	return false
end

function GameHelpers.Character.IsEnemyOfParty(uuid)
	for i,v in pairs(Osi.DB_IsPlayer:Get(nil)) do
		if CharacterIsEnemy(uuid, v[1]) == 1 then
			return true
		end
	end
	return false
end

function GameHelpers.Character.IsNeutralToParty(uuid)
	for i,v in pairs(Osi.DB_IsPlayer:Get(nil)) do
		if CharacterIsNeutral(uuid, v[1]) == 1 then
			return true
		end
	end
	return false
end

function GameHelpers.Character.IsInCombat(uuid)
	if CharacterIsInCombat(uuid) == 1 then
		return true
	elseif GameHelpers.DB.HasUUID("DB_CombatCharacters", uuid, 2, 1) then
		return true
	end
	return false
end

function GameHelpers.Character.GetHighestPlayerLevel()
	local level = 1
	for i,entry in pairs(Osi.DB_IsPlayer:Get(nil)) do
		local v = CharacterGetLevel(entry[1])
		if v > level then
			level = v
		end
	end
	return level
end

function GameHelpers.Character.IsUndead(uuid)
	local character = Ext.GetCharacter(uuid)
	if character then
		if character:HasTag("UNDEAD") or character.Stats.TALENT_Zombie then
			return true
		end
	end
	return false
end