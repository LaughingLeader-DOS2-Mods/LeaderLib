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
	---@param id integer
	---@param profile string
	---@param uuid string
	---@param isHost boolean
	local function SendSyncListenerEvent(id, profile, uuid, isHost)
		InvokeListenerCallbacks(Listeners.SyncData, id, profile, uuid, isHost)
	end

	function GameHelpers.Data.SyncSharedData(syncSettings, client, ignoreProfile)
		if client == nil then
			local totalUsers = Common.TableLength(UserIds, true)
			--Ext.BroadcastMessage("LeaderLib_SharedData_StoreData", Ext.JsonStringify(SharedData), nil)
			if totalUsers <= 0 then
				IterateUsers("LeaderLib_StoreUserData")
			else
				for id,b in pairs(UserIds) do
					local profile = GetUserProfileID(id)
					if profile ~= ignoreProfile then
						local uuid = StringHelpers.GetUUID(GetCurrentCharacter(id))
						local isHost = CharacterGetReservedUserID(CharacterGetHostCharacter()) == id
						local data = {
							Shared = SharedData,
							Profile = profile,
							IsHost = isHost,
							ID = id
						}
						Ext.PostMessageToUser(id, "LeaderLib_SharedData_StoreData", Ext.JsonStringify(data))
						SendSyncListenerEvent(id, profile, uuid, isHost)
					end
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
				local isHost = CharacterGetReservedUserID(CharacterGetHostCharacter()) == id
				local data = {
					Shared = SharedData,
					Profile = profile,
					IsHost = isHost,
					ID = id
				}
				Ext.PostMessageToUser(id, "LeaderLib_SharedData_StoreData", Ext.JsonStringify(data))
				SendSyncListenerEvent(id, profile, uuid, isHost)
			end
		end
		if syncSettings == true then
			SettingsManager.SyncAllSettings(client)
		end
	end

	local syncSettingsNext = false

	local function OnSyncTimer()
		GameHelpers.Data.SyncSharedData(syncSettingsNext)
		syncSettingsNext = false
	end

	function GameHelpers.Data.StartSyncTimer(delay, syncSettings)
		if syncSettingsNext == true then
			syncSettingsNext = true
		end
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
			profileId = GetUserProfileID(id) or GetUserProfileID(CharacterGetReservedUserID(CharacterGetHostCharacter()))
		end
		if profileId == nil then
			return false
		end
		uuid = StringHelpers.GetUUID(uuid or GetCurrentCharacter(id))
		local character = Ext.GetCharacter(uuid)
		local isHost = CharacterGetReservedUserID(CharacterGetHostCharacter()) == id
		if SharedData.CharacterData[profileId] == nil then
			SharedData.CharacterData[profileId] = ClientCharacterData:Create(character.MyGuid, id, profileId, character.NetID, isHost, isInCharacterCreation)
		else
			local data = SharedData.CharacterData[profileId]
			data:SetClientCharacterData(uuid, id, profileId, character.NetID, isHost, isInCharacterCreation)
		end
		GameHelpers.Data.StartSyncTimer()
	end

	Ext.RegisterOsirisListener("UserConnected", 3, "after", function(id, username, profileId)
		if UserIds[id] ~= true then
			UserIds[id] = true
		end
		GameHelpers.Data.SetCharacterData(id, profileId)
	end)

	Ext.RegisterOsirisListener("UserEvent", 2, "after", function(id, event)
		if UserIds[id] ~= true then
			UserIds[id] = true
		end
		if event == "LeaderLib_StoreUserData" then
			GameHelpers.Data.SetCharacterData(id)
		end
	end)

	Ext.RegisterOsirisListener("UserDisconnected", 3, "after", function(id, username, profileId)
		if UserIds[id] == true then
			UserIds[id] = nil
		end
		SharedData.CharacterData[profileId] = nil
		GameHelpers.Data.StartSyncTimer()
	end)

	Ext.RegisterOsirisListener("CharacterReservedUserIDChanged", 3, "after", function(uuid, last, id)
		if UserIds[last] == true then
			UserIds[last] = nil
		end
		if id > -1 then
			if UserIds[id] ~= true then
				UserIds[id] = true
			end
			GameHelpers.Data.SetCharacterData(id)
		end
	end)

	Ext.RegisterOsirisListener("PROC_HandleMagicMirrorResult", 2, "after", function(uuid, result)
		if not StringHelpers.IsNullOrEmpty(uuid) and result == 1 then
			uuid = StringHelpers.GetUUID(uuid)
			local id,profile = GetUserData(uuid)
			if id ~= nil then
				GameHelpers.Data.SetCharacterData(id, profile, uuid, true)
			end
		end
	end)

	Ext.RegisterOsirisListener("CharacterCreationFinished", 1, "after", function(uuid)
		if not StringHelpers.IsNullOrEmpty(uuid) then
			uuid = StringHelpers.GetUUID(uuid)
			local id,profile = GetUserData(uuid)
			if id ~= nil then
				GameHelpers.Data.SetCharacterData(id, profile, uuid, false)
			end
		end
	end)

	Ext.RegisterOsirisListener("ObjectTurnStarted", 2, "after", function(char, combatid)
		if CharacterIsControlled(char) == 1 then
			local id = CharacterGetReservedUserID(char)
			if id ~= nil then
				GameHelpers.Data.SetCharacterData(id, nil, StringHelpers.GetUUID(char))
			end
		end
	end)

	Ext.RegisterListener("GameStateChanged", function(from, to)
		if to == "Running" and from ~= "Paused" then
			IterateUsers("LeaderLib_StoreUserData")
			GameHelpers.Data.StartSyncTimer()
		end
	end)

	Ext.RegisterNetListener("LeaderLib_SharedData_CharacterSelected", function(cmd, payload)
		local data = Ext.JsonParse(payload)
		if data ~= nil then
			local profile = data.Profile
			local netid = tonumber(data.NetID)
			if profile ~= nil and netid ~= nil and SharedData.CharacterData[profile] ~= nil then
				local character = Ext.GetCharacter(netid)
				if character ~= nil then
					local charData = SharedData.CharacterData[profile]
					charData.UUID = character.MyGuid
					charData.NetID = netid
					GameHelpers.Data.SyncSharedData(true, nil, profile)
				end
			end
		end
	end)
end

function GameHelpers.Data.GetPersistentVars(modTable, createIfMissing, ...)
	if modTable ~= nil then
		if Mods[modTable].PersistentVars == nil then
			Mods[modTable].PersistentVars = {}
		end
		local pvars = Mods[modTable].PersistentVars
		local variablePath = {...}
		local lastTable = pvars
		for i=1,#variablePath do
			local tableName = variablePath[i]
			if tableName ~= nil and type(tableName) == "string" then
				local ref = lastTable[tableName]
				if ref == nil and createIfMissing == true then
					ref = {}
					lastTable[tableName] = ref
				end
				if ref ~= nil then
					lastTable = ref
				else
					return nil
				end
			end
		end
		return lastTable
	end
	return nil
end

if Ext.IsClient() then
	local defaultEmptyCharacter = Classes.ClientCharacterData:Create()

	local function GetClientCharacter(profile)
		if profile == nil then
			profile = Client.Profile
		end
		if SharedData.CharacterData ~= nil and profile ~= nil then
			return SharedData.CharacterData[profile] or defaultEmptyCharacter
		end
		return defaultEmptyCharacter
	end
	GameHelpers.Data.GetClientCharacter = GetClientCharacter

	---@param currentCharacter ClientCharacterData
	local function ActiveCharacterChanged(currentCharacter)
		currentCharacter = currentCharacter or GetClientCharacter()
		InvokeListenerCallbacks(Listeners.ClientCharacterChanged, currentCharacter.UUID, currentCharacter.ID, currentCharacter.Profile, currentCharacter.NetID, currentCharacter.IsHost)
	end

	local function StoreData(cmd, payload)
		if Vars.DebugMode then
			print(cmd, payload)
		end
		local last = GetClientCharacter().UUID
		local data = Ext.JsonParse(payload)
		if data ~= nil then
			if not SharedData then
				SharedData = data.Shared
			else
				--Update to new values this way, in case mods have set a variable to LeaderLib.SharedData
				for k,v in pairs(data.Shared) do
					SharedData[k] = v
				end
			end
			Client:SetClientData(data.ID, data.Profile, data.IsHost, GetClientCharacter(data.Profile))
			InvokeListenerCallbacks(Listeners.ClientDataSynced, SharedData.ModData, SharedData)
			if Client.Character.UUID ~= last then
				ActiveCharacterChanged(Client.Character)
			end
			return true
		else
			error("Error parsing json?", payload)
		end
	end

	Ext.RegisterNetListener("LeaderLib_SharedData_StoreData", function(cmd, payload, ...)
		local b,err = xpcall(StoreData, debug.traceback, cmd, payload)
		if not b then
			Ext.PrintError(err)
		end
	end)

	local function OnCharacterSelected(ui, call, doubleHandle, skipSync)
		--print(call, doubleHandle)
		local handle = Ext.DoubleToHandle(doubleHandle)
		if handle ~= nil then
			---@type EclCharacter
			local character = Ext.GetCharacter(handle)
			if character ~= nil and not character:HasTag("SUMMON") then
				local uuid = ""
				local currentCharacter = GetClientCharacter()
				local changeDetected = currentCharacter == nil or false
				if currentCharacter ~= nil then
					local last = currentCharacter.NetID
					--print(currentCharacter.UUID, "=>", character.MyGuid)
					-- MyGuid is null for summons / temp characters
					if character.MyGuid ~= nil then
						currentCharacter.UUID = character.MyGuid
						uuid = character.MyGuid
					end
					currentCharacter.NetID = character.NetID
					if currentCharacter.NetID ~= last then
						changeDetected = true
						ActiveCharacterChanged(currentCharacter)
					end
				end
				if changeDetected and skipSync ~= true then
					Ext.PostMessageToServer("LeaderLib_SharedData_CharacterSelected", Ext.JsonStringify({Profile = SharedData.Profile, UUID = uuid, NetID=character.NetID}))
				end
			end
		end
	end

	local lastCharacterOutsideTrade = ""

	Ext.RegisterListener("SessionLoaded", function()
		Ext.RegisterUITypeInvokeListener(Data.UIType.hotBar, "setPlayerHandle", OnCharacterSelected)
		Ext.RegisterUITypeInvokeListener(Data.UIType.bottomBar_c, "setPlayerHandle", OnCharacterSelected)
		Ext.RegisterUITypeCall(Data.UIType.playerInfo, "charSel", OnCharacterSelected, "After")
		Ext.RegisterUITypeCall(Data.UIType.characterSheet, "selectCharacter", OnCharacterSelected, "After")
		Ext.RegisterUITypeCall(Data.UIType.characterSheet, "centerCamOnCharacter", OnCharacterSelected, "After")
		Ext.RegisterUITypeCall(Data.UIType.trade, "selectCharacter", function(ui, call, doubleHandle)
			OnCharacterSelected(ui, call, doubleHandle, true)
		end, "After")
		Ext.RegisterUITypeCall(Data.UIType.partyManagement_c, "setActiveChar", OnCharacterSelected, "After")
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