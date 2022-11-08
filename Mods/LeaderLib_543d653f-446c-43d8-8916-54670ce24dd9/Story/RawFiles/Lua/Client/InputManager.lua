local _EXTVERSION = Ext.Utils.Version()

---@class LeaderLibInputManager
Input = {
	Keys = {},
	---@class KEYSTATE:table
	KEYSTATE = {
		UNREGISTERED = -1,
		RELEASED = 0,
		DOWN = 1,
		[-1] = "UNREGISTERED",
		[0] = "RELEASED",
		[1] = "DOWN"
	},
	Vars = {
		JustPressedThreshold = 750
	},
	SkipStateCheck = {
		--Doesn't fire events on pressed (only release), so the state change check will fail otherwise
		ContextMenu = 0,
		--These buttons fires on press, not release (ctrl)
		DragSingleToggle = 1,
		DestructionToggle = 1,
		ToggleInfo = 1,
		FlashCtrl = 1,
		ShowWorldTooltips = 1,
		--Shift
		-- QueueCommand = 1,
		-- SplitItemToggle = 1,
		-- ShowSneakCones = 1,
	},
	Shift = false,
	Alt = false,
	Ctrl = false
}

local KEYSTATE = Input.KEYSTATE
local lastPressedTimes = {}

local SpecialKeys = {
	[285] = "Shift"
}

--Initialize states
for name,ids in pairs(Data.InputEnum) do
	Input.Keys[name] = 0
end

---Wrapper around RegisterListener for easier auto-completion.
---@param callbackOrInputName InputEventCallback|string|integer
---@param callbackOrNil InputEventCallback|nil
function Input.RegisterListener(callbackOrInputName, callbackOrNil)
	local t = type(callbackOrInputName)
	if t == "table" then
		for i,v in pairs(callbackOrInputName) do
			Input.RegisterListener(v, callbackOrNil)
		end
	else
		if (t == "string" or t == "number") and callbackOrNil ~= nil then
			if t == "number" then
				local id = callbackOrInputName
				callbackOrInputName = Data.InputEnum[id]
				if not callbackOrInputName then
					error(string.format("Invalid input id %s", id))
				end
			end
			RegisterListener("NamedInputEvent", callbackOrInputName, callbackOrNil)
		elseif t == "function" then
			RegisterListener("InputEvent", callbackOrInputName)
		end
	end
end

---Wrapper around RegisterListener for easier auto-completion.
---@param callbackOrEventName InputEventCallback|string
---@param callbackOrNil InputEventCallback|nil
function Input.RegisterMouseListener(callbackOrEventName, callbackOrNil)
	local t = type(callbackOrEventName)
	if t == "string" and callbackOrNil ~= nil then
		RegisterListener("MouseInputEvent", callbackOrEventName, callbackOrNil)
	elseif t == "function" then
		RegisterListener("MouseInputEvent", UIExtensions.MouseEvent.All, callbackOrEventName)
	end
end

---@param callbackOrInputName InputEventCallback
---@param callbackOrNil InputEventCallback|nil
function Input.RemoveListener(callbackOrInputName, callbackOrNil)
	local t = type(callbackOrInputName)
	if t == "table" then
		for i,v in pairs(callbackOrInputName) do
			Input.RemoveListener(v, callbackOrNil)
		end
	else
		if t == "string" or t == "number" and callbackOrNil ~= nil then
			if t == "number" then
				local id = callbackOrInputName
				callbackOrInputName = Data.InputEnum[id]
				if not callbackOrInputName then
					error(string.format("Invalid input id %s", id))
				end
			end
			local listeners = Listeners.NamedInputEvent[callbackOrInputName]
			if listeners then
				for i,v in pairs(listeners) do
					if v == callbackOrNil then
						table.remove(listeners, i)
					end
				end
			end
		elseif t == "function" then
			for i,v in pairs(Listeners.InputEvent) do
				if v == callbackOrInputName then
					table.remove(Listeners.InputEvent, i)
				end
			end
		end
	end
end

---@param name string|integer|string[]|integer[]
---@return boolean
function Input.IsPressed(name)
	local t = type(name)
	if t == "table" then
		for _,v in pairs(name) do
			if Input.IsPressed(v) then
				return true
			end
		end
		return false
	else
		local state = Input.GetKeyState(name, t)
		return state == KEYSTATE.DOWN
	end
end

---@param name string|integer|string[]|integer[]
---@return boolean
function Input.IsReleased(name)
	local t = type(name)
	if t == "table" then
		for _,v in pairs(name) do
			if Input.IsReleased(v) then
				return true
			end
		end
		return false
	else
		local state = Input.GetKeyState(name, t)
		return state ~= KEYSTATE.DOWN
	end
end

---@param name string|integer|string[]|integer[]
---@param threshold integer|nil Max amount of milliseconds to determine if the key was just pressed.
---@return boolean
function Input.JustPressed(name, threshold)
	threshold = threshold or Input.Vars.JustPressedThreshold
	local t = type(name)
	if t == "table" then
		for _,v in pairs(name) do
			if Input.JustPressed(v, threshold) then
				return true
			end
		end
	else
		local time = nil
		if t == "string" then
			time = lastPressedTimes[name]
		elseif t == "number" then
			local inputName = Data.InputEnum[name]
			time = inputName and lastPressedTimes[inputName] or nil
		end
		if time and Ext.MonotonicTime() - time <= threshold then
			return true
		end
	end
	return false
end

---@param name string|integer
---@return integer
function Input.GetKeyState(name, t)
	local t = t or type(name)
	if t == "number" then
		local actualName = Data.InputEnum[name]
		if actualName then
			if type(actualName) == "table" then
				for _,n in pairs(actualName) do
					local state = Input.Keys[n]
					if state ~= KEYSTATE.UNREGISTERED then
						return state
					end
				end
				return KEYSTATE.UNREGISTERED
			else
				return Input.Keys[actualName] or KEYSTATE.UNREGISTERED
			end
		end
	elseif t == "string" then
		return Input.Keys[name] or KEYSTATE.UNREGISTERED
	end
	fprint(LOGLEVEL.WARNING, "[LeaderLib:Input.GetKeyState] No valid input for name (%s)", name)
	return KEYSTATE.UNREGISTERED
end

--Workaround to prevent key event listeners firing more than once for the same state from a separate extender/flash event
local lastFiredEventFrom = {}

---@param evt InputEvent
local function InvokeExtenderEventCallbacks(evt, eventName)
	local nextState = evt.Press and KEYSTATE.DOWN or KEYSTATE.RELEASED
	if evt.Press or Input.SkipStateCheck[eventName] == KEYSTATE.RELEASED then
		lastPressedTimes[eventName] = Ext.MonotonicTime()
	end
	-- if Vars.DebugMode then
	-- 	fprint(LOGLEVEL.DEFAULT, "[ExtInputEvent] (%s)[%s] Pressed(%s) Time(%s) Last(%s) WillFire(%s)", eventName, evt.EventId, evt.Press, Ext.MonotonicTime(), lastFiredEventFrom[eventName], lastFiredEventFrom[eventName] ~= 1 or Input.Keys[eventName] ~= nextState)
	-- end
	if lastFiredEventFrom[eventName] ~= 1 or Input.Keys[eventName] ~= nextState then
		Input.Keys[eventName] = nextState
		if evt.Press and eventName == "ActionCancel" and SharedData.RegionData.LevelType == LEVELTYPE.GAME then
			local client = Client:GetCharacter()
			if client then
				Ext.PostMessageToServer("LeaderLib_Input_OnActionCancel", tostring(client.NetID))
			end
		end

		local stopPropagation = false
		if _EXTVERSION < 57 and eventName == TooltipExpander.KeyboardKey then
			stopPropagation = TooltipExpander.OnKeyPressed(evt.Press) == true
		end

		if InvokeListenerCallbacks(Listeners.InputEvent, eventName, evt.Press, evt.EventId, Input.Keys, Vars.ControllerEnabled) then
			stopPropagation = true
		end
		if InvokeListenerCallbacks(Listeners.NamedInputEvent[eventName], eventName, evt.Press, evt.EventId, Input.Keys, Vars.ControllerEnabled) then
			stopPropagation = true
		end

		if Ext.GetGameState() == "Running" then
			if not UIExtensions.MouseEnabled and evt.Press and eventName == "FlashLeftMouse" or eventName == "FlashRightMouse" then
				UIExtensions.Invoke("fireMouseClicked", eventName)
			end
		end
		lastFiredEventFrom[eventName] = 0
		return stopPropagation
	end
end

Ext.Events.InputEvent:Subscribe(function (e)
	local evt = e.Event
	local eventName = Data.InputEnum[evt.EventId]
	-- if Vars.DebugMode then
	-- 	if type(eventName) ~= "string" or not string.find(eventName, "Mouse") then
	-- 		fprint(LOGLEVEL.DEFAULT, "[ExtInputEvent] (%s)", Common.JsonStringify(eventName) or "nil")
	-- 		Ext.Dump(evt)
	-- 	end
	-- end
	local stopPropagation = false
	if eventName then
		if type(eventName) == "table" then
			for i=1,#eventName do
				if InvokeExtenderEventCallbacks(evt, eventName[i]) then
					stopPropagation = true
				end
			end
		else
			if InvokeExtenderEventCallbacks(evt, eventName) then
				stopPropagation = true
			end
		end
	elseif Vars.DebugMode then
		fprint(LOGLEVEL.WARNING, "[LeaderLib:OnInputEvent] No key registered for id (%s)", evt.EventId)
	end
	if stopPropagation then
		e:StopPropagation()
	end
end, {Priority=1000})

---@param ui LeaderLibUIExtensions
---@param pressed boolean
---@param eventName string
---@param arrayIndex integer
function Input.OnFlashEvent(ui, call, pressed, eventName, arrayIndex)
	eventName = string.gsub(eventName, "IE ", "")
	local nextState = pressed and KEYSTATE.DOWN or KEYSTATE.RELEASED
	if pressed or Input.SkipStateCheck[eventName] == KEYSTATE.RELEASED then
		lastPressedTimes[eventName] = Ext.MonotonicTime()
	end

	-- if Vars.DebugMode and not string.find(eventName, "Mouse") then
	-- 	PrintLog("[Input.OnFlashEvent] eventName(%s) pressed(%s) index(%s) Last(%s) WillFire(%s)", eventName, pressed, arrayIndex, lastFiredEventFrom[eventName], lastFiredEventFrom[eventName] ~= 0 or Input.Keys[eventName] ~= nextState)
	-- end

	if lastFiredEventFrom[eventName] ~= 0 or Input.Keys[eventName] ~= nextState then
		if pressed and eventName == "ActionCancel" then
			local client = Client:GetCharacter()
			if client then
				Ext.PostMessageToServer("LeaderLib_Input_OnActionCancel", tostring(client.NetID))
			end
		end
		Input.Keys[eventName] = nextState
		local id = Data.Input[eventName]

		local stopPropagation = false

		if _EXTVERSION < 57 and eventName == TooltipExpander.KeyboardKey then
			stopPropagation = TooltipExpander.OnKeyPressed(pressed) == true
		end

		if type(id) == "table" then
			for _,kid in pairs(id) do
				InvokeListenerCallbacks(Listeners.InputEvent, eventName, pressed, kid, Input.Keys, Vars.ControllerEnabled)
				InvokeListenerCallbacks(Listeners.NamedInputEvent[eventName], eventName, pressed, kid, Input.Keys, Vars.ControllerEnabled)
			end
		else
			InvokeListenerCallbacks(Listeners.InputEvent, eventName, pressed, id, Input.Keys, Vars.ControllerEnabled)
			InvokeListenerCallbacks(Listeners.NamedInputEvent[eventName], eventName, pressed, id, Input.Keys, Vars.ControllerEnabled)
		end
		lastFiredEventFrom[eventName] = 1
	end
end

function Input.OnMouseEvent(event, x, y)
	InvokeListenerCallbacks(Listeners.MouseInputEvent[event], x, y)
	InvokeListenerCallbacks(Listeners.MouseInputEvent[UIExtensions.MouseEvent.All], x, y)
end

local ShiftKeys = {
	QueueCommand = true,
	SplitItemToggle = true,
	ShowSneakCones = true,
}

function Input.UpdateModifierKeys(ui, event, shiftKey, altKey, ctrlKey)
	-- Input.Shift = shiftKey
	-- Input.Alt = altKey
	-- Input.Ctrl = ctrlKey
end

function Input.OnKeyboardEvent(ui, call, keyCode, keyName, pressed)
	if Vars.DebugMode and Vars.Print.Input then
		PrintLog("[Input.OnKeyboardEvent] call(%s) keyCode(%s) keyName(%s) pressed(%s)", call, keyCode, keyName, pressed)
	end
end

local brokenCtrlKeys = {
	"DragSingleToggle",
	"DestructionToggle",
	"ToggleInfo",
	"FlashCtrl",
}

Ext.RegisterUITypeInvokeListener(Data.UIType.hotBar, "setActionPreview", function(ui, method, skill, b)
	if skill == "ActionAttackGround" and not b then
		for _,v in pairs(brokenCtrlKeys) do
			if Input.Keys[v] ~= KEYSTATE.RELEASED then
				Input.Keys[v] = KEYSTATE.RELEASED
				local id = Data.Input[v]
				if type(id) == "table" then
					for _,kid in pairs(id) do
						InvokeListenerCallbacks(Listeners.InputEvent, v, false, kid, Input.Keys, Vars.ControllerEnabled)
						InvokeListenerCallbacks(Listeners.NamedInputEvent[v], v, false, kid, Input.Keys, Vars.ControllerEnabled)
					end
				else
					InvokeListenerCallbacks(Listeners.InputEvent, v, false, id, Input.Keys, Vars.ControllerEnabled)
					InvokeListenerCallbacks(Listeners.NamedInputEvent[v], v, false, id, Input.Keys, Vars.ControllerEnabled)
				end
				lastFiredEventFrom[v] = 1
			end
		end
	end
end)

local brokenAltKeys = {
	"ShowWorldTooltips",
	"FlashAlt",
}

Ext.RegisterUITypeInvokeListener(Data.UIType.worldTooltip, "clearAll", function(ui, method)
	for _,v in pairs(brokenAltKeys) do
		if Input.Keys[v] ~= KEYSTATE.RELEASED then
			Input.Keys[v] = KEYSTATE.RELEASED
			local id = Data.Input[v]
			if type(id) == "table" then
				for _,kid in pairs(id) do
					InvokeListenerCallbacks(Listeners.InputEvent, v, false, kid, Input.Keys, Vars.ControllerEnabled)
					InvokeListenerCallbacks(Listeners.NamedInputEvent[v], v, false, kid, Input.Keys, Vars.ControllerEnabled)
				end
			else
				InvokeListenerCallbacks(Listeners.InputEvent, v, false, id, Input.Keys, Vars.ControllerEnabled)
				InvokeListenerCallbacks(Listeners.NamedInputEvent[v], v, false, id, Input.Keys, Vars.ControllerEnabled)
			end
			lastFiredEventFrom[v] = 1
		end
	end
end)

-- if Vars.DebugMode then
-- 	Input.RegisterListener(function(eventName, pressed, id, keys, controllerEnabled)
-- 		if not string.find(eventName, "Mouse") then
-- 			fprint(LOGLEVEL.DEFAULT, "[Input] event(%s) pressed(%s) id(%s) time(%s)", eventName, pressed, id, Ext.MonotonicTime())
-- 		end
-- 	end)
-- end

--[[
{
        "ActionPrevented" : false,
        "CanPreventAction" : false,
        "Input" :
        {
                "Input" :
                {
                        "DeviceId" : "Mouse",
                        "InputId" : "motion_yneg"
                },
                "Value" :
                {
                        "State" : "Released",
                        "Value" : 0.0,
                        "Value2" : 0.0
                }
        },
        "Name" : "RawInput",
        "PreventAction" : "function: 00007FFC848DCBB0",
        "StopPropagation" : "function: 00007FFC848DCB80",
        "Stopped" : false
}
]]

--Focus Tracking

local _focusedUI = nil

Ext.RegisterUINameCall("inputFocus", function (ui, event, ...)
	if ui.AnchorObjectName ~= UIExtensions.ID then
		_focusedUI = StringHelpers.GetLocalDataPath(ui.Path)
	end
end, "Before")

Ext.RegisterUINameCall("inputFocusLost", function (ui, event, ...)
	if ui.AnchorObjectName ~= UIExtensions.ID then
		_focusedUI = nil
	end
end, "Before")

local function _HandleNextInput()
	local ui = UIExtensions.GetInstance()
	if ui then
		ui:ExternalInterfaceCall("inputFocus")
		Ext.OnNextTick(function (e)
			local ui = UIExtensions.GetInstance()
			if ui then
				ui:ExternalInterfaceCall("inputFocusLost")
				if _focusedUI then
					local lastUI = Ext.UI.GetByPath(_focusedUI)
					if lastUI then
						lastUI:ExternalInterfaceCall("inputFocus")
					end
				end
			end
		end)
	end
end

Input.Subscribe = {}

---@param keys InputRawType|InputRawType[]
---@param callback fun(e:LeaderLibRawInputEventArgs|LeaderLibSubscribableEventArgs)
---@param requireAll boolean|nil If keys is a table of inputs, require all keys to be pressed.
---@param anyState boolean|nil
function Input.Subscribe.RawInput(keys, callback, requireAll, anyState)
	local t = type(keys)
	if t == "table" then
		---@param e LeaderLibRawInputEventArgs
		local isMatch = function (e)
			if not anyState and not e.Pressed then
				return false
			end
			if TableHelpers.HasValue(keys, e.ID) then
				if not requireAll then
					return true
				else
					local input = Ext.Input.GetInputManager()
					if input then
						for _,state in pairs(input.InputStates) do
							for _,id in pairs(keys) do
								local idNum = Data.RawInput[id]
								if not state.Inputs[idNum] or state.Inputs[idNum].State ~= "Pressed" then
									return false
								end
							end
						end
						return true
					end
				end
			end
			return false
		end
		Events.RawInput:Subscribe(callback, {MatchArgs=isMatch})
	else
		if not anyState then
			Events.RawInput:Subscribe(callback, {MatchArgs={ID=keys, Pressed=true}})
		else
			Events.RawInput:Subscribe(callback, {MatchArgs={ID=keys}})
		end
	end
end

Ext.Events.RawInput:Subscribe(function (e)
	local device = e.Input.Input
	local value = e.Input.Value
	if device.DeviceId == "Key" then
		local pressed = value.State == "Pressed"
		if device.InputId == "lshift" or device.InputId == "rshift" then
			Input.Shift = pressed
			TooltipExpander.OnKeyPressed(pressed)
		elseif device.InputId == "lctrl" or device.InputId == "rctrl" then
			Input.Ctrl = pressed
		elseif device.InputId == "lalt" or device.InputId == "ralt" then
			Input.Alt = pressed
		end
	end
	if device.DeviceId == "Key" or device.DeviceId == "Unknown" or device.DeviceId == "C" then
		---@type LeaderLibRawInputEventArgs|LeaderLibRuntimeSubscribableEventArgs
		local eventData = {
			Device = device.DeviceId,
			ID = device.InputId,
			Pressed = value.State == "Pressed",
			EventData = e.Input,
			Handled = false,
		}
		---@type SubscribableEventInvokeResult<LeaderLibRawInputEventArgs>
		local invokeResult = Events.GetHitResistanceBonus:Invoke(eventData)
		if invokeResult.ResultCode ~= "Error" then
			local handled = invokeResult.Handled

			if invokeResult.Results then
				for i=1,#invokeResult.Results do
					if invokeResult.Results[i] == true then
						handled = true
					end
				end
			end

			if handled then
				e:StopPropagation()
				_HandleNextInput()
			end
		end
	end
end)