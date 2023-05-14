local _ISCLIENT = Ext.IsClient()

---@class LeaderLibProgressionManager
ProgressionManager = {
	---@type LeaderLibProgressionDataInstance[]
	Data = {},
	TotalData = 0,
}
local _INTERNAL = {}
ProgressionManager._Internal = _INTERNAL

---Add new progression data. This should be called in a Shared script, as the ProgressionManager will invoke data on both sides when applying progression.
---@param params LeaderLibProgressionData|LeaderLibProgressionDataParams
function ProgressionManager.Add(params)
	local data = params
	if data.Type ~= "ProgressionData" then
		data = Classes.ProgressionData:Create(params)
	end
	ProgressionManager.TotalData = ProgressionManager.TotalData + 1
	ProgressionManager.Data[ProgressionManager.TotalData] = data
end

---Add a table of new progression data. This should be called in a Shared script, as the ProgressionManager will invoke data on both sides when applying progression.
---@param entries LeaderLibProgressionData[]|LeaderLibProgressionDataParams[]
function ProgressionManager.AddRange(entries)
	for _,v in pairs(entries) do
		ProgressionManager.Add(v)
	end
end

---@param character CharacterObject
---@param item ItemObject
function ProgressionManager.OnItemLeveledUp(character, item)
	local successes = 0
	local tags = GameHelpers.GetAllTags(item, true)
	local template = GameHelpers.GetTemplate(item)
	for i=1,ProgressionManager.TotalData do
		local entry = ProgressionManager.Data[i]
		if entry:CanAddBoosts(item, tags, template, character) then
			if entry:ApplyBoosts(item) then
				successes = successes + 1
			end
		end
	end
	if not _ISCLIENT and successes > 0 then
		if character then
			GameHelpers.Status.Apply(character, "LEADERLIB_RECALC", 0, true, character)
		end
		GameHelpers.Status.Apply(item, "BOOST", 0)
		GameHelpers.Net.Broadcast("LeaderLib_ProgressionManager_OnItemLeveledUp", {Item=item.NetID, Owner=character.NetID})
	end
	return successes
end

---@param character CharacterObject
function ProgressionManager.OnCharacterLeveledUp(character)
	local successes = 0
	local tags = GameHelpers.GetAllTags(character, true, true)
	local template = GameHelpers.GetTemplate(character)
	local owner = GameHelpers.GetObjectFromHandle(character.OwnerHandle)
	for i=1,ProgressionManager.TotalData do
		local entry = ProgressionManager.Data[i]
		if entry:CanAddBoosts(character, tags, template, owner or character) then
			if entry:ApplyBoosts(character) then
				successes = successes + 1
			end
		end
	end
	if not _ISCLIENT and successes > 0 then
		GameHelpers.Status.Apply(character, "LEADERLIB_RECALC", 0.0, true, character)
		GameHelpers.Net.Broadcast("LeaderLib_ProgressionManager_OnItemLeveledUp", {Character=character.NetID})
	end
	return successes
end

---@param object CharacterObject|ItemObject
---@return LeaderLibProgressionData[]
---@return integer total
function ProgressionManager.GetDataForObject(object)
	if GameHelpers.Ext.ObjectIsItem(object) and GameHelpers.Item.IsObject(object) then
		return {},0
	end
	local entries = {}
	local len = 0
	local tags = GameHelpers.GetAllTags(object, true, true)
	local template = GameHelpers.GetTemplate(object)
	local owner = GameHelpers.GetOwner(object)
	for i=1,ProgressionManager.TotalData do
		local entry = ProgressionManager.Data[i]
		if entry:CanAddBoosts(object, tags, template, owner or object) then
			len = len + 1
			entries[len] = entry
		end
	end
	return entries,len
end

if _ISCLIENT then
	---@class LeaderLib_ProgressionManager_OnItemLeveledUp
	---@field Item NetId
	---@field Owner NetId

	---@class LeaderLib_ProgressionManager_OnCharacterLeveledUp
	---@field Character NetId

	GameHelpers.Net.Subscribe("LeaderLib_ProgressionManager_OnItemLeveledUp", function (e, data)
		local item = GameHelpers.GetItem(data.Item)
		local owner = GameHelpers.GetCharacter(data.Owner)
		if item and owner then
			ProgressionManager.OnItemLeveledUp(owner, item)
		end
	end)

	GameHelpers.Net.Subscribe("LeaderLib_ProgressionManager_OnCharacterLeveledUp", function (e, data)
		local character = GameHelpers.GetCharacter(data.Character)
		if character then
			ProgressionManager.OnCharacterLeveledUp(character)
		end
	end)
else
	Events.ObjectEvent:Subscribe(function (e)
		local owner,item = table.unpack(e.Objects)
		if owner and item then
			---@cast owner EsvCharacter
			---@cast item EsvItem
			ProgressionManager.OnItemLeveledUp(owner, item)
		end
	end, {MatchArgs={EventType="CharacterItemEvent", Event="LeaderLib_Events_ItemLeveledUp"}})
end