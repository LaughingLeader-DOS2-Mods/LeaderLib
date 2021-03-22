---@class UIExtensonsMain:FlashObject
---@field addCheckbox fun(id:number, label:string, tooltip:string, stateID:number|nil, x:number|nil, y:number|nil, filterBool:boolean|nil, enabled:boolean|nil):MovieClip
---@field removeControl fun(id:number):boolean

---@class LeaderLibUIExtensions:UIObject
---@field GetRoot fun():UIExtensonsMain

---@alias CheckboxCallback fun(ui:LeaderLibUIExtensions, controlType:string, id:number, state:number):void

UIExtensions = {
	---@type LeaderLibUIExtensions
	Instance = nil,
	Controls = {},
	Layer = 12,
	SwfPath = "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/LeaderLib_UIExtensions.swf"
}

local function OnControlAdded(ui, ...)
	print("OnControlAdded", Ext.JsonStringify({...}))
end

local function OnControl(ui, controlType, id, ...)
	local callback = UIExtensions.Controls[id]
	if callback and type(callback) == "function" then
		local b,err = xpcall(callback, debug.traceback, controlType, id, ...)
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
				local main = UIExtensions.Instance:GetRoot()
				if main then
					main.clearElements()
					main.controllerEnabled = Vars.ControllerEnabled
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

Ext.RegisterListener("SessionLoaded", function()
	SetupInstance()
	-- Ext.RegisterUINameInvokeListener("onEventUp", function(ui, ...)
	-- 	print(Ext.JsonStringify({...}))
	-- end)
end)

---@param onClick CheckboxCallback
---@param label string
---@param tooltip string
---@param state number The initial state, 0 or 1
---@param x number|nil
---@param y number|nil
---@param filterBool boolean|nil
---@param enabled boolean|nil
---@return number
function UIExtensions.AddCheckbox(onClick, label, tooltip, state, x, y, filterBool, enabled)
	SetupInstance()
	print("UIExtensions.AddCheckbox", onClick, label, tooltip, state, x, y, filterBool, enabled)
	local id = #UIExtensions.Controls
	local main = UIExtensions.Instance:GetRoot()
	if main then
		UIExtensions.Controls[id] = onClick or true
		main.addCheckbox(id, label, tooltip, state or 0, x or 0, y or 0, filterBool ~= nil and filterBool or false, enabled ~= nil and enabled or true)
		return id
	else
		Ext.PrintError("[LeaderLib:UIExtensions.AddCheckbox] Failed to get root of UIObject", UIExtensions.SwfPath)
	end
end

function UIExtensions.RemoveControl(id)
	if UIExtensions.Controls[id] ~= nil then
		UIExtensions.Controls[id] = nil
		if UIExtensions.Instance then
			local main = UIExtensions.Instance:GetRoot()
			main.removeControl(id)
		end
	end
end