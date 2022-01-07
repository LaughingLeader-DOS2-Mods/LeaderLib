if GameHelpers.Client == nil then
	GameHelpers.Client = {}
end

---Get the current character stored in characterSheet's main timeline.
---@param main FlashObject|nil
---@return EclCharacter
function GameHelpers.Client.GetCharacterSheetCharacter(main)
	local character = nil
	if main == nil then
		if not Vars.ControllerEnabled then
			main = Ext.GetUIByType(Data.UIType.characterSheet):GetRoot()
		else
			main = Ext.GetUIByType(Data.UIType.statsPanel_c):GetRoot()
		end
	end
	if main ~= nil then
		character = GameHelpers.Client.TryGetCharacterFromDouble(main.characterHandle)
	end
	return character or Client:GetCharacter()
end

---Get the current character stored in characterSheet's main timeline.
---@param main FlashObject|nil
---@return EclCharacter
function GameHelpers.Client.GetCharacterCreationCharacter(main)
	local character = nil
	if main == nil then
		if not Vars.ControllerEnabled then
			main = Ext.GetUIByType(Data.UIType.characterCreation)
		else
			main = Ext.GetUIByType(Data.UIType.characterCreation_c)
		end
		if main ~= nil then
			main = main:GetRoot()
		end
	end
	if main ~= nil then
		character = GameHelpers.Client.TryGetCharacterFromDouble(main.characterHandle)
	end
	return character or Client:GetCharacter()
end

---Get the GM's target character in GM mode.
---@return EclCharacter
function GameHelpers.Client.GetGMTargetCharacter()
	local character = nil
	local ui = Ext.GetUIByType(Data.UIType.GMPanelHUD)
	if ui then
		local handle = ui:GetValue("targetHandle", "number")
		if handle and handle ~= 0 then
			character = GameHelpers.Client.TryGetCharacterFromDouble(handle)
		end
	end
	return character
end

---Get the current character set in the hotbar.
---@return EclCharacter|nil
function GameHelpers.Client.GetCharacter()
	local character = nil
	if not Vars.ControllerEnabled then
		local ui = Ext.GetUIByType(Data.UIType.hotBar)
		if ui ~= nil then
			local main = ui:GetRoot()
			if main ~= nil then
				character = GameHelpers.Client.TryGetCharacterFromDouble(main.hotbar_mc.characterHandle)
			end
		end
		if not character and SharedData.GameMode == GAMEMODE.GAMEMASTER then
			character = GameHelpers.Client.GetGMTargetCharacter()
		end
	else
		local ui = Ext.GetUIByType(Data.UIType.bottomBar_c)
		if ui ~= nil then
			local main = ui:GetRoot()
			if main ~= nil then
				character = GameHelpers.Client.TryGetCharacterFromDouble(main.characterHandle)
			end
		end
	end
	return character
end

---@return boolean
function GameHelpers.Client.IsGameMaster(ui, this)
	if Client and Client.Character and (Client.Character.IsGameMaster and not Client.Character.IsPossessed) then
		return true
	end
	if not Vars.ControllerEnabled then
		local ui = ui or Ext.GetUIByType(Data.UIType.characterSheet)
		if ui then
			---@type FlashMainTimeline
			local this = this or ui:GetRoot()
			if this and this.isGameMasterChar then
				return true
			end
		end
	end
	return false
end

---Tries to get a character from a double value.
---@param double number
---@return EclCharacter
function GameHelpers.Client.TryGetCharacterFromDouble(double)
	local b,character = xpcall(function()
		if not GameHelpers.Math.IsNaN(double) then
			local handle = Ext.DoubleToHandle(double)
			if handle then
				return Ext.GetCharacter(handle)
			end
		else
			fprint(LOGLEVEL.WARNING, "[GameHelpers.Client.TryGetCharacterFromDouble] Double handle is NaN (not a number)!")
			return nil
		end
	end, debug.traceback)
	return character
end

local function _pairs(t, var)
	var = var + 1
	local value = t[var]
	if value == nil then return end
	return var, value
end

---@param arr FlashArray
---@return table
function GameHelpers.Client.TableFromFlashArray(arr)
	local value = nil
	local i = 0
	local tbl = {}

	repeat
		value = arr[i]
		i = i + 1
		if value ~= nil then
			tbl[#tbl+1] = value
		end
	until value == nil

	return tbl
end

---@param tbl table
---@param arr FlashArray
---@return table
function GameHelpers.Client.WriteTableToFlashArray(tbl, arr)
	for i=1,#tbl do
		arr[i-1] = tbl[i]
	end
end