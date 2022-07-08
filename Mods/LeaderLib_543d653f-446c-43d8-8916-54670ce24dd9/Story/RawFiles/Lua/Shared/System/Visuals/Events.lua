if VisualManager.Events == nil then
	VisualManager.Events = {}
end

---@param char EsvCharacter
---@param item EsvItem
---@param equipped boolean
function VisualManager.Events.OnEquipmentChanged(char,item,equipped)
	if char == nil or item == nil then
		return false
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