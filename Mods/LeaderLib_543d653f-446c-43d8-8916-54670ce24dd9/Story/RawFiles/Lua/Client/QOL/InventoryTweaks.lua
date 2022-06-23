local PartyInventory = Classes.UIWrapper:CreateFromType(Data.UIType.partyInventory, {ControllerID=Data.UIType.partyInventory_c, IsControllerSupported=true})

local _inventoryWasOpened = false

---@param ui UIObject
local function UnlockInventories(ui)
	if not ui then
		return
	end
	for player in GameHelpers.Character.GetPlayers(false) do
		ui:ExternalInterfaceCall("lockInventory", Ext.HandleToDouble(player.Handle), false)
	end
end

local function ShouldUnlockInventories()
	local settings = SettingsManager.GetMod(ModuleUUID, false)
	if settings then
		if settings.Global:FlagEquals("LeaderLib_UnlockCharacterInventories", true) then
			return true
		end
	end
	return false
end

PartyInventory:RegisterInvokeListener("setSortBtnTexts", function (self, ui, event, ...)
	if ShouldUnlockInventories() then
		_inventoryWasOpened = true
		UnlockInventories(ui)
	end
end, "After", "Keyboard")

PartyInventory:RegisterInvokeListener("setPanelTitle", function (self, ui, event, ...)
	if ShouldUnlockInventories() then
		_inventoryWasOpened = true
		UnlockInventories(ui)
	end
end, "After", "Controller")

Ext.RegisterListener("SessionLoaded", function ()
	local settings = SettingsManager.GetMod(ModuleUUID, false)
	if settings then
		settings.Global.Flags.LeaderLib_AutoUnlockInventoryInMultiplayer:AddListener(function(id, enabled, data, settingsData)
			if enabled and (PartyInventory.Visible or _inventoryWasOpened) then
				UnlockInventories(PartyInventory.Instance)
			end
		end)
	end
end)

Ext.RegisterNetListener("LeaderLib_UnlockCharacterInventory", function(cmd, payload)
	if PartyInventory.Visible or _inventoryWasOpened then
		UnlockInventories(PartyInventory.Instance)
	end
end)