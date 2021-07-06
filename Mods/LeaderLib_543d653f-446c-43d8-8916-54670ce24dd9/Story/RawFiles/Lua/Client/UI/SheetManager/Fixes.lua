--local function ActuallySetCharacterHandle(ui, this, player, uiType, uiName)
local function ActuallySetCharacterHandle(ui, call)
	PrintDebug("ActuallySetCharacterHandle", Data.UITypeToName[ui:GetTypeId()], call)
	local player = Client:GetCharacter()
	if player then
		local doubleHandle = Ext.HandleToDouble(player.Handle)
		ui:SetValue("characterHandle", doubleHandle)
		ui:SetValue("charHandle", doubleHandle)
		fprint(LOGLEVEL.ERROR, "Set characterHandle to (%s) in UI (%s)[%s]", player.DisplayName, uiName, uiType)
	end
end

local uiTypes = {Data.UIType.characterCreation, Data.UIType.characterCreation_c, Data.UIType.characterSheet, Data.UIType.statsPanel_c}
-- UI.RegisterUICreatedListener(uiTypes, ActuallySetCharacterHandle)

Ext.RegisterUINameCall("characterCreationStarted", ActuallySetCharacterHandle, "After")

local function UpdateSheetHandlesAfterHotbar(hotBar, method, doubleHandle)
	if doubleHandle ~= nil then
		for i=1,#uiTypes do
			local ui = Ext.GetUIByType(uiTypes[i])
			if ui then
				ui:SetValue("characterHandle", doubleHandle)
				ui:SetValue("charHandle", doubleHandle)
			end
		end
	end
end
Ext.RegisterUITypeInvokeListener(Data.UIType.hotBar, "setPlayerHandle", UpdateSheetHandlesAfterHotbar)
Ext.RegisterUITypeInvokeListener(Data.UIType.bottomBar_c, "setPlayerHandle", UpdateSheetHandlesAfterHotbar)

Ext.RegisterNetListener("LeaderLib_CCStarted", function(cmd, netid)
	PrintDebug(cmd, netid)
	-- local ui = Ext.GetUIByType(Data.UIType.characterCreation)
	-- if ui then
	-- 	ui:CaptureExternalInterfaceCalls()
	-- 	ui:CaptureInvokes()
	-- end
end)