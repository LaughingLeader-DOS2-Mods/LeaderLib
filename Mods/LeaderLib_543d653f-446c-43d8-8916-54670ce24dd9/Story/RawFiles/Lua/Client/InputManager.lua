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
	--These controls don't fire events on pressed (only release), so the state change check will fail otherwise
	SkipStateCheck = {
		ContextMenu = true,
		--Ctrl buttons fires on press, not release
		DragSingleToggle = true,
		DestructionToggle = true,
		ToggleInfo = true,
		FlashCtrl = true,
		ShowWorldTooltips = true,
	}
}

local KEYSTATE = Input.KEYSTATE
local lastPressedTimes = {}

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
---@param callbackOrEventName InputEventCallback
---@param callbackOrNil InputEventCallback|nil
function Input.RegisterMouseListener(callbackOrEventName, callbackOrNil)
	local t = type(callbackOrEventName)
	if t == "string" and callbackOrNil ~= nil then
		RegisterListener("MouseInputEvent", callbackOrEventName, callbackOrNil)
	elseif t == "function" then
		RegisterListener("MouseInputEvent", UIExtensions.MouseEvent.All, callbackOrEventName)
	end
end

---@param callbackOrEventName InputEventCallback
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
---@return boolean
function Input.JustPressed(name)
	local t = type(name)
	if t == "table" then
		for _,v in pairs(name) do
			if Input.IsJustPressed(v) then
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
		if time and Ext.MonotonicTime() - time <= Input.Vars.JustPressedThreshold then
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
					if state ~= KEYSTATE.INACTIVE then
						return state
					end
				end
				return KEYSTATE.INACTIVE
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

--Used to workaround keys that don't send an opposite event
local lastExtenderState = {}
local function InvokeExtenderEventCallbacks(evt, eventName)
	lastExtenderState[eventName] = Input.Keys[eventName] or KEYSTATE.UNREGISTERED
	local nextState = evt.Press and KEYSTATE.DOWN or KEYSTATE.RELEASED
	if evt.Press then
		lastPressedTimes[eventName] = Ext.MonotonicTime()
	end
	-- if Vars.DebugMode then
	-- 	fprint(LOGLEVEL.DEFAULT, "[ExtInputEvent] (%s)[%s] Pressed(%s) Time(%s) Last(%s)", eventName, evt.EventId, evt.Press, Ext.MonotonicTime(), lastExtenderState[eventName])
	-- end

	local skipCheck = Input.SkipStateCheck[eventName] or lastExtenderState[eventName] == nextState

	if skipCheck or Input.Keys[eventName] ~= nextState then
		Input.Keys[eventName] = nextState
		if evt.Press and eventName == "ActionCancel" then
			Ext.PostMessageToServer("LeaderLib_Input_OnActionCancel", Client:GetCharacter().MyGuid)
		end
		InvokeListenerCallbacks(Listeners.InputEvent, eventName, evt.Press, evt.EventId, Input.Keys, Vars.ControllerEnabled)
		InvokeListenerCallbacks(Listeners.NamedInputEvent[eventName], eventName, evt.Press, evt.EventId, Input.Keys, Vars.ControllerEnabled)

		if not UIExtensions.MouseEnabled and evt.Press and eventName == "FlashLeftMouse" or eventName == "FlashRightMouse" then
			UIExtensions.Invoke("fireMouseClicked", eventName)
		end
	end
end

---@param evt InputEvent
Ext.RegisterListener("InputEvent", function(evt)
	local eventName = Data.InputEnum[evt.EventId]
	if eventName then
		if type(eventName) == "table" then
			for i=1,#eventName do
				InvokeExtenderEventCallbacks(evt, eventName[i])
			end
		else
			InvokeExtenderEventCallbacks(evt, eventName)
		end
	end
end)

--Used to workaround keys that don't send an opposite event
local lastFlashState = {}

---@param ui LeaderLibUIExtensions
---@param pressed boolean
---@param eventName string
---@param arrayIndex integer
function Input.OnFlashEvent(ui, call, pressed, eventName, arrayIndex)
	eventName = string.gsub(eventName, "IE ", "")
	lastFlashState[eventName] = Input.Keys[eventName] or KEYSTATE.UNREGISTERED
	local nextState = pressed and KEYSTATE.DOWN or KEYSTATE.RELEASED
	if pressed then
		lastPressedTimes[eventName] = Ext.MonotonicTime()
	end
	
	-- if Vars.DebugMode and not string.find(eventName, "Mouse") then
	-- 	PrintLog("[Input.OnFlashEvent] eventName(%s) pressed(%s) index(%s) Last(%s)", eventName, pressed, arrayIndex, lastFlashState[eventName])
	-- end

	local skipCheck = Input.SkipStateCheck[eventName] or lastFlashState[eventName] == nextState

	if skipCheck or Input.Keys[eventName] ~= nextState then
		if pressed and eventName == "ActionCancel" then
			Ext.PostMessageToServer("LeaderLib_OnActionCancel", Client:GetCharacter().MyGuid)
		end
		Input.Keys[eventName] = nextState
		local id = Data.Input[eventName]
		if type(id) == "table" then
			for _,kid in pairs(id) do
				InvokeListenerCallbacks(Listeners.InputEvent, eventName, pressed, kid, Input.Keys, Vars.ControllerEnabled)
				InvokeListenerCallbacks(Listeners.NamedInputEvent[eventName], eventName, pressed, kid, Input.Keys, Vars.ControllerEnabled)
			end
		else
			InvokeListenerCallbacks(Listeners.InputEvent, eventName, pressed, id, Input.Keys, Vars.ControllerEnabled)
			InvokeListenerCallbacks(Listeners.NamedInputEvent[eventName], eventName, pressed, id, Input.Keys, Vars.ControllerEnabled)
		end
	end
end

function Input.OnMouseEvent(event, x, y)
	InvokeListenerCallbacks(Listeners.MouseInputEvent[event], x, y)
	InvokeListenerCallbacks(Listeners.MouseInputEvent[UIExtensions.MouseEvent.All], x, y)
end

function Input.OnKeyboardEvent(ui, call, keyCode, keyName, pressed)
	if Vars.DebugMode then
		PrintLog("[Input.OnKeyboardEvent] call(%s) keyCode(%s) keyName(%s) pressed(%s)", call, keyCode, keyName, pressed)
	end
end

if Vars.DebugMode then
	Input.RegisterListener(function(eventName, pressed, id, keys, controllerEnabled)
		if not string.find(eventName, "Mouse") then
			fprint(LOGLEVEL.DEFAULT, "[Input] event(%s) pressed(%s) id(%s) time(%s)", eventName, pressed, id, Ext.MonotonicTime())
		end
	end)
end