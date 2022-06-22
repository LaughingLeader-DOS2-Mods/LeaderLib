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
---@field Params table<integer,any> An array of assorted parameters, set if a Timer.Start function was used with variable arguments.

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

---@class GlobalFlagChangedEventArgs
---@field ID string The _FlagName value.
---@field Enabled boolean

---Called when a global flag is set/unset.
---@type SubscribableEvent<GlobalFlagChangedEventArgs>
Events.GlobalFlagChanged = Classes.SubscribableEvent:Create("GlobalFlagChanged", {
	ArgsKeyOrder={"ID", "Enabled"}
})

if not _ISCLIENT then
	---@class TreasureItemGeneratedEventArgs
	---@field Item EsvItem
	---@field StatsId string
	---@field IsClone boolean True if the item was generated via GameHelpers.Item.Clone.
	---@field OriginalItem EsvItem|nil If IsClone is true, this is the item the clone was created from.
	
	---Called when an item is generated from treasure (the extender "TreasureItemGenerated" event), GameHelpers.Item helpers, or by console command.  
	---🔨**Server-Only**🔨  
	---@see GameHelpers.Item#Clone
	---@type SubscribableEvent<TreasureItemGeneratedEventArgs>
	Events.TreasureItemGenerated = Classes.SubscribableEvent:Create("TreasureItemGenerated", {
		ArgsKeyOrder={"Item", "StatsId", "IsClone", "OriginalItem"}
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
	---@field ResistancePenetration table<DamageType, integer>
	
	---Called from a Game.Math.ApplyDamageCharacterBonuses override. This is where resistance penetration happens.  
	---🔨**Server-Only**🔨
	---@see LeaderLibHitOverrides#ApplyDamageCharacterBonuses
	---@type SubscribableEvent<ApplyDamageCharacterBonusesEventArgs>
	Events.ApplyDamageCharacterBonuses = Classes.SubscribableEvent:Create("ApplyDamageCharacterBonuses", {
		ArgsKeyOrder={"Target", "Attacker", "DamageList", "PreModifiedDamageList", "ResistancePenetration"}
	})

	---@class GetHitResistanceBonusEventArgs
	---@field Target StatCharacter
	---@field DamageType DamageType
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
	
	---Modify the result of HitOverrides.CanBackstab by setting e.CanBackstab and/or e.SkipPositionCheck  
	---| Parameter | Description |
	---| ----------- | ----------- |
	---| CanBackstab | Allow the hit to backstab if the attacker is in a correct position, relative to the target. |
	---| SkipPositionCheck | Skip positional checks for distance/angle, allowing the hit to backstab regardless. |  
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
	---Preferrably use TurnCounter.Subscribe to subscribe to specific turn counters.  
	---🔨**Server-Only**🔨  
	---@see LeaderLibTurnCounterSystem#Subscribe
	---@see LeaderLibTurnCounterSystem#CreateTurnCounter
	---@type SubscribableEvent<OnTurnCounterEventArgs>
	Events.OnTurnCounter = Classes.SubscribableEvent:Create("OnTurnCounter", {
		ArgsKeyOrder={"ID", "Turn", "LastTurn", "Finished", "Data"}
	})

	---@class OnTurnEndedEventArgs
	---@field ID string A turn counter ID tracking this character, if any.
	---@field Object ObjectParam
	
	---Called when an object's turn ends in combat, or they leave combat.  
	---If a TurnCounter is associated with this object, that ID is specified.  
	---🔨**Server-Only**🔨  
	---@type SubscribableEvent<OnTurnEndedEventArgs>
	Events.OnTurnEnded = Classes.SubscribableEvent:Create("OnTurnEnded", {
		ArgsKeyOrder={"Object", "ID"}
	})

	---@class ForceMoveFinishedEventArgs
	---@field ID string A way to identify this action, if any.
	---@field Target EsvCharacter
	---@field Source EsvCharacter|EsvItem|nil
	---@field Distance number
	---@field StartingPosition number[]
	---@field Skill StatEntrySkillData|nil
	
	---Called when a GameHelpers.ForceMoveObject action ends.  
	---🔨**Server-Only**🔨  
	---@see LeaderLibGameHelpers#ForceMoveObject
	---@type SubscribableEvent<ForceMoveFinishedEventArgs>
	Events.ForceMoveFinished = Classes.SubscribableEvent:Create("ForceMoveFinished", {
		ArgsKeyOrder={"Target", "Source", "Distance", "StartingPosition", "Skill"}
	})

	---@class PersistentVarsLoadedEventArgs
	
	---Called when PersistentVars should be initialized from a table of default values.  
	---This can be considered deprecated if `GameHelpers.PersistentVars.Initialize` is used, as that will register a PersistentVarsLoaded listener that calls the provided initialize callback function.  
	---🔨**Server-Only**🔨  
	---@see LeaderLibGameHelpers.PersistentVars#Initialize
	---@see LeaderLibGameHelpers.PersistentVars#Update
	---@type SubscribableEvent<PersistentVarsLoadedEventArgs>
	Events.PersistentVarsLoaded = Classes.SubscribableEvent:Create("PersistentVarsLoaded")

	---@alias ObjectEventEventType string|"StoryEvent"|"CharacterCharacterEvent"|"CharacterItemEvent"

	---@class ObjectEventEventArgs
	---@field Event string
	---@field EventType ObjectEventEventType
	---@field Objects ObjectParam[]
	
	---Called when a StoryEvent, CharacterItemEvent, or CharacterCharacterEvent occurs.  
	---🔨**Server-Only**🔨  
	---@type SubscribableEvent<ObjectEventEventArgs>
	Events.ObjectEvent = Classes.SubscribableEvent:Create("ObjectEvent", {
		ArgsKeyOrder={"EventType", "Event", "Objects"}
	})

	---@class CharacterBasePointsChangedEventArgs
	---@field Character EsvCharacter
	---@field Stat string
	---@field StatType string
	---@field Last integer
	---@field Current integer
	
	---Server-side event for when base ability or attribute values change on players. Can fire from character sheet interaction or after respec.  
	---🔨**Server-Only**🔨  
	---@type SubscribableEvent<CharacterBasePointsChangedEventArgs>
	Events.CharacterBasePointsChanged = Classes.SubscribableEvent:Create("CharacterBasePointsChanged", {
		ArgsKeyOrder={"Character", "Stat", "Last", "Current", "StatType"},
		GetArg = function(paramId, param)
			if paramId == "Character" then
				return GameHelpers.GetUUID(param, true)
			end
		end
	})

	---@class OnSkillStateBaseEventArgs
	---@field Character EsvCharacter
	---@field State SKILL_STATE
	---@field Skill string
	---@field DataType LeaderLibSkillListenerDataType
	---@field SourceItem EsvItem|nil

	---@class OnSkillStateAllEventArgs:OnSkillStateBaseEventArgs
	---@field Data SkillEventData|HitData|ProjectileHitData|StatEntrySkillData|boolean

	---@class OnSkillStatePrepareEventArgs:OnSkillStateBaseEventArgs
	---@field Data StatEntrySkillData

	---@class OnSkillStateCancelEventArgs:OnSkillStateBaseEventArgs
	---@field Data StatEntrySkillData

	---@class OnSkillStateSkillEventEventArgs:OnSkillStateBaseEventArgs
	---@field Data SkillEventData

	---@class OnSkillStateHitEventArgs:OnSkillStateBaseEventArgs
	---@field Data HitData

	---@class OnSkillStateBeforeProjectileShootEventArgs:OnSkillStateBaseEventArgs
	---@field Data EsvShootProjectileRequest

	---@class OnSkillStateProjectileShootEventArgs:OnSkillStateBaseEventArgs
	---@field Data EsvProjectile

	---@class OnSkillStateProjectileHitEventArgs:OnSkillStateBaseEventArgs
	---@field Data ProjectileHitData

	---@class OnSkillStateLearnedEventArgs:OnSkillStateBaseEventArgs
	---@field Data boolean

	---@class OnSkillStateMemorizedEventArgs:OnSkillStateBaseEventArgs
	---@field Data boolean
	
	---Server-side event for when a skill state event occurs.  
	---Use SkillManager.Register to register different skill listeners.  
	---🔨**Server-Only**🔨  
	---@see LeaderLibSkillManagerRegistration#All
	---@type SubscribableEvent<OnSkillStateAllEventArgs>
	Events.OnSkillState = Classes.SubscribableEvent:Create("OnSkillState", {
		ArgsKeyOrder={"Skill", "Character", "State", "Data", "DataType"},
		GetArg = function(paramId, param)
			if paramId == "Character" then
				return GameHelpers.GetUUID(param, true)
			end
		end
	})
else
	---@class UICreatedEventArgs
	---@field UI UIObject
	---@field TypeId integer
	---@field Name string
	---@field Path string
	---@field Root FlashMainTimeline
	---@field Player EclCharacter
	
	---Called after a UI is created, when the main timeline is hopefully ready.  
	---🔧**Client-Only**🔧
	---@type SubscribableEvent<UICreatedEventArgs>
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
	---@type SubscribableEvent<OnWorldTooltipEventArgs>
	Events.OnWorldTooltip = Classes.SubscribableEvent:Create("OnWorldTooltip", {
		ArgsKeyOrder={"UI", "Text", "X", "Y", "IsFromItem", "Item"}
	})

	---@class ShouldOpenContextMenuEventArgs
	---@field ContextMenu ContextMenu
	---@field x number The cursor's x position.
	---@field Y number The cursor's y position.
	---@field ShouldOpen boolean Whether the context menu should open. Set to true.
	
	---Called when right clicking with KB+M.  
	---This event is used to determine if the LeaderLib context menu should be opened, allowing context menus for anything in the UI.  
	---🔧**Client-Only**🔧
	---@type SubscribableEvent<ShouldOpenContextMenuEventArgs>
	Events.ShouldOpenContextMenu = Classes.SubscribableEvent:Create("ShouldOpenContextMenu", {
		ArgsKeyOrder={"ContextMenu", "X", "Y"},
		GatherResults = true,
	})

	---@class OnContextMenuOpeningEventArgs
	---@field ContextMenu ContextMenu
	---@field x number The cursor's x position.
	---@field Y number The cursor's y position.
	
	---Called the LeaderLib regular context menu is opening.  
	---Add entries via e.ContextMenu:AddEntry  
	---🔧**Client-Only**🔧
	---@see ContextMenu#AddEntry
	---@type SubscribableEvent<OnContextMenuOpeningEventArgs>
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
	
	---Called when the regular context menu is opening.  
	---Add entries via e.ContextMenu:AddBuiltinEntry  
	---🔧**Client-Only**🔧
	---@see ContextMenu#AddBuiltinEntry
	---@see Ext#GetPickingState
	---@type SubscribableEvent<OnBuiltinContextMenuOpeningEventArgs>
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
	---@type SubscribableEvent<OnContextMenuEntryClickedEventArgs>
	Events.OnContextMenuEntryClicked = Classes.SubscribableEvent:Create("OnContextMenuEntryClicked", {
		ArgsKeyOrder={"ContextMenu", "UI", "ID", "ActionID", "Handle"}
	})
end