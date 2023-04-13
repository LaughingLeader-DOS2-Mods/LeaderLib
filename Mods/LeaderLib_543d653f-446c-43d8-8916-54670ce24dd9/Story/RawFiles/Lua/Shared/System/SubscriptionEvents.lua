if Events == nil then
	---@class LeaderLibSubscriptionEvents
	Events = {}
end

local _ISCLIENT = Ext.IsClient()

Ext.Require("Shared/Classes/SubscribableEvent.lua")
Ext.Require("Shared/Classes/SubscribableEventArgs.lua")

---@class EmptyEventArgs

---@class CharacterResurrectedEventArgs
---@field Character EsvCharacter|EclCharacter
---@field CharacterGUID Guid
---@field IsPlayer boolean

---Called when a character is resurrected, which is after the RESURRECTED status is removed.  
---🔨🔧**Server/Client**🔧🔨 
---@type LeaderLibSubscribableEvent<CharacterResurrectedEventArgs>
Events.CharacterResurrected = Classes.SubscribableEvent:Create("CharacterResurrected", {
	SyncInvoke=true,
	ArgsKeyOrder={"Character", "IsPlayer"}
})

---@class CharacterLeveledUpEventArgs
---@field Character EsvCharacter|EclCharacter
---@field CharacterGUID Guid
---@field Level integer
---@field IsPlayer boolean

---@type LeaderLibSubscribableEvent<CharacterLeveledUpEventArgs>
Events.CharacterLeveledUp = Classes.SubscribableEvent:Create("CharacterLeveledUp", {
	SyncInvoke=true,
	ArgsKeyOrder={"Character", "Level", "IsPlayer"}
})

---@class OnBookReadEventArgs
---@field Character EsvCharacter|EclCharacter
---@field CharacterGUID Guid
---@field Item EsvItem|EclItem
---@field ItemGUID Guid
---@field Template string The root template GUID
---@field ID string The book ID or recipe ID
---@field BookType "Book"|"Recipe"|"Skillbook"

---Called when a player reads a book, recipe book, or skillbook.  
---@type LeaderLibSubscribableEvent<OnBookReadEventArgs>
Events.OnBookRead = Classes.SubscribableEvent:Create("OnBookRead", {
	SyncInvoke=true,
	ArgsKeyOrder={"Character", "Item", "Template", "ID"}
})

---@class FeatureChangedEventArgs
---@field ID string
---@field Enabled boolean

---@type LeaderLibSubscribableEvent<FeatureChangedEventArgs>
Events.FeatureChanged = Classes.SubscribableEvent:Create("FeatureChanged", {ArgsKeyOrder={"ID", "Enabled"}})

---@class InitializedEventArgs
---@field Region string

---@type LeaderLibSubscribableEvent<InitializedEventArgs>
Events.Initialized = Classes.SubscribableEvent:Create("Initialized")

---@class LeaderLibLoadedEventArgs:InitializedEventArgs
---Called when LeaderLib finishes loading its server-side or client-side scripts.
---@type LeaderLibSubscribableEvent<LeaderLibLoadedEventArgs>
Events.Loaded = Classes.SubscribableEvent:Create("Loaded")

---@type LeaderLibSubscribableEvent<EmptyEventArgs>
Events.BeforeLuaReset = Classes.SubscribableEvent:Create("BeforeLuaReset", {SyncInvoke=true})

---@class LuaResetEventArgs:InitializedEventArgs
---@type LeaderLibSubscribableEvent<LuaResetEventArgs>
Events.LuaReset = Classes.SubscribableEvent:Create("LuaReset", {SyncInvoke=true})

---@class RegionChangedEventArgs
---@field Region string
---@field State REGIONSTATE
---@field LevelType LEVELTYPE
---@field Level EsvLevel|EclLevel
---@field GetAllCharacters (fun(asTable?:boolean):(fun():EsvCharacter|EclCharacter))
---@field GetAllItems (fun(asTable?:boolean):(fun():EsvItem|EclItem))

---Called when the region or state (Started, Game, Ended) changes.  
---🔨🔧**Server/Client**🔧🔨  
---@type LeaderLibSubscribableEvent<RegionChangedEventArgs>
Events.RegionChanged = Classes.SubscribableEvent:Create("RegionChanged", {ArgsKeyOrder={"Region", "State", "LevelType"}})

---@class SummonChangedEventArgs
---@field Summon EsvCharacter|EsvItem|nil
---@field SummonGUID Guid
---@field Owner EsvCharacter|nil
---@field OwnerGUID Guid|nil
---@field IsDying boolean
---@field IsItem boolean

---Called when a summon is created or destroyed. Includes items like mines.  
---🔨🔧**Server/Client**🔧🔨  
---@type LeaderLibSubscribableEvent<SummonChangedEventArgs>
Events.SummonChanged = Classes.SubscribableEvent:Create("SummonChanged", {
	SyncInvoke = true,
	ArgsKeyOrder={"Summon", "Owner", "IsDying", "IsItem"}
})

---@class GameTimeChangedEventArgs
---@field Day integer
---@field Hour integer
---@field TotalHours integer
---@field TimeSpeed integer The timer speed for each in-game hour, in ms. Defaults to 300,000 milliseconds.

---Called when a summon is created or destroyed. Includes items like mines.  
---🔨🔧**Server/Client**🔧🔨  
---@type LeaderLibSubscribableEvent<GameTimeChangedEventArgs>
Events.GameTimeChanged = Classes.SubscribableEvent:Create("GameTimeChanged", {
	SyncInvoke = true,
	ArgsKeyOrder={"Day", "Hour", "TotalHours", "TimeSpeed"}
})

---@class ObjectTimerData:table
---@field UUID string
---@field Object EsvCharacter|EsvItem|EclCharacter|EclItem|nil
---@field Params table<integer,any> An array of assorted parameters, set if a Timer.Start function was used with variable arguments.

---@class TimerFinishedEventArgs
---@field ID string The timer name.
---@field Data ObjectTimerData|table Optional values passed to the timer when started.

---@see LeaderLibTimerSystem#RegisterListener
---Called when TimerFinished in Osiris occurs, or a tick timer finishes on the client side.
---Specify a MatchArgs table in the subscription options to register a named timer listener.  
---🔨🔧**Server/Client**🔧🔨  
---@type LeaderLibSubscribableEvent<TimerFinishedEventArgs>
Events.TimerFinished = Classes.SubscribableEvent:Create("TimerFinished", {
	ArgsKeyOrder={"ID", "Data"}
})

---@class ModSettingsSyncedEventArgs
---@field UUID string The Mod UUID
---@field Settings ModSettings

---Called when ModSettings are synced on both the server and client.  
---🔨🔧**Server/Client**🔧🔨  
---@type LeaderLibSubscribableEvent<ModSettingsSyncedEventArgs>
Events.ModSettingsSynced = Classes.SubscribableEvent:Create("ModSettingsSynced", {
	ArgsKeyOrder={"UUID", "Settings"}
})

---@class GameSettingsChangedEventArgs
---@field Settings LeaderLibGameSettings
---@field FromSync boolean True if settings were loaded from a sync carried out by the server.

---Called when GameSettings changes are applied in the options menu.  
---🔨🔧**Server/Client**🔧🔨  
---@type LeaderLibSubscribableEvent<GameSettingsChangedEventArgs>
Events.GameSettingsChanged = Classes.SubscribableEvent:Create("GameSettingsChanged")

---@class TurnDelayedEventArgs
---@field Character EsvCharacter|EclCharacter
---@field CharacterGUID Guid The character MyGuid, for easier matching.

---Called when a character's turn is delayed in combat (clicking the "Shield" icon).  
---🔨🔧**Server/Client**🔧🔨  
---@type LeaderLibSubscribableEvent<TurnDelayedEventArgs>
Events.TurnDelayed = Classes.SubscribableEvent:Create("TurnDelayed", {
	ArgsKeyOrder={"UUID", "Character"}
})

---@class GetTooltipSkillDamageEventArgs
---@field Skill string
---@field SkillData StatEntrySkillData
---@field Character StatCharacter
---@field Result string The text to replace the placeholder with.

---Called from GameHelpers.Tooltip.ReplacePlaceholders when [SkillDamage:SkillId] text exists in the string.  
---Set e.Result to specify the text replacement.  
---🔨🔧**Server/Client**🔧🔨  
---@type LeaderLibSubscribableEvent<GetTooltipSkillDamageEventArgs>
Events.GetTooltipSkillDamage = Classes.SubscribableEvent:Create("GetTooltipSkillDamage", {
	ArgsKeyOrder={"SkillData", "Character"},
	GatherResults = true
})

---@class GetTooltipSkillParamEventArgs
---@field Skill string
---@field SkillData StatEntrySkillData
---@field Character StatCharacter
---@field Param string
---@field Result string The text to replace the placeholder with.

---Called from GameHelpers.Tooltip.ReplacePlaceholders when [Skill:SkillId:Param] text exists in the string.  
---Set e.Result to specify the text replacement.  
---🔨🔧**Server/Client**🔧🔨  
---@type LeaderLibSubscribableEvent<GetTooltipSkillParamEventArgs>
Events.GetTooltipSkillParam = Classes.SubscribableEvent:Create("GetTooltipSkillParam", {
	ArgsKeyOrder={"SkillData", "Character", "Param"},
	GatherResults = true
})

---@class GetTextPlaceholderEventArgs
---@field ID string
---@field Character StatCharacter
---@field Char EclCharacter Character is a StatCharacter due to backwards-compatibility, but while exists to easily provide the EclCharacter.
---@field ExtraParams string[]
---@field Result string The text to replace the placeholder with.

---Called from GameHelpers.Tooltip.ReplacePlaceholders when [Special:ID] text exists in the string.  
---Set e.Result to specify the text replacement.  
---🔨🔧**Server/Client**🔧🔨  
---@type LeaderLibSubscribableEvent<GetTextPlaceholderEventArgs>
Events.GetTextPlaceholder = Classes.SubscribableEvent:Create("GetTextPlaceholder", {
	ArgsKeyOrder={"ID", "Character", "ExtraParams"},
	GatherResults = true
})

---@class GlobalSettingsLoadedEventArgs
---@field Settings GlobalSettings
---@field FromSync boolean True if settings were loaded from a sync carried out by the server.

---Called when all global settings are loaded.  
---🔨🔧**Server/Client**🔧🔨  
---@type LeaderLibSubscribableEvent<GlobalSettingsLoadedEventArgs>
Events.GlobalSettingsLoaded = Classes.SubscribableEvent:Create("GlobalSettingsLoaded", {
	ArgsKeyOrder={"Settings"}
})

---@class ModSettingsLoadedEventArgs
---@field UUID string The mod UUID
---@field Settings ModSettings

---Called when an individual mod's global settings are loaded.  
---🔨🔧**Server/Client**🔧🔨  
---@type LeaderLibSubscribableEvent<ModSettingsLoadedEventArgs>
Events.ModSettingsLoaded = Classes.SubscribableEvent:Create("ModSettingsLoaded", {
	ArgsKeyOrder={"Settings", "UUID"}
})

---@class BaseModSettingsChangedEventArgs
---@field ModuleUUID Guid The UUID of the mod that owns these settings.
---@field ID string
---@field Settings SettingsData

---@class ModSettingsFlagChangedEventArgs:BaseModSettingsChangedEventArgs
---@field Data FlagData
---@field Value boolean

---@class ModSettingsVariableChangedEventArgs:BaseModSettingsChangedEventArgs
---@field Data VariableData
---@field Value integer

---@alias ModSettingsChangedEventArgs ModSettingsFlagChangedEventArgs|ModSettingsVariableChangedEventArgs

---Called when an entry's value in ModSettings changes.  
---🔨🔧**Server/Client**🔧🔨  
---@type LeaderLibSubscribableEvent<ModSettingsChangedEventArgs>
Events.ModSettingsChanged = Classes.SubscribableEvent:Create("ModSettingsChanged", {
	ArgsKeyOrder={"ID", "Value", "Data", "Settings"}
})

---@class OnSkillStateBaseEventArgs
---@field Character EsvCharacter
---@field CharacterGUID Guid
---@field State SKILL_STATE
---@field Skill string
---@field Ability SkillAbility
---@field SkillType SkillType
---@field DataType LeaderLibSkillListenerDataType

---@class OnSkillStateBaseActionEventArgs:OnSkillStateBaseEventArgs
---@field SourceItem EsvItem|nil

---@class OnSkillStatePrepareEventArgs:OnSkillStateBaseActionEventArgs
---@field Data StatEntrySkillData

---@class OnSkillStateCancelEventArgs:OnSkillStateBaseActionEventArgs
---@field Data StatEntrySkillData

---@class OnSkillStateSkillEventEventArgs:OnSkillStateBaseActionEventArgs
---@field Data SkillEventData

---@class OnSkillStateHitEventArgs:OnSkillStateBaseActionEventArgs
---@field Data HitData

---@class OnSkillStateBeforeProjectileShootEventArgs:OnSkillStateBaseActionEventArgs
---@field Data EsvShootProjectileHelper

---@class OnSkillStateProjectileShootEventArgs:OnSkillStateBaseActionEventArgs
---@field Data EsvProjectile

---@class OnSkillStateProjectileHitEventArgs:OnSkillStateBaseActionEventArgs
---@field Data ProjectileHitData

---@class OnSkillStateLearnedEventArgs:OnSkillStateBaseActionEventArgs
---@field Data boolean Whether the skill is learned or not.
---@field Memorized boolean

---@class OnSkillStateMemorizedEventArgs:OnSkillStateBaseActionEventArgs
---@field Data boolean Whether the skill is memorized or not.
---@field Learned boolean

---@class OnSkillStateGetAPCostEventArgs:OnSkillStateBaseEventArgs
---@field Data LuaGetSkillAPCostEvent The event data from `Ext.Events.GetSkillAPCost`.
---@field Character EsvCharacter|EclCharacter

---@class OnSkillStateGetDamageAmountEventArgs:OnSkillStateBaseEventArgs
---@field Data LuaGetSkillDamageEvent The event data from `Ext.Events.GetSkillDamage`.
---@field Character EsvCharacter|EclCharacter The `e.Data.Attacker.Character`, if it's a character.
---@field IsTooltip boolean
---@field Result StatsDamagePairList The damage list to set on `e.Data.DamageList`.

---@class OnSkillStateGetDamageTextEventArgs:OnSkillStateBaseEventArgs
---@field Data EclLuaSkillGetDescriptionParamEvent The event data from `Ext.Events.SkillGetDescriptionParam`.
---@field Character EsvCharacter|EclCharacter
---@field Result CalculatedDamageRange The damage range to turn into text. You can set e.Data.Description directly to skip this.

---@alias OnSkillStateGetDamageEventArgs OnSkillStateGetDamageAmountEventArgs|OnSkillStateGetDamageTextEventArgs

---@alias OnSkillStateAllEventArgs OnSkillStateBeforeProjectileShootEventArgs|OnSkillStateCancelEventArgs|OnSkillStateGetAPCostEventArgs|OnSkillStateGetDamageEventArgs|OnSkillStateHitEventArgs|OnSkillStateLearnedEventArgs|OnSkillStateMemorizedEventArgs|OnSkillStatePrepareEventArgs|OnSkillStateProjectileHitEventArgs|OnSkillStateProjectileShootEventArgs|OnSkillStateSkillEventEventArgs

---Server-side event for when a skill state event occurs.  
---Use SkillManager.Register to register different skill listeners.  
---**Note: Only the GETAPCOST state is client-side.**  
---🔨🔧**Server/Client**🔧🔨  
---@see LeaderLibSkillManagerRegistration#All
---@type LeaderLibSubscribableEvent<OnSkillStateAllEventArgs>
Events.OnSkillState = Classes.SubscribableEvent:Create("OnSkillState", {
	ArgsKeyOrder={"Skill", "CharacterGUID", "State", "Data", "DataType"},
	OnSubscribe = function (callback, opts, matchArgs, matchArgsType)
		if matchArgsType == "nil" or (matchArgsType == "table" and matchArgs.Skill == nil) then
			SkillManager.EnableForAllSkills(true)
		end
	end,
	OnUnsubscribe = function (callback, opts, matchArgs, matchArgsType)
		if matchArgsType == "nil" or (matchArgsType == "table" and matchArgs.Skill == nil) then
			SkillManager.EnableForAllSkills(false)
		elseif (matchArgsType == "table" and matchArgs.Skill ~= nil) then
			local st = type(matchArgs.Skill)
			if st == "table" then
				for _,v in pairs(matchArgs.Skill) do
					SkillManager.SetSkillEnabled(v, false)
				end
			elseif st == "string" then
				SkillManager.SetSkillEnabled(matchArgs.Skill, false)
			end
		end
	end
})

if not _ISCLIENT then
	---@class GlobalFlagChangedEventArgs
	---@field ID string The _FlagName value.
	---@field Enabled boolean
	
	---Called when a global flag is set/unset.  
	---🔨**Server-Only**🔨  
	---@type LeaderLibSubscribableEvent<GlobalFlagChangedEventArgs>
	Events.GlobalFlagChanged = Classes.SubscribableEvent:Create("GlobalFlagChanged", {
		ArgsKeyOrder={"ID", "Enabled"}
	})

	---@class TreasureItemGeneratedEventArgs
	---@field Item EsvItem
	---@field ResultingItem EsvItem If set, this item will replace Item as the generated item.
	---@field StatsId string
	---@field IsClone boolean True if the item was generated via GameHelpers.Item.Clone.
	---@field OriginalItem EsvItem|nil If IsClone is true, this is the item the clone was created from.
	
	---Called when an item is generated from treasure (the extender "TreasureItemGenerated" event), GameHelpers.Item helpers, or by console command.  
	---🔨**Server-Only**🔨  
	---@see GameHelpers.Item#Clone
	---@type LeaderLibSubscribableEvent<TreasureItemGeneratedEventArgs>
	Events.TreasureItemGenerated = Classes.SubscribableEvent:Create("TreasureItemGenerated", {
		ArgsKeyOrder={"Item", "StatsId", "IsClone", "OriginalItem", "ResultingItem"},
		GatherResults = true
	})

	---@class OnPrepareHitEventArgs
	---@field Target EsvCharacter|EsvItem
	---@field TargetGUID Guid
	---@field Source EsvCharacter|EsvItem|nil
	---@field SourceGUID Guid|NULL_UUID
	---@field Damage integer The initial damage amount, before any modifications. Check `e.Data.TotalDamageDone` for an updated damage value.
	---@field Handle integer
	---@field Data HitPrepareData
	
	---Called during NRD_OnPrepareHit, with a data wrapper for easier manipulation. 
	---🔨**Server-Only**🔨
	---@type LeaderLibSubscribableEvent<OnPrepareHitEventArgs>
	Events.OnPrepareHit = Classes.SubscribableEvent:Create("OnPrepareHit", {
		ArgsKeyOrder={"TargetGUID", "SourceGUID", "Damage", "Handle", "Data"}
	})

	---@class OnHitEventArgs
	---@field Target EsvCharacter|EsvItem
	---@field Source EsvCharacter|EsvItem|nil
	---@field TargetGUID string
	---@field SourceGUID string|NULL_UUID
	---@field Data HitData
	---@field HitStatus EsvStatusHit
	---@field HitContext EsvPendingHit
	
	---Called during `Ext.Events.StatusHitEnter`, before SkillManager and OnWeaponHit events fire, and before `Events.OnHit` is called.  
	---🔨**Server-Only**🔨
	---@type LeaderLibSubscribableEvent<OnHitEventArgs>
	Events.BeforeOnHit = Classes.SubscribableEvent:Create("OnHit", {
		ArgsKeyOrder={"Target", "Source", "Data", "HitStatus"}
	})
	
	---Called during `Ext.Events.StatusHitEnter`, with a hit data wrapper for easier manipulation. This event is called after SkillManager and OnWeaponHit related events.  
	---🔨**Server-Only**🔨
	---@type LeaderLibSubscribableEvent<OnHitEventArgs>
	Events.OnHit = Classes.SubscribableEvent:Create("OnHit", {
		ArgsKeyOrder={"Target", "Source", "Data", "HitStatus"}
	})

	---@class OnBasicAttackStartEventArgs
	---@field Attacker EsvCharacter
	---@field AttackerGUID Guid
	---@field Target EsvCharacter|EsvItem|number[]
	---@field TargetGUID Guid|nil
	---@field TargetIsObject boolean
	
	---Called via AttackManager, when a character starts a basic attack.  
	---🔨**Server-Only**🔨
	---@see LeaderLibAttackManager
	---@type LeaderLibSubscribableEvent<OnBasicAttackStartEventArgs>
	Events.OnBasicAttackStart = Classes.SubscribableEvent:Create("OnBasicAttackStart", {
		ArgsKeyOrder={"Attacker", "Target", "Data"}
	})

	---@alias BasicAttackPositionDamageData {Type:string, DamageList:DamageList}

	---@class OnWeaponHitEventArgs
	---@field Target EsvCharacter|EsvItem|number[]
	---@field TargetGUID Guid
	---@field Attacker EsvCharacter|EsvItem|nil
	---@field AttackerGUID Guid
	---@field Data HitData|BasicAttackPositionDamageData
	---@field TargetIsObject boolean
	---@field Skill string|nil Separate from SkillData, so it can be used more easily with MatchArgs.
	---@field SkillData StatEntrySkillData|nil
	
	---Called via AttackManager, when an object or position is hit with a basic attack or weapon skill.
	---🔨**Server-Only**🔨
	---@see LeaderLibAttackManager
	---@type LeaderLibSubscribableEvent<OnWeaponHitEventArgs>
	Events.OnWeaponHit = Classes.SubscribableEvent:Create("OnWeaponHit", {
		ArgsKeyOrder={"Attacker", "Target", "Data", "TargetIsObject", "SkillData"}
	})

	---@alias WeaponTypeAlias "Staff"|"Rifle"|"Spear"|"Sentinel"|"Sword"|"Bow"|"Axe"|"Wand"|"Arrow"|"None"|"Knife"|"Crossbow"|"Club"

	---@class OnWeaponTypeHitEventArgs:OnWeaponHitEventArgs
	---@field WeaponType WeaponTypeAlias
	
	---Called via AttackManager, when an object or position is hit with a basic attack or weapon skill.
	---🔨**Server-Only**🔨
	---@see LeaderLibAttackManager
	---@type LeaderLibSubscribableEvent<OnWeaponTypeHitEventArgs>
	Events.OnWeaponTypeHit = Classes.SubscribableEvent:Create("OnWeaponTypeHit", {
		ArgsKeyOrder={"WeaponType", "Attacker", "Target", "Data", "TargetIsObject", "Skill"}
	})

	---@class OnWeaponTagHitEventArgs:OnWeaponHitEventArgs
	---@field Tag string
	
	---Called via AttackManager, when an object or position is hit with a basic attack or weapon skill.
	---🔨**Server-Only**🔨
	---@see LeaderLibAttackManager
	---@type LeaderLibSubscribableEvent<OnWeaponTagHitEventArgs>
	Events.OnWeaponTagHit = Classes.SubscribableEvent:Create("OnWeaponTagHit", {
		ArgsKeyOrder={"Tag", "Attacker", "Target", "Data", "TargetIsObject", "Skill"},
		OnSubscribe = function (callback, opts, matchArgs, matchArgsType)
			if matchArgsType == "table" and type(opts.MatchArgs.Tag) == "string" then
				AttackManager.EnabledTags[opts.MatchArgs.Tag] = true
			end
		end
	})

	---@class ComputeCharacterHitEventArgs
	---@field AlwaysBackstab boolean
	---@field Attacker StatCharacter
	---@field CriticalRoll CriticalRoll
	---@field DamageList DamageList
	---@field ForceReduceDurability boolean
	---@field Handled boolean
	---@field HighGround HighGroundBonus
	---@field Hit StatsHitDamageInfo
	---@field HitType HitTypeValues
	---@field NoHitRoll boolean
	---@field SkillProperties AnyStatProperty[]
	---@field Target StatCharacter
	---@field Weapon CDivinityStatsItem
	
	---Hit listeners/callbacks, for mod compatibility.  
	---Called from HitOverrides.ComputeCharacterHit at the end of the function, if certain features are enabled or listeners are registered.  
	---🔨**Server-Only**🔨
	---@see LeaderLibHitOverrides#ComputeCharacterHit
	---@type LeaderLibSubscribableEvent<ComputeCharacterHitEventArgs>
	Events.ComputeCharacterHit = Classes.SubscribableEvent:Create("ComputeCharacterHit", {
		ArgsKeyOrder={"Target", "Attacker", "Weapon", "DamageList", "HitType", "NoHitRoll", "ForceReduceDurability", "Hit", "AlwaysBackstab", "HighGround", "CriticalRoll"}
	})

	---@class DoHitEventArgs
	---@field Hit StatsHitDamageInfo
	---@field DamageList DamageList
	---@field StatusBonusDamageTypes table
	---@field HitType HitTypeValues
	---@field Target StatCharacter
	---@field Attacker StatCharacter
	
	---Called from HitOverrides.DoHit, which overrides Game.Math.DoHit to wrap listener callbacks. The original Game.Math.DoHit is called for calculation.  
	---🔨**Server-Only**🔨
	---@see LeaderLibHitOverrides#DoHit
	---@type LeaderLibSubscribableEvent<DoHitEventArgs>
	Events.DoHit = Classes.SubscribableEvent:Create("DoHit", {
		ArgsKeyOrder={"Hit", "DamageList", "StatusBonusDamageTypes", "HitType", "Target", "Attacker"}
	})

	---@class ApplyDamageCharacterBonusesEventArgs
	---@field Target StatCharacter
	---@field Attacker StatCharacter
	---@field DamageList DamageList
	---@field PreModifiedDamageList DamageList
	---@field ResistancePenetration table<DamageType, integer>
	
	---Called from a Game.Math.ApplyDamageCharacterBonuses override. This is where resistance penetration happens.  
	---🔨**Server-Only**🔨
	---@see LeaderLibHitOverrides#ApplyDamageCharacterBonuses
	---@type LeaderLibSubscribableEvent<ApplyDamageCharacterBonusesEventArgs>
	Events.ApplyDamageCharacterBonuses = Classes.SubscribableEvent:Create("ApplyDamageCharacterBonuses", {
		ArgsKeyOrder={"Target", "Attacker", "DamageList", "PreModifiedDamageList", "ResistancePenetration"}
	})

	---@class GetHitResistanceBonusEventArgs
	---@field Target StatCharacter
	---@field DamageType DamageType
	---@field ResistancePenetration integer The retrieved res pen from whatever tags were found on the target. This value is applied to CurrentResistanceAmount before the event runs.
	---@field OriginalResistanceAmount integer The target's original resistance, before res pen was applied.
	---@field CurrentResistanceAmount integer The resistance value the hit calculation will use. Modify this to change the resulting resistance amount applied to damage.
	---@field ResistanceName FixedString The resistance ID.
	
	---Called during HitOverrides.ApplyDamageCharacterBonuses, to apply resistances to a hit.  
	---🔨**Server-Only**🔨  
	---@see LeaderLibHitOverrides#GetResistance
	---@type LeaderLibSubscribableEvent<GetHitResistanceBonusEventArgs>
	Events.GetHitResistanceBonus = Classes.SubscribableEvent:Create("GetHitResistanceBonus", {
		ArgsKeyOrder={"Target", "DamageType", "ResistancePenetration", "CurrentResistanceAmount", "ResistanceName"},
		GatherResults = true
	})

	---@class GetCanBackstabEventArgs
	---@field CanBackstab boolean Whether the hit can be a backstab.
	---@field SkipPositionCheck boolean If true, target/attacker positions aren't checked, allowing a hit to backstab outside of melee range, and outside the backstab angle.
	---@field Target StatCharacter
	---@field Attacker StatCharacter
	---@field Weapon CDivinityStatsItem
	---@field DamageList DamageList
	---@field HitType HitTypeValues
	---@field NoHitRoll boolean
	---@field ForceReduceDurability boolean
	---@field Hit StatsHitDamageInfo	
	---@field AlwaysBackstab boolean
	---@field HighGround HighGroundBonus
	---@field CriticalRoll CriticalRoll
	
	---Modify the result of HitOverrides.CanBackstab by setting e.CanBackstab and/or e.SkipPositionCheck  
	---| Parameter | Description |
	---| ----------- | ----------- |
	---| CanBackstab | Allow the hit to backstab if the attacker is in a correct position, relative to the target. |
	---| SkipPositionCheck | Skip positional checks for distance/angle, allowing the hit to backstab regardless. |  
	---🔨**Server-Only**🔨
	---@see LeaderLibHitOverrides#CanBackstab
	---@type LeaderLibSubscribableEvent<GetCanBackstabEventArgs>
	Events.GetCanBackstab = Classes.SubscribableEvent:Create("GetCanBackstab", {
		ArgsKeyOrder={"CanBackstab", "Target", "Attacker", "Weapon", "DamageList", "HitType", "NoHitRoll", "ForceReduceDurability", "Hit", "AlwaysBackstab", "HighGround", "CriticalRoll"},
		GatherResults = true
	})

	---@class OnHealEventArgs
	---@field Target EsvCharacter
	---@field TargetGUID Guid
	---@field Source EsvCharacter|EsvItem|nil
	---@field SourceGUID Guid|nil
	---@field Status EsvStatusHeal|EsvStatusHealing
	---@field StatusId string
	---@field StatusType "HEAL"|"HEALING"
	---@field HealStat StatusHealType The Status.HealType for EsvStatusHeal, or Status.HealStat for EsvStatusHealing.
	---@field HealEffect HealEffect
	---@field OriginalAmount integer The HealAmount before listeners were invoked.
	---@field Skill string|nil The skill possibility associated with this HEAL/HEALING status combination, if Source is set. This is the last healing skill the character casted, if it matches with the HEALING type status it thinks is associated with this HEAL.
	---@field EnterEvent EsvLuaStatusGetEnterChanceEvent|LuaEventBase The event data from Ext.Events.StatusGetEnterChance.
	
	---Called during `Ext.Events.StatusGetEnterChance` for `HEAL` and `HEALING` status types. Altering the HealAmount here ensures the changes work on the client-side correctly.   
	---🔨**Server-Only**🔨
	---@type LeaderLibSubscribableEvent<OnHealEventArgs>
	Events.OnHeal = Classes.SubscribableEvent:Create("OnHeal")

	---@class OnTurnCounterEventArgs
	---@field ID string
	---@field Turn integer
	---@field LastTurn integer
	---@field Finished boolean
	---@field Data TurnCounterData

	---Called when a turn counter progresses to the next turn, or is finished.  
	---Preferrably use TurnCounter.Subscribe to subscribe to specific turn counters.  
	---🔨**Server-Only**🔨  
	---@see LeaderLibTurnCounterSystem#Subscribe
	---@see LeaderLibTurnCounterSystem#CreateTurnCounter
	---@type LeaderLibSubscribableEvent<OnTurnCounterEventArgs>
	Events.OnTurnCounter = Classes.SubscribableEvent:Create("OnTurnCounter", {
		ArgsKeyOrder={"ID", "Turn", "LastTurn", "Finished", "Data"}
	})

	---@class OnTurnEndedEventArgs
	---@field ID string A turn counter ID tracking this character, if any.
	---@field Object EsvCharacter Could technically be an item, but this is EsvCharacter since it's likely a character in most cases.
	---@field ObjectGUID Guid
	
	---Called when an object's turn ends in combat, or they leave combat.  
	---If a TurnCounter is associated with this object, that ID is specified.  
	---🔨**Server-Only**🔨  
	---@type LeaderLibSubscribableEvent<OnTurnEndedEventArgs>
	Events.OnTurnEnded = Classes.SubscribableEvent:Create("OnTurnEnded", {
		ArgsKeyOrder={"Object", "ID"}
	})

	---@class ForceMoveFinishedEventArgs
	---@field ID string A way to identify this action, if any.
	---@field Target EsvCharacter
	---@field TargetGUID Guid
	---@field Source EsvCharacter|EsvItem|nil
	---@field SourceGUID Guid|nil
	---@field Distance number
	---@field StartingPosition number[]
	---@field SkillData StatEntrySkillData|nil
	---@field Skill string|nil
	
	---Called when a GameHelpers.ForceMoveObject action ends.  
	---🔨**Server-Only**🔨  
	---@see LeaderLibGameHelpers#ForceMoveObject
	---@type LeaderLibSubscribableEvent<ForceMoveFinishedEventArgs>
	Events.ForceMoveFinished = Classes.SubscribableEvent:Create("ForceMoveFinished", {
		ArgsKeyOrder={"Target", "Source", "Distance", "StartingPosition", "SkillData"}
	})

	---@class PersistentVarsLoadedEventArgs
	
	---Called when PersistentVars should be initialized from a table of default values.  
	---This can be considered deprecated if `GameHelpers.PersistentVars.Initialize` is used, as that will register a PersistentVarsLoaded listener that calls the provided initialize callback function.  
	---🔨**Server-Only**🔨  
	---@see LeaderLibGameHelpers.PersistentVars#Initialize
	---@see LeaderLibGameHelpers.PersistentVars#Update
	---@type LeaderLibSubscribableEvent<PersistentVarsLoadedEventArgs>
	Events.PersistentVarsLoaded = Classes.SubscribableEvent:Create("PersistentVarsLoaded")

	---@alias ObjectEventEventType string|"StoryEvent"|"CharacterCharacterEvent"|"CharacterItemEvent"

	---@class ObjectEventEventArgs
	---@field Event string
	---@field EventType ObjectEventEventType
	---@field Objects ServerObject[]
	---@field ObjectGUID1 Guid
	---@field ObjectGUID2 Guid|nil
	
	---Called when a StoryEvent, CharacterItemEvent, or CharacterCharacterEvent occurs.  
	---🔨**Server-Only**🔨  
	---@type LeaderLibSubscribableEvent<ObjectEventEventArgs>
	Events.ObjectEvent = Classes.SubscribableEvent:Create("ObjectEvent", {
		ArgsKeyOrder={"EventType", "Event", "Objects"}
	})

	---@class CharacterBasePointsChangedEventArgs
	---@field Character EsvCharacter
	---@field CharacterGUID Guid 
	---@field Stat string
	---@field StatType string
	---@field Last integer
	---@field Current integer
	
	---Server-side event for when base ability or attribute values change on players. Can fire from character sheet interaction or after respec.  
	---🔨**Server-Only**🔨  
	---@type LeaderLibSubscribableEvent<CharacterBasePointsChangedEventArgs>
	Events.CharacterBasePointsChanged = Classes.SubscribableEvent:Create("CharacterBasePointsChanged", {
		ArgsKeyOrder={"CharacterGUID", "Stat", "Last", "Current", "StatType"}
	})

	---@class OnStatusBaseEventArgs
	---@field Target EsvCharacter|EsvItem
	---@field Source EsvCharacter|EsvItem|nil
	---@field TargetGUID string|
	---@field SourceGUID string
	---@field StatusId string
	---@field StatusType StatStatusType
	---@field StatusEvent StatusEventID
	---@field IsDisabling boolean Whether GameHelpers.Status.IsDisablingStatus is true.
	---@field IsLoseControl boolean Whether LoseControl from GameHelpers.Status.IsDisablingStatus is true.

	---@class OnStatusBeforeAttemptEventArgs:OnStatusBaseEventArgs
	---@field Status EsvStatus
	---@field PreventApply boolean If true, the status attempt is prevented.

	---@class OnStatusAttemptEventArgs:OnStatusBaseEventArgs
	---@field Status EsvStatus|string The status from object.StatusMachine.Statuses, or the statusID if that failed.

	---@class OnStatusAppliedEventArgs:OnStatusBaseEventArgs
	---@field Status EsvStatus

	---@class OnStatusGetEnterChanceEventArgs:OnStatusBaseEventArgs
	---@field Status EsvStatus
	---@field EnterChance int32|nil Nil if IsEnterCheck is false.
	---@field IsEnterCheck boolean
	---@field Event EsvLuaStatusGetEnterChanceEvent
	
	---@class OnStatusRemovedEventArgs:OnStatusBaseEventArgs
	---@field Status string
	
	---@class OnStatusBeforeDeleteEventArgs:OnStatusBaseEventArgs
	---@field Status EsvStatus
	---@field PreventDelete boolean If true, the status deletion is prevented.

	---@alias OnStatusEventArgs OnStatusBeforeAttemptEventArgs|OnStatusAttemptEventArgs|OnStatusAppliedEventArgs|OnStatusRemovedEventArgs|OnStatusGetEnterChanceEventArgs
	
	---Server-side event for when a status event occurs.  
	---Use StatusManager.Register to register different status listeners.  
	---🔨**Server-Only**🔨  
	---@see LeaderLibSkillManagerRegistration#All
	---@type LeaderLibSubscribableEvent<OnStatusEventArgs>
	Events.OnStatus = Classes.SubscribableEvent:Create("OnStatusEvent", {
		Benchmark = false,
		ArgsKeyOrder={"TargetGUID", "Status", "SourceGUID", "StatusType", "StatusEvent"},
		---@param param EsvStatus
		GetArg = function(self, paramId, param)
			if paramId == "Target" or paramId == "Source" then
				return GameHelpers.GetUUID(param, true)
			elseif paramId == "Status" then
				if type(param) == "string" then
					return param
				end
				if self.Args.StatusEvent == "BeforeAttempt" then
					return param
				else
					return param.StatusId
				end
			end
		end,
		OnSubscribe = function (callback, opts, matchArgs, matchArgsType)
			if matchArgsType == "table" and type(opts.MatchArgs.StatusId) == "string" then
				local status = opts.MatchArgs.StatusId
				if Vars.DebugMode and not Data.EngineStatus[status] and not GameHelpers.Stats.Exists(status, "StatusData") then
					fprint(LOGLEVEL.ERROR, string.format("Status (%s) does not exist", status), 2)
				end
				local statusEvent = opts.MatchArgs.StatusEvent
				local statusEventType = type(statusEvent)
				if statusEventType == "string" then
					if StatusManager._Internal.EnabledStatuses[statusEvent] then
						StatusManager._Internal.EnabledStatuses[statusEvent][status] = true
					end
				elseif statusEventType == "table" then
					for k,v in pairs(statusEvent) do
						if StatusManager._Internal.EnabledStatuses[v] then
							StatusManager._Internal.EnabledStatuses[v][status] = true
						end
					end
				else
					StatusManager._Internal.EnabledStatuses.All[status] = true
				end
				if Data.IgnoredStatus[status] == true then
					Vars.RegisteredIgnoredStatus[status] = true
				end
			end
		end,
		OnUnsubscribe = function (callback, opts, matchArgs, matchArgsType)
			--Cleanup StatusManager._Internal.EnabledStatuses table if nothing else is subscribed
			if matchArgsType == "table" and type(opts.MatchArgs.Status) == "string" then
				local checkStatus = opts.MatchArgs.Status
				local checkEvent = opts.MatchArgs.StatusEvent
				if checkStatus then
					local cur = Events.OnStatus.First
					if cur then
						while cur ~= nil do
							if cur.Options and cur.MatchArgs then
								if cur.MatchArgs.Status == checkStatus or cur.MatchArgs.StatusType == checkStatus then
									checkStatus = nil
								end
								if cur.MatchArgs.StatusEvent == checkEvent then
									checkEvent = nil
								end
							end
							--Matches found
							if not checkStatus and not checkEvent then
								break
							end
							cur = cur.Next
						end
					end
					if checkStatus then
						StatusManager._Internal.EnabledStatuses.All[checkStatus] = nil
						if checkEvent then
							StatusManager._Internal.EnabledStatuses[checkEvent][checkStatus] = nil
						end
					end
				end
			end
		end
	})

	---@class SyncDataEventArgs
	---@field UserID integer
	---@field Profile string
	---@field UUID Guid
	---@field IsHost boolean
	
	---Called via SharedData, when it syncs data for a specific user.
	---🔨**Server-Only**🔨
	---@see LeaderLibAttackManager
	---@type LeaderLibSubscribableEvent<SyncDataEventArgs>
	Events.SyncData = Classes.SubscribableEvent:Create("SyncData", {
		ArgsKeyOrder={"UserID", "Profile", "UUID", "IsHost"}
	})

	---@alias CharacterDiedEventStateID string
	---|"StatusBeforeAttempt" # [0] - NRD_OnStatusAttempt/Ext.Events.BeforeStatusApply with the DYING status
	---|"StatusAttempt" # [1] - CharacterStatusAttempt/ItemStatusAttempt with the DYING status
	---|"BeforeDying" # [2] - CharacterPrecogDying
	---|"Dying" # [3] - CharacterDying
	---|"StatusApplied" # [4] - CharacterStatusApplied/ItemStatusChange with the DYING status
	---|"Died" # [5] - CharacterDied

	---@class CharacterDiedEventArgs
	---@field Character EsvCharacter
	---@field CharacterGUID Guid
	---@field State CharacterDiedEventStateID
	---@field StateIndex integer
	---@field IsPlayer boolean

	---Called when a character is dying, in several states of the event chain.  
	---🔨**Server-Only**🔨 
	---@type LeaderLibSubscribableEvent<CharacterDiedEventArgs>
	Events.CharacterDied = Classes.SubscribableEvent:Create("CharacterDied", {
		ArgsKeyOrder={"Character", "IsPlayer", "State", "StateIndex"}
	})

	---@class CharacterUsedItemEventArgs
	---@field Character EsvCharacter
	---@field CharacterGUID Guid
	---@field Item EsvItem
	---@field ItemGUID Guid
	---@field Template Guid
	---@field Success boolean Can be false if this is raised by a CharacterUsedItemFailed event.

	---Called when a character uses an item.  
	---🔨**Server-Only**🔨 
	---@type LeaderLibSubscribableEvent<CharacterUsedItemEventArgs>
	Events.CharacterUsedItem = Classes.SubscribableEvent:Create("CharacterUsedItem")

	---@class RuneChangedEventArgs
	---@field Item EsvItem
	---@field ItemGUID Guid
	---@field Character EsvCharacter
	---@field CharacterGUID Guid
	---@field RuneSlot integer
	---@field Inserted boolean
	---@field Rune EsvItem|nil Only set if the rune was removed, otherwise the rune object does not exist.
	---@field RuneTemplate Guid The rune object stat root template.
	---@field BoostStat StatEntryWeapon|StatEntryArmor The active rune boost stat for this item
    ---@field BoostStatID string The active rune boost stat name for this item
    ---@field BoostStatAttribute "RuneEffectWeapon"|"RuneEffectAmulet"|"RuneEffectUpperbody"
	
	---Called when a rune is inserted or removed from an item.  
	---🔨**Server-Only**🔨  
	---@type LeaderLibSubscribableEvent<RuneChangedEventArgs>
	Events.RuneChanged = Classes.SubscribableEvent:Create("RuneChanged")

	---@alias RebuildVisualsEventCause "Loaded"|"Transformed"|"Unsheathed"|"Sheathed"
	---@alias RebuildVisualsEventCauseIndex integer
	---|0 # "Loaded"
	---|2 # "Transformed"
	---|3 # "Unsheathed"
	---|4 # "Sheathed"

	---@class RebuildVisualsEventArgs
	---@field Character EsvCharacter
	---@field CharacterGUID Guid
	---@field CharacterVisual FixedString The character's model visual resource GUID.
	---@field Cause RebuildVisualsEventCause
	---@field CauseIndex RebuildVisualsEventCauseIndex
	---@field Race string|BaseRace|"None"
	---@field Gender "Male"|"Female"|"None"
	
	---Called when a character should have visuals rebuilt (polymorphed/transformed, game started, specific statuses like UNSHEATHED).  
	---🔨**Server-Only**🔨  
	---@type LeaderLibSubscribableEvent<RebuildVisualsEventArgs>
	Events.RebuildVisuals = Classes.SubscribableEvent:Create("RebuildVisuals")
else
	---@class ClientDataSyncedEventArgs
	---@field Data SharedData
	---@field ModData table
	
	---Called when SharedData is synced on the client.  
	---ModData is the SharedData.ModData table, which mods can add to to simplify data that needs to be synced to clients.  
	---🔧**Client-Only**🔧  
	---@see LeaderLibAttackManager
	---@type LeaderLibSubscribableEvent<ClientDataSyncedEventArgs>
	Events.ClientDataSynced = Classes.SubscribableEvent:Create("ClientDataSynced", {
		ArgsKeyOrder={"ModData", "Data"}
	})

	---@class ClientCharacterChangedEventArgs
	---@field Character EclCharacter
	---@field CharacterGUID Guid
	---@field CharacterData ClientCharacterData
	---@field UserID integer
	---@field Profile string
	---@field NetID integer
	---@field IsHost boolean
	
	---Called when the active character changes on the client-side.  
	---🔧**Client-Only**🔧  
	---@see LeaderLibAttackManager
	---@type LeaderLibSubscribableEvent<ClientCharacterChangedEventArgs>
	Events.ClientCharacterChanged = Classes.SubscribableEvent:Create("ClientCharacterChanged", {
		ArgsKeyOrder={"CharacterGUID", "UserID", "Profile", "NetID", "IsHost"}
	})

	---@class CharacterSheetPointChangedEventArgs
	---@field Character EclCharacter
	---@field CharacterGUID Guid
	---@field Stat string
	---@field StatType string
	
	---Called when character sheet buttons are clicked.   
	---🔧**Client-Only**🔧  
	---@see LeaderLibAttackManager
	---@type LeaderLibSubscribableEvent<CharacterSheetPointChangedEventArgs>
	Events.CharacterSheetPointChanged = Classes.SubscribableEvent:Create("CharacterSheetPointChanged", {
		ArgsKeyOrder={"Character", "Stat", "StatType"}
	})

	---@class UICreatedEventArgs
	---@field UI UIObject
	---@field TypeId integer
	---@field Name string
	---@field Path string
	---@field Root FlashMainTimeline
	---@field Player EclCharacter
	
	---Called after a UI is created, when the main timeline is hopefully ready.  
	---🔧**Client-Only**🔧
	---@type LeaderLibSubscribableEvent<UICreatedEventArgs>
	Events.UICreated = Classes.SubscribableEvent:Create("UICreated", {
		ArgsKeyOrder={"UI", "Root", "Player", "TypeId", "Name", "Path"}
	})

	---@class OnWorldTooltipEventArgs
	---@field UI UIObject
	---@field Text string
	---@field X number
	---@field Y number
	---@field IsFromItem boolean
	---@field Item EclItem
	
	---Called when a world tooltip is created either under the cursor, or when the highlight items key is pressed.  
	---Setting the Text property will update the tooltip.  
	---🔧**Client-Only**🔧
	---@type LeaderLibSubscribableEvent<OnWorldTooltipEventArgs>
	Events.OnWorldTooltip = Classes.SubscribableEvent:Create("OnWorldTooltip", {
		ArgsKeyOrder={"UI", "Text", "X", "Y", "IsFromItem", "Item"}
	})

	---@class ShouldOpenContextMenuEventArgs
	---@field ContextMenu ContextMenu
	---@field X number The cursor's x position.
	---@field Y number The cursor's y position.
	---@field ShouldOpen boolean Whether the context menu should open. Set to true.
	
	---Called when right clicking with KB+M.  
	---This event is used to determine if the LeaderLib context menu should be opened, allowing context menus for anything in the UI.  
	---🔧**Client-Only**🔧
	---@type LeaderLibSubscribableEvent<ShouldOpenContextMenuEventArgs>
	Events.ShouldOpenContextMenu = Classes.SubscribableEvent:Create("ShouldOpenContextMenu", {
		ArgsKeyOrder={"ContextMenu", "X", "Y"},
		GatherResults = true,
	})

	---@class OnContextMenuOpeningEventArgs
	---@field ContextMenu ContextMenu
	---@field X number The cursor's x position.
	---@field Y number The cursor's y position.
	
	---Called the LeaderLib regular context menu is opening.  
	---Add entries via e.ContextMenu:AddEntry  
	---🔧**Client-Only**🔧
	---@see ContextMenu#AddEntry
	---@type LeaderLibSubscribableEvent<OnContextMenuOpeningEventArgs>
	Events.OnContextMenuOpening = Classes.SubscribableEvent:Create("OnContextMenuOpening", {
		ArgsKeyOrder={"ContextMenu", "X", "Y"},
	})

	---@class OnBuiltinContextMenuOpeningEventArgs
	---@field ContextMenu ContextMenu
	---@field Entries ContextMenuBuiltinOpeningArrayEntry[] A table of each entry in the buttonArr, allowing you to change specific properties easier (i.e. Entries[1].Label = "Test"). Note that adding entries to this table won't add them to buttonArr - Use e.ContextMenu:AddBuiltinEntry instead.
	---@field Target EclCharacter|EclItem|nil If the "openContextMenu" ExternalInterface.call was invoked, this is the object passed into the call, if any. May be nil. Use Ext.GetPickingState to get whatever is under the cursor.
	---@field UI UIObject The ui for the context menu (contextMenu.swf).
	---@field Root FlashMainTimeline Equivalent to ui:GetRoot()
	---@field ButtonArray FlashArray<FlashMovieClip> The raw root.buttonArr flash array.
	---@field X number The cursor's x position.
	---@field Y number The cursor's y position.
	
	---Called when the regular context menu is opening.  
	---Add entries via e.ContextMenu:AddBuiltinEntry  
	---🔧**Client-Only**🔧
	---@see ContextMenu#AddBuiltinEntry
	---@see Ext#GetPickingState
	---@type LeaderLibSubscribableEvent<OnBuiltinContextMenuOpeningEventArgs>
	Events.OnBuiltinContextMenuOpening = Classes.SubscribableEvent:Create("OnBuiltinContextMenuOpening", {
		ArgsKeyOrder={"ContextMenu", "UI", "Root", "ButtonArray", "Entries", "Target"}
	})

	---@class OnContextMenuEntryClickedEventArgs
	---@field ID integer The generated ID, or assigned ID if this is a built-in entry.
	---@field ActionID string The ID of the action, used to associate entries with readable callbacks (like "LLCM_CopyInfo1")
	---@field Handle integer|string|boolean|nil Whatever handle value was passed to the context menu UI when the entry was created, if any. May be nil.
	---@field ContextMenu ContextMenu
	---@field UI UIObject The ui for the context menu (contextMenu.swf).
	
	---Called when a context menu entry is clicked.  
	---🔧**Client-Only**🔧
	---@type LeaderLibSubscribableEvent<OnContextMenuEntryClickedEventArgs>
	Events.OnContextMenuEntryClicked = Classes.SubscribableEvent:Create("OnContextMenuEntryClicked", {
		ArgsKeyOrder={"ContextMenu", "UI", "ID", "ActionID", "Handle"}
	})

	---@class LeaderLibRawInputEventArgs
	---@field Device "Key"|"Mouse"|"C"|"Touchbar"|"Unknown"
	---@field ID InputRawType
	---@field Pressed boolean
	---@field EventData InjectInputData
	---@field Handled boolean If true, the input event is blocked.

	---Called when an extender RawInput event occurs.  
	---🔧**Client-Only**🔧
	---@type LeaderLibSubscribableEvent<LeaderLibRawInputEventArgs>
	Events.RawInput = Classes.SubscribableEvent:Create("RawInput")
end

---@class TemporaryCharacterRemovedEventArgs
---@field CharacterGUID Guid
---@field NetID NetId|nil May be nil if the character was already destroyed.

---Called GameHelpers.Character.RemoveTemporaryCharacter is called.  
---This event is synced to the client-side, so mods can perform cleanup operations on the CharacterGUID/NetID.  
---🔨🔧**Server/Client**🔧🔨 
---@type LeaderLibSubscribableEvent<TemporaryCharacterRemovedEventArgs>
Events.TemporaryCharacterRemoved = Classes.SubscribableEvent:Create("TemporaryCharacterRemoved", {SyncInvoke=true})