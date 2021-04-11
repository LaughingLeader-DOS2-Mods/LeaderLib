---@class UIExtensonsMain:FlashObject
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
	Layer = 12,
	SwfPath = "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/LeaderLib_UIExtensions.swf"
}

local function DestroyInstance(force)
	if UIExtensions.Instance then
		if force or Common.TableLength(UIExtensions.Controls, true) + Common.TableLength(UIExtensions.Timers, true) == 0then
			UIExtensions.Instance:Invoke("destroyTimers")
			UIExtensions.Instance:Hide()
			UIExtensions.Instance:Destroy()
			UIExtensions.Instance = nil
		end
	end
	UIExtensions.Controls = {}
	UIExtensions.Timers = {}
end

RegisterListener("LuaReset", function()
	UIExtensions.Instance = Ext.GetUI("LeaderLibUIExtensions")
	if UIExtensions.Instance then
		DestroyInstance(true)
	end
end)

Ext.RegisterConsoleCommand("llresetuiext", function(cmd)
	DestroyInstance(true)
end)

local function OnControlAdded(ui, call, ...)
	--print("OnControlAdded", Ext.JsonStringify({...}))
end

local function OnTimerComplete(ui, call, timerCallbackName)
	fprint(LOGLEVEL.WARNING, "[LeaderLib:UIExtensions.OnTimerComplete %s]", timerCallbackName)
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
	fprint(LOGLEVEL.WARNING, "[LeaderLib:UIExtensions.OnTimerTick %s]", timerCallbackName)
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

local function SetupInstance()
	if not UIExtensions.Instance then
		UIExtensions.Instance = Ext.GetUI("LeaderLibUIExtensions")
		if not UIExtensions.Instance then
			UIExtensions.Instance = Ext.CreateUI("LeaderLibUIExtensions", UIExtensions.SwfPath, UIExtensions.Layer)
			if UIExtensions.Instance then
				Ext.RegisterUICall(UIExtensions.Instance, "LeaderLib_OnControl", OnControl)
				Ext.RegisterUICall(UIExtensions.Instance, "LeaderLib_ControlAdded", OnControlAdded)
				Ext.RegisterUICall(UIExtensions.Instance, "LeaderLib_InputEvent", Input.OnFlashEvent)
				Ext.RegisterUICall(UIExtensions.Instance, "LeaderLib_TimerComplete", OnTimerComplete)
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
				else
					Ext.PrintError("[LeaderLib] Failed to GetRoot of UI:", UIExtensions.SwfPath)
				end
			else
				Ext.PrintError("[LeaderLib] Failed to create UI:", UIExtensions.SwfPath)
			end
		end
	end
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
	SetupInstance()
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
	SetupInstance()
	if UIExtensions.Timers[id] == nil then
		UIExtensions.Timers[id] = {}
	end
	table.insert(UIExtensions.Timers[id], callbackFunction)
	UIExtensions.Instance:Invoke("launchTimer", delay, id, repeatTimer or 1)
end