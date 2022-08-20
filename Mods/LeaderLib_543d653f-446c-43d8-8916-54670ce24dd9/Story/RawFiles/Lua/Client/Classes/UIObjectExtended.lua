local _EXTVERSION = Ext.Utils.Version()

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
--setmetatable(_registeredUIs, {__mode = "kv"})

---@type UIObjectExtended[]
local _registeredUIArray = {}
--setmetatable(_registeredUIArray, {__mode = "kv"})

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
	return UIObjectExtended[k]
end

UIObjectExtended.__index = GetIndex

local FunctionParameters = {
	ShouldBeVisible = true,
	OnVisibilityChanged = true,
	OnInitialized = true,
	OnTick = true,
	SetPosition = true,
}

---@param params UIObjectExtendedSettings
function UIObjectExtended:Create(params)
	---@type UIObjectExtended
	local this = {
		ResolutionInitialized = false,
	}
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
			else
				this[k] = v
			end
		end
	end
	setmetatable(this, UIObjectExtended)

	if not StringHelpers.IsNullOrEmpty(this.ID) then
		_registeredUIs[this.ID] = this
	end
	_registeredUIArray[#_registeredUIArray+1] = this

	return this
end

---@param skipCreation boolean|nil
---@param setVisibility boolean|nil
function UIObjectExtended:GetInstance(skipCreation, setVisibility)
	local instance = Ext.UI.GetByName(self.ID) or Ext.GetBuiltinUI(self.SwfPath)
	if not instance and skipCreation ~= true then
		instance = self:Initialize(setVisibility)
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
		if _EXTVERSION >= 56 then
			local flags = _inputFlags[self.ID]
			if flags then
				for flag,b in pairs(_inputFlags[self.ID]) do
					if not Common.TableHasEntry(inst.Flags, flag) then
						inst.Flags[#inst.Flags+1] = flag
					end
				end
				_inputFlags[self.ID] = nil
			end
		end
		inst:Show()
	end
end

---@param inst UIObject
function UIObjectExtended:Hide(inst)
	inst = inst or self.Instance
	if inst then
		if _EXTVERSION >= 56 then
			_inputFlags[self.ID] = {}
			for i,v in pairs(inst.Flags) do
				if string.find(v, "PlayerInput") then
					_inputFlags[self.ID][v] = true
				end
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
	local instance = Ext.UI.GetByName(self.ID) or Ext.GetBuiltinUI(self.SwfPath)
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

local function DestroyInstance(self)
	local instance = self:GetInstance(true)
	if instance then
		instance:Destroy()
	end
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

Classes.UIObjectExtended = UIObjectExtended