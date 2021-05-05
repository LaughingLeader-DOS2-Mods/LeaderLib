---@class LeaderLib:table
---@field RegisterListener fun(event:string, callback:InputEventCallback, param:any|nil):void

--- Registers a function to call when a specific Lua LeaderLib event fires.
---@param event string OnPrepareHit|OnHit|CharacterSheetPointChanged|CharacterBasePointsChanged|TimerFinished|FeatureEnabled|FeatureDisabled|Initialized|ModuleResume|SessionLoaded
---@param callbackOrKey function|string If a string, the function is stored in a subtable of the event, such as NamedTimerFinished.TimerName = function
---@param callbackOrNil function|nil If callback is a string, then this is the callback.
function RegisterListener(event, callbackOrKey, callbackOrNil)
	if Listeners[event] ~= nil then
		if type(callbackOrKey) == "string" then
			if callbackOrNil ~= nil then
				if Listeners[event][callbackOrKey] == nil then
					Listeners[event][callbackOrKey] = {}
				end
				table.insert(Listeners[event][callbackOrKey], callbackOrNil)
			else
				Ext.PrintError(string.format("[LeaderLib__Main.lua:RegisterListener] Event (%s) with sub-key (%s) requires a function as the third parameter. Context: %s", event, callbackOrKey, Ext.IsServer() and "SERVER" or "CLIENT"))
			end
		else
			table.insert(Listeners[event], callbackOrKey)
		end
	else
		Ext.PrintError(string.format("[LeaderLib__Main.lua:RegisterListener] Event (%s) is not a valid LeaderLib listener event! Context: %s", event, Ext.IsServer() and "SERVER" or "CLIENT"))
	end
end

--- Unregisters a function for a specific listener event.
---@param event string
---@param callback function
function RemoveListener(event, callback, param)
	if Listeners[event] ~= nil then
		if type(callback) == "string" then
			if Listeners[event][callback] ~= nil then
				local count = 0
				for i,v in pairs(Listeners[event][callback]) do
					if v == param then
						table.remove(Listeners[event][callback], i)
					else
						count = count + 1
					end
				end
				if count == 0 then
					Listeners[event][callback] = nil
				end
			end
		else
			for i,v in pairs(Listeners[event]) do
				if v == callback then
					table.remove(Listeners[event], i)
				end
			end
		end
	end
end

function InvokeListenerCallbacks(callbacks, ...)
	local length = callbacks and #callbacks or 0
	if length > 0 then
		for i=1,length do
			local callback = callbacks[i]
			local b,err = xpcall(callback, debug.traceback, ...)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
end

--- Registers a function to call when a specific Lua LeaderLib event fires for specific mods.
--- Events: Registered|Updated
---@param event string
---@param uuid string
---@param callback function
function RegisterModListener(event, uuid, callback)
	if ModListeners[event] ~= nil then
		ModListeners[event][uuid] = callback
	else
		Ext.PrintError("[LeaderLib__Main.lua:RegisterListener] Event ("..tostring(event)..") is not a valid LeaderLib listener event!")
	end
end

Ext.RegisterListener("SessionLoading", function()
	for i,status in pairs(Ext.GetStatEntries("StatusData")) do
		local statusType = Ext.StatGetAttribute(status, "StatusType")
		if statusType ~= nil and statusType ~= "" then
			local statusTypeTable = StatusTypes[statusType]
			if statusTypeTable ~= nil then
				statusTypeTable[status] = true
				--PrintDebug("[LeaderLib__Main.lua:LeaderLib_Shared_SessionLoading] Added Status ("..status..") to StatusType table ("..statusType..").")
			end
		end
	end

	if Ext.IsServer() then
		if PersistentVars["OriginalSkillTiers"] ~= nil then
			Data.OriginalSkillTiers = PersistentVars["OriginalSkillTiers"]
		end
	end
end)

Ext.RegisterListener("SessionLoaded", function()
	local count = #TranslatedStringEntries
	if TranslatedStringEntries ~= nil and count > 0 then
		for i,v in pairs(TranslatedStringEntries) do
			if v == nil then
				table.remove(TranslatedStringEntries, i)
			else
				local status,err = xpcall(function()
					v:Update()
				end, debug.traceback)
				if not status then
					Ext.PrintError("[LeaderLib:SessionLoaded] Error updating TranslatedString entry:")
					Ext.PrintError(err)
				end
			end
		end
		PrintDebug(string.format("[LeaderLib_Shared_SessionLoaded] Updated %s TranslatedString entries.", count))
	end
end)

---@param uuid string
---@return ModSettings
function CreateModSettings(uuid)
	return SettingsManager.GetMod(uuid, true)
end