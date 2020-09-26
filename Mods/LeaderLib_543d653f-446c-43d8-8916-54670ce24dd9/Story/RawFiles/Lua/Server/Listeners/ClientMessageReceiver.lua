
local MessageData = Classes["MessageData"]

local statChanges = {}

local function StorePartyValues()
	local players = Osi.DB_IsPlayer:Get(nil)
	for _,entry in pairs(players) do
		local uuid = entry[1]
		local playerData = {
			attributes = {},
			abilities = {}
		}
		statChanges[uuid] = playerData
		for _,att in Data.Attribute:Get() do
			local baseVal = CharacterGetBaseAttribute(uuid, att)
			if baseVal ~= nil then
				playerData.attributes[att] = baseVal
			end
		end
		for _,ability in Data.Ability:Get() do
			local baseVal = CharacterGetBaseAbility(uuid, ability)
			if baseVal ~= nil then
				playerData.abilities[ability] = baseVal
			end
		end
	end
	--PrintDebug("[LeaderLib_ClientMessageReceiver.lua:StorePartyValues] Stored party stat data:\n("..Common.Dump(statChanges)..").")
end

local function FireListenerEvents(uuid, stat, lastVal, nextVal)
	local length = #Listeners.CharacterBasePointsChanged
	if length > 0 then
		for i=1,length do
			local callback = Listeners.CharacterBasePointsChanged[i]
			local status,err = xpcall(callback, debug.traceback, uuid, stat, lastVal, nextVal)
			if not status then
				Ext.PrintError("Error calling function for 'CharacterBasePointsChanged':\n", err)
			end
		end
	end
end

local function SignalPartyValueChanges()
	local players = Osi.DB_IsPlayer:Get(nil)
	for _,entry in pairs(players) do
		local uuid = entry[1]
		local playerData = statChanges[uuid]
		if playerData ~= nil then
			for _,stat in Data.Attribute:Get() do
				local baseVal = CharacterGetBaseAttribute(uuid, stat)
				local lastVal = playerData.attributes[stat]
				if baseVal ~= nil and lastVal ~= nil and lastVal ~= baseVal then
					PrintDebug("[LeaderLib_ClientMessageReceiver.lua:SignalPartyValueChanges] ("..uuid..") base attribute ("..stat..") changed: "..tostring(lastVal).." => "..tostring(baseVal).." ")
					Osi.LeaderLib_CharacterSheet_AttributeChanged(uuid, stat, lastVal, baseVal)
					FireListenerEvents(uuid, stat, lastVal, baseVal)
				end
			end
			for _,stat in Data.Ability:Get() do
				local baseVal = CharacterGetBaseAbility(uuid, stat)
				local lastVal = playerData.abilities[stat]
				if baseVal ~= nil and lastVal ~= nil and lastVal ~= baseVal then
					PrintDebug("[LeaderLib_ClientMessageReceiver.lua:SignalPartyValueChanges] ("..uuid..") base ability ("..stat..") changed: "..tostring(lastVal).." => "..tostring(baseVal).." ")
					Osi.LeaderLib_CharacterSheet_AbilityChanged(uuid, stat, lastVal, baseVal)
					FireListenerEvents(uuid, stat, lastVal, baseVal)
				end
			end
		end
	end
	-- Reset data
	StorePartyValues()
end

function CharacterSheet_SignalPartyValueChanges()
	local status,err = xpcall(SignalPartyValueChanges, debug.traceback)
	if not status then
		Ext.PrintError("Error signaling party attribute changes:\n", err)
	end
end

function CharacterSheet_StorePartyValues()
	local status,err = xpcall(StorePartyValues, debug.traceback)
	if not status then
		Ext.PrintError("Error storing party sheet values:\n", err)
	end
end

local function RunChangesDetectionTimer()
	TimerCancel("Timers_LeaderLib_CharacterSheet_SignalPartyValueChanges")
	TimerLaunch("Timers_LeaderLib_CharacterSheet_SignalPartyValueChanges", 1000)
end

local function LeaderLib_OnGlobalMessage(call, data)
	--PrintDebug("[LLENEMY_ServerMessages.lua:LeaderLib_OnGlobalMessage] Received message from client. Data ("..tostring(data)..").")
	if ID.MESSAGE[data] ~= nil then
		if data == ID.MESSAGE.STORE_PARTY_VALUES then
			StorePartyValues()
		end
	else
		local messageData = MessageData:CreateFromString(data)
		--PrintDebug("[LLENEMY_ServerMessages.lua:LeaderLib_OnGlobalMessage] Created MessageData ("..Common.Dump(messageData)..").")
		if messageData ~= nil then
			if messageData.ID == ID.MESSAGE.ATTRIBUTE_CHANGED or messageData.ID == ID.MESSAGE.ABILITY_CHANGED then
				RunChangesDetectionTimer()
				local stat = messageData.Params[1]
				if stat ~= nil and stat ~= "" then
					Osi.LeaderLib_CharacterSheet_PointsChanged(stat)
				end
			end
		end
	end
end

Ext.RegisterNetListener("LeaderLib_GlobalMessage", LeaderLib_OnGlobalMessage)

Ext.RegisterNetListener("LeaderLib_UI_StartControllerTooltipTimer", function(cmd, payload)
	local data = MessageData:CreateFromString(payload)
	if data ~= nil and data.Params.Client ~= nil then
		StartOneshotTimer(string.format("Timers_LL_TooltipPositioned_%s%s", data.Params.Client, data.Params.UIType), 2, function()
			Ext.PostMessageToClient(data.Params.Client, "LeaderLib_UI_OnControllerTooltipPositioned", tostring(data.Params.UIType))
		end)
	end
end)

function SyncClientData(uuid, id)
	if uuid == nil and id ~= nil then
		uuid = StringHelpers.GetUUID(GetCurrentCharacter(id))
	elseif uuid ~= nil and id == nil then
		id = CharacterGetReservedUserID(uuid)
	end
	local host = CharacterGetHostCharacter()
	local isHost = CharacterGetReservedUserID(host) == id
	local profile = GetUserProfileID(id)
	local data = {UUID = uuid, ID = id, IsHost = isHost, Profile=profile}
	Ext.PostMessageToUser(id, "LeaderLib_SetClientCharacter", Ext.JsonStringify(data))
end