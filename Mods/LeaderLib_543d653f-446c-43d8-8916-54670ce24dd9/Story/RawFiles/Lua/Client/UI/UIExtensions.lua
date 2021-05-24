---@class UIExtensonsMain:FlashMainTimeline
---@field addCheckbox fun(id:number, label:string, tooltip:string, stateID:number|nil, x:number|nil, y:number|nil, filterBool:boolean|nil, enabled:boolean|nil):MovieClip
---@field removeControl fun(id:number):boolean

---@class LeaderLibUIExtensions:UIObject
---@field GetRoot fun():UIExtensonsMain

---@alias CheckboxCallback fun(ui:LeaderLibUIExtensions, controlType:string, id:number, state:number):void
---@alias FlashTimerCallback fun(timerName:string, isComplete:boolean):void

UIExtensions = {
	---@type LeaderLibUIExtensions
	Instance = nil,
	Controls = {},
	---@type table<string, FlashTimerCallback[]>
	Timers = {},
	Layer = 10,
	SwfPath = "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/LeaderLib_UIExtensions.swf",
	Initialized = false,
	RegisteredListeners = false,
	---@class InputMouseEvent:table
	MouseEvent = {
		All = "All",
		Clicked = "Clicked",
		Moved = "Moved",
		RightMouseDown = "RightMouseDown",
		RightMouseUp = "RightMouseUp",
	}
}

local function DestroyInstance(force)
	if UIExtensions.Instance then
		if force or Common.TableLength(UIExtensions.Controls, true) + Common.TableLength(UIExtensions.Timers, true) == 0then
			UIExtensions.Instance:Invoke("dispose")
			UIExtensions.Instance:Hide()
			UIExtensions.Instance:Destroy()
			UIExtensions.Instance = nil
		end
	end
	UIExtensions.Controls = {}
	UIExtensions.Timers = {}
end

RegisterListener("BeforeLuaReset", function()
	if UIExtensions.Instance then
		DestroyInstance(true)
	end	
end)

if Vars.DebugMode then
	RegisterListener("LuaReset", function()
		UIExtensions.SetupInstance()
	
		if not Vars.ControllerEnabled then
			--Clears any unregistered missing abilities
			GameHelpers.UI.TryInvoke(Data.UIType.characterSheet, "clearAbilities")
			GameHelpers.UI.TryInvoke(Data.UIType.characterSheet, "clearTalents")
		end
	end)
end

Ext.RegisterConsoleCommand("llresetuiext", function(cmd)
	DestroyInstance(true)
end)

local function OnControlAdded(ui, call, id, listid, ...)
	print("OnControlAdded", id, listid, Ext.JsonStringify({...}))
end

local function OnTimerComplete(ui, call, timerCallbackName)
	--fprint(LOGLEVEL.DEFAULT, "[LeaderLib:UIExtensions.OnTimerComplete %s]", timerCallbackName)
	local callbacks = UIExtensions.Timers[timerCallbackName]
	if callbacks then
		for i,v in pairs(callbacks) do
			local b,result = xpcall(v, debug.traceback, timerCallbackName, true)
			if not b then
				Ext.PrintError(result)
			end
		end
	end
	UIExtensions.Timers[timerCallbackName] = nil
end

local function OnTimerTick(ui, call, timerCallbackName)
	--fprint(LOGLEVEL.DEFAULT, "[LeaderLib:UIExtensions.OnTimerTick %s]", timerCallbackName)
	local callbacks = UIExtensions.Timers[timerCallbackName]
	if callbacks then
		for i,v in pairs(callbacks) do
			local b,result = xpcall(v, debug.traceback, timerCallbackName, false)
			if not b then
				Ext.PrintError(result)
			end
		end
	end
end

local function OnControl(ui, call, controlType, id, ...)
	local callback = UIExtensions.Controls[id]
	if callback and type(callback) == "function" then
		local b,err = xpcall(callback, debug.traceback, ui, controlType, id, ...)
		if not b then
			Ext.Print(string.format("[LeaderLib] Error invoking UI control callback for id (%s):", id))
			Ext.Print(err)
		end
	end
end

--local function OnMouseMoved(ui, call, x, y, controlDown, altDOwn, shiftDown)
local function OnMouseMoved(ui, call, x, y)
	Input.OnMouseEvent(UIExtensions.MouseEvent.Moved)
end

local function OnMouseClicked(ui, call, x, y)
	Input.OnMouseEvent(UIExtensions.MouseEvent.Clicked)
end

local function OnRightMouseDown(ui, call, x, y)
	Input.OnMouseEvent(UIExtensions.MouseEvent.RightMouseDown)
end

local function OnRightMouseUp(ui, call, x, y)
	Input.OnMouseEvent(UIExtensions.MouseEvent.RightMouseUp)
end

function UIExtensions.SetupInstance()
	if not UIExtensions.Instance or UIExtensions.Instance:GetRoot() == nil then
		if not Vars.ControllerEnabled then
			UIExtensions.Layer = 18 -- May eat inputs
		else
			UIExtensions.Layer = 10
		end
		UIExtensions.Instance = Ext.GetUI("LeaderLibUIExtensions")
		if not UIExtensions.Instance then
			UIExtensions.Instance = Ext.CreateUI("LeaderLibUIExtensions", UIExtensions.SwfPath, UIExtensions.Layer)
			UIExtensions.RegisteredListeners = false
		end
	end
	if UIExtensions.Instance then
		UIExtensions.Instance:Show()
		if not UIExtensions.Initialized then
			local main = UIExtensions.Instance:GetRoot()
			if main then
				main.clearElements()
				main.controllerEnabled = Vars.ControllerEnabled
				main.isInCharacterCreation = SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION
				for i=0,#main.events-1 do
					if main.events[i] then
						local eventName = string.gsub(main.events[i], "IE ", "")
						Input.Keys[eventName] = false
					end
				end
				--main.enableKeyboardListeners()
				UIExtensions.Initialized = true
			else
				Ext.PrintError("[LeaderLib] Failed to GetRoot of UI:", UIExtensions.SwfPath)
			end
		end
		if not UIExtensions.RegisteredListeners then
			Ext.RegisterUICall(UIExtensions.Instance, "LeaderLib_UIExtensions_OnControl", OnControl)
			Ext.RegisterUICall(UIExtensions.Instance, "LeaderLib_UIExtensions_ControlAdded", OnControlAdded)
			Ext.RegisterUICall(UIExtensions.Instance, "LeaderLib_UIExtensions_InputEvent", Input.OnFlashEvent)
			Ext.RegisterUICall(UIExtensions.Instance, "LeaderLib_UIExtensions_TimerComplete", OnTimerComplete)
			Ext.RegisterUICall(UIExtensions.Instance, "LeaderLib_UIExtensions_TimerTick", OnTimerTick)
			Ext.RegisterUICall(UIExtensions.Instance, "LeaderLib_UIExtensions_MouseMoved", OnMouseMoved)
			Ext.RegisterUICall(UIExtensions.Instance, "LeaderLib_UIExtensions_MouseClicked", OnMouseClicked)
			Ext.RegisterUICall(UIExtensions.Instance, "LeaderLib_UIExtensions_RightMouseDown", OnRightMouseDown)
			Ext.RegisterUICall(UIExtensions.Instance, "LeaderLib_UIExtensions_RightMouseUp", OnRightMouseUp)
			Ext.RegisterUICall(UIExtensions.Instance, "LeaderLib_UIExtensions_KeyboardEvent", Input.OnKeyboardEvent)
			-- Ext.RegisterUINameCall("LeaderLib_UIExtensions_OnControl", OnControl)
			-- Ext.RegisterUINameCall("LeaderLib_UIExtensions_ControlAdded", OnControlAdded)
			-- Ext.RegisterUINameCall("LeaderLib_UIExtensions_InputEvent", Input.OnFlashEvent)
			-- Ext.RegisterUINameCall("LeaderLib_UIExtensions_TimerComplete", OnTimerComplete)
			-- Ext.RegisterUINameCall("LeaderLib_UIExtensions_TimerTick", OnTimerTick)
			-- Ext.RegisterUINameCall("LeaderLib_UIExtensions_MouseMoved", OnMouseMoved)
			-- Ext.RegisterUINameCall("LeaderLib_UIExtensions_MouseClicked", OnMouseClicked)
			-- Ext.RegisterUINameCall("LeaderLib_UIExtensions_RightMouseDown", OnRightMouseDown)
			-- Ext.RegisterUINameCall("LeaderLib_UIExtensions_RightMouseUp", OnRightMouseUp)
			-- Ext.RegisterUINameCall("LeaderLib_UIExtensions_KeyboardEvent", Input.OnKeyboardEvent)
			UIExtensions.RegisteredListeners = true
		end
	else
		Ext.PrintError("[LeaderLib] Failed to create UI:", UIExtensions.SwfPath)
	end
end

function UIExtensions.GetInstance()
	if not UIExtensions.Instance then
		UIExtensions.SetupInstance()
	end
	return UIExtensions.Instance
end

RegisterListener("ClientDataSynced", function(modData, sharedData)
	if UIExtensions.Instance then
		local main = UIExtensions.Instance:GetRoot()
		if main then
			main.controllerEnabled = Vars.ControllerEnabled
			main.isInCharacterCreation = sharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION
		end
	end
end)

-- Ext.RegisterListener("SessionLoaded", function()
-- 	--SetupInstance()
-- 	-- Ext.RegisterUINameInvokeListener("onEventUp", function(ui, ...)
-- 	-- 	print(Ext.JsonStringify({...}))
-- 	-- end)
-- end)

---Add a checkbox to LeaderLib's UIExtensions UI, which fits the screen.
---@param onClick CheckboxCallback The callback to invoke when the checkbox is clicked.
---@param label string
---@param tooltip string
---@param state number The initial state, 0 or 1 if filterBool is not true, otherwise 0-2.
---@param x number|nil
---@param y number|nil
---@param filterBool boolean|nil If true, the checkbox state progresses from 0-2 until it resets to 0 at > 2, otherwise it just toggles between 0 and 1.
---@param enabled boolean|nil
---@return integer Returns the ID of the checkbox created if successful.
function UIExtensions.AddCheckbox(onClick, label, tooltip, state, x, y, filterBool, enabled)
	UIExtensions.SetupInstance()
	local id = #UIExtensions.Controls
	local main = UIExtensions.Instance:GetRoot()
	if main then
		UIExtensions.Controls[id] = onClick or true
		if filterBool == nil then
			filterBool = false
		end
		if enabled == nil then
			enabled = true
		end
		main.addCheckbox(id, label, tooltip, state or 0, x or 0, y or 0, filterBool, enabled)
		return id
	else
		Ext.PrintError("[LeaderLib:UIExtensions.AddCheckbox] Failed to get root of UIObject", UIExtensions.SwfPath)
	end
end

---Removes a control with a specific ID.
---@param id integer
---@return boolean
function UIExtensions.RemoveControl(id)
	if UIExtensions.Controls[id] ~= nil then
		UIExtensions.Controls[id] = nil
		if UIExtensions.Instance then
			local main = UIExtensions.Instance:GetRoot()
			if main then
				main.removeControl(id)
				return true
			end
		end
	end
	return false
end

---Removes all controls and clears UIExtensions.Controls.
---@return boolean
function UIExtensions.RemoveAllControls()
	UIExtensions.Controls = {}
	if UIExtensions.Instance then
		UIExtensions.Instance:Invoke("clearElements")
		return true
	end
	return false
end

---@param id string The timer name/id.
---@param delay Number The delay of the timer in milliseconds.
---@param callbackFunction FlashTimerCallback The callback to invoke when the timer is complete, or when it ticks (if repeatTimer > 1).
---@param repeatTimer integer|nil The number of times to repeat the timer. If > 1 then the callback will be called each time the timer ticks.
function UIExtensions.StartTimer(id, delay, callbackFunction, repeatTimer)
	UIExtensions.SetupInstance()
	if UIExtensions.Timers[id] == nil then
		UIExtensions.Timers[id] = {}
	end
	if not Common.TableHasEntry(UIExtensions.Timers[id], callbackFunction) then
		table.insert(UIExtensions.Timers[id], callbackFunction)
		UIExtensions.Instance:Invoke("launchTimer", delay, id, repeatTimer or 1)
	end
end

function UIExtensions.RemoveTimerCallback(id, callbackFunction)
	if UIExtensions.Timers[id] then
		for i,v in pairs(UIExtensions.Timers[id]) do
			if v == callbackFunction then
				table.remove(UIExtensions.Timers[id], i)
			end
		end
	end
end

function UIExtensions.Invoke(method, ...)
	UIExtensions.SetupInstance()
	UIExtensions.Instance:Invoke(method, ...)
end

function UIExtensions.EnableMouseListeners(enabled)
	if enabled == nil then
		enabled = true
	end
	UIExtensions.SetupInstance()
	UIExtensions.Instance:Invoke("enableMouseListeners", enabled)
	UIExtensions.MouseEnabled = enabled
end

function UIExtensions.GetMousePosition()
	UIExtensions.SetupInstance()
	local main = UIExtensions.Instance:GetRoot()
	if main then
		local x = main.mouseX
		local y = main.mouseY
		if x < 0 or y < 0 then
			local ui = Ext.GetUIByType(Data.UIType.playerInfo) or Ext.GetBuiltinUI(Data.UIType.playerInfo_c)
			if ui then
				local root = ui:GetRoot()
				if root then
					x = root.mouseX
					y = root.mouseY
				end
			end
		end
		return x,y
	end
	return 0,0
end

function UIExtensions.GlobalToLocalPosition(x, y)
	UIExtensions.SetupInstance()
	local main = UIExtensions.Instance:GetRoot()
	if main then
		main.setGlobalToLocalPosition(x, y)
		return main.globalToLocalX,main.globalToLocalY
	end
	return 0,0
end

Ext.RegisterListener("SessionLoaded", UIExtensions.SetupInstance)