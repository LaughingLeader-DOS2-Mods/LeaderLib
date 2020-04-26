--- Registers a function to call when a specific Lua LeaderLib event fires.
---@param event string
---@param callback function
function RegisterListener(event, callback)
	if LeaderLib.Listeners[event] ~= nil then
		table.insert(LeaderLib.Listeners[event], callback)
	else
		error("[LeaderLib__Main.lua:RegisterListener] Event ("..tostring(event)..") is not a valid LeaderLib listener event!")
	end
end

--- Registers a function to call when a specific Lua LeaderLib event fires.
---@param event string
---@param uuid string
---@param callback function
function RegisterModListener(event, uuid, callback)
	if LeaderLib.ModListeners[event] ~= nil then
		LeaderLib.Listeners[event][uuid] = callback
	else
		error("[LeaderLib__Main.lua:RegisterListener] Event ("..tostring(event)..") is not a valid LeaderLib listener event!")
	end
end

--- Registers a function to call when a specific skill's events fire.
---@param skill string
---@param callback function
function RegisterSkillListener(skill, callback)
	if LeaderLib.SkillListeners[skill] == nil then
		LeaderLib.SkillListeners[skill] = {}
	end
	table.insert(LeaderLib.SkillListeners[skill], callback)
end

LeaderLib.RegisterListener = RegisterListener
LeaderLib.RegisterModListener = RegisterModListener
LeaderLib.RegisterSkillListener = RegisterSkillListener

LeaderLib.StatusTypes.CHARMED = { CHARMED = true }
--LeaderLib.StatusTypes.POLYMORPHED = { POLYMORPHED = true }

---@type TranslatedString
local TranslatedString = LeaderLib.Classes["TranslatedString"]
-- <content contentuid="h9b6e0ed8g07afg413dg939fg5d5b91a9461c">Next level costs [1] ability point(s)</content>
LeaderLib.LocalizedText.AbilityPlusTooltip = TranslatedString:Create("h9b6e0ed8g07afg413dg939fg5d5b91a9461c", "Next level costs [1] ability point(s)")

LeaderLib.LocalizedText.DamageTypeHandles = {
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

--MagicArmorMasteryDescription = TranslatedString:Create("h211cb400g5881g4b90g8bc8g0399d0288e00","Willpower determines how resistant you are to mental statuses like Fear or Charm."),
--VitalityMasteryDescription = TranslatedString:Create("h2c42b179gd34bg45f8g9a81g847315e0319c","Bodybuilding determines how resistant you are to physical statuses like Bleeding or Crippled."),
LeaderLib.LocalizedText.AbilityNames = {
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

local function LeaderLib_Shared_SessionLoading()
	for i,status in pairs(Ext.GetStatEntries("StatusData")) do
		local statusType = Ext.StatGetAttribute(status, "StatusType")
		if statusType ~= nil and statusType ~= "" then
			statusType = string.upper(statusType)
			local statusTypeTable = LeaderLib.StatusTypes[statusType]
			if statusTypeTable ~= nil then
				statusTypeTable[status] = true
				--LeaderLib.Print("[LeaderLib__Main.lua:LeaderLib_Shared_SessionLoading] Added Status ("..status..") to StatusType table ("..statusType..").")
			end
		end
	end
end

Ext.RegisterListener("SessionLoading", LeaderLib_Shared_SessionLoading)

local function LeaderLib_Shared_SessionLoaded()
	local count = #LeaderLib.TranslatedStringEntries
	if LeaderLib.TranslatedStringEntries ~= nil and count > 0 then
		for i,v in pairs(LeaderLib.TranslatedStringEntries) do
			if v == nil then
				table.remove(LeaderLib.TranslatedStringEntries, i)
			else
				pcall(function()
					v:Update()
				end)
			end
		end
		LeaderLib.Print(string.format("[LeaderLib_Shared_SessionLoaded] Updated %s TranslatedString entries.", count))
	end
end
Ext.RegisterListener("SessionLoaded", LeaderLib_Shared_SessionLoaded)