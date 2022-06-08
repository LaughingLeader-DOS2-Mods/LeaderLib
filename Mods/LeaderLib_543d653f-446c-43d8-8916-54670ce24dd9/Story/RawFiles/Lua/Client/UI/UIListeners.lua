---@param callingUI UIObject
Ext.RegisterListener("UIObjectCreated", function (callingUI)
	local t,name,path = UI.TryFindUIByType(callingUI, callingUI:GetTypeId())
	if t then
		local ui = path and Ext.GetBuiltinUI(path) or Ext.GetUIByType(t)
		if ui then
			local this = ui:GetRoot()
			local player = Client:GetCharacter()
			Events.UICreated:Invoke({
				UI = ui,	
				Root = this,
				Player = player,
				TypeId = t,
				Name = name,
				Path = path
			})
		end
	end
end)

---@param typeId integer|integer[]
---@param callback fun(e:UICreatedEventArgs)
function UI.RegisterUICreatedListener(typeId, callback)
	local t = type(typeId)
	if t == "table" then
		for i,v in pairs(typeId) do
			UI.RegisterUICreatedListener(v, callback)
		end
	else
		Events.UICreated:Subscribe(callback, {MatchArgs={TypeId=typeId}})
	end
end