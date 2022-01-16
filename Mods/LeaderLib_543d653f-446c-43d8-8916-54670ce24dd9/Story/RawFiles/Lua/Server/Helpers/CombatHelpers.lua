if GameHelpers.Combat == nil then
	GameHelpers.Combat = {}
end

---@alias GameHelpersCombatGetCharactersFilter string|'"None"'|'"Player"'|'"Ally"'|'"Enemy"'|'"Neutral"'
---@alias GameHelpersCombatGetCharactersFilterCallback fun(character:EsvCharacter, combatId:integer, teamId:integer, initiative:integer, stillInCombat:boolean):boolean

---@param id integer
---@param filter GameHelpersCombatGetCharactersFilter|GameHelpersCombatGetCharactersFilterCallback|nil Used to filter returned charaters. Allies/Enemies/Neutral are the alignment relation towards the player party. If a function is supplied instead, a character is only included if the function returns true.
---@param filterReference EsvCharacter|EsvItem For when using preset filters like "Ally", is is a reference character for relational checks.
---@return fun():EsvCharacter
local function GetOsirisCombatCharacters(id, filter, filterReference)
	local combat = Osi.DB_CombatCharacters:Get(nil, id)
	if combat then
		local refuuid = GameHelpers.GetUUID(filterReference)
		local objects = {}
		for i,v in pairs(combat) do
			local character = GameHelpers.GetCharacter(v[1])
			if character then
				local uuid = character.MyGuid
				if filter then
					local t = type(filter)
					if t == "function" then
						local b,result = xpcall(filter, debug.traceback, uuid)
						if not b then
							Ext.PrintError(result)
						elseif result == true then
							objects[#objects+1] = character
						end
					elseif t == "string" then
						if refuuid then
							if filter == "Player" and character.IsPlayer then
								objects[#objects+1] = character
							elseif filter == "Ally" and CharacterIsAlly(refuuid, uuid) == 1 then
								objects[#objects+1] = character
							elseif filter == "Enemy" and CharacterIsEnemy(refuuid, uuid) == 1 then
								objects[#objects+1] = character
							elseif filter == "Neutral" and CharacterIsNeutral(refuuid, uuid) == 1 then
								objects[#objects+1] = character
							elseif filter == "None" then
								objects[#objects+1] = character
							end
						else
							if filter == "Player" and character.IsPlayer then
								objects[#objects+1] = character
							elseif filter == "Ally" and GameHelpers.Character.IsAllyOfParty(uuid) then
								objects[#objects+1] = character
							elseif filter == "Enemy" and GameHelpers.Character.IsEnemyOfParty(uuid) then
								objects[#objects+1] = character
							elseif filter == "Neutral" and GameHelpers.Character.IsNeutralToParty(uuid) then
								objects[#objects+1] = character
							elseif filter == "None" then
								objects[#objects+1] = character
							end
						end
					end
				else
					objects[#objects+1] = character
				end
			end
		end

		local i = 0
		local count = #objects
		return function ()
			i = i + 1
			if i <= count then
				return objects[i]
			end
		end
	end
	return function() end
end

---@param id integer
---@param filter GameHelpersCombatGetCharactersFilter|GameHelpersCombatGetCharactersFilterCallback|nil Used to filter returned charaters. Allies/Enemies/Neutral are the alignment relation towards the player party. If a function is supplied instead, a character is only included if the function returns true.
---@param filterReference EsvCharacter|EsvItem For when using preset filters like "Ally", is is a reference character for relational checks.
---@param asTable ?boolean Return as a table instead of the function wrapper.
---@return fun():EsvCharacter
function GameHelpers.Combat.GetCharacters(id, filter, filterReference, asTable)
	if Ext.OsirisIsCallable() then
		return GetOsirisCombatCharacters(id, filter, filterReference)
	end
	local combat = Ext.GetCombat(id)
	if combat then
		local refuuid = GameHelpers.GetUUID(filterReference)
		local objects = {}
		for i,v in pairs(combat:GetAllTeams()) do
			if filter then
				local t = type(filter)
				if t == "function" then
					local b,result = xpcall(filter, debug.traceback, v.Character, v.CombatId, v.TeamId, v.Initiative, v.StillInCombat)
					if not b then
						Ext.PrintError(result)
					elseif result == true then
						objects[#objects+1] = v.Character
					end
				elseif t == "string" then
					if refuuid then
						if filter == "Player" and v.Character.IsPlayer then
							objects[#objects+1] = v.Character
						elseif filter == "Ally" and CharacterIsAlly(refuuid, v.Character.MyGuid) == 1 then
							objects[#objects+1] = v.Character
						elseif filter == "Enemy" and CharacterIsEnemy(refuuid, v.Character.MyGuid) == 1 then
							objects[#objects+1] = v.Character
						elseif filter == "Neutral" and CharacterIsNeutral(refuuid, v.Character.MyGuid) == 1 then
							objects[#objects+1] = v.Character
						elseif filter == "None" then
							objects[#objects+1] = v.Character
						end
					else
						if filter == "Player" and v.Character.IsPlayer then
							objects[#objects+1] = v.Character
						elseif filter == "Ally" and GameHelpers.Character.IsAllyOfParty(v.Character.MyGuid) then
							objects[#objects+1] = v.Character
						elseif filter == "Enemy" and GameHelpers.Character.IsEnemyOfParty(v.Character.MyGuid) then
							objects[#objects+1] = v.Character
						elseif filter == "Neutral" and GameHelpers.Character.IsNeutralToParty(v.Character.MyGuid) then
							objects[#objects+1] = v.Character
						elseif filter == "None" then
							objects[#objects+1] = v.Character
						end
					end
				end
			else
				objects[#objects+1] = v.Character
			end
		end

		if not asTable then
			local i = 0
			local count = #objects
			return function ()
				i = i + 1
				if i <= count then
					return objects[i]
				end
			end
		else
			return objects
		end
	end
	if not asTable then
		return function() end
	else
		return {}
	end
end