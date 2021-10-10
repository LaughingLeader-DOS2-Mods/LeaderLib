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
---@param threshold integer|nil Max amount of milliseconds to determine if the key was just pressed.
---@return boolean
function Input.JustPressed(name, threshold)
	threshold = threshold or Input.Vars.JustPressedThreshold
	local t = type(name)
	if t == "table" then
		for _,v in pairs(name) do
			if Input.IsJustPressed(v, threshold) then
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

local function OnInputChanged(eventName, pressed, id, keys, controllerEnabled)
	if not controllerEnabled then
		if not Client.Character.IsGameMaster and eventName == "ToggleGMShroud" and not pressed then
			UI.ToggleChainGroup()
		end
		-- if Vars.DebugMode then
		-- 	if eventName == "UICopy" and pressed then
		-- 		Ext.GetUIByType(Data.UIType.GMMetadataBox):ExternalInterfaceCall("copy", "Test test")
		-- 	end
		-- end
	end
	-- if controllerEnabled then
	-- 	--Area Interact input workaround
	-- 	local ui = Ext.GetUIByType(Data.UIType.areaInteract_c)
	-- 	if ui then
	-- 		local this = ui:GetRoot()
	-- 		local areaInteractEventId = -1
	-- 		for i=0,#this.events-1 do
	-- 			local name = this.events[i]
	-- 			print(i,name)
	-- 			if name == eventName then
	-- 				areaInteractEventId = i
	-- 				break
	-- 			end
	-- 		end
	-- 		if areaInteractEventId ~= -1 then
	-- 			print("OnInputChanged(areaInteract_c fix)", eventName, areaInteractEventId, id)
	-- 			if pressed then
	-- 				this.onEventDown(areaInteractEventId)
	-- 			else
	-- 				this.onEventUp(areaInteractEventId)
	-- 			end
	-- 		end
	-- 	end
	-- end
end

--Workaround to prevent key event listeners firing more than once for the same state from a separate extender/flash event
local lastFiredEventFrom = {}

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
		OnInputChanged(eventName, evt.Press, evt.EventId, Input.Keys, Vars.ControllerEnabled)
		InvokeListenerCallbacks(Listeners.InputEvent, eventName, evt.Press, evt.EventId, Input.Keys, Vars.ControllerEnabled)
		InvokeListenerCallbacks(Listeners.NamedInputEvent[eventName], eventName, evt.Press, evt.EventId, Input.Keys, Vars.ControllerEnabled)

		if Ext.GetGameState() == "Running" then
			if not UIExtensions.MouseEnabled and evt.Press and eventName == "FlashLeftMouse" or eventName == "FlashRightMouse" then
				UIExtensions.Invoke("fireMouseClicked", eventName)
			end
		end
		lastFiredEventFrom[eventName] = 0
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
		OnInputChanged(eventName, pressed, id, Input.Keys, Vars.ControllerEnabled)
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
				OnInputChanged(v, false, id, Input.Keys, Vars.ControllerEnabled)
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
			OnInputChanged(v, false, id, Input.Keys, Vars.ControllerEnabled)
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