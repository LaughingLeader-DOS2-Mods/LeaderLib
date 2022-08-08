Ext.RegisterConsoleCommand("luareset", function(cmd, delay)
	Ext.PostMessageToServer("LeaderLib_Client_RequestLuaReset", delay or "")
end)

-- Ext.Events.SessionLoaded:Subscribe(function()
	
-- end)

AddConsoleVariable("UIExt", UIExtensions)

-- local flagFound = false; local flags = {"GLO_PathOfBlood_MurderedInnocent", "GLO_PathOfBlood_DisrespectedSoul", "GLO_StoleItem"}; for i,db in pairs(Osi.DB_IsPlayer:Get(nil)) do local player = Ext.GetCharacter(db[1]); for _,flag in pairs(flags) do if ObjectGetFlag(player.MyGuid, flag) == 1 then Ext.Print(string.format("Player (%s) has flag (%s)", player.DisplayName, flag)); flagFound = true; end; end; end; if not flagFound then Ext.Print("No Path of Blood flags set on players.") end

-- local flagFound = false; 
-- local flags = {"GLO_PathOfBlood_MurderedInnocent", "GLO_PathOfBlood_DisrespectedSoul", "GLO_StoleItem"}; 
-- for i,db in pairs(Osi.DB_IsPlayer:Get(nil)) do 
--     local player = Ext.GetCharacter(db[1])
--     for _,flag in pairs(flags) do 
--         if ObjectGetFlag(player.MyGuid, flag) == 1 then 
--             Ext.Print(string.format("Player (%s) has flag (%s)", player.DisplayName, flag))
--             flagFound = true
--         end
--     end
-- end 
-- if not flagFound then 
--     Ext.Print("No Path of Blood flags set on players.") 
-- end

if Vars.DebugMode then
	-- Input.RegisterListener(function(event, pressed, id, keys, controllerEnabled)
	--     if not string.find(event, "Mouse") then
	--         print(event,id,pressed)
	--     end
	-- end)

	Input.RegisterListener("FlashHome", function(event, pressed, id, keys, controllerEnabled)
		if not pressed and Input.IsPressed("FlashCtrl") then
			Vars.Commands.Teleporting = not Vars.Commands.Teleporting
			local text = string.format("<font color='#76FF00'>Click to Teleport %s</font>", Vars.Commands.Teleporting and "Enabled" or "Disabled")
			Ext.PostMessageToServer("LeaderLib_CharacterStatusText", Common.JsonStringify({
				Target = Client.Character.UUID,
				Text = text
			}))
			--[[ local this = Ext.GetUIByType(Data.UIType.overhead):GetRoot()
			local doubleHandle = Ext.HandleToDouble(Client:GetCharacter().Handle)
			this.addOverhead(doubleHandle, text, 2.0)
			this.updateOHs() ]]
		end
	end)

	Input.RegisterMouseListener(UIExtensions.MouseEvent.Clicked, function(event, pressed, id, keys, controllerEnabled)
		if Vars.Commands.Teleporting then
			local state = Ext.GetPickingState()
			if state and state.WalkablePosition then
				Ext.PostMessageToServer("LeaderLib_TeleportToPosition", Common.JsonStringify({
					Target = GameHelpers.GetNetID(Client:GetCharacter()),
					Pos = state.WalkablePosition
				}))
			end
		end
	end)
end

--Duplicate tooltip element test
--[[ Ext.Events.SessionLoaded:Subscribe(function (e)
	---@param character EclCharacter
	---@param status EclStatus
	---@param tooltip TooltipData
	Game.Tooltip.RegisterListener("Status", nil, function (character, status, tooltip)
		-- local boost = status.StatsMultiplier
		local boost = 1.5
		if boost > 1 then
			boost = Ext.Utils.Round((boost - 1) * 100)
			local element = {
				Type = "StatusBonus",
				Label = string.format("Boosted +%i%%", boost),
			}
			tooltip:AppendElementAfterType(element, "StatusBonus")
		end
	end)
end) ]]