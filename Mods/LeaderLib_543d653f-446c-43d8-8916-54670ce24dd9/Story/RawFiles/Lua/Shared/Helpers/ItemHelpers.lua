if GameHelpers.Item == nil then
    GameHelpers.Item = {}
end

local _ISCLIENT = Ext.IsClient()
local _EXTVERSION = Ext.Version()

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
---[Server]
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
---[Server]
---@param statName string
---@param creationProperties ItemDefinition|nil
---@return string,EsvItem
function GameHelpers.Item.CreateItemByStat(statName, creationProperties, ...)
    if _ISCLIENT then
        error("[GameHelpers.Item.CreateItemByStat] is server-side only.", 2)
    end
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

---[Server]
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

---[Server]
---@param item ItemParam
---@param setProperties ItemDefinition|nil
---@param addDeltaMods string[]|nil An optional array of deltamods to add to the ItmeDefinition deltamods. The deltamod is checked for before it gets added.
---@return EsvItem
function GameHelpers.Item.Clone(item, setProperties, addDeltaMods)
    if _ISCLIENT then
        error("[GameHelpers.Item.Clone] is server-side only.", 2)
    end
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

---@param character EclCharacter|EsvCharacter|UUID|NETID
---@param item ItemParam
---@return ItemSlot|nil
function GameHelpers.Item.GetEquippedSlot(character, item)
    local netid = GameHelpers.GetNetID(item)
    local character = GameHelpers.GetCharacter(character)
    for invItem in GameHelpers.Character.GetEquipment(character) do
        if invItem.NetID == netid then
            return Data.EquipmentSlotNames[invItem.Slot]
        end
    end
    return nil
end

---@param character EclCharacter|EsvCharacter|UUID|NETID
---@param slot ItemSlot
---@return EsvItem|EclItem|nil
function GameHelpers.Item.GetItemInSlot(character, slot)
    local char = GameHelpers.GetCharacter(character)
    fassert(char ~= nil, "'%s' is not a valid character", character)
    local slotIndex = Data.EquipmentSlotNames[slot]
    fassert(slotIndex ~= nil, "'%s' is not a valid slot name", slot)
    local items = char:GetInventoryItems()
	local count = math.min(#items, 14)
	if slotIndex <= count then
        return Ext.GetItem(items[slotIndex])
    end
    return nil
end

---@param character EclCharacter|EsvCharacter|UUID|NETID
---@param template string
---@return ItemSlot|nil
---@return EsvItem|EclItem|nil
function GameHelpers.Item.GetEquippedTemplateSlot(character, template)
    for item in GameHelpers.Character.GetEquipment(character) do
        local itemTemplate = GameHelpers.GetTemplate(item)
        if itemTemplate == template then
            return Data.EquipmentSlotNames[item.Slot],item
        end
    end
    return nil
end

---@param character EclCharacter|EsvCharacter|UUID|NETID
---@param tag string|string[]
---@return ItemSlot|nil
---@return EsvItem|EclItem|nil
function GameHelpers.Item.GetEquippedTaggedItemSlot(character, tag)
    local char = GameHelpers.GetCharacter(character)
    fassert(char ~= nil, "'%s' is not a valid character", character)
    local tagType = type(tag)
    fassert(tagType ~= "string" or tagType ~= "table", "'%s' is not a valid tag or table of tags", tag)
    for item in GameHelpers.Character.GetEquipment(character) do
        if GameHelpers.ItemHasTag(item, tag) then
            return Data.EquipmentSlotNames[item.Slot],item
        end
    end
    return nil
end

if not _ISCLIENT then
    
    ---[Server]
    ---@param character EsvCharacter|UUID|NETID
    ---@param item ItemParam
    ---@param slot ItemSlot
    ---@return boolean
    function GameHelpers.Item.EquipInSlot(character, item, slot)
        if Ext.OsirisIsCallable() then
            local char = GameHelpers.GetUUID(character)
            local itemUUID = GameHelpers.GetUUID(item)
            if ObjectExists(itemUUID) == 1 and ObjectExists(char) == 1 then
                NRD_CharacterEquipItem(char, itemUUID, slot, 0, 0, 1, 1)
                return true
            end
        else
            fprint(LOGLEVEL.WARNING, "[GameHelpers.Item.EquipInSlot] NRD_CharacterEquipItem is not callable.")
        end
        return false
    end

    ---@deprecated
    ---@param character EsvCharacter|UUID|NETID
    ---@param item ItemParam
    ---@param slot ItemSlot
    ---@return boolean
    EquipInSlot = function (character, item, slot)
        return GameHelpers.Item.EquipInSlot(character, item, slot)
    end

    ---Removes matching rune templates from items in any equipment slots.
    ---[Server]
    ---@param character EclCharacter|EsvCharacter|UUID|NETID
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

    ---Removes an item in a slot, if one exists.
    ---[Server]
    ---@param character EsvCharacter|UUID|NETID
    ---@param slot ItemSlot
    ---@param delete boolean Whether to destroy the item or simply unequip it.
    ---@return boolean
    function GameHelpers.Item.UnequipItemInSlot(character, slot, delete)
        character = GameHelpers.GetCharacter(character)
        local item = GameHelpers.Item.GetItemInSlot(character, slot)
        if item ~= nil then
            CharacterUnequipItem(character.MyGuid, item.MyGuid)
            if delete == true and not item.Global then
                ItemRemove(item.MyGuid)
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

---@param character EclCharacter|EsvCharacter|UUID|NETID
---@param item ItemParam
---@return boolean
function GameHelpers.Item.ItemIsEquipped(character, item)
    local charUUID = StringHelpers.GetUUID(character)
    local itemObj = GameHelpers.GetItem(item)
    if charUUID and itemObj then
        local slot = itemObj.Slot
        if slot <= 13 then -- 13 is the Overhead slot, 14 is 'Sentinel'
            local owner = GameHelpers.GetCharacter(itemObj.InUseByCharacterHandle)
            return owner and owner.MyGuid == charUUID
        end
    end
    return false
end

---@param item ItemParam
---@return boolean
function GameHelpers.Item.ItemIsEquippedByCharacter(item)
    local itemObj = GameHelpers.GetItem(item)
    if itemObj then
        local user = GameHelpers.GetCharacter(itemObj.InUseByCharacterHandle)
        if user then
            return true
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

---Builds a list of items with a specific tag.
---@param character EsvCharacter|EclCharacter|UUID|NETID
---@param tag string|string[]
---@param asArray boolean|nil Optional param to make the table returned just be an array of UUIDs, instead of <slot,UUID>
---@return table<string,EsvItem|EclItem>
function GameHelpers.Item.FindTaggedEquipment(character, tag, asArray)
    local items = {}
    for item in GameHelpers.Character.GetEquipment(character) do
        if GameHelpers.ItemHasTag(item, tag) then
            if asArray then
                items[#items+1] = item
            else
                items[Data.EquipmentSlotNames[item.Slot]] = item
            end
        end
    end
	return items
end

---Gets an array of items with specific tag(s) on a character.
---@param character EsvCharacter|EclCharacter|UUID|NETID
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
	local t = type(item)
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

---@param item ItemParam
---@param returnNilUUID boolean|nil
---@return UUID
function GameHelpers.Item.GetOwner(item, returnNilUUID)
	local item = GameHelpers.GetItem(item)
	if item then
		if item.OwnerHandle ~= nil then
			local object = Ext.GetGameObject(item.OwnerHandle)
			if object ~= nil then
				return object.MyGuid
			end
		end
		if Ext.OsirisIsCallable() then
			local inventory = StringHelpers.GetUUID(GetInventoryOwner(item.MyGuid))
			if not StringHelpers.IsNullOrEmpty(inventory) then
				return inventory
			end
		else
			if item.InventoryHandle then
				local object = Ext.GetGameObject(item.InventoryHandle)
				if object ~= nil then
					return object.MyGuid
				end
			end
		end
	end
	if returnNilUUID then
		return StringHelpers.NULL_UUID
	end
	return nil
end

---@param item StatItem|ItemParam
---@param weaponType string|string[]
---@return boolean
function GameHelpers.Item.IsWeaponType(item, weaponType)
	if type(item) == "table" then
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
		local t = type(weaponType)
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