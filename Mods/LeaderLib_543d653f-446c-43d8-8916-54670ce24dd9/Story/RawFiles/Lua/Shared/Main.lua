--- Registers a function to call when a specific Lua LeaderLib event fires.
---@param event string OnPrepareHit|OnHit|CharacterSheetPointChanged|CharacterBasePointsChanged|TimerFinished|FeatureEnabled|FeatureDisabled|Initialized|ModuleResume|SessionLoaded
---@param callback function
function RegisterListener(event, callback)
	if Listeners[event] ~= nil then
		table.insert(Listeners[event], callback)
	else
		error("[LeaderLib__Main.lua:RegisterListener] Event ("..tostring(event)..") is not a valid LeaderLib listener event!")
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
		error("[LeaderLib__Main.lua:RegisterListener] Event ("..tostring(event)..") is not a valid LeaderLib listener event!")
	end
end

--- Registers a function to call when a specific skill's events fire.
---@param skill string
---@param callback function
function RegisterSkillListener(skill, callback)
	if SkillListeners[skill] == nil then
		SkillListeners[skill] = {}
	end
	table.insert(SkillListeners[skill], callback)

	if Vars.Initialized then
		if GlobalGetFlag("LeaderLib_LuaSkillListeners_Enabled") == 0 then
			Osi.LeaderLib_ActivateGoal("LeaderLib_19_TS_LuaSkillListeners")
			Osi.LeaderLib_ActivateGoal("LeaderLib_19_TS_LuaEventListeners")
		end
	else
		Vars.PostLoadEnableLuaListeners = true
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

StatusTypes.CHARMED = { CHARMED = true }
--StatusTypes.POLYMORPHED = { POLYMORPHED = true }

local function LeaderLib_Shared_SessionLoading()
	for i,status in pairs(Ext.GetStatEntries("StatusData")) do
		local statusType = Ext.StatGetAttribute(status, "StatusType")
		if statusType ~= nil and statusType ~= "" then
			statusType = string.upper(statusType)
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
end

Ext.RegisterListener("SessionLoading", LeaderLib_Shared_SessionLoading)

Ext.RegisterListener("SessionLoaded", function()
	PrintDebug("[LeaderLib] Updating translated strings", #TranslatedStringEntries)
	--print(Ext.JsonStringify(TranslatedStringEntries))
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
					print("[LeaderLib:SessionLoaded] Error updating TranslatedString entry:")
					print(err)
				end
			end
		end
		PrintDebug(string.format("[LeaderLib_Shared_SessionLoaded] Updated %s TranslatedString entries.", count))
	end
end)