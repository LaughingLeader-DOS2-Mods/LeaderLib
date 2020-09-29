GameHelpers.Data = {}

local ClientCharacterData = Classes.ClientCharacterData

---@class LEVELTYPE
LEVELTYPE = {
	GAME = 1,
	CHARACTER_CREATION = 2,
	LOBBY = 3,
	EDITOR = 4,
}

local UserIds = {}

---@class SharedData
SharedData = {
	RegionData = {
		Current = "",
		---@type LEVELTYPE
		LevelType = LEVELTYPE.GAME
	},
	---@type table<string, ClientCharacterData>
	CharacterData = {},
	ModData = {}
}
if Ext.IsClient() then
	---@type ClientData
	Client = Classes.ClientData:Create("")
end

if Ext.IsServer() then
	function GameHelpers.Data.SyncSharedData(client, ignoreProfile, skipSettingsSync)
		if #Listeners.SyncData > 0 then
			for i,callback in pairs(Listeners.SyncData) do
				local status,result = xpcall(callback, debug.traceback, SharedData.ModData, client)
				if not status then
					Ext.PrintError("Error calling function for 'SyncData':\n", result)
				end
			end
		end
		if client == nil then
			--Ext.BroadcastMessage("LeaderLib_SharedData_StoreData", Ext.JsonStringify(SharedData), nil)
			for id,b in pairs(UserIds) do
				local profile = GetUserProfileID(id)
				if profile ~= ignoreProfile then
					local uuid = StringHelpers.GetUUID(GetCurrentCharacter(id))
					local isHost = StringHelpers.GetUUID(CharacterGetHostCharacter()) == uuid
					local data = {
						Shared = SharedData,
						Profile = profile,
					}
					Ext.PostMessageToUser(id, "LeaderLib_SharedData_StoreData", Ext.JsonStringify(data))
				end
			end
		else
			local clientType = type(client)
			local id = nil
			local uuid = nil
			local profile = nil
			if clientType == "string" then
				id = CharacterGetReservedUserID(client)
				profile = GetUserProfileID(id)
				uuid = client
			elseif clientType == "number" then
				profile = GetUserProfileID(client)
				uuid = StringHelpers.GetUUID(GetCurrentCharacter(client))
				id = client
			else
				Ext.PrintError("[LeaderLib:GameHelpers.Data.SyncSharedData] Error syncing data: client is an incorrect type:", clientType, client)
			end
			if profile ~= ignoreProfile then
				local isHost = StringHelpers.GetUUID(CharacterGetHostCharacter()) == StringHelpers.GetUUID(GetCurrentCharacter(id))
				local data = {
					Shared = SharedData,
					Profile = profile,
				}
				Ext.PostMessageToUser(id, "LeaderLib_SharedData_StoreData", Ext.JsonStringify(data))
			end
		end
		if skipSettingsSync ~= true then
			--SettingsManager.Sync()
			SettingsManager.SyncAllSettings(client)
		end
	end

	local function OnSyncTimer()
		GameHelpers.Data.SyncSharedData()
	end

	function GameHelpers.Data.StartSyncTimer(delay)
		StartOneshotTimer("Timers_LeaderLib_SyncSharedData", delay or 50, OnSyncTimer)
	end

	function GameHelpers.Data.SetRegion(region)
		SharedData.RegionData.Current = region
		if IsCharacterCreationLevel(region) == 1 then
			SharedData.RegionData.LevelType = LEVELTYPE.CHARACTER_CREATION
		elseif IsGameLevel(region) == 1 then
			SharedData.RegionData.LevelType = LEVELTYPE.GAME
		elseif string.find(region, "Lobby") then
			SharedData.RegionData.LevelType = LEVELTYPE.LOBBY
		else
			SharedData.RegionData.LevelType = LEVELTYPE.EDITOR
		end
	end
	Ext.RegisterOsirisListener("RegionStarted", 1, "after", GameHelpers.Data.SetRegion)

	local function GetUserData(uuid)
		local id = CharacterGetReservedUserID(uuid)
		if id ~= nil then
			local profile = GetUserProfileID(id)
			return id,profile
		end
		return nil
	end

	function GameHelpers.Data.SetCharacterData(id, profileId, uuid, isInCharacterCreation)
		if profileId == nil then
			profileId = GetUserProfileID(id)
		end
		uuid = StringHelpers.GetUUID(uuid or GetCurrentCharacter(id))
		local isHost = StringHelpers.GetUUID(CharacterGetHostCharacter()) == uuid
		if SharedData.CharacterData[profileId] == nil then
			SharedData.CharacterData[profileId] = ClientCharacterData:Create(uuid, id, profileId, isHost, isInCharacterCreation)
		else
			local data = SharedData.CharacterData[profileId]
			data.UUID = uuid
			data.Profile = profileId
			data.ID = id
			data.IsHost = isHost
			if isInCharacterCreation ~= nil then
				data.IsInCharacterCreation = isInCharacterCreation
			end
		end
	end

	Ext.RegisterOsirisListener("UserConnected", 3, "after", function(id, username, profileId)
		UserIds[id] = true
		GameHelpers.Data.SetCharacterData(id, profileId)
		GameHelpers.Data.StartSyncTimer()
	end)

	Ext.RegisterOsirisListener("UserEvent", 2, "after", function(id, event)
		UserIds[id] = true
		if event == "LeaderLib_StoreUserData" then
			GameHelpers.Data.SetCharacterData(id)
			GameHelpers.Data.StartSyncTimer()
		end
	end)

	Ext.RegisterOsirisListener("UserDisconnected", 3, "after", function(id, username, profileId)
		UserIds[id] = nil
		SharedData.CharacterData[profileId] = nil
		GameHelpers.Data.StartSyncTimer()
	end)

	Ext.RegisterOsirisListener("CharacterReservedUserIDChanged", 3, "after", function(uuid, last, id)
		UserIds[last] = nil
		UserIds[id] = true
		GameHelpers.Data.SetCharacterData(id)
		GameHelpers.Data.StartSyncTimer()
	end)

	Ext.RegisterOsirisListener("PROC_HandleMagicMirrorResult", 2, "after", function(uuid, result)
		if not StringHelpers.IsNullOrEmpty(uuid) and result == 1 then
			uuid = StringHelpers.GetUUID(uuid)
			local id,profile = GetUserData(uuid)
			if id ~= nil then
				GameHelpers.Data.SetCharacterData(id, profile, uuid, true)
				GameHelpers.Data.StartSyncTimer()
			end
		end
	end)

	Ext.RegisterOsirisListener("CharacterCreationFinished", 1, "after", function(uuid)
		if not StringHelpers.IsNullOrEmpty(uuid) then
			uuid = StringHelpers.GetUUID(uuid)
			local id,profile = GetUserData(uuid)
			if id ~= nil then
				GameHelpers.Data.SetCharacterData(id, profile, uuid, false)
				GameHelpers.Data.StartSyncTimer()
			end
		end
	end)

	Ext.RegisterListener("GameStateChanged", function(from, to)
		if to == "Running" and from ~= "Paused" then
			GameHelpers.Data.StartSyncTimer()
		end
	end)

	Ext.RegisterNetListener("LeaderLib_SharedData_CharacterSelected", function(cmd, payload)
		local data = Ext.JsonParse(payload)
		if data ~= nil then
			local profile = data.Profile
			local uuid = data.UUID
			if profile ~= nil and uuid ~= nil and SharedData.CharacterData[profile] ~= nil then
				SharedData.CharacterData[profile].UUID = uuid
				GameHelpers.Data.SyncSharedData(nil, profile, true)
			end
		end
	end)
end

if Ext.IsClient() then
	local function GetClientCharacter()
		if SharedData.CharacterData ~= nil and Client.Profile ~= nil then
			return SharedData.CharacterData[Client.Profile]	
		end
		return {UUID = "", ID = -1, Profile = ""}
	end
	GameHelpers.Data.GetClientCharacter = GetClientCharacter

	local function ActiveCharacterChanged(currentCharacter)
		currentCharacter = currentCharacter or GetClientCharacter()
		if #Listeners.ClientCharacterChanged > 0 then
			for i,callback in pairs(Listeners.ClientCharacterChanged) do
				local status,err = xpcall(callback, debug.traceback, currentCharacter.UUID, currentCharacter.ID, currentCharacter.Profile, currentCharacter.IsHost)
				if not status then
					Ext.PrintError("Error calling function for 'ClientCharacterChanged':\n", err)
				end
			end
		end
	end

	Ext.RegisterNetListener("LeaderLib_SharedData_StoreData", function(cmd, payload)
		local last = GetClientCharacter().UUID
		local data = Ext.JsonParse(payload)
		SharedData = data.Shared
		Client.Profile = data.Profile
		Client.Character = GetClientCharacter()
		if #Listeners.ClientDataSynced > 0 then
			for i,callback in pairs(Listeners.ClientDataSynced) do
				local status,err = xpcall(callback, debug.traceback, SharedData.ModData)
				if not status then
					Ext.PrintError("Error calling function for 'ClientDataSynced':\n", err)
				end
			end
		end
		if Client.Character.UUID ~= last then
			ActiveCharacterChanged(Client.Character)
		end
	end)

	local function OnCharacterSelected(ui, call, doubleHandle, skipSync)
		--print(ui:GetTypeId(), call, doubleHandle)
		local handle = Ext.DoubleToHandle(doubleHandle)
		if handle ~= nil then
			local character = Ext.GetCharacter(handle)
			if character ~= nil then
				local currentCharacter = GetClientCharacter()
				if currentCharacter ~= nil then
					--print(currentCharacter.UUID, "=>", character.MyGuid)
					currentCharacter.UUID = character.MyGuid
					ActiveCharacterChanged(currentCharacter)
				end
				if skipSync ~= true then
					Ext.PostMessageToServer("LeaderLib_SharedData_CharacterSelected", Ext.JsonStringify({Profile = SharedData.Profile, UUID = character.MyGuid}))
				end
			end
		end
	end

	local lastCharacterOutsideTrade = ""

	Ext.RegisterListener("SessionLoaded", function()
		Ext.RegisterUITypeCall(Data.UIType.playerInfo, "charSel", OnCharacterSelected)
		Ext.RegisterUITypeCall(Data.UIType.characterSheet, "selectCharacter", OnCharacterSelected)
		Ext.RegisterUITypeCall(Data.UIType.trade, "selectCharacter", function(ui, call, doubleHandle)
			OnCharacterSelected(ui, call, doubleHandle, true)
		end)
		Ext.RegisterUITypeCall(Data.UIType.trade, "cancel", function(ui, call)
			if lastCharacterOutsideTrade ~= "" then
				local currentCharacter = GetClientCharacter()
				if currentCharacter ~= nil then
					--print(currentCharacter.UUID, "=>", lastCharacterOutsideTrade)
					currentCharacter.UUID = lastCharacterOutsideTrade
					ActiveCharacterChanged(currentCharacter)
				end
			end
		end)
		--Ext.RegisterUINameCall("charSel", OnCharacterSelected)
		--Ext.RegisterUINameCall("selectCharacter", OnCharacterSelected)
	end)

	Ext.RegisterListener("UIObjectCreated", function(ui)
		if ui:GetTypeId() == Data.UIType.trade then
			local currentCharacter = GetClientCharacter()
			if currentCharacter ~= nil then
				lastCharacterOutsideTrade = currentCharacter.UUID
			end
		end
	end)
end