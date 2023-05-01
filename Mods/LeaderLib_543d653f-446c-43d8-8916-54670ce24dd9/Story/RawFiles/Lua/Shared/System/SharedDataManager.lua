if GameHelpers.Data == nil then GameHelpers.Data = {} end

local ClientCharacterData = Classes.ClientCharacterData

local _ISCLIENT = Ext.IsClient()
local _EXTVERSION = Ext.Utils.Version()

---@enum LEVELTYPE
LEVELTYPE = {
	GAME = 1,
	CHARACTER_CREATION = 2,
	LOBBY = 3,
	EDITOR = 4,
}
Classes.Enum:Create(LEVELTYPE)

---@enum GAMEMODE
GAMEMODE = {
	CAMPAIGN = 1,
	ARENA = 2,
	GAMEMASTER = 3
}
Classes.Enum:Create(GAMEMODE)

local _Users = {}

---@enum REGIONSTATE
REGIONSTATE = {
	NONE = 0,
	STARTED = 1,
	GAME = 2,
	ENDED = 3
}
Classes.Enum:Create(REGIONSTATE)

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

---Get the total amount of users.
---@return integer
function GameHelpers.Data.GetTotalUsers()
	return Common.TableLength(_Users, true)
end

local function SetCurrentLevelData()
	local level = Ext.Entity.GetCurrentLevel()
	if level then
		local levelName = level.LevelDesc.LevelName
		SharedData.RegionData.Current = levelName
		SharedData.RegionData.LevelType = GameHelpers.GetLevelType(levelName)
	end
end

SetCurrentLevelData()

Ext.Events.SessionLoading:Subscribe(SetCurrentLevelData)
Ext.Events.SessionLoaded:Subscribe(SetCurrentLevelData)

---@param region string
---@return RegionChangedEventArgs
local function _GetRegionChangedEventData(region)
	local level = Ext.Entity.GetCurrentLevel()
	local data = {
		Region = region,
		State = SharedData.RegionData.State,
		LevelType = SharedData.RegionData.LevelType,
		Level = level,
	}
	data.GetAllCharacters = function (castType, asTable)
		if castType == true then asTable = true end
		local entries = level.CharacterManager.RegisteredCharacters

		if not asTable then
			local i = 0
			local count = #entries
			return function ()
				i = i + 1
				if i <= count then
					return entries[i]
				end
			end
		else
			return entries
		end
	end
	data.GetAllItems = function (castType, asTable)
		if castType == true then asTable = true end
		local entries = level.ItemManager.Items

		if not asTable then
			local i = 0
			local count = #entries
			return function ()
				i = i + 1
				if i <= count then
					return entries[i]
				end
			end
		else
			return entries
		end
	end
	return data
end

if not _ISCLIENT then
	---@param id integer
	---@param profile string
	---@param uuid string
	---@param isHost boolean
	local function SendSyncListenerEvent(id, profile, uuid, isHost)
		Events.SyncData:Invoke({
			UserID=id,
			Profile = profile,
			UUID = uuid,
			IsHost = isHost == true
		})
	end

	local function GetNetID(uuid)
		local character = GameHelpers.GetCharacter(uuid)
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
		if Osi.CharacterGetHostCharacter() == nil then
			Ext.Utils.PrintError("[LeaderLib:GameHelpers.Data.SyncSharedData] No host character!")
			return
		end
		if client == nil then
			local totalUsers = Common.TableLength(_Users, true)
			if totalUsers <= 0 then
				Osi.IterateUsers("LeaderLib_StoreUserData")
			else
				local host = Osi.CharacterGetHostCharacter()
				if SharedData.GameMode == GAMEMODE.GAMEMASTER then
					local gm = GameHelpers.GetCharacter(host)
					if gm then
						_Users[gm.ReservedUserID] = true
					end
				end
				for id,b in pairs(_Users) do
					local profile = Osi.GetUserProfileID(id)
					if profile ~= ignoreProfile then
						local uuid = StringHelpers.GetUUID(Osi.GetCurrentCharacter(id))
						local isHost = host ~= nil and Osi.CharacterGetReservedUserID(host) == id or false
						local netid = GetNetID(uuid)
						local data = PrepareSharedData(profile, isHost, id, netid)
						SendSyncListenerEvent(id, profile, uuid, isHost)
						GameHelpers.Net.PostToUser(id, "LeaderLib_SharedData_StoreData", data)
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
				id = Osi.CharacterGetReservedUserID(client)
				profile = Osi.GetUserProfileID(id)
				uuid = client
			elseif clientType == "number" then
				profile = Osi.GetUserProfileID(client)
				uuid = StringHelpers.GetUUID(Osi.GetCurrentCharacter(client))
				id = client
			else
				Ext.Utils.PrintError("[LeaderLib:GameHelpers.Data.SyncSharedData] Error syncing data: client is an incorrect type:", clientType, client)
			end
			if profile ~= ignoreProfile then
				local isHost = Osi.CharacterGetReservedUserID(Osi.CharacterGetHostCharacter()) == id
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
	local syncOnGameState = false

	local _validSyncStates = {
		Running = true,
		Paused = true,
		GameMasterPause = true,
	}

	local function OnSyncTimer()
		local state = tostring(_GS())
		if not _validSyncStates[state] then
			syncOnGameState = true
			return
		end
		GameHelpers.Data.SyncSharedData(syncSettingsNext)
		syncSettingsNext = false
	end

	function GameHelpers.Data.StartSyncTimer(delay, syncSettings)
		syncSettingsNext = true
		Timer.Cancel("LeaderLib_SyncSharedData")
		Timer.StartOneshot("LeaderLib_SyncSharedData", delay or 50, OnSyncTimer)
	end

	function GameHelpers.Data.SetRegion(region)
		SharedData.RegionData.LastLevelType = SharedData.RegionData.LevelType

		SharedData.RegionData.Current = region
		if Osi.IsCharacterCreationLevel(region) == 1 then
			SharedData.RegionData.LevelType = LEVELTYPE.CHARACTER_CREATION
		elseif Osi.IsGameLevel(region) == 1 then
			SharedData.RegionData.LevelType = LEVELTYPE.GAME
		elseif string.find(region, "Lobby") or string.find(region, "Menu") then
			SharedData.RegionData.LevelType = LEVELTYPE.LOBBY
		else
			SharedData.RegionData.LevelType = LEVELTYPE.EDITOR
		end
	end

	Ext.Osiris.RegisterListener("RegionStarted", 1, "after", function(region)
		SharedData.RegionData.State = REGIONSTATE.STARTED
		GameHelpers.Data.SetRegion(region)
		Events.RegionChanged:Invoke(_GetRegionChangedEventData(region))
		GameHelpers.Net.Broadcast("LeaderLib_SharedData_SetRegionData", SharedData.RegionData)
	end)
	
	Ext.Osiris.RegisterListener("GameStarted", 2, "after", function(region)
		SharedData.RegionData.State = REGIONSTATE.GAME
		GameHelpers.Data.SetRegion(region)
		Events.RegionChanged:Invoke(_GetRegionChangedEventData(region))
		if _GS() ~= "Running" then
			GameHelpers.Net.Broadcast("LeaderLib_SharedData_SetRegionData", SharedData.RegionData)
		end
	end)
	
	Ext.Osiris.RegisterListener("RegionEnded", 1, "after", function(region)
		SharedData.RegionData.State = REGIONSTATE.ENDED
		GameHelpers.Data.SetRegion(region)
		Events.RegionChanged:Invoke(_GetRegionChangedEventData(region))
		if _GS() ~= "Running" then
			GameHelpers.Net.Broadcast("LeaderLib_SharedData_SetRegionData", SharedData.RegionData)
		end
	end)
	
	Events.LuaReset:Subscribe(function(e)
		SharedData.RegionData.State = REGIONSTATE.GAME
		GameHelpers.Data.SetRegion(e.Region)
		_GetRegionChangedEventData(SharedData.RegionData.Current)
		Events.RegionChanged:Invoke(_GetRegionChangedEventData(SharedData.RegionData.Current))
		GameHelpers.Net.Broadcast("LeaderLib_SharedData_SetRegionData", SharedData.RegionData)
	end)

	function GameHelpers.Data.SetGameMode(gameMode)
		if not gameMode then
			gameMode = Ext.Utils.GetGameMode()
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

	Ext.Osiris.RegisterListener("GameModeStarted", 2, "after", function(gameMode, isEditorMode)
		GameHelpers.Data.SetGameMode(gameMode)
		
		-- Only needs to be loaded if we'll be going to CC, and if Origins is the adventure.
		local firstLevel = nil
		local db = Osi.DB_GLO_FirstLevelAfterCharacterCreation:Get(nil)
		if db and #db > 0 then
			firstLevel = db[1][1]
		end
		if firstLevel == "TUT_Tutorial_A" then
			SkipTutorial.Initialize()
		end
	end)

	local function GetUserData(uuid)
		local id = Osi.CharacterGetReservedUserID(uuid)
		if id ~= nil then
			local profile = Osi.GetUserProfileID(id)
			return id,profile
		end
		return nil
	end

	local function TryGetProfileId(id)
		local profileId = Osi.GetUserProfileID(id)
		if profileId then
			return profileId
		end
		local host = Osi.CharacterGetHostCharacter()
		if not StringHelpers.IsNullOrEmpty(host) then
			local hostId = Osi.CharacterGetReservedUserID(host)
			if hostId then
				profileId = Osi.GetUserProfileID(hostId)
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
		uuid = StringHelpers.GetUUID(uuid or Osi.GetCurrentCharacter(id))
		if not StringHelpers.IsNullOrEmpty(uuid) then
			local character = GameHelpers.GetCharacter(uuid)
			if character then
				local isHost = Osi.CharacterGetReservedUserID(Osi.CharacterGetHostCharacter()) == id
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
					Username = Osi.GetUserName(id),
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

	Ext.Osiris.RegisterListener("UserConnected", 3, "after", function(id, username, profileId)
		if _Users[id] ~= true then
			_Users[id] = true
		end
		GameHelpers.Data.SetCharacterData(id, profileId)
	end)

	Ext.Osiris.RegisterListener("UserEvent", 2, "after", function(id, event)
		if _Users[id] ~= true then
			_Users[id] = true
		end
		if event == "LeaderLib_StoreUserData" then
			local profileId = Osi.GetUserProfileID(id)
			local name = Osi.GetUserName(id)
			Vars.Users[profileId] = {ID=id, Name=name}
			GameHelpers.Data.SetCharacterData(id, profileId)
		end
	end)

	Ext.Osiris.RegisterListener("UserDisconnected", 3, "after", function(id, username, profileId)
		_Users[id] = nil
		SharedData.CharacterData[profileId] = nil
		GameHelpers.Data.StartSyncTimer()
	end)

	Ext.Osiris.RegisterListener("CharacterReservedUserIDChanged", 3, "after", function(uuid, last, id)
		_Users[last] = nil
		if id > -1 then
			_Users[id] = true
			GameHelpers.Data.SetCharacterData(id)
		elseif last > -1 then
			GameHelpers.Data.SetCharacterData(last)
		end
	end)

	Ext.Osiris.RegisterListener("PROC_HandleMagicMirrorResult", 2, "after", function(uuid, result)
		if not StringHelpers.IsNullOrEmpty(uuid) and result == 1 then
			uuid = StringHelpers.GetUUID(uuid)
			local id,profile = GetUserData(uuid)
			if id ~= nil then
				GameHelpers.Data.SetCharacterData(id, profile, uuid, true)
			end
		end
	end)

	Ext.Osiris.RegisterListener("CharacterCreationFinished", 1, "after", function(uuid)
		if not StringHelpers.IsNullOrEmpty(uuid) then
			uuid = StringHelpers.GetUUID(uuid)
			local id,profile = GetUserData(uuid)
			if id ~= nil then
				GameHelpers.Data.SetCharacterData(id, profile, uuid, false)
			end
		end
	end)

	Ext.Osiris.RegisterListener("ObjectTurnStarted", 2, "after", function(char)
		if Osi.CharacterIsControlled(char) == 1 then
			local id = Osi.CharacterGetReservedUserID(char)
			if id ~= nil then
				GameHelpers.Data.SetCharacterData(id, nil, StringHelpers.GetUUID(char))
			end
		end
	end)

	local function OnPointsChanged(uuid)
		local character = GameHelpers.GetCharacter(uuid)
		if character then
			local isPlayer = GameHelpers.Character.IsPlayer(character)
			if isPlayer then
				GameHelpers.Data.StartSyncTimer(500)
			end
			Events.CharacterLeveledUp:Invoke({
				Character = character,
				CharacterGUID = character.MyGuid,
				Level = character.Stats.Level,
				IsPlayer = isPlayer
			})
		end

	end

	Ext.Osiris.RegisterListener("CharacterLeveledUp", 1, "after", OnPointsChanged)

	--Calls not supported.
	-- Ext.Osiris.RegisterListener("CharacterAddAttributePoint", 2, "after", OnPointsChanged)
	-- Ext.Osiris.RegisterListener("CharacterAddAbilityPoint", 2, "after", OnPointsChanged)
	-- Ext.Osiris.RegisterListener("CharacterAddCivilAbilityPoint", 2, "after", OnPointsChanged)
	-- Ext.Osiris.RegisterListener("CharacterAddTalentPoint", 2, "after", OnPointsChanged)
	-- Ext.Osiris.RegisterListener("CharacterAddTalentPoint", 2, "after", OnPointsChanged)
	-- Ext.Osiris.RegisterListener("CharacterAddSourcePoints", 2, "after", OnPointsChanged)
	-- Ext.Osiris.RegisterListener("CharacterOverrideMaxSourcePoints", 2, "after", OnPointsChanged)
	-- Ext.Osiris.RegisterListener("CharacterRemoveMaxSourcePointsOverride", 2, "after", OnPointsChanged)

	Ext.Events.GameStateChanged:Subscribe(function (e)
		local state = tostring(e.ToState)
		if syncOnGameState and _validSyncStates[state] then
			syncOnGameState = false
			GameHelpers.Data.SyncSharedData(syncSettingsNext)
			syncSettingsNext = false
		else
			if state == "Running" and e.FromState ~= "Paused" and e.FromState ~= "GameMasterPause" then
				Osi.IterateUsers("LeaderLib_StoreUserData")
				GameHelpers.Data.StartSyncTimer()
			end
		end
	end)

	Ext.RegisterNetListener("LeaderLib_SharedData_CharacterSelected", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data ~= nil then
			local profile = data.Profile
			local netid = data.NetID
			local id = -1
			if netid ~= nil then
				local character = GameHelpers.GetCharacter(netid)
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
	if modTable ~= nil and Mods[modTable] then
		if Mods[modTable].PersistentVars == nil and createIfMissing then
			Mods[modTable].PersistentVars = {}
		end
		local pvars = Mods[modTable].PersistentVars
		if pvars ~= nil then
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
	end
	return nil
end

if _ISCLIENT then
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
			local character = GameHelpers.GetCharacter(netid)
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
		local netid = currentCharacter.NetID
		local character = GameHelpers.GetCharacter(netid)
		Events.ClientCharacterChanged:Invoke({
			Character = character,
			CharacterGUID = currentCharacter.UUID,
			CharacterData = currentCharacter,
			IsHost = currentCharacter.IsHost,
			NetID = netid,
			Profile = currentCharacter.Profile,
			UserID = currentCharacter.ID
		})
	end

	Ext.RegisterNetListener("LeaderLib_SharedData_SetRegionData", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local invokeRegionChanged = false
			if not SharedData then
				SharedData = {
					RegionData = data
				}
				invokeRegionChanged = true
			else
				local lastRegion = nil
				local lastRegionState = nil
				if SharedData.RegionData then
					lastRegion = SharedData.RegionData.Current
					lastRegionState = SharedData.RegionData.State
				end
				for k,v in pairs(data) do
					SharedData.RegionData[k] = v
				end

				invokeRegionChanged = lastRegion ~= SharedData.RegionData.Current or lastRegionState ~= SharedData.RegionData.State
			end

			if invokeRegionChanged then
				Events.RegionChanged:Invoke(_GetRegionChangedEventData(SharedData.RegionData.Current))
			end
		end
	end)

	local function StoreData(cmd, payload)
		local last = GetClientCharacter().NetID
		local data = Common.JsonParse(payload)
		if data ~= nil then
			local invokeRegionChanged = false
			if not SharedData then
				SharedData = data.Shared
				invokeRegionChanged = true
			else
				local lastRegion = nil
				local lastRegionState = nil
				if SharedData.RegionData then
					lastRegion = SharedData.RegionData.Current
					lastRegionState = SharedData.RegionData.State
				end
				--Update to new values this way, in case mods have set a variable to LeaderLib.SharedData
				for k,v in pairs(data.Shared) do
					SharedData[k] = v
				end

				invokeRegionChanged = lastRegion ~= SharedData.RegionData.Current or lastRegionState ~= SharedData.RegionData.State
			end
			Client:SetClientData(data.ID, data.Profile, data.IsHost, GetClientCharacter(data.Profile, data.NetID))
			Events.ClientDataSynced:Invoke({ModData=SharedData.ModData, Data=SharedData})
			if Client.Character.NetID ~= last then
				ActiveCharacterChanged(Client.Character, last)
			end
			if not Vars.Initialized then
				Vars.Initialized = true
				Events.Initialized:Invoke({Region=SharedData.RegionData.Current})
			end
			if invokeRegionChanged then
				Events.RegionChanged:Invoke(_GetRegionChangedEventData(SharedData.RegionData.Current))
			end
			return true
		else
			error("Error parsing json?", payload)
		end
	end

	Ext.RegisterNetListener("LeaderLib_SharedData_StoreData", function(cmd, payload, ...)
		local b,err = xpcall(StoreData, debug.traceback, cmd, payload)
		if not b then
			Ext.Utils.PrintError(err)
		end
	end)

	local function OnCharacterSelected(ui, call, doubleHandle, skipSync)
		if not doubleHandle or doubleHandle == 0 then
			return
		end
		local handle = Ext.UI.DoubleToHandle(doubleHandle)
		if handle ~= nil then
			---@type EclCharacter
			local character = GameHelpers.GetCharacter(handle)
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
					Ext.Net.PostMessageToServer("LeaderLib_SharedData_CharacterSelected", Common.JsonStringify({Profile = Client.Profile, UUID = uuid, NetID=character.NetID}))
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

	Ext.Events.UIObjectCreated:Subscribe(function(e)
		if e.UI.Type == Data.UIType.trade or e.UI.Type == Data.UIType.trade_c then
			local currentCharacter = GetClientCharacter()
			if currentCharacter ~= nil then
				lastCharacterOutsideTrade = currentCharacter.UUID
			end
		end
	end)

	---@class LeaderLib_CC_OnServerPresetChanged
	---@field NetID NetId
	---@field Profile string

	GameHelpers.Net.Subscribe("LeaderLib_CC_OnServerPresetChanged", function (e, data)
		if data.NetID then
			local character = GameHelpers.GetCharacter(data.NetID, "EclCharacter")
			if character then
				local currentCharacterData = GetClientCharacter(data.Profile, data.NetID)
				Events.ClientCharacterChanged:Invoke({
					Character = character,
					CharacterGUID = currentCharacterData.UUID,
					CharacterData = currentCharacterData,
					IsHost = currentCharacterData.IsHost,
					NetID = data.NetID,
					Profile = currentCharacterData.Profile,
					UserID = currentCharacterData.ID
				})
			end
		end
	end)
else
	Ext.Osiris.RegisterListener("LeaderLib_CC_OnOriginChanged", 3, "after", function (charGUID, lastOrigin, origin)
		if lastOrigin ~= origin then
			local character = GameHelpers.GetCharacter(charGUID, "EsvCharacter")
			if character then
				GameHelpers.Net.PostToUser(charGUID, "LeaderLib_CC_OnServerPresetChanged", {
					NetID = character.NetID,
					Profile = Osi.GetUserProfileID(character.ReservedUserID)
				})
			end
		end
	end)
end