local _EXTVERSION = Ext.Utils.Version()

---@type MessageData
local MessageData = Classes.MessageData

Ext.RegisterNetListener("LeaderLib_SyncFeatures", function(call, dataString)
	local data = Common.JsonParse(dataString)
	if data ~= nil then
		for k,b in pairs(data) do
			Features[k] = b
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_SyncScale", function(cmd, payload)
	local data = Common.JsonParse(payload)
	if data.Scale and data.NetID then
		local obj = nil
		if data.IsItem then
			obj = GameHelpers.GetItem(data.NetID, "EclItem")
		else
			obj = GameHelpers.GetCharacter(data.NetID, "EclCharacter")
		end
		if obj and obj.Scale then
			GameHelpers.SetScale(obj, data.Scale)
		end
	end
end)

---@class StatusMovieClip
---@field setTurns fun(turns:string) Set the turns text.
---@field setCoolDown fun(turns:number) Set the turn display border.
---@field tick fun()

---@class StatusMovieClipTable
---@field Status EsvStatus
---@field MC StatusMovieClip

---@diagnostic disable undefined-field

---@param character EclCharacter The player.
---@param matchStatus? string|table<string,boolean> An optional status to look for.
---@return StatusMovieClipTable[]
local function GetPlayerStatusMovieClips(character, matchStatus)
	local statusMovieclips = {}
	if Vars.ControllerEnabled then
		--TODO Parse playerInfo_c
		return statusMovieclips
	end
	local ui = Ext.UI.GetByType(Data.UIType.playerInfo)
	if ui ~= nil then
		local root = ui:GetRoot()
		if root ~= nil then
			local playerHandle = Ext.UI.HandleToDouble(character.Handle)
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
						local handle = Ext.UI.DoubleToHandle(status_mc.id)
						if handle ~= nil then
							local statusObj = Ext.Entity.GetStatus(character.NetID, handle) or {}
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

---@diagnostic enable

local function RefreshStatusTurns(data)
	if data.UUID ~= nil and data.Status ~= nil then
		---@type EclCharacter
		local character = GameHelpers.GetCharacter(data.UUID)
		if character ~= nil then
			local statusData = GetPlayerStatusMovieClips(character, data.Status)
			for i,v in pairs(statusData) do
				---@type EsvStatus
				local status = v.Status
				local mc = v.MC
				local turns = math.ceil(status.CurrentLifeTime / 6.0)
				local cooldown = status.LifeTime / status.CurrentLifeTime
				if data.Turns ~= nil then
					turns = data.Turns
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

Ext.RegisterNetListener("LeaderLib_UI_RefreshStatusTurns", function(call, payload)
	local data = Common.JsonParse(payload)
	if data then
		local b,err = xpcall(RefreshStatusTurns, debug.traceback, data)
		if not b then
			Ext.Utils.PrintError(err)
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_SetHelmetOption", function(call, dataStr)
	local data = MessageData:CreateFromString(dataStr)
	if data.Params.UUID ~= nil and data.Params.Enabled ~= nil then
		local ui = Ext.UI.GetByPath("Public/Game/GUI/characterSheet.swf")
		if ui ~= nil then
			local state = data.Params.Enabled and 1 or 0
			ui:ExternalInterfaceCall("setHelmetOption", state)
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_SetArmorOption", function(call, dataStr)
	local data = MessageData:CreateFromString(dataStr)
	if data.Params.UUID ~= nil and data.Params.State ~= nil then
		local ui = Ext.UI.GetByPath("Public/Game/GUI/characterCreation.swf")
		if ui ~= nil then
			ui:ExternalInterfaceCall("setArmourState", data.Params.State)
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_UI_RefreshAll", function(cmd, uuid)
	local host = GameHelpers.GetCharacter(uuid)
	Ext.UI.SetDirty(host, 0xffffffffffff)
end)

Ext.RegisterNetListener("LeaderLib_Client_SyncDebugVars", function(cmd, payload)
	local data = Common.JsonParse(payload)
	if data then
		if data.PrintSettings then
			for k,v in pairs(data.PrintSettings) do
				Vars.Print[k] = v
			end
		end
		if data.CommandSettings then
			for k,v in pairs(data.CommandSettings) do
				Vars.Commands[k] = v
			end
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_Client_InvokeListeners", function(cmd, payload)
	local event, listeners, args = nil,nil,nil

	
	if string.find(payload, "{") then
		local data = Common.JsonParse(payload) or {}
		event = data.Event
		listeners = Listeners[data.Event]
		args = data.Args
	else
		listeners = Listeners[payload]
		event = payload
	end

	if listeners then
		if event == "LuaReset" then
			LoadGlobalSettings()
			GameSettingsManager.Load()
		elseif event == "BeforeLuaReset" then
			Vars.Resetting = true
		end
		if args then
			InvokeListenerCallbacks(listeners, table.unpack(args))
		else
			InvokeListenerCallbacks(listeners)
		end
	else
		fprint(LOGLEVEL.ERROR, "[LeaderLib:LeaderLib_Client_InvokeListeners] No listeners for event (%s)", payload)
	end
end)

local lastActiveSkill = -1

local function OnShowActiveSkill(ui, method, id)
	if id == -1 and lastActiveSkill ~= id then
		local char = Client:GetCharacter()
		if char then
			Ext.Net.PostMessageToServer("LeaderLib_OnActiveSkillCleared", tostring(char.NetID))
		end
	end
	lastActiveSkill = id
end

Ext.RegisterUITypeInvokeListener(Data.UIType.hotBar, "showActiveSkill", OnShowActiveSkill)
Ext.RegisterUITypeInvokeListener(Data.UIType.bottomBar_c, "showActiveSkill", OnShowActiveSkill)

Ext.RegisterNetListener("LeaderLib_Debug_MusicTest", function(cmd, payload)
	local data = Common.JsonParse(payload)
	local mType = data.Type or "Explo"
	local theme = data.Theme or "Fort_Joy"
	--Ext.Audio.SetState("Music_Type", "None")
	local success1 = Ext.Audio.SetState("Music_Type", mType)
	local success2 = Ext.Audio.SetState("Music_Theme", theme)
	fprint(LOGLEVEL.TRACE, "Ext.Audio.SetState(\"Music_Type\", \"%s\") = %s", mType, success1)
	fprint(LOGLEVEL.TRACE, "Ext.Audio.SetState(\"Music_Theme\", \"%s\") = %s", theme, success2)
end)