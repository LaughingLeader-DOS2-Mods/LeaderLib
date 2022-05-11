if Events == nil then
	Events = {}
end

local isClient = Ext.IsClient()

Ext.Require("Shared/Classes/SubscribableEvent.lua")

---@alias Event<T>{ Subscribe:fun(self:SubscribableEvent, callback:fun(e:T), opts:SubscribableEventCreateOptions|nil):void }

---@class CharacterResurrectedEventArgs:SubscribableEventArgs
---@field Character EsvCharacter|EclCharacter

---@type SubscribableEvent<CharacterResurrectedEventArgs>
Events.CharacterResurrected = Classes.SubscribableEvent:Create("CharacterResurrected")

---@class FeatureChangedEventArgs:SubscribableEventArgs
---@field ID string
---@field Enabled boolean

---@type SubscribableEvent<FeatureChangedEventArgs>
Events.FeatureChanged = Classes.SubscribableEvent:Create("FeatureChanged")

---@class InitializedEventArgs:SubscribableEventArgs
---@field Region string

---@type SubscribableEvent<InitializedEventArgs>
Events.Initialized = Classes.SubscribableEvent:Create("Initialized")

---@class RegionChangedEventArgs:SubscribableEventArgs
---@field Region string
---@field State REGIONSTATE
---@field LevelType LEVELTYPE

---@type SubscribableEvent<RegionChangedEventArgs>
Events.RegionChanged = Classes.SubscribableEvent:Create("RegionChanged")

if not isClient then
	---@class SummonChangedEventArgs:SubscribableEventArgs
	---@field Summon EsvCharacter|EsvItem
	---@field Owner EsvCharacter
	---@field IsDying boolean
	---@field isItem boolean

	---Called when a summon is created or destroyed. Includes items like mines.
	---@type SubscribableEvent<SummonChangedEventArgs>
	Events.SummonChanged = Classes.SubscribableEvent:Create("SummonChanged")

end

