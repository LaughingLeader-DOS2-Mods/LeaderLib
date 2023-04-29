local _Resistances = {
	Physical = "PhysicalResistance",
	Piercing = "PiercingResistance",
	Corrosive = "CorrosiveResistance",
	Magic = "MagicResistance",
	Air = "AirResistance",
	Earth = "EarthResistance",
	Fire = "FireResistance",
	Poison = "PoisonResistance",
	Shadow = "ShadowResistance", -- Technically Tenebrium
	Water = "WaterResistance",
	--Sulfuric = "CustomResistance",
}

local ResistancePenetrationAttributes = {
	PhysicalResistancePenetration = "PhysicalResistance",
	PiercingResistancePenetration = "PiercingResistance",
	CorrosiveResistancePenetration = "CorrosiveResistance",
	MagicResistancePenetration = "MagicResistance",
	AirResistancePenetration = "AirResistance",
	EarthResistancePenetration = "EarthResistance",
	FireResistancePenetration = "FireResistance",
	PoisonResistancePenetration = "PoisonResistance",
	ShadowResistancePenetration = "ShadowResistance",
	WaterResistancePenetration = "WaterResistance",
	--SulfuricResistancePenetration = "CustomResistance",
}

Ext.Events.StatsStructureLoaded:Subscribe(function (e)
	for attributeName,_ in pairs(ResistancePenetrationAttributes) do
		Ext.Stats.AddAttribute("Armor", attributeName, "ConstantInt")
		Ext.Stats.AddAttribute("Shield", attributeName, "ConstantInt")
		Ext.Stats.AddAttribute("Weapon", attributeName, "ConstantInt")
		Ext.Stats.AddAttribute("Character", attributeName, "ConstantInt")
		Ext.Stats.AddAttribute("Potion", attributeName, "ConstantInt")
	end
end)