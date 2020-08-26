---@type MessageData
local MessageData = Classes.MessageData

Ext.RegisterNetListener("LeaderLib_EnableFeature", function(channel, id)
	Features[id] = true
end)

Ext.RegisterNetListener("LeaderLib_DisableFeature", function(channel, id)
	Features[id] = false
end)

Ext.RegisterNetListener("LeaderLib_SyncFeatures", function(call, dataString)
	Features = Ext.JsonParse(dataString)
end)

Ext.RegisterNetListener("LeaderLib_SyncGlobalSettings", function(call, dataString)
	GlobalSettings = Ext.JsonParse(dataString)
end)

Ext.RegisterNetListener("LeaderLib_SyncAllSettings", function(call, dataString)
	local data = Ext.JsonParse(dataString)
	if data.Features ~= nil then Features = data.Features end
	if data.GlobalSettings ~= nil then GlobalSettings = data.GlobalSettings end
	if data.GameSettings ~= nil then GameSettings = data.GameSettings end
	if #Listeners.ModSettingsLoaded > 0 then
		for i,callback in pairs(Listeners.ModSettingsLoaded) do
			local status,err = xpcall(callback, debug.traceback)
			if not status then
				Ext.PrintError("[LeaderLib_SyncAllSettings] Error invoking callback for ModSettingsLoaded:")
				Ext.PrintError(err)
			end
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_SyncScale", function(call, dataStr)
	local data = MessageData:CreateFromString(dataStr)
	if data.Params.UUID ~= nil and data.Params.Scale ~= nil then
		if data.Params.IsItem == true then
			local item = Ext.GetItem(data.Params.UUID)
			if item ~= nil then
				item:SetScale(data.Params.Scale)
			end
		else
			local character = Ext.GetCharacter(data.Params.UUID)
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
							local statusObj = Ext.GetStatus(character.MyGuid, handle) or {}
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
	print(dataStr)
	local data = MessageData:CreateFromString(dataStr)
	if data ~= nil then
		local b,err = xpcall(RefreshStatusTurns, debug.traceback, data)
		if not b then
			print(err)
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_SetClientCharacter", function(call, uuid)
	UI.ClientCharacter = uuid
end)