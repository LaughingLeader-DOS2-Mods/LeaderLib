---@class UIObjectExtendedSettings
---@field ID string
---@field Layer integer
---@field SwfPath string
---@field DefaultUIFlags integer|nil
---@field SetPosition fun(self:UIObjectExtended):void
---@field OnVisibilityChanged fun(self:UIObjectExtended, lastVisible:boolean, nextVisible:boolean):void
---@field ShouldBeVisible fun(self:UIObjectExtended):boolean
---@field OnInitialized fun(self:UIObjectExtended, instance:UIObject):void

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
setmetatable(_registeredUIs, {__mode = "kv"})

---@type UIObjectExtended[]
local _registeredUIArray = {}
setmetatable(_registeredUIArray, {__mode = "kv"})

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

---@param params UIObjectExtendedSettings
function UIObjectExtended:Create(params)
	---@type UIObjectExtended
	local this = {
		ResolutionInitialized = false,
	}
	if type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	setmetatable(this, UIObjectExtended)

	if not StringHelpers.IsNullOrEmpty(this.ID) then
		_registeredUIs[this.ID] = this
	end
	_registeredUIArray[#_registeredUIArray+1] = this

	return this
end

---@param skipCreation ?boolean
---@param setVisibility ?boolean
function UIObjectExtended:GetInstance(skipCreation, setVisibility)
	local instance = Ext.GetUI(self.ID) or Ext.GetBuiltinUI(self.SwfPath)
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

---@param b boolean
function UIObjectExtended:SetVisible(b)
	if b == nil then
		return
	end
	local last = self.Visible
	if last ~= b then
		--Create the instance if visibility should be true
		local inst = self:GetInstance(not b, false)
		if not self.ResolutionInitialized then
			return
		end
		if inst then
			if b then
				self:Reposition()
				if self.OnVisibilityChanged then
					self:OnVisibilityChanged(last, b)
				end
				inst:Show()
			else
				if self.OnVisibilityChanged then
					self:OnVisibilityChanged(last, b)
				end
				inst:Hide()
			end
		end
	end
end

---@param setVisibility ?boolean
---@private
function UIObjectExtended:Initialize(setVisibility)
	local instance = Ext.GetUI(self.ID) or Ext.GetBuiltinUI(self.SwfPath)
	if not instance then
		instance = Ext.CreateUI(self.ID, self.SwfPath, self.Layer, self.DefaultUIFlags)
		instance:Hide()

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

RegisterListener("BeforeLuaReset", function()
	local length = #_registeredUIArray
	for i=1,length do
		local ui = _registeredUIArray[i]
		DestroyInstance(ui)
	end
end)

RegisterTickListener(function (e)
	local length = #_registeredUIArray
	for i=1,length do
		local ui = _registeredUIArray[i]
		ui:ValidateVisibility()
	end
end, true)

Ext.RegisterUINameCall("LeaderLib_OnEventResolution", function (ui, event, id)
	local data = _registeredUIs[id]
	if data then
		data.ResolutionInitialized = true
		data:Reposition()
	end
end)

Classes.UIObjectExtended = UIObjectExtended