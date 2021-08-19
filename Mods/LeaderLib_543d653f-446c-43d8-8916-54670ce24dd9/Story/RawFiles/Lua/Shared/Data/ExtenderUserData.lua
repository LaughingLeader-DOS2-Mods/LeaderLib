Data.ExtenderClass = {
	EsvCharacter = "esv::Character",
	EclCharacter = "ecl::Character",
	EsvItem = "esv::Item",
	EclItem = "ecl::Item",
	StatCharacter = "CDivinityStats_Character",
	StatItem = "CDivinityStats_Item",
	StatItemWeapon = "CDivinityStats_Weapon_Attributes",
	StatItemArmor = "CDivinityStats_Equipment_Attributes",
}

if GameHelpers.Ext == nil then
	GameHelpers.Ext = {}
end

function GameHelpers.Ext.ObjectIsStatItem(obj)
	local meta = getmetatable(obj)
	return meta == Data.ExtenderClass.StatItem or meta == Data.ExtenderClass.StatItemWeapon or meta == Data.ExtenderClass.StatItemArmor
end

function GameHelpers.Ext.ObjectIsItem(obj)
	local meta = getmetatable(obj)
	return meta == Data.ExtenderClass.EsvItem or meta == Data.ExtenderClass.EclItem
end

function GameHelpers.Ext.ObjectIsCharacter(obj)
	local meta = getmetatable(obj)
	return meta == Data.ExtenderClass.EsvCharacter or meta == Data.ExtenderClass.EclCharacter
end