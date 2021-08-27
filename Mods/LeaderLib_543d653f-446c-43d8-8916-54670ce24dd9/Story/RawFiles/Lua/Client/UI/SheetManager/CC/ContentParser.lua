local ElementType = {
	[0] = "OptionSelector",
	[1] = "Option",
	[2] = "Content",
	[3] = "ControllerInput",
	[4] = "Title",
	[5] = "OptionSelector",
}

local ContentType = {
	[0] = "Text",
	[1] = "List",
	[2] = "cdContent",
	[3] = "Tooltip",
	[4] = "inputBtnHint",
}

local ContentTypeLength = {
	[false] = {
		Text = 1,
		List = 2,
		cdContent = 2,
		Tooltip = 1,
		inputBtnHint = 0,
	},
	--Controllers
	[true] = {
		Text = 1,
		List = 2,
		cdContent = 2,
		Tooltip = 1,
		inputBtnHint = 2,
	},
}
local function GetContentLength(arr, index)
	local length = 3
	local contentType = ContentType[arr[index+3]]
	if contentType then
		if contentType ~= "List" then
			return length + ContentTypeLength[contentType]
		else
			local listLength = arr[index+5]
			length = length + 2
			if listLength and type(listLength) == "number" then
				length = length + (listLength * 2)
			end
			return length
		end
	end
	return length
end

local ElementTypeSize = {
	[false] = {
		OptionSelector = 0,
		Option = 3,
		Content = GetContentLength,
		ControllerInput = 0,
		Title = 2,
	},
	--Controllers
	[true] = {
		OptionSelector = 3,
		Option = 3,
		Content = GetContentLength,
		ControllerInput = 3,
		Title = 2,
	},
}

local ElementTypeNames = {
	OptionSelector = "OptionSelector",
	Option = "Option",
	Content = "Content",
	ControllerInput = "ControllerInput",
	Title = "Title",
}

local function tprint(tbl, indent)
	if not indent then indent = 0 end
	--local toprint = string.rep(" ", indent) .. "{\r\n"
	--local toprint = string.rep(" ", indent) .. "{\r\n"
	local toprint = "{\r\n"
	indent = indent + 1
	for k, v in pairs(tbl) do
		toprint = toprint .. string.rep(" ", indent)
		if (type(k) == "number") then
			toprint = toprint .. "[" .. k .. "] = "
		elseif (type(k) == "string") then
			toprint = toprint  .. k ..  " = " 
		end
		if (type(v) == "number") then
			toprint = toprint .. v .. ",\r\n"
		elseif (type(v) == "string") then
			toprint = toprint .. "\"" .. v .. "\",\r\n"
		elseif (type(v) == "table") then
			toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
		else
			toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
		end
	end
	toprint = toprint .. string.rep(" ", indent-1) .. "}"
	return toprint
end


local function ParseArray(arr)
	local content = {}
	local i = 0
	local length = #arr-1
	while i < length do
		local entryType = ElementType[arr[i]]
		i = i + 1
		if entryType then
			local data = {
				Type = arr[i],
				TypeName = entryType,
				Elements = {}
			}
			content[#content+1] = data
			local length = ElementTypeSize[Vars.ControllerEnabled][entryType]
			if length then
				if type(length) == "function" then
					length = length(arr, i)
				end
				for j=0,length do
					data.Elements[#data.Elements+1] = arr[i+j]
				end
				i = i + length
			end
		end
	end
	print(tprint(content,0))
end

---@param self CharacterCreationWrapper
local function OnUpdateContent(self, ui, event)
	local this = self:GetRoot()
	if this then
		--LeaderLib override success
		if this.isExtended then
			ParseArray(this.contentArray)
			--this.clearArray("contentArray")
		end
	end
end

local testArray = {
	[0] = 4,
	0,
	"Background",
	1,
	0,
	0,
	"<font color=\"#C80030\">Origin:</font> The Red Prince",
	2,
	0,
	0,
	0,
	"You are infamous: a brilliant warrior-general exiled from his empire for cavorting with demons. Fallen from grace, you refuse to give up. The throne will be yours again.",
	2,
	0,
	0,
	2,
	"r",
	2,
	2,
	0,
	0,
	1,
	"Talents",
	2,
	93,
	"Sophisticated",
	94,
	"Spellsong",
	1,
	0,
	1,
	"<font color=\"#C80030\">Origin:</font> Sebille",
	2,
	0,
	1,
	0,
	"A slave no longer, you still bear the living scar your master used to dominate you. He turned you into an assassin; made you hunt your own kin. Now, you hunt him.",
	2,
	0,
	1,
	2,
	"r",
	2,
	2,
	0,
	1,
	1,
	"Talents",
	2,
	90,
	"Corpse Eater",
	89,
	"Ancestral Knowledge",
	1,
	0,
	2,
	"<font color=\"#C80030\">Origin:</font> Ifan ben-Mezd",
	2,
	0,
	2,
	0,
	"A crusader in Lucian's army, you lost your faith as war claimed countless innocents. Now, you're a Lone Wolf mercenary. Your mission? Kill Lucian's son.",
	2,
	0,
	2,
	2,
	"r",
	2,
	2,
	0,
	2,
	1,
	"Talents",
	2,
	87,
	"Ingenious",
	88,
	"Thrifty",
	1,
	0,
	3,
	"<font color=\"#C80030\">Origin:</font> Beast",
	2,
	0,
	3,
	0,
	"Your failed rebellion against the Queen nearly destroyed you - so you began a new life on the high seas. Now, your old enemy is back. If you don't stop her, no-one will.",
	2,
	0,
	3,
	2,
	"r",
	2,
	2,
	0,
	3,
	1,
	"Talents",
	2,
	91,
	"Sturdy",
	92,
	"Dwarven Guile",
	1,
	0,
	4,
	"<font color=\"#C80030\">Origin:</font> Lohse",
	2,
	0,
	4,
	0,
	"You're a musician: performer, star, and host to all manner of disembodied visitors. Now, one dark voice has silenced them all - and aims to claim your body for itself.",
	2,
	0,
	4,
	2,
	"r",
	2,
	2,
	0,
	4,
	1,
	"Talents",
	2,
	87,
	"Ingenious",
	88,
	"Thrifty",
	1,
	0,
	5,
	"<font color=\"#C80030\">Origin:</font> Fane",
	2,
	0,
	5,
	0,
	"You woke up and your world was gone. The last of your kind, you hide behind a charmed mask, searching for the truth about a history that no-one knew existed.",
	2,
	0,
	5,
	2,
	"r",
	2,
	2,
	0,
	5,
	1,
	"Talents",
	2,
	62,
	"Undead",
	87,
	"Ingenious",
	1,
	0,
	6,
	"<font color=\"#C80030\">Origin:</font> Deku'Deku",
	2,
	0,
	6,
	0,
	"The last great war wrought devastation on all the races. You remember first-hand the massacre of your people. While the world continued to spin, your resolve only aged like a great tree - battered by time, yet steadfast and unyielding.",
	2,
	0,
	6,
	2,
	"r",
	2,
	2,
	0,
	6,
	1,
	"Talents",
	2,
	90,
	"Corpse Eater",
	89,
	"Ancestral Knowledge",
	1,
	0,
	7,
	"<font color=\"#C80030\">Origin:</font> Berobreus",
	2,
	0,
	7,
	0,
	"After breaching the material plane, you find a world ripe with source. Let the feast begin.",
	2,
	0,
	7,
	2,
	"r",
	2,
	2,
	0,
	7,
	1,
	"Talents",
	2,
	93,
	"Sophisticated",
	94,
	"Spellsong",
	1,
	0,
	8,
	"<font color=\"#C80030\">Origin:</font> Null",
	2,
	0,
	8,
	0,
	"Upon a mound of corpses, in a strange lab filled with flesh and strange machines, your mind snapped into consciousness. An unending abyss where your soul once resided, you persist with a singular desire - Tearing apart the one who did this to you.",
	2,
	0,
	8,
	2,
	"r",
	2,
	2,
	0,
	8,
	1,
	"Talents",
	2,
	90,
	"Corpse Eater",
	89,
	"Ancestral Knowledge",
	1,
	0,
	9,
	"<font color=\"#C80030\">Origin:</font> Oberon",
	2,
	0,
	9,
	0,
	"You awoke to a body made of plush. Roaming the land in search of kin, armed only with your own sense of justice, you sought answers to the nature of your being, yet the Magistry deemed you an abomination. Time to deliver some \"Bear Justice\".",
	2,
	0,
	9,
	2,
	"r",
	2,
	2,
	0,
	9,
	1,
	"Talents",
	2,
	62,
	"Undead",
	91,
	"Sturdy",
	1,
	0,
	10,
	"<font color=\"#C80030\">Origin:</font> Zebadiah",
	2,
	0,
	10,
	0,
	"While other \"conscious undead\" exist purely in skeleton form, your flesh persists, rotten skin and all. Others of your kind mindlessly shamble, yet you ponder and roam purposefully. Sure, brains taste good, but that's just how it is.",
	2,
	0,
	10,
	2,
	"r",
	2,
	2,
	0,
	10,
	1,
	"Talents",
	2,
	62,
	"Undead",
	87,
	"Ingenious",
	1,
	0,
	11,
	"<font color=\"#C80030\">Origin:</font> Harken",
	2,
	0,
	11,
	0,
	"After a illustrious career as a mercenary, brutally smashing enemies with the legendary Anvilmar, you find yourself adrift on the high seas, captured by the Divine Order.",
	2,
	0,
	11,
	2,
	"r",
	2,
	2,
	0,
	11,
	1,
	"Talents",
	2,
	91,
	"Sturdy",
	92,
	"Dwarven Guile",
	1,
	0,
	12,
	"<font color=\"#C80030\">Origin:</font> Kor'vash",
	2,
	0,
	12,
	0,
	"After a stressful career as a mercenary, cleaning up the aftermath of your crazy comrades, you find yourself captured by the Divine Order, charged with being a Sourcerer. If only they knew.",
	2,
	0,
	12,
	2,
	"r",
	2,
	2,
	0,
	12,
	1,
	"Talents",
	2,
	93,
	"Sophisticated",
	94,
	"Spellsong",
	1,
	0,
	13,
	"<font color=\"#C80030\">Custom:</font> Undead Elf",
	2,
	0,
	13,
	0,
	"The Undead are considered abominations in Rivellon, an affront to the natural order whose mere presence invites violence. Those who walk among the living must do so masked.",
	2,
	0,
	13,
	2,
	"r",
	2,
	2,
	0,
	13,
	1,
	"Talents",
	2,
	62,
	"Undead",
	90,
	"Corpse Eater",
	1,
	0,
	14,
	"<font color=\"#C80030\">Custom:</font> Undead Human",
	2,
	0,
	14,
	0,
	"The Undead are considered abominations in Rivellon, an affront to the natural order whose mere presence invites violence. Those who walk among the living must do so masked.",
	2,
	0,
	14,
	2,
	"r",
	2,
	2,
	0,
	14,
	1,
	"Talents",
	2,
	62,
	"Undead",
	87,
	"Ingenious",
	1,
	0,
	15,
	"<font color=\"#C80030\">Custom:</font> Dwarf",
	2,
	0,
	15,
	0,
	"Between haves and have-nots alike, dwarves are fiercely nationalistic. Even the poorest dwarf would die for their dwindling Kingdom. But not all would die for the Queen...",
	2,
	0,
	15,
	2,
	"r",
	2,
	2,
	0,
	15,
	1,
	"Talents",
	2,
	91,
	"Sturdy",
	92,
	"Dwarven Guile",
	1,
	0,
	16,
	"<font color=\"#C80030\">Custom:</font> Elf",
	2,
	0,
	16,
	0,
	"The annals of elvendom are written in flesh - elves eat of the dead and absorb their memories. Now, the elves are in peril. An unforgettable hero must rise.",
	2,
	0,
	16,
	2,
	"r",
	2,
	2,
	0,
	16,
	1,
	"Talents",
	2,
	90,
	"Corpse Eater",
	89,
	"Ancestral Knowledge",
	1,
	0,
	17,
	"<font color=\"#C80030\">Custom:</font> Human",
	2,
	0,
	17,
	0,
	"Adventurous, confident, flexible, at times even clever, humans are dominant in Rivellon. They always play the hero in their own endless wars… even when they’re the villains.",
	2,
	0,
	17,
	2,
	"r",
	2,
	2,
	0,
	17,
	1,
	"Talents",
	2,
	87,
	"Ingenious",
	88,
	"Thrifty",
	1,
	0,
	18,
	"<font color=\"#C80030\">Custom:</font> Berobreus",
	2,
	0,
	18,
	0,
	"After breaching the material plane, you find a world ripe with source. Let the feast begin.",
	2,
	0,
	18,
	2,
	"r",
	2,
	2,
	0,
	18,
	1,
	"Talents",
	2,
	93,
	"Sophisticated",
	94,
	"Spellsong",
	1,
	0,
	19,
	"<font color=\"#C80030\">Custom:</font> Undead Dwarf",
	2,
	0,
	19,
	0,
	"The Undead are considered abominations in Rivellon, an affront to the natural order whose mere presence invites violence. Those who walk among the living must do so masked.",
	2,
	0,
	19,
	2,
	"r",
	2,
	2,
	0,
	19,
	1,
	"Talents",
	2,
	62,
	"Undead",
	91,
	"Sturdy",
	1,
	0,
	20,
	"<font color=\"#C80030\">Custom:</font> Lizard",
	2,
	0,
	20,
	0,
	"To most, lizards are as exotic and mysterious as the Ancient Empire itself. The outside world knows them as warriors, philosophers and slavers, to be respected... and feared.",
	2,
	0,
	20,
	2,
	"r",
	2,
	2,
	0,
	20,
	1,
	"Talents",
	2,
	93,
	"Sophisticated",
	94,
	"Spellsong",
	1,
	0,
	21,
	"<font color=\"#C80030\">Custom:</font> Undead Lizard",
	2,
	0,
	21,
	0,
	"The Undead are considered abominations in Rivellon, an affront to the natural order whose mere presence invites violence. Those who walk among the living must do so masked.",
	2,
	0,
	21,
	2,
	"r",
	2,
	2,
	0,
	21,
	1,
	"Talents",
	2,
	62,
	"Undead",
	93,
	"Sophisticated",
	4,
	1,
	"Build Preset",
	4,
	9,
	"Build Preset",
	1,
	1,
	0,
	"Battlemage",
	2,
	1,
	0,
	3,
	"Amplifies brute strength with powerful magic.",
	2,
	1,
	0,
	2,
	"s",
	3,
	1,
	9,
	0,
	"Battlemage",
	1,
	1,
	1,
	"Cleric",
	2,
	1,
	1,
	3,
	"Heals allies or smashes skulls, depending on the direction of the winds",
	2,
	1,
	1,
	2,
	"s",
	3,
	1,
	9,
	1,
	"Cleric",
	1,
	1,
	2,
	"Conjurer",
	2,
	1,
	2,
	3,
	"Conjures a trusty personal demon and elemental totems to aid in battle",
	2,
	1,
	2,
	2,
	"s",
	3,
	1,
	9,
	2,
	"Conjurer",
	1,
	1,
	3,
	"Enchanter",
	2,
	1,
	3,
	3,
	"Prefers to turn the tide of battle from afar, manipulating foes with powerful magic",
	2,
	1,
	3,
	2,
	"s",
	3,
	1,
	9,
	3,
	"Enchanter",
	1,
	1,
	4,
	"Fighter",
	2,
	1,
	4,
	3,
	"Brutal warrior and expert in close combat",
	2,
	1,
	4,
	2,
	"s",
	3,
	1,
	9,
	4,
	"Fighter",
	1,
	1,
	5,
	"Inquisitor",
	2,
	1,
	5,
	3,
	"A daring mace-wielder risking life and limb to decimate evil head-on",
	2,
	1,
	5,
	2,
	"s",
	3,
	1,
	9,
	5,
	"Inquisitor",
	1,
	1,
	6,
	"Knight",
	2,
	1,
	6,
	3,
	"Specialised in war tactics, knights are trained not only to fight, but to rally troops",
	2,
	1,
	6,
	2,
	"s",
	3,
	1,
	9,
	6,
	"Knight",
	1,
	1,
	7,
	"Metamorph",
	2,
	1,
	7,
	3,
	"Adapts to dangerous situations with transformational tricks of nature",
	2,
	1,
	7,
	2,
	"s",
	3,
	1,
	9,
	7,
	"Metamorph",
	1,
	1,
	8,
	"Ranger",
	2,
	1,
	8,
	3,
	"A marksman with a legendary knack for self-preservation",
	2,
	1,
	8,
	2,
	"s",
	3,
	1,
	9,
	8,
	"Ranger",
	1,
	1,
	9,
	"Rogue",
	2,
	1,
	9,
	3,
	"With a lot of skill and a little luck, this rogue sees the world as an open coffer",
	2,
	1,
	9,
	2,
	"s",
	3,
	1,
	9,
	9,
	"Rogue",
	1,
	1,
	10,
	"Shadowblade",
	2,
	1,
	10,
	3,
	"A powerful assassin whose arsenal of both daggers and magic would terrify any enemy, if they ever saw it coming.",
	2,
	1,
	10,
	2,
	"s",
	3,
	1,
	9,
	10,
	"Shadowblade",
	1,
	1,
	11,
	"Wayfarer",
	2,
	1,
	11,
	3,
	"A survivalist and a practitioner of magic, the Wayfarer is hard to hit and even harder to evade.",
	2,
	1,
	11,
	2,
	"s",
	3,
	1,
	9,
	11,
	"Wayfarer",
	1,
	1,
	12,
	"Witch",
	2,
	1,
	12,
	3,
	"An intimidating presence whose bone-chilling powers terrify friend and foe alike",
	2,
	1,
	12,
	2,
	"s",
	3,
	1,
	9,
	12,
	"Witch",
	1,
	1,
	13,
	"Wizard",
	2,
	1,
	13,
	3,
	"A scholar of magic specialised in starting and ending battles with a flick of the wrist, exacting swift victory from a safe distance",
	2,
	1,
	13,
	2,
	"s",
	3,
	1,
	9,
	13,
	"Wizard",
	1,
	1,
	14,
	"Assassin",
	2,
	1,
	14,
	3,
	"A contract killer who slays their prey with a pair of deadly blades, whether motivated by political, religious, or financial means",
	2,
	1,
	14,
	2,
	"s",
	3,
	1,
	9,
	14,
	"Assassin",
	1,
	1,
	15,
	"Blademaster",
	2,
	1,
	15,
	3,
	"A wanderer who wields a foreign blade, slaying evil as they pursue their own code of justice",
	2,
	1,
	15,
	2,
	"s",
	3,
	1,
	9,
	15,
	"Blademaster",
	1,
	1,
	16,
	"Chaos Weaver",
	2,
	1,
	16,
	3,
	"Sorcerors who wield the power of Chaos, leveraging luck and foresight to lay waste upon the battlefield",
	2,
	1,
	16,
	2,
	"s",
	3,
	1,
	9,
	16,
	"Chaos Weaver",
	1,
	1,
	17,
	"Dragon Slayer",
	2,
	1,
	17,
	3,
	"A former marksman from a long-forgotten regiment, tasked with destroying dragonkind. With their unyielding strength, Dragon Slayers utilize Greatbows to pierce their enemies with arrows the size of spears",
	2,
	1,
	17,
	2,
	"s",
	3,
	1,
	9,
	17,
	"Dragon Slayer",
	1,
	1,
	18,
	"Shieldmaster",
	2,
	1,
	18,
	3,
	"A warrior who strives to defend the innocent through a unique style that utilizes dual shields",
	2,
	1,
	18,
	2,
	"s",
	3,
	1,
	9,
	18,
	"Shieldmaster",
	1,
	1,
	19,
	"Fencer",
	2,
	1,
	19,
	3,
	"A former gladiator whose repertoire of blade skills once amazed crowds and foes alike",
	2,
	1,
	19,
	2,
	"s",
	3,
	1,
	9,
	19,
	"Fencer",
	1,
	1,
	20,
	"Halberdier",
	2,
	1,
	20,
	3,
	"A warrior who wields the deadly halberd, a combination of spear and axe, taking advantage of the reach and versatility it offers",
	2,
	1,
	20,
	2,
	"s",
	3,
	1,
	9,
	20,
	"Halberdier",
	1,
	1,
	21,
	"Monk (Strength)",
	2,
	1,
	21,
	3,
	"Disciplined warriors who wield metal quarterstaffs, overwhelming enemies with strength and sheer force of will.",
	2,
	1,
	21,
	2,
	"s",
	3,
	1,
	9,
	21,
	"Monk (Strength)",
	1,
	1,
	22,
	"Monk (Finesse)",
	2,
	1,
	22,
	3,
	"Disciplined warriors who wield quarterstaffs, overwhelming enemies with finesse and sheer force of will",
	2,
	1,
	22,
	2,
	"s",
	3,
	1,
	9,
	22,
	"Monk (Finesse)",
	1,
	1,
	23,
	"Pirate",
	2,
	1,
	23,
	3,
	"Adventurers who sail the high seas in search of treasure and opportunity. Equipped with a flintlock pistol, pirates tend to fire explosive lead when their enemies least expect it",
	2,
	1,
	23,
	2,
	"s",
	3,
	1,
	9,
	23,
	"Pirate",
	1,
	1,
	24,
	"Reaper",
	2,
	1,
	24,
	3,
	"A rare type of warrior that wields an intimidating scythe. Some believe them to be soldiers of Death, as their prowess with curved blades is second only to their innate affinity with Necromancy.",
	2,
	1,
	24,
	2,
	"s",
	3,
	1,
	9,
	24,
	"Reaper",
	1,
	1,
	25,
	"Rifleman",
	2,
	1,
	25,
	3,
	"A marksman armed with a new weapon predicted to change the art of war - The Rifle. Steel, wood, and a mysterious alchemical compound combine to create explosions that propel lead at break-neck speeds, piercing armor and flesh with ease",
	2,
	1,
	25,
	2,
	"s",
	3,
	1,
	9,
	25,
	"Rifleman",
	1,
	1,
	26,
	"Runic Knight",
	2,
	1,
	26,
	3,
	"Adept mages who train in the ways of the sword, using special 'Runeblades' as a conduit to enhance their magic. Crafty use of the runes etched upon their blades allow Runic Knights to weave their attacks and spells together, devastating the battlefield",
	2,
	1,
	26,
	2,
	"s",
	3,
	1,
	9,
	26,
	"Runic Knight",
	4,
	4,
	"Face",
	4,
	7,
	"Facial Features",
	4,
	5,
	"Hair Style",
	4,
	3,
	"Skin Colour",
	4,
	6,
	"Hair Colour",
	4,
	8,
	"Voice",
	1,
	4,
	0,
	"Face 1",
	1,
	4,
	1,
	"Face 2",
	1,
	4,
	2,
	"Face 3",
	1,
	4,
	3,
	"Face 4",
	1,
	4,
	4,
	"Face 5",
	1,
	4,
	5,
	"Face 6",
	1,
	4,
	6,
	"Face 7",
	1,
	4,
	7,
	"Face 8",
	1,
	4,
	8,
	"Face 9",
	1,
	4,
	9,
	"Face 10",
	1,
	4,
	10,
	"Face 11",
	1,
	4,
	11,
	"Face 12",
	1,
	4,
	12,
	"Face 13",
	1,
	4,
	13,
	"Face 14",
	1,
	4,
	14,
	"Face 15",
	1,
	4,
	15,
	"Face 16",
	1,
	7,
	0,
	"None",
	1,
	7,
	1,
	"Facial Feature 1",
	1,
	7,
	2,
	"Facial Feature 2",
	1,
	7,
	3,
	"Facial Feature 3",
	1,
	7,
	4,
	"Facial Feature 4",
	1,
	7,
	5,
	"Facial Feature 5",
	1,
	7,
	6,
	"Facial Feature 6",
	1,
	7,
	7,
	"Facial Feature 7",
	1,
	7,
	8,
	"Facial Feature 8",
	1,
	7,
	9,
	"Facial Feature 9",
	1,
	7,
	10,
	"Facial Feature 10",
	1,
	7,
	11,
	"Facial Feature 11",
	1,
	7,
	12,
	"Facial Feature 12",
	1,
	7,
	13,
	"Facial Feature 13",
	1,
	7,
	14,
	"Facial Feature 14",
	1,
	7,
	15,
	"Facial Feature 15",
	1,
	7,
	16,
	"Facial Feature 16",
	1,
	7,
	17,
	"Facial Feature 17",
	1,
	7,
	18,
	"Facial Feature 18",
	1,
	7,
	19,
	"Facial Feature 19",
	1,
	7,
	20,
	"Facial Feature 20",
	1,
	7,
	21,
	"Facial Feature 21",
	1,
	7,
	22,
	"Facial Feature 22",
	1,
	7,
	23,
	"Facial Feature 23",
	1,
	7,
	24,
	"Facial Feature 24",
	1,
	7,
	25,
	"Facial Feature 25",
	1,
	7,
	26,
	"Facial Feature 26",
	1,
	5,
	0,
	"Hair Style 1",
	1,
	5,
	1,
	"Hair Style 2",
	1,
	5,
	2,
	"Hair Style 3",
	1,
	5,
	3,
	"Hair Style 4",
	1,
	5,
	4,
	"Hair Style 5",
	1,
	5,
	5,
	"Hair Style 6",
	1,
	5,
	6,
	"Hair Style 7",
	1,
	5,
	7,
	"Hair Style 8",
	1,
	5,
	8,
	"Hair Style 9",
	1,
	5,
	9,
	"Hair Style 10",
	1,
	5,
	10,
	"Hair Style 11",
	1,
	5,
	11,
	"Hair Style 12",
	1,
	5,
	12,
	"Hair Style 13",
	1,
	5,
	13,
	"Hair Style 14",
	1,
	5,
	14,
	"Hair Style 15",
	1,
	5,
	15,
	"Hair Style 16",
	1,
	5,
	16,
	"Hair Style 17",
	1,
	5,
	17,
	"Hair Style 18",
	1,
	5,
	18,
	"Hair Style 19",
	1,
	5,
	19,
	"Hair Style 20",
	1,
	5,
	20,
	"Hair Style 21",
	1,
	5,
	21,
	"Hair Style 22",
	1,
	5,
	22,
	"Hair Style 23",
	1,
	3,
	0,
	"Amethyst",
	1,
	6,
	0,
	"Zincite",
	1,
	6,
	1,
	"Padparadscha",
	1,
	6,
	2,
	"Moonstone",
	1,
	6,
	3,
	"Smoked Topaz",
	1,
	6,
	4,
	"Fire Opal",
	1,
	6,
	5,
	"Almandine",
	1,
	6,
	6,
	"Rose Alabaster",
	1,
	6,
	7,
	"Feldspar",
	1,
	6,
	8,
	"Tanzanite",
	1,
	6,
	9,
	"Corundum",
	1,
	6,
	10,
	"Amethyst",
	1,
	6,
	11,
	"Cobalt",
	1,
	6,
	12,
	"Light Sapphire",
	1,
	6,
	13,
	"Heliotrope",
	1,
	6,
	14,
	"Fluorite",
	1,
	6,
	15,
	"Still Water",
	1,
	6,
	16,
	"Chrysolite",
	1,
	6,
	17,
	"Peridot",
	1,
	6,
	18,
	"Lilac",
	1,
	6,
	19,
	"Silver",
	1,
	6,
	20,
	"Child of Light",
	1,
	6,
	21,
	"Whimsical Wisteria",
	1,
	6,
	22,
	"Princess Peach",
	1,
	6,
	23,
	"Vivid Tangerine",
	1,
	6,
	24,
	"Blue Slate",
	1,
	6,
	25,
	"Cool Breeze",
	1,
	6,
	26,
	"Astarte",
	1,
	6,
	27,
	"Jade",
	1,
	6,
	28,
	"White Smoke",
	1,
	6,
	29,
	"Glossy Grape",
	1,
	6,
	30,
	"Lemon Quartz",
	1,
	6,
	31,
	"Smokescreen",
	1,
	6,
	32,
	"Alpha Quartz",
	1,
	6,
	33,
	"Grassy Knoll",
	1,
	6,
	34,
	"Ogre Green",
	1,
	6,
	35,
	"Mountain Meadow",
	1,
	6,
	36,
	"Pink Void",
	1,
	6,
	37,
	"Orchid",
	1,
	6,
	38,
	"Violet Visionary",
	1,
	6,
	39,
	"Pink Pixie",
	1,
	6,
	40,
	"Cupid",
	1,
	6,
	41,
	"Soulsap",
	1,
	6,
	42,
	"Asphyxia",
	1,
	6,
	43,
	"Sunset Orange",
	1,
	6,
	44,
	"Sandman",
	1,
	6,
	45,
	"Smashed Pumpkin",
	1,
	6,
	46,
	"Violator",
	1,
	6,
	47,
	"Rosso Quattro",
	1,
	6,
	48,
	"Bloodstone",
	1,
	6,
	49,
	"Madder Lake",
	1,
	6,
	50,
	"Last Sin",
	1,
	6,
	51,
	"Burn Out",
	1,
	6,
	52,
	"Folklore Fuscia",
	1,
	6,
	53,
	"Sapphire",
	1,
	6,
	54,
	"Scarlet",
	1,
	6,
	55,
	"Heroine",
	1,
	6,
	56,
	"Deep Mauve",
	1,
	6,
	57,
	"Caramel",
	1,
	6,
	58,
	"Blood Brew",
	1,
	6,
	59,
	"Bright Sky",
	1,
	6,
	60,
	"Deep Freeze",
	1,
	6,
	61,
	"Blizzard Blue",
	1,
	6,
	62,
	"Sea Nymph",
	1,
	6,
	63,
	"Gentle Earth",
	1,
	6,
	64,
	"Wild Blue Yonder",
	1,
	6,
	65,
	"Shadow Blue",
	1,
	6,
	66,
	"Spring Meadow",
	1,
	6,
	67,
	"Electra",
	1,
	6,
	68,
	"The Cure",
	1,
	6,
	69,
	"Mermaid",
	1,
	6,
	70,
	"Eucalyptus",
	1,
	6,
	71,
	"Kryptonite",
	1,
	6,
	72,
	"Wintergreen Dream",
	1,
	6,
	73,
	"Hunter's Edge",
	1,
	6,
	74,
	"Lucky",
	1,
	6,
	75,
	"Pixie Dust",
	1,
	6,
	76,
	"Celestial Blue",
	1,
	6,
	77,
	"Slate Blue",
	1,
	6,
	78,
	"High Tide",
	1,
	6,
	79,
	"Royal Purple",
	1,
	6,
	80,
	"Stelvio",
	1,
	6,
	81,
	"Siren",
	1,
	6,
	82,
	"Ultramarine Blue",
	1,
	6,
	83,
	"Void Dragon",
	1,
	6,
	84,
	"Charcoal Gray",
	1,
	6,
	85,
	"Death Knight",
	1,
	6,
	86,
	"Van Dyke Brown",
	1,
	6,
	87,
	"Violet Visionary",
	1,
	6,
	88,
	"Black Opal",
	1,
	6,
	89,
	"Purple Mountains' Majesty",
	1,
	6,
	90,
	"Zombie Troll",
	1,
	6,
	91,
	"Chathams Blue",
	1,
	6,
	92,
	"Kush",
	1,
	6,
	93,
	"Dark Craft",
	1,
	6,
	94,
	"Deepest Mode",
	1,
	6,
	95,
	"Midnight Oil",
	1,
	6,
	96,
	"Moonstone",
	1,
	8,
	0,
	"The Red Prince"
}

Ext.RegisterConsoleCommand("testcc", function()
	ParseArray(testArray)
end)

return {
	---@param cc CharacterCreationWrapper
	Init = function(cc)
		cc:RegisterInvokeListener("updateContent", OnUpdateContent, "Before", "All")
	end
}