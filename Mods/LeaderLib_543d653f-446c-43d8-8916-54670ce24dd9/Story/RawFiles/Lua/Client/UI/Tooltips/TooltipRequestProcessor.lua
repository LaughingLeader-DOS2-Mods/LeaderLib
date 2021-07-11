---@class TooltipRequestProcessor
local RequestProcessor = {
	---@type table<string,fun(request:TooltipRequest, ui:UIObject, uiType:integer, event:string, vararg any):Request>
	CallbackHandler = {},
	---@type TooltipHooks
	Tooltip = nil
}

local TooltipCalls = {
	Skill = "showSkillTooltip",
	Status = "showStatusTooltip",
	Item ="showItemTooltip",
	Stat = "showStatTooltip",
	Ability = "showAbilityTooltip",
	Talent = "showTalentTooltip",
	Tag = "showTagTooltip",
	CustomStat = "showCustomStatTooltip",
	Rune = "showRuneTooltip"
}
local ControllerCharacterCreationCalls = {
	Skill = "requestSkillTooltip",
	Stat = "requestAttributeTooltip",
	Ability = "requestAbilityTooltip",
	Item = {"slotOver", "itemDollOver"},
	Talent = "requestTalentTooltip",
	Tag = "requestTagTooltip",
	Rune = "runeSlotOver"
}

RequestProcessor.CallbackHandler[TooltipCalls.Skill] = function(request, ui, uiType, event, id)
	request.Skill = id
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Status] = function(request, ui, uiType, event, id)
	request.Status = Ext.GetStatus(request.Character.Handle, Ext.DoubleToHandle(id))
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Item] = function(request, ui, uiType, event, id, slot, extraArg)
	if uiType == Data.UIType.partyInventory_c then
		local this = ui:GetRoot()
		local ownerHandle = extraArg
		if ownerHandle == nil then
			ownerHandle = this.ownerHandle
		end
		if id == nil then
			local inventoryArray = this.inventoryPanel_mc.inventoryList.content_array
			for i=0,#inventoryArray do
				local playerInventory = inventoryArray[i]
				if playerInventory ~= nil then
					local localInventory = playerInventory.localInventory
					if localInventory._currentIdx >= 0 then
						local currentItem = localInventory._itemArray[localInventory._currentIdx]
						if currentItem ~= nil then
							id = currentItem.itemHandle
						end
						if ownerHandle == nil then
							ownerHandle = playerInventory.ownerHandle
						end
					end
				end
			end
		end
		if ownerHandle ~= nil and ownerHandle ~= 0 then
			local inventoryHandle = Ext.DoubleToHandle(ownerHandle)
			if inventoryHandle ~= nil then
				request.Inventory = Ext.GetGameObject(inventoryHandle)
			end
		end
	else
		request.Item = Ext.GetItem(Ext.DoubleToHandle(id))
	end
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Stat] = function(request, ui, uiType, event, id)
	local stat = Game.Tooltip.TooltipStatAttributes[id]
	request.Stat = stat or id
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.CustomStat] = function(request, ui, uiType, event, id)
	request.Stat = id
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Ability] = function(request, ui, uiType, event, id)
	request.Ability = Ext.EnumIndexToLabel("AbilityType", id)
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Talent] = function(request, ui, uiType, event, id)
	request.Talent = Ext.EnumIndexToLabel("TalentType", id)
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Tag] = function(request, ui, uiType, event, id, arg2)
	request.Tag = id
	request.Category = ""
	if uiType == Data.UIType.characterCreation then
		local this = ui:GetRoot()
		for i=0,#this.CCPanel_mc.tags_mc.tagList.content_array-1 do
			local tag = this.CCPanel_mc.tags_mc.tagList.content_array[i]
			if tag and tag.tagID == id then
				request.Category = tag.categoryID
				break
			end
		end
	elseif uiType == Data.UIType.characterCreation_c then
		request.Tag = arg2
		request.Category = id
	end
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Rune] = function(request, ui, uiType, event, slot)
	request.Item = nil
	request.Rune = nil
	request.Slot = slot
	request.StatsId = nil

	local this = ui:GetRoot()
	if this then
		if uiType == Data.UIType.uiCraft then
			local item = Ext.GetItem(Ext.DoubleToHandle(this.craftPanel_mc.runesPanel_mc.targetHit_mc.itemHandle))
			if item then
				request.Item = item
				local runeBoost = item.Stats.DynamicStats[3+slot]
				request.Rune = Ext.GetStat(runeBoost.BoostName)
				request.StatsId = runeBoost.BoostName
			end
		elseif uiType == Data.UIType.craftPanel_c then
			local runePanel = this.craftPanel_mc.runePanel_mc
			if runePanel then
				local item = Ext.GetItem(Ext.DoubleToHandle(runePanel.runes_mc.runeTargetHandle))
				if slot == 0 then
					-- The target item is selected instead of a rune, so this should be an item tooltip
					request = {
						Type = "Item",
						Item = item
					}
					return request
				else
					slot = slot - 1
					request.Slot = slot
					--local item = Ext.GetItem(Ext.DoubleToHandle(runePanel.item_array[runePanel.currentHLSlot].itemHandle))
					local rune = Ext.GetItem(Ext.DoubleToHandle(runePanel.item_array[runePanel.currentHLSlot].itemHandle))
					--local rune = Ext.GetItem(Ext.DoubleToHandle(runePanel.currMC.itemHandle))
		
					request.Item = item
		
					if rune then
						request.Rune = Ext.GetStat(rune.StatsId)
						request.StatsId = rune.StatsId
						request.RuneItem = rune
					elseif item and item.Stats then
						local runeBoost = item.Stats.DynamicStats[3+slot]
						request.Rune = Ext.GetStat(runeBoost.BoostName)
						request.StatsId = runeBoost.BoostName
					end
				end
			end
		end
	end

	return request
end

function RequestProcessor.HandleStatCallback(requestType, ui, uiType, event, idOrHandle, statOrWidth, ...)
	local params = {...}

	local this = ui:GetRoot()

	---@type EclCharacter
	local character = nil
	local id = idOrHandle

	local characterHandle = ui:GetPlayerHandle()
	if event == "showSkillTooltip" or event == "showStatusTooltip" then
		id = statOrWidth
		characterHandle = Ext.DoubleToHandle(idOrHandle)
	end

	if not characterHandle then
		if this and this.characterHandle then
			characterHandle = Ext.DoubleToHandle(this.characterHandle)
		end
	end

	if characterHandle then
		character = Ext.GetCharacter(characterHandle)
	end

	if not character then
		character = Client:GetCharacter()
	end

	if uiType == Data.UIType.characterCreation then
		id = statOrWidth
	elseif event == "showSkillTooltip" then
		id = statOrWidth
		characterHandle = id
	end
	local request = {
		Type = requestType,
		Character = character
	}
	if RequestProcessor.CallbackHandler[event] then
		local b,r = xpcall(RequestProcessor.CallbackHandler[event], debug.traceback, request, ui, uiType, event, id, statOrWidth, ...)
		if b then
			RequestProcessor.Tooltip.NextRequest = r
		else
			Ext.PrintError(string.format("[LeaderLib:RequestProcessor] Error invoking tooltip handler for event (%s):\n%s", event, r))
		end
	end
	if Vars.ControllerEnabled then
		Game.Tooltip.ControllerVars.LastPlayer = request.Character
	end
	RequestProcessor.Tooltip.Last.Event = event
	RequestProcessor.Tooltip.Last.UIType = uiType

	if event == "showCustomStatTooltip" then
		CustomStatSystem:OnRequestTooltip(ui, event, request.Stat, request.Character, table.unpack(params))
	end
end

---@param tooltip TooltipHooks
function RequestProcessor:Init(tooltip)
	self.Tooltip = tooltip
	for t,v in pairs(TooltipCalls) do
		Ext.RegisterUINameCall(v, function(ui, event, ...) RequestProcessor.HandleStatCallback(t, ui, ui:GetTypeId(), event, ...) end, "Before")
	end
	for t,v in pairs(ControllerCharacterCreationCalls) do
		Ext.RegisterUITypeCall(Data.UIType.characterCreation_c, v, function(ui, event, ...) RequestProcessor.HandleStatCallback(t, ui, ui:GetTypeId(), event, ...) end, "Before")
	end

	--Custom controller tooltip calls.
	Ext.RegisterUITypeCall(Data.UIType.bottomBar_c, "SlotHover", function (ui, event, slotNum)
		local this = ui:GetRoot()
		local slotsHolder_mc = this.bottombar_mc.slotsHolder_mc
		local slotType = slotsHolder_mc.tooltipSlotType
		local slotHandle = slotsHolder_mc.tooltipSlot

		local requestType = "Skill"
		local id = nil
		-- 4 is for non-skills like Flee, Sheathe etc
		if slotType == 1 or slotType == 4 then
			id = slotsHolder_mc.tooltipStr
		elseif slotType == 2 then
			-- Sometimes tooltipSlot will be set to the tooltip index instead of the slot's handle value
			if slotNum == slotHandle then
				local slot = slotsHolder_mc.slot_array[slotNum]
				if slot then
					slotHandle = slot.handle
				end
			end
			if slotHandle and slotNum ~= slotHandle then
				local handle = Ext.DoubleToHandle(slotHandle)
				if handle then
					requestType = "Item"
					id = handle
				end
			end
		end
		RequestProcessor.HandleStatCallback(requestType, ui, ui:GetTypeId(), event, id)
	end, "Before")
	-- slotOver is called when selecting any slot, item or not
	Ext.RegisterUITypeCall(Data.UIType.equipmentPanel_c, "slotOver", function (ui, event, ...)
		RequestProcessor.HandleStatCallback("Item", ui, ui:GetTypeId(), event, ...)
	end, "Before")
	-- itemOver is called when selecting a slot with an item, in addition to slotOver
	-- Ext.RegisterUITypeCall(Data.UIType.equipmentPanel_c, "itemOver", function (ui, event, ...)
	-- 	RequestProcessor.HandleStatCallback("Item", ui, ui:GetTypeId(), event, ...)
	-- end, "Before")
	Ext.RegisterUITypeCall(Data.UIType.craftPanel_c, "slotOver", function (ui, event, ...)
		RequestProcessor.HandleStatCallback("Item", ui, ui:GetTypeId(), event, ...)
	end, "Before")
	Ext.RegisterUITypeCall(Data.UIType.partyInventory_c, "slotOver", function (ui, event, ...)
		RequestProcessor.HandleStatCallback("Item", ui, ui:GetTypeId(), event, ...)
	end, "Before")
	-- Ext.RegisterUITypeCall(Data.UIType.craftPanel_c, "overItem", function (ui, event, ...)
	-- 	RequestProcessor.HandleStatCallback("Item", ui, ui:GetTypeId(), event, ...)
	-- end, "Before")
	Ext.RegisterUITypeCall(Data.UIType.craftPanel_c, "runeSlotOver", function (ui, event, ...)
		RequestProcessor.HandleStatCallback("Rune", ui, ui:GetTypeId(), event, ...)
	end, "Before")
	Ext.RegisterUITypeCall(Data.UIType.equipmentPanel_c, "itemDollOver", function (ui, event, ...)
		RequestProcessor.HandleStatCallback("Item", ui, ui:GetTypeId(), event, ...)
	end, "Before")
	-- Ext.RegisterUITypeCall(Data.UIType.equipmentPanel_c, "setTooltipPanelVisible", function (ui, event, visible, ...)
	-- 	RequestProcessor.HandleStatCallback("Item", ui, ui:GetTypeId(), event, nil, nil, ...)
	-- end, "Before")
	-- When the tooltip is opened without moving slots
	Ext.RegisterUITypeCall(Data.UIType.partyInventory_c, "setTooltipVisible", function (ui, event, visible, ...)
		if visible == true then
			RequestProcessor.HandleStatCallback("Item", ui, ui:GetTypeId(), event, nil, nil, ...)
		end
	end, "Before")

	Ext.RegisterUITypeCall(Data.UIType.trade_c, "overItem", function(ui, event, itemHandleDouble)
		RequestProcessor.HandleStatCallback("Item", ui, ui:GetTypeId(), event, itemHandleDouble)
	end)

	Ext.RegisterUITypeCall(Data.UIType.reward_c, "refreshTooltip", function(ui, event, itemHandleDouble)
		RequestProcessor.HandleStatCallback("Item", ui, ui:GetTypeId(), event, itemHandleDouble)
	end)
end

return RequestProcessor