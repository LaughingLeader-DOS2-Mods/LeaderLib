GameHelpers.Data = {}

---@class LEVELTYPE
LEVELTYPE = {
	GAME = 1,
	CHARACTER_CREATION = 2,
	LOBBY = 3,
	EDITOR = 4,
}

---@class ClientCharacterData
local ClientCharacterData = {
	UUID = "",
	ID = "",
	Profile = "",
	IsHost = false
}

ClientCharacterData.__index = ClientCharacterData

function ClientCharacterData:Create(uuid, id, profile, isHost)
	local this = {
		UUID = uuid,
		ID = id,
		Profile = profile,
		IsHost = isHost or false
	}
	setmetatable(this, ClientCharacterData)
	return this
end

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
	SharedData.IsHost = false
	SharedData.ID = -1
	SharedData.Profile = ""
	SharedData.CurrentCharacter = function()
		return SharedData.CharacterData[SharedData.Profile]		
	end
end

if Ext.IsServer() then
	function GameHelpers.Data.SyncSharedData(client)
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
				local isHost = StringHelpers.GetUUID(CharacterGetHostCharacter()) == StringHelpers.GetUUID(GetCurrentCharacter(id))
				local data = {
					RegionData = SharedData.RegionData, 
					CharacterData = SharedData.CharacterData, 
					ModData = SharedData.ModData, 
					ID = id, 
					Profile = GetUserProfileID(id),
					IsHost = isHost
				}
				Ext.PostMessageToUser(id, "LeaderLib_SharedData_StoreData", Ext.JsonStringify(data))
			end
		else
			local id = CharacterGetReservedUserID(client)
			local profile = GetUserProfileID(id)
			local isHost = StringHelpers.GetUUID(CharacterGetHostCharacter()) == StringHelpers.GetUUID(GetCurrentCharacter(id))
			local data = {
				RegionData = SharedData.RegionData, 
				CharacterData = SharedData.CharacterData, 
				ModData = SharedData.ModData, 
				ID = id, 
				Profile = GetUserProfileID(id),
				IsHost = isHost
			}
			Ext.PostMessageToUser(id, "LeaderLib_SharedData_StoreData", Ext.JsonStringify(data))
		end
		--SettingsManager.Sync()
		SettingsManager.SyncAllSettings(client)
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

	function GameHelpers.Data.SetCharacterData(id, profileId)
		if profileId == nil then
			profileId = GetUserProfileID(id)
		end
		local uuid = StringHelpers.GetUUID(GetCurrentCharacter(id) or "")
		local isHost = StringHelpers.GetUUID(CharacterGetHostCharacter()) == uuid
		if SharedData.CharacterData[profileId] == nil then
			SharedData.CharacterData[profileId] = ClientCharacterData:Create(uuid, id, profileId, isHost)
		else
			local data = SharedData.CharacterData[profileId]
			data.UUID = uuid
			data.Profile = profileId
			data.ID = id
			data.IsHost = isHost
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

	Ext.RegisterListener("GameStateChanged", function(from, to)
		if to == "Running" and from ~= "Paused" then
			GameHelpers.Data.StartSyncTimer()
		end
	end)
end

if Ext.IsClient() then
	Ext.RegisterNetListener("LeaderLib_SharedData_StoreData", function(cmd, payload)
		SharedData = Ext.JsonParse(payload)
		if #Listeners.ClientDataSynced > 0 then
			for i,callback in pairs(Listeners.ClientDataSynced) do
				local status,err = xpcall(callback, debug.traceback, SharedData)
				if not status then
					Ext.PrintError("Error calling function for 'ClientDataSynced':\n", err)
				end
			end
		end
	end)
end