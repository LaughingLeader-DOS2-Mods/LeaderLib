
local function Net_EnableFeature(channel, id)
	Features[id] = true
end

Ext.RegisterNetListener("LeaderLib_EnableFeature", Net_EnableFeature)

local function Net_DisableFeature(channel, id)
	Features[id] = false
end

Ext.RegisterNetListener("LeaderLib_DisableFeature", Net_DisableFeature)

Ext.RegisterNetListener("LeaderLib_DisplayMessageBox", function(call, dataStr)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/msgBox.swf")
	if ui ~= nil then
		ui:Hide()
		local data = Classes.MessageData:CreateFromString(dataStr)
		if data.Params.Text ~= nil then
			if data.Params.Type == 1 then
				ui:Invoke("setText", data.Params.Text)
				ui:Invoke("showMsgbox")
			else
				--ui:Invoke("setAnchor", 0)
				--ui:Invoke("setPos", 50.0, 50.0)
				--ui:Invoke("setText", data.Params.Text)
				ui:Invoke("removeButtons")
				ui:Invoke("addButton", 3, "OK", "", "")
				--ui:Invoke("addBlueButton", 3, "OK")
				--ui:Invoke("addYesButton", 1)
				ui:Invoke("showWin")
				ui:Invoke("fadeIn")
				--ui:Invoke("setWaiting", true)
				ui:Invoke("setPopupType", 3)
				ui:Invoke("setInputEnabled", true)
				ui:Invoke("showPopup", data.Params.Title, data.Params.Text)
			end
			ui:Show()
		end
	end
	print(call, dataStr, ui ~= nil)
end)