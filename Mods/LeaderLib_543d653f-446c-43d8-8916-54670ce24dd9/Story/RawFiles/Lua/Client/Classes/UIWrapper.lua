local _PrintError = Ext.Utils.PrintError
local xpcall = xpcall
local type = type
local _debugtraceback = debug.traceback

---@type LeaderLibUIWrapper[]
local _uiVisibilityArray = {}

---@type table<integer,LeaderLibUIWrapper[]>
local _uiTypeWrappers = {}
---@type table<string,LeaderLibUIWrapper[]>
local _uiPathWrappers = {}

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
		Call = {},
		---@type fun(self:LeaderLibUIWrapper, visible:boolean)[]
		Visibility = {},
	},
	LastVisible = false
}

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


---@class LeaderLibUIWrapperRegistration
local _REGISTER = {}

---@param self LeaderLibUIWrapper
---@param event string|string[] The method name.
---@param callback UIWrapperCallbackHandler
---@param eventType UICallbackEventType|nil
---@param uiContext UIWrapperEventContextType|nil
---@return LeaderLibUIWrapperRegistration
function _REGISTER.Invoke(self, event, callback, eventType, uiContext)
	if type(event) == "table" then
		for _,v in pairs(event) do
			_REGISTER.Invoke(self, v, callback, eventType, uiContext)
		end
	else
		if self.Callbacks.Invoke[event] == nil then
			self.Callbacks.Invoke[event] = {}
		end
		table.insert(self.Callbacks.Invoke[event], {
			Callback = callback,
			Context = eventType or "After",
			UIContext = uiContext,
		})
	---@diagnostic disable-next-line missing-return
	end
end

---@param self LeaderLibUIWrapper
---@param event string|string[] The ExternalInterface.call name.
---@param callback UIWrapperCallbackHandler
---@param eventType UICallbackEventType|nil Defaults to "After"
---@param uiContext UIWrapperEventContextType|nil
---@return LeaderLibUIWrapperRegistration
function _REGISTER.Call(self, event, callback, eventType, uiContext)
	if type(event) == "table" then
		for _,v in pairs(event) do
			_REGISTER.Invoke(self, v, callback, eventType, uiContext)
		end
	else
		if self.Callbacks.Call[event] == nil then
			self.Callbacks.Call[event] = {}
		end
		table.insert(self.Callbacks.Call[event], {
			Callback = callback,
			Context = eventType or "After",
			UIContext = uiContext,
		})
	---@diagnostic disable-next-line missing-return
	end
end

---Call a function when the visibility of this UI changes. This also enabled visibility checks via a ticker listener.
---@param self LeaderLibUIWrapper
---@param callback fun(self:LeaderLibUIWrapper, visible:boolean)
---@return LeaderLibUIWrapperRegistration
function _REGISTER.Visibility(self, callback)
	self.Callbacks.Visibility[#self.Callbacks.Visibility+1] = callback
	if not self._EnabledVisibilityListener then
		self._EnabledVisibilityListener = true
		_uiVisibilityArray[#_uiVisibilityArray+1] = self
	---@diagnostic disable-next-line missing-return
	end
end

UIWrapper.Register = _REGISTER

local function SetMeta(this)
	local _private = {
		Register = {
			__self = this
		}
	}
	for k,v in pairs(_REGISTER) do
		_private.Register[k] = function(reg, ...)
			v(this, ...)
			return _private.Register
		end
	end
	setmetatable(this, {
		__index = function(tbl,k)
			if _private[k] ~= nil then
				return _private[k]
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
					return Common.TableHasValue(ui.Flags, "OF_Visible")
				end
				return false
			end
			if UIWrapper[k] then
				return UIWrapper[k]
			end
		end,
		__newindex = function (tbl,k,v)
			if _private[k] ~= nil then
				return
			else
				rawset(tbl, k, v)
			end
		end
	})
end

local function _NewWrapper(params)
	local this = {
		Name = "",
		ID = -1,
		Path = "",
		ControllerID = -1,
		ControllerPath = "",
		IsControllerSupported = false,
		Callbacks = {
			---@type table<string, UIWrapperCallbackEntry[]>
			Invoke = {},
			---@type table<string, UIWrapperCallbackEntry[]>
			Call = {},
			---@type fun(self:LeaderLibUIWrapper, visible:boolean)[]
			Visibility = {},
		},
		_EnabledVisibilityListener = false,
		LastVisible = false,
	}
	if params then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	return this
end

local function _AppendWrapper(baseTable, id, this)
	if baseTable[id] == nil then
		baseTable[id] = {}
	end
	local wrappers = baseTable[id]
	wrappers[#wrappers+1] = this
end

---@param id integer
---@param params LeaderLibUIWrapper|nil
---@return LeaderLibUIWrapper
function UIWrapper:CreateFromType(id, params)
	local this = _NewWrapper(params)
	this.ID = id
	SetMeta(this)
	local ui = UIWrapper.GetInstance(this)
	if ui then
		ui:CaptureExternalInterfaceCalls()
		ui:CaptureInvokes()
	end
	_AppendWrapper(_uiTypeWrappers, id, this)
	if this.ControllerID and this.ControllerID > -1 then
		_AppendWrapper(_uiTypeWrappers, this.ControllerID, this)
	end
	return this
end

---@param path string
---@param params LeaderLibUIWrapper|nil
---@return LeaderLibUIWrapper
function UIWrapper:CreateFromPath(path, params)
	local this = _NewWrapper(params)
	this.Path = path
	local ui = UIWrapper.GetInstance(this)
	if ui then
		this.ID = ui:GetTypeId()
		this.Name = Data.UITypeToName[this.ID]
		ui:CaptureExternalInterfaceCalls()
		ui:CaptureInvokes()
	end
	SetMeta(this)
	_AppendWrapper(_uiPathWrappers, path, this)
	if not StringHelpers.IsNullOrEmpty(this.ControllerPath) then
		_AppendWrapper(_uiPathWrappers, this.ControllerPath, this)
	end
	return this
end

local function CanInvokeCallback(data, eventType)
	if data.UIContext then
		local controllerEnabled = Vars.ControllerEnabled
		if data.UIContext == "Keyboard" and controllerEnabled then
			return false
		elseif data.UIContext == "Controller" and not controllerEnabled then
			return false
		end
	end
	return data.Context == eventType
end

---@alias UIWrapperEventContextType string|"Keyboard"|"Controller"|"All"
---@alias UIWrapperCallbackHandler fun(self:LeaderLibUIWrapper, e:EclLuaUICallEventParams, ui:UIObject, event:string, ...:SerializableValue)

---@param callbackType string
---@param e EclLuaUICallEventParams
function UIWrapper:InvokeCallbacks(callbackType, e)
	if not self.Callbacks[callbackType] then
		error(string.format("Invalid callback type %s", callbackType))
	end
	local callbacks = self.Callbacks[callbackType][e.Function]
	if callbacks then
		local len = #callbacks
		for i=1,len do
			local callbackData = callbacks[i]
			if CanInvokeCallback(callbackData, e.When) then
				local result = {xpcall(callbackData.Callback, debug.traceback, self, e, e.UI, e.Function, table.unpack(e.Args))}
				if result[1] then
					local b,preventAction,stopPropagation = table.unpack(result)
					if preventAction then
						e:PreventAction()
					end
					if stopPropagation then
						e:StopPropagation()
					end
				else
					_PrintError(result[2])
				end
			end
		end
	end
end

---@deprecated
---@param event string The method name.
---@param callback UIWrapperCallbackHandler
---@param eventType UICallbackEventType|nil
---@param uiContext UIWrapperEventContextType|nil
function UIWrapper:RegisterInvokeListener(event, callback, eventType, uiContext)
	_REGISTER.Invoke(self, event, function (self, e, ui, event, ...)
		callback(self, ui, event, ...)
	end)
end

---@deprecated
---@param event string The ExternalInterface.call name.
---@param callback UIWrapperCallbackHandler
---@param eventType UICallbackEventType|nil Defaults to "After"
---@param uiContext UIWrapperEventContextType|nil
function UIWrapper:RegisterCallListener(event, callback, eventType, uiContext)
	_REGISTER.Call(self, event, function (self, e, ui, event, ...)
		callback(self, ui, event, ...)
	end)
end

---@return UIObject|nil
function UIWrapper:GetInstance()
	if not Vars.ControllerEnabled then
		if not StringHelpers.IsNullOrEmpty(self.Path) then
			local ui = Ext.UI.GetByPath(self.Path)
			if ui then
				self.Name = Data.UITypeToName[ui.Type]
				return ui
			end
		end
		if self.ID > -1 then
			local ui = Ext.UI.GetByType(self.ID)
			if ui then
				self.Name = Data.UITypeToName[ui.Type]
				return ui
			end
		end
	else
		if not StringHelpers.IsNullOrEmpty(self.ControllerPath) then
			local ui = Ext.UI.GetByPath(self.ControllerPath)
			if ui then
				self.Name = Data.UITypeToName[ui.Type]
				return ui
			end
		end
		if self.ControllerID > -1 then
			local ui = Ext.UI.GetByType(self.ControllerID)
			if ui then
				self.Name = Data.UITypeToName[ui.Type]
				return ui
			end
		end
	end
end

---@return FlashMainTimeline|nil
function UIWrapper:GetRoot()
	local ui = self:GetInstance()
	if ui then
		return ui:GetRoot()
	end
	return nil
end

---@param call string
---@vararg SerializableValue
function UIWrapper:ExternalInterfaceCall(call, ...)
	local ui = self:GetInstance()
	if ui then
		ui:ExternalInterfaceCall(call, ...)
	end
end

---@param method string
---@vararg SerializableValue
function UIWrapper:Invoke(method, ...)
	local root = self:GetRoot()
	if root then
		local func = root[method]
		if func then
			local b,err = xpcall(func, debug.traceback, ...)
			if not b then
				_PrintError(err)
			end
		else
			fprint(LOGLEVEL.ERROR, "[UIWrapper:%s] Flash method (%s) does not exist!", self.Name, method)
		end
	end
end

local _sfind = string.find

local _cachedShortPath = {}
local function _GetUIPath(path)
	local _,_,shortPath = _sfind(path, "(Public/.+)")
	if shortPath then
		_cachedShortPath[path] = shortPath
	end
	return shortPath
end


Ext.Events.UIInvoke:Subscribe(function (e)
	local wrappers = _uiTypeWrappers[e.UI.Type]
	if wrappers then
		local len = #wrappers
		for i=1,len do
			wrappers[i]:InvokeCallbacks("Invoke", e)
		end
	end
	local path = _cachedShortPath[e.UI.Path] or _GetUIPath(e.UI.Path)
	local wrappers = _uiPathWrappers[path]
	if wrappers then
		local len = #wrappers
		for i=1,len do
			wrappers[i]:InvokeCallbacks("Invoke", e)
		end
	end
end)

Ext.Events.UICall:Subscribe(function (e)
	local wrappers = _uiTypeWrappers[e.UI.Type]
	if wrappers then
		local len = #wrappers
		for i=1,len do
			wrappers[i]:InvokeCallbacks("Call", e)
		end
	end
	local path = _cachedShortPath[e.UI.Path] or _GetUIPath(e.UI.Path)
	local wrappers = _uiPathWrappers[path]
	if wrappers then
		local len = #wrappers
		for i=1,len do
			wrappers[i]:InvokeCallbacks("Call", e)
		end
	end
end)

Ext.Events.Tick:Subscribe(function (e)
	local length = #_uiVisibilityArray
	for i=1,length do
		local wrapper = _uiVisibilityArray[i]
		local visible = wrapper.Visible
		if visible ~= wrapper.LastVisible then
			print(wrapper.Path, visible, wrapper.LastVisible)
			local callbacks = wrapper.Callbacks.Visibility
			if callbacks then
				local len = #callbacks
				for j=1,len do
					local b,err = xpcall(callbacks[j], _debugtraceback, wrapper, visible)
					if not b then
						_PrintError(err)
					end
				end
			end
			wrapper.LastVisible = visible
		end
	end
end)

Classes.UIWrapper = UIWrapper

Ext.Events.UIObjectCreated:Subscribe(function (e)
	if not StringHelpers.IsNullOrEmpty(e.UI.Path) then
		_GetUIPath(e.UI.Path)
	end
end)