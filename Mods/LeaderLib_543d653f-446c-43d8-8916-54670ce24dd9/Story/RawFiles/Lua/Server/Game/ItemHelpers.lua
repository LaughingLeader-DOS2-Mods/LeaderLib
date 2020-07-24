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

---Creates an item by stat, using cloning.
---@param stat string
---@param level integer
---@return string
local function CreateItemByStat(stat, level)
    local x,y,z = GetPosition(CharacterGetHostCharacter())
    local item = CreateItemTemplateAtPosition("LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830",x,y,z)
    NRD_ItemCloneBegin(item)
    NRD_ItemCloneSetString("GenerationStatsId", stat)
    NRD_ItemCloneSetString("StatsEntryName", stat)
    NRD_ItemCloneSetInt("HasGeneratedStats", 0)
    NRD_ItemCloneSetInt("StatsLevel", level)
    --NRD_ItemCloneResetProgression()
    local cloned NRD_ItemClone()
    ItemLevelUpTo(cloned,level)
    return cloned
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

---Removes matching rune templates from items in any equipment slots.
---@param character string
---@param runeTemplates table
local function RemoveRunes(character, runeTemplates)
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
local function HasTagEquipped(character, tag)
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
GameHelpers.HasTagEquipped = HasTagEquipped

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