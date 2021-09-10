Ext.RegisterConsoleCommand("luareset", function(cmd, delay)
    Ext.PostMessageToServer("LeaderLib_Client_RequestLuaReset", delay or "")
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