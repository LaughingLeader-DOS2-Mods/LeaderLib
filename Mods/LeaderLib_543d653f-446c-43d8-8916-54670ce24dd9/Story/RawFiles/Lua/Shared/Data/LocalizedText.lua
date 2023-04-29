local ts = Classes.TranslatedString

---@class ColoredTranslatedStringEntry
---@field Text TranslatedString
---@field Color string

LocalizedText.DamageTypeHandles = {
	None = {Text=ts:Create("h8a070775gc251g4f34g9086gb1772f7e2cff","pure damage"), Color="#13D177"},
	Physical = {Text=ts:Create("h40782d69gbfaeg40cegbe3cg370ef44e3980","physical damage"), Color="#AE9F95"},
	Piercing = {Text=ts:Create("hd05581a1g83a7g4d95gb59fgfa5ef68f5c90","piercing damage"), Color="#CD1F1F"},
	Corrosive = {Text=ts:Create("h161d5479g06d6g408egade2g37a203e3361f","Physical Armour"), Color="#88A25B"},
	Magic = {Text=ts:Create("hdb4307b4g1a6fg4c05g9602g6a4a6e7a29d9","Magic Armour"), Color="#7F00FF"},
	Chaos = {Text=ts:Create("h2bc14afag7627g4db8gaaa6g19c26b9820d5","chaos damage"), Color="#9A00FF"},-- Special LeaderLib handle
	Air = {Text=ts:Create("hdd80e44fg9585g48b8ga34dgab20dc18f077","air damage"), Color="#7D71D9"},
	Earth = {Text=ts:Create("h68b77a37g9c43g4436gb360gd651af08d7bb","earth damage"), Color="#7F3D00"},
	Fire = {Text=ts:Create("hc4d062edgd8e6g4048gaa44g160fe3c7b018","fire damage"), Color="#FE6E27"},
	Poison = {Text=ts:Create("ha77d36b3ge969g4461g9b30gfff624024b18","poison damage"), Color="#65C900"},
	Shadow = {Text=ts:Create("h256557fbg1d49g45d9g8690gb86b39d2a135","shadow damage"), Color="#797980"},
	Water = {Text=ts:Create("h8cdcfeedg357eg4877ga69egc05dbe9c68a4","water damage"), Color="#4197E2"},
	Sulfuric = {Text=ts:Create("h12d0bc64gdf1dg424egaf04g644417604184","sulfuric damage"), Color="#C7A758"},-- Special LeaderLib handle
	Sentinel = {Text=ts:Create("h972f1d0cgbce6g4a8fg8ab4g02430e78b2b4","unknown damage"), Color="#008858"}, -- Special LeaderLib handle
}

LocalizedText.DamageTypeNames = {
	None = {Text=ts:Create("h37e16e2cgb2c7g46a6g942egb35eb0a825f1","Pure"), Color="#13D177"},
	Physical = {Text=ts:Create("ha6c38456g4c6ag47b2gae87g60a26cf4bf7b","Physical"), Color="#AE9F95"},
	Piercing = {Text=ts:Create("h22f6b7bcgc548g49cbgbc04g9532e893fb55","Piercing"), Color="#CD1F1F"},
	Corrosive = {Text=ts:Create("h727b2365g5cd3g4557g8627ge9612ab59420","Corrosive"), Color="#88A25B"},
	Magic = {Text=ts:Create("h02e0fcacg670eg4d35g9f20gcf5cddab7fd1","Magic"), Color="#7F00FF"},
	Chaos = {Text=ts:Create("hf43ec8a1gb6c4g421dg983cg01535ee1bcdf","Chaos"), Color="#9A00FF"},-- Special LeaderLib color
	Air = {Text=ts:Create("h1cea7e28gc8f1g4915ga268g31f90767522c","Air"), Color="#7D71D9"},
	Earth = {Text=ts:Create("h85fee3f4g0226g41c6g9d38g83b7b5bf96ba","Earth"), Color="#7F3D00"},
	Fire = {Text=ts:Create("h051b2501g091ag4c93ga699g407cd2b29cdc","Fire"), Color="#FE6E27"},
	Poison = {Text=ts:Create("haa64cdb8g22d6g40d6g9918g61961514f70f","Poison"), Color="#65C900"},
	Shadow = {Text=ts:Create("hf4632a8fg42a7g4d53gbe26gd203f28e3d5e","Shadow"), Color="#797980"},
	Water = {Text=ts:Create("hd30196cdg0253g434dga42ag12be43dac4ec","Water"), Color="#4197E2"},
	Sulfuric = {Text=ts:Create("h1da479e7gc4e2g4748g8234g754e97a4b680","Sulfuric"), Color="#C7A758"},-- Special LeaderLib handle
	Sentinel = {Text=ts:Create("h00b235c6gdd0bg494fg997cga2d204f060a8","Unknown"), Color="#008858"}, -- Special LeaderLib handle
}

---A table of sorted damage types, in alphabetical order of the localized name. Initialized on SessionLoaded.
---@type string[]
LocalizedText.DamageTypeNameAlphabeticalOrder = {}

--MagicArmorMasteryDescription = ts:Create("h211cb400g5881g4b90g8bc8g0399d0288e00","Willpower determines how resistant you are to mental statuses like Fear or Charm."),
--VitalityMasteryDescription = ts:Create("h2c42b179gd34bg45f8g9a81g847315e0319c","Bodybuilding determines how resistant you are to physical statuses like Bleeding or Crippled."),

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
	PainReflection = ts:Create("h591d7502gb8c3g443cg86ebga0b3a903155a", "Retribution"), -- Or h19487a02g5b86g4129ga879g0ec268a9f50b
	Runecrafting = ts:Create("h87db6c3cg511dg4db1gad59g58ace25f71d1","Rune Crafting"),
	Brewmaster = ts:Create("hab7acde6g5af6g47a7ga65dgc633aef193cf","Brew Master"),
}

LocalizedText.AbilityDescriptions = {
	WarriorLore = ts:Create("hae8649cfg3688g43b4gb137gdae29b32492e", "[1] increases all Physical damage you deal."),
	RangerLore = ts:Create("h3a0e0946g2b6bg49d4g93c2g9e61ee4910cd", "[1] increases the damage bonus when attacking from high ground."),
	RogueLore = ts:Create("h60a27d9cg35fag451cga251gbd01c84d033b", "[1] increases movement speed and boosts your Critical Modifier."),
	SingleHanded = ts:Create("h751cb9fcgcc15g485fg80dag96d013bb5fff", "[1] increases damage and Accuracy when using a single-handed weapon (dagger, sword, axe, mace or wand) with a shield or empty off-hand."),
	TwoHanded = ts:Create("h206ce4abg4f84g4b2dg934aga0d96a602f2c", "[1] increases damage and the Critical Multiplier when using two-handed melee weapons (sword, axe, mace, spear or staff)."),
	PainReflection = ts:Create("hded47ed1gcc2eg4ce8g9277g5ee6b7204293", "[1] reflects received damage to your attacker."),
	Ranged = ts:Create("h54f2ea13g97dbg4b86g9d13geeb81186faca", "[1] increases damage and Critical Chance when using bows and crossbows."),
	Shield = ts:Create("h0c8d8c87g11c9g4d2dg804dg372552dd6939", "[1] improves your damage and armour when using one handed weapon with a shield."),
	Reflexes = ts:Create("h0ac15e33g806bg4d83g94cdg394dc6192073", "[1] improves Dodging."),
	PhysicalArmorMastery = ts:Create("h7c6cf982g3e67g47c2ga455gca2a8c5eba70", "[1] increases your total amount of Physical Armour."),
	MagicArmorMastery = ts:Create("h034670fdg3faag453cgb7ceg6b1feb19e27d", "[1] increases your total amount of Magic Armour."),
	VitalityMastery = ts:Create("h0307d682gd10cg45d3gae2bgff9f8529b93c", "[1] increases your total amount of Vitality."),
	Sourcery = ts:Create("h94888701g37e3g49edgae2dg427bbbf84ce8", "Improves [1] skills."),
	FireSpecialist = ts:Create("he4bae728g9ec0g482cgaa22g21796d72983f", "[1] increases all Fire damage you deal."),
	WaterSpecialist = ts:Create("hbac7843eg0419g4685ga4d6g5aab9302a18a", "[1] increases all Water damage you deal, and any Vitality healing or Magic Armour restoration that you cause."),
	AirSpecialist = ts:Create("h5241e098gbfa7g4091gb6eaga7a3a61683ce", "[1] increases all Air damage you deal."),
	EarthSpecialist = ts:Create("hc5c3b4a8g0f31g45deg873ag413f99d89910", "[1] increases all Poison and Earth damage you deal, and any Physical Armour restoration you cause."),
	Necromancy = ts:Create("he52dcf72g081eg4f4fgb24fg692f73242b73", "[1] heals you whenever you deal damage directly to Vitality."),
	Summoning = ts:Create("h1d6340c5g7f22g4db4ga12agae3143d9a292", "[1] increases Vitality, Damage, Physical Armour and Magic Armour of your summons and totems."),
	Polymorph = ts:Create("hde85b3faga9aag4420g9089gc7e6eee20084", "[1] provides 1 free Attribute Point per point invested."),
	Telekinesis = ts:Create("hd3883f56g7daag44a3g9779gb43982022372", "[1] allows you to move items telepathically regardless of weight."),
	Repair = ts:Create("hd2674a06g6033g4347g9497g2a9e1836e83e", "[1] allows you to repair your own items. The higher, the faster you repair. Required to create and improve weapons and armour if any metal is involved."),
	Sneaking = ts:Create("hd9df7e13ge3d4g4aabga798g7caabc9f9f27", "[1] determines how well you can sneak without getting caught."),
	Pickpocket = ts:Create("h8a7f77e5ga69ag4ccegbf4dg7a5d73a8729f", "[1] determines what you can steal and who you can successfully pickpocket."),
	Thievery = ts:Create("h14501134g13d5g4753g9185gfc1ddb638635", "[1] improves your lockpicking and pickpocketing skills."),
	Loremaster = ts:Create("ha6e5ee5aga554g4f4cg8785gb0c60e78f4fd", "[1] identifies enemies and allows you to identify items. Increasing [1] allows you to identify more, faster."),
	Crafting = ts:Create("he400bf50ge94dg4d1dga9d1g98c613a5bef6", "[1] determines what you can craft and the quality of your crafted items. The higher, the faster you craft."),
	Barter = ts:Create("h0fa52e51gac65g465fga278g42977446ccfa", "[1] improves your haggling skills. With each point invested, traders' items become cheaper and your items become more expensive."),
	Charm = ts:Create("hd24694f2g67f5g402eg8525gf970bf3d0d0b", "[1] determines how well you can Charm in dialogues."),
	Intimidate = ts:Create("h10ba8d7dg2e9eg4e6dga916g52afdfd7e33f", "[1] determines how well you can Intimidate in dialogues."),
	Reason = ts:Create("he272c8ebg2b59g48d3g9005gc30e88ab501f", "[1] determines how well you can Reason in dialogues."),
	Persuasion = ts:Create("h25fd04d8g8062g4791ga132g5732d389ec82", "[1] helps you convince characters to do your bidding in dialogues, and increases how much characters like you."),
	Leadership = ts:Create("h8256bf13gb4cag4662gaafegb5724b210c92", "[1] grants Dodging and Resistance bonuses to all allies in a 8m radius."),
	Luck = ts:Create("h81aaba21gf061g4643g8217g985692485151", "[1] increases your likelihood of finding extra treasure wherever loot is stashed."),
	DualWielding = ts:Create("h768669d0g02adg48f7g901eg83068a96bf19", "[1] increases damage and Dodging when dual-wielding two one-handed weapons."),
	Wand = ts:Create("h61202687g650bg4b03gad57g0a62ead1aa9c", "[1] increases damage of main hand wand attacks."),
	Perseverance = ts:Create("h1bae56a9ga45fg431fg80bfg2afbef03c1d2", "[1] restores Magic Armour after you recover from [2] or [3], and restores Physical Armour after [4] or [5]."),
	Runecrafting = ts:Create("ha9e388f3gc8c9g4137gb1b6g7913d91a8eb7", "[1] determines the level of runes you can insert into or extract from equipment. Increasing [1] allows you to use more advanced runes."),
	Brewmaster = ts:Create("h1c35dfdeg4d5cg49eag89e7gaf21acb29287", "[1] determines which potions you can brew and the quality of your brewed potions."),
	Sulfurology = ts:Create("hf48f945bg2eb3g4036g9d66g9605658da0bc", "[1] increases all Explosive damage you deal."),
}

LocalizedText.SkillAbility = {
	None = ts:Create("h4bd36f71g030cg41bega79ega89506adf728","Special"),
	Warrior = LocalizedText.AbilityNames.WarriorLore,
	Ranger = LocalizedText.AbilityNames.RangerLore,
	Rogue = LocalizedText.AbilityNames.RogueLore,
	Source = LocalizedText.AbilityNames.Sourcery,
	Fire = LocalizedText.AbilityNames.FireSpecialist,
	Water = LocalizedText.AbilityNames.WaterSpecialist,
	Air = LocalizedText.AbilityNames.AirSpecialist,
	Earth = LocalizedText.AbilityNames.EarthSpecialist,
	Death = LocalizedText.AbilityNames.Necromancy,
	Summoning = LocalizedText.AbilityNames.Summoning,
	Polymorph = LocalizedText.AbilityNames.Polymorph,
	Sulfurology = LocalizedText.AbilityNames.Sulfurology,
}

LocalizedText.AttributeNames = {
	Strength = ts:Create("hb4e3a075g5f82g4a0dgaffbg456e5c15c3db","Strength"),
	Finesse = ts:Create("h281c2da7g2d2bg4d69g986agfd124c7f569f","Finesse"),
	Intelligence = ts:Create("hfbc938ceg297fg4232ga11dg3fe44985b9f8","Intelligence"),
	Constitution = ts:Create("hb4cd5b0bg5731g40b3gb49bg1fa6db60f346","Constitution"),
	Memory = ts:Create("h8565e761ge486g467aga4cfg17344874f1ab","Memory"),
	Wits = ts:Create("h2b03f6f9gbf5dg4f51g9b98gf01243633ed3","Wits"),
}

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

LocalizedText.TalentDescriptions = {
	ItemMovement = ts:Create("h8143aa7fge201g49cagb53bg4d79f5239f00", "[1] improves your telekinetic abilities."),
	ItemCreation = ts:Create("h5351657cg21cag4cf3g8a0cgf37cdea35602", "[1] improves your ability to brew potions, prepare food, write scrolls..."),
	Flanking = ts:Create("h9ff27273g73cbg493cg8beage447e6da1644", "[1] removes the Dodging penalty when flanked."),
	AttackOfOpportunity = ts:Create("ha323378egb5f6g451cg858dged752a3540ca", "[1] gives you the ability to perform attacks of opportunity."),
	Backstab = ts:Create("h39f1dfedg93f0g48bega382g17d1d9f2b373", "[1] allows you to backstab enemies with weapons other than a knife."),
	Trade = ts:Create("hdad95974g8d9fg4541ga4c5gf138f1f1f5c3", "[1] improves your bartering techniques."),
	Lockpick = ts:Create("he5034744g0d0bg4d1dgbd4dg3b8532a501ec", "[1] improves your aptitude at picking locks."),
	ChanceToHitRanged = ts:Create("hd79dc27cg8215g4839gbc4ag6553902cdb45", "[1] improves your chances to hit an opponent with ranged weapons in battle."),
	ChanceToHitMelee = ts:Create("hc453c48fg7b72g479fgbc25gd3a2ba400219", "[1] improves your chances to hit an opponent with melee weapons in battle."),
	Damage = ts:Create("hb33aa02dgbc3eg4f98g89e4gcf0876c381f5", "[1] increases the overall damage by [2]%."),
	ActionPoints = ts:Create("hfd722f87g522bg41f9ga1beg04c47bbe1b0c", "[1] increases your maximum Action Points by [2]."),
	ActionPoints2 = ts:Create("hfd722f87g522bg41f9ga1beg04c47bbe1b0c", "[1] increases your maximum Action Points by [2]."),
	Criticals = ts:Create("h786a4955g7116g42eeg9dc8gd8932fbf6d50", "[1] improves your chance to land critical hits by [2]%."),
	IncreasedArmor = ts:Create("h18ffa51eg1f49g4e0bg9000g14cf844213b8", "[1] improves your armour rating."),
	Sight = ts:Create("h5a63b4bcga3cbg472ag8bffg777881da218a", "[1] makes you farsighted, causing your ranged attacks to be precise at long distances, but miss frequently if your target is close."),
	ResistFear = ts:Create("h224f7442gc0fdg4f51gb681g000365c8e90b", "[1] increases your ability to resist fear by [2]%."),
	ResistKnockdown = ts:Create("h9548c578g12bfg4044ga4f0g78fa3b8f1ae5", "[1] increases your ability to resist knockdown attacks by [2]%."),
	ResistStun = ts:Create("h30e145d0g5b67g4acagbd6eg91348e9759f9", "[1] increases your ability to resist stun attacks by [2]%."),
	ResistPoison = ts:Create("h73d2e1aagd32ag493eg9789g29787126910b", "[1] increases your ability to resist poison by [2]%."),
	ResistSilence = ts:Create("h6c51531cg07bfg49b5ga9c0g103614058dfa", "[1] increases your ability to resist being silenced by [2]%. (When silenced you can no longer cast spells until the effect wears off.)"),
	ResistDead = ts:Create("he32b97bcg4cf5g4918g8a91gd45e7cab39be", "Once per combat, if an enemy lands a fatal blow, [1] will help you bounce back to life with [2]% health. If you die and are resurrected in combat, [1] will be available again."),
	Carry = ts:Create("h50ccd3ebg9a48g43fdgacccg51d87e776671", "[1] increases the amount of weight you can carry."),
	Throwing = ts:Create("hde17544dg4d2fg4274g9cd1g93f784252f9f", "[1] increases the distance you can throw objects and how heavy they can be."),
	Repair = ts:Create("hb77afffbg7654g48d5g9784g2e08bdaf7650", "[1] improves your ability to repair damaged items."),
	ExpGain = ts:Create("hc2c75079g0c68g48aag9edcg1635c14fd87d", "[1] increases the rate at which you gain experience by [2]%."),
	ExtraStatPoints = ts:Create("hfc8981a1g8f84g49c8ga8b4g17564a836c45", "[1] immediately grants you [2] extra attribute point to spend."),
	ExtraSkillPoints = ts:Create("hf3893f8fg20c5g4078ga83cgef8783082103", "[1] immediately gives you [2] extra Combat ability point(s) and [3] extra Civil ability point(s)."),
	Durability = ts:Create("ha43c6246g7c02g4281g8374g9cb63fbb2abf", "With [1], every time you hit or get hit, your gear has a [2]% chance not to lose durability."),
	Awareness = ts:Create("hbea47d88ge9b1g4383gb0bag0b7fef2a7676", "[1] increases your ability to hear and spot (hidden) things in and out of combat."),
	Vitality = ts:Create("hf01635b9gf1f3g4de7ga9b4g1402d90d7613", "[1] increases your hitpoints total by [2]%."),
	FireSpells = ts:Create("h128de25cg050eg4558g9cb6g7d211492af57", "[1] improves your casting ability of fire-based spells."),
	WaterSpells = ts:Create("hece43274geac4g4f00g8df9gd95a5e06e9fb", "[1] improves your casting ability of water-based spells."),
	AirSpells = ts:Create("hc30930ecg7964g4f74g8da2g8bc39e7bacc5", "[1] improves your casting ability of air-based spells."),
	EarthSpells = ts:Create("h7f278b40gaa0eg4edcga4c6g92de77e1c04c", "[1] improves your casting ability of earth-based spells."),
	Charm = ts:Create("h349badc6gb093g4527g8f5fge03b7d8699a5", "[1] improves the ability to charm people during dialogue."),
	Intimidate = ts:Create("hd2d023ddg3911g4d4fga1d3g358bf3c678f8", "[1] improves the ability to intimidate people during dialogue."),
	Reason = ts:Create("h451b4348g12d9g4b79g9f3bg7f9260b8f53a", "[1] improves the ability to reason with people during dialogue."),
	Luck = ts:Create("hdb1b7101gde25g45bfgb246g63f2b59b96f0", "[1] increases your overall luck."),
	Initiative = ts:Create("hb02edec5g0dedg4b21gb7b6gaf70873d9143", "[1] increases your initiative by [2] at the onset of combat."),
	InventoryAccess = ts:Create("h105745ffgaa63g4816g93fdgdd9992e2a337", "[1] decreases the amount of Action Points it takes to equip different items during combat."),
	AvoidDetection = ts:Create("h791bf8b0gebe5g4583g9456g8bc58c70c77f", "[1] makes you less prone to be detected while performing suspicious acts."),
	AnimalEmpathy = ts:Create("h42b4c1e3g7c07g400dg8924g2807a024e6bb", "[1] enables you to talk to animals."),
	Escapist = ts:Create("hcb8f9837gdf0fg4a01ga7d6g5ed522b74189", "[1] allows you to flee combat even when enemies are right next to you."),
	StandYourGround = ts:Create("hd3951d31gd5a1g430bg9988g5adc3465f6ae", "A character with [1] cannot be Knocked Down."),
	SurpriseAttack = ts:Create("hb6ef5200g4cd4g48dag8006gac3dc3e8aa51", "While sneaking, [1] increases attack damage by [2]%. Also reduces cost of entering sneak mode by [3] AP."),
	LightStep = ts:Create("heb79a487g4757g4252g9775gbbdc437699e4", "[1] gives you a +[2] Wits bonus to detecting traps."),
	ResurrectToFullHealth = ts:Create("h278b2bccg1afcg4314gbfcbgb10105ebc12b", "When resurrected, you resurrect to full health."),
	Scientist = ts:Create("h9dfd9964g46e9g421aga42fge77eca278e1e", "[1] gives you a bonus point in [2] and one in [3]."),
	Raistlin = ts:Create("h46770f2agdbb8g47eag9e0eg65ac47bde918", "With [1], you start every combat round with Maximum AP, but Magic and Physical Armour do not protect you from statuses."),
	MrKnowItAll = ts:Create("hd0c4c763gc5deg4381gb73eg59493fa5232b", "[1] decreases everyone's attitude towards you by [2], but gives you [3] extra point in [4]."),
	WhatARush = ts:Create("hd7c21999g602cg4497gaa65g41507b81eda1", "[1] increases your recovery and maximum Action Points by [2] when your health is below [3]%."),
	FaroutDude = ts:Create("h6f77e8f2g044eg44a8gacb8g64457aac8c8f", "[1] increases the range of skills and scrolls by [2]m. Does not affect melee and touch-range skills."),
	Leech = ts:Create("h81ca938fg5ef4g452agb093g1294e2f0718b", "[1] heals you when standing in blood."),
	ElementalAffinity = ts:Create("h3886606fg0cc0g49b9g9bbcg3ea8baa4c040", "[1] lowers the Action Point cost of spells by [2] when standing in a surface of the same element."),
	FiveStarRestaurant = ts:Create("hd2ce8051g60adg4d7ega77cg86b745bd1b5c", "[1] doubles the effects of food and potions."),
	Bully = ts:Create("h653df73ag9464g423fgad5ag09d19dbd8ad4", "[1] gives you [2]% extra damage against opponents that are Slowed, Crippled or Knocked Down."),
	ElementalRanger = ts:Create("h7a2f1a05g4b52g4ec2g8354g1f92a8bf442d", "Shooting arrows will inflict bonus elemental damage depending on the surface your target is standing in."),
	LightningRod = ts:Create("ha4c23394ge3d0g42d1ga894g577379e4e6f9", "[1] makes you immune to stun."),
	Politician = ts:Create("hc0850870g2eebg4bc6gbda9g161bd04d63cd", "[1] gives you 2 bonus points in [2], but you lose a point in Intelligence."),
	WeatherProof = ts:Create("hcb3f875fg901eg406bg8ae3g315c4fa67509", "[1] makes you immune to environmental effects."),
	LoneWolf = ts:Create("hbaf5c48eg86eeg4947gb884g6508d4dbd1fe", "[1] provides +[2] Max AP, +[3] Recovery AP, +[4]% Vitality, +[5]% Physical Armour, +[6]% Magic Armour, and doubles invested points in attributes - up to a maximum of 40 - and combat abilities (except Polymorph ability) - up to a maximum of 10 - while you are adventuring solo or with at most one companion. This bonus is temporarily removed while there are more than two members in the current party."),
	Zombie = ts:Create("hf9a4b3bbgddefg469fg8170ga44988007e2a", "[1] lets you heal from poison, but regular healing will damage you instead. You will receive Poisoned status even if you have Magic Armour."),
	Demon = ts:Create("hc453e399ge1f5g41f1gaeabgcdd4de833c63", "A character with [1] has an extra [2]% [3], but takes a [4]% penalty to [5]. Additionally, the maximum [3] is raised by [6]."),
	IceKing = ts:Create("hc453e399ge1f5g41f1gaeabgcdd4de833c63", "A character with [1] has an extra [2]% [3], but takes a [4]% penalty to [5]. Additionally, the maximum [3] is raised by [6]."),
	Courageous = ts:Create("h9987aab3ged6ag4e04g822bg777e5a929fb8", "[1] grants you immunity to [2], but you can no longer flee from combat."),
	GoldenMage = ts:Create("h3d72869dgfda9g4ddega996gc78970aa3436", "[1] grants you immunity to [2]."),
	WalkItOff = ts:Create("h6d76eb15gdb1ag4ebeg8001g58173516a923", "[1] reduces all status durations by 1 turn, including positive statuses. Does not affect statuses with a duration of 1 turn."),
	FolkDancer = ts:Create("hd749731fgb0cdg42a4g8133g6f2b8385b005", "A character with [1] moves at normal speed while sneaking."),
	SpillNoBlood = ts:Create("h17d48c1fg3287g4be8g900cgddfe62b2a4c9", "[1] increases your damage with crushing weapons by [2]%."),
	Stench = ts:Create("h878c02c0gc629g470dg955cg80dc2a125cb2", "[1] decreases everyone's attitude towards you by [2], but melee opponents find you less attractive in combat."),
	Kickstarter = ts:Create("hfd166830gc9d4g41dcg93deg8df5d94f1c22", "A character with [1] will find certain secrets throughout the game."),
	WarriorLoreNaturalArmor = ts:Create("h8fbbcc05gdfedg47a6g890bg15fdc6e27028", "[1] gives you extra armour equal to your Warfare ability + [2]."),
	WarriorLoreNaturalHealth = ts:Create("h49426677g68f9g4467g947cg68fad9de4af8", "[1] gives you extra Vitality: +[2]% for every point in Warfare."),
	WarriorLoreNaturalResistance = ts:Create("hcc42ecefg5965g48b7g98a1g2e34fb174186", "[1] gives you [2]% x Warfare extra Magic Resistance."),
	RangerLoreArrowRecover = ts:Create("h6a4d6da0g29cfg44ecg8913g5a0a76cf1bbd", "[1] gives you [2]% chance to recover a special arrow after shooting it."),
	RangerLoreEvasionBonus = ts:Create("h0e2dc6e9g5a11g45bagbde6gaa8a03fd1667", "[1] gives you [2]% extra chance to evade hits."),
	RangerLoreRangedAPBonus = ts:Create("h1454af55gdb0fg4d6fgbde1g8235fa16d980", "[1] increases attack range of Bows, Crossbows and Rifles by [2]m."),
	RogueLoreDaggerAPBonus = ts:Create("h2b97bbedga210g46c7ga762g74ab945b27f5", "[1] reduces [2]AP from the cost of using Daggers and Knives."),
	RogueLoreDaggerBackStab = ts:Create("h56b21dd3g7d43g4de8gbe58ge0e7ad8f84f1", "[1] allows you to backstab enemies with weapons other than a dagger.<br><font size='16' color='#00AAFF'>(LeaderLib)</font>"),
	RogueLoreMovementBonus = ts:Create("hdf8e7f7eg7880g42e7gac90gaed20ec6f948", "[1] gives you a [2]% movement bonus."),
	RogueLoreHoldResistance = ts:Create("hdb5862ccg234cg4d76g99acgeb5df44f7706", "[1] gives you a [2]% bonus against being Frozen, Stunned, Petrified and Knocked Down."),
	NoAttackOfOpportunity = ts:Create("h8ddc8dd4ge8feg4420ga6dag0d87ce8ec743", "[1] lets you evade attacks of opportunity."),
	WarriorLoreGrenadeRange = ts:Create("hfb8eec35g3339g4762g8382g712e74a2ac0b", "[1] adds an extra [2]m range to your grenade throws."),
	RogueLoreGrenadePrecision = ts:Create("h6df2b9a8gdd9bg494fg9bb2g5618201e2716", "[1] makes your grenade throws never miss."),
	WandCharge = ts:Create("h3b08726bgd80cg4b77gaa6bg934b6fe6f9bf", "[1] gives you one extra use of a wand skill."),
	DualWieldingDodging = ts:Create("h00f565c4g6178g424fgb031g41a2c12bf85d", "[1] gives you [2]% Dodging while dual wielding."),
	Human_Inventive = ts:Create("hfb009de5g5552g49b2g8d31g80ca64be659e", "[1] gives you [2]% bonus Critical Chance and [3]% extra Critical Multiplier."),
	Human_Civil = ts:Create("h68e89d14gb030g4fa7g807dg19b0a32eaa7d", "[1] gives you +[2] to Bartering."),
	Elf_Lore = ts:Create("h2e80f302g3024g48bcg8ffegabba5ce7a14b", "[1] gives you +[2] Loremaster."),
	Elf_CorpseEating = ts:Create("hfc3dfe78g9089g4d34g901cgfda31fb689f6", "[1] lets you eat body parts to access the memories of the dead."),
	Dwarf_Sturdy = ts:Create("h14fda75cgc90ag481cg8ca5gf31b3cf5f062", "[1] gives you +[2]% maximum Vitality and +[3]% Dodging."),
	Dwarf_Sneaking = ts:Create("he9d7a73ag20a3g4a9fg805bge5e560ff7dfd", "[1] gives you +[2] in Sneaking."),
	Lizard_Resistance = ts:Create("h998324e4g5715g4343g9a50g58f7de8ab6a5", "[1] gives you +[2]% Fire Resistance and +[3]% Poison Resistance."),
	Lizard_Persuasion = ts:Create("h0da6aab0g20b7g47e6gb38bg6a40d4a77168", "You get +[2] in Persuasion from [1]."),
	Perfectionist = ts:Create("he94327f7g293dg488eg9d25gcb4f7ae7be24", "While you are at maximum Vitality, [1] grants you an extra [2]% critical chance and [3]% more accuracy!"),
	Executioner = ts:Create("h98163163g695ag4813gb105g3ade9ea09050", "[1] gives you [2] extra Action Points after dealing a killing blow once per turn."),
	ViolentMagic = ts:Create("h90812fdfg4f53g49afg8a97g42aefdeb508c", "[1] gives all magical skills a critical chance equal to your critical chance score."),
	QuickStep = ts:Create("h91a3adcbg43d8g4d85ga819gffe52d51a629", "[1] permits your character [2] AP worth of free movement per turn."),
	Quest_SpidersKiss_Str = ts:Create("h1bfdf2e6g55b2g4296gaf68g092d466df657", "[1] gives you [2] to Constitution and +[3] to Strength."),
	Quest_SpidersKiss_Int = ts:Create("hd96e80c4g1c44g4851gb6a5g24063a0acd4f", "[1] gives you [2] to Constitution and +[3] to Intelligence."),
	Quest_SpidersKiss_Per = ts:Create("ha68e51d2g208eg4668gad97g0ce18a63ea1b", "[1] gives you [2] to Constitution and +[3] to Wits."),
	Quest_SpidersKiss_Null = ts:Create("h9819de28gc33bg4bc1gab21g5abcfe493da9", "[1] gives you [2] to Constitution."),
	Memory = ts:Create("hbde985cfgb1c4g4bb6g9a61gbec72c9b4ed6", "[1] gives you [2] extra points in your Memory attribute."),
	Quest_TradeSecrets = ts:Create("h4df4a910ge25cg4309gb5bbg7300680a1043", "[1] gives you +[2] to Bartering."),
	Quest_GhostTree = ts:Create("hb2001124g5a2bg47fdgb51bg66369c9064db", "[1] gives you +[2] to Lucky Charm."),
	BeastMaster = ts:Create("h3a46e939gee4fg4009ga15fg86804238276b", "[1] allows you to control an extra summon."),
	LivingArmor = ts:Create("h493986c9g104eg4517g9c49g90cee026cd6c", "[1] adds [2]% of all healing you receive by skills or consumables to your Magic Armour."),
	Torturer = ts:Create("h53f1f4d5gf664g4cb3gac8dgb4fbd2651d51", "With [1], certain statuses caused by you are no longer blocked by Magic or Physical Armour, and their duration is extended by one turn. Burning, Poisoned, Bleeding, Necrofire, Acid, Suffocating, Entangled, Death Wish, and Ruptured Tendons are affected by this talent."),
	Ambidextrous = ts:Create("hf3cd8067g36c0g4b48ga4dfg361f33579b43", "[1] reduces the cost of using grenades and scrolls by [2] AP when your offhand is free."),
	Unstable = ts:Create("hc37324bdg4088g4df7gbf3bg944c59d7eeb3", "[1] makes you explode in a bloody cloud when you die, dealing [2]% of your Vitality as physical damage in a [3] meter radius."),
	ResurrectExtraHealth = ts:Create("h570c9745gb003g4d1cgb1f9g2665f726b37e", "[1] gives [2]% more Vitality when being resurrected (stacks)."),
	NaturalConductor = ts:Create("ha39edeecg8efbg4f58g970dg5cbbadec6df0", "[1] grants the Hasted Status when standing on electric surfaces."),
	Quest_Rooted = ts:Create("h659301cfg7377g4404g8b83g448758d621a3", "[1] gives you +[2] Memory."),
	-- PainDrinker = ts:Create("", ""),-- Not set
	-- DeathfogResistant = ts:Create("", ""), -- Not set
	-- Sourcerer = ts:Create("", ""), -- Not set
	-- Rager = ts:Create("", ""), -- Not set
	Elementalist = ts:Create("h19a8880ageca0g4939g89e7g91e9fcd639be", "|Resistances are equalized between you and nearby allies. Does not affect summoned creatures. Range 10m.|"),
	Sadist = ts:Create("h71bc27c2g10b3g4ffcgbe92g98d921a979f6", "Melee attacks deal additional fire damage to burning targets, poison damage to poisoned targets and physical damage to bleeding targets."),
	Haymaker = ts:Create("ha79ac9a4g91ceg4fbfg9b70ge273d5f12090", "Your attacks never miss but cannot deal critical strikes."),
	Gladiator = ts:Create("h99d0d7c7g4503g417agb761g5a825bd06b18", "Every time you are hit with a melee attack while wielding a shield, you perform a counterattack. Can happen only once per turn."),
	Indomitable = ts:Create("haa3cebcagba62g47bbg8546gf0c154e0e46f", "You gain immunity to stunned, frozen, knocked down, polymorphed, petrified, crippled for 1 turn after being affected by one of these statuses. Can happen once every 3 turns."),
	WildMag = ts:Create("h219f555eg2017g4a5egbe12g2eb35b86f095", "|Damaging enemy with a spell causes a minor projectile of random element to hit nearest character in 6m range. Can trigger once per turn and can damage allies.|"),
	Jitterbug = ts:Create("h758efe2fgb3bag4935g9500g2c789497e87a", "|Being depleted of Physical or Magical armour teleports you to random location, away from the source of damage. Can happen once every 2 turns.|"),
	Soulcatcher = ts:Create("h8fc505abgfadbg4481g8d79gb73e606117d7", "When an allied character dies, a Zombie Crawler is raised at their corpse, under their control. Zombie Crawler lasts 3 turns or until character is resurrected. Range 12m. Does not affect summoned creatures."),
	MasterThief = ts:Create("ha3151180g3a04g418aga7fag221b83642b51", "You become Invisible while pickpocketing."),
	GreedyVessel = ts:Create("h6ccf760cg505ag41efg9f2egc1ff2f783f80", "Every time someone casts a Source Spell in combat you receive a 20% chance of gaining a Source Point."),
	MagicCycles = ts:Create("h34fa90bdg6d1fg4ee8gb3e7g8c3694c70fae", "At the start of an encounter, you gain one of two statuses: Cycle of Fire and Water or Cycle of Earth and Air. Cycle of Fire and Water increases your Pyrokinetic and Hydrosophist combat abilities by 2. Cycle of Earth and Air increases your Geomancer and Aerotheurge combat abilities by 2. Statuses swap each turn.")
}

LocalizedText.TalentDescriptionsAlt = {
	---Used if the Animal Empathy gift bag is enabled
	AnimalEmpathy = ts:Create("h20651336g5c38g40f0ga905g9248e33643d9", "Attitude of all animals increased."),
	---Used if Ext.ExtraData.TalentViolentMagicCriticalChancePercent is less than 100
	ViolentMagic = ts:Create("hbbdbc590g81a4g4adfg9f5cgcc9b9af87dbd", "[1] gives all magical skills a critical chance equal to [2]% of your critical chance score."),
}

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
	Preset = ts:Create("h72ab555bg3ff6g4049ga555g37e9d9a0f2ed", "Preset"),
	Select = ts:Create("hdf10e5a7g950eg4f82gb716ga5a614c00811", "Select"),
	Active = ts:Create("h4d5a9819gb8efg4f9ag8ceeg1b11c1619b85", "Active"):WithFormat("<font color='#33FF33'>(%s)</font>"),
	Inactive = ts:Create("hfbe448d5ga175g4f6aga6f8g758a142bff9e", "Inactive"):WithFormat("<font color='#FF3333'>(%s)</font>"),
	--Change = ts:Create("hd2c3081eg2847g44bag82d5g121c54bfb29f", "Change"),
	ModSettings = Classes.TranslatedString:Create("h5945db23gdaafg400ega4d6gc2ffa7a53f92", "Mod Settings"),
	ModSettings_Description = Classes.TranslatedString:Create("hc5012999g3c27g43bfg9a89g2a6557effb94", "Various mod options for active mods."),
}

LocalizedText.ContextMenu = {
	HideStatus = ts:Create("h901ab1b9g943dg465cg8583g3ad8e86354b5", "Hide Status"),
	HideStatus_Examine = ts:Create("hc9377dd3g70d6g4d84g8c8fg812246a61029", "Hide Status from Portrait UI"),
	ShowStatus = ts:Create("ha52299cfg95f3g4a46gaa56g3cd74d716741", "Show Status"),
	ShowStatus_Examine = ts:Create("h456c5c8bg7103g4b19g9185ge4cd6ddbab30", "Show Status in Portrait UI"),
}

LocalizedText.SkillTooltip = {
	SkillRequiredEquipment = ts:Create("h0a088d84g04f9g47b5g8d4dg3021748bfe00", "Requires a [1]"),
	RifleWeapon = ts:Create("ha3a18e3fge9e4g4496g84b8g5590844143f0", "Rifle Weapon"),
	SafeForce = ts:Create("h788df33dg4d61g4cb7g8f2cgfb75e14e7ffc", "Pushes targets [1]m [2]."),
	SafeForceRandom = ts:Create("h9308f157g1e5ag4051gbcc0g9d41c54ffa57", "Pushes targets [1]m [2] ([3]% Chance)."),
	SafeForce_Negative = ts:Create("h3209c996gd9ebg4594ga886gddca741dafdd", "Pulls targets [1]m [2]."),
	SafeForceRandom_Negative = ts:Create("h21fd2959g743dg49e6g9922g02b39ce3c8b8", "Pulls targets [1]m [2] ([3]% Chance)."),
	FromTarget = ts:Create("hafb63d24gd9b3g47d2gbe4cg1ecb09f9c1c9", "from target"),
	FromSelf = ts:Create("h727273bcg948ag461agad93gef52b2419eca", "from self"),
	MoveToTarget = ts:Create("h19d1b9dag302dg4655g86fdgad6fe369db15", "Move to the target."),
	ToggleStatus = ts:CreateFromKey("LeaderLib_Tooltip_ToggleStatus", "Toggle [1]"),
	ToggleStatusDuration = ts:CreateFromKey("LeaderLib_Tooltip_ToggleStatus", "Toggle [1] for [2] Turn(s)"),
	--BasicAttack = ts:Create("hbdac34fdg43b6g4439g9947g6676e9c03294", "Basic Attack"),
	LeaderLibToggleGrouping = ts:CreateFromKey("LeaderLib_Tooltip_ToggleGrouping", "<font color='#00CCFF'>Keyboard Shortcut</font><br><font color='#44CCAA'>Press CTRL + Spacebar to chain/unchain party members. No skill required.</font><br>(Note: This is the '<font color='#FFAA11'>[Handle:h310a22a4g1ebag4b1cg89d6g5cebc301c5c5:Toggle Game Master Shroud]</font>' [Handle:h6867dea8g129fg4a85g9368g1cf6534df65f:Key]).", {AutoReplacePlaceholders = true}),
	DamageLevelScaled = ts:Create("h71b09f9fg285fg4532gab16g1c7640864141", "Damage is based on your level and receives bonus from [1]."),
	DamageWeaponScaled = ts:Create("ha4cfd852g52f1g4079g8919gd392ac8ade1a", "Damage is based on your basic attack and receives a bonus from [1]."),
	DamageShieldScaled = ts:Create("hc8bae163gccf2g4127g8e0dg68d172d2ecf6", "Damage is based on the Physical Armour of your shield."),
	DamagePhysicalArmourScaled = ts:Create("h1351a6d8g5dc2g4f9bgbda1gfee5cde2c85e", "Damage is based on your current Physical Armour."),
	DamageMagicArmourScaled = ts:Create("hf1ff2734g96adg486fg800cgd9d0320b04c7", "Damage is based on your current Magic Armour."),
}

--Engine statuses from eoc::GetStatusTranslatedName
LocalizedText.Status = {
	ACTIVE_DEFENSE = ts:Create("hdb2d0824gf6c8g44b1g8fb6gf36202c82c4f", "Active Defence"),
	ADRENALINE = ts:Create("h4c891442g3b79g4dbeg906fgf8eeffcf60df", "Adrenaline"),
	BLIND = ts:Create("h5c47fcd7g8fd1g453bgbbffgd10009874b58", "Blind"),
	CHANNELING = ts:Create("hd8afb428g6d9fg4b40g802dg84ff6405e3ea", "Channeling"),
	CHARMED = ts:Create("h30fc0122g6378g408cgac6fg6e3bcb3c852b", "Charmed"),
	CLEAN = ts:Create("h8fb688afg29efg4804g9d68g955c3c463053", "Clean"),
	COMBUSTION = ts:Create("h4438bd47gf552g48begaea5g2231ec04d93a", "Combustion"),
	CONSTRAINED = ts:Create("h6f529258g53e7g45f5gb475gac35ed577198", "Constrained"),
	DAMAGE = ts:Create("h9531fd22g6366g4e93g9b08g11763cac0d86", "Damage"),
	DAMAGE_ON_MOVE = ts:Create("h79fb3ad9g4225g448bgb5f4g13fa2f2b2112", "Damage On Move"),
	DARK_AVENGER = ts:Create("h64892b81g9543g4608ga303gcffa5055d869", "Dark Avenger"),
	DEACTIVATED = ts:Create("h134f5495g54ccg48a9g96bfgcdbdd31faec0", "Deactivated"),
	DEAD = ts:Create("h2e807311g8c4bg4141g85f3gcc88ee095888", "Dead"),
	DECAYING = ts:Create("hbc2789fegb2deg4952ga436ga8a0aad070bf", "Decaying"),
	DISARMED = ts:Create("h4904c1c3g1485g48a1g9084g13b821449d0f", "Disarmed"),
	DRAIN = ts:Create("h9cf08d12gc1b8g4c7cg8662g40d03ca96df5", "Drain"),
	ENCUMBERED = ts:Create("hdc2c6815g4c4fg4e81g94d5g299646e91500", "Encumbered"),
	EXPLODE = ts:Create("he16d8b7dg7f45g45ddga2c8g0b5bf010be9e", "Explode"),
	FEAR = ts:Create("h6f38a9b4gc4deg4318g9f6cg4d073b48bde2", "Fear"),
	FLANKED = ts:Create("hd052e4cfg1a83g4ee5g886cgbf15dc656a0b", "Flanked"),
	GUARDIAN_ANGEL = ts:Create("hfe33ce6aged4fg4cb7g8bd8g47e3956c6ba7", "Guardian Angel"),
	HEAL = ts:Create("h069389c2gc635g4e5cga15fg28d1eae30e3e", "Heal"),
	HEALING = ts:Create("hb4da6a16g24a7g4d39g8e71g09bb80781f5b", "Healing"),
	INCAPACITATED = ts:Create("h1791dcc9g5662g48begb48fg621f6da5b1d6", "Incapacitated"),
	INFECTED = ts:Create("hecfd20c2geb00g4b42g9fc4g76021f4635d6", "Infected"),
	INVISIBLE = ts:Create("h7fa4cea8gf162g40a8g83cbg133d613ee6eb", "Invisible"),
	KNOCKED_DOWN = ts:Create("h4a390c48ga640g4f98ga491g7b92bb9f7ba8", "Knocked Down"),
	LEADERSHIP = ts:Create("h7c65fe39g1526g427bg8a2dgab7e74c66202", "Leadership"),
	LINGERING_WOUNDS = ts:Create("h3924a821gdb1fg4d6fg920eg62ee3c4586ed", "Lingering Wounds"),
	MATERIAL = ts:Create("h959b01c5g0a34g4d08gbf99g854ac742a452", "Material"),
	MUTED = ts:Create("h45f9834cg4d53g4a3cgaddcg1ec6c38bcdf0", "Muted"),
	OVERPOWERED = ts:Create("hb57e8596gbeedg49a8g9f03g9adf59e0608a", "Overpowered"),
	PLAYING_DEAD = ts:Create("hb541d496g70efg45cbg84c9g07e626209303", "Playing Dead"),
	POLYMORPHED = ts:Create("h3739559fg64acg42c3g893cg6fb341570556", "Polymorphed"),
	POTION = ts:Create("hae185f7aga216g43afg82b3gaf96a75a7890", "Potion"),
	REMORSE = ts:Create("h7e0fe51fg9df2g4854gb8f1g183251dcc25b", "Remorse"),
	SHACKLES_OF_PAIN = ts:Create("h36a82a09gc2dag46feg990cgf3807db54d54", "Shackles of Pain"),
	SHACKLES_OF_PAIN_CASTER = ts:Create("h89ad2635gd8acg4dc1gb7f5g2287082b3733", "Shackles of Pain (caster)"),
	SHIELDED = ts:Create("hb424f644g56d8g4216ga07dg5efb24c662e4", "Shielded"),
	SITTING = ts:Create("h33b529f1g6fb3g4210g8b40ga41e4d05c0d0", "Sitting"),
	SMELLY = ts:Create("h312fc6d0gd271g40ffg949dge80fba98335e", "Smelly"),
	SNEAKING = ts:Create("h6bf7caf0g7756g443bg926dg1ee5975ee133", "Sneaking"),
	SOURCE_INFUSED = ts:Create("hae4ca8a4g56feg480eg95c8ge5761ab1eb2e", "Source-Infused"),
	SOURCE_MUTED = ts:Create("h534aec4fgecc5g4b34gb0f5g8b08c3c4309e", "Source-Muted"),
	SPARK = ts:Create("h6a1b19e6gf6fcg498fgb0acgb74606dc9d0e", "Spark"),
	SPIRIT = ts:Create("h90cedca8g690cg4aabg8df0g98da27d72991", "Spirit"),
	SPIRIT_VISION = ts:Create("h81ca2748g7469g47c9g8e5dg49ecc8d1e382", "Spirit Vision"),
	SWAPING_HEALTH = ts:Create("hba2ce28ag006eg4601g9ab9g2d1d93f97a37", "Swaping health"),
	THICK_OF_THE_FIGHT = ts:Create("hba6034c6g884ag43a0g8a4bg4a0a8c8fa4f0", "Thick of the fight"),
	THROWN = ts:Create("hfa754958gff75g4474g8cd5g508b4fb7a984", "Thrown"),
	TIME_WARP = ts:Create("h320c5fb3gca9dg4f13gb43ag5f41792b28b3", "Time Warp"),
	UNHEALABLE = ts:Create("hc33f0ac7gc3f0g47b3gba3cg8c3ddb82508e", "Unhealable"),
	WIND_WALKER = ts:Create("hc7566374g36afg4345gaf18gab4ba7d7c809", "Wind Walker"),
	WINGS = ts:Create("hd716a074gd36ag4dfcgbf79g53bd390dd202", "Wings"),
}

LocalizedText.StatusDescription = {}

LocalizedText.WeaponType = {
	Bow = ts:Create("h0e38a42fg44dfg491dg8387g6d582a3cacf9", "Bow"),
	Crossbow = ts:Create("h52ee27b1g46a7g4a0dg95b3gf519d1072d3b", "Crossbow"),
	Dagger = ts:Create("hd6d18316gbc8bg400bga46eg18cd9f4185ee", "Dagger"),
	Rifle = ts:Create("h4120c4e5g4931g46dbgad0fga7a57514ac42", "Rifle"),
	Shield = ts:Create("h77557ac7g4f6fg49bdga76cg404de43d92f5", "Shield"),
	Spear = ts:Create("h45830ff5g54bdg4098g9395gede7110cf8f1", "Spear"),
	Staff = ts:Create("h0172003bg3d9cg492bga07cg55c4db8606a8", "Staff"),
	Wand = ts:Create("h82e2ab7bg3b67g4e82ga2fdg312cd5b63603", "Wand"),
	OneHandedAxe = ts:Create("h2c89d4e0g529bg4e4agbae9ge3119ee32cc9", "One-Handed Mace"),
	TwoHandedAxe = ts:Create("h4be6203eg3fd9g4712g989egf69a65af1bfe", "Two-Handed Axe"),
	OneHandedMace = ts:Create("h17a906aeg8f00g4f9dga784g93b8e4ad26b2", "One-Handed Mace"),
	TwoHandedMace = ts:Create("h7b586984gd7abg42fcg84a4ge354c937ec07", "Two-Handed Mace"),
	OneHandedSword = ts:Create("h657cfe58g240bg43c6g9129gf3a6a75d6ca4", "One-Handed Sword"),
	TwoHandedSword = ts:Create("h57099d1cg88ccg44f5g9ba7gc1acedf94335", "Two-Handed Sword"),
}

LocalizedText.SkillRequirement = {
	BowOrCrossbow = ts:Create("h4f8719aeg053bg40d5gb9cag3ba001b3f0ed", "Bow or Crossbow"),
	Dagger = ts:Create("h6e21af89g96d5g4826ga11ag8688bee4a5f7", "Dagger"),
	MeleeWeapon = ts:Create("h17d6fa6bgde7bg467cg81d7g4f382e194ba5", "Melee Weapon"),
	RangedWeapon = ts:Create("h87b42cabg950ag4e52g802dg9fc6aa755f5e", "Ranged Weapon"),
	Shield = ts:Create("h0c4dfdb5g88e7g4df8gabc9gf17b7042bf14", "Shield"),
	StaffWeapon = ts:Create("h9d2c3f11g8702g4504ga467g9e63531ce7ab", "Staff Weapon"),
}

LocalizedText.Tooltip = {
	AutoLevel = ts:Create("hca27994egc60eg495dg8146g7f81c970e265", "<font color='#80FFC3'>Automatically levels up with the wearer.</font>"),
	Chance = ts:CreateFromKey("LeaderLib_Tooltip_Chance", "([1]% Chance)"),
	BonusWeaponOnAttack = ts:CreateFromKey("LeaderLib_Tooltip_BonusWeaponOnAttack", "On Basic Attack or Weapon Skill:"),
	ExtraPropertiesOnHit = ts:CreateFromKey("LeaderLib_Tooltip_ExtraPropertiesCondensed", "On Hit:<br>Set [1] for [2] turns(s).[3]"),
	ExtraPropertiesOnHitPermanent = ts:CreateFromKey("LeaderLib_Tooltip_ExtraPropertiesCondensedPermanent", "On Hit:<br>Set [1].[3]"),
	ExtraPropertiesWithTurns = ts:Create("hf90daa3cgba5cg471cgbebcgedb58a337a9f", "Set [1] for [4] turn(s).[2][3]"),
	ExtraPropertiesPermanent = ts:Create("h233bf83cg2204g4f14gb46agad27f95deb43", "Set [1].[2][3]"),
	ExtraPropertiesCreateSurfaceAtTarget = ts:Create("h1823215bgb61fg48e9g8982g4704ed9c05ae", "Creates a [2]m [1] surface at the location of your target(s)"),
	ExtraPropertiesClearSurfacesTarget = ts:CreateFromKey("LeaderLib_Tooltip_ExtraPropertiesClearSurfaces", "Clears surfaces in a [1]m range at the location of your target(s)."),
	ChanceToSucceed = ts:Create("h54e0b91cg48a7g4d5agaedcgbde756a109ea", "[1]% chance to succeed."),
	ScalesWith = ts:Create("h565537edgdec5g4483g938fg296519760088", "Scales With [1]"),
	Requires = ts:Create("h7de69a95g70cag4bb3gbabcg1cf2df46f12c", "Requires [1]"),
	RequiresWithParam = ts:Create("ha6e36605gee35g4aaagaddbg7ab8bfaf86f6", "Requires [1] [2]"),
	--RequiresWithParam2 = ts:Create("h825990a2gaf64g4235g9d53gcd340042c0d0", "Requires [1] [2]"),
	--RequiresWithParam3 = ts:Create("hf1571b7eg8f35g4da2g8e38g87fee1c3d79f", "Requires [1] [2]<br>"),
	ExpanderInactive = ts:Create("h17380891g0e8eg42d3gbb55g9478bba4f684", "Hold [1] for More Info"),
	ExpanderActive = ts:Create("h7b3bd7e6g9a34g4959gad11g241f6d8d33c1", "Release [1] for Less Info"),
	StatBase = ts:Create("hbb9884d7g3b9ag43dfga88egdcc32db8bd74", "<br>Base: [1]"),
	AbilityCurrentLevel = ts:Create("h8154ae8eg2b37g4f0fgb6b6gd7e27fed37a6", "Level [1]: [2]"),
	AbilityNextLevel = ts:Create("he31d5820g9ddbg4e08gac83g1358e22e499b", "Next Level [1]: [2]"),
	ImmunityTo = ts:Create("h0b55e55fg0b1dg4c92g899egca5204be3932", "Immunity to [1]<br>"),
	ImmuneTo = ts:Create("hac7cca96gd0dfg4391gb188gc53fd12cb6a5", "Immune to [1]"),
	BookIsKnown = ts:CreateFromKey("LeaderLib_Tooltip_BookIsKnown", "<br><font color='#44FF33'>(This book has been read)</font>"),
	StatusSource = ts:CreateFromKey("LeaderLib_Tooltip_StatusSource", "<font color='#6EB09D'>Applied by [1]</font>"),
	APCost = ts:Create("hc9eb3ff8ge40dg4d7bg91d2gd2107aa86f9c", "([1] AP)"),
	Unlocks = ts:Create("h71c8fc3eg415bg4cedgba5fgb720f9ca3023", "Unlocks [1]"),
}

LocalizedText.Input = {
	Shift = ts:Create("hbb74f5fag4e95g4e8fgb2b8g2a761e814bd5", "Shift"),
	Alt = ts:Create("h2eac7501gd233g41edgae49g1a7a41a4bb06", "Alt"),
	LeftAlt = ts:Create("h69d93655g343ag4b3eg8705g93a3deb00ef5", "Left Alt"),
	RightAlt = ts:Create("hcd82cb63g0a61g4799g859egba9f1efabd4b", "Right Alt"),
	Select = ts:Create("hdf10e5a7g950eg4f82gb716ga5a614c00811", "Select"),
}

LocalizedText.Base = {
	Experience = ts:Create("he50fce4dg250cg4449g9f33g7706377086f6", "Experience"),
	Total = ts:Create("h9e9c017dg3bceg4c21ga665g71b50ca351b6", "Total"),
}

LocalizedText.CharacterSheet = {
	Strength = ts:Create("hc8c67074g3c19g44d1g8b7bg9e5a8d06d87f", "Strength"),
	Finesse = ts:Create("h3b3ad9d6g754fg44a0g953dg4f87d4ac96fe", "Finesse"),
	Intelligence = ts:Create("h33d41553g12cag401eg8c71g640d3d654054", "Intelligence"),
	Constitution = ts:Create("hcd19f46ag85bcg41f2gb8fbg1dc69843d250", "Constitution"),
	Memory = ts:Create("h8d2cecb4g5be0g4fafg8b9bga446ca226c92", "Memory"),
	Wits = ts:Create("h0f1053bbg8ac4g461fg9179g6f28b9d091bd", "Wits"),
	Damage = ts:Create("h9531fd22g6366g4e93g9b08g11763cac0d86", "Damage"),
	Tooltip = {
		DamageAttribute_Description = ts:Create("hb924258ag2cf7g4c11gaf4eg8b7de303c197", "+1 point = +[1]% damage."),
		Memory_Description = ts:Create("h49b9da32gdb42g4772ga68dgd155a02fb246", "+[1] point = +1 Slot."),
		Constitution_Description = ts:Create("h6d615e0bgea5bg4fe3g922ega508e86bceed", "1 point would add +[1]% Vitality."),
		Wits_Description = ts:Create("hd5dd26e5gadc6g40d9ga0c6g2ae909cbc842", "1 point would add [1]% Critical Chance + [2] Initiative."),
		MaxWeight_Description = ts:Create("h64b80b35gb4e8g4081gae87g04ced2abe5c2", "Can move items with weight up to [1]kg. Can carry items with total weight up to [2]kg before becoming encumbered."),
		StatBase = ts:Create("hbb9884d7g3b9ag43dfga88egdcc32db8bd74", "<br>Base: [1]"),
		Vitality = ts:Create("hba9570fega15cg4069gad0eg7754669e7209", "Vitality Bonus: [1][2]%"),
		CriticalChance = ts:Create("h84bafbedgb201g4356gaa16g41cf785deff0", "<br>Critical Multiplier: [1]%"),
		AccuracyWeaponPenalty = ts:Create("hea8697b1g2bd6g4e6bga901gf1837a763f15", "Weapon level too high: [1][2]%"),
		AccuracyBlindedPenalty = ts:Create("hf76d16e7g8b08g4240ga6b6g88c0d9d27156", "<br>Blinded!"),
		MovementSpeedPenalty = ts:Create("h8951ca6dgc1a1g4fcega09agf54d40f3be37", "<br>Movement Speed Penalty: [1][2]%"),
		MovementSpeedBoost = ts:Create("h331c7392g2787g49f7g88d4g72ff33dca16c", "<br>Movement Speed Boost: [1][2]%"),
		SpellSlots = ts:Create("hea9cf9e9gb7f0g4cc0ga3d7gdd7516bc04bb", "Base slots: [1]. Extra slots from Memory: +[2]."),
		ExtraDamage = ts:Create("h947808bdgf2b2g431eg83d9g86bba689ec0c", "Currently: [1] based attacks and skills do [2][3]% extra damage."),
		ActionPoints = {
			StartAP = ts:Create("h8723691egfcd3g498fgbcb4g2bf0a0f4d00d", "<br><br>Start Action Points: [1]"),
			StartAP_Description = ts:Create("h97706f14gb39eg4975gbcb6gb876c0bdd4d4", "<br>How many Action Points you start combat with."),
			MaxAP = ts:Create("h4938529agb8d4g4f9bg98d2gf057c8e17b8a", "<br><br>Maximum Action Points: [1]"),
			MaxAP_Description = ts:Create("hddbbffffgc663g4a20ga452gf25cbbd871c8", "The number of Action Points you can have in total. You save up unused Action Points from previous turns, but never more than this."),
			FromGlassCannonTalent = ts:Create("h2f644eafg3fcag4043ga68bg4f8e6488b840", "<br>From [1]: Start AP equal to Maximum AP."),
			ActionPointCost = ts:Create("hac06d8ecg2be5g4b1egac56g9cd90cf03b46", "<br>Action Points cost: [1]"),
			RecoveryAP = ts:Create("hfabcc55fgc0d2g45ccg85c7g2ebf651f470f", "<br><br>Turn Action Points: [1]"),
			RecoveryAP_Description = ts:Create("h07ef9f40g7f92g45d1g9f7egb3628a5ab01d", "<br>How many Action Points you gain in subsequent turns."),
		},
		FromGear = ts:Create("h89018e24g2f67g4f5bg80e1gc6724d1a122e", "<br>From Gear: [1][2]"),
		FromGearPercentage = ts:Create("h3c8f876bgb69fg453dgb3a7g99bad86cb0ec", "From Gear: [1][2]%"),
		BaseBoost = ts:Create("h5f77d376g279cg4a8bga7a8gf1886a8cd7e7", "<br>Base Boost: [1]%"),
		FromPhysicalArmourAbility = ts:Create("hb71362a8gcb34g4db8gb821g4416a786f7b5", "From Physical Armour ability: [1][2]%"),
		FromMagicArmourAbility = ts:Create("h3e6d0038g5b02g47b7ga291gd039dd29736c", "From Magic Armour ability: [1][2]%"),
		FromVitalityAbility = ts:Create("h075e5eeeg248eg4bd3g9031ga5b0f7a30c17", "From Vitality ability: [1][2]%"),
		FromFlanking = ts:Create("hefbdb9d7g49c6g4432g987fge1ef96b86851", "From Flanking: [1]%"),
		FromLevel = ts:Create("h8a3ccfcegd106g4076gabceg175e0c192575", "<br>From Level: +[1]"),
		FromWits = ts:Create("h8b2c9945g7714g47dagb168g4fc45d47058e", "<br>From Wits: [1][2]"),
		FromStrength = ts:Create("h6318785cgfc54g4611gb4c7ge980849f08c5", "<br>From Strength: [1][2]"),
		FromCarryTalent = ts:Create("h5ec34e8cge6b7g4288g91f7g0e6df1f3d685", "<br>From [1]: +[2]"),
		Damage = {
			FromCharacter = ts:Create("h5d4473fdg9d82g494dg8ee1g18e855eaefcb", "<br>From character: [1][2]%"),
			FromSneaking = ts:Create("he3c4035ag8e41g49d5gb1d5gd604872ef5b2", "<br>From Sneaking: x[1]"),
			FromBullyTalent = ts:Create("h03c85049g2e71g49b1gb87eg1a3ed11a2564", "<br>From [1]: +[2]% (Against opponents with [3], [4] or [5])"),
			FromMultiplicative = ts:Create("hd2273461gcca8g4f08g9eaeged96827308c2", "From [1]: [2] damage increased by [3]% (multiplicative)"),
			FromFists = ts:Create("h0881bb60gf067g4223ga925ga343fa0f2cbd", "<br>From Fists: [1]-[2]"),
			FromWeapon = ts:Create("hfa8c138bg7c52g4b7fgaccdgbe39e6a3324c", "<br>From Weapon: [1]-[2]"),
			FromOffhandWeapon = ts:Create("hfe5601bdg2912g4beag895eg6c28772311fb", "<br>From Offhand Weapon: [1]-[2]"),
			DualWieldingPenalty = ts:Create("he3980bf8gf554g4dd8g823cgf2ccb71036a6", "Dual wielding penalty: [1]%"),
			TotalDamage = ts:Create("h1035c3e5gc73dg4cc4ga914ga03a8a31e820", "Total damage: [1]-[2]"),
			None = ts:Create("hed58f57eg7b16g4b63g812ega842be8f1953","pure"),
			Physical = ts:Create("h666fff63g3033g4063gb364g72c7b70c0969","physical"),
			Piercing = ts:Create("h5022bb08ge403g4110gb272g043a6b5fcd05","piercing"),
			Corrosive = ts:Create("h161d5479g06d6g408egade2g37a203e3361f","Physical Armour"),
			Magic = ts:Create("hdb4307b4g1a6fg4c05g9602g6a4a6e7a29d9","Magic Armour"),
			Air = ts:Create("he90b8313g9f8dg4dddg871ag3deb9dfeeb10","air"),
			Earth = ts:Create("h0d765ef8gca43g4e90ga3cegbb41065861cb","earth"),
			Fire = ts:Create("h72d4ba14gd1c7g4878ga2d6g940925b0332c","fire"),
			Poison = ts:Create("h7ecb0492g363fg4b80gb9e2gdb068327e2f8","poison"),
			Shadow = ts:Create("h168f52b6g342ag42e0g99d0g47d94b7363c8","rot"),
			Water = ts:Create("h67923c72gd6f7g4430gab14gd893c772d522","water"),
		}
	},
	PhysicalArmour = ts:Create("hb677b3f7g5cf6g49c3g84fag2f773ef50dd6", "Physical Armour"),
	MagicArmour = ts:Create("hc6dcb940gb6b6g41aagaeceg31008af9c082", "Magic Armour"),
	CriticalChance = ts:Create("h1b6a1120gb023g4df1gb463gc317e509ee2c", "Critical Chance"),
	Accuracy = ts:Create("h6372c697g5d05g414cga3e3gbb2656f62f2d", "Accuracy"):WithFormat("<font color=\"#411600\">%s</font>"),
	Dodging = ts:Create("h5b82f1a5gb4bcg48bdg8827g0d9baecfaada", "Dodging"):WithFormat("<font color=\"#411600\">%s</font>"),
	Vitality = ts:Create("h67a4c781g589ag4872g8c46g870e336074bd", "Vitality"),
	ActionPoints = ts:Create("h4ef9c467g3c7bg4614g96d0g801b09fcc05c", "Action Points"),
	SourcePoints = ts:Create("hc4281cefg2577g4c22g9a01gf90be11a051f", "Source Points"),
	Reputation = ts:Create("haf00c1a8gc56bg4eacgbd98g933b95e9f4b7", "Reputation"),
	Karma = ts:Create("h1fbed78cg6928g414ag9046g7ae3aabc8fee", "Karma"),
	Sight = ts:Create("hbd823364g3cd7g40a8g86dcg683cbc11515e", "Sight"),
	Hearing = ts:Create("h72f5211cg1ad9g4092g8398g799c66b2311f", "Hearing"),
	Movement = ts:Create("ha9fe36bfg692ag4f8bg8d9eg379bbbf04c87", "Movement"),
	Initiative = ts:Create("h8c8cc7e3gdaf7g46d2g9d3bg04a31d8f0599", "Initiative"),
	Block = ts:Create("h7f512771g9783g4c18g8af1g8c052a73edc5", "|Block|"),
	PiercingResistance = ts:Create("he840ff3eg35e6g4e06ga987g970ebee744e3", "Piercing Resistance"),
	PhysicalResistance = ts:Create("hcd84ee03g9912g4b0dga49age6bce09b19d1", "Physical Resistance"),
	CorrosiveResistance = ts:Create("hacc27ae5gfaf0g4854g85a6ga57d5be46dc5", "Corrosive Resistance"),
	MagicResistance = ts:Create("h8bfd4518ge6deg47a2g90a6g541f5ba1ba88", "Magic Resistance"),
	TenebriumResistance = ts:Create("hef0c737eg2a72g4564ga5cfg088484ac8b45", "Tenebrium Resistance"),
	FireResistance = ts:Create("he04c3934g32b0g455fgac3dg75f2b7fd2119", "Fire Resistance"),
	WaterResistance = ts:Create("he5441d99gdb3cg40acga0c4g24379b8b09f7", "Water Resistance"),
	EarthResistance = ts:Create("hac36ad5ag557fg4456ga0edga5a40606fabb", "Earth Resistance"),
	AirResistance = ts:Create("h134d72acgdd42g4c2dg97a8g6df0af2802a5", "Air Resistance"),
	PoisonResistance = ts:Create("he526af2ag192cg4a71g8247gb306eb0eb97d", "Poison Resistance"),
	Experience = ts:Create("he50fce4dg250cg4449g9f33g7706377086f6", "Experience"),
	NextLevel = ts:Create("hd2c1d752gc727g4c69g9a6cg67116ca0b97e", "Next Level"),
	MaxAP = ts:Create("hf82911f7g7ee2g4d32gb42ag391f69336428", "Max AP"),
	StartAP = ts:Create("h38fd7a07gf031g4dfeg89e2g30679a0898d9", "Start AP"),
	APRecovery = ts:Create("h544d0f04ga5b2g4350g9208g24b6ba25cbe8", "AP Recovery"),
	MaxWeight = ts:Create("hd47021f7g7867g4714ga91cg02ac22e9cfb3", "Max Weight"),
	MinDamage = ts:Create("h0cda6f38gcd49g4f74g8e14gd5bc2600a6e7", "Min Damage"),
	MaxDamage = ts:Create("he43f0127ge25eg464cg8093g343ca73872bc", "Max Damage"),
	LifeSteal = ts:Create("h69bafc0bgd06eg4ca0gbc2eg0959423c19b6", "Life Steal"),
	Gain = ts:Create("hd0a6556ag7601g41fdg9a72gff05a766e77c", "Gain"),
	Fire = ts:Create("h051b2501g091ag4c93ga699g407cd2b29cdc", "Fire"),
	Water = ts:Create("hd30196cdg0253g434dga42ag12be43dac4ec", "Water"),
	Earth = ts:Create("h85fee3f4g0226g41c6g9d38g83b7b5bf96ba", "Earth"),
	Air = ts:Create("h1cea7e28gc8f1g4915ga268g31f90767522c","Air"),
	Poison = ts:Create("haa64cdb8g22d6g40d6g9918g61961514f70f", "Poison"),
	--Custom replacement for Next Level
	Total = ts:Create("h9e9c017dg3bceg4c21ga665g71b50ca351b6", "Total"),
}

---Get localized damage text wrapped in that damage type's color.
---@param damageType string
---@param damageValue string|integer|number|nil
---@param omitDamageName boolean|nil
---@return string
local function GetDamageText(damageType, damageValue, omitDamageName)
	local entry = LocalizedText.DamageTypeHandles[damageType]
	if entry ~= nil then
		if omitDamageName then
			return string.format("<font color='%s'>%s</font>", entry.Color, damageValue)
		else
			if damageValue ~= nil then
				if type(damageValue) == "number" then
					return string.format("<font color='%s'>%i %s</font>", entry.Color, damageValue, entry.Text.Value)
				else
					return string.format("<font color='%s'>%s %s</font>", entry.Color, damageValue, entry.Text.Value)
				end
			else
				return string.format("<font color='%s'>%s</font>", entry.Color, entry.Text.Value)
			end
		end
	else
		Ext.Utils.PrintError("No damage name/color entry for type " .. tostring(damageType))
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
		Ext.Utils.PrintError("[GameHelpers.GetAbilityName] No ability name for ["..tostring(ability).."]")
	end
	return nil
end

GameHelpers.GetAbilityName = GetAbilityName

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
	CustomResistance = {Text=ts:Create("h95b9aa7bg9ca3g46ecga152gbed2951313b4","Sulfuric Resistance"), Color="#C7A758"}, -- Special LeaderLib handle
	SentinelResistance = {Text=ts:Create("h3e9f92b4g5634g425egb6f8g75b06a572a2c","Unknown Resistance"), Color="#008858"}, -- Special LeaderLib handle
}

LocalizedText.MessageBox = {
	CancelChangesTitle = ts:Create("h28ee4af1geab8g41f0g94b5ga4e9ae85e8ff", "Cancel Changes"),
	CancelChangesDescription = ts:Create("h554cccd7g50ffg4e7agae6cgef8b708bd622", "Are you sure you want to cancel your changes and exit?"),
	WarningTitle = ts:Create("h0434b959gff6fg4e99g85c2g450cfe0b1335", "Warning"),
	HasPointsDescription = ts:Create("h9962441bg2b65g4f24gbb4fgce984cdd0948", "You still have points to spend! Points can also be spent later, in-game. Continue?"),
}

LocalizedText.Keywords = {
	Hit = ts:Create("h8ade1bb0gb79eg44c0gbe01g1dd0d51935df", "hit"),
}

LocalizedText.CombatLog = {
	WasHitFor = ts:Create("h3cc306cdg95b4g4803g803ag2dd33a722d6c", "[1] was [2] for [3]"),
	WasHitBySurface = ts:Create("h3cc306cdg95b4g4803g803ag2dd33a722d6c", "[1] was [2] for [3] by a surface"),
	WasDestroyed = ts:Create("h3d2c57b3g8b84g4315ga619g04367092ce5f", "[2] was destroyed"),
}

---@class ResistanceTextEntry
---@field Text TranslatedString
---@field Color string

---Get localized resistance text wrapped in that resistance's color.
---@param resistance string
---@param amount integer
---@return string
function GameHelpers.GetResistanceText(resistance, amount)
	---@type ResistanceTextEntry
	local entry = LocalizedText.ResistanceNames[resistance]
	if entry == nil then
		local damageTypeToResistance = Data.DamageTypeToResistance[resistance]
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
		Ext.Utils.PrintError("No damage name/color entry for resistance " .. tostring(resistance))
	end
	return ""
end

---Get the localized resistance name for a damage type.
---@param damageType string
---@return string
function GameHelpers.GetResistanceNameFromDamageType(damageType)
	local resistance = Data.DamageTypeToResistanceWithExtras[damageType]
	if resistance ~= nil then
		local entry = LocalizedText.ResistanceNames[resistance]
		if entry ~= nil then
			return entry.Text.Value
		else
			Ext.Utils.PrintError("No name/color entry for resistance/damagetype",resistance,damageType)
		end
	end
	return ""
end

--for k,v in pairs(Mods.LeaderLib.LocalizedText.Surfaces) do print(string.format("\t%s = ts:Create(\"%s\", \"%s\"),", k, v.Handle, v.Value)) end

LocalizedText.Surfaces = {
	--None = ts:Create("", "None"),
	Blood = ts:Create("had97d00cg1642g417fg815fg09903e8210c3", "Blood"),
	BloodBlessed = ts:Create("hcee07dfdg8ba6g493eg8a91g06290b32fe2f", "Blessed Blood"),
	BloodCloud = ts:Create("hc314707cg9b2dg4cb0ga922gf7010e3472ad", "Blood Cloud"),
	BloodCloudBlessed = ts:Create("haa8a5144g516bg4a5agabcfgc8e34fed6f78", "Blessed Blood Cloud"),
	BloodCloudCursed = ts:Create("h26b4b792g9fa6g44f8gbbc2ge07a876b2c72", "Cursed Blood Cloud"),
	BloodCloudElectrified = ts:Create("h7d391ac6gadb3g4929gaa29g29e78d28c05b", "Electrified Blood Cloud"),
	BloodCloudElectrifiedBlessed = ts:Create("haee763bdg8c34g4620gbc9cgaf2d0f033154", "Blessed Electrified Blood Cloud"),
	BloodCloudElectrifiedCursed = ts:Create("he8d091e5g20a3g4381g9c62g4a6b9d299e8a", "Cursed Electrified Blood Cloud"),
	BloodCloudElectrifiedPurified = ts:Create("h7d391ac6gadb3g4929gaa29g29e78d28c05b", "Electrified Blood Cloud"),
	BloodCloudPurified = ts:Create("hc314707cg9b2dg4cb0ga922gf7010e3472ad", "Blood Cloud"),
	BloodCursed = ts:Create("hd7079d01g1acag43d4gabbcg63870cd36aae", "Cursed Blood"),
	BloodElectrified = ts:Create("h11569126geef1g42b8g9a3bg6d84440d02ff", "Electrified Blood"),
	BloodElectrifiedBlessed = ts:Create("h4b3438bfg2807g4deaga71egae6412a50d4f", "Blessed Electrified Blood"),
	BloodElectrifiedCursed = ts:Create("h34b396e3gfa2fg42ffgb559gb3ecfe4ae24f", "Cursed Electrified Blood Surface"),
	BloodElectrifiedPurified = ts:Create("h11569126geef1g42b8g9a3bg6d84440d02ff", "Electrified Blood"),
	BloodFrozen = ts:Create("h90936409g7afdg4b75gaedbgc3de9b8b22b9", "Frozen Blood"),
	BloodFrozenBlessed = ts:Create("h2c92ec27g38ebg4e3aga44cg37b73a5d8d35", "Blessed Frozen Blood"),
	BloodFrozenCursed = ts:Create("h944192a3gb9deg4560gba1dg1af7bcb3c680", "Cursed Frozen Blood"),
	BloodFrozenPurified = ts:Create("h90936409g7afdg4b75gaedbgc3de9b8b22b9", "Frozen Blood"),
	BloodPurified = ts:Create("had97d00cg1642g417fg815fg09903e8210c3", "Blood"),
	DeathfogCloud = ts:Create("hd9494a3bg316dg4e74g9fcag80b735e2d3d9", "Deathfog"),
	Deepwater = ts:Create("h1d2c7e49ge777g4cf4ga93dg537d356d0927", "Sea"), -- No actual DisplayName set for this surface
	ExplosionCloud = ts:Create("hc5e88d12g5f08g4722gadaag45033d89e5a7", "Explosion Cloud"),
	Fire = ts:Create("h9d241c17g79ccg42b2g80d8gd6baba6ad9f6", "Fire"),
	FireBlessed = ts:Create("h3be44cfbg20beg4b06g8569g95be3f938eed", "Blessed Fire"),
	FireCloud = ts:Create("hf6366832g9247g42fagb5a1gee2f03b3ff06", "Fire Cloud"),
	FireCloudBlessed = ts:Create("hd6aa99bbg2e96g4561gb44ag75d97bf449eb", "Blessed Fire Cloud"),
	FireCloudCursed = ts:Create("h343c0fbdgaf40g415fg8f81g0acda0561996", "Cursed Fire Cloud"),
	FireCloudPurified = ts:Create("hf6366832g9247g42fagb5a1gee2f03b3ff06", "Fire Cloud"),
	FireCursed = ts:Create("h674ddc35gdb3ag4dc3g92eeg5574ba741db8", "Cursed Fire"),
	FirePurified = ts:Create("h9d241c17g79ccg42b2g80d8gd6baba6ad9f6", "Fire"),
	FrostCloud = ts:Create("h761ed327g72fbg42begbd12g5d0d96c44232", "Frost Explosion"),
	Lava = ts:Create("hbf9a3b93g1fc9g4a58g9c5dg9ea62b968d1b", "Lava"),
	Oil = ts:Create("h863a4340g93d8g4a37g83a4ge3bef90a1042", "Oil"),
	OilBlessed = ts:Create("haee6aed9g2752g4883gad86ga9ad66ee3e70", "Blessed Oil"),
	OilCursed = ts:Create("h4a9aa92egd40ag46c6g9c26g2ddfd794faac", "Cursed Oil"),
	OilPurified = ts:Create("h863a4340g93d8g4a37g83a4ge3bef90a1042", "Oil"),
	Poison = ts:Create("h3252bb32g9bcfg4dd4gbc9dg5839ad5b509a", "Poison"),
	PoisonBlessed = ts:Create("h7c4c8fafg4dd9g452aga570ga05ed90d1f75", "Blessed Poison"),
	PoisonCloud = ts:Create("h765be1f4g10e2g436dg8e51g83281e6cd714", "Poison Cloud"),
	PoisonCloudBlessed = ts:Create("h3c11e45eg2fdag441bg885ege2fe2e989341", "Blessed Poison Cloud"),
	PoisonCloudCursed = ts:Create("h2b25dcfbg6ca9g4e6bg884agd420dc75eb19", "Cursed Poison Cloud"),
	PoisonCloudPurified = ts:Create("h765be1f4g10e2g436dg8e51g83281e6cd714", "Poison Cloud"),
	PoisonCursed = ts:Create("h0d9c7db4gd2bag4b07g96a1gcd80d9ae61aa", "Cursed Poison"),
	PoisonPurified = ts:Create("h3252bb32g9bcfg4dd4gbc9dg5839ad5b509a", "Poison"),
	SmokeCloud = ts:Create("hb57b3935gfde9g4a05g82d2gfc8c3aa029cf", "Smoke Cloud"),
	SmokeCloudBlessed = ts:Create("hbf02846cg1055g428dgb753gbfdd15ac3ee6", "Blessed Smoke Cloud"),
	SmokeCloudCursed = ts:Create("h9df9eca7g2031g445egbc1bg4184a9f47a95", "Cursed Smoke Cloud"),
	SmokeCloudPurified = ts:Create("hb57b3935gfde9g4a05g82d2gfc8c3aa029cf", "Smoke Cloud"),
	Source = ts:Create("ha6811009g9b6dg4d7egb545g71f84ab5da8f", "Source"),
	SourceBlessed = ts:Create("hb0d019b5g8b09g489dgb863g757a4f6e6897", "Blessed Source"),
	SourceCursed = ts:Create("h21b45732g6abdg4409g8ba0g5bc86f63a573", "Cursed Source"),
	SourcePurified = ts:Create("ha6811009g9b6dg4d7egb545g71f84ab5da8f", "Source"),
	Sulfuric = ts:Create("h28954ca9gdeeag45a2g9db1ga3d5e2f7f49a", "Sulfurium"), -- Overwritten in LeaderLib to remove the Pipes ||
	Water = ts:Create("h2802f36dga180g4e96gbf08g2e4cde9c8e22", "Water"),
	WaterBlessed = ts:Create("h9ad4a6e1g5b71g4b42gb45bgbe80c5e48bda", "Blessed Water"),
	WaterCloud = ts:Create("hb9d59adeg447cg46ccga1e0g4bfbfaba0b73", "Steam Cloud"),
	WaterCloudBlessed = ts:Create("h573ae0f2gaf22g4898gb2feg707866e4b462", "Blessed Steam"),
	WaterCloudCursed = ts:Create("hf6c390eag825bg4962ga378g131add988ce3", "Cursed Steam"),
	WaterCloudElectrified = ts:Create("h311e8a3dgc1aeg4fdbg822dg0a470c03c294", "Electrified Steam"),
	WaterCloudElectrifiedBlessed = ts:Create("h0b2994b7g3e27g499eg9ff8gd5b8ed87c17a", "Blessed Electrified Steam"),
	WaterCloudElectrifiedCursed = ts:Create("h8c9abb09gf966g467eg9dddg68c01db6a52b", "Cursed Electrified Steam"),
	WaterCloudElectrifiedPurified = ts:Create("h311e8a3dgc1aeg4fdbg822dg0a470c03c294", "Electrified Steam"),
	WaterCloudPurified = ts:Create("hb9d59adeg447cg46ccga1e0g4bfbfaba0b73", "Steam Cloud"),
	WaterCursed = ts:Create("hfe6f85f6g03afg4c67gba3bg1db7644095a5", "Cursed Water"),
	WaterElectrified = ts:Create("h36de6e45g7f77g4548g8f51gdf58e71d1691", "Electrified Water"),
	WaterElectrifiedBlessed = ts:Create("h06695366g31f3g4cb6ga262g98e01c3d66da", "Blessed Electrified Water"),
	WaterElectrifiedCursed = ts:Create("hb50e6faag1b96g4f94g8de3g21f5e8f2d371", "Cursed Electrified Water"),
	WaterElectrifiedPurified = ts:Create("h36de6e45g7f77g4548g8f51gdf58e71d1691", "Electrified Water"),
	WaterFrozen = ts:Create("haf0c6ea5gbdbbg4b31g81f5gd7a42302faa6", "Ice"),
	WaterFrozenBlessed = ts:Create("h78a6ad4agd4a7g409fg8120g34a4b9d0d6a9", "Blessed Ice"),
	WaterFrozenCursed = ts:Create("h1becc132g703dg4386gb839g290943b70256", "Cursed Ice"),
	WaterFrozenPurified = ts:Create("haf0c6ea5gbdbbg4b31g81f5gd7a42302faa6", "Ice"),
	WaterPurified = ts:Create("h2802f36dga180g4e96gbf08g2e4cde9c8e22", "Water"),
	Web = ts:Create("h758c25fcgc899g4016g8967g1812cf70e353", "Web"),
	WebBlessed = ts:Create("h5855a730gc280g40c5g81ccg5e47dfc7a3dd", "Blessed Web"),
	WebCursed = ts:Create("h32a3af9cg9befg45b2g9ec5ge9322161fc2d", "Cursed Web"),
	WebPurified = ts:Create("h758c25fcgc899g4016g8967g1812cf70e353", "Web"),
}

LocalizedText.ActionSkills = {
	ActionAttackGround = ts:Create("hbdac34fdg43b6g4439g9947g6676e9c03294", "Basic Attack"),
	ActionSkillDisarm = ts:Create("h0caaedadg4d07g4378g9cd1ge13fee7703e7", "Disarm trap"),
	ActionSkillEndTurn = ts:Create("ha17c1b4bgc146g4897g8cfeg8e379b560530", "End Turn"),
	ActionSkillFlee = ts:Create("hb399d83eg5ae8g48d0g8f7eg1a89d707f7f9", "Flee"),
	ActionSkillGuard = ts:Create("hcf2cc556g6779g4605g95a8g23ded44b1e7c", "Delay your turn"),
	ActionSkillIdentify = ts:Create("ha3f5e4ecg662eg457fg95b5g4b37cf12028b", "Identify"),
	ActionSkillLockpick = ts:Create("h12379ad5g2d06g43b0g8bb2gae030cc52b8a", "Pick Lock"),
	ActionSkillRepair = ts:Create("hfb0ab865gb8dfg4e35g9c8dg0a8bb9445348", "Repair"),
	ActionSkillSheathe = {Off=ts:Create("h14dec5c1g0fa6g4abag8219gba6727c227d8", "Unsheathe"), On=ts:Create("hbb510089g3d5bg434dga929gcb697fcaf656", "Sheathe")},
	ActionSkillSneak = {Off=ts:Create("h7ccd039age7f6g4022g9078g4b8d3749c956", "Enter Sneak Mode"), On=ts:Create("hc0d5bf50g6523g4779g9b2egb772480114c7", "Exit Sneak Mode")},
}

LocalizedText.TraitNames = {
	Forgiving = ts:Create("hcb9dc268g2164g4b10g9267gfda4cae74b56", "Forgiving"),
	Vindictive = ts:Create("h9cee362ag05abg4e01gb64ag3099b3c6db73", "Vindictive"),
	Bold = ts:Create("h4d3591b0g91b8g45acg84a3g34654e3da81f", "Bold"),
	Cautious = ts:Create("hb3d412f6g0128g4faag9c0eg4c85568f2166", "Cautious"),
	Altruistic = ts:Create("hfca28b9ag77a3g44cfg8eefgebcf830e07f3", "Altruistic"),
	Egotistical = ts:Create("he855d563g6297g4dc3ga08eg67dd4fdbd866", "Egotistical"),
	Independent = ts:Create("h65b93013g4e90g4b55g8c00g4d0ccd01add2", "Independent"),
	Obedient = ts:Create("h6bf8d8feg5234g404bg9b50ga32041dc3d92", "Obedient"),
	Pragmatic = ts:Create("h2ab97575g7d62g4b9dgaa08gfc99590a3980", "Pragmatic"),
	Romantic = ts:Create("hda8b82adg6e43g4d8fg912eg3607004cc47d", "Romantic"),
	Spiritual = ts:Create("hd4d290aegd2e7g4540gba63gf8ed188bf20d", "Spiritual"),
	Materialistic = ts:Create("h9906f3aeg2d87g47aega1adg372f48eb840a", "Materialistic"),
	Righteous = ts:Create("h53139c5fged6cg4e56gae1dg1d0ae1fa9b9a", "Righteous"),
	Renegade = ts:Create("he7fba2adgc894g4399g985cgb5251f66cda8", "Renegade"),
	Blunt = ts:Create("hc992aba4g83eeg4e29g9cb0g0d507a83bc93", "Blunt"),
	Considerate = ts:Create("h7dfa94ccg14c5g463cg81ceg7fe27308a74e", "Considerate"),
	Compassionate = ts:Create("h9b27e541g8c15g4b74g9654gca77a2377cfc", "Compassionate"),
	Heartless = ts:Create("h103b7077g828eg4849gb4d0g8a2629a444c8", "Heartless"),
}

LocalizedText.Requirements = {
	Level = ts:Create("hdac4a008g7019g4a50g9887gc03eb73be9b4", "Level"),
	Combat = ts:Create("hc03e8eaagdca1g423dgb096gae39e3a975f2", "Can only be cast in combat."),
	NotCombat = ts:Create("hb1b287b5g3c91g4b52ga408g4fece4a73d24", "Can only be cast outside of combat."),
	Immobile = ts:Create("hc3338918g67a4g4002g85f4g07818bad4e94", "Cannot use when Movement speed is 0."),
	NotImmobile = ts:Create("hb449144agb84dg4499ga455g06ea10b1bd7a", "Can only use when Movement speed is 0."),
	Tag = ts:Create("h67e90c1eg8eefg4313ga2efg34d42f163756", "tag"),
	TALENT_Sourcerer = ts:Create("hc4a66cefg7cceg492eg8739g5940d7f0a286", "Can only be cast by Sourcerers<br>"),
	NotTALENT_Sourcerer = ts:Create("he4c521fdg45e1g4a19g934eg28c0de7bd7f9", "Cannot be cast by Sourcerers<br>"),
	MinKarma = ts:Create("h3a4ccbd9g3562g457dgbd42g4819bafceba8", "Minimum Karma"),
	MaxKarma = ts:Create("h735e123eg3bedg40e4gb445ge3e84405c963", "Maximum Karma"),
	IncompatibleWith = ts:Create("h97ce8eb1gaa65g475egb663g210e24bb0833", "Incompatible with [1]"),
	Requires = ts:Create("h7de69a95g70cag4bb3gbabcg1cf2df46f12c", "Requires [1]"),
	IncompatibleWithMultiple = ts:Create("h3fa5694dgb995g4311ga09eg8369fa1c3847", "Incompatible with [1] [2]"),
	RequiresMultiple = ts:Create("ha6e36605gee35g4aaagaddbg7ab8bfaf86f6", "Requires [1] [2]"),
	ScalesWith = ts:Create("h565537edgdec5g4483g938fg296519760088", "Scales With [1]"),
}

LocalizedText.Mods = {
	DivineTalents = ts:Create("he470681fg8373g4fa6ga978g02089eae5d9e", "Divine Talents"),
}

Ext.Events.SessionLoaded:Subscribe(function ()
	if Ext.Mod.IsModLoaded(Data.ModID.GiftBag.AnimalEmpathy) then
		LocalizedText.TalentDescriptions.AnimalEmpathy = LocalizedText.TalentDescriptionsAlt.AnimalEmpathy
	end
	if GameHelpers.GetExtraData("TalentViolentMagicCriticalChancePercent", 100) < 100 then
		LocalizedText.TalentDescriptions.ViolentMagic = LocalizedText.TalentDescriptionsAlt.ViolentMagic
	end
	
	LocalizedText.DamageTypeNameAlphabeticalOrder = {}
	local nameToDamageType = {}
	local sortedNames = {}

	for damageType,v in pairs(LocalizedText.DamageTypeNames) do
		local displayName = v.Text.Value
		sortedNames[#sortedNames+1] = displayName
		nameToDamageType[displayName] = damageType
	end

	table.sort(sortedNames)

	for i=1,#sortedNames do
		local displayName = sortedNames[i]
		local damageType = nameToDamageType[displayName]
		table.insert(LocalizedText.DamageTypeNameAlphabeticalOrder, damageType)
	end
end)