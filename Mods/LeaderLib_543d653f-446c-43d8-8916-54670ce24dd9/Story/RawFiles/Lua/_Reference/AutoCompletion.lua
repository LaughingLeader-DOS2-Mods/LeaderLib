---@diagnostic disable

--This file is never actually loaded, and is used to make EmmyLua work better.

if not Mods then Mods = {} end
if not Mods.LeaderLib then Mods.LeaderLib = {} end
if not Mods.LeaderLib.Listeners then
	Mods.LeaderLib.Listeners = {}
end
if not Mods.LeaderLib.Import then
	Mods.LeaderLib.Import = Import
end

---@alias DamageType string|"None"|"Physical"|"Piercing"|"Corrosive"|"Magic"|"Chaos"|"Fire"|"Air"|"Water"|"Earth"|"Poison"|"Shadow"
---@alias DeathType string|"Sulfur"|"FrozenShatter"|"Surrender"|"Lifetime"|"KnockedDown"|"Piercing"|"Physical"|"Sentinel"|"DoT"|"Explode"|"Arrow"|"None"|"Acid"|"PetrifiedShatter"|"Hang"|"Incinerate"|"Electrocution"
---@alias ItemSlot string|"Weapon"|"Shield"|"Helmet"|"Breast"|"Gloves"|"Leggings"|"Boots"|"Belt"|"Amulet"|"Ring"|"Ring2"|"Wings"|"Horns"|"Overhead"|"Sentinel"

--- @alias EngineStatus string|"ADRENALINE"|"AOO"|"BOOST"|"CHANNELING"|"CLEAN"|"CLIMBING"|"COMBAT"|"COMBUSTION"|"CONSTRAINED"|"DARK_AVENGER"|"DRAIN"|"DYING"|"ENCUMBERED"|"EXPLODE"|"FLANKED"|"FORCE_MOVE"|"HIT"|"IDENTIFY"|"INFECTIOUS_DISEASED"|"INFUSED"|"INSURFACE"|"LEADERSHIP"|"LINGERING_WOUNDS"|"LYING"|"MATERIAL"|"OVERPOWER"|"REMORSE"|"REPAIR"|"ROTATE"|"SHACKLES_OF_PAIN_CASTER"|"SHACKLES_OF_PAIN"|"SITTING"|"SMELLY"|"SNEAKING"|"SOURCE_MUTED"|"SPIRIT_VISION"|"SPIRIT"|"STORY_FROZEN"|"SUMMONING"|"TELEPORT_FALLING"|"TUTORIAL_BED"|"UNHEALABLE"|"UNLOCK"|"UNSHEATHED"|"WIND_WALKER"

---@alias StatStatusType string|"ACTIVE_DEFENSE"|"BLIND"|"CHALLENGE"|"CHARMED"|"CONSUME"|"DAMAGE_ON_MOVE"|"DAMAGE"|"DEACTIVATED"|"DECAYING_TOUCH"|"DEMONIC_BARGAIN"|"DISARMED"|"EFFECT"|"EXTRA_TURN"|"FEAR"|"FLOATING"|"GUARDIAN_ANGEL"|"HEAL_SHARING_CASTER"|"HEAL_SHARING"|"HEAL"|"HEALING"|"INCAPACITATED"|"INVISIBLE"|"KNOCKED_DOWN"|"MUTED"|"PLAY_DEAD"|"POLYMORPHED"|"SPARK"|"STANCE"|"THROWN"

---@alias RaceTag "DWARF"|"ELF"|"HUMAN"|"LIZARD"

---@alias StatCharacter CDivinityStatsCharacter
---@alias DamageList StatsDamagePairList

---@alias LeaderLibGetTextPlaceholderCallback fun(param:string, character:StatCharacter):string