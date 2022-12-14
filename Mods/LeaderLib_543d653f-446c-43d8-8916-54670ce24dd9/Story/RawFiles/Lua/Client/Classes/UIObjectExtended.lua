local _EXTVERSION = Ext.Utils.Version()

---@alias UIObjectExtendedSubscriptionCallback fun(e:EclLuaUICallEvent, self:UIObjectExtended)
---@alias UIObjectExtendedCallbackSubscriptionData {Callback:UIObjectExtendedSubscriptionCallback, Context:UICallbackEventType}

---A wrapper around a UI that handles automatically creating/hiding the UI when it should be visible.
---@class UIObjectExtendedSettings
---@field ID string
---@field Layer integer
---@field SwfPath string
---@field DefaultUIFlags integer|nil
---@field SetPosition fun(self:UIObjectExtended)
---@field ShouldBeVisible fun(self:UIObjectExtended):boolean
---@field OnVisibilityChanged fun(self:UIObjectExtended, lastVisible:boolean, nextVisible:boolean)
---@field OnInitialized fun(self:UIObjectExtended, instance:UIObject)
---@field OnTick fun(self:UIObjectExtended, e:GameTime)
---@field _GetIndex fun(self:table, key:string):any Custom function for providing more behavior in the __index metamethod for the instance.
---@field Subscribe UIObjectExtendedSubscription
---@field Callbacks {Invoke:table<string,UIObjectExtendedCallbackSubscriptionData[]>, Call:table<string,UIObjectExtendedCallbackSubscriptionData[]>}

---@class UIObjectExtended:UIObjectExtendedSettings
---@field Instance UIObject
---@field Root FlashMainTimeline
---@field Visible boolean
---@field ResolutionInitialized boolean
local UIObjectExtended = {
	DefaultUIFlags = Data.DefaultUIFlags
}

---@type table<string, UIObjectExtended>
local _registeredUIs = {}
---@type table<integer, UIObjectExtended>
local _registeredUITypes = {}
---@type UIObjectExtended[]
local _registeredUIArray = {}

local function GetIndex(tbl, k)
	if k == "Instance" then
		return UIObjectExtended.GetInstance(tbl, true)
	elseif k == "Root" then
		local ui = UIObjectExtended.GetInstance(tbl, true)
		if ui then
			return ui:GetRoot()
		end
	elseif k == "Visible" then
		local ui = UIObjectExtended.GetInstance(tbl, true)
		if ui then
			return Common.TableHasValue(ui.Flags, "OF_Visible")
		end
		return false
	end
	local _getIndex = rawget(tbl, "_GetIndex")
	if _getIndex then
		local v = _getIndex(tbl, k)
		if v ~= nil then
			return v
		end
	end
	return UIObjectExtended[k]
end

local FunctionParameters = {
	ShouldBeVisible = true,
	OnVisibilityChanged = true,
	OnInitialized = true,
	OnTick = true,
	SetPosition = true,
}

---@class UIObjectExtendedSubscription
local _SUB = {}

---@param params UIObjectExtendedSettings
function UIObjectExtended:Create(params)
	---@type UIObjectExtended
	local this = {
		ResolutionInitialized = false,
		Callbacks = {
			Invoke = {},
			Call = {},
		},
	}
	local _private = {
		Subscribe = {
			__self = this
		}
	}
	for k,v in pairs(_SUB) do
		_private.Subscribe[k] = function(reg, ...)
			v(this, ...)
			return _private.Subscribe
		end
	end
	if type(params) == "table" then
		for k,v in pairs(params) do
			if FunctionParameters[k] then
				local t = type(v)
				if t ~= "function" then
					fprint(LOGLEVEL.ERROR, "[LeaderLib:UIObjectExtended] Parameters [%s] should be a function, but it is a [%s].", k, t)
					--In case "ShouldBeVisible" is true/false, return the value in a wrapper function instead.
					if t ~= "nil" then
						this[k] = function ()
							return v
						end
					end
				else
					this[k] = v
				end
			elseif _private[k] == nil then
				this[k] = v
			end
		end
	end
	setmetatable(this, {
		__index = function (tbl,k)
			if _private[k] ~= nil then
				return _private[k]
			end
			return GetIndex(tbl,k)
		end,
		__newindex = function (tbl,k,v)
			if _private[k] ~= nil then
				return
			else
				rawset(tbl, k, v)
			end
		end
	})

	if not StringHelpers.IsNullOrEmpty(this.ID) then
		_registeredUIs[this.ID] = this
	end
	_registeredUIArray[#_registeredUIArray+1] = this

	return this
end

---@param skipCreation boolean|nil
---@param setVisibility boolean|nil
function UIObjectExtended:GetInstance(skipCreation, setVisibility)
	local instance = Ext.UI.GetByName(self.ID) or Ext.UI.GetByPath(self.SwfPath)
	if not instance and skipCreation ~= true then
		instance = self:Initialize(setVisibility)
	end
	if instance then
		_registeredUITypes[instance.Type] = self
	end
	return instance
end

function UIObjectExtended:Reposition()
	if self.SetPosition then
		self:SetPosition()
	end
end

local _inputFlags = {}

---@param inst UIObject
function UIObjectExtended:Show(inst)
	inst = inst or self.Instance
	if inst then
		--TODO broken in v57 devel since inst.Flags is userdata
		-- if _EXTVERSION >= 56 then
		-- 	local flags = _inputFlags[self.ID]
		-- 	if flags then
		-- 		for flag,b in pairs(_inputFlags[self.ID]) do
		-- 			if not Common.TableHasEntry(inst.Flags, flag) then
		-- 				inst.Flags[#inst.Flags+1] = flag
		-- 			end
		-- 		end
		-- 		_inputFlags[self.ID] = nil
		-- 	end
		-- end
		inst:Show()
	end
end

---@param inst UIObject
function UIObjectExtended:Hide(inst)
	inst = inst or self.Instance
	if inst then
		_inputFlags[self.ID] = {}
		for i,v in pairs(inst.Flags) do
			if string.find(v, "PlayerInput") then
				_inputFlags[self.ID][v] = true
			end
		end
		inst:Hide()
	end
end

---@param b boolean
function UIObjectExtended:SetVisible(b)
	if b == nil then
		return
	end
	local last = self.Visible
	if last ~= b then
		local inst = self:GetInstance(not b, false)
		--Create the instance if visibility should be true
		if not self.ResolutionInitialized then
			return
		end
		if inst then
			if b then
				self:Reposition()
				if self.OnVisibilityChanged then
					self:OnVisibilityChanged(last, b)
				end
				self:Show(inst)
			else
				if self.OnVisibilityChanged then
					self:OnVisibilityChanged(last, b)
				end
				self:Hide(inst)
			end
		end
	end
end

---@param setVisibility boolean|nil
---@private
function UIObjectExtended:Initialize(setVisibility)
	local instance = Ext.UI.GetByName(self.ID) or Ext.UI.GetByPath(self.SwfPath)
	if not instance then
		instance = Ext.UI.Create(self.ID, self.SwfPath, self.Layer, self.DefaultUIFlags)
		self:Hide(instance)

		if self.OnInitialized then
			self:OnInitialized(instance)
		end
	end

	if instance and setVisibility then
		self:ValidateVisibility()
	end

	return instance
end

function UIObjectExtended:ValidateVisibility()
	if self.ShouldBeVisible then
		self:SetVisible(self:ShouldBeVisible())
	end
end

---@param self UIObjectExtended
local function DestroyInstance(self)
	local instance = self:GetInstance(true)
	if instance then
		_registeredUITypes[instance.Type] = nil
		instance:Destroy()
	end
end

---Destroy any existing instances and recreate it.
function UIObjectExtended:Reset()
	DestroyInstance(self)
end

Events.BeforeLuaReset:Subscribe(function()
	local length = #_registeredUIArray
	for i=1,length do
		local ui = _registeredUIArray[i]
		DestroyInstance(ui)
	end
end)

local function OnTick(e)
	local length = #_registeredUIArray
	for i=1,length do
		local ui = _registeredUIArray[i]
		ui:ValidateVisibility()
		if ui.OnTick then
			ui:OnTick(e)
		end
	end
end

RegisterTickListener(OnTick, true)

Ext.Events.GameStateChanged:Subscribe(function (e)
	if e.ToState == "Disconnect" or e.ToState == "Menu" then
		local length = #_registeredUIArray
		for i=1,length do
			local ui = _registeredUIArray[i]
			DestroyInstance(ui)
		end
		_registeredUIArray = {}
		_registeredUIs = {}
	end
end)

Ext.RegisterUINameCall("LeaderLib_OnEventResolution", function (ui, event, id)
	local data = _registeredUIs[id]
	if data then
		data.ResolutionInitialized = true
		data:Reposition()
	end
end)

---@param callbackType string
---@param e EclLuaUICallEvent|LuaEventBase
function UIObjectExtended:InvokeCallbacks(callbackType, e)
	if not self.Callbacks[callbackType] then
		error(string.format("Invalid callback type %s", callbackType))
	end
	local callbacks = self.Callbacks[callbackType][e.Function]
	if callbacks then
		local len = #callbacks
		for i=1,len do
			local callbackData = callbacks[i]
			if callbackData.Context == e.When then
				local b,err = xpcall(callbackData.Callback, debug.traceback, e, self)
				if not b then
					Ext.Utils.PrintError(err)
				end
			end
		end
	end
end

---@param self UIObjectExtended
---@param event string|string[] The method name.
---@param callback UIObjectExtendedSubscriptionCallback
---@param eventType UICallbackEventType|nil
---@return UIObjectExtendedSubscription
function _SUB.Invoke(self, event, callback, eventType)
	if type(event) == "table" then
		for _,v in pairs(event) do
			_SUB.Invoke(self, v, callback, eventType)
		end
	else
		if self.Callbacks.Invoke[event] == nil then
			self.Callbacks.Invoke[event] = {}
		end
		table.insert(self.Callbacks.Invoke[event], {
			Callback = callback,
			Context = eventType or "After",
		})
	---@diagnostic disable-next-line missing-return
	end
end

---@param self UIObjectExtended
---@param event string|string[] The ExternalInterface.call name.
---@param callback UIObjectExtendedSubscriptionCallback
---@param eventType UICallbackEventType|nil Defaults to "After"
---@return UIObjectExtendedSubscription
function _SUB.Call(self, event, callback, eventType)
	if type(event) == "table" then
		for _,v in pairs(event) do
			_SUB.Invoke(self, v, callback, eventType)
		end
	else
		if self.Callbacks.Call[event] == nil then
			self.Callbacks.Call[event] = {}
		end
		table.insert(self.Callbacks.Call[event], {
			Callback = callback,
			Context = eventType or "After",
		})
	---@diagnostic disable-next-line missing-return
	end
end

UIObjectExtended.Subscribe = _SUB

Ext.Events.UIInvoke:Subscribe(function (e)
	local object = _registeredUITypes[e.UI.Type]
	if object then
		object:InvokeCallbacks("Invoke", e)
	end
end)

Ext.Events.UICall:Subscribe(function (e)
	local object = _registeredUITypes[e.UI.Type]
	if object then
		object:InvokeCallbacks("Call", e)
	end
end)

Classes.UIObjectExtended = UIObjectExtended