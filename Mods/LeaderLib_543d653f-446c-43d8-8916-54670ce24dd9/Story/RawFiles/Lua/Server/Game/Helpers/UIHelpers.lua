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

---@type client string
---@type skill string
---@type enabled string
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
	if #Listeners.TurnDelayed > 0 then
		for i,callback in ipairs(Listeners.TurnDelayed) do
			local status,err = xpcall(callback, debug.traceback, uuid)
			if not status then
				Ext.PrintError("Error calling function for 'TurnDelayed':\n", err)
			end
		end
	end
end)