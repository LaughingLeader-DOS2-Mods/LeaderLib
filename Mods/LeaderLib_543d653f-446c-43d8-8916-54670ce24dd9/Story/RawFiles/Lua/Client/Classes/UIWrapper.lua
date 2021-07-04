---@class LeaderLibUIWrapper
---@field Root FlashMainTimeline
---@field Instance UIObject
local UIWrapper = {
	Type = "UIWrapper",
	Name = "",
	ID = -1,
	Path = "",
	IsControllerSupported = false,
	ControllerID = -1,
	ControllerPath = "",
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
			end
		end
	})
end

---@param id integer
---@param params UIWrapper|nil
---@return LeaderLibUIWrapper
function UIWrapper:CreateFromType(id, params)
	local this = {
		ID = id,
		Name = Data.UITypeToName[id] or "",
		Path = ""
	}
	if params then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	SetMeta(this)
	return this
end

---@param path string
---@param params UIWrapper|nil
---@return LeaderLibUIWrapper
function UIWrapper:CreateFromPath(path, params)
	local this = {
		ID = -1,
		Name = "",
		Path = path
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
	end
	SetMeta(this)
	return this
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

Classes.UIWrapper = UIWrapper