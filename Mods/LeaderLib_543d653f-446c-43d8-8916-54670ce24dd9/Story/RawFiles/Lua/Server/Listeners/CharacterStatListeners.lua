local statChanges = {}

local function GetStoredPlayerValues(uuid, skipCreation)
	local playerData = statChanges[uuid]
	if playerData == nil and skipCreation ~= true then
		playerData = {
			attributes = {},
			abilities = {}
		}
		statChanges[uuid] = playerData
		for _,stat in Data.Attribute:Get() do
			playerData.attributes[stat] = CharacterGetBaseAttribute(uuid, stat) or 0
		end
		for _,stat in Data.Ability:Get() do
			playerData.abilities[stat] = CharacterGetBaseAbility(uuid, stat) or 0
		end
	end
	return playerData
end

local function StorePartyValues()
	local players = Osi.DB_IsPlayer:Get(nil)
	for _,entry in pairs(players) do
		local uuid = StringHelpers.GetUUID(entry[1])
		local playerData = {
			attributes = {},
			abilities = {}
		}
		statChanges[uuid] = playerData
		for _,stat in Data.Attribute:Get() do
			playerData.attributes[stat] = CharacterGetBaseAttribute(uuid, stat) or 0
		end
		for _,stat in Data.Ability:Get() do
			playerData.abilities[stat] = CharacterGetBaseAbility(uuid, stat) or 0
		end
	end
	--PrintDebug("[LeaderLib_ClientMessageReceiver.lua:StorePartyValues] Stored party stat data:\n("..Common.Dump(statChanges)..").")
end

Ext.RegisterNetListener("LeaderLib_CharacterSheet_StorePartyValues", function(cmd, param)
	StorePartyValues()
end)

if Vars.DebugMode then
	RegisterListener("LuaReset", function()
		StorePartyValues()
		LoadGameSettings()
	end)
end

local function FireListenerEvents(uuid, stat, lastVal, nextVal, statType)
	InvokeListenerCallbacks(Listeners.CharacterBasePointsChanged, uuid, stat, lastVal, nextVal, statType)
end

local function DetectStatChanges(uuid, playerData, stat, statType)
	if statType == "attribute" then
		local lastVal = playerData.attributes[stat] or 0
		local baseVal = CharacterGetBaseAttribute(uuid, stat) or 0
		if lastVal ~= baseVal then
			if Vars.DebugMode then
				PrintLog("[LeaderLib:CharacterStatListeners.lua:DetectStatChanges] (%s) base stat (%s) changed: %s => %s", uuid, stat, lastVal, baseVal)
			end
			Osi.LeaderLib_CharacterSheet_AttributeChanged(uuid, stat, lastVal, baseVal)
			FireListenerEvents(uuid, stat, lastVal, baseVal, statType)
			playerData.attributes[stat] = baseVal
		end
	elseif statType == "ability" then
		local lastVal = playerData.abilities[stat] or 0
		local baseVal = CharacterGetBaseAbility(uuid, stat) or 0
		if lastVal ~= baseVal then
			if Vars.DebugMode then
				PrintLog("[LeaderLib:CharacterStatListeners.lua:DetectStatChanges] (%s) base stat (%s) changed: %s => %s", uuid, stat, lastVal, baseVal)
			end
			Osi.LeaderLib_CharacterSheet_AbilityChanged(uuid, stat, lastVal, baseVal)
			FireListenerEvents(uuid, stat, lastVal, baseVal, statType)
			playerData.abilities[stat] = baseVal
		end
	end
end

local function SignalPartyValueChanges()
	for _,entry in pairs(Osi.DB_IsPlayer:Get(nil)) do
		local uuid = StringHelpers.GetUUID(entry[1])
		local playerData = GetStoredPlayerValues(uuid)
		if playerData ~= nil then
			for _,stat in Data.Attribute:Get() do
				DetectStatChanges(uuid, playerData, stat, "attribute")
			end
			for _,stat in Data.Ability:Get() do
				DetectStatChanges(uuid, playerData, stat, "ability")
			end
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

local function RunChangesDetectionTimer()
	TimerCancel("Timers_LeaderLib_CharacterSheet_SignalPartyValueChanges")
	TimerLaunch("Timers_LeaderLib_CharacterSheet_SignalPartyValueChanges", 1000)
end

local function OnCharacterSheetStatChanged(cmd, uuid, stat, statType)
	--print("OnCharacterSheetStatChanged", cmd, uuid, stat, statType)
	RunChangesDetectionTimer()
	-- StartOneshotTimer("Timers_LeaderLib_CheckStatChanges_"..uuid, 1000, function()
	-- 	Osi.LeaderLib_CharacterSheet_PointsChanged(stat)
	-- 	local playerData = GetStoredPlayerValues(uuid)
	-- 	if playerData ~= nil then
	-- 		DetectStatChanges(uuid, playerData, stat, statType)
	-- 	else
	-- 		RunChangesDetectionTimer()
	-- 	end
	-- end)
end

Ext.RegisterNetListener("LeaderLib_CharacterSheet_AttributeChanged", function(cmd, payload)
	local data = Ext.JsonParse(payload)
	if data then
		local uuid = Ext.GetCharacter(data.NetID).MyGuid
		OnCharacterSheetStatChanged(cmd, uuid, data.Stat, "attribute")
	end
end)

Ext.RegisterNetListener("LeaderLib_CharacterSheet_AbilityChanged", function(cmd, payload)
	local data = Ext.JsonParse(payload)
	if data then
		local uuid = Ext.GetCharacter(data.NetID).MyGuid
		OnCharacterSheetStatChanged(cmd, uuid, data.Stat, "ability")
	end
end)

---@type uuid string
---@type ability string
---@type old integer
---@type new integer
local function OnCharacterBaseAbilityChanged(uuid, ability, old, new)
	if CharacterIsPlayer(uuid) == 1 then
		uuid = StringHelpers.GetUUID(uuid)
		FireListenerEvents(uuid, ability, old, new)
		statChanges[uuid][ability] = new
	end
end

RegisterProtectedOsirisListener("CharacterBaseAbilityChanged", 4, "after", OnCharacterBaseAbilityChanged)

RegisterProtectedOsirisListener("CharacterJoinedParty", 1, "after", function(partyMember)
	--Create the data
	GetStoredPlayerValues(StringHelpers.GetUUID(partyMember))
	Ext.BroadcastMessage("LeaderLib_UI_RefreshStatusMCVisibility", "")
end)

RegisterProtectedOsirisListener("CharacterLeftParty", 1, "after", function(partyMember)
	if CharacterIsPlayer(partyMember) == 0 then
		statChanges[StringHelpers.GetUUID(partyMember)] = nil
	end
end)