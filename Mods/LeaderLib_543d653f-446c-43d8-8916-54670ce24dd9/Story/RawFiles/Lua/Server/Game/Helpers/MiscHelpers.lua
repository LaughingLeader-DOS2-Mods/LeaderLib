--- Applies ExtraProperties/SkillProperties.
---@param target string
---@param source string|nil
---@param properties StatProperty[]
function GameHelpers.ApplyProperties(target, source, properties)
	for i,v in pairs(properties) do
		if v.Type == "Status" then
			if v.Context[1] == "Target" then
				if target ~= nil then
					if v.StatusChance >= 1.0 then
						ApplyStatus(target, v.Action, v.Duration, 0, source)
					elseif v.StatusChance > 0 then
						if Ext.Random(0.0, 1.0) <= v.StatusChance then
							ApplyStatus(target, v.Action, v.Duration, 0, source)
						end
					end
				end
			elseif v.Context[1] == "Self" then
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
	if type(object) == "string" then
		if ObjectIsCharacter(object) == 1 then
			object = Ext.GetCharacter(object)
		elseif ObjectIsItem(object) == 1 then
			object = Ext.GetItem(object)
		end
	end
	if object ~= nil then
		local isItem = ObjectIsItem(object.MyGuid) == 1
		Ext.BroadcastMessage("LeaderLib_SyncScale", Classes.MessageData:CreateFromTable("SyncScaleData", {
			UUID = object.MyGuid,
			Scale = object.Scale,
			IsItem = isItem,
			Handle = object.NetID
			--Handle = Ext.HandleToDouble(object.Handle)
		}):ToString())
	end
end

---Set an item or character's scale, and sync it to clients.
---@param object EsvCharacter|string
---@param scale number
function GameHelpers.SetScale(object, scale)
	if type(object) == "string" then
		if ObjectIsCharacter(object) == 1 then
			object = Ext.GetCharacter(object)
		elseif ObjectIsItem(object) == 1 then
			object = Ext.GetItem(object)
		end
	end
	if object.SetScale ~= nil then
		object:SetScale(scale)
		GameHelpers.SyncScale(object)
	end
end