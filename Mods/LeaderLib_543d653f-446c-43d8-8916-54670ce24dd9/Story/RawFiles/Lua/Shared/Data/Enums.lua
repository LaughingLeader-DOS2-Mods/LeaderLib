Data.AnimType = {
	None = 0,
	OneHanded = 1,
	TwoHanded = 2,
	Bow = 3,
	DualWield = 4,
	Shield = 5,
	SmallWeapons = 6,
	PoleArms = 7,
	Unarmed = 8,
	CrossBow = 9,
	TwoHanded_Sword = 10,
	Sitting = 11,
	Lying = 12,
	DualWieldSmall = 13,
	Staves = 14,
	Wands = 15,
	DualWieldWands = 17,
	ShieldWands = 18,
}

---@type LeaderLibEnum
Data.DamageTypes = {
	None = 0,
	Physical = 1,
	Piercing = 2,
	Corrosive = 3,
	Magic = 4,
	Chaos = 5,
	Fire = 6,
	Air = 7,
	Water = 8,
	Earth = 9,
	Poison = 10,
	Shadow = 11,
	[0] = "None",
	[1] = "Physical",
	[2] = "Piercing",
	[3] = "Corrosive",
	[4] = "Magic",
	[5] = "Chaos",
	[6] = "Fire",
	[7] = "Air",
	[8] = "Water",
	[9] = "Earth",
	[10] = "Poison",
	[11] = "Shadow",
}

Classes.Enum:Create(Data.DamageTypes)
---@deprecated
Data.DamageTypeEnums = Data.DamageTypes