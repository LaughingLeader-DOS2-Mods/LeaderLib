local function ContextContains(context, find)
	local findType = type(find)
	for i,v in pairs(context) do
		if findType == "string" and StringHelpers.Equals(find, v, true) then
			return true
		elseif findType == "table" and Common.TableHasEntry(find, v, true) then
			return true
		end
	end
	return false
end

--- Applies ExtraProperties/SkillProperties.
---@param target string
---@param source string|nil
---@param properties StatProperty[]
function GameHelpers.ApplyProperties(target, source, properties)
	for i,v in pairs(properties) do
		if v.Type == "Status" then
			if ContextContains(v.Context, "Target") then
				if v.Action == "EXPLODE" then
					if v.StatusChance >= 1.0 then
						GameHelpers.Skill.Explode(source, v.StatsId, target)
					elseif v.StatusChance > 0 then
						if Ext.Random(0.0, 1.0) <= v.StatusChance then
							GameHelpers.Skill.Explode(source, v.StatsId, target)
						end
					end
				else
					if target ~= nil then
						if v.StatusChance >= 1.0 then
							ApplyStatus(target, v.Action, v.Duration, 0, source)
						elseif v.StatusChance > 0 then
							if Ext.Random(0.0, 1.0) <= v.StatusChance then
								ApplyStatus(target, v.Action, v.Duration, 0, source)
							end
						end
					end
				end
			end
			if ContextContains(v.Context, "Self") then
				if v.Action == "EXPLODE" then
					if v.StatusChance >= 1.0 then
						GameHelpers.Skill.Explode(source, v.StatsId, source)
					elseif v.StatusChance > 0 then
						if Ext.Random(0.0, 1.0) <= v.StatusChance then
							GameHelpers.Skill.Explode(source, v.StatsId, source)
						end
					end
				else
					if v.StatusChance >= 1.0 then
						ApplyStatus(source, v.Action, v.Duration, 0, source)
					elseif v.StatusChance > 0 then
						if Ext.Random(0.0, 1.0) <= v.StatusChance then
							ApplyStatus(source, v.Action, v.Duration, 0, source)
						end
					end
				end
			end
		end
	end
end

---Get a character's party members.
---@param partyMember string
---@param includeSummons boolean
---@param includeFollowers boolean
---@param includeDead boolean
---@param includeSelf boolean
---@return string[]
function GameHelpers.GetParty(partyMember, includeSummons, includeFollowers, includeDead, includeSelf)
	local party = {}
	local allParty = Osi.DB_LeaderLib_AllPartyMembers:Get(nil)
	if allParty ~= nil then
		for i,v in pairs(allParty) do
			local uuid = v[1]
			if CharacterIsDead(uuid) == 0 or includeDead then
				if (uuid ~= partyMember or includeSelf) and CharacterIsInPartyWith(partyMember, uuid) == 1 then
					if (CharacterIsSummon(uuid) == 0 or includeSummons) and (CharacterIsPartyFollower(uuid) == 0 or includeFollowers) then
						party[#party+1] = uuid
					end
				end
			end
		end
	end
	return party
end

---Roll between 0 and 100 and see if the result is below a number.
---@param chance integer The minimum number that must be met.
---@param includeZero boolean If true, 0 is not a failure roll, otherwise the roll must be higher than 0.
---@return boolean,integer
function GameHelpers.Roll(chance, includeZero)
	if chance <= 0 then
		return false,0
	elseif chance >= 100 then
		return true,100
	end
	local roll = Ext.Random(0,100)
	if includeZero == true then
		return (roll <= chance),roll
	else
		return (roll > 0 and roll <= chance),roll
	end
end

---Clears the action queue that may block things like skill usage via scripting.
---@param character string
---@param purge boolean|nil
function GameHelpers.ClearActionQueue(character, purge)
	if purge then
		CharacterPurgeQueue(character)
	else
		CharacterFlushQueue(character)
	end

	CharacterMoveTo(character, character, 1, "", 1)
	CharacterSetStill(character)
end

---Sync an item or character's scale to clients.
---@param object string|EsvCharacter|EsvItem
function GameHelpers.SyncScale(object)
	if object and type(object) ~= "userdata" then
		object = Ext.GetGameObject(object)
	end
	if object then
		Ext.BroadcastMessage("LeaderLib_SyncScale", Ext.JsonStringify({
			UUID = object.MyGuid,
			Scale = object.Scale,
			Handle = object.NetID
			--Handle = Ext.HandleToDouble(object.Handle)
		}))
	end
end

---Set an item or character's scale, and sync it to clients.
---@param object EsvCharacter|string
---@param scale number
---@param persist boolean|nil
function GameHelpers.SetScale(object, scale, persist)
	if object and type(object) ~= "userdata" then
		object = Ext.GetGameObject(object)
	end
	if object and object.SetScale then
		object:SetScale(scale)
		GameHelpers.SyncScale(object)
		if persist == true then
			PersistentVars.ScaleOverride[object.MyGuid] = scale
		end
	end
end

function GameHelpers.IsInCombat(uuid)
	if ObjectIsCharacter(uuid) == 1 and CharacterIsInCombat(uuid) == 1 then
		return true
	else
		local db = Osi.DB_CombatObjects:Get(uuid, nil)
		if db ~= nil and #db > 0 then
			return true
		end
	end
	return false
end

function GameHelpers.IsActiveCombat(id)
	if not id or id == -1 then
		return false
	end
	local db = Osi.DB_LeaderLib_Combat_ActiveCombat(id)
	if db and #db > 0 then
		return true
	end
	return false
end

---@param id integer
---@return EsvCharacter[]|nil
function GameHelpers.GetCombatCharacters(id)
	local combat = Ext.GetCombat(id)
	if combat then
		local objects = {}
		for i,v in pairs(combat:GetAllTeams()) do
			objects[#objects+1] = v.Character
		end
		return objects
	end
	return nil
end

---@param dialog string
---@vararg string
---@return boolean
function GameHelpers.IsInDialog(dialog, ...)
	local targets = {}
	for i,v in pairs({...}) do
		targets[StringHelpers.GetUUID(v)] = true
	end
	if #targets == 0 then
		return false
	end
	local instanceDb = Osi.DB_DialogName:Get(dialog, nil)
	if instanceDb and #instanceDb > 0 then
		local instance = instanceDb[1][2]
		local playerDb = Osi.DB_DialogPlayers:Get(instance, nil, nil)
		if playerDb and #playerDb > 0 then
			for _,v in pairs(playerDb) do
				local inst,actor,slot = table.unpack(v)
				if targets[StringHelpers.GetUUID(actor)] == true then
					return true
				end
			end
		end
		local npcDb = Osi.DB_DialogNPCs:Get(instance, nil, nil)
		if npcDb and #npcDb > 0 then
			for _,v in pairs(npcDb) do
				local inst,actor,slot = table.unpack(v)
				if targets[StringHelpers.GetUUID(actor)] == true then
					return true
				end
			end
		end
	end
	return false
end

---@vararg string
---@return boolean
function GameHelpers.IsInAnyDialog(...)
	local targets = {}
	for i,v in pairs({...}) do
		local uuid = StringHelpers.GetUUID(v)
		local playerDb = Osi.DB_DialogPlayers:Get(nil, uuid, nil)
		if playerDb and #playerDb > 0 then
			return true
		end
		local npcDb = Osi.DB_DialogNPCs:Get(nil, uuid, nil)
		if npcDb and #npcDb > 0 then
			return true
		end
	end
	return false
end

---@param dialog string
---@vararg string
---@return integer|nil
function GameHelpers.GetDialogInstance(dialog, ...)
	local targets = {}
	for i,v in pairs({...}) do
		targets[StringHelpers.GetUUID(v)] = true
	end
	local instanceDb = Osi.DB_DialogName:Get(dialog, nil)
	if instanceDb and #instanceDb > 0 then
		local instance = instanceDb[1][2]
		if #targets == 0 then
			return instance
		end
		local playerDb = Osi.DB_DialogPlayers:Get(instance, nil, nil)
		if playerDb and #playerDb > 0 then
			for _,v in pairs(playerDb) do
				local inst,actor,slot = table.unpack(v)
				if targets[StringHelpers.GetUUID(actor)] == true then
					return instance
				end
			end
		end
		local npcDb = Osi.DB_DialogNPCs:Get(instance, nil, nil)
		if npcDb and #npcDb > 0 then
			for _,v in pairs(npcDb) do
				local inst,actor,slot = table.unpack(v)
				if targets[StringHelpers.GetUUID(actor)] == true then
					return instance
				end
			end
		end
	end
	return nil
end

---Tries to get a game object if the target exists, otherwise returns nil.
---@param id string|integer|ObjectHandle
---@return EsvCharacter|EsvItem|nil
function GameHelpers.TryGetObject(id)
	if type(id) == "string" then
		if ObjectExists(id) == 1 then
			return Ext.GetGameObject(id)
		end
	else
		return Ext.GetGameObject(id)
	end
	return nil
end