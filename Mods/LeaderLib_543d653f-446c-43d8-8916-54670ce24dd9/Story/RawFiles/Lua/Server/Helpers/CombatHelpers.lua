if GameHelpers.Combat == nil then
	GameHelpers.Combat = {}
end

---@alias GameHelpersCombatGetCharactersFilter string|'"None"'|'"Player"'|'"Ally"'|'"Enemy"'|'"Neutral"'
---@alias GameHelpersCombatGetCharactersFilterCallback fun(character:EsvCharacter, combatId:integer, teamId:integer, initiative:integer, stillInCombat:boolean):boolean

---@param id integer
---@param filter? GameHelpersCombatGetCharactersFilter|GameHelpersCombatGetCharactersFilterCallback Used to filter returned charaters. Allies/Enemies/Neutral are the alignment relation towards the player party. If a function is supplied instead, a character is only included if the function returns true.
---@param filterReference EsvCharacter|EsvItem For when using preset filters like "Ally", is is a reference character for relational checks.
---@param asTable? boolean Return results as a table, instead of an iterator function.
---@return fun():EsvCharacter|nil
local function GetOsirisCombatCharacters(id, filter, filterReference, asTable)
	local combat = Osi.DB_CombatCharacters:Get(nil, id)
	if combat then
		local refuuid = GameHelpers.GetUUID(filterReference)
		local objects = {}
		for i,v in pairs(combat) do
			local character = GameHelpers.GetCharacter(v[1])
			if character and not character.OffStage then
				local uuid = character.MyGuid
				if filter then
					local t = type(filter)
					if t == "function" then
						local b,result = xpcall(filter, debug.traceback, uuid)
						if not b then
							Ext.Utils.PrintError(result)
						elseif result == true then
							objects[#objects+1] = character
						end
					elseif t == "string" then
						if refuuid then
							if filter == "Player" and character.IsPlayer then
								objects[#objects+1] = character
							elseif filter == "Ally" and Osi.CharacterIsAlly(refuuid, uuid) == 1 then
								objects[#objects+1] = character
							elseif filter == "Enemy" and Osi.CharacterIsEnemy(refuuid, uuid) == 1 then
								objects[#objects+1] = character
							elseif filter == "Neutral" and Osi.CharacterIsNeutral(refuuid, uuid) == 1 then
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

---🔨**Server-Only**🔨  
---@overload fun(id:integer|nil, filter:GameHelpersCombatGetCharactersFilter|GameHelpersCombatGetCharactersFilterCallback|nil, filterReference:EsvCharacter|EsvItem):fun():EsvCharacter
---@overload fun(id:integer|nil):fun():EsvCharacter
---@param id? integer The combat ID, or nothing to get all characters in combat.
---@param filter? GameHelpersCombatGetCharactersFilter|GameHelpersCombatGetCharactersFilterCallback Used to filter returned charaters. Allies/Enemies/Neutral are the alignment relation towards the player party. If a function is supplied instead, a character is only included if the function returns true.
---@param filterReference? EsvCharacter|EsvItem For when using preset filters like "Ally", is is a reference character for relational checks.
---@param asTable boolean Return results as a table, instead of an iterator function.
---@return EsvCharacter[]
function GameHelpers.Combat.GetCharacters(id, filter, filterReference, asTable)
	if _OSIRIS() then
		return GetOsirisCombatCharacters(id, filter, filterReference, asTable)
	end
	local combat = Ext.Entity.GetCombat(id)
	if combat then
		local refuuid = GameHelpers.GetUUID(filterReference)
		local objects = {}
		for i,v in pairs(combat:GetAllTeams()) do
			if v.Character and not v.Character.OffStage then
				if filter then
					local t = type(filter)
					if t == "function" then
						local b,result = xpcall(filter, debug.traceback, v.Character, v.CombatId, v.TeamId, v.Initiative, v.StillInCombat)
						if not b then
							Ext.Utils.PrintError(result)
						elseif result == true then
							objects[#objects+1] = v.Character
						end
					elseif t == "string" then
						--TODO Replace osiris queries
						if refuuid and _OSIRIS() then
							if filter == "Player" and v.Character.IsPlayer then
								objects[#objects+1] = v.Character
							elseif filter == "Ally" and Osi.CharacterIsAlly(refuuid, v.Character.MyGuid) == 1 then
								objects[#objects+1] = v.Character
							elseif filter == "Enemy" and Osi.CharacterIsEnemy(refuuid, v.Character.MyGuid) == 1 then
								objects[#objects+1] = v.Character
							elseif filter == "Neutral" and Osi.CharacterIsNeutral(refuuid, v.Character.MyGuid) == 1 then
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