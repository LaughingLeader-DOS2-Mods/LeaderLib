Ext.RegisterConsoleCommand("luareset", function(cmd, delay)
    Ext.PostMessageToServer("LeaderLib_Client_RequestLuaReset", delay or "")
end)

Ext.RegisterConsoleCommand("abilityTest", function(cmd, enabled)
    if enabled == "false" then
        SheetManager.AbilityManager.DisableAbility("all", ModuleUUID)
    else
        SheetManager.AbilityManager.EnableAbility("all", ModuleUUID)
    end
end)

local pointsWarn = {}

Input.RegisterListener("ToggleCraft", function(event, pressed, id, keys, controllerEnabled)
    if Input.IsPressed("ToggleInfo") then
        local this = Ext.GetUIByType(Data.UIType.characterSheet):GetRoot()
        Ext.Print("Toggling GM mode in character sheet: ", not this.isGameMasterChar)
        if this.isGameMasterChar then
            this.setGameMasterMode(false, false, false)
            this.stats_mc.setVisibilityStatButtons(false)
            this.stats_mc.setVisibilityAbilityButtons(true, false)
            this.stats_mc.setVisibilityAbilityButtons(false, false)
            this.stats_mc.setVisibilityTalentButtons(false)
            Ext.PostMessageToServer("LeaderLib_RefreshCharacterSheet", Client.Character.UUID)

            for i,v in pairs(pointsWarn) do
                this.stats_mc.INTSetWarnAndPoints(i,v)
            end
            pointsWarn = {}
        else
            for i=0,#this.stats_mc.pointsWarn-1 do
                pointsWarn[i] = this.stats_mc.pointsWarn[i].avPoints
            end

            this.setGameMasterMode(true, true, false)
        end
    end
end)

-- Ext.RegisterListener("SessionLoaded", function()
    
-- end)

local registeredContextListeners = false
Ext.RegisterConsoleCommand("contextRollTest", function()
    if not registeredContextListeners then
        UI.ContextMenu.Register.ShouldOpenListener(function(contextMenu, x, y)
            if Game.Tooltip.RequestTypeEquals("CustomStat") then
                return true
            end
        end)
        
        UI.ContextMenu.Register.OpeningListener(function(contextMenu, x, y)
            if Game.Tooltip.RequestTypeEquals("CustomStat") and Game.Tooltip.IsOpen() then
                ---@type TooltipCustomStatRequest
                local request = Game.Tooltip.GetCurrentOrLastRequest()
                local characterId = request.Character.NetID
                local modId = nil
                local statId = request.Stat
                if request.StatData then
                    modId = request.StatData.Mod
                    statId = request.StatData.ID
                end
                contextMenu:AddEntry("RollCustomStat", function(cMenu, ui, id, actionID, handle)
                    CustomStatSystem:RequestStatChange(statId, characterId, Ext.Random(1,10), modId)
                end, "<font color='#33AA33'>Roll</font>")
            end
        end)
        
        UI.ContextMenu.Register.EntryClickedListener(function(...)
            fprint(LOGLEVEL.DEFAULT, "[ContextMenu.EntryClickedListener] %s", Lib.inspect({...}))
        end)

        registeredContextListeners = true
    end
end)

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