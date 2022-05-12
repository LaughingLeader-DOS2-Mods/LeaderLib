if Events == nil then
	Events = {}
end

local isClient = Ext.IsClient()

Ext.Require("Shared/Classes/SubscribableEvent.lua")
Ext.Require("Shared/Classes/SubscribableEventArgs.lua")

---@class EmptyEventArgs:SubscribableEventArgs

---@class CharacterResurrectedEventArgs:SubscribableEventArgs
---@field Character EsvCharacter|EclCharacter

---@type SubscribableEvent<CharacterResurrectedEventArgs>
Events.CharacterResurrected = Classes.SubscribableEvent:Create("CharacterResurrected")

---@class FeatureChangedEventArgs:SubscribableEventArgs
---@field ID string
---@field Enabled boolean

---@type SubscribableEvent<FeatureChangedEventArgs>
Events.FeatureChanged = Classes.SubscribableEvent:Create("FeatureChanged", {ArgsKeyOrder={"ID", "Enabled"}})

---@class InitializedEventArgs:SubscribableEventArgs
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

---@class RegionChangedEventArgs:SubscribableEventArgs
---@field Region string
---@field State REGIONSTATE
---@field LevelType LEVELTYPE

---@type SubscribableEvent<RegionChangedEventArgs>
Events.RegionChanged = Classes.SubscribableEvent:Create("RegionChanged", {ArgsKeyOrder={"Region", "State", "LevelType"}})

---@class SummonChangedEventArgs:SubscribableEventArgs
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