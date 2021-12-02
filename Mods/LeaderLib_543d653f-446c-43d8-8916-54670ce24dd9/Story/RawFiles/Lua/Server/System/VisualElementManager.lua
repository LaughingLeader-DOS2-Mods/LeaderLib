if VisualManager == nil then
	VisualManager = {}
end

VisualManager.VisualSlot = {
	Helmet = 1,
	Head = 2,
	Torso = 3,
	Arms = 4,
	Trousers = 5,
	Boots = 6,
	Beard = 7,
	Extra1 = 8,
	Extra2 = 9
}

VisualManager.Slot = {
	Helmet = "Helmet",
	Breast = "Breast",
	Leggings = "Leggings",
	Weapon = "Weapon",
	Shield = "Shield",
	Ring = "Ring",
	Belt = "Belt",
	Boots = "Boots",
	Gloves = "Gloves",
	Amulet = "Amulet",
	Ring2 = "Ring2",
	Wings = "Wings",
	Horns = "Horns",
	Overhead = "Overhead",
}

VisualManager.ArmorType = {
	None = "None",
	Cloth = "Cloth",
	Leather = "Leather",
	Mail = "Mail",
	Plate = "Plate",
	Robe = "Robe",
}

if VisualManager.Register == nil then
	VisualManager.Register = {}
end

if VisualManager.Events == nil then
	VisualManager.Events = {}
end

---@alias VisualSetUUID string
---@alias ArmorType string

if VisualManager.Data == nil then
	---@type table<VisualSetUUID, VisualElementData>
	VisualManager.Data = {}
end

---@param visualSet string
---@param data VisualElementData
function VisualManager.Register.Visuals(visualSet, data)
	VisualManager.Data[visualSet] = data
	data.VisualSet = visualSet
end

---@param char EsvCharacter
---@param item EsvItem
---@param equipped boolean
function VisualManager.Events.OnEquipmentChanged(char,item,equipped)
	if char == nil or item == nil then
		return false
	end
	if item.ItemType == "Armor" and char.RootTemplate ~= nil then
		local visual = char.RootTemplate.VisualTemplate
		if not StringHelpers.IsNullOrEmpty(visual) then
			local data = VisualManager.Data[visual]
			if data ~= nil and data.OnEquipmentChanged ~= nil then
				-- Hidden Helmet
				if equipped and (item.Stats ~= nil and item.Stats.Slot == VisualManager.Slot.Helmet) and ObjectGetFlag(char.MyGuid, "LeaderLib_HelmetHidden") == 1 then
					equipped = false
				end
				local b,result = xpcall(data.OnEquipmentChanged, debug.traceback, data, char, item, equipped)
				if not b then
					Ext.PrintError(result)
				end
			end
		end
	end
end

RegisterProtectedOsirisListener("ItemEquipped", 2, "after", function(item,char)
	if ObjectExists(item) == 0 or ObjectExists(char) == 0 then
		return
	end
	VisualManager.Events.OnEquipmentChanged(Ext.GetCharacter(char), Ext.GetItem(item), true)
end)

RegisterProtectedOsirisListener("ItemUnEquipped", 2, "after", function(item,char)
	if ObjectExists(item) == 0 or ObjectExists(char) == 0 then
		return
	else
		VisualManager.Events.OnEquipmentChanged(Ext.GetCharacter(char), Ext.GetItem(item), false)
	end
end)

--[[ 
-- Would work great if CharacterSetVisualElement worked in CC.
local CCItemData = {}

RegisterProtectedOsirisListener("ItemEquipped", 2, "after", function(item,char)
	if ObjectExists(item) == 0 then
		return
	end
	if SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION then
		local itemData = GameHelpers.Ext.CreateItemTable(item)
		CCItemData[StringHelpers.GetUUID(item)] = itemData
	end
	VisualManager.Events.OnEquipmentChanged(Ext.GetCharacter(char), Ext.GetItem(item), true)
end, true)

RegisterProtectedOsirisListener("ItemUnEquipped", 2, "after", function(item,char)
	item = StringHelpers.GetUUID(item)
	if ObjectExists(item) == 0 then
		if SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION then
			local itemData = CCItemData[item]
			if itemData then
				VisualManager.Events.OnEquipmentChanged(Ext.GetCharacter(char), itemData, false)
				CCItemData[item] = nil
			else
				return
			end
		else
			return
		end
	else
		VisualManager.Events.OnEquipmentChanged(Ext.GetCharacter(char), Ext.GetItem(item), false)
	end
end, true) ]]

Ext.RegisterNetListener("LeaderLib_OnHelmetToggled", function(cmd, payload)
	local data = Common.JsonParse(payload)
	if data ~= nil and data.NetID ~= nil then
		local char = Ext.GetCharacter(data.NetID)
		if char ~= nil then
			if data.State == 1 then
				ObjectClearFlag(char.MyGuid, "LeaderLib_HelmetHidden", 0)
			else
				ObjectSetFlag(char.MyGuid, "LeaderLib_HelmetHidden", 0)
			end
			local item = nil
			local helmet = CharacterGetEquippedItem(char.MyGuid, "Helmet")
			if not StringHelpers.IsNullOrEmpty(helmet) then
				item = Ext.GetItem(helmet)
			end
			if item ~= nil then
				if data.State == 1 then
					VisualManager.Events.OnEquipmentChanged(char, item, true)
				else
					VisualManager.Events.OnEquipmentChanged(char, item, false)
				end
			end
		end
	end
end)