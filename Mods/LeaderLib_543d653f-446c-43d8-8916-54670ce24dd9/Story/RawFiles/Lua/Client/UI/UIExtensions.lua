---@class UIExtensionsMain:FlashMainTimeline
---@field addCheckbox fun(id:number, label:string, tooltip:string, stateID:number|nil, x:number|nil, y:number|nil, filterBool:boolean|nil, enabled:boolean|nil):MovieClip
---@field removeControl fun(id:number):boolean
---@field addBar fun(id:number, label:string, tooltip:string|nil, x:number|nil, y:number|nil, percentage:number|nil, doTween:boolean|nil, color:number|nil):void

---@class LeaderLibUIExtensions:UIObject
---@field GetRoot fun():UIExtensionsMain

---@alias CheckboxCallback fun(ui:LeaderLibUIExtensions, controlType:string, id:number, state:number):void
---@alias FlashTimerCallback fun(timerName:string, isComplete:boolean):void

---@class UIExtensions
---@field Root UIExtensionsMain
UIExtensions = {
	---@type LeaderLibUIExtensions
	Instance = nil,
	Controls = {},
	---@type table<string, FlashTimerCallback[]>
	Timers = {},
	Layer = 18,
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
	},
	Visible = false
}

setmetatable(UIExtensions, {
	__index = function(tbl,k)
		if k == "Root" then
			local ui = UIExtensions.GetInstance()
			if ui then
				return ui:GetRoot()
			end
		end
	end
})

local function DestroyInstance(force)
	if UIExtensions.Instance then
		if force or Common.TableLength(UIExtensions.Controls, true) + Common.TableLength(UIExtensions.Timers, true) == 0 then
			UIExtensions.Instance:Invoke("dispose")
			UIExtensions.Instance:Hide()
			UIExtensions.Instance:Destroy()
			UIExtensions.Instance = nil
			UIExtensions.Visible = false
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

RegisterListener("LuaReset", function()
	UIExtensions.SetupInstance()
end)

Ext.RegisterConsoleCommand("llresetuiext", function(cmd)
	DestroyInstance(true)
end)

local function OnControlAdded(ui, call, id, listid, ...)
	PrintDebug("OnControlAdded", id, listid, Ext.JsonStringify({...}))
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
		if Vars.ControllerEnabled then
			----Needs to be less than 9
			UIExtensions.Layer = 7
		end
		UIExtensions.Instance = Ext.GetUI("LeaderLibUIExtensions")
		if not UIExtensions.Instance then
			print("Creating LeaderLibUIExtensions")
			UIExtensions.Instance = Ext.CreateUI("LeaderLibUIExtensions", UIExtensions.SwfPath, UIExtensions.Layer)
			UIExtensions.RegisteredListeners = false
			UIExtensions.Visible = true
		end
	end
	if UIExtensions.Instance then
		UIExtensions.Instance:Show()
		UIExtensions.Visible = true
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

local function SetVisibility(b)
	if Vars.DebugMode and UIExtensions.Visible ~= b then
		fprint(LOGLEVEL.DEFAULT, "[LeaderLib] UIExtensions.Visible (%s) => (%s)", UIExtensions.Visible, b)
	end
	if not b then
		if UIExtensions.Instance and UIExtensions.Visible then
			UIExtensions.Instance:Hide()
			UIExtensions.Visible = false
		end
	else
		if UIExtensions.Visible ~= true then
			UIExtensions.GetInstance():Show()
			UIExtensions.Visible = true
		end
	end
end

local registeredControllerListeners = false

Ext.RegisterListener("SessionLoaded", function()
	Vars.ControllerEnabled = (Ext.GetBuiltinUI("Public/Game/GUI/msgBox_c.swf") or Ext.GetUIByType(Data.UIType.msgBox_c)) ~= nil

	UIExtensions.SetupInstance()

	if Vars.ControllerEnabled and not registeredControllerListeners then
		Ext.RegisterUITypeInvokeListener(Data.UIType.areaInteract_c, "clearBtnHints", function()
			SetVisibility(false)
		end)
		Ext.RegisterUITypeInvokeListener(Data.UIType.gameMenu_c, "showWin", function()
			SetVisibility(false)
		end)
		Ext.RegisterUITypeInvokeListener(Data.UIType.gameMenu_c, "openMenu", function()
			SetVisibility(false)
		end)
		--Ext.RegisterUITypeCall(Data.UIType.areaInteract_c, "closeUI", function()
		Ext.RegisterUINameCall("hideUI", function()
			SetVisibility(true)
		end)
		Ext.RegisterUINameCall("closeUI", function()
			SetVisibility(true)
		end)
		Ext.RegisterUINameCall("requestCloseUI", function()
			SetVisibility(true)
		end)
		Ext.RegisterUITypeInvokeListener(Data.UIType.journal_csp, "setMapLegendHidden", function()
			SetVisibility(false)
		end)

		registeredControllerListeners = true
	end
end)

Ext.RegisterConsoleCommand("barTest", function()
	local ui = UIExtensions.GetInstance()
	if ui then
		local this = ui:GetRoot()
		if this then
			this.addBar("BeetusAdrenaline", "Adrenaline", "Is this working?", 100, 100, 0.5, true)
		end
	end
end)

Ext.RegisterConsoleCommand("panelTest", function()
	local this = UIExtensions.Root
	if this then
		local panel = this.panels_mc.panels[this.addDarkPanel("test", 100, 100)]
		if panel then
			panel.addText("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer eu nibh aliquam, lacinia tellus sed, imperdiet elit. Mauris ultricies nunc at tortor tristique porttitor. Nam orci est, varius iaculis laoreet vel, ultricies in nisi. Pellentesque nec scelerisque nisi. Ut molestie sagittis tempor. Sed tincidunt purus sit amet magna accumsan, ut sollicitudin felis elementum. Mauris posuere malesuada mattis. Duis maximus non massa eu sodales. Pellentesque nibh felis, pellentesque in mauris pretium, vulputate malesuada nunc. Maecenas eget lacinia ex. Integer nec dui vel massa gravida elementum eget nec massa. Aenean tincidunt non est a scelerisque. Nam eu enim mi.\n\nMauris molestie commodo leo quis ultrices. Quisque elementum felis et neque vestibulum scelerisque. Cras sodales felis lorem, vel tempus justo porttitor quis. Suspendisse potenti. Phasellus nisi leo, cursus sed lorem sit amet, semper consequat orci. Aliquam sagittis pellentesque libero et interdum. Sed iaculis facilisis velit, quis hendrerit libero dapibus auctor.\n\n<font color='#FFCC11'>Phasellus mi metus, congue a tincidunt eget, viverra ut lectus. Cras elit quam, fringilla in dui sit amet, tristique faucibus mauris. Ut bibendum rutrum sem, efficitur malesuada nunc euismod quis. Morbi eros leo, commodo quis aliquet eget, pretium sit amet diam. Nullam posuere augue vel ligula gravida fermentum. Proin a consequat risus. Integer ac ligula condimentum, pretium est ac, feugiat lorem. Sed suscipit ut neque vel facilisis. Nullam lobortis lacinia lacus a mattis. Maecenas eget mi fermentum, aliquet odio at, feugiat risus. Integer finibus vitae tortor sed tristique. Pellentesque pellentesque venenatis velit, sit amet euismod dui eleifend eget. Donec malesuada ex nisi, sit amet imperdiet ex scelerisque at.\n\nNulla eget dui sed nulla tempus interdum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Duis a lobortis lacus. Morbi neque nulla, rutrum sit amet leo ac, rutrum efficitur magna. Nulla odio nisi, dignissim a justo rutrum, malesuada eleifend lectus. Fusce nec cursus augue. Morbi at sem iaculis, eleifend libero vel, posuere velit.</font>\n\nMauris non justo nec justo congue laoreet. Maecenas porttitor magna at libero rhoncus bibendum. Phasellus vel sem cursus, semper erat quis, aliquet metus. Aenean quis metus egestas, ultrices velit in, molestie tellus. Etiam nec purus nec quam varius luctus. Nulla quis suscipit tellus, maximus accumsan felis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Sed viverra quis nisi sit amet luctus. Cras dapibus sodales mauris ut tristique. Aliquam orci purus, suscipit in porttitor nec, tincidunt eget lectus.")
			print(panel.list_id, panel.id)
		end
	end
end)
