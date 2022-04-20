---@class UIExtensionsMain:FlashMainTimeline
---@field addCheckbox fun(id:number, label:string, tooltip:string, stateID:number|nil, x:number|nil, y:number|nil, filterBool:boolean|nil, enabled:boolean|nil):FlashMovieClip
---@field removeControl fun(id:number):boolean
---@field addBar fun(id:number, label:string, tooltip:string|nil, x:number|nil, y:number|nil, percentage:number|nil, doTween:boolean|nil, color:number|nil):void

---@class LeaderLibUIExtensions:UIObject
---@field GetRoot fun():UIExtensionsMain

---@alias CheckboxCallback fun(ui:LeaderLibUIExtensions, controlType:string, id:number, state:number):void
---@alias LeaderLibDropdownCallback fun(ui:LeaderLibUIExtensions, controlType:string, id:number, selectedIndex:number):void
---@alias FlashTimerCallback fun(timerName:string, isComplete:boolean):void

---@class UIExtensions
---@field Root UIExtensionsMain
---@field Instance LeaderLibUIExtensions
UIExtensions = {
	Controls = {},
	---@type table<string, FlashTimerCallback[]>
	Timers = {},
	Layer = 18,
	ID = "LeaderLibUIExtensions",
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
	MouseEnabled = false,
	Visible = false
}

local _EXTVERSION = Ext.Version()

setmetatable(UIExtensions, {
	__index = function(tbl,k)
		if k == "Root" then
			local ui = UIExtensions.GetInstance()
			if ui then
				return ui:GetRoot()
			end
		elseif k == "Instance" then
			local ui = UIExtensions.GetInstance()
			if ui then
				return ui
			end
		end
	end
})

local function DestroyInstance(force)
	local instance = UIExtensions.GetInstance(true)
	if instance then
		if force or Common.TableLength(UIExtensions.Controls, true) + Common.TableLength(UIExtensions.Timers, true) == 0 then
			instance:Invoke("dispose")
			instance:Hide()
			instance:Destroy()
			UIExtensions.Visible = false
		end
	end
	UIExtensions.Controls = {}
	UIExtensions.Timers = {}
end

RegisterListener("BeforeLuaReset", function()
	UI.ContextMenu:ClearCustomIcons()
	DestroyInstance(true)
end)

RegisterListener("LuaReset", function()
	UIExtensions.SetupInstance()
end)

Ext.RegisterConsoleCommand("llresetuiext", function(cmd)
	DestroyInstance(true)
end)

local function OnControlAdded(ui, call, controlType, id, index, ...)
	fprint(LOGLEVEL.TRACE, "[UIExtensions:%s] controlType(%s) id(%s) index(%s)", call, controlType, id, index)
	local main = ui:GetRoot()
	if main then
		local control = main.mainPanel_mc.elements[index]
		InvokeListenerCallbacks(Listeners.UIExtensionsControlAdded, main, control, id, index, ...)
	end
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

local justResized = false

---@param ui UIObject
local function OnResolution(ui, call, w, h)
	-- if not justResized and _EXTVERSION >= 56 and SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION then
	-- 	--ui:ExternalInterfaceCall("setPosition",this.anchorPos,this.anchorTarget,this.anchorPos);
	-- 	UIExtensions.ResizeToUI(Ext.GetUIByType(Vars.ControllerEnabled and Data.UIType.characterCreation_c or Data.UIType.characterCreation))
	-- end
	-- if w == nil then
	-- 	if _EXTVERSION >= 56 then
	-- 		w,h = table.unpack(ui.FlashMovieSize)
	-- 		print(call, w,h)
	-- 		local this = UIExtensions.Root
	-- 		if this then
	-- 			this.OnRes(w,h)
	-- 		end
	-- 	end
	-- else
	-- 	print(call, w, h)
	-- end
	-- if not justResized then
	-- 	justResized = true
	-- 	ui:Resize(1920, 1080)
	-- else
	-- 	justResized = false
	-- end
	InvokeListenerCallbacks(Listeners.UIExtensionsResized, ui, w, h)
end

--local defaultUIFlags = Data.DefaultUIFlags | Data.UIFlags.OF_FullScreen | Data.UIFlags.OF_KeepInScreen
local defaultUIFlags = Data.DefaultUIFlags

function UIExtensions.SetupInstance(skipCheck)
	-- if Ext.GetGameState() == "Menu" then
	-- 	Ext.PrintError("[UIExtensions.SetupInstance] Game not ready yet.")
	-- end
	local instance = nil
	if not skipCheck then
		instance = Ext.GetUI(UIExtensions.ID) or Ext.GetBuiltinUI(UIExtensions.SwfPath)
	end
	if not instance then
		if Vars.ControllerEnabled then
			----Needs to be less than 9
			UIExtensions.Layer = 7
		end
		if Vars.DebugMode and not Vars.ControllerEnabled then
			instance = Ext.CreateUI(UIExtensions.ID, UIExtensions.SwfPath, UIExtensions.Layer, defaultUIFlags)
		else
			instance = Ext.CreateUI(UIExtensions.ID, UIExtensions.SwfPath, UIExtensions.Layer)
		end
		UIExtensions.RegisteredListeners = false
		UIExtensions.Visible = true
	end
	if instance then
		instance:Show()
		UIExtensions.Visible = true
		if not UIExtensions.Initialized then
			local main = instance:GetRoot()
			if main then
				main.autoPosition = Ext.Version() < 56
				main.clearElements()
				main.controllerEnabled = Vars.ControllerEnabled
				main.isInCharacterCreation = SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION
				for i=0,#main.events-1 do
					if main.events[i] then
						local eventName = string.gsub(main.events[i], "IE ", "")
						Input.Keys[eventName] = false
					end
				end
				main.enableKeyboardListeners()
				UIExtensions.Initialized = true
			else
				Ext.PrintError("[LeaderLib] Failed to GetRoot of UI:", UIExtensions.SwfPath)
			end
		end
		if not UIExtensions.RegisteredListeners then
			Ext.RegisterUICall(instance, "LeaderLib_UIExtensions_OnControl", OnControl)
			Ext.RegisterUICall(instance, "LeaderLib_UIExtensions_ControlAdded", OnControlAdded)
			Ext.RegisterUICall(instance, "LeaderLib_UIExtensions_InputEvent", Input.OnFlashEvent)
			Ext.RegisterUICall(instance, "LeaderLib_UIExtensions_TimerComplete", OnTimerComplete)
			Ext.RegisterUICall(instance, "LeaderLib_UIExtensions_TimerTick", OnTimerTick)
			Ext.RegisterUICall(instance, "LeaderLib_UIExtensions_MouseMoved", OnMouseMoved)
			Ext.RegisterUICall(instance, "LeaderLib_UIExtensions_MouseClicked", OnMouseClicked)
			Ext.RegisterUICall(instance, "LeaderLib_UIExtensions_RightMouseDown", OnRightMouseDown)
			Ext.RegisterUICall(instance, "LeaderLib_UIExtensions_RightMouseUp", OnRightMouseUp)
			Ext.RegisterUICall(instance, "LeaderLib_UIExtensions_KeyboardEvent", Input.OnKeyboardEvent)
			Ext.RegisterUICall(instance, "LeaderLib_UIExtensions_SetModifierKeys", Input.UpdateModifierKeys)
			Ext.RegisterUICall(instance, "LeaderLib_UIExtensions_OnEventResolution", OnResolution)
			Ext.RegisterUICall(instance, "LeaderLib_UIExtensions_OnEventResize", OnResolution)
			Ext.RegisterUICall(instance, "LeaderLib_UIAssert", function (ui, call, msg)
				if Vars.DebugMode then
					Ext.PrintWarning(msg)
				end
			end)
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

function UIExtensions.GetInstance(skipSetup)
	local instance = Ext.GetUI(UIExtensions.ID) or Ext.GetBuiltinUI(UIExtensions.SwfPath)
	if not instance and not skipSetup then
		instance = UIExtensions.SetupInstance(true)
	end
	return instance
end

RegisterListener("ClientDataSynced", function(modData, sharedData)
	local main = UIExtensions.Root
	if main then
		main.controllerEnabled = Vars.ControllerEnabled
		main.isInCharacterCreation = sharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION
	end
end)

-- Ext.RegisterListener("SessionLoaded", function()
-- 	--SetupInstance()
-- 	-- Ext.RegisterUINameInvokeListener("onEventUp", function(ui, ...)
-- 	-- 	print(Common.JsonStringify({...}))
-- 	-- end)
-- end)

---Add a checkbox to LeaderLib's UIExtensions UI.
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
	local main = UIExtensions.Root
	if main then
		UIExtensions.Controls[id] = onClick or true
		if filterBool == nil then
			filterBool = false
		end
		if enabled == nil then
			enabled = true
		end
		local index = main.addCheckbox(id, label, tooltip, state or 0, x or 0, y or 0, filterBool, enabled)
		return id,index
	else
		Ext.PrintError("[LeaderLib:UIExtensions.AddCheckbox] Failed to get root of UIObject", UIExtensions.SwfPath)
	end
end

---@class LeaderLibUIExtensionsDropdownTextSettings
---@field Label string
---@field Dropdown string
---@field Tooltip string

---@class LeaderLibUIExtensionsDropdownEntry
---@field Label string
---@field ID number

---Add a dropdown to LeaderLib's UIExtensions UI.
---@param onChange LeaderLibDropdownCallback The callback to invoke when the selection changes.
---@param x number
---@param y number
---@param text LeaderLibUIExtensionsDropdownTextSettings
---@param entries LeaderLibUIExtensionsDropdownEntry[]
---@return integer
function UIExtensions.AddDropdown(onChange, x, y, text, entries)
	UIExtensions.SetupInstance()
	local id = #UIExtensions.Controls
	local main = UIExtensions.Root
	if main then
		UIExtensions.Controls[id] = onChange or true
		local dropdownText = ""
		local topLabelText = ""
		local tooltipText = ""
		if type(text) == "table" then
			dropdownText = text.Dropdown or ""
			topLabelText = text.Label or ""
			tooltipText = text.Tooltip or ""
		end
		local index = main.dropdowns_mc.add(id, x, y, dropdownText, topLabelText, tooltipText)
		local dropdown_mc = main.dropdowns_mc.entries[index];
		Ext.PrintError(index, dropdown_mc)
		if dropdown_mc and type(entries) == "table" then
			for i=1,#entries do
				local entry = entries[i]
				dropdown_mc.addEntry(entry.Label, entry.ID);
			end
		end
		return dropdown_mc,id,index
	else
		Ext.PrintError("[LeaderLib:UIExtensions.AddCheckbox] Failed to get root of UIObject", UIExtensions.SwfPath)
	end
end

---Removes a control with a specific ID.
---@param id integer
---@return boolean
function UIExtensions.RemoveControl(id)
	UIExtensions.Controls[id] = nil
	local main = UIExtensions.Root
	if main then
		return main.removeControl(id) == true
	end
	return false
end

---Removes all controls and clears UIExtensions.Controls.
---@return boolean
function UIExtensions.RemoveAllControls()
	UIExtensions.Controls = {}
	local main = UIExtensions.Root
	if main then
		main.clearElements()
		return true
	end
	return false
end

---@param id string The timer name/id.
---@param delay number The delay of the timer in milliseconds.
---@param callbackFunction FlashTimerCallback The callback to invoke when the timer is complete, or when it ticks (if repeatTimer > 1).
---@param repeatTimer integer|nil The number of times to repeat the timer. If > 1 then the callback will be called each time the timer ticks.
function UIExtensions.StartTimer(id, delay, callbackFunction, repeatTimer)
	if UIExtensions.Timers[id] == nil then
		UIExtensions.Timers[id] = {}
	end
	if not Common.TableHasEntry(UIExtensions.Timers[id], callbackFunction) then
		table.insert(UIExtensions.Timers[id], callbackFunction)
		UIExtensions.Invoke("launchTimer", delay, id, repeatTimer or 1)
	end
end

function UIExtensions.RemoveTimerCallback(id, callbackFunction)
	if UIExtensions.Timers[id] then
		for i,v in pairs(UIExtensions.Timers[id]) do
			if not callbackFunction or v == callbackFunction then
				table.remove(UIExtensions.Timers[id], i)
			end
		end
	end
end

function UIExtensions.Invoke(method, ...)
	local instance = UIExtensions.GetInstance()
	if instance then
		instance:Invoke(method, ...)
	end
end

function UIExtensions.EnableMouseListeners(enabled)
	if enabled == nil then
		enabled = true
	end
	local main = UIExtensions.Root
	if main then
		main.enableMouseListeners(enabled)
		UIExtensions.MouseEnabled = enabled
	else
		UIExtensions.MouseEnabled = false
	end
end

function UIExtensions.GetMousePosition()
	local main = UIExtensions.Root
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
	local main = UIExtensions.Root
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
	local instance = UIExtensions.GetInstance()
	if not b then
		if instance then
			Classes.UIObjectExtended.Hide(UIExtensions, instance)
		end
		UIExtensions.Visible = false
	else
		if UIExtensions.Visible ~= true then
			if instance then
				Classes.UIObjectExtended.Show(UIExtensions, instance)
			end
		end
		UIExtensions.Visible = true
	end
end

function UIExtensions.ResetSize()
	local inst = UIExtensions.Instance
	if inst then
		inst.MovieLayout = 6
		inst.AnchorPos = "topleft"
		inst.AnchorTPos = "topleft"
		inst.AnchorTarget = "screen"
		local this = inst:GetRoot()
		this.layout = "fillVFit"
		this.anchorPos = "topleft"
		this.anchorTPos = "topleft"
		this.anchorTarget = "screen"
		--inst:ExternalInterfaceCall("setAnchor", this.anchorPos, this.anchorTarget, this.anchorPos)
		justResized = true
		inst:Resize(1920, 1080)
	end
end

---@param targetUIObject UIObject
function UIExtensions.ResizeToUI(targetUIObject)
	local extInst = UIExtensions.Instance
	local extRoot = extInst:GetRoot()
	local targetRoot = targetUIObject:GetRoot()
	if targetRoot then
		if not StringHelpers.IsNullOrEmpty(targetRoot.layout) then
			extRoot.layout = targetRoot.layout
		end
		if not StringHelpers.IsNullOrEmpty(targetRoot.alignment) then
			extRoot.alignment = targetRoot.alignment
		end

		extRoot.anchorPos = targetUIObject.AnchorPos
		extRoot.anchorTarget = targetUIObject.AnchorTarget
		extRoot.anchorTPos = targetUIObject.AnchorTPos
		--extInst:ExternalInterfaceCall("setAnchor", extRoot.anchorPos, extRoot.anchorTarget, extRoot.anchorPos)

		local w,h = table.unpack(targetUIObject.FlashMovieSize)

		extInst.MovieLayout = targetUIObject.MovieLayout
		extInst.AnchorPos = targetUIObject.AnchorPos
		extInst.AnchorTPos = targetUIObject.AnchorTPos
		extInst.AnchorTarget = targetUIObject.AnchorTarget
		
		justResized = true
		extInst:Resize(w, h)

		-- if Vars.LeaderDebugMode then
		-- 	Ext.SaveFile("Dumps/UIExtensions.json", Ext.DumpExport({
		-- 		TargetWidth = w,
		-- 		TargetHeight = h,
		-- 		GetUIScaleMultiplier = extInst:GetUIScaleMultiplier(),
		-- 		CC_GetUIScaleMultiplier = targetUIObject:GetUIScaleMultiplier(),
		-- 		ZZCC = targetUIObject,
		-- 		UIExtensions = extInst,
		-- 	}))
		-- end
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

Ext.RegisterConsoleCommand("panelTest", function()
	local this = UIExtensions.Root
	if this then
		local panel = this.panels_mc.panels[this.addDarkPanel("test", 100, 100, "Test Text")]
		if panel then
			panel.addText("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer eu nibh aliquam, lacinia tellus sed, imperdiet elit. Mauris ultricies nunc at tortor tristique porttitor. Nam orci est, varius iaculis laoreet vel, ultricies in nisi. Pellentesque nec scelerisque nisi. Ut molestie sagittis tempor. Sed tincidunt purus sit amet magna accumsan, ut sollicitudin felis elementum. Mauris posuere malesuada mattis. Duis maximus non massa eu sodales. Pellentesque nibh felis, pellentesque in mauris pretium, vulputate malesuada nunc. Maecenas eget lacinia ex. Integer nec dui vel massa gravida elementum eget nec massa. Aenean tincidunt non est a scelerisque. Nam eu enim mi.\n\nMauris molestie commodo leo quis ultrices. Quisque elementum felis et neque vestibulum scelerisque. Cras sodales felis lorem, vel tempus justo porttitor quis. Suspendisse potenti. Phasellus nisi leo, cursus sed lorem sit amet, semper consequat orci. Aliquam sagittis pellentesque libero et interdum. Sed iaculis facilisis velit, quis hendrerit libero dapibus auctor.\n\n<font color='#FFCC11'>Phasellus mi metus, congue a tincidunt eget, viverra ut lectus. Cras elit quam, fringilla in dui sit amet, tristique faucibus mauris. Ut bibendum rutrum sem, efficitur malesuada nunc euismod quis. Morbi eros leo, commodo quis aliquet eget, pretium sit amet diam. Nullam posuere augue vel ligula gravida fermentum. Proin a consequat risus. Integer ac ligula condimentum, pretium est ac, feugiat lorem. Sed suscipit ut neque vel facilisis. Nullam lobortis lacinia lacus a mattis. Maecenas eget mi fermentum, aliquet odio at, feugiat risus. Integer finibus vitae tortor sed tristique. Pellentesque pellentesque venenatis velit, sit amet euismod dui eleifend eget. Donec malesuada ex nisi, sit amet imperdiet ex scelerisque at.\n\nNulla eget dui sed nulla tempus interdum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Duis a lobortis lacus. Morbi neque nulla, rutrum sit amet leo ac, rutrum efficitur magna. Nulla odio nisi, dignissim a justo rutrum, malesuada eleifend lectus. Fusce nec cursus augue. Morbi at sem iaculis, eleifend libero vel, posuere velit.</font>\n\nMauris non justo nec justo congue laoreet. Maecenas porttitor magna at libero rhoncus bibendum. Phasellus vel sem cursus, semper erat quis, aliquet metus. Aenean quis metus egestas, ultrices velit in, molestie tellus. Etiam nec purus nec quam varius luctus. Nulla quis suscipit tellus, maximus accumsan felis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Sed viverra quis nisi sit amet luctus. Cras dapibus sodales mauris ut tristique. Aliquam orci purus, suscipit in porttitor nec, tincidunt eget lectus.")
		end
	end
end)
