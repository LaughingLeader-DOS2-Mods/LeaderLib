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

Ext.RegisterListener("SessionLoaded", function()
	UIExtensions.Instance = Ext.GetUI("LeaderLibUIExtensions")
	if not UIExtensions.Instance then
		UIExtensions.Instance = Ext.CreateUI("LeaderLibUIExtensions", UIExtensions.SwfPath, UIExtensions.Layer)
		Ext.RegisterUICall(UIExtensions.Instance, "LeaderLib_OnControl", OnControl)
	end
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
	local id = #UIExtensions.Controls
	UIExtensions.Controls[id] = onClick or true
	local main = UIExtensions.Instance:GetRoot()
	main.addCheckbox(id, label, tooltip, state or 0, x or 0, y or 0, filterBool ~= nil and filterBool or false, enabled ~= nil and enabled or true)
	return id
end

function UIExtensions.RemoveControl(id)
	if UIExtensions.Controls[id] ~= nil then
		UIExtensions.Controls[id] = nil
		local main = UIExtensions.Instance:GetRoot()
		main.removeControl(id)
	end
end