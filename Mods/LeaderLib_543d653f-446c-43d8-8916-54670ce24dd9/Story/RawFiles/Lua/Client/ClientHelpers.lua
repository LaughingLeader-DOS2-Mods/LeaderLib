if GameHelpers.Client == nil then
	GameHelpers.Client = {}
end

---Get the current character set in the hotbar.
---@return EclCharacter|nil
function GameHelpers.Client.GetCharacter()
	local handle = nil
	if UI.ControllerEnabled ~= true then
		local hotbar = Ext.GetUIByType(Data.UIType.hotBar)
		if hotbar ~= nil then
			local main = hotbar:GetRoot()
			if main ~= nil then
				handle = Ext.DoubleToHandle(main.hotbar_mc.characterHandle)
			end
		end
	else
		local hotbar = Ext.GetUIByType(Data.UIType.bottomBar_c)
		if hotbar ~= nil then
			local main = hotbar:GetRoot()
			if main ~= nil then
				handle = Ext.DoubleToHandle(main.characterHandle)
			end
		end
	end
	if handle ~= nil then
		return Ext.GetCharacter(handle)
	end
	return nil
end