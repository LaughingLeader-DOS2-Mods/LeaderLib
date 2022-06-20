---@alias UIListenerContext string|"Before"|"After"

---@class UIWrapperCallbackEntry
---@field Callback UIWrapperCallbackHandler
---@field Type string
---@field Context UIListenerContext

---@class LeaderLibUIWrapper
---@field Root FlashMainTimeline
---@field Instance UIObject
---@field Visible boolean
local UIWrapper = {
	Type = "UIWrapper",
	Name = "",
	ID = -1,
	Path = "",
	IsControllerSupported = false,
	ControllerID = -1,
	ControllerPath = "",
	Callbacks = {
		---@type table<string, UIWrapperCallbackEntry[]>
		Invoke = {},
		---@type table<string, UIWrapperCallbackEntry[]>
		Call = {}
	}
}

local _EXTVERSION = Ext.Version()

---@type table<integer,LeaderLibUIWrapper[]>
local _uiWrappers = {}

---@return LeaderLibUIWrapper
local function CreateWrapper(...)
	local params = {...}
	if #params > 0 then
		local t = type(params[1])
		if t == "number" then
			return UIWrapper:CreateFromType(...)
		elseif t == "string" then
			return UIWrapper:CreateFromPath(...)
		end
	end
	error("UIWrapper requires an integer id or path string as the first parameter!", 2)
end
setmetatable(UIWrapper, {
	__call = CreateWrapper
})

local function SetMeta(this)
	setmetatable(this, {
		__index = function(tbl,k)
			if UIWrapper[k] then
				return UIWrapper[k]
			end
			if k == "Instance" then
				return UIWrapper.GetInstance(this)
			elseif k == "Root" then
				local ui = UIWrapper.GetInstance(this)
				if ui then
					return ui:GetRoot()
				end
			elseif k == "Visible" then
				local ui = UIWrapper.GetInstance(this)
				if ui then
					if _EXTVERSION >= 56 then
						---@diagnostic disable-next-line undefined-field
						return Common.TableHasValue(ui.Flags, "OF_Visible")
					else
						return true
					end
				end
				return false
			end
		end
	})
end

---@param id integer
---@param params LeaderLibUIWrapper
---@return LeaderLibUIWrapper
function UIWrapper:CreateFromType(id, params)
	local this = {
		ID = id,
		Name = Data.UITypeToName[id] or "",
		Path = "",
		Callbacks = {
			Invoke = {},
			Call = {}
		}
	}
	if params then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	SetMeta(this)
	local ui = Ext.GetUIByType(id) or Ext.GetUIByType(this.ControllerID)
	if ui then
		ui:CaptureExternalInterfaceCalls()
		ui:CaptureInvokes()
	end
	if _uiWrappers[id] == nil then
		_uiWrappers[id] = {}
	end
	table.insert(_uiWrappers[id], this)
	return this
end

local function CanInvokeCallback(data, uiType, eventType)
	return data.Type == uiType and data.Context == eventType
end

---@param path string
---@param params LeaderLibUIWrapper
---@return LeaderLibUIWrapper
function UIWrapper:CreateFromPath(path, params)
	local this = {
		ID = -1,
		Name = "",
		Path = path,
		Callbacks = {
			Invoke = {},
			Call = {}
		}
	}
	if params then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	local ui = Ext.GetBuiltinUI(path)
	if ui then
		this.ID = ui:GetTypeId()
		this.Name = Data.UITypeToName[this.ID]
		ui:CaptureExternalInterfaceCalls()
		ui:CaptureInvokes()
	end
	SetMeta(this)
	return this
end

---@alias UIWrapperEventContextType string|'"Keyboard"'|'"Controller"'|'"All"'
---@alias UIWrapperCallbackHandler fun(self:LeaderLibUIWrapper, ui:UIObject, event:string, vararg):void

function UIWrapper:InvokeCallbacks(callbackType, e, ui, event, eventType, args)
	if not self.Callbacks[callbackType] then
		error(string.format("Invalid callback type %s", callbackType))
	end
	local callbacks = self.Callbacks[callbackType][event]
	if callbacks then
		local len = #callbacks
		for i=1,len do
			local callbackData = callbacks[i]
			if CanInvokeCallback(callbackData, ui.Type, eventType) then
				local result = {xpcall(callbackData.Callback, debug.traceback, self, ui, event, table.unpack(args))}
				if result[1] then
					local b,preventAction,stopPropagation = table.unpack(result)
					if preventAction then
						e:PreventAction()
					end
					if stopPropagation then
						e:StopPropagation()
					end
				else
					Ext.PrintError(result[2])
				end
			end
		end
	end
end

---@param event string The method name.
---@param callback UIWrapperCallbackHandler
---@param eventType UICallbackEventType|nil
---@param uiContext UIWrapperEventContextType|nil
function UIWrapper:RegisterInvokeListener(event, callback, eventType, uiContext)
	if self.ID ~= -1 and uiContext ~= "Controller" then
		if self.Callbacks.Invoke[event] == nil then
			self.Callbacks.Invoke[event] = {}
		end
		table.insert(self.Callbacks.Invoke[event], {
			Callback = callback,
			Type = self.ID,
			Context = eventType or "After"
		})
		-- Ext.RegisterUITypeInvokeListener(self.ID, event, function(...)
		-- 	local b,err = xpcall(callback, debug.traceback, self, ...)
		-- 	if not b then
		-- 		fprint(LOGLEVEL.ERROR, "[UIWrapper(%s):InvokeListener] Error:%s", self.ID, err)
		-- 		error(err, 2)
		-- 	end
		-- end, eventType)
	end
	if self.ControllerID ~= -1 and (uiContext == "Controller" or uiContext == "All") then
		if self.Callbacks.Invoke[event] == nil then
			self.Callbacks.Invoke[event] = {}
		end
		table.insert(self.Callbacks.Invoke[event], {
			Callback = callback,
			Type = self.ControllerID,
			Context = eventType or "After"
		})
		-- Ext.RegisterUITypeInvokeListener(self.ControllerID, event, function(...)
		-- 	local b,err = xpcall(callback, debug.traceback, self, ...)
		-- 	if not b then
		-- 		fprint(LOGLEVEL.ERROR, "[UIWrapper(%s):InvokeListener] Error:%s", self.ControllerID, err)
		-- 		error(err, 2)
		-- 	end
		-- end, eventType)
	end
end

---@param event string The ExternalInterface.call name.
---@param callback UIWrapperCallbackHandler
---@param eventType UICallbackEventType
---@param uiContext UIWrapperEventContextType
function UIWrapper:RegisterCallListener(event, callback, eventType, uiContext)
	if self.ID ~= -1 and uiContext ~= "Controller" then
		if self.Callbacks.Call[event] == nil then
			self.Callbacks.Call[event] = {}
		end
		table.insert(self.Callbacks.Call[event], {
			Callback = callback,
			Type = self.ID,
			Context = eventType or "After"
		})
		-- Ext.RegisterUITypeCall(self.ID, event, function(...)
		-- 	local b,err = xpcall(callback, debug.traceback, self, ...)
		-- 	if not b then
		-- 		fprint(LOGLEVEL.ERROR, "[UIWrapper(%s):CallListener] Error:%s", self.ID, err)
		-- 		error(err, 2)
		-- 	end
		-- end, eventType)
	end
	if self.ControllerID ~= -1 and (uiContext == "Controller" or uiContext == "All") then
		if self.Callbacks.Call[event] == nil then
			self.Callbacks.Call[event] = {}
		end
		table.insert(self.Callbacks.Call[event], {
			Callback = callback,
			Type = self.ControllerID,
			Context = eventType or "After"
		})
		-- Ext.RegisterUITypeCall(self.ControllerID, event, function(...)
		-- 	local b,err = xpcall(callback, debug.traceback, self, ...)
		-- 	if not b then
		-- 		fprint(LOGLEVEL.ERROR, "[UIWrapper(%s):CallListener] Error:%s", self.ControllerID, err)
		-- 		error(err, 2)
		-- 	end
		-- end, eventType)
	end
end

---@return UIObject
function UIWrapper:GetInstance()
	if self.IsControllerSupported and Vars.ControllerEnabled then
		if self.ControllerID ~= -1 then
			self.Name = Data.UITypeToName[self.ControllerID]
			return Ext.GetUIByType(self.ControllerID)
		elseif not StringHelpers.IsNullOrWhitespace(self.ControllerPath) then
			local ui = Ext.GetBuiltinUI(self.ControllerPath)
			if ui then
				self.ControllerID = ui:GetTypeId()
				self.Name = Data.UITypeToName[self.ControllerID]
				return ui
			end
		end
	else
		if self.ID ~= -1 then
			--self.Name = Data.UITypeToName[self.ID]
			return Ext.GetUIByType(self.ID)
		elseif not StringHelpers.IsNullOrWhitespace(self.Path) then
			local ui = Ext.GetBuiltinUI(self.Path)
			if ui then
				self.ID = ui:GetTypeId()
				self.Name = Data.UITypeToName[self.ID]
				return ui
			end
		end
	end
end

---@return FlashMainTimeline
function UIWrapper:GetRoot()
	local ui = self:GetInstance()
	if ui then
		return ui:GetRoot()
	end
end

---@param call string
---@vararg any
function UIWrapper:ExternalInterfaceCall(call, ...)
	local ui = self:GetInstance()
	if ui then
		ui:ExternalInterfaceCall(call, ...)
	end
end

---@param method string
---@vararg any
function UIWrapper:Invoke(method, ...)
	local root = self:GetRoot()
	if root then
		local func = root[method]
		if func then
			local b,err = xpcall(func, debug.traceback, ...)
			if not b then
				Ext.PrintError(err)
			end
		else
			fprint(LOGLEVEL.ERROR, "[UIWrapper:%s] Flash method (%s) does not exist!", self.Name, method)
		end
	end
end

if _EXTVERSION >= 56 then
	---@diagnostic disable-next-line undefined-field
	Ext.Events.UIInvoke:Subscribe(function (e)
		local wrappers = _uiWrappers[e.UI.Type]
		if wrappers then
			local len = #wrappers
			for i=1,len do
				wrappers[i]:InvokeCallbacks("Invoke", e, e.UI, e.Function, e.When, e.Args)
			end
		end
	end)

	---@diagnostic disable-next-line undefined-field
	Ext.Events.UICall:Subscribe(function (e)
		local wrappers = _uiWrappers[e.UI.Type]
		if wrappers then
			local len = #wrappers
			for i=1,len do
				wrappers[i]:InvokeCallbacks("Call", e, e.UI, e.Function, e.When, e.Args)
			end
		end
	end)
end

Classes.UIWrapper = UIWrapper