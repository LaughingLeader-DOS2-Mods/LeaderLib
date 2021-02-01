--- Registers a function to call when a specific Lua LeaderLib event fires.
---@param event string OnPrepareHit|OnHit|CharacterSheetPointChanged|CharacterBasePointsChanged|TimerFinished|FeatureEnabled|FeatureDisabled|Initialized|ModuleResume|SessionLoaded
---@param callback function
function RegisterListener(event, callback, param)
	if Listeners[event] ~= nil then
		if type(callback) == "string" then
			if Listeners[event][callback] == nil then
				Listeners[event][callback] = {}
			end
			table.insert(Listeners[event][callback], param)
		else
			table.insert(Listeners[event], callback)
		end
	else
		Ext.PrintError("[LeaderLib__Main.lua:RegisterListener] Event ("..tostring(event)..") is not a valid LeaderLib listener event!")
	end
end

function InvokeListenerCallbacks(callbacks, ...)
	local length = callbacks and #callbacks or 0
	if length > 0 then
		for i=0,length do
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

TotalSkillListeners = 0

---@alias LeaderLibSkillListenerCallback fun(skill:string, char:string, state:SKILL_STATE, data:SkillEventData|HitData)

--- Registers a function to call when a specific skill's events fire.
---@param skill string|string[]
---@param callback LeaderLibSkillListenerCallback
function RegisterSkillListener(skill, callback)
	local t = type(skill)
	if t == "string" then
		if SkillListeners[skill] == nil then
			SkillListeners[skill] = {}
		end
		table.insert(SkillListeners[skill], callback)
		TotalSkillListeners = TotalSkillListeners + 1

		if Vars.Initialized then
			Osi.LeaderLib_ToggleScripts_EnableScript("LeaderLib_LuaSkillListeners_Enabled", "LeaderLib")
			Osi.LeaderLib_ToggleScripts_EnableScript("LeaderLib_LuaEventListeners_Enabled", "LeaderLib")
		else
			Vars.PostLoadEnableLuaListeners = true
		end
	elseif t == "table" then
		for i,v in pairs(skill) do
			RegisterSkillListener(v, callback)
		end
	end
end

--- Removed a function from the listeners table.
---@param skill string
---@param callback function
function RemoveSkillListener(skill, callback)
	if SkillListeners[skill] ~= nil then
		for i,v in pairs(SkillListeners[skill]) do
			if v == callback then
				table.remove(SkillListeners[skill], i)
				break
			end
		end
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