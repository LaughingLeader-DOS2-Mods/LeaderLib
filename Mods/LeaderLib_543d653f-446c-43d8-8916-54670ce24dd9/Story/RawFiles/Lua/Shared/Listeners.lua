---@alias LeaderLibGlobalListenerEvent string|'"FeatureEnabled"' | '"FeatureDisabled"' | '"Initialized"' | '"ModuleResume"' | '"SessionLoaded"' | '"TurnDelayed"' | '"SyncData"' | '"ClientDataSynced"' | '"ClientCharacterChanged"' | '"GetTooltipSkillDamage"' | '"GetTooltipSkillParam"' | '"LuaReset"' | '"BeforeLuaReset"' | '"Loaded"' | '"ModSettingsLoaded"' | '"ModSettingsSynced"' | '"ModSettingsChanged"'

---@alias LeaderLibServerListenerEvent string|'"ApplyDamageCharacterBonuses"' | '"CharacterBasePointsChanged"' | '"ComputeCharacterHit"' | '"DoHit"' | '"GetHitResistanceBonus"' | '"GlobalFlagChanged"' | '"NamedTimerFinished"' | '"ObjectEvent"' | '"OnHit"' | '"OnNamedTurnCounter"' | '"OnPrepareHit"' | '"OnSkillHit"' | '"OnSummonChanged"' | '"OnTurnCounter"' | '"PersistentVarsLoaded"' | '"ProcObjectTimerFinished"' | '"StatusHitEnter"' | '"TimerFinished"' | '"TreasureItemGenerated"'

---@alias LeaderLibClientListenerEvent string|'"CharacterSheetPointChanged"' | '"ControllerModeEnabled"' | '"InputEvent"' | '"ModMenuSectionCreated"' | '"MouseInputEvent"' | '"NamedInputEvent"' | '"OnContextMenuEntryClicked"' | '"OnContextMenuOpening"' | '"OnTalentArrayUpdating"' | '"OnTooltipPositioned"' | '"OnWorldTooltip"' | '"ShouldOpenContextMenu"' | '"UICreated"'

if not Listeners then
	---@private
	---@class LeaderLibListeners:table
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

---@alias LeaderLibGetTooltipSkillDamageCallback fun(skill:SkillEventData, character:StatCharacter):string
---@alias LeaderLibGetTooltipSkillParam fun(skill:SkillEventData, character:StatCharacter, param:string):string

---Called from GameHelpers.Tooltip.ReplacePlaceholders when [SkillDamage:SkillId] text exists in the string.
---@type LeaderLibGetTooltipSkillDamageCallback[]
Listeners.GetTooltipSkillDamage = {}
---Called from GameHelpers.Tooltip.ReplacePlaceholders when [Skill:SkillId:Param] text exists in the string.
---@type LeaderLibGetTooltipSkillParam[]
Listeners.GetTooltipSkillParam = {}

--Debug listeners
Listeners.LuaReset = {}
Listeners.BeforeLuaReset = {}
---Called when LeaderLib finishes loading its server-side or client-side scripts.
Listeners.Loaded = {}

---Callbacks for when all global settings are loaded, or when an individual mod's settings are loaded.
Listeners.ModSettingsLoaded = {All = {}}
---Callbacks for when ModSettings are synced on both the server and client.
---@type fun(uuid:string, settings:ModSettings):void[]
Listeners.ModSettingsSynced = {}

---@alias ModSettingsFlagDataChangedListener fun(id:string, enabled:boolean, data:FlagData, settings:SettingsData):void
---@alias ModSettingsVariableDataChangedListener fun(id:string, value:integer, data:VariableData, settings:SettingsData):void

---@type table<string, ModSettingsFlagDataChangedListener|ModSettingsVariableDataChangedListener>
Listeners.ModSettingsChanged = {All = {}}

---@alias MessageBoxEventListener fun(event:string, isConfirmed:boolean, player:EsvCharacter|EclCharacter):void
---@type table<string, MessageBoxEventListener>
Listeners.MessageBoxEvent = {All = {}}

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

	---Modifies the result of HitOverrides.CanBackstab if true or false is returned. The second returned boolean is optional, and will make backstabs ignore positioning.
	---@alias LeaderLibGetCanBackstabCallback fun(canBackstab:boolean, target:StatCharacter, attacker:StatCharacter, weapon:StatItem, damageList:DamageList, hitType:string, noHitRoll:boolean, forceReduceDurability:boolean, hit:HitRequest, alwaysBackstab:boolean, highGroundFlag:HighGroundFlag, criticalRoll:CriticalRollFlag):boolean,boolean
	---@type LeaderLibGetCanBackstabCallback[]
	Listeners.GetCanBackstab = {}

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

	---@alias OnHealCallback fun(target:EsvCharacter|EsvItem, source:EsvCharacter|EsvItem, heal:EsvStatusHeal, originalAmount:integer, handle:integer, skill:string|nil, healingSourceStatus:EsvStatusHealing|nil):void
	---Fires during NRD_OnHeal.
	---@type OnHealCallback[]
	Listeners.OnHeal = {}

	---Server-side event for when base ability or attribute values change on players. Can fire from character sheet interaction or after respec.
	---@type table<string, fun(uuid:string, stat:string, lastVal:integer, nextVal:integer, statType:string):void>
	Listeners.CharacterBasePointsChanged = {}

	---@alias TurnCounterCallback fun(id:string, turn:integer, lastTurn:integer, finished:boolean, data:TurnCounterData):void

	---@type TurnCounterCallback[]
	Listeners.OnTurnCounter = {}
	---@type table<string, TurnCounterCallback>
	Listeners.OnNamedTurnCounter = {}
	---Called when a summon is created or destroyed. Includes items like mines.
	---@type table<string, fun(summon:EsvCharacter, owner:EsvCharacter, isDying:boolean, isItem:boolean)>
	Listeners.OnSummonChanged = {}
	---@type table<string, fun(event:string, vararg string)>
	Listeners.ObjectEvent = {}

	---Called when PersistentVars should be initialized from a table of default values.
	---@type function[]
	Listeners.PersistentVarsLoaded = {}

	---@type fun(target:EsvCharacter|EsvItem, source:EsvCharacter|EsvItem|nil, distance:number, startingPosition:number[], skill:StatEntrySkillData|nil):void[]
	Listeners.ForceMoveFinished = {}
end
if Ext.IsClient() then
	---Client-side Mod Menu events
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
	
	---@alias OnBuiltinContextMenuOpeningCallback fun(contextMenu:ContextMenu, ui:UIObject, this:FlashMainTimeline, buttonArr:FlashArray, buttons:table):void
	---Triggered when the regular context menu is opening.
	---@type OnBuiltinContextMenuOpeningCallback[]
	Listeners.OnBuiltinContextMenuOpening = {}
	
	---@alias OnContextMenuEntryClickedCallback fun(contextMenu:ContextMenu, ui:UIObject, entryID:integer, actionID:string, handle:number):void
	---@type OnContextMenuEntryClickedCallback[]
	Listeners.OnContextMenuEntryClicked = {}

	---@alias UICreatedCallback fun(ui:UIObject, this:FlashMainTimeline, player:EclCharacter):void
	---Called after a UI is created, when the main timeline is hopefully ready.
	---Register to a UIType or "All" for all UIs.
	---@type table<integer,UICreatedCallback>
	Listeners.UICreated = {All = {}}

	---@type fun(ui:UIExtensionsMain, control:FlashMovieClip, id:string, index:integer):void[]
	Listeners.UIExtensionsControlAdded = {}

	---Simple listener called when Vars.ControllerEnabled is set to true.
	---@type function[]
	Listeners.ControllerModeEnabled = {}
end

---@class LeaderLib:table
---@field RegisterListener fun(event:LeaderLibGlobalListenerEvent|LeaderLibServerListenerEvent|LeaderLibClientListenerEvent|string[], callbackOrKey:function|string, callbackOrNil:function|nil):void

--- Registers a function to call when a specific Lua LeaderLib event fires.
---@param event LeaderLibGlobalListenerEvent|LeaderLibServerListenerEvent|LeaderLibClientListenerEvent|string[] Listener table name.
---@param callbackOrKey function|string If a string, the function is stored in a subtable of the event, such as NamedTimerFinished.TimerName = function
---@param callbackOrNil function|nil If callback is a string, then this is the callback.
function RegisterListener(event, callbackOrKey, callbackOrNil)
	local listenerTable = nil
	if type(event) == "table" then
		if Common.TableHasValue(Listeners, event) then
			listenerTable = event
		else
			for i,v in pairs(event) do
				if Listeners[v] then
					RegisterListener(v, callbackOrKey, callbackOrNil)
				end
			end
			return
		end
	else
		listenerTable = Listeners[event]
	end
	if listenerTable then
		local keyType = type(callbackOrKey)
		if keyType == "string" or keyType == "number" then
			if callbackOrNil then
				if listenerTable[callbackOrKey] == nil then
					listenerTable[callbackOrKey] = {}
				end
				table.insert(listenerTable[callbackOrKey], callbackOrNil)
			else
				Ext.PrintError(string.format("[LeaderLib__Main.lua:RegisterListener] Event (%s) with sub-key (%s) requires a function as the third parameter. Context: %s", event, callbackOrKey, Ext.IsServer() and "SERVER" or "CLIENT"))
			end
		else
			if listenerTable.All ~= nil then
				table.insert(listenerTable.All, callbackOrKey)
			else
				table.insert(listenerTable, callbackOrKey)
			end
		end
	else
		Ext.PrintError(string.format("[LeaderLib__Main.lua:RegisterListener] Event (%s) is not a valid LeaderLib listener event! Context: %s", event, Ext.IsServer() and "SERVER" or "CLIENT"))
	end
end

--- Unregisters a function for a specific listener event.
---@param event string
---@param callback function
function RemoveListener(event, callback, param)
	if Listeners[event] ~= nil then
		if type(callback) == "string" then
			if Listeners[event][callback] ~= nil then
				local count = 0
				for i,v in pairs(Listeners[event][callback]) do
					if v == param then
						table.remove(Listeners[event][callback], i)
					else
						count = count + 1
					end
				end
				if count == 0 then
					Listeners[event][callback] = nil
				end
			end
		else
			for i,v in pairs(Listeners[event]) do
				if v == callback then
					table.remove(Listeners[event], i)
				end
			end
		end
	end
end

function InvokeListenerCallbacks(callbacks, ...)
	local length = callbacks and #callbacks or 0
	if length > 0 then
		for i=1,length do
			local callback = callbacks[i]
			local b,err = xpcall(callback, debug.traceback, ...)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
end

--- Registers a function to call when a specific Lua LeaderLib event fires for specific mods.
--- Events: Registered|Updated
---@param event string
---@param uuid string
---@param callback function
function RegisterModListener(event, uuid, callback)
	if ModListeners[event] ~= nil then
		ModListeners[event][uuid] = callback
	else
		Ext.PrintError("[LeaderLib__Main.lua:RegisterListener] Event ("..tostring(event)..") is not a valid LeaderLib listener event!")
	end
end