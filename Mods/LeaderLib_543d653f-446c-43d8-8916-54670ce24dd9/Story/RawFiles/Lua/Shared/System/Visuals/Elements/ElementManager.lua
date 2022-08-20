--Server-Side Script

Ext.Require("Shared/System/Visuals/Elements/Classes/VisualResourceData.lua")
Ext.Require("Shared/System/Visuals/Elements/Classes/VisualElementData.lua")

---@class LeaderLibVisualElementManager
local ElementManager = {
	---@type table<string, VisualElementData>
	Data = {}
}

ElementManager.Register = {
	---@param visualSet string
	---@param data VisualElementData
	Visuals = function(visualSet, data)
		ElementManager.Data[visualSet] = data
		data.VisualSet = visualSet
	end
}

---@enum ElementManagerVisualSlot
ElementManager.VisualSlot = {
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
Classes.Enum:Create(ElementManager.VisualSlot)

---@enum ElementManagerItemSlot
ElementManager.Slot = {
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

---@enum ElementManagerArmorType
ElementManager.ArmorType = {
	None = "None",
	Cloth = "Cloth",
	Leather = "Leather",
	Mail = "Mail",
	Plate = "Plate",
	Robe = "Robe",
}

---@param visualSet string
---@param data VisualElementData
function ElementManager.Register.Visuals(visualSet, data)
	ElementManager.Data[visualSet] = data
	data.VisualSet = visualSet
end

---@param char EsvCharacter
---@param item EsvItem
---@param equipped boolean
function ElementManager.OnEquipmentChanged(char,item,equipped)
	if char == nil or item == nil then
		return false
	end
	if item.Stats and item.Stats.ItemType == "Armor" and char.RootTemplate ~= nil then
		local visual = char.RootTemplate.VisualTemplate
		if not StringHelpers.IsNullOrEmpty(visual) then
			local data = ElementManager.Data[visual]
			if data ~= nil and data.OnEquipmentChanged ~= nil then
				-- Hidden Helmet
				if equipped and (item.Stats.ItemSlot == ElementManager.Slot.Helmet) and ObjectGetFlag(char.MyGuid, "LeaderLib_HelmetHidden") == 1 then
					equipped = false
				end
				local b,result = xpcall(data.OnEquipmentChanged, debug.traceback, data, char, item, equipped)
				if not b then
					Ext.Utils.PrintError(result)
				end
			end
		end
	end
end

RegisterProtectedOsirisListener("ItemEquipped", 2, "after", function(item,char)
	if ObjectExists(item) == 0 or ObjectExists(char) == 0 then
		return
	end
	ElementManager.OnEquipmentChanged(GameHelpers.GetCharacter(char), GameHelpers.GetItem(item), true)
end)

RegisterProtectedOsirisListener("ItemUnEquipped", 2, "after", function(item,char)
	if ObjectExists(item) == 0 or ObjectExists(char) == 0 then
		return
	else
		ElementManager.OnEquipmentChanged(GameHelpers.GetCharacter(char), GameHelpers.GetItem(item), false)
	end
end)

Ext.RegisterNetListener("LeaderLib_OnHelmetToggled", function(cmd, payload)
	local data = Common.JsonParse(payload)
	if data ~= nil and data.NetID ~= nil then
		local char = GameHelpers.GetCharacter(data.NetID)
		if char ~= nil then
			if data.State == 1 then
				ObjectClearFlag(char.MyGuid, "LeaderLib_HelmetHidden", 0)
			else
				ObjectSetFlag(char.MyGuid, "LeaderLib_HelmetHidden", 0)
			end
			local item = nil
			local helmet = CharacterGetEquippedItem(char.MyGuid, "Helmet")
			if not StringHelpers.IsNullOrEmpty(helmet) then
				item = GameHelpers.GetItem(helmet)
			end
			if item ~= nil then
				if data.State == 1 then
					ElementManager.OnEquipmentChanged(char, item, true)
				else
					ElementManager.OnEquipmentChanged(char, item, false)
				end
			end
		end
	end
end)

VisualManager.Elements = ElementManager