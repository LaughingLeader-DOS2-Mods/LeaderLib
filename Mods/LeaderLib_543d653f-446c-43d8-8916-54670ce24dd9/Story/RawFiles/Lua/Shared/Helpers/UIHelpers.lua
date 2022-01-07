if GameHelpers.UI == nil then
	GameHelpers.UI = {}
end

if Ext.IsServer() then

function SetSlotEnabled(client, slot, enabled)
	if CharacterGetReservedUserID(client) ~= nil then
		Ext.PostMessageToClient(client, "LeaderLib_Hotbar_SetSlotEnabled", Common.JsonStringify({
			Slot = slot,
			Enabled = enabled,
			UUID = client
		}))
	end
end

GameHelpers.UI.SetSlotEnabled = SetSlotEnabled

---@param client string
---@param skill string
---@param enabled string
function GameHelpers.UI.SetSkillEnabled(client, skill, enabled)
	if CharacterIsPlayer(client) == 1 and CharacterGetReservedUserID(client) ~= nil then
		if type(enabled) == "string" then
			enabled = string.lower(enabled) == "true" or enabled == "1"
		end
		local slots = GameHelpers.Skill.GetSkillSlots(client, skill, true)
		if #slots > 0 then
			Ext.PostMessageToClient(client, "LeaderLib_Hotbar_SetSlotEnabled", Common.JsonStringify({
				Slots = slots,
				Enabled = enabled,
				UUID = client
			}))
		end
	end
end

SetSkillEnabled = GameHelpers.UI.SetSkillEnabled

---@param client string Client character UUID.
---@param skill string
function GameHelpers.UI.RefreshSkillBarSkillCooldown(client, skill)
	if CharacterIsPlayer(client) == 1 and CharacterGetReservedUserID(client) ~= nil then
		local data = {NetID = GameHelpers.GetNetID(client), Slots = {}}
		local slots = GameHelpers.Skill.GetSkillSlots(client, skill, true)
		if #slots > 0 then
			local cd = Ext.GetCharacter(client):GetSkillInfo(skill).ActiveCooldown
			for _,index in pairs(slots) do
				table.insert(data.Slots, {
					Index = index,
					Cooldown = math.ceil(cd/6)
				})
			end
			Ext.PostMessageToClient(client, "LeaderLib_Hotbar_RefreshCooldowns", Common.JsonStringify(data))
		end
	end
end

RefreshSkillBarSkillCooldown = GameHelpers.UI.RefreshSkillBarSkillCooldown

---Refresh the skillbar's cooldowns.
---@param client string Client character UUID.
function GameHelpers.UI.RefreshSkillBarCooldowns(client)
	if CharacterIsPlayer(client) == 1 and CharacterGetReservedUserID(client) ~= nil then
		local character = Ext.GetCharacter(client)
		local data = {NetID = GameHelpers.GetNetID(client), Slots = {}}
		for i=0,144,1 do
			local skill = NRD_SkillBarGetSkill(client, i)
			if skill ~= nil then
				local info = character:GetSkillInfo(skill)
				if info ~= nil and info.ActiveCooldown > 0 then
					table.insert(data.Slots, {
						Index = i,
						Cooldown = math.ceil(info.ActiveCooldown/6)
					})
				end
			end
		end
		Ext.PostMessageToClient(client, "LeaderLib_Hotbar_RefreshCooldowns", Common.JsonStringify(data))
	end
end

RefreshSkillBarCooldowns = GameHelpers.UI.RefreshSkillBarCooldowns

---Refresh the skillbar's cooldowns.
---@param client UUID|NETID|EsvCharacter
---@param delay integer
function GameHelpers.UI.RefreshSkillBarAfterDelay(client, delay)
	local uuid = GameHelpers.GetUUID(client)
	if uuid then
		local timerName = string.format("LeaderLib_RefreshSkillbar_%s", uuid)
		Timer.Cancel(timerName)
		Timer.StartOneshot(timerName, delay, function()
			GameHelpers.UI.RefreshSkillBar(uuid)
		end)
	end
end

---@param text string
---@param filter integer
---@param specificCharacters string|string[]|nil
function GameHelpers.UI.CombatLog(text, filter, specificCharacters)
	local data = Common.JsonStringify({
		Filter = filter or 0,
		Text = GameHelpers.Tooltip.ReplacePlaceholders(text)
	})
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
---@param specificCharacters string|string[]|nil
---@param boxType integer|nil
---@param title string|nil
function GameHelpers.UI.ShowMessageBox(text, specificCharacters, boxType, title)
	local data = Common.JsonStringify({
		Type = boxType or 1,
		Text = text,
		Title = title
	})
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
		local data = Common.JsonStringify({
			UUID = GetUUID(player),
			Status = status,
			Turns = turns
		})
		Ext.BroadcastMessage("LeaderLib_UI_RefreshStatusTurns", data, nil)
	end
end

Ext.RegisterNetListener("LeaderLib_OnDelayTurnClicked", function(call, uuid, ...)
	--print(call, uuid, "DB_LeaderLib_Combat_ActiveObject", Common.JsonStringify(Osi.DB_LeaderLib_Combat_ActiveObject:Get(nil,nil)))
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

Ext.RegisterNetListener("LeaderLib_UI_Server_RefreshPlayerInfo", function(cmd, netid)
	local character = Ext.GetCharacter(tonumber(netid))
	if character and not character.Dead and not character.OffStage then
		local timerName = string.format("LeaderLib_Recalc_%s", character.MyGuid)
		Timer.StartOneshot(timerName, 10, function()
			ApplyStatus(character.MyGuid, "LEADERLIB_RECALC", 0.0, 1, character.MyGuid)
		end)
	end
end)

else
	---@param id integer|string
	---@param method string
	---@vararg any
	---@return boolean
	function GameHelpers.UI.TryInvoke(id, method, ...)
		local ui = nil
		local t = type(id)
		if t == "number" then
			ui = Ext.GetUIByType(id)
		elseif t == "string" then
			ui = Ext.GetBuiltinUI(id) or Ext.GetUI(id)
		end
		if ui then
			ui:Invoke(method, ...)
			return true
		end
		return false
	end

	---@param id integer|string
	---@return FlashMainTimeline
	function GameHelpers.UI.TryGetRoot(id)
		local ui = nil
		local t = type(id)
		if t == "number" then
			ui = Ext.GetUIByType(id)
		elseif t == "string" then
			ui = Ext.GetBuiltinUI(id) or Ext.GetUI(id)
		end
		if ui then
			return ui:GetRoot()
		end
		return nil
	end
end

---Refresh the whole active skillbar. Useful for refreshing if a skill is clickable from tag requirements changing.
---@param client string|integer|EsvCharacter Client character UUID, user ID, or EsvCharacter.
function GameHelpers.UI.RefreshSkillBar(client)
	if not Vars.IsClient then
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
	else
		local ui = not Vars.ControllerEnabled and Ext.GetUIByType(Data.UIType.hotBar) or Vars.ControllerEnabled and Ext.GetBuiltinUI(Data.UIType.bottomBar_c)
		if ui then
			ui:ExternalInterfaceCall("updateSlots", ui:GetValue("maxSlots", "number"))
		end
	end
end

RefreshSkillBar = GameHelpers.UI.RefreshSkillBar