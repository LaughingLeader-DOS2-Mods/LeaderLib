--- Registers a function to call when a specific Lua LeaderLib event fires.
---@param event string
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
end

Ext.RegisterListener("SessionLoading", LeaderLib_Shared_SessionLoading)

local function LeaderLib_Shared_SessionLoaded()
	local count = #TranslatedStringEntries
	if TranslatedStringEntries ~= nil and count > 0 then
		for i,v in pairs(TranslatedStringEntries) do
			if v == nil then
				table.remove(TranslatedStringEntries, i)
			else
				pcall(function()
					v:Update()
				end)
			end
		end
		PrintDebug(string.format("[LeaderLib_Shared_SessionLoaded] Updated %s TranslatedString entries.", count))
	end
end
Ext.RegisterListener("SessionLoaded", LeaderLib_Shared_SessionLoaded)