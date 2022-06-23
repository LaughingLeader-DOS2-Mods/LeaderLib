local PartyInventory = Classes.UIWrapper:CreateFromType(Data.UIType.partyInventory, {ControllerID=Data.UIType.partyInventory_c, IsControllerSupported=true})

local _inventoryWasOpened = false

---@param ui UIObject
local function UnlockInventories(ui)
	if not ui then
		return
	end
	--UI Version
	--[[
	local this = ui:GetRoot()
	if not Vars.ControllerEnabled then
		local arr = this.inventory_mc.list.content_array
		for i=0,#arr-1 do
			local inv = arr[i]
			if inv and inv.id then
				ui:ExternalInterfaceCall(inv.id, false)
			end
		end
	else
		local arr = this.inventoryPanel_mc.inventoryList.content_array
		for i=0,#arr-1 do
			local inv = arr[i]
			if inv and inv.ownerHandle then
				ui:ExternalInterfaceCall(inv.ownerHandle, false)
			end
		end
	end
	]]
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

PartyInventory:RegisterInvokeListener("setSortBtnTexts", function (self, ui, event, vararg)
	if ShouldUnlockInventories() then
		_inventoryWasOpened = true
		UnlockInventories(ui)
	end
end, "After", "Keyboard")

PartyInventory:RegisterInvokeListener("setPanelTitle", function (self, ui, event, vararg)
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