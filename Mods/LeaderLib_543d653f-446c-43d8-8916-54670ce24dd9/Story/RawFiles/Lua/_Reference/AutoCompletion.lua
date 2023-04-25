---@meta
---@diagnostic disable

--This file is never actually loaded, and is used to make the vscode extension work better.

if not Mods then Mods = {} end

---@class LeaderLibModTable
---@field PersistentVars LeaderLibPersistentVars
Mods.LeaderLib = {
	Import = Import,
	--AttackManager = AttackManager,
	Classes = Classes,
	Client = Client,
	CombatLog = CombatLog,
	Common = Common,
	Data = Data,
	EffectManager = EffectManager,
	Events = Events,
	GameHelpers = GameHelpers,
	GameSettingsManager = GameSettingsManager,
	Input = Input,
	LocalizedText = LocalizedText,
	Managers = Managers,
	QOL = QOL,
	SceneManager = SceneManager,
	SettingsManager = SettingsManager,
	SkillManager = SkillManager,
	StatusManager = StatusManager,
	StringHelpers = StringHelpers,
	TableHelpers = TableHelpers,
	Testing = Testing,
	Timer = Timer,
	TurnCounter = TurnCounter,
	UI = UI,
	Vars = Vars,
	VisualManager = VisualManager,
	Lib = Lib,
	ModuleUUID = "7e737d2f-31d2-4751-963f-be6ccc59cd0c",
}

---@alias DamageType "None"|"Physical"|"Piercing"|"Corrosive"|"Magic"|"Chaos"|"Fire"|"Air"|"Water"|"Earth"|"Poison"|"Shadow"
---@alias DeathType "Sulfur"|"FrozenShatter"|"Surrender"|"Lifetime"|"KnockedDown"|"Piercing"|"Physical"|"Sentinel"|"DoT"|"Explode"|"Arrow"|"None"|"Acid"|"PetrifiedShatter"|"Hang"|"Incinerate"|"Electrocution"
---@alias ItemSlot "Weapon"|"Shield"|"Helmet"|"Breast"|"Gloves"|"Leggings"|"Boots"|"Belt"|"Amulet"|"Ring"|"Ring2"|"Wings"|"Horns"|"Overhead"|"Sentinel"

--- @alias EngineStatus "ADRENALINE"|"AOO"|"BOOST"|"CHANNELING"|"CLEAN"|"CLIMBING"|"COMBAT"|"COMBUSTION"|"CONSTRAINED"|"DARK_AVENGER"|"DRAIN"|"DYING"|"ENCUMBERED"|"EXPLODE"|"FLANKED"|"FORCE_MOVE"|"HIT"|"IDENTIFY"|"INFECTIOUS_DISEASED"|"INFUSED"|"INSURFACE"|"LEADERSHIP"|"LINGERING_WOUNDS"|"LYING"|"MATERIAL"|"OVERPOWER"|"REMORSE"|"REPAIR"|"ROTATE"|"SHACKLES_OF_PAIN_CASTER"|"SHACKLES_OF_PAIN"|"SITTING"|"SMELLY"|"SNEAKING"|"SOURCE_MUTED"|"SPIRIT_VISION"|"SPIRIT"|"STORY_FROZEN"|"SUMMONING"|"TELEPORT_FALLING"|"TUTORIAL_BED"|"UNHEALABLE"|"UNLOCK"|"UNSHEATHED"|"WIND_WALKER"

---@alias StatStatusType "ACTIVE_DEFENSE"|"BLIND"|"CHALLENGE"|"CHARMED"|"CONSUME"|"DAMAGE_ON_MOVE"|"DAMAGE"|"DEACTIVATED"|"DECAYING_TOUCH"|"DEMONIC_BARGAIN"|"DISARMED"|"EFFECT"|"EXTRA_TURN"|"FEAR"|"FLOATING"|"GUARDIAN_ANGEL"|"HEAL_SHARING_CASTER"|"HEAL_SHARING"|"HEAL"|"HEALING"|"INCAPACITATED"|"INVISIBLE"|"KNOCKED_DOWN"|"MUTED"|"PLAY_DEAD"|"POLYMORPHED"|"SPARK"|"STANCE"|"THROWN"

---@alias RaceTag "DWARF"|"ELF"|"HUMAN"|"LIZARD"
---@alias BaseRace "Dwarf"|"Elf"|"Human"|"Lizard"

---@alias StatCharacter CDivinityStatsCharacter
---@alias StatItem CDivinityStatsItem
---@alias StatItemDynamic CDivinityDynamicStatsEntry
---@alias DamageList StatsDamagePairList
---@alias ObjectHandle ComponentHandle
---@alias HitRequest StatsHitDamageInfo
---@alias HitContext EsvPendingHit

---@alias LeaderLibGetTextPlaceholderCallback fun(param:string, character:StatCharacter):string

---@alias OriginsCampaignRegion "TUT_Tutorial_A"|"FJ_FortJoy_Main"|"LV_HoE_Main"|"RC_Main"|"CoS_Main"|"ARX_Main"|"ARX_Endgame"

---@alias Guid string
---@alias NetId integer

--Legacy support
---@alias GUID string
---@alias NETID integer

---A parameter type that can be either item userdata, or a ID to ultimately retrieve that userdata via GameHelpers.GetItem.
---@see GameHelpers.GetItem
---@alias ItemParam EsvItem|EclItem|Guid|NetId|ComponentHandle

---A parameter type that can be either character userdata, or a ID to ultimately retrieve that userdata via GameHelpers.GetCharacter.
---@see GameHelpers.GetCharacter
---@alias CharacterParam EsvCharacter|EclCharacter|Guid|NetId|ComponentHandle
---@alias ObjectParam EsvCharacter|EclCharacter|EsvItem|EclItem|Guid|NetId|ComponentHandle
---@alias ServerObject EsvCharacter|EsvItem
---@alias ClientObject EclCharacter|EclItem
---@alias CharacterObject EsvCharacter|EclCharacter
---@alias ItemObject EsvItem|EclItem

---@alias ServerCharacterParam EsvCharacter|Guid|NetId|ComponentHandle
---@alias ClientCharacterParam EclCharacter|Guid|NetId|ComponentHandle

---@alias CalculatedDamageRange table<DamageType, {Min:integer, Max:integer}>

---Mainly used to specify a default value in optional parameter tables.
---@class DefaultValue<T>:{}

---@alias CrimeType "ActiveSummon"|"Assault"|"AttackAnimal"|"Diseased"|"EmptyPocketNoticed"|"IncapacitatedAssault"|"ItemDestroy"|"KilledAnimal"|"LoudContinuousNoise"|"MoveForbiddenItem"|"Murder"|"PickPocketFailed"|"Polymorphed"|"Smelly"|"Sneaking"|"SneakKilledAnimal"|"SneakMurder"|"SneakUseForbiddenItem"|"SourceMagic"|"Steal"|"SummonAssault"|"SummonAttackAnimal"|"SummonItemDestroy"|"SummonKilledAnimal"|"SummonMoveForbiddenItem"|"SummonMurder"|"SummonVandalise"|"SummonVandaliseNoOwner"|"TeleportPlayerDialog"|"Trespassing"|"UseForbiddenItem"|"Vandalise"|"VandaliseNoOwner"|"WeaponsDrawn"