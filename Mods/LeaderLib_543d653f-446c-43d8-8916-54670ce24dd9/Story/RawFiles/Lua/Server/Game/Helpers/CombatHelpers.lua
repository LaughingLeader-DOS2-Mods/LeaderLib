if GameHelpers.Combat == nil then
	GameHelpers.Combat = {}
end

---@alias GameHelpersCombatGetCharactersFilter string|'"None"'|'"Player"'|'"Ally"'|'"Enemy"'|'"Neutral"'
---@alias GameHelpersCombatGetCharactersFilterCallback fun(character:EsvCharacter, combatId:integer, teamId:integer, initiative:integer, stillInCombat:boolean):boolean

---@param id integer
---@param filter GameHelpersCombatGetCharactersFilter|GameHelpersCombatGetCharactersFilterCallback|nil Used to filter returned charaters. Allies/Enemies/Neutral are the alignment relation towards the player party. If a function is supplied instead, a character is only included if the function returns true.
---@param filterReference EsvCharacter|EsvItem For when using preset filters like "Ally", is is a reference character for relational checks.
---@return fun():EsvCharacter
function GameHelpers.Combat.GetCharacters(id, filter, filterReference)
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

		local i = 0
		local count = #objects
		return function ()
			i = i + 1
			if i <= count then
				return objects[i]
			end
		end

		return objects
	end
	return nil
end