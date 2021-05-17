if GameHelpers.UI == nil then
	GameHelpers.UI = {}
end

local MessageData = Classes.MessageData

function SetSlotEnabled(client, slot, enabled)
	if CharacterGetReservedUserID(client) ~= nil then
		Ext.PostMessageToClient(client, "LeaderLib_Hotbar_SetSlotEnabled", MessageData:CreateFromTable("SetSlotEnabled", {
			Slot = slot,
			Enabled = enabled,
			UUID = client
		}):ToString())
	end
end

GameHelpers.UI.SetSlotEnabled = SetSlotEnabled

---@param client string
---@param skill string
---@param enabled string
function SetSkillEnabled(client, skill, enabled)
	if CharacterIsPlayer(client) == 1 and CharacterGetReservedUserID(client) ~= nil then
		if type(enabled) == "string" then
			enabled = string.lower(enabled) == "true" or enabled == "1"
		end
		local slots = GetSkillSlots(client, skill)
		if #slots > 0 then
			Ext.PostMessageToClient(client, "LeaderLib_Hotbar_SetSlotEnabled", MessageData:CreateFromTable("SetSlotEnabled", {
				Slots = slots,
				Enabled = enabled,
				UUID = client
			}):ToString())
		end
	end
end

GameHelpers.UI.SetSkillEnabled = SetSkillEnabled

---Refresh the whole active skillbar. Useful for refreshing if a skill is clickable from tag requirements changing.
---@param client string|integer|EsvCharacter Client character UUID, user ID, or EsvCharacter.
function RefreshSkillBar(client)
	local t = type(client)
	if t == "string" then
		if CharacterIsPlayer(client) == 1 and Ext.GetGameState() == "Running" then
			local id = CharacterGetReservedUserID(client)
			if id ~= nil then
				--Ext.PostMessageToClient(client, "LeaderLib_Hotbar_Refresh", "")
				Ext.PostMessageToUser(id, "LeaderLib_Hotbar_Refresh", "")
			end
		end
	elseif t == "number" then
		Ext.PostMessageToUser(client, "LeaderLib_Hotbar_Refresh", "")
	elseif  t == "userdata" and client.NetID then
		Ext.PostMessageToUser(client.NetID, "LeaderLib_Hotbar_Refresh", "")
	end
end

GameHelpers.UI.RefreshSkillBar = RefreshSkillBar

---@param client string Client character UUID.
---@param skill string
function RefreshSkillBarSkillCooldown(client, skill)
	if CharacterIsPlayer(client) == 1 and CharacterGetReservedUserID(client) ~= nil then
		local data = MessageData:CreateFromTable("SkillbarCooldowns", {
			UUID = GetUUID(client),
			Slots = {}
		})
		local slots = GetSkillSlots(client, skill)
		if #slots > 0 then
			local cd = Ext.GetCharacter(client):GetSkillInfo(skill).ActiveCooldown
			for i,v in pairs(slots) do
				data.Params.Slots[i] = cd
			end
			Ext.PostMessageToClient(client, "LeaderLib_Hotbar_RefreshCooldowns", data:ToString())
		end
	end
end

GameHelpers.UI.RefreshSkillBarSkillCooldown = RefreshSkillBarSkillCooldown

---Refresh the skillbar's cooldowns.
---@param client string Client character UUID.
function RefreshSkillBarCooldowns(client)
	if CharacterIsPlayer(client) == 1 and CharacterGetReservedUserID(client) ~= nil then
		local character = Ext.GetCharacter(client)
		local slots = {}
		for i=0,144,1 do
			local skill = NRD_SkillBarGetSkill(client, i)
			if skill ~= nil then
				local info = character:GetSkillInfo(skill)
				if info ~= nil and info.ActiveCooldown > 0 then
					slots[i] = info.ActiveCooldown / 6.0
				end
			end
		end
		Ext.PostMessageToClient(client, "LeaderLib_Hotbar_RefreshCooldowns", Ext.JsonStringify(slots))
	end
end

GameHelpers.UI.RefreshSkillBarCooldowns = RefreshSkillBarCooldowns

---@param text string
---@param filter integer
---@param specificCharacters string|string[]|nil
function GameHelpers.UI.CombatLog(text, filter, specificCharacters)
	local data = MessageData:CreateFromTable("CombatLogData", {
		Filter = filter or 0,
		Text = GameHelpers.Tooltip.ReplacePlaceholders(text)
	}):ToString()
	if specificCharacters == nil then
		Ext.BroadcastMessage("LeaderLib_AddTextToCombatLog", data, nil)
	else
		local charType = type(specificCharacters)
		if charType == "string" then
			Ext.PostMessageToClient(specificCharacters, "LeaderLib_AddTextToCombatLog", data)
		elseif charType == "table" then
			for i,v in pairs(specificCharacters) do
				Ext.PostMessageToClient(v, "LeaderLib_AddTextToCombatLog", data)
			end
		end
	end
end

---@param text string
---@param title string|nil
---@param specificCharacters string|string[]|nil
---@param boxType integer|nil
---@param title string|nil
function GameHelpers.UI.ShowMessageBox(text, specificCharacters, boxType, title)
	local data = MessageData:CreateFromTable("MessageBoxData", {
		Type = boxType or 1,
		Text = text,
		Title = title
	}):ToString()
	if specificCharacters == nil then
		Ext.BroadcastMessage("LeaderLib_DisplayMessageBox", data, nil)
	else
		local charType = type(specificCharacters)
		if charType == "string" then
			Ext.PostMessageToClient(specificCharacters, "LeaderLib_DisplayMessageBox", data)
		elseif charType == "table" then
			for i,v in pairs(specificCharacters) do
				Ext.PostMessageToClient(v, "LeaderLib_DisplayMessageBox", data)
			end
		end
	end
end

---@param player string
---@param status string
---@param turns integer
function GameHelpers.UI.RefreshStatusTurns(player, status, turns)
	if CharacterIsPlayer(player) == 1 then
		local data = MessageData:CreateFromTable("MessageBoxData", {
			UUID = GetUUID(player),
			Status = status,
			Turns = turns
		}):ToString()
		Ext.BroadcastMessage("LeaderLib_UI_RefreshStatusTurns", data, nil)
	end
end

Ext.RegisterNetListener("LeaderLib_OnDelayTurnClicked", function(call, uuid, ...)
	--print(call, uuid, "DB_LeaderLib_Combat_ActiveObject", Ext.JsonStringify(Osi.DB_LeaderLib_Combat_ActiveObject:Get(nil,nil)))
	-- local charMatch = false
	-- for i,v in pairs(Osi.DB_LeaderLib_Combat_ActiveObject:Get(nil,nil)) do
	-- 	if GetUUID(v[2]) == uuid then
	-- 		charMatch = true
	-- 	end
	-- end
	-- if not charMatch then
	-- 	return
	-- end
	local length = #Listeners.TurnDelayed
	if length > 0 then
		for i=1,length do
			local callback = Listeners.TurnDelayed[i]
			local status,err = xpcall(callback, debug.traceback, uuid)
			if not status then
				Ext.PrintError("Error calling function for 'TurnDelayed':\n", err)
			end
		end
	end
end)

---@param visible boolean
---@param client string|nil
function GameHelpers.UI.SetStatusVisibility(visible, client)
	visible = visible ~= nil and tostring(visible) or tostring(GameSettings.Settings.Client.HideStatuses)
	client = client or CharacterGetHostCharacter()
	Ext.PostMessageToClient(client, "LeaderLib_UI_UpdateStatusVisibility", visible)
end

Ext.RegisterNetListener("LeaderLib_UI_Server_RefreshPlayerInfo", function(cmd, uuid)
	if ObjectExists(uuid) == 1 then
		ApplyStatus(uuid, "LEADERLIB_RECALC", 0.0, 1, uuid)
	end
end)

--[[
function GameHelpers.UI.UpdateStatusTurns(target, statusid)
	local objectHandle = nil
	local statusHandle = NRD_StatusGetHandle(target, statusid)

	if ObjectIsCharacter(target) == 1 then
		objectHandle = Ext.GetCharacter(target).Handle
	elseif ObjectIsItem(target) == 1 then
		objectHandle = Ext.GetItem(target).Handle
	end
	if objectHandle ~= nil and statusHandle ~= nil then
		local status = Ext.GetStatus(objectHandle, statusHandle)
		if status ~= nil then
			local data = MessageData:CreateFromTable("UpdateStatusUIData", {
				IsPlayer = CharacterIsPlayer(target) == 1,
				IsEnemy = CharacterIsPlayer(target) ~= 1,
				ObjectHandle = objectHandle,
				StatusHandle = status.StatusHandle,
				Turns = status.CurrentLifeTime / 6.0
			})
		end
	end
end
]]