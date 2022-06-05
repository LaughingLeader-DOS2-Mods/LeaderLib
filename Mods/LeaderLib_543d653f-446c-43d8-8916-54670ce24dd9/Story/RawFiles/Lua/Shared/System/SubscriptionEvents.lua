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
---@field IsPlayer boolean

---@type SubscribableEvent<CharacterResurrectedEventArgs>
Events.CharacterResurrected = Classes.SubscribableEvent:Create("CharacterResurrected", {
	SyncInvoke=true,
	ArgsKeyOrder={"Character", "IsPlayer"}
})

---@class CharacterLeveledUpEventArgs
---@field Character EsvCharacter|EclCharacter
---@field Level integer
---@field IsPlayer boolean

---@type SubscribableEvent<CharacterLeveledUpEventArgs>
Events.CharacterLeveledUp = Classes.SubscribableEvent:Create("CharacterLeveledUp", {
	SyncInvoke=true,
	ArgsKeyOrder={"Character", "Level", "IsPlayer"}
})

---@class FeatureChangedEventArgs
---@field ID string
---@field Enabled boolean

---@type SubscribableEvent<FeatureChangedEventArgs>
Events.FeatureChanged = Classes.SubscribableEvent:Create("FeatureChanged", {ArgsKeyOrder={"ID", "Enabled"}})

---@class InitializedEventArgs
---@field Region string

---@type SubscribableEvent<InitializedEventArgs>
Events.Initialized = Classes.SubscribableEvent:Create("Initialized")

---@class LeaderLibLoadedEventArgs:InitializedEventArgs
---Called when LeaderLib finishes loading its server-side or client-side scripts.
---@type SubscribableEvent<LeaderLibLoadedEventArgs>
Events.Loaded = Classes.SubscribableEvent:Create("Loaded")

---@type SubscribableEvent<EmptyEventArgs>
Events.BeforeLuaReset = Classes.SubscribableEvent:Create("BeforeLuaReset", {SyncInvoke=true})

---@class LuaResetEventArgs:InitializedEventArgs
---@type SubscribableEvent<LuaResetEventArgs>
Events.LuaReset = Classes.SubscribableEvent:Create("LuaReset", {SyncInvoke=true})

---@class RegionChangedEventArgs
---@field Region string
---@field State REGIONSTATE
---@field LevelType LEVELTYPE

---@type SubscribableEvent<RegionChangedEventArgs>
Events.RegionChanged = Classes.SubscribableEvent:Create("RegionChanged", {ArgsKeyOrder={"Region", "State", "LevelType"}})

---@class SummonChangedEventArgs
---@field Summon EsvCharacter|EsvItem
---@field Owner EsvCharacter
---@field IsDying boolean
---@field IsItem boolean

---Called when a summon is created or destroyed. Includes items like mines.
---@type SubscribableEvent<SummonChangedEventArgs>
Events.SummonChanged = Classes.SubscribableEvent:Create("SummonChanged", {
	SyncInvoke = true,
	ArgsKeyOrder={"Summon", "Owner", "IsDying", "IsItem"}
})

---@class ObjectTimerData:table
---@field UUID string
---@field Object EsvCharacter|EsvItem|EclCharacter|EclItem|nil

---@class TimerFinishedEventArgs
---@field ID string The timer name.
---@field Data ObjectTimerData|table Optional values passed to the timer when started.

---@see LeaderLibTimerSystem#RegisterListener
---Called when TimerFinished in Osiris occurs, or a tick timer finishes on the client side.
---Specify a MatchArgs table in the subscription options to register a named timer listener.
---@type SubscribableEvent<TimerFinishedEventArgs>
Events.TimerFinished = Classes.SubscribableEvent:Create("TimerFinished", {
	ArgsKeyOrder={"ID", "Data"}
})

---@class ModSettingsSyncedEventArgs
---@field UUID string The Mod UUID
---@field Settings ModSettings

---Called when ModSettings are synced on both the server and client.
---@type SubscribableEvent<ModSettingsSyncedEventArgs>
Events.ModSettingsSynced = Classes.SubscribableEvent:Create("ModSettingsSynced", {
	ArgsKeyOrder={"UUID", "Settings"}
})

---@class TurnDelayedEventArgs
---@field UUID UUID The character UUID.
---@field Character EsvCharacter|EclCharacter

---Called when a character's turn is delayed in combat (clicking the "Shield" icon).
---@type SubscribableEvent<TurnDelayedEventArgs>
Events.TurnDelayed = Classes.SubscribableEvent:Create("TurnDelayed", {
	ArgsKeyOrder={"UUID", "Character"}
})

if not _ISCLIENT then
	---@class TreasureItemGeneratedEventArgs
	---@field Item EsvItem
	---@field StatsId string
	
	---Called when an item is generated from treasure, or console command.  
	---🔨**Server-Only**🔨
	---@type SubscribableEvent<TreasureItemGeneratedEventArgs>
	Events.TreasureItemGenerated = Classes.SubscribableEvent:Create("TreasureItemGenerated", {
		ArgsKeyOrder={"Item", "StatsId"}
	})

	---@class OnPrepareHitEventArgs
	---@field Target EsvCharacter|EsvItem
	---@field Source EsvCharacter|EsvItem|nil
	---@field Damage integer
	---@field Handle integer
	---@field Data HitPrepareData
	
	---Called during NRD_OnPrepareHit, with a data wrapper for easier manipulation. 
	---🔨**Server-Only**🔨
	---@type SubscribableEvent<OnPrepareHitEventArgs>
	Events.OnPrepareHit = Classes.SubscribableEvent:Create("OnPrepareHit", {
		ArgsKeyOrder={"Target", "Source", "Damage", "Handle", "Data"},
		GetArg = function(paramId, param)
			if paramId == "Target" or paramId == "Source" then
				return GameHelpers.GetUUID(param, true)
			end
		end
	})

	---@class OnHitEventArgs
	---@field Target EsvCharacter|EsvItem
	---@field Source EsvCharacter|EsvItem|nil
	---@field Data HitData
	---@field HitStatus EsvStatusHit
	
	---Called during StatusHitEnter, with a data wrapper for easier manipulation.  
	---🔨**Server-Only**🔨
	---@type SubscribableEvent<OnHitEventArgs>
	Events.OnHit = Classes.SubscribableEvent:Create("OnHit", {
		ArgsKeyOrder={"Target", "Source", "Data", "HitStatus"}
	})

	---@class ComputeCharacterHitEventArgs
	---@field AlwaysBackstab boolean
	---@field Attacker StatCharacter
	---@field CriticalRoll CriticalRollFlag
	---@field DamageList DamageList
	---@field ForceReduceDurability boolean
	---@field Handled boolean
	---@field HighGround HighGroundFlag
	---@field Hit HitRequest
	---@field HitType HitTypeValues
	---@field NoHitRoll boolean
	---@field SkillProperties StatProperty[]
	---@field Target StatCharacter
	---@field Weapon StatItem
	
	---Hit listeners/callbacks, for mod compatibility.  
	---Called from HitOverrides.ComputeCharacterHit at the end of the function, if certain features are enabled or listeners are registered.  
	---🔨**Server-Only**🔨
	---@see LeaderLibHitOverrides#ComputeCharacterHit
	---@type SubscribableEvent<ComputeCharacterHitEventArgs>
	Events.ComputeCharacterHit = Classes.SubscribableEvent:Create("ComputeCharacterHit", {
		ArgsKeyOrder={"Target", "Attacker", "Weapon", "DamageList", "HitType", "NoHitRoll", "ForceReduceDurability", "Hit", "AlwaysBackstab", "HighGround", "CriticalRoll"}
	})

	---@class DoHitEventArgs
	---@field Hit HitRequest
	---@field DamageList DamageList
	---@field StatusBonusDamageTypes table
	---@field HitType HitTypeValues
	---@field Target StatCharacter
	---@field Attacker StatCharacter
	
	---Called from HitOverrides.DoHit, which overrides Game.Math.DoHit to wrap listener callbacks. The original Game.Math.DoHit is called for calculation.  
	---🔨**Server-Only**🔨
	---@see LeaderLibHitOverrides#DoHit
	---@type SubscribableEvent<DoHitEventArgs>
	Events.DoHit = Classes.SubscribableEvent:Create("DoHit", {
		ArgsKeyOrder={"Hit", "DamageList", "StatusBonusDamageTypes", "HitType", "Target", "Attacker"}
	})

	---@class ApplyDamageCharacterBonusesEventArgs
	---@field Target StatCharacter
	---@field Attacker StatCharacter
	---@field DamageList DamageList
	---@field PreModifiedDamageList DamageList
	---@field ResistancePenetration table<DAMAGE_TYPE, integer>
	
	---Called from a Game.Math.ApplyDamageCharacterBonuses override. This is where resistance penetration happens.  
	---🔨**Server-Only**🔨
	---@see LeaderLibHitOverrides#ApplyDamageCharacterBonuses
	---@type SubscribableEvent<ApplyDamageCharacterBonusesEventArgs>
	Events.ApplyDamageCharacterBonuses = Classes.SubscribableEvent:Create("ApplyDamageCharacterBonuses", {
		ArgsKeyOrder={"Target", "Attacker", "DamageList", "PreModifiedDamageList", "ResistancePenetration"}
	})

	---@class GetHitResistanceBonusEventArgs
	---@field Target StatCharacter
	---@field DamageType DAMAGE_TYPE
	---@field ResistancePenetration integer
	---@field CurrentResistanceAmount integer
	---@field ResistanceName string
	
	---Called during HitOverrides.ApplyDamageCharacterBonuses, to apply resistances to a hit.  
	---🔨**Server-Only**🔨  
	---@see LeaderLibHitOverrides#GetResistance
	---@type SubscribableEvent<GetHitResistanceBonusEventArgs>
	Events.GetHitResistanceBonus = Classes.SubscribableEvent:Create("GetHitResistanceBonus", {
		ArgsKeyOrder={"Target", "DamageType", "ResistancePenetration", "CurrentResistanceAmount", "ResistanceName"},
		GatherResults = true
	})

	---@class GetCanBackstabEventArgs
	---@field CanBackstab boolean Whether the hit can be a backstab.
	---@field SkipPositionCheck boolean If true, target/attacker positions aren't checked, allowing a hit to backstab outside of melee range, and outside the backstab angle.
	---@field Target StatCharacter
	---@field Attacker StatCharacter
	---@field Weapon StatItem
	---@field DamageList DamageList
	---@field HitType HitTypeValues
	---@field NoHitRoll boolean
	---@field ForceReduceDurability boolean
	---@field Hit HitRequest	
	---@field AlwaysBackstab boolean
	---@field HighGround HighGroundFlag
	---@field CriticalRoll CriticalRollFlag
	
	---Modifies the result of HitOverrides.CanBackstab if true or false is returned.  
	---The second returned boolean is optional, and will make backstabs ignore positioning.  
	---Example: `return true, true` to make the hit a backstab, and ignore 
	---🔨**Server-Only**🔨
	---@see LeaderLibHitOverrides#CanBackstab
	---@type SubscribableEvent<GetCanBackstabEventArgs>
	Events.GetCanBackstab = Classes.SubscribableEvent:Create("GetCanBackstab", {
		ArgsKeyOrder={"CanBackstab", "Target", "Attacker", "Weapon", "DamageList", "HitType", "NoHitRoll", "ForceReduceDurability", "Hit", "AlwaysBackstab", "HighGround", "CriticalRoll"},
		GatherResults = true
	})

	---@class OnHealEventArgs
	---@field Target EsvCharacter
	---@field Source EsvCharacter|EsvItem|nil
	---@field Heal EsvStatusHeal
	---@field OriginalAmount integer
	---@field Handle integer
	---@field Skill string|nil
	---@field HealingSourceStatus EsvStatusHealing|nil
	
	---Called during NRD_OnHeal, with extra data for the optional skill that was used, our source EsvStatusHealing.  
	---🔨**Server-Only**🔨
	---@type SubscribableEvent<OnHealEventArgs>
	Events.OnHeal = Classes.SubscribableEvent:Create("OnHeal", {
		ArgsKeyOrder={"Target", "Source", "Heal", "OriginalAmount", "Handle", "Skill", "HealingSourceStatus"}
	})

	---@class OnTurnCounterEventArgs
	---@field ID string
	---@field Turn integer
	---@field LastTurn integer
	---@field Finished boolean
	---@field Data TurnCounterData

	---Called when a turn counter progresses to the next turn, or is finished.
	---@see LeaderLibTurnCounterSystem#CreateTurnCounter
	---🔨**Server-Only**🔨
	---@type SubscribableEvent<OnTurnCounterEventArgs>
	Events.OnTurnCounter = Classes.SubscribableEvent:Create("OnTurnCounter", {
		ArgsKeyOrder={"ID", "Turn", "LastTurn", "Finished", "Data"}
	})
end