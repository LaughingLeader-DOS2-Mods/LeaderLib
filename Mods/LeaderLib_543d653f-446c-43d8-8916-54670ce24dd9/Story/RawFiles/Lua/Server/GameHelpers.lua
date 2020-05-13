Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/Game/DamageHelpers.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/Game/HitHelpers.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/Game/ItemHelpers.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/Game/ProjectileHelpers.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/Game/SkillHelpers.lua")

--- Applies ExtraProperties/SkillProperties.
---@param target string
---@param source string|nil
---@param properties StatProperty[]
local function ApplyProperties(target, source, properties)
    if Ext.IsDeveloperMode() then
        PrintDebug("=========")
        PrintDebug(Common.Dump(properties))
        PrintDebug("=========")
    end
    for i,v in ipairs(properties) do
        if v.Type == "Status" then
            if v.Context[1] == "Target" then
                if target ~= nil then
                    if v.StatusChance >= 1.0 then
                        ApplyStatus(target, v.Action, v.Duration, 0, source)
                    elseif v.StatusChance > 0 then
                        if Ext.Random(0.0, 1.0) <= v.StatusChance then
                            ApplyStatus(target, v.Action, v.Duration, 0, source)
                        end
                    end
                end
            elseif v.Context[1] == "Self" then
                if v.StatusChance >= 1.0 then
                    ApplyStatus(source, v.Action, v.Duration, 0, source)
                elseif v.StatusChance > 0 then
                    if Ext.Random(0.0, 1.0) <= v.StatusChance then
                        ApplyStatus(source, v.Action, v.Duration, 0, source)
                    end
                end
            end
        end
    end
end

---Get a character's party members.
---@param partyMember string
---@param includeSummons boolean
---@param includeFollowers boolean
---@param includeSelf boolean
---@return string[]
local function GetParty(partyMember, includeSummons, includeFollowers, includeSelf)
    local party = {}
    local allParty = Osi.DB_LeaderLib_AllPartyMembers:Get(nil)
    if allParty ~= nil then
        for i,v in pairs(allParty) do
            local uuid = v[1]
            if (uuid ~= partyMember or includeSelf) and CharacterIsInPartyWith(partyMember, uuid) == 1 then
                if (CharacterIsSummon(uuid) == 0 or includeSummons) and (CharacterIsPartyFollower(uuid) == 0 or includeFollowers) then
                    party[#party+1] = uuid
                end
            end
        end
    end
    return party
end

Game.ApplyProperties = ApplyProperties