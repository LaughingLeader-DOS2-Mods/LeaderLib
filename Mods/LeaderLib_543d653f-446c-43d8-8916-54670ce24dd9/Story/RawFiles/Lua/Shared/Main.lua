---@class LeaderLib:table
---@field RegisterListener fun(event:LeaderLibGlobalListenerEvent|LeaderLibServerListenerEvent|LeaderLibClientListenerEvent|string[], callbackOrKey:function|string, callbackOrNil:function|nil):void

--- Registers a function to call when a specific Lua LeaderLib event fires.
---@param event LeaderLibGlobalListenerEvent|LeaderLibServerListenerEvent|LeaderLibClientListenerEvent|string[] Listener table name.
---@param callbackOrKey function|string If a string, the function is stored in a subtable of the event, such as NamedTimerFinished.TimerName = function
---@param callbackOrNil function|nil If callback is a string, then this is the callback.
function RegisterListener(event, callbackOrKey, callbackOrNil)
	local listenerTable = nil
	if type(event) == "table" then
		if Common.TableHasValue(Listeners, event) then
			listenerTable = event
		else
			for i,v in pairs(event) do
				if Listeners[v] then
					RegisterListener(v, callbackOrKey, callbackOrNil)
				end
			end
			return
		end
	else
		listenerTable = Listeners[event]
	end
	if listenerTable then
		local keyType = type(callbackOrKey)
		if keyType == "string" or keyType == "number" then
			if callbackOrNil then
				if listenerTable[callbackOrKey] == nil then
					listenerTable[callbackOrKey] = {}
				end
				table.insert(listenerTable[callbackOrKey], callbackOrNil)
			else
				Ext.PrintError(string.format("[LeaderLib__Main.lua:RegisterListener] Event (%s) with sub-key (%s) requires a function as the third parameter. Context: %s", event, callbackOrKey, Ext.IsServer() and "SERVER" or "CLIENT"))
			end
		else
			if listenerTable.All ~= nil then
				table.insert(listenerTable.All, callbackOrKey)
			else
				table.insert(listenerTable, callbackOrKey)
			end
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
	if Ext.IsServer() then
		if PersistentVars["OriginalSkillTiers"] ~= nil then
			Data.OriginalSkillTiers = PersistentVars["OriginalSkillTiers"]
		end
	end
end)

Ext.RegisterListener("SessionLoaded", function()
	Vars.LeaderDebugMode = Ext.LoadFile("LeaderDebug") ~= nil
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
	for _,stat in pairs(Ext.GetStatEntries("Object")) do
		Data.ObjectStats[stat] = true
	end
	for _,stat in pairs(Ext.GetStatEntries("Potion")) do
		if not StringHelpers.IsNullOrWhitespace(Ext.StatGetAttribute(stat, "RootTemplate")) then
			Data.ObjectStats[stat] = true
		end
	end
end)

---@param uuid string
---@return ModSettings
function CreateModSettings(uuid)
	return SettingsManager.GetMod(uuid, true)
end