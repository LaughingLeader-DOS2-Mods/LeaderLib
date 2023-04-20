if GameHelpers.Combat == nil then
	GameHelpers.Combat = {}
end

local _ISCLIENT = Ext.IsClient()

local function _GetCombatComponent_Old(character)
	local combatid = GameHelpers.Combat.GetID(character)
	if combatid > -1 then
		local turnManager = Ext.Combat.GetTurnManager()
		local combat = turnManager.Combats[combatid]
		if combat then
			for _,team in pairs(combat:GetCurrentTurnOrder()) do
				if team.Character == character and team.EntityWrapper then
					return team.EntityWrapper.CombatComponentPtr
				end
			end
		end
	end
	return nil
end

---@param character CharacterParam
---@return EocCombatComponent|nil
function GameHelpers.Combat.GetCombatComponent(character)
	local character = GameHelpers.GetCharacter(character, "EsvCharacter")
	if character then
		return Ext.Entity.GetCombatComponent(character.Handle)
	end
	return nil
end

local function _GetCombatID_ServerDB(obj)
	if _OSIRIS() then
		local GUID = GameHelpers.GetUUID(obj)
		if GUID then
			--TODO replace with obj.RootTempate.CombatComponent index, if that's made available
			local db = Osi.DB_CombatObjects:Get(GUID, nil)
			if db and db[1] then
				local _,id = table.unpack(db[1])
				if id then
					return id
				end
			end
		end
	end
	return -1
end

---@param obj ObjectParam
---@return integer
function GameHelpers.Combat.GetID(obj)
	local comp = GameHelpers.Combat.GetCombatComponent(obj)
	if comp and comp.CombatAndTeamIndex then
		return comp.CombatAndTeamIndex.CombatId
	end
	if not _ISCLIENT then
		return _GetCombatID_ServerDB(obj)
	end
	return -1
end


---Returns true if it's the object's active turn in combat.
---@param obj ObjectParam
---@return boolean isActiveTurn
---@return EocCombatComponent|nil combatComponent
local function _IsActiveTurn_Server(obj)
	local object = GameHelpers.TryGetObject(obj)
	if object and not GameHelpers.ObjectIsDead(object) then
		---@cast object EsvCharacter|EsvItem
		local combatID = GameHelpers.Combat.GetID(object)
		if combatID > -1 then
			local turnManager = Ext.Combat.GetTurnManager()
			local combat = turnManager.Combats[combatID]
			if combat then
				local turnOrder = combat:GetCurrentTurnOrder()
				if turnOrder then
					local activeTeam = turnOrder[1]
					if activeTeam then
						if activeTeam.Character and activeTeam.Character.MyGuid == object.MyGuid then
							return true,activeTeam.EntityWrapper.CombatComponentPtr
						end
						if activeTeam.Item and activeTeam.Item.MyGuid == object.MyGuid then
							return true,activeTeam.EntityWrapper.CombatComponentPtr
						end
					end
				end
			end
		end
	end
	return false
end

---@param obj ObjectParam
---@return boolean isActiveTurn
---@return EocCombatComponent|nil combatComponent
function GameHelpers.Combat.IsActiveTurn(obj)
	local comp = GameHelpers.Combat.GetCombatComponent(obj)
	if comp then
		return comp.IsTicking,comp
	end
	if not _ISCLIENT then
		return _IsActiveTurn_Server(obj)
	end
	return false
end

---@return boolean
function GameHelpers.Combat.IsAnyPlayerInCombat()
	for player in GameHelpers.Character.GetPlayers() do
		if GameHelpers.Character.IsInCombat(player) then
			return true
		end
	end
	return false
end