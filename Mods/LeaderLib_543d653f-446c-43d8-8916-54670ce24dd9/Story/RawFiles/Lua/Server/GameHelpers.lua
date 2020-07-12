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

GameHelpers.ApplyProperties = ApplyProperties

---Get a character's party members.
---@param partyMember string
---@param includeSummons boolean
---@param includeFollowers boolean
---@param includeDead boolean
---@param includeSelf boolean
---@return string[]
local function GetParty(partyMember, includeSummons, includeFollowers, includeDead, includeSelf)
    local party = {}
    local allParty = Osi.DB_LeaderLib_AllPartyMembers:Get(nil)
    if allParty ~= nil then
        for i,v in pairs(allParty) do
            local uuid = v[1]
            if CharacterIsDead(uuid) == 0 or includeDead then
                if (uuid ~= partyMember or includeSelf) and CharacterIsInPartyWith(partyMember, uuid) == 1 then
                    if (CharacterIsSummon(uuid) == 0 or includeSummons) and (CharacterIsPartyFollower(uuid) == 0 or includeFollowers) then
                        party[#party+1] = uuid
                    end
                end
            end
        end
    end
    return party
end

GameHelpers.GetParty = GetParty

---Sets an object's rotation.
---@param uuid string
---@param rotx number
---@param rotz number
---@param turnTo boolean
local function SetRotation(uuid, rotx, rotz, turnTo)
    if ObjectIsCharacter(uuid) == 1 then
        local x,y,z = 0.0,0.0,0.0
        if rotx ~= nil and rotz ~= nil then
            local character = Ext.GetCharacter(uuid)
            local pos = character.Stats.Position
            local forwardVector = {
                -rotx * 4.0,
                0,
                -rotz * 4.0,
            }
            x = pos[1] + forwardVector[1]
            y = pos[2]
            z = pos[3] + forwardVector[3]
            local target = CreateItemTemplateAtPosition("98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
            if turnTo ~= true then
                CharacterLookAt(uuid, target, 1)
            end
            Osi.LeaderLib_Timers_StartObjectTimer(target, 250, "LLMIME_Timers_LeaderLib_Commands_RemoveItem", "LeaderLib_Commands_RemoveItem")
        end
    else
        local x,y,z = GetPosition(uuid)
        local amount = ItemGetAmount(uuid)
        local owner = ItemGetOwner(uuid)

        local pitch = 0.0174533 * rotx
        local roll = 0.0174533 * rotz

        ItemToTransform(uuid, x, y, z, pitch, 0.0, roll, amount, owner)
    end
end

GameHelpers.SetRotation = SetRotation

---Roll between 0 and 100 and see if the result is below a number.
---@param chance integer The minimum number that must be met.
---@param includeZero boolean If true, 0 is not a failure roll, otherwise the roll must be higher than 0.
---@return boolean,integer
local function Roll(chance, includeZero)
	if chance <= 0 then
		return false,0
	elseif chance >= 100 then
		return true,100
    end
    local roll = Ext.Random(0,100)
	if includeZero == true then
		return (roll <= chance),roll
	else
		return (roll > 0 and roll <= chance),roll
	end
end

GameHelpers.Roll = Roll

local function ClearActionQueue(character, purge)
    if purge then
        CharacterPurgeQueue(character)
    else
        CharacterFlushQueue(character)
    end

    CharacterMoveTo(character, character, 1, "", 1);
    CharacterSetStill(character);
end

GameHelpers.ClearActionQueue = ClearActionQueue