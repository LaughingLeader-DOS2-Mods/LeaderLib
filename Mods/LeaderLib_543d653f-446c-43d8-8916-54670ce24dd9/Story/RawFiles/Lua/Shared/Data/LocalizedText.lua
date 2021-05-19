---@type TranslatedString
local ts = Classes["TranslatedString"]

---@class ColoredTranslatedStringEntry
---@field Text TranslatedString
---@field Color string

---@type table<string, ColoredTranslatedStringEntry>
LocalizedText.DamageTypeHandles = {
	None = {Text=ts:Create("h8a070775gc251g4f34g9086gb1772f7e2cff","pure damage"), Color="#13D177"},
	Physical = {Text=ts:Create("h40782d69gbfaeg40cegbe3cg370ef44e3980","physical damage"), Color="#AE9F95"},
	Piercing = {Text=ts:Create("hd05581a1g83a7g4d95gb59fgfa5ef68f5c90","piercing damage"), Color="#CD1F1F"},
	Corrosive = {Text=ts:Create("h161d5479g06d6g408egade2g37a203e3361f","corrosive damage"), Color="#88A25B"},
	Magic = {Text=ts:Create("hdb4307b4g1a6fg4c05g9602g6a4a6e7a29d9","magic damage"), Color="#7F00FF"},
	Chaos = {Text=ts:Create("h2bc14afag7627g4db8gaaa6g19c26b9820d5","chaos damage"), Color="#9A00FF"},-- Special LeaderLib handle
	Air = {Text=ts:Create("hdd80e44fg9585g48b8ga34dgab20dc18f077","air damage"), Color="#7D71D9"},
	Earth = {Text=ts:Create("h68b77a37g9c43g4436gb360gd651af08d7bb","earth damage"), Color="#F7BA14"},
	Fire = {Text=ts:Create("hc4d062edgd8e6g4048gaa44g160fe3c7b018","fire damage"), Color="#FE6E27"},
	Poison = {Text=ts:Create("ha77d36b3ge969g4461g9b30gfff624024b18","poison damage"), Color="#65C900"},
	Shadow = {Text=ts:Create("h256557fbg1d49g45d9g8690gb86b39d2a135","shadow damage"), Color="#797980"},
	Water = {Text=ts:Create("h8cdcfeedg357eg4877ga69egc05dbe9c68a4","water damage"), Color="#4197E2"},
}

---@type table<string, ColoredTranslatedStringEntry>
LocalizedText.DamageTypeNames = {
	None = {Text=ts:Create("h37e16e2cgb2c7g46a6g942egb35eb0a825f1","Pure"), Color="#13D177"},
	Physical = {Text=ts:Create("ha6c38456g4c6ag47b2gae87g60a26cf4bf7b","Physical"), Color="#AE9F95"},
	Piercing = {Text=ts:Create("h22f6b7bcgc548g49cbgbc04g9532e893fb55","Piercing"), Color="#CD1F1F"},
	Corrosive = {Text=ts:Create("h727b2365g5cd3g4557g8627ge9612ab59420","Corrosive"), Color="#88A25B"},
	Magic = {Text=ts:Create("h02e0fcacg670eg4d35g9f20gcf5cddab7fd1","Magic"), Color="#7F00FF"},
	Chaos = {Text=ts:Create("hf43ec8a1gb6c4g421dg983cg01535ee1bcdf","Chaos"), Color="#9A00FF"},-- Special LeaderLib handle
	Air = {Text=ts:Create("h1cea7e28gc8f1g4915ga268g31f90767522c","Air"), Color="#7D71D9"},
	Earth = {Text=ts:Create("h85fee3f4g0226g41c6g9d38g83b7b5bf96ba","Earth"), Color="#F7BA14"},
	Fire = {Text=ts:Create("h051b2501g091ag4c93ga699g407cd2b29cdc","Fire"), Color="#FE6E27"},
	Poison = {Text=ts:Create("haa64cdb8g22d6g40d6g9918g61961514f70f","Poison"), Color="#65C900"},
	Shadow = {Text=ts:Create("hf4632a8fg42a7g4d53gbe26gd203f28e3d5e","Shadow"), Color="#797980"},
	Water = {Text=ts:Create("hd30196cdg0253g434dga42ag12be43dac4ec","Water"), Color="#4197E2"},
}

--MagicArmorMasteryDescription = ts:Create("h211cb400g5881g4b90g8bc8g0399d0288e00","Willpower determines how resistant you are to mental statuses like Fear or Charm."),
--VitalityMasteryDescription = ts:Create("h2c42b179gd34bg45f8g9a81g847315e0319c","Bodybuilding determines how resistant you are to physical statuses like Bleeding or Crippled."),

---@type table<string, TranslatedString>
LocalizedText.AbilityNames = {
	--None = ts:Create("h9a2aead4gfa2dg4fbegae65g57c501cadf4f","None"),
	WarriorLore = ts:Create("h8e4bebcbg21c7g43dag8b05gd3b13c1be651","Warfare"),
	RangerLore = ts:Create("h3d3dc89dgd286g418eg8134g2eb65d063514","Huntsman"),
	RogueLore = ts:Create("hed591025g5c39g48ccga899gc9b1569716c1","Scoundrel"),
	SingleHanded = ts:Create("ha74334b1gd56bg49c2g8738g44da4decd00a","Single-Handed"),
	TwoHanded = ts:Create("h3fb5cd5ag9ec8g4746g8f9cg03100b26bd3a","Two-Handed"),
	Reflection = ts:Create("h591d7502gb8c3g443cg86ebga0b3a903155a","Retribution"),
	Ranged = ts:Create("hdda30cb9g17adg433ag9071g867e97c09c3a","Ranged"),
	Shield = ts:Create("h2bbbfa10g8c9cg4c49ga425g582da93fb156","Shieldbearer"), -- Or h0c4dfdb5g88e7g4df8gabc9gf17b7042bf14 ?
	Reflexes = ts:Create("h4e65fe41g7f4cg429ega1abgab8894fc6b2e","Reflexes"),
	PhysicalArmorMastery = ts:Create("hae52ff4bg54e7g4eabgb930gca752c4ba072","Armour Specialist"), -- Re-added by LeaderLib
	Sourcery = ts:Create("ha8b343fbg4ebbg4e72gb58fg633850ad0580","Sourcery"),
	Telekinesis = ts:Create("h455eb073g28abg4f3bgae9dga8a592a30cdb","Telekinesis"),
	FireSpecialist = ts:Create("hf0a5a77dg132ag4517g8701g9d2ca3057a28","Pyrokinetic"),
	WaterSpecialist = ts:Create("h21354580g6870g411dgbef4g52f34942686a","Hydrosophist"),
	AirSpecialist = ts:Create("hf8056089g5b06g4a54g8dd5gf1fb9a796b53","Aerotheurge"),
	EarthSpecialist = ts:Create("h814e6bb5g3f51g4549gb3e4ge99e1d0017e1","Geomancer"),
	Necromancy = ts:Create("hb7ea4cc5g2a18g416bg9b95g51d928a60398","Necromancer"),
	Summoning = ts:Create("hac10f374gf9dbg4ee5gb5d0g7b1d3cb6d1fe","Summoning"),
	Polymorph = ts:Create("h70714d89g196eg4affga165gaa9d72a61368","Polymorph"),
	Sulfurology = ts:Create("h919b260ag66c4g4551gb4c7g793a12115cfc","Sulfurology"),
	Repair = ts:Create("hfb0ab865gb8dfg4e35g9c8dg0a8bb9445348","Repair"), -- Or h11c016c1g62a6g4e34g852dg9cc43da69d57
	Sneaking = ts:Create("h6bf7caf0g7756g443bg926dg1ee5975ee133","Sneaking"),
	Pickpocket = ts:Create("ha39a1bbeg39a3g4f52g8953g8f2f6b6ee1fa","Pickpocketing"), -- or h285c0c44g7cf1g43deg8ec7g6d6e9b7deba0
	Thievery = ts:Create("h1633e511g35e3g4e22gb999gbbf3b0d5ce5e","Thievery"),
	Loremaster = ts:Create("hb8aa942egbeaag4452gbfbcg31b493bead6e","Loremaster"),
	Crafting = ts:Create("hebe1820eg1937g4413g83bcgf02d9720d66c","Crafting"), -- or h9d0ba738g6db4g43b4gac05g864de7d1b249
	Barter = ts:Create("hcc404653ga10ag4f56g8119g11162e60f81d","Bartering"),
	Charm = ts:Create("h83638179g9e69g48e1g8c84g06b469920867","Charm"), -- Or h0fca4136gc89dg49b6gadc0gaba3e4941988 ??
	Intimidate = ts:Create("h6efd5166g9073g439fgb814gcd9186cb8e61","Intimidate"),
	Reason = ts:Create("h682664edg221eg4ab3g8eb6gc25abf00c8bf","Reason"),
	Persuasion = ts:Create("h257372d3g6f98g4450g813bg190e19aecce4","Persuasion"),
	Leadership = ts:Create("h7c65fe39g1526g427bg8a2dgab7e74c66202","Leadership"), -- Or hbcbab273g6573g4b68g810cgae231a342df0
	Luck = ts:Create("h2f9ec5acgbcbeg45b8g8058gee363e6875d5","Lucky Charm"),
	DualWielding = ts:Create("h03d68693g35e7g4721ga1b3g9f9882f08b12","Dual Wielding"),
	Wand = ts:Create("hb135e047g6d81g4e68gb805g355316f12982","Wands"), -- No Idea
	MagicArmorMastery = ts:Create("h3478fd51gb40bg4a9ega851g25a1b5e62ea5","Willpower"),
	VitalityMastery = ts:Create("h9e592393gda0fg4841gb7eegbfa847582e82","Bodybuilding"),
	Perseverance = ts:Create("h5b61fccfg5d2ag4a81g9cacg068403d61b5c","Perseverance"), -- Or hfc4ae314g920ag4fdagbc50ge73b91cfa7c7
	Runecrafting = ts:Create("h87db6c3cg511dg4db1gad59g58ace25f71d1","Rune Crafting"),
	Brewmaster = ts:Create("hab7acde6g5af6g47a7ga65dgc633aef193cf","Brew Master"),
}

---@type table<string, TranslatedString>
LocalizedText.AttributeNames = {
	Strength = ts:Create("hb4e3a075g5f82g4a0dgaffbg456e5c15c3db","Strength"),
	Finesse = ts:Create("h281c2da7g2d2bg4d69g986agfd124c7f569f","Finesse"),
	Intelligence = ts:Create("hfbc938ceg297fg4232ga11dg3fe44985b9f8","Intelligence"),
	Constitution = ts:Create("hb4cd5b0bg5731g40b3gb49bg1fa6db60f346","Constitution"),
	Memory = ts:Create("h8565e761ge486g467aga4cfg17344874f1ab","Memory"),
	Wits = ts:Create("h2b03f6f9gbf5dg4f51g9b98gf01243633ed3","Wits"),
}

---@type table<string, TranslatedString>
LocalizedText.TalentNames = {
	ActionPoints = ts:Create("h6f921734gc02bg415dg98dag0437a0bbd913", "Fleetfooted"),
	ActionPoints2 = ts:Create("h9be2e2b0gfa3ag480dgbbabgd8f49fd46e5f", "Rosy-cheeked"),
	AirSpells = ts:Create("h0b4471b4gf3cfg4eecgaf24g8526735e8d11", "Tempest"),
	Ambidextrous = ts:Create("h52b6a3cfga4dag4a3bga6fdgf5158d6d030b", "Ambidextrous"),
	AnimalEmpathy = ts:Create("h8637e196g238ag46b6gbb85gc2bbbb5e0424", "Pet Pal"),
	AttackOfOpportunity = ts:Create("ha6916b7cg086eg4d2dgb30ag80c997699e8a", "Opportunist"),
	AvoidDetection = ts:Create("h0c76874ag1d3cg48b1g9ca8g1c0765708f85", "Pussyfooter"),
	Awareness = ts:Create("h04a28dbeg50c9g42f9g9f04g50f5c4951cdf", "Sixth Sense"),
	Backstab = ts:Create("h9836a401g63f6g49c3g8fa0g9564cbad7628", "Assassin"),
	Beastmaster = ts:Create("hf7681f8fg310cg4596g91efg571d32a2bd70", "Beast Master"),
	Bully = ts:Create("h6ce94509gdf8fg4831gaf49g099d62e457f8", "Bully"),
	Carry = ts:Create("h5cf639a9g48b2g44cfgb47bg2350abc0fe0b", "Packmule"),
	ChanceToHitMelee = ts:Create("h6e2e18fcg265bg4a62g855dg51cc05443219", "Gladiator"),
	ChanceToHitRanged = ts:Create("h368525f5gf1e4g4e2ag8bf8gc5dc929deb7a", "Marksman"),
	Charm = ts:Create("hba2372ffge6deg418ag9ae7gc7b860cbcded", "Prince Charming"),
	Courageous = ts:Create("h881d0db8g9f57g44dfg9839g0f169399ed51", "Courageous"),
	Criticals = ts:Create("h6f51690dge17eg4b21g93c6g149d73c8ff74", "Killer Instinct"),
	Damage = ts:Create("hbc17d848g850dg482eg904dga57d86f1abc2", "Warlord"),
	Demon = ts:Create("h332be1ccg2610g4942g8d92g58708580c68a", "Demon"),
	DualWieldingBlock = ts:Create("", "DualWieldingBlock"),
	DualWieldingDodging = ts:Create("h3b5870dfg90e2g4b87g9328g12872063f35f", "Parry Master"),
	Durability = ts:Create("hbb931846g8f68g45cdg9f97g45afae886797", "My Precious"),
	Dwarf_Sneaking = ts:Create("h429e53b9ge574g4c77gbc1ag2cfd9844252f", "Dwarven Guile"),
	Dwarf_Sturdy = ts:Create("h477b8976gfac3g4cdag954bg5617876c6ef7", "Sturdy"),
	EarthSpells = ts:Create("h814e6bb5g3f51g4549gb3e4ge99e1d0017e1", "Geomancer"),
	ElementalAffinity = ts:Create("h11964196g2451g4dc2gbb99gba40f1f3dc2d", "Elemental Affinity"),
	ElementalRanger = ts:Create("h211a5354g7752g4d67gacffg7e07c8fd06e9", "Elemental Ranger"),
	Elf_CorpseEating = ts:Create("h8fcf368eg0abeg4314gacdcgb495473a9ade", "Corpse Eater"),
	Elf_Lore = ts:Create("hcfd646bdg491dg4d9cgaf1ag2ca5f4421f7b", "Ancestral Knowledge"),
	Escapist = ts:Create("hd8c70f78g43eeg44c9g81f2gcf16132b1e21", "Escapist"),
	Executioner = ts:Create("h51aee942g9713g493ag9467g6dff07a0f02d", "Executioner"),
	ExpGain = ts:Create("h1e39c5b6gec83g4eb5g9f29g7811024fccf7", "Quick-witted"),
	ExtraSkillPoints = ts:Create("h70fe2b7cg2c09g403ag9dd2g82b757e0d39c", "All Skilled Up"),
	ExtraStatPoints = ts:Create("hd980a2a1gc33eg4810gafc8g07f55ba70245", "Bigger And Better"),
	ExtraWandCharge = ts:Create("h8725f47dg3256g4d6agb02fg0a9c611146e8", "Magician"),
	FaroutDude = ts:Create("ha04e7d1ag8bf6g4914g82a3gdb7efab194a3", "Far Out Man"),
	FireSpells = ts:Create("h3ec565c4gbf86g4ecbg8269gcf2999fab937", "Pyromaniac"),
	FiveStarRestaurant = ts:Create("h4e3165b4gc58bg44caga271ga210f01ba582", "Five-Star Diner"),
	Flanking = ts:Create("hbb7a1718g390dg400agb5a4g9e07b758a2e8", "Sidewinder"),
	FolkDancer = ts:Create("h8fa27d2fgeb94g4475ga70ag1510273e6003", "Speedcreeper"),
	GoldenMage = ts:Create("h13b41369g85b4g4897ga277g55b06c779b4b", "Voluble Mage"),
	Human_Civil = ts:Create("h6c44d6c0g4603g429ag9f5bgc4ba0460fdec", "Thrifty"),
	Human_Inventive = ts:Create("h2646745cgf1b5g44a2gaf6ageef8ee73a923", "Ingenious"),
	IceKing = ts:Create("hb2647f59g3906g4b9bg8b96g0f3ce9518e07", "Ice King"),
	IncreasedArmor = ts:Create("h3fa29fc4gcd05g415cgab67g4dc26f815f5a", "Indestructible"),
	Initiative = ts:Create("hc4d2ebdagd523g4606gbac9g686e44aaee5a", "Leader of the Pack"),
	Intimidate = ts:Create("hcf35b10ag331ag438cga2b5gc6d873aab0a0", "Intimidator"),
	InventoryAccess = ts:Create("h1b8aeef2gf10fg4ae0g8fe7g7a053b568517", "Dress Rehearsal"),
	ItemCreation = ts:Create("hb97606efg07d3g4d71gae3ag735767403366", "Tinkerer"),
	ItemMovement = ts:Create("hbe8305f4g2b31g431ega1ffgc3f0518503ed", "Spook"),
	Kickstarter = ts:Create("h14703cb2g02e2g4befg8adcg7bf93245939b", "Kickstarter"),
	Leech = ts:Create("h4a42fa34g8674g47b2g8313g00a0d9b767a8", "Leech"),
	LightningRod = ts:Create("h37e6c2b5ge8bag4e75gaa7ag42fb8aa205a2", "Lightning Rod"),
	LightStep = ts:Create("hea860e3ag9226g41a8ga17bg0a997bf896fa", "Light Stepper"),
	LivingArmor = ts:Create("h34f3a0e4g7722g4d5fg97f8gd9b67a582c32", "Living Armour"),
	Lizard_Persuasion = ts:Create("ha4af67a7g7112g4e66gbaedg6bf024feb097", "Spellsong"),
	Lizard_Resistance = ts:Create("h7b9a0d2egff87g42afgbec4g6c01c4303401", "Sophisticated"),
	Lockpick = ts:Create("h76d7cc01g0ab7g41f4gb41eg158ae544a5d1", "Cat Burglar"),
	LoneWolf = ts:Create("hd650c4cfg77b8g42d5ga6b3g55c28fd8e4e3", "Lone Wolf"),
	Luck = ts:Create("hdab9966fgf122g475cg87feg88e08bf52e7b", "Fortune's Favourite"),
	Memory = ts:Create("heb588256ge75fg492fg8c29g3c3b5643f3db", "Mnemonic"),
	MrKnowItAll = ts:Create("hd8a824bdg56bcg4574gb32bg184b06d10564", "Know-It-All"),
	NaturalConductor = ts:Create("h0a3386f4gd52cg47b0ga63eg02582fe6720d", "Natural Conductor"),
	NoAttackOfOpportunity = ts:Create("ha08a2ddag5df0g4e9ag92f5ga34af7b1fc17", "Duck Duck Goose"),
	Perfectionist = ts:Create("h1fe3d762g3ad4g403bgbe14gfcbcf99d692a", "Hothead"),
	Politician = ts:Create("h01dd61c8gd2fdg426fgbd15g4b3f66ab663f", "Politician"),
	Quest_GhostTree = ts:Create("hb3f045a6gd7b6g49fcga080g5b7d13aee6de", "Forest's Fortune"),
	Quest_Rooted = ts:Create("h61e75d99g2d31g43d3g9de5gb523a74506e1", "Rooted"),
	Quest_SpidersKiss_Int = ts:Create("h69cf8934ge43eg4564g8c7eg35ce410cf457", "Spider Kiss"),
	Quest_SpidersKiss_Null = ts:Create("h69cf8934ge43eg4564g8c7eg35ce410cf457", "Spider Kiss"),
	Quest_SpidersKiss_Per = ts:Create("h69cf8934ge43eg4564g8c7eg35ce410cf457", "Spider Kiss"),
	Quest_SpidersKiss_Str = ts:Create("h69cf8934ge43eg4564g8c7eg35ce410cf457", "Spider Kiss"),
	Quest_TradeSecrets = ts:Create("h068a4c1dg465ag4653gb5eeg639f1ebdf539", "Trade Secrets"),
	QuickStep = ts:Create("h01248cafga159g43aaga826g214fd84dde62", "The Pawn"),
	Raistlin = ts:Create("h9ce62b0fg4219g4b8bg8844g7bec16feaa3d", "Glass Cannon"),
	RangerLoreArrowRecover = ts:Create("hfb6e0d6aga98fg4398g979agcc71ba1ec1e0", "Arrow Recovery"),
	RangerLoreEvasionBonus = ts:Create("h6a4f7786g3c96g419bgb023g8cd0d25ee9b3", "Sidestep"),
	RangerLoreRangedAPBonus = ts:Create("h67fc2341g6949g4283g8eb3g2566cbfcda83", "Quickdraw"),
	Reason = ts:Create("h84750678g16d5g45ddg9039g46459b7100e9", "Rhetorician"),
	Repair = ts:Create("h9b132ea3g89edg4d79gb9bag640fd23effb4", "Grease Monkey"),
	ResistDead = ts:Create("hb15a53dbge70eg4ca7gba85g94f17e75c0e0", "Comeback Kid"),
	ResistFear = ts:Create("h17d5a17egc177g4ea4gb0c5g235babd3ba86", "Braveheart"),
	ResistKnockdown = ts:Create("h2337ec28gb7e0g471bg8f8agcedb4bf66b8a", "Stand Your Ground"),
	ResistPoison = ts:Create("hf066c9e3g68a7g42d9gb038g12b35bc83c7a", "Mithridates"),
	ResistSilence = ts:Create("h57fbe968gc007g46d4gbee9g53360bb4c3fb", "Silver-tongued"),
	ResistStun = ts:Create("h37e6c2b5ge8bag4e75gaa7ag42fb8aa205a2", "Lightning Rod"),
	ResurrectExtraHealth = ts:Create("h958144bbg2c4ag4267g9d71g3b9080167711", "Resurrect With Extra Health"),
	ResurrectToFullHealth = ts:Create("he8b593b1g2187g47f6g9424g063cb6b60789", "Morning Person"),
	RogueLoreDaggerAPBonus = ts:Create("hd2bafc20g2692g4ac2g8c9cg957d3c671850", "Mack The Knife"),
	RogueLoreDaggerBackStab = ts:Create("hce5fda5egaeb0g4e2bg8c94g595c0cd029b3", "Backstabber"),
	RogueLoreGrenadePrecision = ts:Create("hc0ab97b9g95dbg461fg9b8eg4601142ae50a", "Pinpoint"),
	RogueLoreHoldResistance = ts:Create("h4e0cb65dg11e1g4195gbf29gc2e12d310d25", "Headstrong"),
	RogueLoreMovementBonus = ts:Create("h9c905ad9g5c9ag4566g957bgefb4d45eefd5", "Swift Footed"),
	Scientist = ts:Create("h5ca84506g2110g4cdeg923cgb409350183d9", "Scientist"),
	Sight = ts:Create("h15361d26g3894g4dd1gb726ga9d81cf84138", "Hyperopia"),
	SpillNoBlood = ts:Create("h54fdcb17g804bg499eg8a8egc562dbfe0a24", "Anaconda"),
	StandYourGround = ts:Create("h2337ec28gb7e0g471bg8f8agcedb4bf66b8a", "Stand Your Ground"),
	Stench = ts:Create("hdebdc54fg082dg4973ga6e8g54695c64fb9a", "Stench"),
	SurpriseAttack = ts:Create("hd82e253fg4915g4275g883bgd61ec85f22b7", "Guerrilla"),
	Throwing = ts:Create("h43453702gb543g454dg9755g22b76c8209ae", "Catapult"),
	Torturer = ts:Create("hec141b07gb2e6g4283g8006gd94adc63d734", "Torturer"),
	Trade = ts:Create("hecd2ef6cgdd5bg4844ga65fg01193fb2326d", "Trader's Tongue"),
	Unstable = ts:Create("hb95f314agabcfg45e9g942ege43b8c9adaa5", "Unstable"),
	ViolentMagic = ts:Create("hfb87cc03g1dc0g4095g93efg0becba59f352", "Savage Sortilege"),
	Vitalty = ts:Create("h8d63a08agaee1g4184g8a26g588784aa55de", "Picture of Health"),
	WalkItOff = ts:Create("h3f059078g65efg4ea9g8514g7175404a276e", "Walk It Off"),
	WandCharge = ts:Create("h8725f47dg3256g4d6agb02fg0a9c611146e8", "Magician"),
	WarriorLoreGrenadeRange = ts:Create("h86bee297g3f52g425egbef7g5057f1ee930d", "Slingshot"),
	WarriorLoreNaturalArmor = ts:Create("hfef25ef5g6e0dg4a54g8fa3g1f464130a469", "Thick Skin"),
	WarriorLoreNaturalHealth = ts:Create("h618f5bcbg76dbg4941g8611gf3a1d50f297e", "Picture Of Health"),
	WarriorLoreNaturalResistance = ts:Create("ha1b1543eg1df1g4c92ga08ag0fd9ef3ef355", "Weather The Storm"),
	WaterSpells = ts:Create("h5893d609g682bg49c0g9872g395016a50e50", "Rainman"),
	WeatherProof = ts:Create("h476e2244gf088g49e5ga32agc39039659145", "Weatherproof"),
	WhatARush = ts:Create("hf562d566g65d6g46c8g8e27g429bb4d3cf8b", "What A Rush"),
	Zombie = ts:Create("hffa022a2g03b0g46f7g8ee6gcb8e5811a4d3", "Undead"),
	PainDrinker = ts:Create("hc07b1f2ag23b4g42d4g8d11g1b9e54a2ea8a", "Pain Drinker"),
	DeathfogResistant = ts:Create("hcf141983g4e08g405dg83bcg3f66636aa9ec", "Deathfog Resistant"),
	Sourcerer = ts:Create("h5279a104g5c7ag4d0fgb191gc963d39c286c", "Sourcerer"),
	Rager = ts:Create("he1b6d26dgfa57g4878g8948g68f08c6c531f", "Rager"),
	Elementalist = ts:Create("h8d9e4cc0g448dg40b0g9936gbd7cb0098f46", "Elementalist"),
	Sadist = ts:Create("h1ba5c933g7a30g4d1fg99c0gc266fb5a0d12", "Sadist"),
	Haymaker = ts:Create("h53a20ccfgf169g4e61ga093g1e0586b73318", "Haymaker"),
	Gladiator = ts:Create("hba13af60g3ff2g4927gac9dgb98029a1873f", "Gladiator"),
	Indomitable = ts:Create("h37ab421bgc879g4e3cgabdegf6ec70854bea", "Indomitable"),
	WildMag = ts:Create("h42bc6d05g85f4g4315gaa8bg5ec6073f74ea", "Wild Mag"),
	Jitterbug = ts:Create("h34c2dbe0g49e4g40cdgb6bcgbc19f73b7a06", "Jitterbug"),
	Soulcatcher = ts:Create("hc6caa349gcb41g4976g8257gae9fc52b6031", "Soulcatcher"),
	MasterThief = ts:Create("h2a458c89g1c51g47c9ga6dbg6d507dc10022", "Master Thief"),
	GreedyVessel = ts:Create("h1d99c24eg60a0g424dg8fa5gd184f6b7cb4f", "Greedy Vessel"),
	MagicCycles = ts:Create("h4564bbfbgd845g4318g97e7ge85f5923b323", "Magic Cycles"),
}

---@type table<string, TranslatedString>
LocalizedText.Slots = {
	Helmet = ts:Create("hd4b98ff5g33a8g44e0ga6a9gdb1ab7d70bf3", "Helmet"),
	Breast = ts:Create("hb5c52d20g6855g4929ga78ege3fe776a1f2e", "Chest Armour"),
	Leggings = ts:Create("he7042b52g54d7g4f46g8f69g509460dfe595", "Leggings"),
	Weapon = ts:Create("h102d1ef8g3757g4ff3g8ef2gd68007c6268d", "Weapon"),
	Shield = ts:Create("h77557ac7g4f6fg49bdga76cg404de43d92f5", "Shield"),
	Ring = ts:Create("h970199f8ge650g4fa3ga0deg5995696569b6", "Ring"),
	Belt = ts:Create("h2a76a9ecg2982g4c7bgb66fgbe707db0ac9e", "Belt"),
	Boots = ts:Create("h9b65aab2gf4c4g4b81g96e6g1dcf7ffa8306", "Boots"),
	Gloves = ts:Create("h185545eagdaf0g4286ga411gd50cbdcabc8b", "Gloves"),
	Amulet = ts:Create("hb9d79ca5g59afg4255g9cdbgf614b894be68", "Amulet"),
	Ring2 = ts:Create("h970199f8ge650g4fa3ga0deg5995696569b6", "Ring"),
	Wings = ts:Create("hd716a074gd36ag4dfcgbf79g53bd390dd202", "Wings"),
	Horns = ts:Create("ha35fc503g56dbg4adag963dga359d961e0c8", "Horns"),
	Overhead = ts:Create("hda749a3fg52c0g48d5gae3bgd522dd34f65c", "Overhead"),
	Offhand = ts:Create("h50110389gc98ag49dbgb58fgae2fd227dff4", "Offhand"),
}

LocalizedText.ItemBoosts = {
	ResistancePenetration = ts:Create("hf638bc67g5cb6g4dcfg8663gce1951caad2b", "[1] Penetration")
}

-- <content contentuid="h9b6e0ed8g07afg413dg939fg5d5b91a9461c">Next level costs [1] ability point(s)</content>

LocalizedText.UI = {
	AbilityPlusTooltip = ts:Create("h9b6e0ed8g07afg413dg939fg5d5b91a9461c", "Next level costs [1] ability point(s)"),
	Confirm = ts:Create("h0fb8bf07g3932g4ccbg8659g2f4f5aa7dd82", "Confirm"),
	Close = ts:Create("h9eed6c77g31bbg4637g9332g30e47efcd7eb", "Close"),
	OK = ts:Create("h1cb63048g62e1g4b86gac15gb333158c2c81", "OK"),
	Yes = ts:Create("hf52bf842g05beg48dega717gca15b3678e0e", "Yes"),
	No = ts:Create("heded8384gb4f5g439dg9883g5cf950b2bbfc", "No"),
}

LocalizedText.ContextMenu = {
	HideStatus = ts:Create("h901ab1b9g943dg465cg8583g3ad8e86354b5", "Hide Status"),
	HideStatus_Examine = ts:Create("hc9377dd3g70d6g4d84g8c8fg812246a61029", "Hide Status from Portrait UI"),
	ShowStatus = ts:Create("h456c5c8bg7103g4b19g9185ge4cd6ddbab30", "Show Status in Portrait UI"),
}

LocalizedText.SkillTooltip = {
	SkillRequiredEquipment = ts:Create("h0a088d84g04f9g47b5g8d4dg3021748bfe00", "Requires a [1]"),
	RifleWeapon = ts:Create("ha3a18e3fge9e4g4496g84b8g5590844143f0", "Rifle Weapon"),
	SafeForce = ts:Create("h788df33dg4d61g4cb7g8f2cgfb75e14e7ffc", "Pushes [1]m")
	--BasicAttack = ts:Create("hbdac34fdg43b6g4439g9947g6676e9c03294", "Basic Attack")
}

LocalizedText.WeaponType = {
	Rifle = ts:Create("h4120c4e5g4931g46dbgad0fga7a57514ac42", "Rifle")
}

LocalizedText.Tooltip = {
	AutoLevel = ts:Create("hca27994egc60eg495dg8146g7f81c970e265", "<font color='#80FFC3'>Automatically levels up with the wearer.</font>"),
	ExtraPropertiesOnHit = ts:Create("h3eff6bc1gb26dg4bb5gb3b9g2551c65026e0", "Apply On Hit:<br>[1] for [2] turns(s). ([3] Chance)"),
	ExtraPropertiesPermanent = ts:Create("h233bf83cg2204g4f14gb46agad27f95deb43", "Set [1].[2][3]"),
	ExtraPropertiesWithTurns = ts:Create("hf90daa3cgba5cg471cgbebcgedb58a337a9f", "Set [1] for [4] turn(s).[2][3]"),
	ChanceToSucceed = ts:Create("h54e0b91cg48a7g4d5agaedcgbde756a109ea", "[1]% chance to succeed."),
	ScalesWith = ts:Create("h565537edgdec5g4483g938fg296519760088", "Scales With [1]"),
	Requires = ts:Create("h7de69a95g70cag4bb3gbabcg1cf2df46f12c", "Requires [1]"),
	ExpanderInactive = ts:Create("h17380891g0e8eg42d3gbb55g9478bba4f684", "Hold [1] for More Info"),
	ExpanderActive = ts:Create("h7b3bd7e6g9a34g4959gad11g241f6d8d33c1", "Release [1] for Less Info"),
}

LocalizedText.Input = {
	Shift = ts:Create("hbb74f5fag4e95g4e8fgb2b8g2a761e814bd5", "Shift"),
	Select = ts:Create("hdf10e5a7g950eg4f82gb716ga5a614c00811", "Select"),
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
	PureResistance = {Text=ts:Create("h71766947g9564g4a6bg936bga055cccc01a0","Pure Resistance"), Color="#13D177"}, -- Special LeaderLib handle
	PhysicalResistance = {Text=ts:Create("hcd84ee03g9912g4b0dga49age6bce09b19d1","Physical Resistance"), Color="#AE9F95"},
	PiercingResistance = {Text=ts:Create("he840ff3eg35e6g4e06ga987g970ebee744e3","Piercing Resistance"), Color="#CD1F1F"},
	CorrosiveResistance = {Text=ts:Create("hacc27ae5gfaf0g4854g85a6ga57d5be46dc5","Corrosive Resistance"), Color="#88A25B"},
	MagicResistance = {Text=ts:Create("h8bfd4518ge6deg47a2g90a6g541f5ba1ba88","Magic Resistance"), Color="#7F00FF"},
	ChaosResistance = {Text=ts:Create("h17e6d1bbgbe95g4944gb37dgfe5059a58a2d","Chaos Resistance"), Color="#9A00FF"},-- Special LeaderLib handle
	AirResistance = {Text=ts:Create("h134d72acgdd42g4c2dg97a8g6df0af2802a5","Air Resistance"), Color="#7D71D9"},
	EarthResistance = {Text=ts:Create("hac36ad5ag557fg4456ga0edga5a40606fabb","Earth Resistance"), Color="#F7BA14"},
	FireResistance = {Text=ts:Create("he04c3934g32b0g455fgac3dg75f2b7fd2119","Fire Resistance"), Color="#FE6E27"},
	PoisonResistance = {Text=ts:Create("he526af2ag192cg4a71g8247gb306eb0eb97d","Poison Resistance"), Color="#65C900"},
	ShadowResistance = {Text=ts:Create("hef0c737eg2a72g4564ga5cfg088484ac8b45","Shadow Resistance"), Color="#797980"}, -- Technically Tenebrium
	WaterResistance = {Text=ts:Create("he5441d99gdb3cg40acga0c4g24379b8b09f7","Water Resistance"), Color="#4197E2"},
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
	local text = Ext.GetTranslatedString(handle, ref) or fallback
	return text
end

GameHelpers.GetStringKeyText = GetStringKeyText