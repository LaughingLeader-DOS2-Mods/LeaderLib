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
	if ui ~= nil then
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
			for i,v in ipairs(testSelectionArray) do
				ui:SetValue("selectionInfo_array", v, i)
			end
			ui:Invoke("updateOHs")
			print("UI.StatusText", target, text, displayTime, isItem)
			--ui:Invoke("addOverhead", doubleHandle, text, displayTime)
		end
	end
end

Ext.RegisterNetListener("LeaderLib_DisplayStatusText", function(call, dataStr)
	local data = Classes.MessageData:CreateFromString(dataStr)
	if data.Params.UUID ~= nil then
		UI.StatusText(data.Params.UUID, data.Params.Text, data.Params.Duration, data.Params.IsItem)
	end
end)

function UI.DisplayMessageBox(text, title, popupType)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/msgBox.swf")
	if ui ~= nil then
		ui:Hide()
		if popupType == 1 then
			ui:Invoke("setText", text)
			ui:Invoke("showMsgbox")
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
			ui:Invoke("setPopupType", 3)
			ui:Invoke("setInputEnabled", true)
			ui:Invoke("showPopup", title, text)
		end
		ui:Show()
	end
end

Ext.RegisterNetListener("LeaderLib_DisplayMessageBox", function(call, dataStr)
	local data = Classes.MessageData:CreateFromString(dataStr)
	if data.Params.Text ~= nil then
		UI.DisplayMessageBox(data.Params.Text, data.Params.Title, data.Params.Type)
	end
end)

Ext.RegisterNetListener("LeaderLib_UnlockCharacterInventory", function(call, playersTableString)
	--ExternalInterface.call("lockInventory",this.id,this.lockBtn_mc.isActive)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/partyInventory.swf")
	if ui ~= nil then
		local players = Ext.JsonParse(playersTableString)
		for i,v in pairs(players) do
			ui:ExternalInterfaceCall("lockInventory", Ext.HandleToDouble(Ext.GetCharacter(v[1]).Handle), false)
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_AutoSortPlayerInventory", function(call, uuid)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/partyInventory.swf")
	if ui ~= nil then
		ui:ExternalInterfaceCall("autosort", Ext.HandleToDouble(Ext.GetCharacter(uuid).Handle), false)
	end
end)

Ext.RegisterNetListener("LeaderLib_Hotbar_SetSlotEnabled", function(call, dataStr)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/hotBar.swf")
	if ui ~= nil then
		local status,err = xpcall(function()
			local hotbar = ui:GetRoot().hotbar_mc
			local currentBarIndex = hotbar.cycleHotBar_mc.currentHotBarIndex or 0

			local maxSlot = (29 * currentBarIndex) - 1
			local minSlot = 29 * (currentBarIndex - 1)

			local data = Classes.MessageData:CreateFromString(dataStr)
			for i,slot in pairs(data.Params.Slots) do
				--print("slot", slot, "local slot", slot%29, "currentBarIndex", currentBarIndex, "minSlot", minSlot, "maxSlot", maxSlot)
				if slot <= maxSlot and slot >= minSlot then
					hotbar.setSlotEnabled(slot%29, data.Params.Enabled)
					PrintDebug("[LeaderLib] Set slot ", slot, "enabled to", data.Params.Enabled)
				end
			end
			return true
		end, debug.traceback)
		if not status then
			Ext.PrintError(err)
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_AddTextToCombatLog", function(call, dataStr)
	local data = MessageData:CreateFromString(dataStr)
	if data.Params ~= nil then
		local filter = data.Params.Filter or 0
		local text = data.Params.Text

		if text ~= nil then
			local ui = Ext.GetBuiltinUI("Public/Game/GUI/combatLog.swf")
			if ui ~= nil then
				ui:Invoke("addTextToTab", filter, text)
			end
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_ClearCombatLog", function(call, filterStr)
	local filter = tonumber(filterStr)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/combatLog.swf")
	if ui ~= nil then
		ui:Invoke("clearFilter", math.tointeger(filter))
	end
end)