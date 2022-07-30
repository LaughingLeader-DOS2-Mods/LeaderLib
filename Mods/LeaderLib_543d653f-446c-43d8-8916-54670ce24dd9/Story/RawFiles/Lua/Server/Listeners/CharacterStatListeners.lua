---@type table<UUID, LeaderLibCharacterStatListenersPlayerData>
local statChanges = {}

---@alias LeaderLibCharacterStatListenersPlayerData {Attributes:table<string,integer>, Abilities:table<string,integer>, Talents:table<string,boolean>}

---@param uuid UUID
local function CreatePlayerData(uuid, player)
	--local player = player or GameHelpers.GetCharacter(uuid)
	local playerData = {
		Attributes = {},
		Abilities = {},
		Talents = {},
	}
	statChanges[uuid] = playerData
	for _,stat in Data.Attribute:Get() do
		playerData.Attributes[stat] = CharacterGetBaseAttribute(uuid, stat) or 0
	end
	for _,stat in Data.Ability:Get() do
		playerData.Abilities[stat] = CharacterGetBaseAbility(uuid, stat) or 0
	end
	for _,stat in Data.Talents:Get() do
		playerData.Talents[stat] = CharacterHasTalent(uuid, stat) == 1
	end
	return playerData
end

local function StorePartyValues()
	for player in GameHelpers.Character.GetPlayers(false) do
		CreatePlayerData(player.MyGuid, player)
	end
end

Ext.RegisterNetListener("LeaderLib_CharacterSheet_StorePartyValues", function(cmd, param)
	StorePartyValues()
end)

local function FireListenerEvents(uuid, stat, lastVal, nextVal, statType)
	Events.CharacterBasePointsChanged:Invoke({
		Character = GameHelpers.GetCharacter(uuid),
		CharacterGUID = uuid,
		Stat = stat,
		StatType = statType,
		Last = lastVal,
		Current = nextVal,
	})
end

---@param uuid UUID
---@param playerData LeaderLibCharacterStatListenersPlayerData
---@param stat string
---@param statType string|"Attribute"|"Ability"|"Talent"
local function DetectStatChanges(uuid, playerData, stat, statType)
	if statType == "Attribute" then
		local lastVal = playerData.Attributes[stat] or 0
		local baseVal = CharacterGetBaseAttribute(uuid, stat) or 0
		if lastVal ~= baseVal then
			Osi.LeaderLib_CharacterSheet_AttributeChanged(uuid, stat, lastVal, baseVal)
			FireListenerEvents(uuid, stat, lastVal, baseVal, statType)
			playerData.Attributes[stat] = baseVal
		end
	elseif statType == "Ability" then
		local lastVal = playerData.Abilities[stat] or 0
		local baseVal = CharacterGetBaseAbility(uuid, stat) or 0
		if lastVal ~= baseVal then
			Osi.LeaderLib_CharacterSheet_AbilityChanged(uuid, stat, lastVal, baseVal)
			FireListenerEvents(uuid, stat, lastVal, baseVal, statType)
			playerData.Abilities[stat] = baseVal
		end
	elseif statType == "Talent" then
		local lastVal = playerData.Talents[stat] or false
		local baseVal = CharacterHasTalent(uuid, stat) == 1
		if lastVal ~= baseVal then
			Osi.LeaderLib_CharacterSheet_AbilityChanged(uuid, stat, lastVal, baseVal)
			FireListenerEvents(uuid, stat, lastVal, baseVal, statType)
			playerData.Talents[stat] = baseVal
		end
	end
end

local function SignalPartyValueChanges()
	for _,stat in Data.Attribute:Get() do
		for uuid,data in pairs(statChanges) do
			DetectStatChanges(uuid, data, stat, "Attribute")
		end
	end
	for _,stat in Data.Ability:Get() do
		for uuid,data in pairs(statChanges) do
			DetectStatChanges(uuid, data, stat, "Ability")
		end
	end
	for _,stat in Data.Talents:Get() do
		for uuid,data in pairs(statChanges) do
			DetectStatChanges(uuid, data, stat, "Talent")
		end
	end
end

function CharacterSheet_SignalPartyValueChanges()
	local b,err = xpcall(SignalPartyValueChanges, debug.traceback)
	if not b then
		Ext.PrintError("Error signaling party attribute changes:\n", err)
	end
end

function CharacterSheet_StorePartyValues()
	local b,err = xpcall(StorePartyValues, debug.traceback)
	if not b then
		Ext.PrintError("Error storing party sheet values:\n", err)
	end
end

Ext.RegisterNetListener("LeaderLib_CharacterSheet_PointsChanged", function(cmd, payload)
	Timer.StartOneshot("CharacterSheet_SignalPartyValueChanges", 1000, CharacterSheet_SignalPartyValueChanges, true)
end)

---@param uuid string
---@param ability string
---@param old integer
---@param new integer
local function OnCharacterBaseAbilityChanged(uuid, ability, old, new)
	if CharacterIsPlayer(uuid) == 1 then
		uuid = StringHelpers.GetUUID(uuid)
		FireListenerEvents(uuid, ability, old, new)
	end
end

RegisterProtectedOsirisListener("CharacterBaseAbilityChanged", 4, "after", OnCharacterBaseAbilityChanged)
RegisterProtectedOsirisListener("CharacterJoinedParty", 1, "after", function(partyMember)
	if CharacterIsPlayer(partyMember) == 1 and ObjectIsGlobal(partyMember) == 1 then
		CreatePlayerData(StringHelpers.GetUUID(partyMember))
	end
end)

RegisterProtectedOsirisListener("CharacterLeftParty", 1, "after", function(partyMember)
	if CharacterIsPlayer(partyMember) == 0 then
		statChanges[StringHelpers.GetUUID(partyMember)] = nil
	end
end)

RegisterProtectedOsirisListener("DB_Illusionist", 1, "after", function(db)
	StorePartyValues()
end)

Events.RegionChanged:Subscribe(function (e)
	if e.State == REGIONSTATE.ENDED and e.LevelType == LEVELTYPE.CHARACTER_CREATION then
		StorePartyValues()
	elseif e.State == REGIONSTATE.GAME and e.LevelType == LEVELTYPE.GAME then
		StorePartyValues()
	end
end)