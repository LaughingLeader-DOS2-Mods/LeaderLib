---@class UIListenerWrapper
local UIListenerWrapper = {
	Type = "UIListenerWrapper",
	Name = "",
	Calls = {},
	Methods = {},
	ID = -1,
	Enabled = false,
	CustomCallback = {},
	Ignored = {},
}

Classes.UIListenerWrapper = UIListenerWrapper

---@type UIListenerWrapper[]
local allListeners = {}
---@type table<integer,UIListenerWrapper>
local typeListeners = {}

local deferredRegistrations = {}

setmetatable(UIListenerWrapper, {
	__index = function (_,k)
		if k == "_TypeListeners" then
			return typeListeners
		elseif k == "_AllListeners" then
			return allListeners
		elseif k == "_DeferredRegistrations" then
			return deferredRegistrations
		end
	end
})

function UIListenerWrapper:Create(id, params)
	local this = {
		ID = id,
		Enabled = UIListenerWrapper.Enabled,
		CustomCallback = {},
		PrintParams = true,
		Initialized = nil,
		Ignored = {}
	}

	if params and type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end

	if type(id) == "string" then
		this.Name = string.find
		local ui = Ext.GetBuiltinUI(id)

		if not ui then
			deferredRegistrations[id] = this
		else
			if this.Initialized then
				local b,err = xpcall(this.Initialized, debug.traceback, ui)
				if not b then
					Ext.PrintError(err)
				end
			end
		end
	else
		if type(id) == "table" then
			for k,id2 in pairs(id) do
				this.Name = Data.UITypeToName[id2] or ""
				if this.Initialized then
					local ui = Ext.GetBuiltinUI(id2)
					if ui then
						local b,err = xpcall(this.Initialized, debug.traceback, ui)
						if not b then
							Ext.PrintError(err)
						end
					end
				end
				typeListeners[id2] = this
			end
		else
			this.Name = Data.UITypeToName[id] or ""
			if this.Initialized then
				local ui = Ext.GetUIByType(id)
				if ui then
					local b,err = xpcall(this.Initialized, debug.traceback, ui)
					if not b then
						Ext.PrintError(err)
					end
				end
			end
			typeListeners[this.ID] = this
		end
	end

	setmetatable(this, {
		__index = function (_,k)
			return UIListenerWrapper[k]
		end
	})

	allListeners[#allListeners+1] = this

	return this
end

Ext.RegisterConsoleCommand("uilogging", function(cmd, enabled)
	for i,v in pairs(allListeners) do
		if enabled == "false" then
			v.Enabled = false
		else
			v.Enabled = true
		end
	end
end)