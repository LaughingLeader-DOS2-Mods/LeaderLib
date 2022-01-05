if GameHelpers.Item == nil then
    GameHelpers.Item = {}
end

local itemConstructorProps = {
    ["RootTemplate"] = true,
    ["OriginalRootTemplate"] = true,
    ["Slot"] = true,
    ["Amount"] = true,
    ["GoldValueOverwrite"] = true,
    ["WeightValueOverwrite"] = true,
    ["DamageTypeOverwrite"] = true,
    ["ItemType"] = true,
    ["CustomDisplayName"] = true,
    ["CustomDescription"] = true,
    ["CustomBookContent"] = true,
    ["GenerationStatsId"] = true,
    ["GenerationItemType"] = true,
    ["GenerationRandom"] = true,
    ["GenerationLevel"] = true,
    ["StatsLevel"] = true,
    ["Key"] = true,
    ["LockLevel"] = true,
    ["EquipmentStatsType"] = true,
    ["HasModifiedSkills"] = true,
    ["Skills"] = true,
    ["HasGeneratedStats"] = true,
    ["IsIdentified"] = true,
    ["GMFolding"] = true,
    ["CanUseRemotely"] = true,
    ["GenerationBoosts"] = true,
    ["RuneBoosts"] = true,
    ["DeltaMods"] = true,
}

---Clone an item for a character.
---@param char string
---@param item string
---@param completion_event string
---@param autolevel string
function GameHelpers.Item.CloneItemForCharacter(char, item, completion_event, autolevel)
    local autolevel_enabled = autolevel == "Yes"
	NRD_ItemCloneBegin(item)
    local cloned = NRD_ItemClone()
    if autolevel_enabled then
        local level = CharacterGetLevel(char)
        ItemLevelUpTo(cloned,level)
    end
    CharacterItemSetEvent(char, cloned, completion_event)
end

---@param item EsvItem|string
---@return integer
function GameHelpers.Item.GetItemLevel(item)
    if type(item) == "string" then
        local itemObject = Ext.GetItem(item)
        if itemObject then
            return GameHelpers.Item.GetItemLevel(itemObject)
        end
    else
        if item.Stats then
            return item.Stats.Level
        else
            local levelOverride = (item.LevelOverride and item.LevelOverride > 0) and item.LevelOverride or -1
            if levelOverride > -1 then
                return levelOverride
            else
                return Ext.GetStat(item.StatsId)["Act part"] or 1
            end
        end
    end
    return 1
end

---@param statName string The item stat.
---@return string[]
function GameHelpers.Item.GetRootTemplatesForStat(statName)
    local matches = {}
    local stat = Ext.GetStat(statName)
    if stat then
        if GameHelpers.Item.IsObject(statName) then
            return stat.RootTemplate
        elseif stat.ItemGroup then
            local itemGroup = Ext.GetItemGroup(stat.ItemGroup)
            if itemGroup then
                for _,lgroup in pairs(itemGroup.LevelGroups) do
                    for _,root in pairs(lgroup.RootGroups) do
                        if not StringHelpers.IsNullOrEmpty(root.RootGroup) then
                            table.insert(matches, root.RootGroup)
                        end
                    end
                end
            end
        end
    end
    return matches
end

---@param template string The item root template.
---@param statType string The type of stat, ex. Weapon, Armor, Object.
---@return string[]
function GameHelpers.Item.GetStatsForRootTemplate(template, statType)
    local matches = {}
    local stats = {}
    if statType then
        stats = Ext.GetStatEntries(statType)
    end
    local isEquipment = statType == "Weapon" or statType == "Armor" or statType == "Shield"
    if isEquipment or not statType then
        local matchedgroups = {}
        for _,itemgroupName in pairs(Ext.GetStatEntries("ItemGroup")) do
            local itemGroup = Ext.GetItemGroup(itemgroupName)
            if itemGroup then
                for _,lgroup in pairs(itemGroup.LevelGroups) do
                    for _,root in pairs(lgroup.RootGroups) do
                        if root.RootGroup == template then
                            matchedgroups[itemgroupName] = true
                        end
                    end
                end
            end
        end
        if not statType then
            Common.MergeTables(stats, Ext.GetStatEntries("Weapon"))
            Common.MergeTables(stats, Ext.GetStatEntries("Armor"))
            Common.MergeTables(stats, Ext.GetStatEntries("Shield"))
        end
        for _,statName in pairs(stats) do
            if matchedgroups[Ext.StatGetAttribute(statName, "ItemGroup")] == true then
                table.insert(matches, statName)
            end
        end
    end
    if not isEquipment then
        if not statType then
            stats = {}
            Common.MergeTables(stats, Ext.GetStatEntries("Object"))
            Common.MergeTables(stats, Ext.GetStatEntries("Potion"))
        end
        for _,statName in pairs(stats) do
            if Ext.StatGetAttribute(statName, "RootTemplate") == template then
                table.insert(matches, statName)
            end
        end
    end
    return matches
end

local function WithinLevelRange(targetMin, targetMax, compareMin, compareMax)
    return ((targetMin == 0 or compareMin == 0) or compareMin >= targetMin) and ((targetMax == 0 or compareMax == 0) or compareMax >= targetMax)
end

---@param itemGroupId string
---@param minLevel integer
---@param maxLevel integer
---@param fallbackRarity string If any rarity is supported, use this rarity.
---@return integer,string,ItemRootGroup[]|nil
function GameHelpers.Item.GetSupportedGenerationValues(itemGroupId, minLevel, maxLevel, fallbackRarity)
    local rarity = "Common"
    local rootGroups = nil
    local level = minLevel
    local group = Ext.GetItemGroup(itemGroupId)
    if group then
        for i,v in pairs(group.LevelGroups) do
            if WithinLevelRange(v.MinLevel, v.MaxLevel, minLevel, maxLevel) then
                if v.Name == "All" then
                    if v.MinLevel == 0 or v.MaxLevel == 0 then
                        level = minLevel
                    else
                        level = math.max(1, math.max(v.MinLevel, v.MaxLevel))
                    end
                    return level,fallbackRarity,v.RootGroups
                else
                    local rarityVal = Data.ItemRarity[v.Name]
                    local lastRarityVal = Data.ItemRarity[rarity]
                    if rarityVal > lastRarityVal then
                        level = math.max(1, math.max(v.MinLevel, v.MaxLevel))
                        rarity = v.Name
                        rootGroups = v.RootGroups
                    end
                end
            end
        end
    end
    if rarity == "" then
        rarity = "Common"
    end
    return level,rarity,rootGroups
end

---Creates an item by stat, provided it has an ItemGroup set (for equipment).
---@param statName string
---@param creationProperties ItemDefinition|nil
---@return string,EsvItem
function GameHelpers.Item.CreateItemByStat(statName, creationProperties, ...)
    local properties = creationProperties or {}
    if type(creationProperties) == "boolean" then
        local args = {...}
        if #args > 0 and type(args[1]) == "table" then
            properties = args[1]
        end
    end
    ---@type StatEntryWeapon|StatEntryArmor|StatEntryShield|StatEntryObject|StatEntryPotion
    local stat = nil
    local statType = ""
    local level = properties and properties.StatsLevel or 1
    local generationLevel = properties and properties.GenerationLevel or level
    local targetRarity = properties and properties.ItemType or "Common"
    local generatedRarity = properties and properties.GenerationItemType or targetRarity
    local rootTemplate = properties and properties.RootTemplate or nil
    local itemGroup = nil

    if type(statName) == "string" then
        stat = Ext.GetStat(statName, level)
        statType = NRD_StatGetType(statName)
    else
        stat = statName
        statType = NRD_StatGetType(stat.Name)
    end

    if stat and stat.Unique == 1 then
        targetRarity = "Unique"
    elseif properties then
        if properties.ItemType then
            targetRarity = properties.ItemType
        elseif properties.Rarity then
            targetRarity = properties.Rarity
        end
    end

    if level == nil or level <= 0 then
        level = GameHelpers.Character.GetHighestPlayerLevel() or 1
    end
    
    local hasGeneratedStats = false
    if properties and properties.HasGeneratedStats ~= nil then
        hasGeneratedStats = properties.HasGeneratedStats
    end

    if stat and (statType ~= "Object" and statType ~= "Potion") then
        if not StringHelpers.IsNullOrWhitespace(stat.ItemGroup) then
            itemGroup = stat.ItemGroup
            local rootGroups = nil
            generationLevel,generatedRarity,rootGroups = GameHelpers.Item.GetSupportedGenerationValues(itemGroup, generationLevel, 0, generatedRarity)
            if not rootTemplate and (rootGroups and #rootGroups > 0) then
                rootTemplate = rootGroups[1].RootGroup
            end
        end
    end

    if rootTemplate == nil then
        if (statType == "Object" or statType == "Potion") then
            if stat.RootTemplate ~= nil and stat.RootTemplate ~= "" then
                rootTemplate = stat.RootTemplate
            end
        end
    end

    if rootTemplate ~= nil then
        local constructor = Ext.CreateItemConstructor(rootTemplate)
        ---@type ItemDefinition
        local props = constructor[1]
        props.GMFolding = false

        props.RootTemplate = rootTemplate
        props.OriginalRootTemplate = rootTemplate
        props.GenerationStatsId = stat.Name
        props.HasGeneratedStats = hasGeneratedStats
        props.StatsLevel = level
        props.ItemType = targetRarity

        if properties and type(properties) == "table" then
            for k,v in pairs(properties) do
                if itemConstructorProps[k] == true then
                    props[k] = v
                end
            end
        end

        props.GenerationLevel = generationLevel
        props.GenerationItemType = generatedRarity

        local newItem = constructor:Construct()
        if newItem then
            newItem = Ext.GetItem(newItem.Handle)
            if not hasGeneratedStats then
                if properties.IsIdentified then
                    NRD_ItemSetIdentified(newItem.MyGuid, 1)
                end
                if properties.StatsLevel then
                    ItemLevelUpTo(newItem.MyGuid, properties.StatsLevel)
                end
            end
            InvokeListenerCallbacks(Listeners.TreasureItemGenerated, newItem, statName)
            return newItem.MyGuid,newItem
        end
    end
    return nil
end

---@param template string
---@param setProperties ItemDefinition|nil
---@return EsvItem
function GameHelpers.Item.CreateItemByTemplate(template, setProperties)
    local constructor = Ext.CreateItemConstructor(template)
    ---@type ItemDefinition
    local props = constructor[1]
    props:ResetProgression()
    -- if type(template) == "String" then
    --     props.RootTemplate = template
    --     props.OriginalRootTemplate = template
    --     props.GenerationStatsId = "WPN_Sword_1H"
    --     props.StatsLevel = 1
    --     props.GenerationLevel = 1
    -- end
    if setProperties then
        for k,v in pairs(setProperties) do
            if itemConstructorProps[k] then
                props[k] = v
            else
                fprint(LOGLEVEL.WARNING, "[LeaderLib:GameHelpers.Item.CreateItemByTemplate] Property %s doesn't exist for ItemDefinition", k)
            end
        end
    end
    local item = constructor:Construct()
    if item ~= nil then
        item = Ext.GetItem(item.Handle)
        InvokeListenerCallbacks(Listeners.TreasureItemGenerated, item)
        return item
    else
        Ext.PrintError(string.format("[LeaderLib:GameHelpers.Item.CreateItemByTemplate] Error constructing item when invoking Construct() - Returned item is nil for template %s.", template))
    end
    return nil
end

---@param item EsvItem|string
---@param setProperties ItemDefinition|nil
---@param addDeltaMods string[]|nil An optional array of deltamods to add to the ItmeDefinition deltamods. The deltamod is checked for before it gets added.
---@return EsvItem
function GameHelpers.Item.Clone(item, setProperties, addDeltaMods)
    local constructor = Ext.CreateItemConstructor(item)
    ---@type ItemDefinition
    local props = constructor[1]

    local level = GameHelpers.Item.GetItemLevel(item)
    props.StatsLevel = level
    props.GenerationLevel = level

    if type(item) == "string" then
        props.RootTemplate = item
        props.OriginalRootTemplate = item
        local stats = GameHelpers.Item.GetStatsForRootTemplate(item)
        if stats and #stats > 0 then
            props.GenerationStatsId = stats[1]
        end
    elseif item.StatsId then
        if item.RootTemplate then
            props.RootTemplate = item.RootTemplate.Id
            props.OriginalRootTemplate = item.RootTemplate.Id
        else
            local templates = GameHelpers.Item.GetRootTemplatesForStat(item.StatsId)
            if templates and #templates > 0 then
                props.RootTemplate = templates[1]
                props.OriginalRootTemplate = templates[1]
            end
        end
        props.GenerationStatsId = item.StatsId
    end
    --props:ResetProgression(props)
    if setProperties then
        for k,v in pairs(setProperties) do
            if itemConstructorProps[k] then
                props[k] = v
            else
                fprint(LOGLEVEL.WARNING, "[LeaderLib:GameHelpers.Item.Clone] Property %s doesn't exist for ItemDefinition", k)
            end
        end
    end
    if addDeltaMods then
        local originalDeltaMods = {}
        for i,v in pairs(props.DeltaMods) do
            originalDeltaMods[#originalDeltaMods+1] = v
        end
        for i=1,#addDeltaMods do
            if not Common.TableHasValue(originalDeltaMods, addDeltaMods[i]) then
                originalDeltaMods[#originalDeltaMods+1] = addDeltaMods[i]
            end
        end
        props.DeltaMods = originalDeltaMods
    end
    --constructor[1] = props
    local clone = constructor:Construct()
    if clone then
        clone = Ext.GetItem(clone.Handle)
        InvokeListenerCallbacks(Listeners.TreasureItemGenerated, clone, item.StatsId or clone.StatsId)
        return item
    else
        error("Error cloning item.", 2)
    end
end

---@param char string
---@param item string
---@return string|nil
function GameHelpers.Item.GetEquippedSlot(char, item)
    for i,slot in Data.EquipmentSlots:Get() do
        local slotItem = StringHelpers.GetUUID(CharacterGetEquippedItem(char, slot))
        if slotItem ~= nil and slotItem == StringHelpers.GetUUID(item) then
            return slot
        end
    end
    return nil
end

---@param char EsvCharacter|string
---@param slot string
---@return EsvItem|nil
function GameHelpers.Item.GetItemInSlot(char, slot)
    local uuid = CharacterGetEquippedItem(GameHelpers.GetUUID(char), slot)
    if not StringHelpers.IsNullOrEmpty(uuid) then
        return Ext.GetItem(uuid)
    end
    return nil
end

---@param char string
---@param template string
---@return string|nil
function GameHelpers.Item.GetEquippedTemplateSlot(char, template)
    template = StringHelpers.GetUUID(template)
    for i,slot in Data.EquipmentSlots:Get() do
        local slotItem = StringHelpers.GetUUID(CharacterGetEquippedItem(char, slot))
        if slotItem ~= nil then
            if StringHelpers.GetUUID(GetTemplate(slotItem)) == template then
                return slot,slotItem
            end
        end
    end
    return nil
end

---@param char string
---@param tag string
---@return string|nil
function GameHelpers.Item.GetEquippedTaggedItemSlot(char, tag)
    for i,slot in Data.EquipmentSlots:Get() do
        local slotItem = StringHelpers.GetUUID(CharacterGetEquippedItem(char, slot))
        if slotItem ~= nil and IsTagged(slotItem, tag) == 1 then
            return slot,slotItem
        end
    end
    return nil
end

function EquipInSlot(char, item, slot)
    if ObjectExists(item) == 1 and ObjectExists(char) == 1 then
        NRD_CharacterEquipItem(char, item, slot, 0, 0, 1, 1)
    end
end

GameHelpers.Item.EquipInSlot = EquipInSlot

---@param char UUID|EsvCharacter
---@param item UUID|EsvItem
function GameHelpers.Item.ItemIsEquipped(char, item)
    local itemObj = GameHelpers.GetItem(item)
    if itemObj ~= nil then
        local slot = itemObj.Slot
        if slot <= 13 then -- 13 is the Overhead slot
            return true
        end
    else
        char = GameHelpers.GetUUID(char)
        item = GameHelpers.GetUUID(item)
        if char and item then
            for i,slot in Data.EquipmentSlots:Get() do
                if CharacterGetEquippedItem(char, slot) == item then
                    return true
                end
            end
        end
    end
    return false
end

function GameHelpers.Item.ItemIsEquippedByCharacter(item)
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
function GameHelpers.Item.RemoveRunes(character, runeTemplates)
	for _,slotName in Data.VisibleEquipmentSlots:Get() do
		local item = CharacterGetEquippedItem(character, slotName)
		if not StringHelpers.IsNullOrEmpty(item) then
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
function GameHelpers.Item.HasTagEquipped(character, tag)
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

--- Removes an item in a slot, if one exists.
---@param character string
---@param slot string
---@param delete boolean Whether to destroy the item or simply unequip it.
---@return boolean
function GameHelpers.Item.UnequipItemInSlot(character, slot, delete)
    local item = CharacterGetEquippedItem(character, slot)
    if item ~= nil then
        CharacterUnequipItem(character, item)
        if delete == true and ObjectIsGlobal(item) == 0 then
            ItemRemove(item)
        end
    end
end

---Builds a list of items with a specific tag.
---@param character string
---@param tag string
---@param asArray boolean Optional param to make the table returned just be an array of UUIDs, instead of <slot,UUID>
---@return table<string,UUID>
function GameHelpers.Item.FindTaggedEquipment(character, tag, asArray)
    local items = {}
	for _,slotName in Data.VisibleEquipmentSlots:Get() do
		local item = CharacterGetEquippedItem(character, slotName)
		if item ~= nil and GameHelpers.ItemHasTag(item, tag) then
            if asArray then
                items[#items+1] = item
            else
                items[slotName] = item
            end
		end
	end
	return items
end

---Gets an array of items with specific tag(s) on a character.
---@param character string|EsvCharacter
---@param tag string|string[]
---@param asEsvItem boolean
---@return string[]|EsvItem[]
function GameHelpers.Item.FindTaggedItems(character, tag, asEsvItem)
    local items = {}
    character = GameHelpers.GetCharacter(character)
    if character then
        for i,v in pairs(character:GetInventoryItems()) do
            local item = Ext.GetItem(v)
            if GameHelpers.ItemHasTag(item, tag) then
                if asEsvItem then
                    items[#items+1] = item
                else
                    items[#items+1] = v
                end
            end
        end
    end
	return items
end

---Gets an array of items with specific tag(s) on a character.
---@param item EsvItem|UUID|NETID
---@return string[]|EsvItem[]
function GameHelpers.Item.GetTags(item)
    local item = GameHelpers.GetItem(item)
    local tags = {}
    if item then
        local tagDict = {}
        for _,v in pairs(item:GetTags()) do
            if not tagDict[v] then
                tagDict[v] = true
            end
        end
        if not GameHelpers.Item.IsObject(item) then
            local statTags = StringHelpers.Split(item.Stats.Tags, ";")
            for _,v in pairs(statTags) do
                if not tagDict[v] then
                    tagDict[v] = true
                end
            end
        end
        for tag,_ in pairs(tagDict) do
            table.insert(tags, tag)
        end
        table.sort(tags)
    end
	return tags
end

--- Checks if an item is locked from unequip.
---@param uuid string
---@return boolean
function GameHelpers.Item.ItemIsLocked(uuid)
    local item = Ext.GetItem(uuid)
    if item ~= nil then
        return item.UnEquipLocked
    end
    return false
end

local function ItemIsLockedQRY(item)
    if GameHelpers.Item.ItemIsLocked(item) then
        return 1
    end
    return 0
end
Ext.NewQuery(GameHelpers.Item.ItemIsLocked, "LeaderLib_Ext_QRY_ItemIsLocked", "[in](ITEMGUID)_Item, [out](INTEGER)_Locked")

function ContainerHasContents(uuid)
    local item = uuid
    if type(uuid) == "string" then
        item = Ext.GetItem(uuid)
    end
    if item ~= nil and item.GetInventoryItems ~= nil then
        local contents = item:GetInventoryItems()
        return contents ~= nil and #contents > 0
    end
    return false
end

GameHelpers.Item.ContainerHasContents = ContainerHasContents