---@class LeaderLibInputManager
Input = {
	Keys = {}
}

--Wrapper around RegisterListener for easier auto-completion.
---@param callback InputEventCallback
function Input.RegisterListener(callback)
	RegisterListener("InputEvent", callback)
end

---@param evt InputEvent
local function OnInputEvent(evt)
	--PrintLog("[InputEvent] EventId(%s)\n  InputDeviceId(%s)\n  InputPlayerIndex(%s)\n  Press(%s)\n  Release(%s)\n  ValueChange(%s)\n  Hold(%s)\n  Repeat(%s)\n  AcceleratedRepeat(%s)", evt.EventId, evt.InputDeviceId, evt.InputPlayerIndex, evt.Press, evt.Release, evt.ValueChange, evt.Hold, evt.Repeat, evt.AcceleratedRepeat)
	Input.Keys[evt.EventId] = evt.Press

	InvokeListenerCallbacks(Listeners.InputEvent, evt, Input.Keys, Vars.ControllerEnabled)
end

if Ext.IsDeveloperMode() then
	---@param evt InputEvent
	Ext.RegisterListener("InputEvent", OnInputEvent)
end