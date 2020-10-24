if VisualManager == nil then
	VisualManager = {}
end

if VisualManager.VisualSlot == nil then
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
end

if VisualManager.Slot == nil then
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
end

if VisualManager.ArmorType == nil then
	VisualManager.ArmorType = {
		None = "None",
		Cloth = "Cloth",
		Leather = "Leather",
		Mail = "Mail",
		Plate = "Plate",
		Robe = "Robe",
	}
end

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
	if item.ItemType == "Armor" then
		if char.RootTemplate ~= nil and char.RootTemplate.VisualSetResourceID ~= nil then
			local data = VisualManager.Data[char.RootTemplate.VisualSetResourceID]
			if data ~= nil and data.ID == "VisualElementData" then
				if data.OnEquipmentChanged ~= nil then
					local b,result = xpcall(data.OnEquipmentChanged, debug.traceback, data, char, item, equipped)
					if not b then
						Ext.PrintError(result)
					end
				end
			end
		end
	end
end

RegisterProtectedOsirisListener("ItemEquipped", 2, "after", function(item,char)
	VisualManager.Events.OnEquipmentChanged(Ext.GetCharacter(char), Ext.GetItem(item), true)
end)

RegisterProtectedOsirisListener("ItemUnEquipped", 2, "after", function(item,char)
	VisualManager.Events.OnEquipmentChanged(Ext.GetCharacter(char), Ext.GetItem(item), false)
end)