if not Listeners then
	Listeners = {}
end
Listeners.FeatureEnabled = {}
Listeners.FeatureDisabled = {}
Listeners.Initialized = {}
Listeners.ModuleResume = {}
Listeners.SessionLoaded = {}
Listeners.ModSettingsLoaded = {}
Listeners.TurnDelayed = {}
Listeners.SyncData = {}
Listeners.ClientDataSynced = {}
Listeners.ClientCharacterChanged = {}
Listeners.GetTooltipSkillDamage = {}
Listeners.GetTooltipSkillParam = {}
Listeners.LuaReset = {}
---Callbacks for when ModSettings are synced on both the server and client.
---@type fun(uuid:string, settings:ModSettings):void[]
Listeners.ModSettingsSynced = {}

if Ext.IsServer() then
	Listeners.TimerFinished = {}
	---@type table<string,fun(uuid1:string|nil, uuid2:string|nil):void>
	Listeners.NamedTimerFinished = {}

	---Hit listeners/callbacks, for mod compatibility.
	---Called from HitOverrides.ComputeCharacterHit at the end of the function, if certain features are enabled or listeners are registered.
	---@type ExtComputeCharacterHitCallback[]
	Listeners.ComputeCharacterHit = {}
	---Called from HitOverrides.DoHit, which overrides Game.Math.DoHit to wrap listener callbacks. The original Game.Math.DoHit is called for calculation.
	---If the original function was overwritten by a mod, this should still work.
	---@type DoHitCallback[]
	Listeners.DoHit = {}
	---Called from a Game.Math.ApplyDamageCharacterBonuses override. This is where resistance penetration happens. 
	---@type ApplyDamageCharacterBonusesCallback[]
	Listeners.ApplyDamageCharacterBonuses = {}
	---HitOverrides.GetResistance during ComputeCharacterHit.
	---@type fun(character:StatCharacter, damageType:string, resistancePenetration:integer, currentRes:integer):integer[]
	Listeners.GetHitResistanceBonus = {}
	--Flag events
	---@type table<string, fun(flag:string, enabled:boolean):void[]>
	Listeners.GlobalFlagChanged = {}

	---@alias OnPrepareHitCallback fun(target:string, source:string, damage:integer, handle:integer):void
	---@alias OnHitCallback fun(target:string, source:string, damage:integer, handle:integer, skill:string|nil):void
	---@alias OnSkillHitCallback fun(skill:string, source:string, state:SKILL_STATE, data:HitData|ProjectileHitData):void

	---@type OnPrepareHitCallback[]
	Listeners.OnPrepareHit = {}
	---@type OnHitCallback[]
	Listeners.OnHit = {}
	---Fires when a skill hits, or a projectile from a skill hits.
	---@type OnSkillHitCallback[]
	Listeners.OnSkillHit = {}

	--Debug listeners
	Listeners.BeforeLuaReset = {}

	---Server-side event for when base ability or attribute values change on players. Can fire from character sheet interaction or after respec.
	---@type table<string, fun(uuid:string, stat:string, lastVal:integer, nextVal:integer, statType:string):void>
	Listeners.CharacterBasePointsChanged = {}
end
if Ext.IsClient() then
	-- Client-side Mod Menu events
	---Callbacks for when a mod's Mod Menu section is created in the options menu.
	---@type fun(uuid:string, settings:ModSettings, ui:UIObject, mainMenu:MainMenuMC):void[]
	Listeners.ModMenuSectionCreated = {}
	---Client-side event for when sheet buttons are clicked.
	---@type table<string, fun(character:EclCharacter, stat:string, statType:string):void>
	Listeners.CharacterSheetPointChanged = {}
	---@type fun(ui:UIObject, player:EclCharacter, startIndex:integer, talentEnumReference:table<string,integer>):void[]
	Listeners.OnTalentArrayUpdating = {}

	---@alias InputEventCallback fun(eventName:string, pressed:boolean, id:integer, inputMap:table<int,boolean>, controllerEnabled:boolean):void
	---@type InputEventCallback[]
	Listeners.InputEvent = {}
end