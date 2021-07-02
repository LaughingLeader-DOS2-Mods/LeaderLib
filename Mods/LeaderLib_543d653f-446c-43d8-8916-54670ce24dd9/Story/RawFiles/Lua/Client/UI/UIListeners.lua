---@param ui UIObject
Ext.RegisterListener("UIObjectCreated", function (callingUI)
	local t,name,path = UI.TryFindUIByType(callingUI, callingUI:GetTypeId())
	if t then
		local ui = path and Ext.GetBuiltinUI(path) or Ext.GetUIByType(t)
		if ui then
			local this = ui:GetRoot()
			local player = Client:GetCharacter()
			InvokeListenerCallbacks(Listeners.UICreated[t], ui, this, player, t, name)
			InvokeListenerCallbacks(Listeners.UICreated.All, ui, this, player, t, name)
		end
	end
end)

---@param typeId integer|integer[]
---@param callback UICreatedCallback
function UI.RegisterUICreatedListener(typeId, callback)
	local t = type(typeId)
	if t == "table" then
		for i,v in pairs(typeId) do
			UI.RegisterUICreatedListener(v, callback)
		end
	else
		RegisterListener("UICreated", typeId, callback)
	end
end