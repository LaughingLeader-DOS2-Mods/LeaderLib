if GameHelpers.Item == nil then
    ---@class GameHelpers.Item
    GameHelpers.Item = {}
end

local _ISCLIENT = Ext.IsClient()
local _EXTVERSION = Ext.Utils.Version()
local _type = type

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

---@deprecated
---Clone an item for a character.  
---🔨**Server-Only**🔨  
---@param char string
---@param item string
---@param completion_event string
---@param autolevel string
function GameHelpers.Item.CloneItemForCharacter(char, item, completion_event, autolevel)
    if not _ISCLIENT then
        local autolevel_enabled = autolevel == "Yes"
        NRD_ItemCloneBegin(item)
        local cloned = NRD_ItemClone()
        if autolevel_enabled then
            local level = CharacterGetLevel(char)
            ItemLevelUpTo(cloned,level)
        end
        CharacterItemSetEvent(char, cloned, completion_event)
    end
end

---@param item ItemParam
---@return integer
function GameHelpers.Item.GetItemLevel(item)
    local item = GameHelpers.GetItem(item)
    if item then
        if not GameHelpers.Item.IsObject(item) and item.Stats then
            return item.Stats.Level
        else
            local levelOverride = (item.LevelOverride and item.LevelOverride > 0) and item.LevelOverride or -1
            if levelOverride > -1 then
                return levelOverride
            elseif item.StatsFromName and item.StatsFromName.StatsEntry then
                return item.StatsFromName.StatsEntry["Act part"] or 1
            end
        end
    end
    return 1
end

---@param statName string The item stat.
---@return string[]
function GameHelpers.Item.GetRootTemplatesForStat(statName)
    local matches = {}
    local stat = Ext.Stats.Get(statName)
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
---@param statType string|nil The type of stat, ex. Weapon, Armor, Object.
---@return string[]
function GameHelpers.Item.GetStatsForRootTemplate(template, statType)
    local matches = {}
    local stats = {}
    if statType then
        stats = Ext.Stats.GetStats(statType)
    end
    local isEquipment = statType == "Weapon" or statType == "Armor" or statType == "Shield"
    if isEquipment or not statType then
        local matchedgroups = {}
        for _,itemgroupName in pairs(Ext.Stats.GetStats("ItemGroup")) do
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
            Common.MergeTables(stats, GameHelpers.Stats.GetStats("Weapon"))
            Common.MergeTables(stats, GameHelpers.Stats.GetStats("Armor"))
            Common.MergeTables(stats, GameHelpers.Stats.GetStats("Shield"))
        end
        for i=1, #stats do
            local statName = stats[i]
            if matchedgroups[Ext.StatGetAttribute(statName, "ItemGroup")] == true then
                table.insert(matches, statName)
            end
        end
    end
    if not isEquipment then
        if not statType then
            stats = {}
            Common.MergeTables(stats, GameHelpers.Stats.GetStats("Object"))
            Common.MergeTables(stats, GameHelpers.Stats.GetStats("Potion"))
        end
        for i=1, #stats do
            local statName = stats[i]
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
---🔨**Server-Only**🔨  
---@param statName string
---@param creationProperties ItemDefinition|nil
---@return string|nil itemGUID
---@return EsvItem|nil generatedItem
function GameHelpers.Item.CreateItemByStat(statName, creationProperties, ...)
    if _ISCLIENT then
        error("[GameHelpers.Item.CreateItemByStat] is server-side only.", 2)
    end
    local properties = creationProperties or {}
    if _type(creationProperties) == "boolean" then
        local args = {...}
        if #args > 0 and _type(args[1]) == "table" then
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

    if _type(statName) == "string" then
        stat = Ext.Stats.Get(statName, level)
        statType = GameHelpers.Stats.GetStatType(statName)
    else
        stat = statName
        statType = GameHelpers.Stats.GetStatType(stat.Name)
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

    local isObject = statType == "Object" or statType == "Potion"

    if stat and not isObject then
        if not StringHelpers.IsNullOrWhitespace(stat.ItemGroup) then
            itemGroup = stat.ItemGroup
            local rootGroups = nil
            generationLevel,generatedRarity,rootGroups = GameHelpers.Item.GetSupportedGenerationValues(itemGroup, generationLevel, 0, generatedRarity)
            if not rootTemplate and (rootGroups and #rootGroups > 0) then
                rootTemplate = rootGroups[1].RootGroup
            end
        end
    end

    if rootTemplate == nil and isObject and not StringHelpers.IsNullOrEmpty(stat.RootTemplate) then
        rootTemplate = stat.RootTemplate
    end

    if rootTemplate ~= nil then
        local constructor = Ext.CreateItemConstructor(rootTemplate)
        ---@type ItemDefinition
        local props = constructor[1]
        props.GMFolding = false

        props.RootTemplate = rootTemplate
        props.OriginalRootTemplate = rootTemplate
        props.StatsEntryName = stat.Name
        if not isObject then
            props.GenerationStatsId = stat.Name
            props.HasGeneratedStats = hasGeneratedStats
            props.StatsLevel = level
            props.ItemType = targetRarity
            props.GenerationLevel = generationLevel
            props.GenerationItemType = generatedRarity
        end

        --props.HasGeneratedStats = true
        --props.GenerationBoosts = {"Boost_Weapon_Status_Set_Petrify_Club"}

        if properties and _type(properties) == "table" then
            for k,v in pairs(properties) do
                if itemConstructorProps[k] == true then
                    props[k] = v
                end
            end
        end

        if isObject then
            props.HasGeneratedStats = false
            props.StatsLevel = stat.Level
        end

        local newItem = constructor:Construct()
        if newItem then
            newItem = GameHelpers.GetItem(newItem.Handle)
            if not hasGeneratedStats then
                if properties.IsIdentified then
                    NRD_ItemSetIdentified(newItem.MyGuid, 1)
                end
                if properties.StatsLevel then
                    ItemLevelUpTo(newItem.MyGuid, properties.StatsLevel)
                end
            end
            ---@type SubscribableEventInvokeResult<TreasureItemGeneratedEventArgs>
            local invokeResult = Events.TreasureItemGenerated:Invoke({Item=newItem, StatsId=statName, IsClone=false, ResultingItem=newItem})
            if invokeResult.ResultCode ~= "Error" then
                local nextItem = invokeResult.Args.ResultingItem
                if invokeResult.Results then
                    for i=1,#invokeResult.Results do
                        local replaceItem = invokeResult.Results[i]
                        if replaceItem and GameHelpers.Ext.ObjectIsItem(replaceItem) then
                            nextItem = replaceItem
                        end
                    end
                end
                if nextItem and nextItem.MyGuid ~= newItem.MyGuid then
                    if Ext.OsirisIsCallable then
                        ItemRemove(newItem.MyGuid)
                    end
                    newItem = nextItem
                end
            end
            return newItem.MyGuid,newItem
        end
    end
    return nil
end

---🔨**Server-Only**🔨  
---@param template string
---@param setProperties ItemDefinition|nil
---@return EsvItem
function GameHelpers.Item.CreateItemByTemplate(template, setProperties)
    if _ISCLIENT then
        error("[GameHelpers.Item.CreateItemByTemplate] is server-side only.", 2)
    end
    local constructor = Ext.CreateItemConstructor(template)
    ---@type ItemDefinition
    local props = constructor[1]
    props:ResetProgression()
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
        item = GameHelpers.GetItem(item.Handle)
        local statsId = GameHelpers.Item.GetItemStat(item)
        ---@type SubscribableEventInvokeResult<TreasureItemGeneratedEventArgs>
        local invokeResult = Events.TreasureItemGenerated:Invoke({Item=item, StatsId=statsId, IsClone=false, ResultingItem=item})
        if invokeResult.ResultCode ~= "Error" then
            local nextItem = invokeResult.Args.ResultingItem
            if invokeResult.Results then
                for i=1,#invokeResult.Results do
                    local replaceItem = invokeResult.Results[i]
                    if replaceItem and GameHelpers.Ext.ObjectIsItem(replaceItem) then
                        nextItem = replaceItem
                    end
                end
            end
            if nextItem and nextItem.MyGuid ~= item.MyGuid then
                if Ext.OsirisIsCallable then
                    ItemRemove(item.MyGuid)
                end
                item = nextItem
            end
        end
        return item
    else
        Ext.Utils.PrintError(string.format("[LeaderLib:GameHelpers.Item.CreateItemByTemplate] Error constructing item when invoking Construct() - Returned item is nil for template %s.", template))
    end
    return nil
end

---@class GameHelpers_Item_CloneOptions
---@field DeltaMods string[]|nil An optional array of deltamods to add to the ItmeDefinition deltamods. The deltamod is checked for before it gets added.
---@field CopyTags boolean|nil Copy all tags from the target item.
---@field InvokeEvent boolean|nil Invoke the LeaderLib event, Events.TreasureItemGenerated. This allows mods subscribed to this event to alter the item.

---🔨**Server-Only**🔨  
---@param item ItemParam The target item to clone.
---@param setProperties ItemDefinition|nil
---@param opts GameHelpers_Item_CloneOptions|nil Optional table of additional options.
---@return EsvItem
function GameHelpers.Item.Clone(item, setProperties, opts)
    if _ISCLIENT then
        error("[GameHelpers.Item.Clone] is server-side only.", 2)
    end
    local item = GameHelpers.GetItem(item)
    if not item then
        error("item parameter is not a valid item.", 2)
    end

    ---@type GameHelpers_Item_CloneOptions
    opts = opts or {}
    local constructor = Ext.CreateItemConstructor(item)
    ---@type ItemDefinition
    local props = constructor[1]

    local level = GameHelpers.Item.GetItemLevel(item)
    props.StatsLevel = level
    props.GenerationLevel = level

    if _type(item) == "string" then
        props.RootTemplate = item
        props.OriginalRootTemplate = item
        local stats = GameHelpers.Item.GetStatsForRootTemplate(item)
        if stats and #stats > 0 then
            props.GenerationStatsId = stats[1]
            props.StatsEntryName = stats[1]
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
        props.StatsEntryName = item.StatsId
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
    if _type(opts.DeltaMods) == "table" then
        local originalDeltaMods = {}
        for i,v in pairs(props.DeltaMods) do
            originalDeltaMods[#originalDeltaMods+1] = v
        end
        for i=1,#opts.DeltaMods do
            if not Common.TableHasValue(originalDeltaMods, opts.DeltaMods[i]) then
                originalDeltaMods[#originalDeltaMods+1] = opts.DeltaMods[i]
            end
        end
        props.DeltaMods = originalDeltaMods
    end
    --constructor[1] = props
    local clone = constructor:Construct()
    if clone then
        clone = GameHelpers.GetItem(clone.Handle)
        if opts.CopyTags then
            for _,v in pairs(item:GetTags()) do
                SetTag(clone.MyGuid, v)
            end
        end
        --TODO No way to get all of an object's flags currently.
        -- if opts.CopyFlags then
            
        -- end
        if opts.InvokeEvent then
            local cloneStatsId = GameHelpers.Item.GetItemStat(clone)
            ---@type SubscribableEventInvokeResult<TreasureItemGeneratedEventArgs>
            local invokeResult = Events.TreasureItemGenerated:Invoke({Item=clone, StatsId=cloneStatsId, IsClone=true, ResultingItem=clone})
            if invokeResult.ResultCode ~= "Error" then
                local nextItem = invokeResult.Args.ResultingItem
                if invokeResult.Results then
                    for i=1,#invokeResult.Results do
                        local replaceItem = invokeResult.Results[i]
                        if replaceItem and GameHelpers.Ext.ObjectIsItem(replaceItem) then
                            nextItem = replaceItem
                        end
                    end
                end
                if nextItem and nextItem.MyGuid ~= clone.MyGuid then
                    if Ext.OsirisIsCallable then
                        ItemRemove(clone.MyGuid)
                    end
                    clone = nextItem
                end
            end
        end
        return clone
    else
        error("Error cloning item.", 2)
    end
end

---@param character CharacterParam
---@param item ItemParam
---@return ItemSlot|nil
function GameHelpers.Item.GetEquippedSlot(character, item)
    local netid = GameHelpers.GetNetID(item)
    local character = GameHelpers.GetCharacter(character)
    for invItem in GameHelpers.Character.GetEquipment(character) do
        if invItem.NetID == netid then
            return Data.EquipmentSlots[GameHelpers.Item.GetSlot(invItem)]
        end
    end
    return nil
end

---@param character CharacterParam
---@param slot ItemSlot
---@return EsvItem|EclItem|nil
function GameHelpers.Item.GetItemInSlot(character, slot)
    character = GameHelpers.GetCharacter(character)
    fassert(character ~= nil, "'%s' is not a valid character", character)
    local slotIndex = Data.EquipmentSlots[slot]
    fassert(slotIndex ~= nil, "'%s' is not a valid slot name", slot)
    if not _ISCLIENT then
        ---@cast char EsvCharacter
        if _OSIRIS() then
            local itemGUID = CharacterGetEquippedItem(character.MyGuid, slot)
            if not StringHelpers.IsNullOrEmpty(itemGUID) then
                return GameHelpers.GetItem(itemGUID)
            end
        else
            for item in GameHelpers.Character.GetEquipment(character) do
                if GameHelpers.Item.GetSlot(item) == slotIndex then
                    return item
                end
            end
        end
    else
        ---@cast char EclCharacter
        return character:GetItemObjectBySlot(slot)
    end
    return nil
end

---@param character CharacterParam
---@param template string
---@return ItemSlot|nil
---@return EsvItem|EclItem|nil
function GameHelpers.Item.GetEquippedTemplateSlot(character, template)
    for item in GameHelpers.Character.GetEquipment(character) do
        local itemTemplate = GameHelpers.GetTemplate(item)
        if itemTemplate == template then
            return Data.EquipmentSlots[GameHelpers.Item.GetSlot(item)],item
        end
    end
    return nil
end

---Gets the first item with a matching tag, and the slot.
---@param character CharacterParam
---@param tag string|string[]
---@return ItemSlot|nil slot
---@return GUID|nil itemGUID
---@return EsvItem|EclItem|nil item
function GameHelpers.Item.GetEquippedTaggedItemSlot(character, tag)
    local char = GameHelpers.GetCharacter(character)
    fassert(char ~= nil, "'%s' is not a valid character", character)
    local tagType = _type(tag)
    fassert(tagType ~= "string" or tagType ~= "table", "'%s' is not a valid tag or table of tags", tag)
    for item in GameHelpers.Character.GetEquipment(character) do
        if GameHelpers.ItemHasTag(item, tag) then
            return GameHelpers.Item.GetSlot(item, true), item.MyGuid, item
        end
    end
    return nil
end

if not _ISCLIENT then

    ---🔨**Server-Only**🔨  
    ---@param character CharacterParam
    ---@param item ItemParam
    ---@param slot ItemSlot
    ---@return boolean
    function GameHelpers.Item.EquipInSlot(character, item, slot)
        if _OSIRIS() then
            local char = GameHelpers.GetUUID(character)
            local itemGUID = GameHelpers.GetUUID(item)
            if ObjectExists(itemGUID) == 1 and ObjectExists(char) == 1 then
                SetOnStage(itemGUID, 1)
                NRD_CharacterEquipItem(char, itemGUID, slot, 0, 0, 1, 1)
                return true
            end
        else
            fprint(LOGLEVEL.WARNING, "[GameHelpers.Item.EquipInSlot] NRD_CharacterEquipItem is not callable.")
        end
        return false
    end

    ---@deprecated
    ---@param character CharacterParam
    ---@param item ItemParam
    ---@param slot ItemSlot
    ---@return boolean
    EquipInSlot = function (character, item, slot)
        return GameHelpers.Item.EquipInSlot(character, item, slot)
    end

    ---Removes matching rune templates from items in any equipment slots.
    ---🔨**Server-Only**🔨  
    ---@param character CharacterParam
    ---@param runeTemplates table
    function GameHelpers.Item.RemoveRunes(character, runeTemplates)
        local char = GameHelpers.GetUUID(character)
        for item in GameHelpers.Character.GetEquipment(character) do
            for runeSlot=0,2,1 do
                local runeTemplate = ItemGetRuneItemTemplate(item.MyGuid, runeSlot)
                if runeTemplate ~= nil and runeTemplates[runeTemplate] == true then
                    local rune = ItemRemoveRune(char, item.MyGuid, runeSlot)
                    fprint(LOGLEVEL.TRACE, "[GameHelpers.Item.RemoveRunes] Removed rune (%s) from item (%s)[%s] for character (%s)", rune, item.DisplayName, runeSlot, char)
                end
            end
        end
    end

    ---@class GameHelpers.Item.GetRunes.RuneEntry
    ---@field RuneSlot integer The rune slot, starting at 0
    ---@field Stat StatEntryObject The rune object stat
    ---@field StatID string The rune object stat name
    ---@field Template GameObjectTemplate The object stat's root template
    ---@field TemplateGUID GUID The object stat's root template GUID
    ---@field BoostStat StatEntryWeapon|StatEntryArmor The active rune boost stat for this item
    ---@field BoostStatID string The active rune boost stat name for this item
    ---@field BoostStatAttribute "RuneEffectWeapon"|"RuneEffectAmulet"|"RuneEffectUpperbody"

    local _RuneAccessorySlot = {
        Amulet = true,
        Ring = true,
        Ring2 = true,
        Belt = true,
    }

    ---Get inserted runes for an item.  
    ---🔨**Server-Only**🔨  
    ---@param item EsvItem
    ---@return {[1]:GameHelpers.Item.GetRunes.RuneEntry|nil,[2]:GameHelpers.Item.GetRunes.RuneEntry|nil,[3]:GameHelpers.Item.GetRunes.RuneEntry|nil} insertedRunes
    function GameHelpers.Item.GetRunes(item)
        if not item or not item.Stats then
            return {}
        end
        local runes = {}
        local runeSlot = 0
        local itemType = item.Stats.ItemType
        for i=2,4 do
            runeSlot = runeSlot + 1
            local entry = item.Stats.DynamicStats[i]
            if entry and not StringHelpers.IsNullOrEmpty(entry.BoostName) then
                local runeStat = Ext.Stats.Get(entry.BoostName, nil, false)
                if runeStat then
                    local template = Ext.Template.GetRootTemplate(runeStat.RootTemplate)
                    local activeBoostStat = ""
                    local activeBoostStatAttribute = ""
                    if itemType == "Weapon" then
                        activeBoostStat = runeStat.RuneEffectWeapon
                        activeBoostStatAttribute = "RuneEffectWeapon"
                    elseif itemType == "Armor" then
                        if _RuneAccessorySlot[item.Stats.ItemSlot] then
                            activeBoostStat = runeStat.RuneEffectAmulet
                            activeBoostStatAttribute = "RuneEffectAmulet"
                        else
                            activeBoostStat = runeStat.RuneEffectUpperbody
                            activeBoostStatAttribute = "RuneEffectUpperbody"
                        end
                    end

                    runes[runeSlot] = {
                        RuneSlot=runeSlot-1,
                        Stat=runeStat,
                        StatID=runeStat.Name,
                        Template=template,
                        TemplateGUID=runeStat.RootTemplate,
                        BoostStat = not StringHelpers.IsNullOrWhitespace(activeBoostStat) and Ext.Stats.Get(activeBoostStat, nil, false),
                        BoostStatID = activeBoostStat,
                        BoostStatAttribute = activeBoostStatAttribute,
                    }
                end
            end
        end
        return runes
    end

    ---Removes an item in a slot, if one exists.
    ---🔨**Server-Only**🔨  
    ---@param character CharacterParam
    ---@param slot ItemSlot
    ---@param delete boolean|nil Whether to destroy the item or simply unequip it.
    ---@param bypassLock boolean|nil Forcefully unequiped items that are locked via ItemLockUnEquip.
    ---@return boolean
    function GameHelpers.Item.UnequipItemInSlot(character, slot, delete, bypassLock)
        character = GameHelpers.GetCharacter(character)
        local item = GameHelpers.Item.GetItemInSlot(character, slot)
        if item ~= nil then
            if bypassLock == true or not GameHelpers.Item.ItemIsLocked(item) then
                ItemLockUnEquip(item.MyGuid, 0)
                CharacterUnequipItem(character.MyGuid, item.MyGuid)
                if delete == true and not item.Global then
                    ItemRemove(item.MyGuid)
                end
            end
        end
    end

    local function ItemIsLockedQRY(item)
        if GameHelpers.Item.ItemIsLocked(item) then
            return 1
        end
        return 0
    end
    Ext.NewQuery(ItemIsLockedQRY, "LeaderLib_Ext_QRY_ItemIsLocked", "[in](ITEMGUID)_Item, [out](INTEGER)_Locked")
end

---@param character CharacterParam
---@param item ItemParam
---@return boolean
function GameHelpers.Item.ItemIsEquipped(character, item)
    character = GameHelpers.GetUUID(character)
    item = GameHelpers.GetItem(item)
    if character and item then
        --[[ if Ext.Utils.IsValidHandle(item.OwnerHandle) then
            local owner = GameHelpers.GetCharacter(item.OwnerHandle)
            local slot = GameHelpers.Item.GetSlot(item, true)
            if Data.EquipmentSlots[slot] and owner.MyGuid == charGUID then
                return true
            end
        end ]]
        --Sometimes the item can have no owner set, despite being equipped, so check the character's currently equipped items instead of the item's owner / current slot
        local statSlot = item.Stats and item.Stats.ItemSlot or nil
        if statSlot then
            local equippedItem = GameHelpers.Item.GetItemInSlot(character, statSlot)
            if equippedItem and equippedItem.MyGuid == item.MyGuid then
                return true
            end
            --Check offhand
            if statSlot == "Weapon" then
                local equippedItem = GameHelpers.Item.GetItemInSlot(character, "Shield")
                if equippedItem and equippedItem.MyGuid == item.MyGuid then
                    return true
                end
            end
        end
    end
    return false
end

---@param item ItemParam
---@return boolean isEquipped
---@return EsvCharacter|EclCharacter|nil character
function GameHelpers.Item.ItemIsEquippedByCharacter(item)
    local itemObj = GameHelpers.GetItem(item)
    if itemObj then
        if Ext.Utils.IsValidHandle(itemObj.OwnerHandle) then
            local user = GameHelpers.GetCharacter(itemObj.OwnerHandle)
            if user then
                return true,user
            end
        end
    end
    return false
end

---@deprecated
---Checks if a character has an item equipped with a specific tag.
---@param character string
---@param tag string
---@return boolean
function GameHelpers.Item.HasTagEquipped(character, tag)
	return GameHelpers.CharacterOrEquipmentHasTag(character, tag)
end

---@overload fun(character:CharacterParam, tag:string|string[]):table<ItemSlot,EsvItem|EclItem>
---Builds a list of items with a specific tag.
---@param character CharacterParam
---@param tag string|string[]
---@param asArray boolean|nil Optional param to make the table returned just be an array of UUIDs, instead of <slot,UUID>
---@return EsvItem[]|EclItem[] items
function GameHelpers.Item.FindTaggedEquipment(character, tag, asArray)
    local items = {}
    for item in GameHelpers.Character.GetEquipment(character) do
        if GameHelpers.ItemHasTag(item, tag) then
            if asArray then
                items[#items+1] = item
            else
                items[Data.EquipmentSlots[GameHelpers.Item.GetSlot(item)]] = item
            end
        end
    end
	return items
end

---Gets an array of items with specific tag(s) on a character.
---@param character CharacterParam
---@param tag string|string[]
---@param asEsvItem boolean
---@return string[]|EsvItem[]
function GameHelpers.Item.FindTaggedItems(character, tag, asEsvItem)
    local items = {}
    character = GameHelpers.GetCharacter(character)
    if character then
        for i,v in pairs(character:GetInventoryItems()) do
            local item = GameHelpers.GetItem(v)
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

---@deprecated
---Gets an item's tags in a table.
---@param item ItemParam
---@return string[]
function GameHelpers.Item.GetTags(item)
    return GameHelpers.GetItemTags(item, false, false)
end

--- Checks if an item is locked from unequip.
---@param item ItemParam
---@return boolean
function GameHelpers.Item.ItemIsLocked(item)
    local item = GameHelpers.GetItem(item)
    if item ~= nil then
        return item.UnEquipLocked
    end
    return false
end

---@deprecated
---@param uuid UUID
---@return boolean
function ContainerHasContents(uuid)
    local item = GameHelpers.GetItem(uuid)
    if item ~= nil and item.GetInventoryItems ~= nil then
        local contents = item:GetInventoryItems()
        return contents ~= nil and #contents > 0 or false
    end
    return false
end

GameHelpers.Item.ContainerHasContents = ContainerHasContents

---Returns true if the item's stat is an Object type.
---@param item ItemParam
---@return boolean
function GameHelpers.Item.IsObject(item)
	local t = _type(item)
	if t == "userdata" then
		if GameHelpers.Ext.ObjectIsItem(item) then
			if Data.ObjectStats[item.StatsId] or item.ItemType == "Object" then
				return true
			end
			if not item.Stats then
				return true
			end
		end
	elseif t == "string" then
		return Data.ObjectStats[item] == true
	end
	return false
end

---Returns true if the item can be destroyed (not already destroyed, not a story item, not indestructible).
---@param item ItemParam
---@return boolean
function GameHelpers.Item.IsDestructible(item)
	local item = GameHelpers.GetItem(item)
    if item then
        if GameHelpers.ObjectIsDead(item) then
            return false
        end
        local stat = item.StatsFromName
        --Indestructible chests etc
        if stat and stat.StatsEntry and stat.StatsEntry.Vitality <= -1 then
            return false
        end
        if item.StoryItem or item.Invulnerable or item.Invulnerable2 or (not _ISCLIENT and item.Destroy) then
            return false
        end
        return true
    end
    return false
end

---Returns true if the item can cast a skill, like a scroll.
---@param item ItemParam
---@return boolean
function GameHelpers.Item.HasConsumableSkillAction(item)
    local item = GameHelpers.GetItem(item)
    if item then
        if GameHelpers.Item.IsObject(item) then
			if _EXTVERSION >= 56 then
                for _,v in pairs(item.RootTemplate.OnUsePeaceActions) do
                    if v.Type == "UseSkill" and v.Consume == true and not StringHelpers.IsNullOrEmpty(v.SkillID) then
                        return true
                    end
                end
            else
                return item:HasTag("SCROLL")
            end
		end
    end
	return false
end

---@param item ItemParam
---@param returnNilUUID boolean|nil Return a null GUID instead of nil, if no owner is found.
---@return EsvCharacter|EsvItem|EclCharacter|EclItem|nil
function GameHelpers.Item.GetOwner(item, returnNilUUID)
	local item = GameHelpers.GetItem(item)
	if item then
        if _ISCLIENT then
            return item:GetOwnerCharacter()
        end
        ---@cast item EsvItem

		if Ext.Utils.IsValidHandle(item.OwnerHandle) then
			local object = GameHelpers.TryGetObject(item.OwnerHandle)
			if object then
				return object
			end
		end
        
        --InventoryParentHandle on the client?
		if Ext.Utils.IsValidHandle(item.ParentInventoryHandle) then
			local object = GameHelpers.TryGetObject(item.ParentInventoryHandle)
			if object then
				return object
			end
		end
	end
	if returnNilUUID then
		return StringHelpers.NULL_UUID
	end
	return nil
end

---@param item ItemParam
---@param weaponType string|string[]
---@return boolean
function GameHelpers.Item.IsWeaponType(item, weaponType)
	if _type(item) == "table" then
		local hasMatch = false
		for i,v in pairs(item) do
			if GameHelpers.Item.IsWeaponType(v, weaponType) then
				hasMatch = true
			end
		end
		return hasMatch
	else
		if item == nil then
			return false
		end
		if GameHelpers.Ext.ObjectIsItem(item) and not GameHelpers.Item.IsObject(item) then
			item = item.Stats
		end
		if not GameHelpers.Ext.ObjectIsStatItem(item) then
			return false
		end
		local t = _type(weaponType)
		if t == "table" then
			for _,v in pairs(weaponType) do
				if GameHelpers.Item.IsWeaponType(item, v) then
					return true
				end
			end
		elseif t == "string" then
			if item.WeaponType == weaponType then
				return true
			end
		end
	end
	return false
end

---@param item EsvItem|EclItem
---@param asName boolean|nil Return the slot as a name, such as "Weapon".
---@return integer|ItemSlot slotIndexOrName
function GameHelpers.Item.GetSlot(item, asName)
    local slot = -1
    local item = GameHelpers.GetItem(item)
    if item then
        if not _ISCLIENT then
            slot = item.Slot
        elseif item.CurrentSlot then
           slot = item.CurrentSlot
        end
        if asName and Data.EquipmentSlots[slot] then
            return Data.EquipmentSlots[slot]
        end
    end
    return slot
end

---@param item ItemParam
---@param inKeyValueFormat boolean|nil If true, the table is returned as table<skill,boolean>
---@param consumableOnly boolean|nil
---@return string[]|table<string,boolean> skills
---@return {IsSkillbook:boolean, IsConsumable:boolean, CastsSkill:boolean} itemParams
function GameHelpers.Item.GetUseActionSkills(item, inKeyValueFormat, consumableOnly)
	local skills = {}
    local itemParams = {
        IsSkillbook = false,
        IsConsumable = false,
        CastsSkill = false
    }
	if _EXTVERSION >= 56 then
        item = GameHelpers.GetItem(item)
		if item and item.RootTemplate and item.RootTemplate.OnUsePeaceActions then
			for _,v in pairs(item.RootTemplate.OnUsePeaceActions) do
                if v.Type == "SkillBook" then
                    itemParams.IsSkillbook = true
                elseif v.Type == "UseSkill" then
                    itemParams.CastsSkill = true
                end
                if (v.Type == "UseSkill" or v.Type == "SkillBook") and v.Consume then
                    itemParams.IsConsumable = true
                end

				if (v.Type == "UseSkill" or v.Type == "SkillBook") and not StringHelpers.IsNullOrWhitespace(v.SkillID)
                and (not consumableOnly or v.Consume == true) then
                    if not inKeyValueFormat then
                        skills[#skills+1] = v.SkillID
                    else
                        skills[v.SkillID] = true
                    end
				end
			end
		end
	end
    return skills,itemParams
end

---Get all the skills that an item grants when equipped in a dictionary-format table.
---@param item ItemParam
---@return table<string,boolean> skills
function GameHelpers.Item.GetEquippedSkills(item)
	local skills = {}
    item = GameHelpers.GetItem(item)
    if item and item.Stats then
        if not StringHelpers.IsNullOrEmpty(item.Stats.Skills) then
            for _,v in pairs(StringHelpers.Split(item.Stats.Skills, ";")) do
                skills[v] = true
            end
        end
        for _,v in pairs(item.Stats.DynamicStats) do
            if not StringHelpers.IsNullOrEmpty(v.Skills) then
                for _,v in pairs(StringHelpers.Split(v.Skills, ";")) do
                    skills[v] = true
                end
            end
        end
    end
    return skills
end

---@param item ItemParam
---@return string
function GameHelpers.Item.GetItemStat(item)
	item = GameHelpers.GetItem(item)
    if item then
        if item.StatsId and not Data.ItemRarity[item.StatsId] then
            return item.StatsId
        end
        if not GameHelpers.Item.IsObject(item) and item.Stats then
            return item.Stats.Name
        end
    end
    return ""
end