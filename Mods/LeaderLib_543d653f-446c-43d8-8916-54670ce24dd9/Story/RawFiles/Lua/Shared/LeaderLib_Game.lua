---@type TranslatedString
local TranslatedString = LeaderLib.Classes["TranslatedString"]

local DamageTypeHandles = {
	None = {Handle="h8a070775gc251g4f34g9086gb1772f7e2cff",Content="pure damage", Color="#13D177"},
	Physical = {Handle="h40782d69gbfaeg40cegbe3cg370ef44e3980",Content="physical damage", Color="#AE9F95"},
	Piercing = {Handle="hd05581a1g83a7g4d95gb59fgfa5ef68f5c90",Content="piercing damage", Color="#CD1F1F"},
	Corrosive = {Handle="h161d5479g06d6g408egade2g37a203e3361f",Content="corrosive damage", Color="#88A25B"},
	Magic = {Handle="hdb4307b4g1a6fg4c05g9602g6a4a6e7a29d9",Content="magic damage", Color="#7F00FF"},
	-- Special LeaderLib handle
	Chaos = {Handle="h2bc14afag7627g4db8gaaa6g19c26b9820d5",Content="chaos damage", Color="#9A00FF"},
	Air = {Handle="hdd80e44fg9585g48b8ga34dgab20dc18f077",Content="air damage", Color="#7D71D9"},
	Earth = {Handle="h68b77a37g9c43g4436gb360gd651af08d7bb",Content="earth damage", Color="#F7BA14"},
	Fire = {Handle="hc4d062edgd8e6g4048gaa44g160fe3c7b018",Content="fire damage", Color="#FE6E27"},
	Poison = {Handle="ha77d36b3ge969g4461g9b30gfff624024b18",Content="poison damage", Color="#65C900"},
	Shadow = {Handle="h256557fbg1d49g45d9g8690gb86b39d2a135",Content="shadow damage", Color="#797980"},
	Water = {Handle="h8cdcfeedg357eg4877ga69egc05dbe9c68a4",Content="water damage", Color="#4197E2"},
}

---Get localized damage text wrapped in that damage type's color.
---@param damageType string
---@param damageValue integer
---@return string
local function GetDamageText(damageType, damageValue)
	local entry = DamageTypeHandles[damageType]
	if entry ~= nil then
		local name = Ext.GetTranslatedString(entry.Handle, entry.Content)
		return string.format("<font color='%s'>%s %s</font>", entry.Color, damageValue, name)
	else
		Ext.PrintError("No damage name/color entry for type " .. tostring(damageType))
	end
	return ""
end

LeaderLib.Game.GetDamageText = GetDamageText

local AbilityNames = {
	None = TranslatedString:Create("h9a2aead4gfa2dg4fbegae65g57c501cadf4f","None"),
	WarriorLore = TranslatedString:Create("h8e4bebcbg21c7g43dag8b05gd3b13c1be651","Warfare"),
	RangerLore = TranslatedString:Create("h3d3dc89dgd286g418eg8134g2eb65d063514","Huntsman"),
	RogueLore = TranslatedString:Create("hed591025g5c39g48ccga899gc9b1569716c1","Scoundrel"),
	SingleHanded = TranslatedString:Create("ha74334b1gd56bg49c2g8738g44da4decd00a","Single-Handed"),
	TwoHanded = TranslatedString:Create("h3fb5cd5ag9ec8g4746g8f9cg03100b26bd3a","Two-Handed"),
	Reflection = TranslatedString:Create("h591d7502gb8c3g443cg86ebga0b3a903155a","Retribution"),
	Ranged = TranslatedString:Create("hdda30cb9g17adg433ag9071g867e97c09c3a","Ranged"),
	Shield = TranslatedString:Create("h77557ac7g4f6fg49bdga76cg404de43d92f5","Shield"), -- Or h0c4dfdb5g88e7g4df8gabc9gf17b7042bf14 ?
	Reflexes = TranslatedString:Create("h4e65fe41g7f4cg429ega1abgab8894fc6b2e","Reflexes"),
	PhysicalArmorMastery = TranslatedString:Create("h1f09b725g975dg4480gb88fge119687654f9","Tenebrium"),
	Sourcery = TranslatedString:Create("ha8b343fbg4ebbg4e72gb58fg633850ad0580","Sourcery"),
	Telekinesis = TranslatedString:Create("h455eb073g28abg4f3bgae9dga8a592a30cdb","Telekinesis"),
	FireSpecialist = TranslatedString:Create("hf0a5a77dg132ag4517g8701g9d2ca3057a28","Pyrokinetic"),
	WaterSpecialist = TranslatedString:Create("h21354580g6870g411dgbef4g52f34942686a","Hydrosophist"),
	AirSpecialist = TranslatedString:Create("hf8056089g5b06g4a54g8dd5gf1fb9a796b53","Aerotheurge"),
	EarthSpecialist = TranslatedString:Create("h814e6bb5g3f51g4549gb3e4ge99e1d0017e1","Geomancer"),
	Necromancy = TranslatedString:Create("hb7ea4cc5g2a18g416bg9b95g51d928a60398","Necromancer"),
	Summoning = TranslatedString:Create("hac10f374gf9dbg4ee5gb5d0g7b1d3cb6d1fe","Summoning"),
	Polymorph = TranslatedString:Create("h70714d89g196eg4affga165gaa9d72a61368","Polymorph"),
	Repair = TranslatedString:Create("hfb0ab865gb8dfg4e35g9c8dg0a8bb9445348","Repair"), -- Or h11c016c1g62a6g4e34g852dg9cc43da69d57
	Sneaking = TranslatedString:Create("h6bf7caf0g7756g443bg926dg1ee5975ee133","Sneaking"),
	Pickpocket = TranslatedString:Create("ha39a1bbeg39a3g4f52g8953g8f2f6b6ee1fa","Pickpocketing"), -- or h285c0c44g7cf1g43deg8ec7g6d6e9b7deba0
	Thievery = TranslatedString:Create("h1633e511g35e3g4e22gb999gbbf3b0d5ce5e","Thievery"),
	Loremaster = TranslatedString:Create("hb8aa942egbeaag4452gbfbcg31b493bead6e","Loremaster"),
	Crafting = TranslatedString:Create("hebe1820eg1937g4413g83bcgf02d9720d66c","Crafting"), -- or h9d0ba738g6db4g43b4gac05g864de7d1b249
	Barter = TranslatedString:Create("hcc404653ga10ag4f56g8119g11162e60f81d","Bartering"),
	Charm = TranslatedString:Create("h83638179g9e69g48e1g8c84g06b469920867","Charm"), -- Or h0fca4136gc89dg49b6gadc0gaba3e4941988 ??
	Intimidate = TranslatedString:Create("h6efd5166g9073g439fgb814gcd9186cb8e61","Intimidate"),
	Reason = TranslatedString:Create("h682664edg221eg4ab3g8eb6gc25abf00c8bf","Reason"),
	Persuasion = TranslatedString:Create("h257372d3g6f98g4450g813bg190e19aecce4","Persuasion"),
	Leadership = TranslatedString:Create("h7c65fe39g1526g427bg8a2dgab7e74c66202","Leadership"), -- Or hbcbab273g6573g4b68g810cgae231a342df0
	Luck = TranslatedString:Create("h2f9ec5acgbcbeg45b8g8058gee363e6875d5","Lucky Charm"),
	DualWielding = TranslatedString:Create("h03d68693g35e7g4721ga1b3g9f9882f08b12","Dual Wielding"),
	Wand = TranslatedString:Create("hb135e047g6d81g4e68gb805g355316f12982","Wands"), -- No Idea
	MagicArmorMastery = TranslatedString:Create("h3478fd51gb40bg4a9ega851g25a1b5e62ea5","Willpower"),
	VitalityMastery = TranslatedString:Create("h9e592393gda0fg4841gb7eegbfa847582e82","Bodybuilding"),
	Perseverance = TranslatedString:Create("h5b61fccfg5d2ag4a81g9cacg068403d61b5c","Perseverance"), -- Or hfc4ae314g920ag4fdagbc50ge73b91cfa7c7
	Runecrafting = TranslatedString:Create("h87db6c3cg511dg4db1gad59g58ace25f71d1","Rune Crafting"),
	Brewmaster = TranslatedString:Create("h01fcbb18gbec4g488egaab1g96f8a3db38cc","Brewer"),
}

--MagicArmorMasteryDescription = TranslatedString:Create("h211cb400g5881g4b90g8bc8g0399d0288e00","Willpower determines how resistant you are to mental statuses like Fear or Charm."),
--VitalityMasteryDescription = TranslatedString:Create("h2c42b179gd34bg45f8g9a81g847315e0319c","Bodybuilding determines how resistant you are to physical statuses like Bleeding or Crippled."),

---Get the localized name for an ability.
---@param ability string
---@return string
local function GetAbilityName(ability, damageValue)
	local entry = AbilityNames[ability]
	if entry ~= nil then
		return entry.Value
	else
		Ext.PrintError("[LeaderLib.Game.GetAbilityName] No ability name for " .. tostring(ability))
	end
	return nil
end

LeaderLib.Game.GetAbilityName = GetAbilityName