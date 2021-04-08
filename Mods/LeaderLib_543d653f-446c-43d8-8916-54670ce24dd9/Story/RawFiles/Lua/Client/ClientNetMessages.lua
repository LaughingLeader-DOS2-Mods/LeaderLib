---@type MessageData
local MessageData = Classes.MessageData

Ext.RegisterNetListener("LeaderLib_EnableFeature", function(channel, id)
	Features[id] = true
end)

Ext.RegisterNetListener("LeaderLib_DisableFeature", function(channel, id)
	Features[id] = false
end)

Ext.RegisterNetListener("LeaderLib_SyncFeatures", function(call, dataString)
	if Features == nil then
		Features = {}
	end
	local data = Ext.JsonParse(dataString)
	if data ~= nil then
		for k,b in pairs(data) do
			Features[k] = b
		end
	end
end)

local function SetGlobalSettingsMetatables()
	for _,v in pairs(GlobalSettings.Mods) do
		setmetatable(v, Classes.ModSettingsClasses.ModSettings)
		Classes.ModSettingsClasses.SettingsData.SetMetatables(v.Global)
		setmetatable(v.Global, Classes.ModSettingsClasses.SettingsData)
		for _,p in pairs(v.Profiles) do
			Classes.ModSettingsClasses.SettingsData.SetMetatables(p.Settings)
			setmetatable(p, Classes.ModSettingsClasses.ProfileSettings)
			setmetatable(p.Settings, Classes.ModSettingsClasses.SettingsData)
		end
	end
end

---@param settings GlobalSettings
local function SyncGlobalSettings(settings)
	if GlobalSettings ~= nil then
		local length = #Listeners.ModSettingsSynced

		GlobalSettings.Version = settings.Version
		for k,v in pairs(settings.Mods) do
			local target = v
			if GlobalSettings.Mods[k] == nil then
				GlobalSettings.Mods[k] = v
			else
				local existing = GlobalSettings.Mods[k]
				if existing.Global == nil then
					existing.Global = v.Global
				else
					existing.Global:CopySettings(v.Global)
				end
				if existing.Profiles == nil then
					existing.Profiles = v.Profiles
				else
					for k2,v2 in pairs(v.Profiles) do
						local existingProfile = existing.Profiles[k2]
						if existingProfile ~= nil then
							existingProfile.Settings:CopySettings(v2.Settings)
						else
							existing.Profiles[k2] = v2
						end
					end
				end
				existing.Version = v.Version
				target = existing
			end
			if length > 0 then
				for i=1,length do
					local callback = Listeners.ModSettingsSynced[i]
					local status,err = xpcall(callback, debug.traceback, k, target)
					if not status then
						Ext.PrintError("[LeaderLib:HitListeners.lua] Error calling function for 'ModSettingsSynced':\n", err)
					end
				end
			end
		end
		PrintDebug("[LeaderLib:CLIENT] Updated GlobalSettings.")
	else
		Ext.PrintError("[LeaderLib:CLIENT] GlobalSettings is nil.")
		GlobalSettings = settings
	end
	SetGlobalSettingsMetatables()
end

Ext.RegisterNetListener("LeaderLib_SyncGlobalSettings", function(call, dataString)
	local settings = Ext.JsonParse(dataString)
	if settings ~= nil then
		SyncGlobalSettings(settings)
	end
end)

Ext.RegisterNetListener("LeaderLib_SyncAllSettings", function(call, dataString)
	local data = Ext.JsonParse(dataString)
	if data.Features ~= nil then Features = data.Features end
	if data.GlobalSettings ~= nil then 
		SyncGlobalSettings(data.GlobalSettings)
	end
	if data.GameSettings ~= nil then
		GameSettings = data.GameSettings
		setmetatable(GameSettings, Classes.LeaderLibGameSettings)
		--SyncStatOverrides(GameSettings)
	end
	InvokeListenerCallbacks(Listeners.ModSettingsLoaded)
end)

Ext.RegisterNetListener("LeaderLib_SyncScale", function(call, dataStr)
	local data = MessageData:CreateFromString(dataStr)
	if data.Params.UUID ~= nil and data.Params.Scale ~= nil then
		if data.Params.IsItem == true then
			local item = Ext.GetItem(data.Params.UUID)
			if item == nil and data.Params.Handle ~= nil then
				item = Ext.GetItem(data.Params.Handle)
			end
			if item ~= nil then
				item:SetScale(data.Params.Scale)
			end
		else
			local character = Ext.GetCharacter(data.Params.UUID)
			if character == nil and data.Params.Handle ~= nil then
				character = Ext.GetCharacter(data.Params.Handle)
			end
			if character ~= nil then
				character:SetScale(data.Params.Scale)
			end
		end
	end
end)

---@class StatusMovieClip
---@field setTurns fun(turns:string) Set the turns text.
---@field setCooldown fun(turns:number) Set the turn display border.

---@class StatusMovieClipTable
---@field Status EsvStatus
---@field MC StatusMovieClip

---@param character EclCharacter The player.
---@param matchStatus string|table<string,bool>|nil An optional status to look for.
---@return StatusMovieClipTable[]
local function GetPlayerStatusMovieClips(character, matchStatus)
	local statusMovieclips = {}
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/playerInfo.swf")
	if ui ~= nil then
		local root = ui:GetRoot()
		if root ~= nil then
			local playerHandle = Ext.HandleToDouble(character.Handle)
			local player_mc = nil --root.getPlayerOrSummonByHandle(playerHandle)
			for i=0,#root.player_array,1 do
				local mc = root.player_array[i]
				if mc ~= nil then
					if mc.characterHandle == playerHandle then
						player_mc = mc
						break
					end
				end
			end
			if player_mc ~= nil then
				for i=0,#player_mc.status_array,1 do
					local status_mc = player_mc.status_array[i]
					if status_mc ~= nil then
						local handle = Ext.DoubleToHandle(status_mc.id)
						if handle ~= nil then
							local statusObj = Ext.GetStatus(character.NetID, handle) or {}
							--print(string.format("[%i] id(%s) name(%s) iconId(%s) tooltip(%s) handle(%s) StatusId(%s)", i, status_mc.id, status_mc.name, status_mc.iconId, status_mc.tooltip, handle, statusObj.StatusId))
							if statusObj ~= nil then
								if matchStatus == nil then
									table.insert(statusMovieclips, {Status=statusObj, MC = status_mc})
								else
									if type(matchStatus) == "table" then
										if matchStatus[statusObj.StatusId] == true then
											table.insert(statusMovieclips, {Status=statusObj, MC = status_mc})
										end
									elseif statusObj.StatusId == matchStatus then
										table.insert(statusMovieclips, {Status=statusObj, MC = status_mc})
									end
								end
							end
						end
					end
				end
			else
				error(string.format("[LeaderLib:RefreshStatusTurns] Failed to find player MC for %s", character.MyGuid), 1)
			end
		end
	end
	return statusMovieclips
end

local function RefreshStatusTurns(data)
	if data.Params.UUID ~= nil and data.Params.Status ~= nil then
		---@type EclCharacter
		local character = Ext.GetCharacter(data.Params.UUID)
		if character ~= nil then
			local statusData = GetPlayerStatusMovieClips(character, data.Params.Status)
			for i,v in pairs(statusData) do
				---@type EsvStatus
				local status = v.Status
				local mc = v.MC
				local turns = math.ceil(status.CurrentLifeTime / 6.0)
				local cooldown = status.LifeTime / status.CurrentLifeTime
				if data.Params.Turns ~= nil then
					turns = data.Params.Turns
					local nextLifetime = turns * 6.0
					if nextLifetime >= status.LifeTime then
						cooldown = 1.0
					else
						cooldown = math.min(1.0, status.LifeTime / nextLifetime)
					end
				end
				mc.setTurns(tostring(turns))
				mc.setCoolDown(1.0)
				mc.tick()
			end
		end
	end
end

Ext.RegisterNetListener("LeaderLib_UI_RefreshStatusTurns", function(call, dataStr)
	local data = MessageData:CreateFromString(dataStr)
	if data ~= nil then
		local b,err = xpcall(RefreshStatusTurns, debug.traceback, data)
		if not b then
			Ext.PrintError(err)
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_SetHelmetOption", function(call, dataStr)
	local data = MessageData:CreateFromString(dataStr)
	if data.Params.UUID ~= nil and data.Params.Enabled ~= nil then
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
		if ui ~= nil then
			local state = data.Params.Enabled and 1 or 0
			ui:ExternalInterfaceCall("setHelmetOption", state)
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_SetArmorOption", function(call, dataStr)
	local data = MessageData:CreateFromString(dataStr)
	if data.Params.UUID ~= nil and data.Params.State ~= nil then
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterCreation.swf")
		if ui ~= nil then
			ui:ExternalInterfaceCall("setArmourState", data.Params.State)
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_UI_RefreshAll", function(cmd, uuid)
	local host = Ext.GetCharacter(uuid)
	Ext.UISetDirty(host, 0xffffffffffff)
end)

Ext.RegisterNetListener("LeaderLib_Client_InvokeLuaResetListeners", function(cmd, region)
	InvokeListenerCallbacks(Listeners.LuaReset, region)
	GameSettings:Apply()
end)