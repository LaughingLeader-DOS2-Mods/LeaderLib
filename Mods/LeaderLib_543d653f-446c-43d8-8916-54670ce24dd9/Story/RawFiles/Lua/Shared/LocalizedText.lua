---@type TranslatedString
local TranslatedString = Classes["TranslatedString"]

---@class ColoredTranslatedStringEntry
---@field Text TranslatedString
---@field Color string

---@type table<string, ColoredTranslatedStringEntry>
LocalizedText.DamageTypeHandles = {
	None = {Text=TranslatedString:Create("h8a070775gc251g4f34g9086gb1772f7e2cff","pure damage"), Color="#13D177"},
	Physical = {Text=TranslatedString:Create("h40782d69gbfaeg40cegbe3cg370ef44e3980","physical damage"), Color="#AE9F95"},
	Piercing = {Text=TranslatedString:Create("hd05581a1g83a7g4d95gb59fgfa5ef68f5c90","piercing damage"), Color="#CD1F1F"},
	Corrosive = {Text=TranslatedString:Create("h161d5479g06d6g408egade2g37a203e3361f","corrosive damage"), Color="#88A25B"},
	Magic = {Text=TranslatedString:Create("hdb4307b4g1a6fg4c05g9602g6a4a6e7a29d9","magic damage"), Color="#7F00FF"},
	Chaos = {Text=TranslatedString:Create("h2bc14afag7627g4db8gaaa6g19c26b9820d5","chaos damage"), Color="#9A00FF"},-- Special LeaderLib handle
	Air = {Text=TranslatedString:Create("hdd80e44fg9585g48b8ga34dgab20dc18f077","air damage"), Color="#7D71D9"},
	Earth = {Text=TranslatedString:Create("h68b77a37g9c43g4436gb360gd651af08d7bb","earth damage"), Color="#F7BA14"},
	Fire = {Text=TranslatedString:Create("hc4d062edgd8e6g4048gaa44g160fe3c7b018","fire damage"), Color="#FE6E27"},
	Poison = {Text=TranslatedString:Create("ha77d36b3ge969g4461g9b30gfff624024b18","poison damage"), Color="#65C900"},
	Shadow = {Text=TranslatedString:Create("h256557fbg1d49g45d9g8690gb86b39d2a135","shadow damage"), Color="#797980"},
	Water = {Text=TranslatedString:Create("h8cdcfeedg357eg4877ga69egc05dbe9c68a4","water damage"), Color="#4197E2"},
}

---@type table<string, ColoredTranslatedStringEntry>
LocalizedText.DamageTypeNames = {
	None = {Text=TranslatedString:Create("h37e16e2cgb2c7g46a6g942egb35eb0a825f1","Pure"), Color="#13D177"},
	Physical = {Text=TranslatedString:Create("ha6c38456g4c6ag47b2gae87g60a26cf4bf7b","Physical"), Color="#AE9F95"},
	Piercing = {Text=TranslatedString:Create("h22f6b7bcgc548g49cbgbc04g9532e893fb55","Piercing"), Color="#CD1F1F"},
	Corrosive = {Text=TranslatedString:Create("h727b2365g5cd3g4557g8627ge9612ab59420","Corrosive"), Color="#88A25B"},
	Magic = {Text=TranslatedString:Create("h02e0fcacg670eg4d35g9f20gcf5cddab7fd1","Magic"), Color="#7F00FF"},
	Chaos = {Text=TranslatedString:Create("hf43ec8a1gb6c4g421dg983cg01535ee1bcdf","Chaos"), Color="#9A00FF"},-- Special LeaderLib handle
	Air = {Text=TranslatedString:Create("h1cea7e28gc8f1g4915ga268g31f90767522c","Air"), Color="#7D71D9"},
	Earth = {Text=TranslatedString:Create("h85fee3f4g0226g41c6g9d38g83b7b5bf96ba","Earth"), Color="#F7BA14"},
	Fire = {Text=TranslatedString:Create("h051b2501g091ag4c93ga699g407cd2b29cdc","Fire"), Color="#FE6E27"},
	Poison = {Text=TranslatedString:Create("haa64cdb8g22d6g40d6g9918g61961514f70f","Poison"), Color="#65C900"},
	Shadow = {Text=TranslatedString:Create("hf4632a8fg42a7g4d53gbe26gd203f28e3d5e","Shadow"), Color="#797980"},
	Water = {Text=TranslatedString:Create("hd30196cdg0253g434dga42ag12be43dac4ec","Water"), Color="#4197E2"},
}

--MagicArmorMasteryDescription = TranslatedString:Create("h211cb400g5881g4b90g8bc8g0399d0288e00","Willpower determines how resistant you are to mental statuses like Fear or Charm."),
--VitalityMasteryDescription = TranslatedString:Create("h2c42b179gd34bg45f8g9a81g847315e0319c","Bodybuilding determines how resistant you are to physical statuses like Bleeding or Crippled."),

---@type table<string, TranslatedString>
LocalizedText.AbilityNames = {
	--None = TranslatedString:Create("h9a2aead4gfa2dg4fbegae65g57c501cadf4f","None"),
	WarriorLore = TranslatedString:Create("h8e4bebcbg21c7g43dag8b05gd3b13c1be651","Warfare"),
	RangerLore = TranslatedString:Create("h3d3dc89dgd286g418eg8134g2eb65d063514","Huntsman"),
	RogueLore = TranslatedString:Create("hed591025g5c39g48ccga899gc9b1569716c1","Scoundrel"),
	SingleHanded = TranslatedString:Create("ha74334b1gd56bg49c2g8738g44da4decd00a","Single-Handed"),
	TwoHanded = TranslatedString:Create("h3fb5cd5ag9ec8g4746g8f9cg03100b26bd3a","Two-Handed"),
	Reflection = TranslatedString:Create("h591d7502gb8c3g443cg86ebga0b3a903155a","Retribution"),
	Ranged = TranslatedString:Create("hdda30cb9g17adg433ag9071g867e97c09c3a","Ranged"),
	Shield = TranslatedString:Create("h2bbbfa10g8c9cg4c49ga425g582da93fb156","Shieldbearer"), -- Or h0c4dfdb5g88e7g4df8gabc9gf17b7042bf14 ?
	Reflexes = TranslatedString:Create("h4e65fe41g7f4cg429ega1abgab8894fc6b2e","Reflexes"),
	PhysicalArmorMastery = TranslatedString:Create("hae52ff4bg54e7g4eabgb930gca752c4ba072","Armour Specialist"), -- Re-added by LeaderLib
	Sourcery = TranslatedString:Create("ha8b343fbg4ebbg4e72gb58fg633850ad0580","Sourcery"),
	Telekinesis = TranslatedString:Create("h455eb073g28abg4f3bgae9dga8a592a30cdb","Telekinesis"),
	FireSpecialist = TranslatedString:Create("hf0a5a77dg132ag4517g8701g9d2ca3057a28","Pyrokinetic"),
	WaterSpecialist = TranslatedString:Create("h21354580g6870g411dgbef4g52f34942686a","Hydrosophist"),
	AirSpecialist = TranslatedString:Create("hf8056089g5b06g4a54g8dd5gf1fb9a796b53","Aerotheurge"),
	EarthSpecialist = TranslatedString:Create("h814e6bb5g3f51g4549gb3e4ge99e1d0017e1","Geomancer"),
	Necromancy = TranslatedString:Create("hb7ea4cc5g2a18g416bg9b95g51d928a60398","Necromancer"),
	Summoning = TranslatedString:Create("hac10f374gf9dbg4ee5gb5d0g7b1d3cb6d1fe","Summoning"),
	Polymorph = TranslatedString:Create("h70714d89g196eg4affga165gaa9d72a61368","Polymorph"),
	Sulfurology = TranslatedString:Create("h919b260ag66c4g4551gb4c7g793a12115cfc","Sulfurology"),
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
	Brewmaster = TranslatedString:Create("hab7acde6g5af6g47a7ga65dgc633aef193cf","Brew Master"),
}

---@type table<string, TranslatedString>
LocalizedText.AttributeNames = {
	Strength = TranslatedString:Create("hb4e3a075g5f82g4a0dgaffbg456e5c15c3db","Strength"),
	Finesse = TranslatedString:Create("h281c2da7g2d2bg4d69g986agfd124c7f569f","Finesse"),
	Intelligence = TranslatedString:Create("hfbc938ceg297fg4232ga11dg3fe44985b9f8","Intelligence"),
	Constitution = TranslatedString:Create("hb4cd5b0bg5731g40b3gb49bg1fa6db60f346","Constitution"),
	Memory = TranslatedString:Create("h8565e761ge486g467aga4cfg17344874f1ab","Memory"),
	Wits = TranslatedString:Create("h2b03f6f9gbf5dg4f51g9b98gf01243633ed3","Wits"),
}

---@type table<string, TranslatedString>
LocalizedText.Slots = {
	Helmet = TranslatedString:Create("hd4b98ff5g33a8g44e0ga6a9gdb1ab7d70bf3", "Helmet"),
	Breast = TranslatedString:Create("hb5c52d20g6855g4929ga78ege3fe776a1f2e", "Chest Armour"),
	Leggings = TranslatedString:Create("he7042b52g54d7g4f46g8f69g509460dfe595", "Leggings"),
	Weapon = TranslatedString:Create("h102d1ef8g3757g4ff3g8ef2gd68007c6268d", "Weapon"),
	Shield = TranslatedString:Create("h77557ac7g4f6fg49bdga76cg404de43d92f5", "Shield"),
	Ring = TranslatedString:Create("h970199f8ge650g4fa3ga0deg5995696569b6", "Ring"),
	Belt = TranslatedString:Create("h2a76a9ecg2982g4c7bgb66fgbe707db0ac9e", "Belt"),
	Boots = TranslatedString:Create("h9b65aab2gf4c4g4b81g96e6g1dcf7ffa8306", "Boots"),
	Gloves = TranslatedString:Create("h185545eagdaf0g4286ga411gd50cbdcabc8b", "Gloves"),
	Amulet = TranslatedString:Create("hb9d79ca5g59afg4255g9cdbgf614b894be68", "Amulet"),
	Ring2 = TranslatedString:Create("h970199f8ge650g4fa3ga0deg5995696569b6", "Ring"),
	Wings = TranslatedString:Create("hd716a074gd36ag4dfcgbf79g53bd390dd202", "Wings"),
	Horns = TranslatedString:Create("ha35fc503g56dbg4adag963dga359d961e0c8", "Horns"),
	Overhead = TranslatedString:Create("hda749a3fg52c0g48d5gae3bgd522dd34f65c", "Overhead"),
	Offhand = TranslatedString:Create("h50110389gc98ag49dbgb58fgae2fd227dff4", "Offhand"),
}

---@type table<string, TranslatedString>
LocalizedText.ItemBoosts = {
	ResistancePenetration = TranslatedString:Create("hf638bc67g5cb6g4dcfg8663gce1951caad2b", "[1] Penetration")
}

-- <content contentuid="h9b6e0ed8g07afg413dg939fg5d5b91a9461c">Next level costs [1] ability point(s)</content>

---@type table<string, TranslatedString>
LocalizedText.UI = {
	AbilityPlusTooltip = TranslatedString:Create("h9b6e0ed8g07afg413dg939fg5d5b91a9461c", "Next level costs [1] ability point(s)"),
	Confirm = TranslatedString:Create("h0fb8bf07g3932g4ccbg8659g2f4f5aa7dd82", "Confirm"),
	Close = TranslatedString:Create("h9eed6c77g31bbg4637g9332g30e47efcd7eb", "Close"),
	OK = TranslatedString:Create("h1cb63048g62e1g4b86gac15gb333158c2c81", "OK"),
	Yes = TranslatedString:Create("hf52bf842g05beg48dega717gca15b3678e0e", "Yes"),
	No = TranslatedString:Create("heded8384gb4f5g439dg9883g5cf950b2bbfc", "No"),
}

---Get localized damage text wrapped in that damage type's color.
---@param damageType string
---@param damageValue string|integer|number
---@return string
local function GetDamageText(damageType, damageValue)
	local entry = LocalizedText.DamageTypeHandles[damageType]
	if entry ~= nil then
		if damageValue ~= nil then
			if type(damageValue) == "number" then
				return string.format("<font color='%s'>%i %s</font>", entry.Color, damageValue, entry.Text.Value)
			else
				return string.format("<font color='%s'>%s %s</font>", entry.Color, damageValue, entry.Text.Value)
			end
		else
			return string.format("<font color='%s'>%s</font>", entry.Color, entry.Text.Value)
		end
	else
		Ext.PrintError("No damage name/color entry for type " .. tostring(damageType))
	end
	return ""
end

GameHelpers.GetDamageText = GetDamageText

---Get localized damage text wrapped in that damage type's color.
---@param damageType string
---@param damageValue string|integer|number
---@return string
local function GetColoredDamageText(damageType, damageValue)
	local entry = LocalizedText.DamageTypeHandles[damageType]
	if entry ~= nil then
		if damageValue ~= nil then
			if type(damageValue) == "number" then
				return string.format("<font color='%s'>%i</font>", entry.Color, damageValue)
			else
				return string.format("<font color='%s'>%s</font>", entry.Color, damageValue)
			end
		else
			return damageValue
		end
	else
		Ext.PrintError("No damage name/color entry for type " .. tostring(damageType))
	end
	return damageValue
end

GameHelpers.GetColoredDamageText = GetColoredDamageText

--- Get the localized name for an ability.
---@param ability string|integer
---@return string
local function GetAbilityName(ability)
	if type(ability) == "number" then
		ability = Data.Ability(math.tointeger(ability))
	else
		if ability == "None" then
			return ""
		end
	end
	local entry = LocalizedText.AbilityNames[ability]
	if entry ~= nil then
		return entry.Value
	else
		Ext.PrintError("[GameHelpers.GetAbilityName] No ability name for ["..tostring(ability).."]")
	end
	return nil
end

GameHelpers.GetAbilityName = GetAbilityName

local damageTypeToResistanceName = {
	None = "PureResistance", -- Special LeaderLib Addition
	Physical = "PhysicalResistance",
	Piercing = "PiercingResistance",
	Corrosive = "CorrosiveResistance",
	Magic = "MagicResistance",
	Chaos = "ChaosResistance",-- Special LeaderLib Addition
	Air = "AirResistance",
	Earth = "EarthResistance",
	Fire = "FireResistance",
	Poison = "PoisonResistance",
	Shadow = "ShadowResistance", -- Technically Tenebrium
	Water = "WaterResistance",
}

---@class ResistanceTextEntry
---@field Text TranslatedString
---@field Color string

---@type table<string, ResistanceTextEntry>
LocalizedText.ResistanceNames = {
	PureResistance = {Text=TranslatedString:Create("h71766947g9564g4a6bg936bga055cccc01a0","Pure Resistance"), Color="#13D177"}, -- Special LeaderLib handle
	PhysicalResistance = {Text=TranslatedString:Create("hcd84ee03g9912g4b0dga49age6bce09b19d1","Physical Resistance"), Color="#AE9F95"},
	PiercingResistance = {Text=TranslatedString:Create("he840ff3eg35e6g4e06ga987g970ebee744e3","Piercing Resistance"), Color="#CD1F1F"},
	CorrosiveResistance = {Text=TranslatedString:Create("hacc27ae5gfaf0g4854g85a6ga57d5be46dc5","Corrosive Resistance"), Color="#88A25B"},
	MagicResistance = {Text=TranslatedString:Create("h8bfd4518ge6deg47a2g90a6g541f5ba1ba88","Magic Resistance"), Color="#7F00FF"},
	ChaosResistance = {Text=TranslatedString:Create("h17e6d1bbgbe95g4944gb37dgfe5059a58a2d","Chaos Resistance"), Color="#9A00FF"},-- Special LeaderLib handle
	AirResistance = {Text=TranslatedString:Create("h134d72acgdd42g4c2dg97a8g6df0af2802a5","Air Resistance"), Color="#7D71D9"},
	EarthResistance = {Text=TranslatedString:Create("hac36ad5ag557fg4456ga0edga5a40606fabb","Earth Resistance"), Color="#F7BA14"},
	FireResistance = {Text=TranslatedString:Create("he04c3934g32b0g455fgac3dg75f2b7fd2119","Fire Resistance"), Color="#FE6E27"},
	PoisonResistance = {Text=TranslatedString:Create("he526af2ag192cg4a71g8247gb306eb0eb97d","Poison Resistance"), Color="#65C900"},
	ShadowResistance = {Text=TranslatedString:Create("hef0c737eg2a72g4564ga5cfg088484ac8b45","Shadow Resistance"), Color="#797980"}, -- Technically Tenebrium
	WaterResistance = {Text=TranslatedString:Create("he5441d99gdb3cg40acga0c4g24379b8b09f7","Water Resistance"), Color="#4197E2"},
}

---Get localized resistance text wrapped in that resistance's color.
---@param resistance string
---@param amount integer
---@return string
local function GetResistanceText(resistance, amount)
	local entry = LocalizedText.ResistanceNames[resistance]
	if entry == nil then
		local damageTypeToResistance = damageTypeToResistanceName[resistance]
		if damageTypeToResistance ~= nil then
			entry = LocalizedText.ResistanceNames[damageTypeToResistance]
		end
	end
	if entry ~= nil then
		if amount ~= nil then
			if type(amount) == "number" then
				return string.format("<font color='%s'>%i%%%% %s</font>", entry.Color, amount, entry.Text.Value)
			else
				return string.format("<font color='%s'>%s%%%% %s</font>", entry.Color, amount, entry.Text.Value)
			end
		else
			return string.format("<font color='%s'>%s</font>", entry.Color, entry.Text.Value)
		end
	else
		Ext.PrintError("No damage name/color entry for resistance " .. tostring(resistance))
	end
	return ""
end

GameHelpers.GetResistanceText = GetResistanceText

---Get the localized resistance name for a damage type.
---@param damageType string
---@return string
local function GetResistanceNameFromDamageType(damageType)
	local resistance = Data.DamageTypeToResistanceWithExtras[damageType]
	if resistance ~= nil then
		local entry = LocalizedText.ResistanceNames[resistance]
		if entry ~= nil then
			return entry.Text.Value
		else
			Ext.PrintError("No name/color entry for resistance/damagetype",resistance,damageType)
		end
	end
	return ""
end

GameHelpers.GetResistanceNameFromDamageType = GetResistanceNameFromDamageType

---Get the final value of a string key.
---This uses the handle returned from Ext.GetTranslatedStringFromKey to then get the text from Ext.GetTranslatedString.
---@param key string The string key.
---@param fallback string Text to use if the key does not exist.
---@return string
local function GetStringKeyText(key,fallback)
	local ref,handle = Ext.GetTranslatedStringFromKey(key)
	if handle == nil then
		return fallback
	end
	local text = Ext.GetTranslatedString(handle, ref)
	return text
end

GameHelpers.GetStringKeyText = GetStringKeyText