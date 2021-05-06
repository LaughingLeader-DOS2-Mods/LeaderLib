---@class LeaderLibInputManager
Input = {
	Keys = {}
}

for i,name in pairs(Data.InputEnum) do
	Input.Keys[name] = false
end

---Wrapper around RegisterListener for easier auto-completion.
---@param callbackOrInputName InputEventCallback
function Input.RegisterListener(callbackOrInputName, callbackOrNil)
	if type(callbackOrInputName) == "string" then
		if callbackOrNil ~= nil then
			RegisterListener("NamedInputEvent", callbackOrInputName, callbackOrNil)
		end
	else
		RegisterListener("InputEvent", callbackOrInputName)
	end
end

---@param callbackOrInputNameOrInputName InputEventCallback
function Input.RemoveListener(callbackOrInputName, callbackOrNil)
	local t = type(callbackOrInputName)
	if t == "string" and callbackOrNil ~= nil then
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

function Input.GetKeyState(name)
	local ids = Data.Input[name]
	if ids then
		if type(ids) == "table" then
			for _,id in pairs(ids) do
				local state = Input.Keys[Data.InputEnum[id]]
				if state == true then
					return true
				end
			end
		else
			return Input.Keys[Data.InputEnum[ids]]
		end
	end
	return Input.Keys[name] == true
end

function Input.GetKeyStateByID(id)
	local name = Data.InputEnum[id]
	if name then
		local state = Input.Keys[name]
		if state ~= nil then
			return state
		end
	end
	return false
end

---@param evt InputEvent
Ext.RegisterListener("InputEvent", function(evt)
	local eventName = Data.InputEnum[evt.EventId]
	if eventName then
		local fireListeners = Input.Keys[eventName] ~= evt.Press
		Input.Keys[eventName] = evt.Press
		if fireListeners then
			InvokeListenerCallbacks(Listeners.InputEvent, eventName, evt.Press, evt.EventId, Input.Keys, Vars.ControllerEnabled)
			InvokeListenerCallbacks(Listeners.NamedInputEvent[eventName], eventName, evt.Press, evt.EventId, Input.Keys, Vars.ControllerEnabled)
		end

		if not UIExtensions.MouseEnabled and evt.Press and eventName == "FlashLeftMouse" or eventName == "FlashRightMouse" then
			UIExtensions.Invoke("fireMouseClicked", eventName)
		end
	end

	if Vars.DebugMode then
		fprint(LOGLEVEL.DEFAULT, "[ExtInputEvent] (%s) Pressed(%s) Time(%s)", eventName, evt.EventId, evt.Press, Ext.MonotonicTime())
	end
end)

---@param ui LeaderLibUIExtensions
---@param pressed boolean
---@param eventName string
---@param arrayIndex integer
function Input.OnFlashEvent(ui, call, pressed, eventName, arrayIndex)
	local fireListeners = Input.Keys[eventName] ~= pressed
	eventName = string.gsub(eventName, "IE ", "")
	Input.Keys[eventName] = pressed
	-- if Vars.DebugMode then
	-- 	PrintLog("[Input.OnFlashEvent] eventName(%s) pressed(%s) index(%i)", eventName, pressed, arrayIndex)
	-- end
	if fireListeners then
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