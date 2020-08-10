local MessageData = Classes.MessageData

function SetSlotEnabled(client, slot, enabled)
	Ext.PostMessageToClient(client, "LeaderLib_Hotbar_SetSlotEnabled", MessageData:CreateFromTable("SetSlotEnabled", {
		Slot = slot,
		Enabled = enabled,
		UUID = client
	}):ToString())
end

GameHelpers.UI.SetSlotEnabled = SetSlotEnabled

function SetSkillEnabled(client, skill, enabled)
	if CharacterIsPlayer(client) == 1 then
		if type(enabled) == "string" then
			enabled = enabled == "true" or enabled == "1"
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
		Filter = filter,
		Text = text
	}):ToString()
	if specificCharacters == nil then
		Ext.BroadcastMessage("LeaderLib_AddTextToCombatLog", data, nil)
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

---@param text string
---@param title string|nil
---@param specificCharacters string|string[]|nil
---@param boxType integer|nil
---@param title string|nil
function GameHelpers.UI.ShowMessageBox(text, specificCharacters, boxType, title)
	local data = MessageData:CreateFromTable("MessageBoxData", {
		Type = boxType,
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