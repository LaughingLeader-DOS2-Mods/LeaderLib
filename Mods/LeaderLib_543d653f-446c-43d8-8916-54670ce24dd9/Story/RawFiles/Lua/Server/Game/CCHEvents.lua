if Events.CCH == nil then
	Events.CCH = {}
end

local function _OnCCHListenerSubscribed(callback, opts)
	HitOverrides.ListenersRegistered = HitOverrides.ListenersRegistered + 1
end

local function _OnCCHListenerUnsubscribed(ecallback, opts)
	HitOverrides.ListenersRegistered = HitOverrides.ListenersRegistered - 1
	if HitOverrides.ListenersRegistered < 0 then
		HitOverrides.ListenersRegistered = 0
	end
end

local _OPTS = {
	OnSubscribe = _OnCCHListenerSubscribed,
	OnUnsubscribe = _OnCCHListenerUnsubscribed
}

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
Events.CCH.ComputeCharacterHit = Classes.SubscribableEvent:Create("ComputeCharacterHit", {
	ArgsKeyOrder={"Target", "Attacker", "Weapon", "DamageList", "HitType", "NoHitRoll", "ForceReduceDurability", "Hit", "AlwaysBackstab", "HighGround", "CriticalRoll"},
	OnSubscribe = _OnCCHListenerSubscribed,
	OnUnsubscribe = _OnCCHListenerUnsubscribed
})

---@deprecated
---@see Events.CCH.ComputeCharacterHit
Events.ComputeCharacterHit = Events.CCH.ComputeCharacterHit

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
Events.CCH.DoHit = Classes.SubscribableEvent:Create("DoHit", {
	ArgsKeyOrder={"Hit", "DamageList", "StatusBonusDamageTypes", "HitType", "Target", "Attacker"},
	OnSubscribe = _OnCCHListenerSubscribed,
	OnUnsubscribe = _OnCCHListenerUnsubscribed
})

---@deprecated
---@see Events.CCH.DoHit
Events.DoHit = Events.CCH.DoHit

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
Events.CCH.ApplyDamageCharacterBonuses = Classes.SubscribableEvent:Create("ApplyDamageCharacterBonuses", {
	ArgsKeyOrder={"Target", "Attacker", "DamageList", "PreModifiedDamageList", "ResistancePenetration"},
	OnSubscribe = _OnCCHListenerSubscribed,
	OnUnsubscribe = _OnCCHListenerUnsubscribed
})

---@deprecated
---@see Events.CCH.ApplyDamageCharacterBonuses
Events.ApplyDamageCharacterBonuses = Events.CCH.ApplyDamageCharacterBonuses

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
Events.CCH.GetHitResistanceBonus = Classes.SubscribableEvent:Create("GetHitResistanceBonus", {
	ArgsKeyOrder={"Target", "DamageType", "ResistancePenetration", "CurrentResistanceAmount", "ResistanceName"},
	GatherResults = true,
	OnSubscribe = _OnCCHListenerSubscribed,
	OnUnsubscribe = _OnCCHListenerUnsubscribed
})

---@deprecated
---@see Events.CCH.GetHitResistanceBonus
Events.GetHitResistanceBonus = Events.CCH.GetHitResistanceBonus

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
Events.CCH.GetCanBackstab = Classes.SubscribableEvent:Create("GetCanBackstab", {
	ArgsKeyOrder={"CanBackstab", "Target", "Attacker", "Weapon", "DamageList", "HitType", "NoHitRoll", "ForceReduceDurability", "Hit", "AlwaysBackstab", "HighGround", "CriticalRoll"},
	GatherResults = true,
	OnSubscribe = _OnCCHListenerSubscribed,
	OnUnsubscribe = _OnCCHListenerUnsubscribed
})

---@deprecated
---@see Events.CCH.GetCanBackstab
Events.GetCanBackstab = Events.CCH.GetCanBackstab

---@class LeaderLibGetShouldApplyCriticalHitEventArgs
---@field Hit HitRequest
---@field Attacker StatCharacter
---@field HitType HitType
---@field CriticalRoll CriticalRoll
---@field IsCriticalHit boolean

---Modify the result of `HitOverrides.ShouldApplyCriticalHit` by setting `e.IsCriticalHit`. 
---This allows you to make a hit critical, regardless of talents/hit type/etc.  
---🔨**Server-Only**🔨
---@see LeaderLibHitOverrides#CanBackstab
---@type LeaderLibSubscribableEvent<LeaderLibGetShouldApplyCriticalHitEventArgs>
Events.CCH.GetShouldApplyCriticalHit = Classes.SubscribableEvent:Create("CCH.GetShouldApplyCriticalHit", _OPTS)

---@class LeaderLibGetCriticalHitMultiplierEventArgs
---@field Attacker StatCharacter
---@field Weapon StatItem
---@field CriticalMultiplier number

---Modify the result of `HitOverrides.GetCriticalHitMultiplier` by setting `e.CriticalMultiplier`. 
---🔨**Server-Only**🔨
---@see LeaderLibHitOverrides#CanBackstab
---@type LeaderLibSubscribableEvent<LeaderLibGetCriticalHitMultiplierEventArgs>
Events.CCH.GetCriticalHitMultiplier = Classes.SubscribableEvent:Create("CCH.GetCriticalHitMultiplier", _OPTS)