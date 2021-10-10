Ext.RegisterConsoleCommand("luareset", function(cmd, delay)
    Ext.PostMessageToServer("LeaderLib_Client_RequestLuaReset", delay or "")
end)

-- Ext.RegisterListener("SessionLoaded", function()
    
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
    local isSheetOpen = false
    Ext.RegisterUITypeInvokeListener(Data.UIType.hotBar, "setButtonActive", function(ui, method, id, isActive)
        if id == 1 then
            isSheetOpen = isActive
        end
    end)
    -- CTRL + G to toggle GameMasterMode
    Input.RegisterListener("ToggleCraft", function(event, pressed, id, keys, controllerEnabled)
        if Input.IsPressed("ToggleInfo") and isSheetOpen then
            ---@type FlashMainTimeline
            local this = nil
            if not Vars.ControllerEnabled then
                this = Ext.GetUIByType(Data.UIType.characterSheet):GetRoot()
            else
                this = Ext.GetUIByType(Data.UIType.statsPanel_c):GetRoot()
            end
            if not this then
                return
            end
            Ext.Print("Toggling GM mode in character sheet: ", not this.isGameMasterChar)
            if this.isGameMasterChar then
                this.setGameMasterMode(false, false, false)
                this.stats_mc.setVisibilityStatButtons(false)
                this.stats_mc.setVisibilityAbilityButtons(true, false)
                this.stats_mc.setVisibilityAbilityButtons(false, false)
                this.stats_mc.setVisibilityTalentButtons(false)
                Ext.PostMessageToServer("LeaderLib_RefreshCharacterSheet", Client.Character.UUID)
    
                this.setAvailableStatPoints(Client.Character.Points.Attribute)
                this.setAvailableCombatAbilityPoints(Client.Character.Points.Ability)
                this.setAvailableCivilAbilityPoints(Client.Character.Points.Civil)
                this.setAvailableTalentPoints(Client.Character.Points.Talent)
                if Mods.CharacterExpansionLib then
                    this.setAvailableCustomStatPoints(Mods.CharacterExpansionLib.CustomStatSystem:GetTotalAvailablePoints())
                end
            else
                this.setGameMasterMode(true, true, false)
                this.stats_mc.setVisibilityStatButtons(true)
                this.stats_mc.setVisibilityAbilityButtons(true, true)
                this.stats_mc.setVisibilityAbilityButtons(false, true)
                this.stats_mc.setVisibilityTalentButtons(true)
            end
        end
    end)

    -- Input.RegisterListener(function(event, pressed, id, keys, controllerEnabled)
    --     if not string.find(event, "Mouse") then
    --         print(event,id,pressed)
    --     end
    -- end)

    Input.RegisterListener("FlashHome", function(event, pressed, id, keys, controllerEnabled)
        if not pressed and Input.IsPressed("FlashCtrl") then
            Vars.Commands.Teleporting = not Vars.Commands.Teleporting
            local text = string.format("<font color='#76FF00'>Click to Teleported %s</font>", Vars.Commands.Teleporting and "Enabled" or "Disabled")
            Ext.PostMessageToServer("LeaderLib_CharacterStatusText", Ext.JsonStringify({
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
                Ext.PostMessageToServer("LeaderLib_TeleportToPosition", Ext.JsonStringify({
                    Target = GameHelpers.GetNetID(Client:GetCharacter()),
                    Pos = state.WalkablePosition
                }))
            end
        end
    end)
end