if not Listeners then
	Listeners = {}
end
Listeners.FeatureEnabled = {}
Listeners.FeatureDisabled = {}
Listeners.Initialized = {}
Listeners.ModuleResume = {}
Listeners.SessionLoaded = {}
Listeners.TurnDelayed = {}
Listeners.SyncData = {}
Listeners.ClientDataSynced = {}
Listeners.ClientCharacterChanged = {}
Listeners.GetTooltipSkillDamage = {}
Listeners.GetTooltipSkillParam = {}
--Debug listeners
Listeners.LuaReset = {}
Listeners.BeforeLuaReset = {}

Listeners.ModSettingsLoaded = {}
---Callbacks for when ModSettings are synced on both the server and client.
---@type fun(uuid:string, settings:ModSettings):void[]
Listeners.ModSettingsSynced = {}

---@alias ModSettingsFlagDataChangedListener fun(id:string, enabled:boolean, data:FlagData, settings:SettingsData):void
---@alias ModSettingsVariableDataChangedListener fun(id:string, value:integer, data:VariableData, settings:SettingsData):void

---@type table<string, ModSettingsFlagDataChangedListener|ModSettingsVariableDataChangedListener>
Listeners.ModSettingsChanged = {All = {}}

if Ext.IsServer() then
	Listeners.TimerFinished = {}
	---@type table<string,fun(uuid1:string|nil, uuid2:string|nil):void>
	Listeners.NamedTimerFinished = {}
	---Wrapper around ProcObjectTimerFinished for timers with a specific name, or "any" for all object timers.
	---@type table<string, fun(uuid:string, timerName:string):void>
	Listeners.ProcObjectTimerFinished = {}

	---@type table<integer, fun(item:EsvItem, statsId:string):void>
	Listeners.TreasureItemGenerated = {}

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

	---@alias OnPrepareHitCallback fun(target:string, source:string, damage:integer, handle:integer, data:HitPrepareData):void
	---@alias OnHitCallback fun(target:string, source:string, damage:integer, handle:integer, skill:string|nil):void
	---@alias OnStatusHitEnterCallback fun(target:EsvCharacter|EsvItem, source:EsvCharacter|EsvItem, totalDamage:integer, hit:HitRequest, context:HitContext, hitStatus:EsvStatusHit, skill:StatEntrySkillData|nil):void
	---@alias OnSkillHitCallback fun(skill:string, source:string, state:SKILL_STATE, data:HitData|ProjectileHitData):void

	---@type OnPrepareHitCallback[]
	Listeners.OnPrepareHit = {}
	---@type OnHitCallback[]
	Listeners.OnHit = {}
	---Newer hit listener.
	---@type OnStatusHitEnterCallback[]
	Listeners.StatusHitEnter = {}
	---Fires when a skill hits, or a projectile from a skill hits.
	---@type OnSkillHitCallback[]
	Listeners.OnSkillHit = {}

	---Server-side event for when base ability or attribute values change on players. Can fire from character sheet interaction or after respec.
	---@type table<string, fun(uuid:string, stat:string, lastVal:integer, nextVal:integer, statType:string):void>
	Listeners.CharacterBasePointsChanged = {}

	---@alias TurnCounterCallback fun(id:string, turn:integer, lastTurn:integer, finished:boolean, data:TurnCounterData):void

	---@type TurnCounterCallback[]
	Listeners.OnTurnCounter = {}
	---@type table<string, TurnCounterCallback>
	Listeners.OnNamedTurnCounter = {}
	---@type table<string, fun(summon:EsvCharacter, owner:EsvCharacter, isAlive:boolean)>
	Listeners.OnSummonChanged = {}
	---@type table<string, fun(event:string, vararg string)>
	Listeners.ObjectEvent = {}

	---Called when PersistentVars should be initialized from a table of default values.
	---@type function[]
	Listeners.PersistentVarsLoaded = {}
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
	---@type table<string, InputEventCallback>
	Listeners.NamedInputEvent = {}

	---@alias MouseInputEventCallback fun(event:InputMouseEvent, x:number, y:number):void
	---@type table<string, MouseInputEventCallback>
	Listeners.MouseInputEvent = {}

	---@alias OnTooltipPositionedCallback fun(ui:UIObject, tooltip_mc:FlashObject, isControllerMode:boolean, item:EclItem)
	---Called after showFormattedTooltipAfterPos is invoked.
	Listeners.OnTooltipPositioned = {}

	---@alias OnWorldTooltipCallback fun(ui:UIObject, text:string, x:number, y:number, isFromItem:boolean, item:EclItem):string
	---Called when a world tooltip is created either under the cursor, or when the highlight items key is pressed. The callback should return new tooltip text if the text should be modified, else don't return anything.
	---@type OnWorldTooltipCallback[]
	Listeners.OnWorldTooltip = {}

	---@alias ShouldOpenContextMenuCallback fun(contextMenu:ContextMenu, mouseX:number, mouseY:number):boolean
	---Triggered when right clicking with KB+M.
	---@type ShouldOpenContextMenuCallback[]
	Listeners.ShouldOpenContextMenu = {}
	---@alias OnContextMenuOpeningCallback fun(contextMenu:ContextMenu, mouseX:number, mouseY:number):void
	---Triggered when the custom context menu is opening. For adding entries to it, use contextMenu:AddEntry
	---@see ContextMenu#AddEntry
	---@type OnContextMenuOpeningCallback[]
	Listeners.OnContextMenuOpening = {}
	---@alias OnContextMenuEntryClickedCallback fun(contextMenu:ContextMenu, ui:UIObject, entryID:integer, actionID:string, handle:number):void
	---@type OnContextMenuEntryClickedCallback[]
	Listeners.OnContextMenuEntryClicked = {}

	---@alias UICreatedCallback fun(ui:UIObject, this:FlashMainTimeline, player:EclCharacter):void
	---Called after a UI is created, when the main timeline is hopefully ready.
	---Register to a UIType or "All" for all UIs.
	---@type table<integer,UICreatedCallback>
	Listeners.UICreated = {All = {}}
end