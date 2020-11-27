if GameHelpers.Client == nil then
	GameHelpers.Client = {}
end

---Get the current character stored in characterSheet's main timeline.
---@param main FlashObject|nil
---@return EclCharacter
function GameHelpers.Client.GetCharacterSheetCharacter(main)
	local character = nil
	if not Vars.ControllerEnabled then
		if main == nil then
			main = Ext.GetUIByType(Data.UIType.characterSheet):GetRoot()
		end
		if main ~= nil then
			local b,result = pcall(function()
				return Ext.GetCharacter(Ext.DoubleToHandle(main.charHandle))
			end)
			if not b then
				Ext.PrintError(result)
			else
				character = result
			end
		end
	else
		--main = Ext.GetUIByType(Data.UIType.statsPanel_c):GetRoot()
		return Client:GetCharacter()
	end
	
	if character == nil then
		character = Client:GetCharacter()
	end
	return character
end

---Get the current character set in the hotbar.
---@return EclCharacter|nil
function GameHelpers.Client.GetCharacter()
	local handle = nil
	if Vars.ControllerEnabled ~= true then
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