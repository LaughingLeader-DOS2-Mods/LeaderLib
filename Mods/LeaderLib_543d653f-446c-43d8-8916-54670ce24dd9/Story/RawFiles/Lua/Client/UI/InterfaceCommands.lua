---@type MessageData
local MessageData = Classes.MessageData

--public function addOverhead(param1:Number, param2:String, param3:Number) : *

local testSelectionArray = {
	[0] = -1,
	[1] = "Sir Lora",
	[2] = false,
	[3] = 14430525.0,
	[4] = 1.0,
	[5] = -1.0,
	[6] = 1.0,
	[7] = -1.0,
	[8] = 19.0,
	[9] = -1.0,
	[10] = "4",
	[11] = "Talk",
	[12] = "",
	[13] = "",
	[14] = true,
	[15] = false,
	[16] = "68",
	[17] = "",
	[18] = false,
	[19] = 1.0,
	[20] = true,
}

---@param target string The object to display the text on.
---@param text string
---@param displayTime number The duration the text is visible for.
---@param isItem boolean
function UI.StatusText(target, text, displayTime, isItem)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/overhead.swf")
	if ui then
		local handle = nil
		if isItem == true then
			handle = Ext.GetItem(target).Handle
		elseif isItem == false then
			handle = Ext.GetCharacter(target).Handle
		else
			local object = Ext.GetCharacter(target)
			if object ~= nil then
				handle = object.Handle
			else
				object = Ext.GetItem(target)
				if object ~= nil then
					handle = object.Handle
				end
			end
		end

		if handle ~= nil then
			ui:Invoke("clearObsoleteOHTs")
			ui:Invoke("clearAll")
			ui:Invoke("cleanupDeleteRequests")
			local doubleHandle = Ext.HandleToDouble(handle)
			ui:SetValue("addOH_array", 0, 0)
			ui:SetValue("addOH_array", doubleHandle, 1)
			ui:SetValue("addOH_array", text, 2)
			ui:SetValue("addOH_array", displayTime, 3)

			-- [0] = [3.4431383083963e-282]
			-- [1] = ["Sir Lora"]
			-- [2] = [false]
			-- [3] = [14430525.0]
			-- [4] = [1.0]
			-- [5] = [-1.0]
			-- [6] = [1.0]
			-- [7] = [-1.0]
			-- [8] = [19.0]
			-- [9] = [-1.0]
			-- [10] = ["4"]
			-- [11] = ["Talk"]
			-- [12] = [""]
			-- [13] = [""]
			-- [14] = [true]
			-- [15] = [false]
			-- [16] = ["68"]
			-- [17] = [""]
			-- [18] = [false]
			-- [19] = [1.0]
			-- [20] = [true]
			testSelectionArray[0] = doubleHandle
			for i,v in pairs(testSelectionArray) do
				ui:SetValue("selectionInfo_array", v, i)
			end
			ui:Invoke("updateOHs")
			--print("UI.StatusText", target, text, displayTime, isItem)
			--ui:Invoke("addOverhead", doubleHandle, text, displayTime)
		end
	end
end

Ext.RegisterNetListener("LeaderLib_DisplayStatusText", function(call, dataStr)
	local data = Common.JsonParse(dataStr)
	if data.UUID ~= nil then
		UI.StatusText(data.UUID, data.Text, data.Duration, data.IsItem)
	end
end)

local specialMessageBoxOpen = false

--Experimental
function UI.DisplayMessageBox(text, title, popupType)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/msgBox.swf")
	if ui then
		ui:Hide()
		if popupType <= 1 then
			local root = ui:GetRoot()
			--root.addButton(3, LocalizedText.UI.Close.Value, "", "")
			root.setPopupType(1)
			root.setText(text)
			root.showMsgbox()
		else
			--ui:Invoke("setAnchor", 0)
			--ui:Invoke("setPos", 50.0, 50.0)
			--ui:Invoke("setText", data.Params.Text)
			ui:Invoke("removeButtons")
			ui:Invoke("addButton", 3, LocalizedText.UI.Close.Value, "", "")
			--ui:Invoke("addBlueButton", 3, "OK")
			--ui:Invoke("addYesButton", 1)
			ui:Invoke("showWin")
			ui:Invoke("fadeIn")
			--ui:Invoke("setWaiting", true)
			ui:Invoke("setPopupType", 2)
			ui:Invoke("setInputEnabled", true)
			ui:Invoke("showPopup", title, text)
		end
		ui:Show()
		specialMessageBoxOpen = true
	end
end

Ext.RegisterNetListener("LeaderLib_DisplayMessageBox", function(call, dataStr)
	local data = Common.JsonParse(dataStr)
	if data.Text ~= nil then
		UI.DisplayMessageBox(data.Text, data.Title, data.Type)
	end
end)

Ext.RegisterNetListener("LeaderLib_UnlockCharacterInventory", function(call, playersTableString)
	if Ext.GetGameState() == "Running" and playersTableString ~= nil then
		local ui = Ext.GetBuiltinUI(not Vars.ControllerEnabled and Data.UIType.partyInventory or Data.UIType.partyInventory_c)
		if ui then
			for player in GameHelpers.Character.GetPlayers() do
				ui:ExternalInterfaceCall("lockInventory", Ext.HandleToDouble(player.Handle), false)
			end
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_AutoSortPlayerInventory", function(call, uuid)
	--TODO No way to sort controller inventories?
	if not Vars.ControllerEnabled then
		local ui = Ext.GetUIByType(Data.UIType.partyInventory)
		if ui then
			ui:ExternalInterfaceCall("autosort", Ext.HandleToDouble(Ext.GetCharacter(uuid).Handle), false)
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_Hotbar_SetSlotEnabled", function(call, dataStr)
	if not Vars.ControllerEnabled then
		local ui = Ext.GetUIByType(Data.UIType.hotBar)
		if ui then
			local status,err = xpcall(function()
				local hotbar = ui:GetRoot().hotbar_mc
				local currentBarIndex = hotbar.cycleHotBar_mc.currentHotBarIndex or 0
	
				local maxSlot = (29 * currentBarIndex) - 1
				local minSlot = 29 * (currentBarIndex - 1)
	
				local data = Common.JsonParse(dataStr)
				for i,slot in pairs(data.Slots) do
					--print("slot", slot, "local slot", slot%29, "currentBarIndex", currentBarIndex, "minSlot", minSlot, "maxSlot", maxSlot)
					if slot <= maxSlot and slot >= minSlot then
						hotbar.setSlotEnabled(slot%29, data.Enabled)
						PrintDebug("[LeaderLib] Set slot ", slot, "enabled to", data.Enabled)
					end
				end
				return true
			end, debug.traceback)
			if not status then
				Ext.PrintError(err)
			end
		end
	else
		local ui = Ext.GetUIByType(Data.UIType.bottomBar_c)
		if ui then
			local status,err = xpcall(function()
				local this = ui:GetRoot()
				local currentBarIndex = tonumber(this.bottombar_mc.groupList_mc.groupText_mc.groupNr_txt.text) or 0
	
				local maxSlot = (29 * currentBarIndex) - 1
				local minSlot = 29 * (currentBarIndex - 1)
	
				local data = Common.JsonParse(dataStr)
				for i,slot in pairs(data.Slots) do
					--print("slot", slot, "local slot", slot%29, "currentBarIndex", currentBarIndex, "minSlot", minSlot, "maxSlot", maxSlot)
					if slot <= maxSlot and slot >= minSlot then
						this.setSlotEnabled(slot%29, data.Enabled)
						PrintDebug("[LeaderLib] Set slot ", slot, "enabled to", data.Enabled)
					end
				end
				return true
			end, debug.traceback)
			if not status then
				Ext.PrintError(err)
			end
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_Hotbar_Refresh", function(call, payload)
	local ui = not Vars.ControllerEnabled and Ext.GetUIByType(Data.UIType.hotBar) or Vars.ControllerEnabled and Ext.GetBuiltinUI(Data.UIType.bottomBar_c)
	if ui then
		ui:ExternalInterfaceCall("updateSlots", ui:GetValue("maxSlots", "number"))
	end
end)

--Useless if hotBar is spamming updateSlotData
Ext.RegisterNetListener("LeaderLib_Hotbar_RefreshCooldowns", function(call, datastr)
	local data = Common.JsonParse(datastr)
	if data and data.Slots then
		if data.NetID then
			if Client.Character.NetID ~= data.NetID then
				--Current character isn't the one the slot data is for, so skip.
				return
			end
		end
		if not Vars.ControllerEnabled then
			local ui = Ext.GetUIByType(Data.UIType.hotBar)
			if ui then
				local slotholder = ui:GetRoot().hotbar_mc.slotholder_mc
				for _,slotData in pairs(data.Slots) do
					if slotData.Index and slotData.Cooldown then
						local slot_mc = slotholder.slot_array[slotData.Index]
						--PrintDebug(slotData.Index, slot_mc, slotData.Cooldown, slot_mc and slot_mc.cd_mc.cd_txt.htmlText or "")
						if slot_mc then
							slot_mc.setCoolDown(slotData.Cooldown)
						end
					end
				end
			end
		else
			local ui = Ext.GetUIByType(Data.UIType.bottomBar_c)
			if ui then
				local slotholder = ui:GetRoot().bottombar_mc.slotsHolder_mc
				for _,slotData in pairs(data.Slots) do
					if slotData.Index and slotData.Cooldown then
						local slot_mc = slotholder.slot_array[slotData.Index]
						if slot_mc then
							slot_mc.setCoolDown(slotData.Cooldown)
						end
					end
				end
			end
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_AddTextToCombatLog", function(call, dataStr)
	local data = Common.JsonParse(dataStr)
	if data ~= nil then
		local filter = data.Filter or 0
		local text = data.Text or ""
		if text ~= nil then
			if not Vars.ControllerEnabled then
				local ui = Ext.GetBuiltinUI("Public/Game/GUI/combatLog.swf")
				if ui then
					ui:Invoke("addTextToTab", filter, text)
				end
			else
				local ui = Ext.GetBuiltinUI("Public/Game/GUI/combatLog_c.swf")
				if ui then
					ui:Invoke("addTextEntry", text, false)
				end
			end
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_ClearCombatLog", function(call, filterStr)
	if not Vars.ControllerEnabled then
		local filter = tonumber(filterStr)
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/combatLog.swf")
		if ui then
			ui:Invoke("clearFilter", math.tointeger(filter))
		end
	else
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/combatLog_c.swf")
		if ui then
			ui:Invoke("clearAll")
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_UpdateStatusTurns", function(call, dataStr)
	local data = Common.JsonParse(dataStr)
	if data.IsPlayer then
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/playerInfo.swf")
		if ui then
			--public function setStatus(createNewIfNotExisting:Boolean, characterHandle:Number, statusHandle:Number, iconId:Number, turns:Number, cooldown:Number, tooltip:String = "") : *
			ui:Invoke("setStatus", false, Ext.HandleToDouble(data.ObjectHandle), Ext.HandleToDouble(data.StatusHandle), -1, data.Turns, data.Cooldown or 0.0, data.Tooltip or "")
		end
	elseif data.IsEnemy then
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/enemyHealthBar.swf")
		if ui then
			--public function setStatus(createNewIfNotExisting:Boolean, characterHandle:Number, statusHandle:Number, iconId:Number, turns:Number, cooldown:Number, tooltip:String = "") : *
			ui:Invoke("setStatus", false, Ext.HandleToDouble(data.Params.ObjectHandle), Ext.HandleToDouble(data.StatusHandle), -1, data.Turns, data.Cooldown or 0.0, data.Tooltip or "")
		end
	end
end)

Ext.RegisterUITypeCall(Data.UIType.msgBox, "ButtonPressed", function(ui, call, id, currentDevice)
	--print("ButtonPressed", call, id, currentDevice)
	if specialMessageBoxOpen and id == 3 then
		specialMessageBoxOpen = false
		ui:Hide()
	end
end)