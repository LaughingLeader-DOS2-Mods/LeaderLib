---@class TooltipRequestProcessor
local RequestProcessor = {
	---@type table<string,fun(request:TooltipRequest, ui:UIObject, uiType:integer, event:string, vararg):TooltipRequest>
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
	Rune = "showRuneTooltip",
	Pyramid = "pyramidOver"
}
local ControllerCharacterCreationCalls = {
	Skill = "requestSkillTooltip",
	Stat = "requestAttributeTooltip",
	Ability = "requestAbilityTooltip",
	Item = {"slotOver", "itemDollOver"},
	Talent = "requestTalentTooltip",
	Tag = "requestTagTooltip",
	Rune = "runeSlotOver",
	Pyramid = "pyramidOver"
}

local function GetNetID(obj)
	if obj then
		return obj.NetID
	end
	return nil
end

---@return TooltipRequest
local function CreateRequest()
	local request = {
		Type = ""
	}
	setmetatable(request, {
		__index = function(tbl,k)
			if k == "Character" then
				if request.CharacterNetID then
					return Ext.GetCharacter(request.CharacterNetID)
				end
			elseif k == "Item" then
				if request.ItemNetID then
					return Ext.GetItem(request.ItemNetID)
				end
			elseif k == "Status" then
				if request.StatusHandle and request.CharacterNetID then
					return Ext.GetStatus(request.CharacterNetID, Ext.DoubleToHandle(request.StatusHandle))
				end
			elseif k == "StatusId" then
				if request.StatusHandle and request.CharacterNetID then
					local status = Ext.GetStatus(request.CharacterNetID, Ext.DoubleToHandle(request.StatusHandle))
					if status then
						request.StatusId = status.StatusId
					end
				end
			end
		end
	})
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Skill] = function(request, ui, uiType, event, id)
	request.Skill = id
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Status] = function(request, ui, uiType, event, id)
	request.StatusHandle = id
	local status = Ext.GetStatus(request.Character.Handle, Ext.DoubleToHandle(id))
	if status then
		request.StatusId = status and status.StatusId or ""
	end
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Item] = function (request, ui, uiType, event, id, slot, extraArg)
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
		if id == nil then
			fprint(LOGLEVEL.WARNING, "[LeaderLib:TooltipRequestProcessor] Item handle (%s) is nil? UI(%s) Event(%s)", id, uiType, event)
			return request
		end
		request.ItemNetID = GetNetID(Ext.GetItem(Ext.DoubleToHandle(id)))
	end
	return request
end

--ExternalInterface.call("pyramidOver",param1.id,val2.x,val2.y,param1.width,param1.height,"bottom");
RequestProcessor.CallbackHandler[TooltipCalls.Pyramid] = function(request, ui, uiType, event, id, x, y, width, height, side)
	request.ItemNetID = GetNetID(Ext.GetItem(Ext.DoubleToHandle(id)))
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Stat] = function(request, ui, uiType, event, id)
	local stat = Game.Tooltip.TooltipStatAttributes[id]
	request.Stat = stat or id
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.CustomStat] = function(request, ui, uiType, event, id, index)
	request.Stat = id or -1
	request.StatIndex = index or -1
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Ability] = function(request, ui, uiType, event, id)
	if not request.Ability then
		request.Ability = Ext.EnumIndexToLabel("AbilityType", id)
	end
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Talent] = function(request, ui, uiType, event, id, ...)
	if not request.Talent then
		request.Talent = Ext.EnumIndexToLabel("TalentType", id)
	end
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
	request.Rune = nil
	request.Slot = slot
	request.StatsId = nil

	local this = ui:GetRoot()
	if this then
		if uiType == Data.UIType.uiCraft then
			local item = Ext.GetItem(Ext.DoubleToHandle(this.craftPanel_mc.runesPanel_mc.targetHit_mc.itemHandle))
			if item then
				request.ItemNetID = GetNetID(item)
				local runeBoost = item.Stats.DynamicStats[3+slot]
				request.Rune = Ext.GetStat(runeBoost.BoostName)
				request.StatsId = runeBoost.BoostName
			end
		elseif uiType == Data.UIType.craftPanel_c then
			local runePanel = this.craftPanel_mc.runePanel_mc
			if runePanel then
				local item = Ext.GetItem(Ext.DoubleToHandle(runePanel.runes_mc.runeTargetHandle))
				request.ItemNetID = GetNetID(item)
				if slot == 0 then
					-- The target item is selected instead of a rune, so this should be an item tooltip
					request.Type = "Item"
					return request
				else
					slot = slot - 1
					request.Slot = slot
					--local item = Ext.GetItem(Ext.DoubleToHandle(runePanel.item_array[runePanel.currentHLSlot].itemHandle))
					local rune = Ext.GetItem(Ext.DoubleToHandle(runePanel.item_array[runePanel.currentHLSlot].itemHandle))
					--local rune = Ext.GetItem(Ext.DoubleToHandle(runePanel.currMC.itemHandle))
		
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

function RequestProcessor.HandleCallback(requestType, ui, uiType, event, idOrHandle, statOrWidth, ...)
	local params = {...}

	local this = ui:GetRoot()

	---@type EclCharacter
	local character = nil
	local id = idOrHandle

	local characterHandle = ui:GetPlayerHandle()
	if (event == "showSkillTooltip" or event == "showStatusTooltip") then
		id = statOrWidth
		if idOrHandle ~= nil and not GameHelpers.Math.IsNaN(idOrHandle) then
			characterHandle = Ext.DoubleToHandle(idOrHandle)
		end
	end
	--charHandle is NaN in GM mode
	if event == "showSkillTooltip" and SharedData.GameMode == GAMEMODE.GAMEMASTER then
		character = GameHelpers.Client.GetGMTargetCharacter()
	end

	if not characterHandle and not character then
		if this and this.characterHandle then
			characterHandle = Ext.DoubleToHandle(this.characterHandle)
		end
	end

	if not character and characterHandle then
		character = Ext.GetCharacter(characterHandle)
	end

	if not character then
		if (uiType == Data.UIType.characterSheet or uiType == Data.UIType.statsPanel_c) then
			character = GameHelpers.Client.GetCharacterSheetCharacter(this)
		elseif (uiType == Data.UIType.playerInfo or uiType == Data.UIType.playerInfo_c) then
			--[[ Help! This shouldn't ever happen because the character handle is passed into the external call.
			We have no idea which row of statuses/whatever is being looked at for a character otherwise.--]]
			character = Client:GetCharacter()
		else
			character = Client:GetCharacter()
		end
	end

	if uiType == Data.UIType.characterCreation then
		id = statOrWidth
	end
	
	local request = CreateRequest()
	request.Type = requestType
	request.CharacterNetID = character.NetID

	RequestProcessor.Tooltip:InvokeRequestListeners(request, "before", ui, uiType, event, id, statOrWidth, ...)
	if RequestProcessor.CallbackHandler[event] then
		local b,r = xpcall(RequestProcessor.CallbackHandler[event], debug.traceback, request, ui, uiType, event, id, statOrWidth, ...)
		if b then
			RequestProcessor.Tooltip.NextRequest = r
			request = RequestProcessor.Tooltip.NextRequest
		else
			Ext.PrintError(string.format("[LeaderLib:RequestProcessor] Error invoking tooltip handler for event (%s):\n%s", event, r))
		end
	end
	if Vars.ControllerEnabled then
		Game.Tooltip.ControllerVars.LastPlayer = request.Character
	end
	RequestProcessor.Tooltip.Last.Event = event
	RequestProcessor.Tooltip.Last.UIType = uiType

	RequestProcessor.Tooltip:InvokeRequestListeners(request, "after", ui, uiType, event, id, statOrWidth, ...)
end

---@param tooltip TooltipHooks
function RequestProcessor:Init(tooltip)
	self.Tooltip = tooltip
	for t,v in pairs(TooltipCalls) do
		Ext.RegisterUINameCall(v, function(ui, event, ...) RequestProcessor.HandleCallback(t, ui, ui:GetTypeId(), event, ...) end, "Before")
	end
	for t,v in pairs(ControllerCharacterCreationCalls) do
		Ext.RegisterUITypeCall(Data.UIType.characterCreation_c, v, function(ui, event, ...) RequestProcessor.HandleCallback(t, ui, ui:GetTypeId(), event, ...) end, "Before")
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
		RequestProcessor.HandleCallback(requestType, ui, ui:GetTypeId(), event, id)
	end, "Before")
	-- slotOver is called when selecting any slot, item or not
	Ext.RegisterUITypeCall(Data.UIType.equipmentPanel_c, "slotOver", function (ui, event, ...)
		RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), event, ...)
	end, "Before")
	-- itemOver is called when selecting a slot with an item, in addition to slotOver
	-- Ext.RegisterUITypeCall(Data.UIType.equipmentPanel_c, "itemOver", function (ui, event, ...)
	-- 	RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), event, ...)
	-- end, "Before")
	Ext.RegisterUITypeCall(Data.UIType.craftPanel_c, "slotOver", function (ui, event, ...)
		RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), event, ...)
	end, "Before")
	Ext.RegisterUITypeCall(Data.UIType.partyInventory_c, "slotOver", function (ui, event, ...)
		RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), event, ...)
	end, "Before")
	-- Ext.RegisterUITypeCall(Data.UIType.craftPanel_c, "overItem", function (ui, event, ...)
	-- 	RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), event, ...)
	-- end, "Before")
	Ext.RegisterUITypeCall(Data.UIType.craftPanel_c, "runeSlotOver", function (ui, event, ...)
		RequestProcessor.HandleCallback("Rune", ui, ui:GetTypeId(), event, ...)
	end, "Before")
	Ext.RegisterUITypeCall(Data.UIType.equipmentPanel_c, "itemDollOver", function (ui, event, ...)
		RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), event, ...)
	end, "Before")
	-- Ext.RegisterUITypeCall(Data.UIType.equipmentPanel_c, "setTooltipPanelVisible", function (ui, event, visible, ...)
	-- 	RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), event, nil, nil, ...)
	-- end, "Before")
	-- When the tooltip is opened without moving slots
	Ext.RegisterUITypeCall(Data.UIType.partyInventory_c, "setTooltipVisible", function (ui, event, visible, ...)
		if visible == true then
			RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), event, nil, nil, ...)
		end
	end, "Before")

	Ext.RegisterUITypeCall(Data.UIType.trade_c, "overItem", function(ui, event, itemHandleDouble)
		RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), event, itemHandleDouble)
	end)

	Ext.RegisterUITypeCall(Data.UIType.reward_c, "refreshTooltip", function(ui, event, itemHandleDouble)
		RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), event, itemHandleDouble)
	end)
end

return RequestProcessor