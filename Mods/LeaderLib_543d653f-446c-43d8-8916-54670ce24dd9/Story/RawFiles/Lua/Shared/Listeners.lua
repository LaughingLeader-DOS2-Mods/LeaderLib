---@alias LeaderLibGlobalListenerEvent string|"FeatureEnabled" | "FeatureDisabled" | "Initialized" | "ModuleResume" | "SessionLoaded" | "TurnDelayed" | "SyncData" | "ClientDataSynced" | "ClientCharacterChanged" | "GetTooltipSkillDamage" | "GetTooltipSkillParam" | "LuaReset" | "BeforeLuaReset" | "Loaded" | "ModSettingsLoaded" | "ModSettingsSynced" | "ModSettingsChanged"

---@alias LeaderLibServerListenerEvent string|"ApplyDamageCharacterBonuses" | "CharacterBasePointsChanged" | "ComputeCharacterHit" | "DoHit" | "GetHitResistanceBonus" | "GlobalFlagChanged" | "NamedTimerFinished" | "ObjectEvent" | "OnHit" | "OnNamedTurnCounter" | "OnPrepareHit" | "OnSkillHit" | "OnSummonChanged" | "OnTurnCounter" | "PersistentVarsLoaded" | "ProcObjectTimerFinished" | "StatusHitEnter" | "TimerFinished" | "TreasureItemGenerated"

---@alias LeaderLibClientListenerEvent string|"CharacterSheetPointChanged" | "InputEvent" | "ModMenuSectionCreated" | "MouseInputEvent" | "NamedInputEvent" | "OnContextMenuEntryClicked" | "OnContextMenuOpening" | "OnTalentArrayUpdating" | "OnTooltipPositioned" | "OnWorldTooltip" | "ShouldOpenContextMenu" | "UICreated"

local _EXTVERSION = Ext.Version()
local _ISCLIENT = Ext.IsClient()

if not Listeners then
	Listeners = {}
end

--Debug listeners
---@type table<string,fun(cmd:string, isClient:boolean, ...):void>
Listeners.DebugCommand = {}

---Callbacks for when all global settings are loaded, or when an individual mod's settings are loaded.
Listeners.ModSettingsLoaded = {All = {}}

---@alias ModSettingsFlagDataChangedListener fun(id:string, enabled:boolean, data:FlagData, settings:SettingsData):void
---@alias ModSettingsVariableDataChangedListener fun(id:string, value:integer, data:VariableData, settings:SettingsData):void

---@type table<string, ModSettingsFlagDataChangedListener|ModSettingsVariableDataChangedListener>
Listeners.ModSettingsChanged = {All = {}}

---@alias MessageBoxEventListener fun(event:string, isConfirmed:boolean, player:EsvCharacter|EclCharacter):void
---@type table<string, MessageBoxEventListener>
Listeners.MessageBoxEvent = {All = {}}

if Ext.IsServer() then
	---@alias OnPrepareHitCallback fun(target:string, source:string, damage:integer, handle:integer, data:HitPrepareData):void
	---@alias OnHitCallback fun(target:string, source:string, damage:integer, handle:integer, skill:string|nil):void
	---@alias OnSkillHitCallback fun(skill:string, source:string, state:SKILL_STATE, data:HitData|ProjectileHitData):void

	---@deprecated
	---Fires when a skill hits, or a projectile from a skill hits.
	---@type OnSkillHitCallback[]
	Listeners.OnSkillHit = {}

	---@type table<string, fun(questId:string, character:EsvCharacter):void>
	Listeners.QuestStarted = {All = {}}
	---@type table<string, fun(questId:string, character:EsvCharacter):void>
	Listeners.QuestCompleted = {All = {}}
	---@type table<string, fun(questId:string, stateId:string, character:EsvCharacter):void>
	Listeners.QuestStateChanged = {All = {}}
else
	---Client-side Mod Menu events
	---Callbacks for when a mod's Mod Menu section is created in the options menu.
	---@type fun(uuid:string, settings:ModSettings, ui:UIObject, mainMenu:MainMenuMC):void[]
	Listeners.ModMenuSectionCreated = {}

	---@type fun(ui:UIObject, player:EclCharacter, startIndex:integer, talentEnumReference:table<string,integer>):void[]
	Listeners.OnTalentArrayUpdating = {}

	---@alias InputEventCallback fun(eventName:string, pressed:boolean, id:integer, inputMap:table<integer,boolean>, controllerEnabled:boolean):void
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

	---@type fun(ui:UIExtensionsMain, control:FlashMovieClip, id:string, index:integer)[]
	Listeners.UIExtensionsControlAdded = {}

	---@type fun(ui:UIExtensionsMain, width:number, height:number)[]
	Listeners.UIExtensionsResized = {}
end

---region Tick Listeners

local _state = Ext.GetGameState()

Ext.RegisterListener("GameStateChanged", function (from, to)
	_state = to
end)

Ext.Require("Shared/System/SubscriptionEvents.lua")

---@class GameTime
---@field Time number
---@field DeltaTime number
---@field Ticks integer

---Wrapper around Ext.Events.Tick that skips execution if resetting, or if the game isn't running.
---@type fun(e:GameTime):void[]
Listeners.Tick = {}

local _startTickTimer = false

---@param callback fun(e:GameTime):void
---@param runningOnly boolean|nil
function RegisterTickListener(callback, runningOnly)
	_startTickTimer = true
	if runningOnly then
		Listeners.Tick[#Listeners.Tick+1] = function (e)
			if _state == "Running" and not Vars.Resetting and Vars.Initialized then
				callback(e)
			end
		end
	else
		Listeners.Tick[#Listeners.Tick+1] = function (e)
			if not Vars.Resetting then
				callback(e)
			end
		end
	end
end

local function OnTick(e)
	InvokeListenerCallbacks(Listeners.Tick, e)
end

if _EXTVERSION >= 56 then
	Ext.Events.Tick:Subscribe(OnTick)
elseif Ext.IsDeveloperMode() and not _ISCLIENT then
	local _minTime = 0.1 -- 10 FPS
	local _maxTime = 0.016 -- 30 FPS
	local _monoTime = Ext.MonotonicTime
	local _clamp = nil

	local _lastTime = _monoTime()

	local _OnTick = nil
	_OnTick = function()
		local _ts = _monoTime()
		local _dt = _clamp((_ts - _lastTime) / 1000000, _maxTime, _minTime)
		--local _dt = (_ts - _lastTime) / 1000000
		--fprint(LOGLEVEL.DEFAULT, "DeltaTime(%s)(%s) Ticks(%s) Time(%s)", _dt, (_ts - _lastTime)/ 1000000, _ts, _ts / 1000000)
		_lastTime = _ts
		OnTick({Time = {
			DeltaTime = _dt,
			Ticks = _ts,
			Time = _ts / 1000000}})

		--Timer.StartOneshot("LeaderLib_v55_Tick", 30, _OnTick, true)
		if Testing.Active then
			TimerCancel("LeaderLib_v55_Tick")
			TimerLaunch("LeaderLib_v55_Tick", 30)
		end
	end

	Ext.RegisterOsirisListener("TimerFinished", 1, "after", function (timerName)
		if timerName == "LeaderLib_v55_Tick" then
			_OnTick()
		end
	end)

	Ext.RegisterListener("SessionLoaded", function ()
		_clamp = GameHelpers.Math.Clamp
	end)
end

---endregion

---@class LeaderLibGlobals:table
---@field RegisterListener fun(event:LeaderLibGlobalListenerEvent|LeaderLibServerListenerEvent|LeaderLibClientListenerEvent|string[], callbackOrKey:function|string, callbackOrNil:function|nil):void

--- Registers a function to call when a specific Lua LeaderLib event fires.
---@param event LeaderLibGlobalListenerEvent|LeaderLibServerListenerEvent|LeaderLibClientListenerEvent|string[] Listener table name.
---@param callbackOrKey function|string If a string, the function is stored in a subtable of the event, such as NamedTimerFinished.TimerName = function
---@param callbackOrNil function|nil If callback is a string, then this is the callback.
function RegisterListener(event, callbackOrKey, callbackOrNil)
	local listenerTable = nil
	local t = type(event)
	if type(event) == "table" then
		if Common.TableHasValue(Listeners, event) then
			listenerTable = event
		else
			for i,v in pairs(event) do
				RegisterListener(v, callbackOrKey, callbackOrNil)
			end
			return
		end
	elseif t == "string" then
		local keyType = type(callbackOrKey)
		local callback = keyType == "function" and callbackOrKey or callbackOrNil

		--Legacy support
		if event == "OnHit" then
			Events.OnHit:Subscribe(function (e)
				local b,err = xpcall(callback, debug.traceback, GameHelpers.GetUUID(e.Target), GameHelpers.GetUUID(e.Source), e.Data.Damage, e.Data.Handle, e.Data.Skill, e.HitStatus, e.Data.HitContext, e.Data)
				if not b then
					Ext.PrintError(err)
				end
			end)
			return
		elseif event == "StatusHitEnter" then
			Events.OnHit:Subscribe(function (e)
				local b,err = xpcall(callback, debug.traceback, e.Target, e.Source, e.Data, e.HitStatus)
				if not b then
					Ext.PrintError(err)
				end
			end)
			return
		elseif event == "OnNamedTurnCounter" then
			if keyType == "string" then
				Events.OnTurnCounter:Subscribe(function (e)
					local b,err = xpcall(callback, debug.traceback, e.ID, e.Turn, e.LastTurn, e.Finished, e.Data)
					if not b then
						Ext.PrintError(err)
					end
				end, {MatchArgs={id=callbackOrKey}})
			elseif keyType == "table" then
				for _,v in pairs(keyType) do
					RegisterListener("OnNamedTurnCounter", v, callbackOrNil)
				end
			end
			return
		elseif event == "OnTurnEnded" then
			local opts = nil
			if keyType == "string" and callbackOrKey ~= "All" then
				opts = {MatchArgs={ID=callbackOrKey}}
			end
			Events.OnTurnEnded:Subscribe(function (e)
				local b,err = xpcall(callback, debug.traceback, GameHelpers.GetUUID(e.Object), e.ID)
				if not b then
					Ext.PrintError(err)
				end
			end, opts)
			return
		elseif event == "UICreated" then
			if keyType == "number" and callbackOrKey ~= "All" then
				UI.RegisterUICreatedListener(callbackOrKey, callback)
			else
				Events.UICreated:Subscribe(function(e)
					local b,err = xpcall(callback, debug.traceback, e:Unpack())
					if not b then
						Ext.PrintError(err)
					end
				end)
			end
			return
		elseif event == "TimerFinished" then
			Events.TimerFinished:Subscribe(Timer._Internal.CreateDeprecatedWrapper(callback))
			return
		elseif event == "NamedTimerFinished" then
			local opts = nil
			if keyType == "string" and callbackOrKey ~= "All" then
				opts = {MatchArgs={ID=callbackOrKey}}
			end
			Events.TimerFinished:Subscribe(Timer._Internal.CreateDeprecatedWrapper(callback), opts)
			return
		elseif event == "GetTextPlaceholder" then
			local opts = nil
			if keyType == "string" and callbackOrKey ~= "All" then
				opts = {MatchArgs={ID=callbackOrKey}}
			end
			Events.GetTextPlaceholder:Subscribe(function (e)
				return callback(e.ID, e.Character, table.unpack(e.ExtraParams))
			end, opts)
			return
		end
		local subEvent = Events[event]
		if subEvent then
			subEvent:Subscribe(function(e)
				local b,err = xpcall(callbackOrKey, debug.traceback, e:Unpack())
				if not b then
					Ext.PrintError(err)
				end
			end)
			return
		else
			listenerTable = Listeners[event]
		end
	else
		error(string.format("Incorrect event ID (%s)", event), 2)
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

local invoke = xpcall
local messageFunc = debug.traceback
function InvokeListenerCallbacks(callbacks, ...)
	local length = callbacks and #callbacks or 0
	if length > 0 then
		for i=1,length do
			local callback = callbacks[i]
			local b,err = invoke(callback, messageFunc, ...)
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