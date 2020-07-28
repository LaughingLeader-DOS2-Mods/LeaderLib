---Clone an item for a character.
---@param char string
---@param item string
---@param completion_event string
---@param autolevel string
local function CloneItemForCharacter(char, item, completion_event, autolevel)
    local autolevel_enabled = autolevel == "Yes"
	NRD_ItemCloneBegin(item)
    local cloned = NRD_ItemClone()
    if autolevel_enabled then
        local level = CharacterGetLevel(char)
        ItemLevelUpTo(cloned,level)
    end
    CharacterItemSetEvent(char, cloned, completion_event)
end

---Creates an item by stat, provided it has an ItemGroup set (for equipment).
---@param statName string
---@param level integer
---@param rarity string|nil
---@param identify integer
---@param amount integer
---@param goldValueOverwrite integer
---@param weightValueOverwrite integer
---@return string
function GameHelpers.CreateItemByStat(statName, level, rarity, identify, amount, goldValueOverwrite, weightValueOverwrite)
    ---@type StatEntryWeapon
    local stat = nil
    local statType = ""
    if type(statName) == "string" then
        stat = Ext.GetStat(stat, level)
        statType = NRD_StatGetType(statName)
    else
        stat = statName
        statType = NRD_StatGetType(stat.Name)
    end
    
    local rootTemplate = nil
    local generateRandomBoosts = 0
    if stat.RootTemplate ~= nil and stat.RootTemplate ~= "" then
        rootTemplate = stat.RootTemplate
    elseif stat.ItemGroup ~= nil and stat.ItemGroup ~= "" then
        generateRandomBoosts = 1
        local group = Ext.GetItemGroup(stat.ItemGroup)
        for i,v in pairs(group.LevelGroups) do
            if v.Name == "All" or v.Name == rarity then
                if v.MinLevel <= level and v.MaxLevel <= level then
                    rootTemplate = v.RootGroups[1].RootGroup
                end
            end
        end
    end

    if rootTemplate ~= nil then
        NRD_ItemConstructBegin(rootTemplate)

        if rarity == nil or rarity == "" then
            rarity = "Common"
        end

        if statType == "Weapon" then
            -- Damage type fix
            -- Deltamods with damage boosts may make the weapon's damage type be all of that type, so overwriting the statType
            -- fixes this issue.
            local damageTypeString = stat["Damage Type"]
            if damageTypeString == nil then damageTypeString = "Physical" end
            local damageTypeEnum = Data.DamageTypeEnums[damageTypeString]
            NRD_ItemCloneSetInt("DamageTypeOverwrite", damageTypeEnum)
        end

        if goldValueOverwrite ~= nil then
            NRD_ItemCloneSetInt("GoldValueOverwrite", goldValueOverwrite)
        end
        if weightValueOverwrite ~= nil then
            NRD_ItemCloneSetInt("WeightValueOverwrite", weightValueOverwrite)
        end
        if amount ~= nil then
            NRD_ItemCloneSetInt("Amount", amount)
        end

        NRD_ItemCloneSetString("RootTemplate", rootTemplate)
        NRD_ItemCloneSetString("OriginalRootTemplate", rootTemplate)
        NRD_ItemCloneSetString("GenerationStatsId", stat)
        NRD_ItemCloneSetString("StatsEntryName", stat)
        NRD_ItemCloneSetInt("HasGeneratedStats", generateRandomBoosts)
        NRD_ItemCloneSetInt("GenerationLevel", level)
        NRD_ItemCloneSetInt("StatsLevel", level)
        NRD_ItemCloneSetInt("IsIdentified", identify or 1)
        NRD_ItemCloneSetString("ItemType", rarity)
        NRD_ItemCloneSetString("GenerationItemType", rarity)

        return NRD_ItemClone()
    end
    return nil
end

local function GetEquippedSlot(char, item)
    for i,slot in Data.EquipmentSlots:Get() do
        local slotItem = CharacterGetEquippedItem(char, slot)
        if slotItem ~= nil and GetUUID(slotItem) == GetUUID(item) then
            return slot
        end
    end
    return nil
end

function EquipInSlot(char, item, slot)
    if Ext.Version() >= 42 then
        NRD_CharacterEquipItem(char, item, slot, 0, 0, 1, 1)
    else
        CharacterEquipItem(char, item)
    end
end

function ItemIsEquipped(char, item)
    local itemObj = Ext.GetItem(item)
    if itemObj ~= nil then
        local slot = itemObj.Slot
        if slot <= 13 then -- 13 is the Overhead slot
            return true
        end
    else
        for i,slot in Data.EquipmentSlots:Get() do
            if CharacterGetEquippedItem(char, slot) == item then
                return true
            end
        end
    end
    return false
end

function GameHelpers.ItemIsEquippedByCharacter(item)
    local itemObj = Ext.GetItem(item)
    if itemObj ~= nil then
        if itemObj.InUseByCharacterHandle ~= nil and itemObj.InUseByCharacterHandle ~= 0 then
            return true
        end
    end
    return false
end

---Removes matching rune templates from items in any equipment slots.
---@param character string
---@param runeTemplates table
function GameHelpers.RemoveRunes(character, runeTemplates)
	for _,slotName in Data.VisibleEquipmentSlots:Get() do
		local item = CharacterGetEquippedItem(character, slotName)
		if item ~= nil then
			for runeSlot=0,2,1 do
				local runeTemplate = ItemGetRuneItemTemplate(item, runeSlot)
				if runeTemplate ~= nil and runeTemplates[runeTemplate] == true then
					local rune = ItemRemoveRune(character, item, runeSlot)
					PrintDebug("[LeaderLib:RemoveRunes] Removed rune ("..tostring(rune)..") from item ("..item..")["..tostring(runeSlot).."] for character ("..character..")")
				end
			end
		end
	end
end

--- Checks if a character has an item equipped with a specific tag.
---@param character string
---@param tag string
---@return boolean
function GameHelpers.HasTagEquipped(character, tag)
    if StringHelpers.IsNullOrEmpty(character) or StringHelpers.IsNullOrEmpty(tag) then
        return false
    end
	for _,slotName in Data.VisibleEquipmentSlots:Get() do
		local item = CharacterGetEquippedItem(character, slotName)
		if item ~= nil and IsTagged(item, tag) == 1 then
			return true
		end
	end
	return false
end

GameHelpers.EquipInSlot = EquipInSlot
GameHelpers.GetEquippedSlot = GetEquippedSlot
GameHelpers.ItemIsEquipped = ItemIsEquipped
GameHelpers.CloneItemForCharacter = CloneItemForCharacter
GameHelpers.CreateItemByStat = CreateItemByStat
GameHelpers.RemoveRunes = RemoveRunes

--- Removes an item in a slot, if one exists.
---@param character string
---@param slot string
---@param delete boolean Whether to destroy the item or simply unequip it.
---@return boolean
function GameHelpers.UnequipItemInSlot(character, slot, delete)
    local item = CharacterGetEquippedItem(character, slot)
    if item ~= nil then
        CharacterUnequipItem(character, item)
        if delete == true and ObjectIsGlobal(item) == 0 then
            ItemRemove(item)
        end
    end
end

--- Checks if a character has an item equipped with a specific tag.
---@param character string
---@param tag string
---@return boolean
function GameHelpers.FindTaggedEquipment(character, tag)
    local items = {}
	for _,slotName in Data.VisibleEquipmentSlots:Get() do
		local item = CharacterGetEquippedItem(character, slotName)
		if item ~= nil and IsTagged(item, tag) == 1 then
			items[slotName] = item
		end
	end
	return items
end