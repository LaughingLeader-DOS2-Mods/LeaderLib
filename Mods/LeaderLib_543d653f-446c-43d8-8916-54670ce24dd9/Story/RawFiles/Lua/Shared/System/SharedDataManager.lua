if GameHelpers.Data == nil then
	GameHelpers.Data = {}
end

local ClientCharacterData = Classes.ClientCharacterData

local isClient = Ext.IsClient()

---@class LEVELTYPE
LEVELTYPE = {
	GAME = 1,
	CHARACTER_CREATION = 2,
	LOBBY = 3,
	EDITOR = 4,
}

---@class GAMEMODE
GAMEMODE = {
	CAMPAIGN = 1,
	ARENA = 2,
	GAMEMASTER = 3
}

local UserIds = {}

---@class REGIONSTATE
REGIONSTATE = {
	NONE = 0,
	STARTED = 1,
	GAME = 2,
	ENDED = 3
}

---@class SharedData
SharedData = {
	RegionData = {
		Current = "",
		---@type LEVELTYPE
		LevelType = LEVELTYPE.GAME,
		---@type LEVELTYPE
		LastLevelType = -1,
		---@type REGIONSTATE
		State = REGIONSTATE.NONE
	},
	---@type table<string, ClientCharacterData>
	CharacterData = {},
	ModData = {},
	GameMode = GAMEMODE.CAMPAIGN
}

if isClient then
	---@type ClientData
	Client = Classes.ClientData:Create("")
else
	---@param id integer
	---@param profile string
	---@param uuid string
	---@param isHost boolean
	local function SendSyncListenerEvent(id, profile, uuid, isHost)
		InvokeListenerCallbacks(Listeners.SyncData, id, profile, uuid, isHost)
	end

	local function GetNetID(uuid)
		local character = Ext.GetCharacter(uuid)
		if character then
			return character.NetID
		end
	end

	local function PrepareSharedData(profile, isHost, id, netid)
		local data = {
			Shared = {
				RegionData = SharedData.RegionData,
				ModData = SharedData.ModData,
				GameMode = SharedData.GameMode,
				CharacterData = {}
			},
			Profile = profile,
			IsHost = isHost,
			ID = id,
			NetID = netid
		}
		for k,v in pairs(SharedData.CharacterData) do
			data.Shared.CharacterData[k] = v:Export()
		end
		return data
	end

	function GameHelpers.Data.SyncSharedData(syncSettings, client, ignoreProfile)
		if CharacterGetHostCharacter() == nil then
			return
		end
		if client == nil then
			local totalUsers = Common.TableLength(UserIds, true)
			--GameHelpers.Net.Broadcast("LeaderLib_SharedData_StoreData", Common.JsonStringify(SharedData), nil)
			if totalUsers <= 0 then
				IterateUsers("LeaderLib_StoreUserData")
			else
				local host = CharacterGetHostCharacter()
				if SharedData.GameMode == GAMEMODE.GAMEMASTER then
					local gm = Ext.GetCharacter(host)
					if gm then
						UserIds[gm.ReservedUserID] = true
					end
				end
				for id,b in pairs(UserIds) do
					local profile = GetUserProfileID(id)
					if profile ~= ignoreProfile then
						local uuid = StringHelpers.GetUUID(GetCurrentCharacter(id))
						local isHost = host ~= nil and CharacterGetReservedUserID(host) == id or false
						local netid = GetNetID(uuid)
						local data = PrepareSharedData(profile, isHost, id, netid)
						SendSyncListenerEvent(id, profile, uuid, isHost)
						GameHelpers.Net.PostToUser(id, "LeaderLib_SharedData_StoreData", Common.JsonStringify(data))
						GameSettingsManager.Sync(id)
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
				local netid = GetNetID(uuid)
				local data = PrepareSharedData(profile, isHost, id, netid)
				SendSyncListenerEvent(id, profile, uuid, isHost)
				GameHelpers.Net.PostToUser(id, "LeaderLib_SharedData_StoreData", Common.JsonStringify(data))
				GameSettingsManager.Sync(id)
			end
		end
		if syncSettings == true then
			SettingsManager.SyncAllSettings(client, true)
		end
	end

	local syncSettingsNext = false

	local function OnSyncTimer()
		GameHelpers.Data.SyncSharedData(syncSettingsNext)
		syncSettingsNext = false
	end

	function GameHelpers.Data.StartSyncTimer(delay, syncSettings)
		syncSettingsNext = true
		Timer.StartOneshot("LeaderLib_SyncSharedData", delay or 50, OnSyncTimer)
	end

	function GameHelpers.Data.SetRegion(region)
		SharedData.RegionData.LastLevelType = SharedData.RegionData.LevelType

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

	Ext.RegisterOsirisListener("RegionStarted", 1, "after", function(region)
		SharedData.RegionData.State = REGIONSTATE.STARTED
		GameHelpers.Data.SetRegion(region)
		InvokeListenerCallbacks(Listeners.RegionChanged, region, SharedData.RegionData.State, SharedData.RegionData.LevelType)
	end)
	
	Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region)
		SharedData.RegionData.State = REGIONSTATE.GAME
		GameHelpers.Data.SetRegion(region)
		InvokeListenerCallbacks(Listeners.RegionChanged, region, SharedData.RegionData.State, SharedData.RegionData.LevelType)
	end)
	
	Ext.RegisterOsirisListener("RegionEnded", 1, "after", function(region)
		SharedData.RegionData.State = REGIONSTATE.ENDED
		GameHelpers.Data.SetRegion(region)
		InvokeListenerCallbacks(Listeners.RegionChanged, region, SharedData.RegionData.State, SharedData.RegionData.LevelType)
	end)

	function GameHelpers.Data.SetGameMode(gameMode)
		if not gameMode then
			local db = Osi.DB_LeaderLib_GameMode:Get(nil,nil)
			if db and #db > 0 then
				gameMode = db[1][1]
			end
		end
		if gameMode then
			if gameMode == "Campaign" then
				SharedData.GameMode = GAMEMODE.CAMPAIGN
			elseif gameMode == "GameMaster" then
				SharedData.GameMode = GAMEMODE.GAMEMASTER
			elseif gameMode == "Arena" then
				SharedData.GameMode = GAMEMODE.ARENA
			end
		else
			SharedData.GameMode = GAMEMODE.CAMPAIGN
		end
	end

	Ext.RegisterOsirisListener("GameModeStarted", 2, "after", function(gameMode, isEditorMode)
		GameHelpers.Data.SetGameMode(gameMode)
		
		-- Only needs to be loaded if we'll be going to CC, and if Origins is the adventure.
		local firstLevel = Osi.DB_GLO_FirstLevelAfterCharacterCreation:Get(nil)
		if firstLevel and #firstLevel > 0 then
			firstLevel = firstLevel[1][1]
		end
		if firstLevel == "TUT_Tutorial_A" then
			SkipTutorial.Initialize()
		end
	end)

	local function GetUserData(uuid)
		local id = CharacterGetReservedUserID(uuid)
		if id ~= nil then
			local profile = GetUserProfileID(id)
			return id,profile
		end
		return nil
	end

	local function TryGetProfileId(id)
		local profileId = GetUserProfileID(id)
		if profileId then
			return profileId
		end
		local host = CharacterGetHostCharacter()
		if not StringHelpers.IsNullOrEmpty(host) then
			local hostId = CharacterGetReservedUserID(host)
			if hostId then
				profileId = GetUserProfileID(hostId)
				if profileId then
					return profileId
				end
			end
		end
		return nil
	end

	function GameHelpers.Data.SetCharacterData(id, profileId, uuid, isInCharacterCreation)
		if profileId == nil then
			profileId = TryGetProfileId(id)
		end
		if profileId == nil then
			return false
		end
		uuid = StringHelpers.GetUUID(uuid or GetCurrentCharacter(id))
		if not StringHelpers.IsNullOrEmpty(uuid) then
			local character = Ext.GetCharacter(uuid)
			if character then
				local isHost = CharacterGetReservedUserID(CharacterGetHostCharacter()) == id
				---@type ClientCharacterData
				local params = {
					UUID = character.MyGuid,
					NetID = character.NetID,
					IsHost = isHost,
					IsInCharacterCreation = isInCharacterCreation,
					IsPossessed = character.IsPossessed,
					IsGameMaster = character.IsGameMaster or (SharedData.GameMode == GAMEMODE.GAMEMASTER and isHost),
					IsPlayer = character.IsPlayer,
					Profile = profileId,
					ID = id,
				}
				if SharedData.CharacterData[profileId] == nil then
					--Create(character.MyGuid, id, profileId, character.NetID, isHost, isInCharacterCreation)
					SharedData.CharacterData[profileId] = ClientCharacterData:Create(params)
				else
					SharedData.CharacterData[profileId]:Update(params)
				end
				GameHelpers.Data.StartSyncTimer()
				return true
			end
		end
		--If we're still here then something went wrong, so clear the data for this profile
		SharedData.CharacterData[profileId] = nil
		return false
	end

	function GameHelpers.Data.UpdateCharacterPoints()
		for profile,cdata in pairs(SharedData.CharacterData) do
			cdata:UpdatePoints()
		end
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
			local profileId = GetUserProfileID(id)
			local name = GetUserName(id)
			Vars.Users[profileId] = {ID=id, Name=name}
			GameHelpers.Data.SetCharacterData(id, profileId)
		end
	end)

	Ext.RegisterOsirisListener("UserDisconnected", 3, "after", function(id, username, profileId)
		UserIds[id] = nil
		SharedData.CharacterData[profileId] = nil
		GameHelpers.Data.StartSyncTimer()
	end)

	Ext.RegisterOsirisListener("CharacterReservedUserIDChanged", 3, "after", function(uuid, last, id)
		UserIds[last] = nil
		if id > -1 then
			UserIds[id] = true
			GameHelpers.Data.SetCharacterData(id)
		elseif last > -1 then
			GameHelpers.Data.SetCharacterData(last)
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

	local function OnPointsChanged(uuid)
		if GameHelpers.Character.IsPlayer(uuid) then
			GameHelpers.Data.StartSyncTimer(500)
		end
	end

	Ext.RegisterOsirisListener("CharacterLeveledUp", 1, "after", OnPointsChanged)

	--Calls not supported.
	-- Ext.RegisterOsirisListener("CharacterAddAttributePoint", 2, "after", OnPointsChanged)
	-- Ext.RegisterOsirisListener("CharacterAddAbilityPoint", 2, "after", OnPointsChanged)
	-- Ext.RegisterOsirisListener("CharacterAddCivilAbilityPoint", 2, "after", OnPointsChanged)
	-- Ext.RegisterOsirisListener("CharacterAddTalentPoint", 2, "after", OnPointsChanged)
	-- Ext.RegisterOsirisListener("CharacterAddTalentPoint", 2, "after", OnPointsChanged)
	-- Ext.RegisterOsirisListener("CharacterAddSourcePoints", 2, "after", OnPointsChanged)
	-- Ext.RegisterOsirisListener("CharacterOverrideMaxSourcePoints", 2, "after", OnPointsChanged)
	-- Ext.RegisterOsirisListener("CharacterRemoveMaxSourcePointsOverride", 2, "after", OnPointsChanged)

	Ext.RegisterListener("GameStateChanged", function(from, to)
		if to == "Running" and from ~= "Paused" then
			IterateUsers("LeaderLib_StoreUserData")
			GameHelpers.Data.StartSyncTimer()
		end
	end)

	Ext.RegisterNetListener("LeaderLib_SharedData_CharacterSelected", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data ~= nil then
			local profile = data.Profile
			local netid = data.NetID
			local id = -1
			if netid ~= nil then
				local character = Ext.GetCharacter(netid)
				if character then
					if profile ~= nil and SharedData.CharacterData[profile] ~= nil then
						local charData = SharedData.CharacterData[profile]
						charData.UUID = character.MyGuid
						charData.NetID = netid
						GameHelpers.Data.SyncSharedData(true, nil, profile)
					else
						local id,profile = GetUserData(character.MyGuid)
						if id ~= nil then
							GameHelpers.Data.SetCharacterData(id, profile, character.MyGuid, false)
						end
					end
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

if isClient then
	local defaultEmptyCharacter = Classes.ClientCharacterData:Create()

	local function GetClientCharacter(profile, netid)
		if profile == nil then
			profile = Client.Profile
		end
		if SharedData.CharacterData ~= nil and profile ~= nil and SharedData.CharacterData[profile] then
			return SharedData.CharacterData[profile]
		end
		--Fallback in case all we have is a netid
		if netid then
			local character = Ext.GetCharacter(netid)
			if character then
				SharedData.CharacterData[profile] = Classes.ClientCharacterData:Create({
					UUID = character.MyGuid,
					NetID = character.NetID,
					IsHost = false,
					IsInCharacterCreation = SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION,
					IsPossessed = false,
					IsGameMaster = false,
					IsPlayer = true,
					Profile = profile,
				})
				return SharedData.CharacterData[profile]
			end
		end
		return defaultEmptyCharacter
	end
	GameHelpers.Data.GetClientCharacter = GetClientCharacter

	---@param currentCharacter ClientCharacterData
	local function ActiveCharacterChanged(currentCharacter, last)
		currentCharacter = currentCharacter or GetClientCharacter()
		if Vars.DebugMode then
			fprint(LOGLEVEL.DEFAULT, "[LeaderLib:ActiveCharacterChanged] Profile(%s) NameOrID(%s) Last(%s)", currentCharacter.Profile, (GameHelpers.Character.GetDisplayName(currentCharacter.NetID)) or currentCharacter.NetID, (last and GameHelpers.Character.GetDisplayName(last)) or -1)
			local character = Ext.GetCharacter(currentCharacter.NetID)
			if character then
				fprint(LOGLEVEL.DEFAULT, "DisplayName(%s) StoryDisplayName(%s) OriginalDisplayName(%s) PlayerCustomData.Name(%s)", character.DisplayName, character.StoryDisplayName, character.OriginalDisplayName, character.PlayerCustomData and character.PlayerCustomData.Name or "")
			end
		end
		InvokeListenerCallbacks(Listeners.ClientCharacterChanged, currentCharacter.UUID, currentCharacter.ID, currentCharacter.Profile, currentCharacter.NetID, currentCharacter.IsHost)
	end

	local function StoreData(cmd, payload)
		local last = GetClientCharacter().NetID
		local data = Common.JsonParse(payload)
		if data ~= nil then
			if not SharedData then
				SharedData = data.Shared
			else
				--Update to new values this way, in case mods have set a variable to LeaderLib.SharedData
				for k,v in pairs(data.Shared) do
					SharedData[k] = v
				end
			end
			Client:SetClientData(data.ID, data.Profile, data.IsHost, GetClientCharacter(data.Profile, data.NetID))
			InvokeListenerCallbacks(Listeners.ClientDataSynced, SharedData.ModData, SharedData)
			if Client.Character.NetID ~= last then
				ActiveCharacterChanged(Client.Character, last)
			end
			if not Vars.Initialized then
				InvokeListenerCallbacks(Listeners.Initialized, SharedData.RegionData.Current)
				Vars.Initialized = true
			end
			InvokeListenerCallbacks(Listeners.RegionChanged, SharedData.RegionData.State, SharedData.RegionData.Current, SharedData.RegionData.LevelType)
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
		if not doubleHandle or doubleHandle == 0 then
			return
		end
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
						ActiveCharacterChanged(currentCharacter, last)
					end
				else
					--changeDetected = true
				end
				if changeDetected and skipSync ~= true then
					Ext.PostMessageToServer("LeaderLib_SharedData_CharacterSelected", Common.JsonStringify({Profile = Client.Profile, UUID = uuid, NetID=character.NetID}))
				end
			end
		end
	end

	local lastCharacterOutsideTrade = ""

	Ext.RegisterUITypeInvokeListener(Data.UIType.playerInfo, "selectPlayer", OnCharacterSelected)
	Ext.RegisterUITypeInvokeListener(Data.UIType.hotBar, "setPlayerHandle", OnCharacterSelected)
	Ext.RegisterUITypeInvokeListener(Data.UIType.bottomBar_c, "setPlayerHandle", OnCharacterSelected)
	Ext.RegisterUITypeCall(Data.UIType.playerInfo, "charSel", OnCharacterSelected, "After")
	Ext.RegisterUITypeCall(Data.UIType.characterSheet, "selectCharacter", OnCharacterSelected, "After")
	--Sheet UI opened, or character switched
	Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "selectCharacter", OnCharacterSelected, "After")
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
	
	-- Ext.RegisterListener("SessionLoaded", function()
	-- 	--Ext.RegisterUINameCall("charSel", OnCharacterSelected)
	-- 	--Ext.RegisterUINameCall("selectCharacter", OnCharacterSelected)
	-- end)

	Ext.RegisterListener("UIObjectCreated", function(ui)
		if ui:GetTypeId() == Data.UIType.trade or ui:GetTypeId() == Data.UIType.trade_c then
			local currentCharacter = GetClientCharacter()
			if currentCharacter ~= nil then
				lastCharacterOutsideTrade = currentCharacter.UUID
			end
		end
	end)
end