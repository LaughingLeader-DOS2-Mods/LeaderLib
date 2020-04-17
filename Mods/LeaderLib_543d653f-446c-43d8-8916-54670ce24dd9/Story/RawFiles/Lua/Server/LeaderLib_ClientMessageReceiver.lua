
local MessageData = LeaderLib.Classes["MessageData"]

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
		for _,att in pairs(LeaderLib.Data.Attribute) do
			local baseVal = CharacterGetBaseAttribute(uuid, att)
			if baseVal ~= nil then
				playerData.attributes[att] = baseVal
			end
		end
		for _,ability in pairs(LeaderLib.Data.Ability) do
			local baseVal = CharacterGetBaseAbility(uuid, ability)
			if baseVal ~= nil then
				playerData.abilities[ability] = baseVal
			end
		end
	end
	--LeaderLib.Print("[LeaderLib_ClientMessageReceiver.lua:StorePartyValues] Stored party stat data:\n("..LeaderLib.Common.Dump(statChanges)..").")
end

local function SignalPartyValueChanges()
	local players = Osi.DB_IsPlayer:Get(nil)
	for _,entry in pairs(players) do
		local uuid = entry[1]
		local playerData = statChanges[uuid]
		if playerData ~= nil then
			for _,att in pairs(LeaderLib.Data.Attribute) do
				local baseVal = CharacterGetBaseAttribute(uuid, att)
				local lastVal = playerData.attributes[att]
				if baseVal ~= nil and lastVal ~= nil and lastVal ~= baseVal then
					Osi.LeaderLib_CharacterSheet_AttributeChanged(uuid, att, lastVal, baseVal)
					LeaderLib.Print("[LeaderLib_ClientMessageReceiver.lua:SignalPartyValueChanges] ("..uuid..") base attribute ("..att..") changed: "..tostring(lastVal).." => "..tostring(baseVal).." ")
				end
			end
			for _,ability in pairs(LeaderLib.Data.Ability) do
				local baseVal = CharacterGetBaseAbility(uuid, ability)
				local lastVal = playerData.abilities[ability]
				if baseVal ~= nil and lastVal ~= nil and lastVal ~= baseVal then
					Osi.LeaderLib_CharacterSheet_AbilityChanged(uuid, ability, lastVal, baseVal)
					LeaderLib.Print("[LeaderLib_ClientMessageReceiver.lua:SignalPartyValueChanges] ("..uuid..") base ability ("..ability..") changed: "..tostring(lastVal).." => "..tostring(baseVal).." ")
				end
			end
		end
	end
	-- Reset data
	StorePartyValues()
end

function LeaderLib_Ext_CharacterSheet_SignalPartyValueChanges()
	xpcall(SignalPartyValueChanges, function(err)
		Ext.Print("[LeaderLib_ClientMessageReceiver.lua:SignalPartyValueChanges] Error signaling party attribute changes:\n" .. tostring(err))
	end)
end

function LeaderLib_Ext_CharacterSheet_StorePartyValues()
	xpcall(StorePartyValues, function(err)
		Ext.Print("[LeaderLib_ClientMessageReceiver.lua:StorePartyValues] Error storing party sheet values:\n" .. tostring(err))
	end)
end

local function RunChangesDetectionTimer()
	TimerCancel("Timers_LeaderLib_CharacterSheet_SignalPartyValueChanges")
	TimerLaunch("Timers_LeaderLib_CharacterSheet_SignalPartyValueChanges", 1000)
end

local function LeaderLib_OnGlobalMessage(call, data)
	--LeaderLib.Print("[LLENEMY_ServerMessages.lua:LeaderLib_OnGlobalMessage] Received message from client. Data ("..tostring(data)..").")
	if LeaderLib.ID.MESSAGE[data] ~= nil then
		if data == LeaderLib.ID.MESSAGE.STORE_PARTY_VALUES then
			StorePartyValues()
		end
	else
		local messageData = MessageData:CreateFromString(data)
		--LeaderLib.Print("[LLENEMY_ServerMessages.lua:LeaderLib_OnGlobalMessage] Created MessageData ("..LeaderLib.Common.Dump(messageData)..").")
		if messageData ~= nil then
			if messageData.ID == LeaderLib.ID.MESSAGE.ATTRIBUTE_CHANGED or messageData.ID == LeaderLib.ID.MESSAGE.ABILITY_CHANGED then
				RunChangesDetectionTimer()
			end
		end
	end
end

Ext.RegisterNetListener("LeaderLib_GlobalMessage", LeaderLib_OnGlobalMessage)