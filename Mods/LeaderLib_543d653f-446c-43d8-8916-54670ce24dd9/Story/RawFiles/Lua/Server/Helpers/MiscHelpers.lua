local _EXTVERSION = Ext.Utils.Version()

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

---@deprecated
---[DEPRECATED] Use `Ext.PropertyList.ExecuteSkillPropertiesOnTarget` instead.
---@param source EsvCharacter
---@param target IEoCServerObject|number[]
---@param properties StatProperty[]
---@param targetPosition? number[]
---@param radius? number
---@param fromSkill? string
function GameHelpers.ApplyProperties(source, target, properties, targetPosition, radius, fromSkill)
	local canTargetItems = false
	local t = type(target)
	if fromSkill then
		local stat = Ext.Stats.Get(fromSkill, nil, false)
		if stat then
			canTargetItems = stat.CanTargetItems == "Yes"
		end
	end
	if not properties then
		return false
	end
	for i,v in pairs(properties) do
		local actionTarget = target
		if ContextContains(v.Context, "target") then
			actionTarget = target
		elseif ContextContains(v.Context, "self") then
			actionTarget = source
		end
		local aType = type(actionTarget)
		if aType == "string" or aType == "number" then
			actionTarget = GameHelpers.TryGetObject(actionTarget)
			aType = type(actionTarget)
		end
		if v.Type == "Status" then
			if v.Action == "EXPLODE" then
				if v.StatusChance >= 1.0 then
					GameHelpers.TrackBonusWeaponPropertiesApplied(source.MyGuid, v.StatsId)
					GameHelpers.Skill.Explode(actionTarget, v.StatsId, source)
				elseif v.StatusChance > 0 then
					if Ext.Utils.Random(0.0, 1.0) <= v.StatusChance then
						GameHelpers.TrackBonusWeaponPropertiesApplied(source.MyGuid, v.StatsId)
						GameHelpers.Skill.Explode(actionTarget, v.StatsId, source)
					end
				end
			else
				if actionTarget then
					if v.StatusChance >= 1.0 then
						GameHelpers.TrackBonusWeaponPropertiesApplied(source.MyGuid)
						GameHelpers.Status.Apply(actionTarget, v.Action, v.Duration, 0, source, radius, canTargetItems)
					elseif v.StatusChance > 0 then
						local statusObject = {
							StatusId = v.Action,
							StatusType = GameHelpers.Status.GetStatusType(v.Action),
							ForceStatus = false,
							StatusSourceHandle = source.Handle,
							TargetHandle = aType == "userdata" and target.Handle or nil,
							CanEnterChance = Ext.Utils.Round(v.StatusChance * 100)
						}
						if Ext.Utils.Random(0,100) <= Game.Math.StatusGetEnterChance(statusObject, true) then
							GameHelpers.TrackBonusWeaponPropertiesApplied(source.MyGuid)
							GameHelpers.Status.Apply(actionTarget, v.Action, v.Duration, 0, source, radius, canTargetItems)
						end
					end
				end
			end
		elseif v.Type == "SurfaceTransform" then
			local x,y,z = 0,0,0
			if targetPosition then
				x,y,z = table.unpack(targetPosition)
			else
				if aType == "table" then
					x,y,z = table.unpack(actionTarget)
				elseif aType == "userdata" then
					x,y,z = table.unpack(actionTarget.WorldPos)
				elseif aType == "string" then
					x,y,z = Osi.GetPosition(actionTarget)
				end
			end
			GameHelpers.TrackBonusWeaponPropertiesApplied(source.MyGuid)
			Osi.TransformSurfaceAtPosition(x, y, z, v.Action, "Ground", 1.0, 6.0, source)
		elseif v.Type == "Force" then
			local distance = math.floor(v.Arg2/6) or 1.0
			if distance > 0 then
				GameHelpers.TrackBonusWeaponPropertiesApplied(source.MyGuid)
				GameHelpers.ForceMoveObject(source, actionTarget, distance, nil, actionTarget.WorldPos)
			end
		end
	end
	return true
end

---Get a character's party members.
---@param partyMember string
---@param includeSummons boolean
---@param includeFollowers boolean
---@param excludeDead boolean
---@param includeSelf boolean
---@return string[]
function GameHelpers.GetParty(partyMember, includeSummons, includeFollowers, excludeDead, includeSelf)
	partyMember = StringHelpers.GetUUID(partyMember or Osi.CharacterGetHostCharacter())
	local party = {}
	if includeSelf then
		party[partyMember] = true
	end
	local allParty = Osi.DB_LeaderLib_AllPartyMembers:Get(nil)
	if allParty ~= nil then
		for i,v in pairs(allParty) do
			local uuid = StringHelpers.GetUUID(v[1])
			local isDead = Osi.CharacterIsDead(uuid) == 1
			if not isDead or excludeDead ~= true then
				if uuid == partyMember and not includeSelf then
					--Skip
				else
					if Osi.CharacterIsInPartyWith(partyMember, uuid) == 1
					and (Osi.CharacterIsSummon(uuid) == 0 or includeSummons) 
					and (Osi.CharacterIsPartyFollower(uuid) == 0 or includeFollowers)
					then
						party[uuid] = true
					end
				end
			end
		end
	end
	local data = {}
	for uuid,b in pairs(party) do
		data[#data+1] = uuid
	end
	return data
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
	local roll = Ext.Utils.Random(0,100)
	if includeZero == true then
		return (roll <= chance),roll
	else
		return (roll > 0 and roll <= chance),roll
	end
end

---Clears the action queue that may block things like skill usage via scripting.
---@param character CharacterParam
---@param purge? boolean Call CharacterPurgeQueue instead of CharacterFlushQueue.
function GameHelpers.ClearActionQueue(character, purge)
	character = GameHelpers.GetUUID(character)
	if not character then
		return
	end
	if purge then
		Osi.CharacterPurgeQueue(character)
	else
		Osi.CharacterFlushQueue(character)
	end

	Osi.CharacterMoveTo(character, character, 1, "", 1)
	Osi.CharacterSetStill(character)
end

---Sync an item or character's scale to clients.
---@param object string|EsvCharacter|EsvItem
function GameHelpers.SyncScale(object)
	local netid = GameHelpers.GetNetID(object)
	if netid then
		GameHelpers.Net.Broadcast("LeaderLib_SyncScale", {NetID = netid, Scale = object.Scale, IsItem=GameHelpers.Ext.ObjectIsItem(object)})
	end
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

---Deprecated
---@see GameHelpers.Combat.GetCharacters
---@param id integer
---@return EsvCharacter[]|nil
function GameHelpers.GetCombatCharacters(id)
	local combat = Ext.Entity.GetCombat(id)
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

Timer.Subscribe("LeaderLib_SetExperienceToZero", function (e)
	if e.Data.Object and e.Data.Object.Stats then
		e.Data.Object.Stats.Experience = 0
	end
end)

---@param object ObjectParam
---@param level integer
function GameHelpers.SetExperienceLevel(object, level)
	if type(object) ~= "userdata" then
		object = GameHelpers.TryGetObject(object)
	end
	if object then
		if GameHelpers.Ext.ObjectIsItem(object) then
			---@cast object EsvItem
			local owner = GameHelpers.Item.GetOwner(object)
			if not GameHelpers.Item.IsObject(object) then
				if level > object.Stats.Level then
					Osi.ItemLevelUpTo(object.MyGuid, level)
					ProgressionManager.OnItemLeveledUp(owner, object)
					return true
				else
					local xpNeeded = Data.LevelExperience[level]
					if xpNeeded then
						if xpNeeded == 0 then
							object.Stats.Experience = 1
							Timer.StartObjectTimer("LeaderLib_SetExperienceToZero", object, 250)
						else
							object.Stats.Experience = xpNeeded
						end
						ProgressionManager.OnItemLeveledUp(owner, object)
						return true
					end
				end
			else
				Osi.ItemLevelUpTo(object.MyGuid, level)
				ProgressionManager.OnItemLeveledUp(owner, object)
				return true
			end
		else
			if object.Stats and level < object.Stats.Level then
				local xpNeeded = Data.LevelExperience[level]
				if xpNeeded then
					if xpNeeded == 0 then
						object.Stats.Experience = 1
						Timer.StartObjectTimer("LeaderLib_SetExperienceToZero", object, 250)
					else
						object.Stats.Experience = xpNeeded
					end
					return true
				end
			else
				Osi.CharacterLevelUpTo(object.MyGuid, level)
				return true
			end
		end
	end
	return false
end

---@param character CharacterParam
---@param level integer
function GameHelpers.Character.SetLevel(character, level)
	return GameHelpers.SetExperienceLevel(character, level)
end