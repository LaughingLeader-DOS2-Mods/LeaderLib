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
		local this = ui:GetRoot()
		if this then
			local handle = this.targetHandle
			if not GameHelpers.Math.IsNaN(handle) and handle ~= 0 then
				character = GameHelpers.Client.TryGetCharacterFromDouble(handle)
			end
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
		if not character then
			local ui = Ext.GetUIByType(Data.UIType.statusConsole)
			if ui ~= nil then
				local handle = ui:GetPlayerHandle()
				if handle ~= nil then
					character = GameHelpers.GetCharacter(handle)
				end
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
		if not character then
			local ui = Ext.GetUIByType(Data.UIType.statusConsole)
			if ui ~= nil then
				local handle = ui:GetPlayerHandle()
				if handle ~= nil then
					character = GameHelpers.GetCharacter(handle)
				end
			end
		end
	end
	return character
end

---@return EclCharacter
function GameHelpers.Client.GetGameMaster()
	if Client and Client.Character and (Client.Character.IsGameMaster and not Client.Character.IsPossessed) then
		return Client:GetCharacter()
	end
	if not Vars.ControllerEnabled then
		local ui = Ext.GetUIByType(Data.UIType.characterSheet)
		if ui then
			---@type FlashMainTimeline
			local this = ui:GetRoot()
			if this and this.isGameMasterChar then
				return GameHelpers.Client.TryGetCharacterFromDouble(this.characterHandle)
			end
		end
	end
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

---@param double number
---@param func fun(handle:ComponentHandle):EclCharacter|EclItem
local function ProcessDoubleHandle(double, func)
	if double == nil or double == 0 then
		return nil
	end
	if not GameHelpers.Math.IsNaN(double) then
		if double <= 0 then
			return nil
		end
		local handle = Ext.UI.DoubleToHandle(double)
		if GameHelpers.IsValidHandle(handle) then
			return func(handle)
		end
	else
		fprint(LOGLEVEL.WARNING, "[GameHelpers.Client.ProcessDoubleHandle] Double handle is NaN (not a number)! Double(%s)", double)
		return nil
	end
end

---Tries to get a character from a double value.
---@param double number
---@return EclCharacter
function GameHelpers.Client.TryGetCharacterFromDouble(double)
	if double == nil or double == 0 then
		return nil
	end
	local b,character = pcall(ProcessDoubleHandle, double, GameHelpers.GetCharacter)
	if b then
		return character
	end
	return nil
end

---Tries to get an item from a double value.
---@param double number
---@return EclItem
function GameHelpers.Client.TryGetItemFromDouble(double)
	if double == nil or double == 0 then
		return nil
	end
	local b,item = pcall(ProcessDoubleHandle, double, GameHelpers.GetItem)
	if b then
		return item
	end
	return nil
end

---@param arr FlashArray<any>
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
---@param arr FlashArray<any>
---@return table
function GameHelpers.Client.WriteTableToFlashArray(tbl, arr)
	for i=1,#tbl do
		arr[i-1] = tbl[i]
	end
end

---@alias ExtenderSkillBarSlotType string|'"None"'|'"Skill"'|'"Item"'

---@class ExtenderPlayerSkillBarSlot
---@field Type ExtenderSkillBarSlotType
---@field SkillOrStatId string
---@field ItemHandle ObjectHandle

---@param slotData ExtenderPlayerSkillBarSlot
function GameHelpers.Client.ClearSlot(slotData)
	slotData.Type = "None"
	slotData.SkillOrStatId = ""
	slotData.ItemHandle = Ext.DoubleToHandle(0)
end

---@param locked boolean|nil Defaults to false.
function GameHelpers.Client.SetInventoryLocked(locked)
	if Ext.GetGameState() == "Running" then
		if type(locked) ~= "boolean" then
			locked = false
		end
		local ui = Ext.GetBuiltinUI(not Vars.ControllerEnabled and Data.UIType.partyInventory or Data.UIType.partyInventory_c)
		if ui then
			for player in GameHelpers.Character.GetPlayers() do
				ui:ExternalInterfaceCall("lockInventory", Ext.HandleToDouble(player.Handle), locked)
			end
		end
	end
end