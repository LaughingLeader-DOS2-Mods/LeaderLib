if GameHelpers.UI == nil then
	GameHelpers.UI = {}
end

local _type = type
local _ISCLIENT = Ext.IsClient()

if not _ISCLIENT then
	function SetSlotEnabled(client, slot, enabled)
		GameHelpers.Net.PostToUser(client, "LeaderLib_Hotbar_SetSlotEnabled", Common.JsonStringify({
			Slot = slot,
			Enabled = enabled,
			UUID = client
		}))
	end

	GameHelpers.UI.SetSlotEnabled = SetSlotEnabled

	---@param client CharacterParam
	---@param skill string
	---@param enabled string|boolean
	function GameHelpers.UI.SetSkillEnabled(client, skill, enabled)
		client = GameHelpers.GetUUID(client)
		if not StringHelpers.IsNullOrEmpty(client) then
			if GameHelpers.Character.IsPlayer(client) then
				if _type(enabled) == "string" then
					enabled = string.lower(enabled) == "true" or enabled == "1"
				end
				local slots = GameHelpers.Skill.GetSkillSlots(client, skill, true)
				if #slots > 0 then
					GameHelpers.Net.PostToUser(client, "LeaderLib_Hotbar_SetSlotEnabled", {
						Slots = slots,
						Enabled = enabled,
						UUID = client
					})
				end
			end
		end
	end

	SetSkillEnabled = GameHelpers.UI.SetSkillEnabled

	---@param client CharacterParam
	---@param skill string
	function GameHelpers.UI.RefreshSkillBarSkillCooldown(client, skill)
		local character = GameHelpers.GetCharacter(client)
		if character and GameHelpers.Character.IsPlayer(character) and character.ReservedUserID then
			local data = {NetID = character.NetID, Slots = {}}
			local slots = GameHelpers.Skill.GetSkillSlots(client, skill, true)
			if #slots > 0 then
				local cd = character:GetSkillInfo(skill).ActiveCooldown
				for _,index in pairs(slots) do
					table.insert(data.Slots, {
						Index = index,
						Cooldown = math.ceil(cd/6)
					})
				end
				GameHelpers.Net.PostToUser(character, "LeaderLib_Hotbar_RefreshCooldowns", Common.JsonStringify(data))
			end
		end
	end

	RefreshSkillBarSkillCooldown = GameHelpers.UI.RefreshSkillBarSkillCooldown

	---Refresh the skillbar's cooldowns.
	---@param client CharacterParam The client character 
	function GameHelpers.UI.RefreshSkillBarCooldowns(client)
		local character = GameHelpers.GetCharacter(client) --[[@as EsvCharacter]]
		if character and GameHelpers.Character.IsPlayer(character) then
			local data = {NetID = GameHelpers.GetNetID(client), Slots = {}}
			for i,v in pairs(character.PlayerData.SkillBar) do
				if v.Type == "Skill" then
					local skillInfo = character.SkillManager.Skills[v.SkillOrStatId]
					table.insert(data.Slots, {
						Index = i,
						Cooldown = math.ceil(skillInfo.ActiveCooldown/6)
					})
				end
			end
			GameHelpers.Net.PostToUser(client, "LeaderLib_Hotbar_RefreshCooldowns", Common.JsonStringify(data))
		end
	end

	RefreshSkillBarCooldowns = GameHelpers.UI.RefreshSkillBarCooldowns

	---@param text string
	---@param filter integer
	---@param specificCharacters string|string[]|nil
	function GameHelpers.UI.CombatLog(text, filter, specificCharacters)
		local data = Common.JsonStringify({
			Filter = filter or 0,
			Text = GameHelpers.Tooltip.ReplacePlaceholders(text)
		})
		if specificCharacters == nil then
			GameHelpers.Net.Broadcast("LeaderLib_AddTextToCombatLog", data)
		else
			local charType = _type(specificCharacters)
			if charType == "string" then
				GameHelpers.Net.PostToUser(specificCharacters, "LeaderLib_AddTextToCombatLog", data)
			elseif charType == "table" then
				for i,v in pairs(specificCharacters) do
					GameHelpers.Net.PostToUser(v, "LeaderLib_AddTextToCombatLog", data)
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
			GameHelpers.Net.Broadcast("LeaderLib_DisplayMessageBox", data)
		else
			local charType = _type(specificCharacters)
			if charType == "string" then
				GameHelpers.Net.PostToUser(specificCharacters, "LeaderLib_DisplayMessageBox", data)
			elseif charType == "table" then
				for i,v in pairs(specificCharacters) do
					GameHelpers.Net.PostToUser(v, "LeaderLib_DisplayMessageBox", data)
				end
			end
		end
	end

	---@param player string
	---@param status string
	---@param turns integer
	function GameHelpers.UI.RefreshStatusTurns(player, status, turns)
		if Osi.CharacterIsPlayer(player) == 1 then
			local data = Common.JsonStringify({
				UUID = Osi.GetUUID(player),
				Status = status,
				Turns = turns
			})
			GameHelpers.Net.Broadcast("LeaderLib_UI_RefreshStatusTurns", data)
		end
	end

	Ext.RegisterNetListener("LeaderLib_OnDelayTurnClicked", function(call, uuid, ...)
		Events.TurnDelayed:Invoke({CharacterGUID = uuid, Character=GameHelpers.GetCharacter(uuid)})
	end)

	---@param visible boolean
	---@param client string|nil
	function GameHelpers.UI.SetStatusVisibility(visible, client)
		visible = visible ~= nil and tostring(visible) or tostring(GameSettings.Settings.Client.HideStatuses)
		client = client or Osi.CharacterGetHostCharacter()
		GameHelpers.Net.PostToUser(client, "LeaderLib_UI_UpdateStatusVisibility", visible)
	end

	Ext.RegisterNetListener("LeaderLib_UI_Server_RefreshPlayerInfo", function(cmd, netid)
		local id = tonumber(netid)
		local character = GameHelpers.GetCharacter(id)
		if character and not character.Dead and not character.OffStage then
			local timerName = string.format("LeaderLib_Recalc_%s", id)
			Timer.StartOneshot(timerName, 10, function()
				local character = GameHelpers.GetCharacter(id)
				if character then
					GameHelpers.Status.Apply(character, "LEADERLIB_RECALC", 0.0, true, character)
				end
			end)
		end
	end)

else
	---@param id integer|string
	---@param method string
	---@vararg SerializableValue
	---@return boolean
	function GameHelpers.UI.TryInvoke(id, method, ...)
		local ui = nil
		local t = _type(id)
		if t == "number" then
			ui = Ext.UI.GetByType(id)
		elseif t == "string" then
			ui = Ext.UI.GetByPath(id) or Ext.UI.GetByName(id)
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
		local t = _type(id)
		if t == "number" then
			ui = Ext.UI.GetByType(id)
		elseif t == "string" then
			ui = Ext.UI.GetByPath(id) or Ext.UI.GetByName(id)
		end
		if ui then
			return ui:GetRoot()
		end
		return nil
	end
end

---Refresh the whole active skillbar. Useful for refreshing if a skill is clickable from tag requirements changing.
---@param client CharacterParam|integer|nil Client character UUID, user ID, or Esv/EclCharacter.
function GameHelpers.UI.RefreshSkillBar(client)
	if not _ISCLIENT then
		local player = GameHelpers.GetCharacter(client)
		if player and player.CharacterControl then
			GameHelpers.Net.PostToUser(player, "LeaderLib_Hotbar_Refresh", "")
		end
	else
		local ui = not Vars.ControllerEnabled and Ext.UI.GetByType(Data.UIType.hotBar) or Vars.ControllerEnabled and Ext.UI.GetByPath(Data.UIType.bottomBar_c)
		if ui then
			ui:ExternalInterfaceCall("updateSlots", UI.MaxHotbarSlots)
		end
	end
end

if _ISCLIENT then
	Ext.RegisterNetListener("LeaderLib_Hotbar_Refresh", function(call, payload)
		GameHelpers.UI.RefreshSkillBar(nil)
	end)
end

RefreshSkillBar = GameHelpers.UI.RefreshSkillBar

---Refresh the skillbar's cooldowns.
---@param client CharacterParam
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