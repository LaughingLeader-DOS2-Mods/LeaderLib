local _EXTVERSION = Ext.Version()

---@class TooltipRequestProcessor
local RequestProcessor = {
	---@type table<string,fun(request:TooltipRequest, ui:UIObject, uiType:integer, event:string, ...:SerializableValue):TooltipRequest>
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
	Pyramid = "pyramidOver",
}

local TooltipInvokes = {
	Surface = "displaySurfaceText"
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

---@param doubleHandle integer
---@return EclCharacter|EclItem
local function __TryGetObjectFromDouble(doubleHandle)
	if GameHelpers.Math.IsNaN(doubleHandle) then
		return nil
	end
	local handle = Ext.DoubleToHandle(doubleHandle)
	if GameHelpers.IsValidHandle(handle) then
		return Ext.GetGameObject(handle)
	end
	return nil
end

---@param doubleHandle integer
---@return EclCharacter|EclItem
local function _GetObjectFromDouble(doubleHandle)
	local b,result = pcall(__TryGetObjectFromDouble, doubleHandle)
	return result
end

---@return TooltipRequest
local function CreateRequest()
	local request = {
		Type = ""
	}
	setmetatable(request, {
		__index = function(tbl,k)
			if k == "Character" or k == "Item" or k == "RuneItem" then
				if request.ObjectHandleDouble then
					return _GetObjectFromDouble(request.ObjectHandleDouble)
				end
			elseif k == "Status" then
				if request.StatusHandleDouble and request.ObjectHandleDouble then
					local handle = Ext.DoubleToHandle(request.ObjectHandleDouble)
					local statusHandle = Ext.DoubleToHandle(request.StatusHandleDouble)
					if GameHelpers.IsValidHandle(handle) and GameHelpers.IsValidHandle(statusHandle) then
						return Ext.GetStatus(handle, statusHandle)
					end
				end
			elseif k == "StatusId" then
				if request.StatusHandleDouble and request.ObjectHandleDouble then
					local handle = Ext.DoubleToHandle(request.ObjectHandleDouble)
					local statusHandle = Ext.DoubleToHandle(request.StatusHandleDouble)
					if GameHelpers.IsValidHandle(handle) and GameHelpers.IsValidHandle(statusHandle) then
						local status = Ext.GetStatus(handle, statusHandle)
						if status then
							request.StatusId = status.StatusId
							return request.StatusId
						end
					end
				end
			elseif k == "Rune" then
				if not StringHelpers.IsNullOrEmpty(request.StatsId) then
					return Ext.GetStat(request.StatsId)
				end
			end
		end
	})
	return request
end

RequestProcessor.CreateRequest = CreateRequest

RequestProcessor.CallbackHandler[TooltipCalls.Skill] = function(request, ui, uiType, event, id)
	request.Skill = id
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Status] = function(request, ui, uiType, event, id)
	request.StatusHandleDouble = id
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
		request.ObjectHandleDouble = id
	end
	return request
end

--ExternalInterface.call("pyramidOver",param1.id,val2.x,val2.y,param1.width,param1.height,"bottom");
RequestProcessor.CallbackHandler[TooltipCalls.Pyramid] = function(request, ui, uiType, event, id, x, y, width, height, side)
	request.ObjectHandleDouble = id
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
		request.Ability = Ext.EnumIndexToLabel("AbilityType", id) or id
	end
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Talent] = function(request, ui, uiType, event, id, ...)
	if not request.Talent then
		request.Talent = Ext.EnumIndexToLabel("TalentType", id) or id
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
			local doubleHandle = this.craftPanel_mc.runesPanel_mc.targetHit_mc.itemHandle
			local item = Ext.GetItem(Ext.DoubleToHandle(doubleHandle))
			if item then
				request.ObjectHandleDouble = doubleHandle
				request.StatsId = item.Stats.DynamicStats[3+slot].BoostName
			end
		elseif uiType == Data.UIType.craftPanel_c then
			local runePanel = this.craftPanel_mc.runePanel_mc
			if runePanel then
				local doubleHandle = runePanel.runes_mc.runeTargetHandle
				local item = Ext.GetItem(Ext.DoubleToHandle(doubleHandle))
				request.ObjectHandleDouble = doubleHandle
				if slot == 0 then
					-- The target item is selected instead of a rune, so this should be an item tooltip
					request.Type = "Item"
					return request
				else
					slot = slot - 1
					request.Slot = slot
					request.RuneHandleDouble = runePanel.item_array[runePanel.currentHLSlot].itemHandle
					local rune = Ext.GetItem(Ext.DoubleToHandle(request.RuneHandleDouble))
					local statsID = ""
					if rune then
						statsID = rune.StatsId
					elseif item and item.Stats then
						local runeBoost = item.Stats.DynamicStats[3+slot]
						if runeBoost then
							statsID = runeBoost.BoostName
						end
					end

					request.StatsId = statsID
				end
			end
		end
	end

	return request
end

local function GetCursorSurfaces()
	local cursor = Ext.GetPickingState()
	if cursor and cursor.WorldPosition then
		if _EXTVERSION >= 56 then
			local grid = Ext.Entity.GetAiGrid()
			if grid then
				local surfaces = GameHelpers.Grid.GetSurfaces(cursor.WorldPosition[1], cursor.WorldPosition[3], grid)
				if surfaces then
					Ext.Dump(surfaces)
					return surfaces
				end
			end
		end
	end
end

RequestProcessor.CallbackHandler[TooltipInvokes.Surface] = function(request, ui, uiType, event, x, y)
	local surfaces = nil
	local cursor = Ext.GetPickingState()
	if cursor and cursor.WalkablePosition then
		request.Position = cursor.WalkablePosition
		if _EXTVERSION >= 56 then
			local grid = Ext.Entity.GetAiGrid()
			if grid then
				--surfaces = GameHelpers.Grid.GetSurfaces(x, y, grid, 0, nil, true)
				surfaces = GameHelpers.Grid.GetSurfaces(cursor.WalkablePosition[1], cursor.WalkablePosition[3], grid, 0, nil, true)
				--surfaces = GameHelpers.Grid.GetSurfaces(cursor.WorldPosition[1], cursor.WorldPosition[3], grid, 1)
			end
		end
	end
	if surfaces then
		if surfaces.Flags then
			request.Flags = surfaces.Flags
		end
		if surfaces.Ground then
			request.Ground = surfaces.Ground
		end
		if surfaces.Cloud then
			request.Cloud = surfaces.Cloud
		end
	end
	--Ext.Dump({Cursor = cursor, Request=request, Surfaces=surfaces or "nil"})
	return request
end

---The last double handle of the object under the cursor in KB+M mode, when the context menu was opened.
---@type number|nil
local lastCursorObjectDoubleHandle = nil

local function _CaptureCursorObject(ui, event)
	local cursor = Ext.GetPickingState()
	if cursor then
		if GameHelpers.IsValidHandle(cursor.HoverCharacter) then
			lastCursorObjectDoubleHandle = Ext.HandleToDouble(cursor.HoverCharacter)
		elseif GameHelpers.IsValidHandle(cursor.HoverCharacter2) then
			lastCursorObjectDoubleHandle = Ext.HandleToDouble(cursor.HoverCharacter2)
		elseif GameHelpers.IsValidHandle(cursor.HoverItem) then
			lastCursorObjectDoubleHandle = Ext.HandleToDouble(cursor.HoverItem)
		end
	end
end

local function _OnExamineWindowClosed(ui, event)
	lastCursorObjectDoubleHandle = nil
end

Ext.RegisterUITypeInvokeListener(Data.UIType.contextMenu.Object, "open", _CaptureCursorObject)
Ext.RegisterUITypeCall(Data.UIType.examine, "hideUI", _OnExamineWindowClosed)

--ExternalInterface.call("showTooltip",param1.type,param2,val3.x,val3.y + val5,val4,param1.height,"right");
function RequestProcessor.OnExamineTooltip(ui, method, typeIndex, id, ...)
	local object = nil

	--id is nil for statuses, for some reason

	local params = {...}

	--GetPlayerHandle returns the examine character or item
	local handle = ui:GetPlayerHandle()
	if GameHelpers.IsValidHandle(handle) then
		object = GameHelpers.TryGetObject(handle)
	end

	if object == nil and lastCursorObjectDoubleHandle then
		object = GameHelpers.TryGetObject(Ext.DoubleToHandle(lastCursorObjectDoubleHandle))
	end

	if not object then
		object = Client:GetCharacter()
	end
	
	local request = CreateRequest()
	
	if object then
		request.ObjectHandleDouble = Ext.HandleToDouble(object.Handle)
	end

	if typeIndex == 1 then
		request.Type = "Stat"
		request.Stat = Game.Tooltip.TooltipStatAttributes[id]

		if request.Stat == nil then
			Ext.PrintWarning("Requested tooltip for unknown stat ID " .. id)
		end
	elseif typeIndex == 2 then
		request.Type = "Ability"
		request.Ability = Ext.EnumIndexToLabel("AbilityType", id) or id
	elseif typeIndex == 3 then
		if id == 0 then
			--Tooltip for "This character has no talents" doesn't exist.
			RequestProcessor.Tooltip.Last.Event = method
			RequestProcessor.Tooltip.Last.UIType = ui:GetTypeId()
			return
		else
			request.Type = "Talent"
			request.Talent = Ext.EnumIndexToLabel("TalentType", id) or id
		end
	elseif typeIndex == 7 then
		request.Type = "Status"
		if id then
			local statusHandle = Ext.DoubleToHandle(id)
			if GameHelpers.IsValidHandle(statusHandle) then
				request.StatusHandleDouble = id
				local status = Ext.GetStatus(object.Handle, statusHandle)
				if status then
					request.StatusId = status and status.StatusId or ""
				end
			end
		end
	else
		local text = typeIndex
		local x = id
		local y, width, height, side, allowDelay = table.unpack(params)
		--text, x, y, width, height, side, allowDelay
		--Generic type
		request.Type = "Generic"
		request.Text = text
		request.UIType = ui:GetTypeId()
		if x then
			request.X = x
			request.Y = y
			request.Width = width
			request.Height = height
			request.Side = side
			request.AllowDelay = allowDelay
		end
	end

	if RequestProcessor.Tooltip.NextRequest ~= nil then
		Ext.PrintWarning("Previous tooltip request not cleared in render callback?")
	end

	RequestProcessor.Tooltip.NextRequest = request
	RequestProcessor.Tooltip.Last.Event = method
	RequestProcessor.Tooltip.Last.UIType = ui:GetTypeId()
end

function RequestProcessor.OnGenericTooltip(ui, call, text, x, y, width, height, side, allowDelay)
	if RequestProcessor.Tooltip.NextRequest == nil then
		---@type TooltipGenericRequest
		local request = CreateRequest()
		request.Type = "Generic"
		request.Text = text
		request.UIType = ui:GetTypeId()

		if x then
			request.X = x
			request.Y = y
			request.Width = width
			request.Height = height
			request.Side = side
			request.AllowDelay = allowDelay
		end

		RequestProcessor.Tooltip.NextRequest = request
		RequestProcessor.Tooltip.Last.Event = call
		RequestProcessor.Tooltip.Last.UIType = request.UIType
	end
end

function RequestProcessor.HandleCallback(requestType, ui, uiType, event, idOrHandle, statOrWidth, ...)
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
	request.ObjectHandleDouble = Ext.HandleToDouble(character.Handle)

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
	for t,v in pairs(TooltipInvokes) do
		Ext.RegisterUINameInvokeListener(v, function(ui, event, ...) RequestProcessor.HandleCallback(t, ui, ui:GetTypeId(), event, ...) end, "Before")
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

	--Generic tooltips
	Ext.RegisterUINameCall("showTooltip", function(ui, ...)
		if ui:GetTypeId() == Data.UIType.examine then
			RequestProcessor.OnExamineTooltip(ui, ...)
		else
			RequestProcessor.OnGenericTooltip(ui, ...)
		end
	end, "Before")
end

--TODO Implement World tooltip editing with Game.Tooltip

Events.OnWorldTooltip:Subscribe(function (e)
	if e.Item and Game.Tooltip.TooltipHooks.Last.Request == nil then
		local request = CreateRequest()
		request.Type = "World"
		request.Text = e.Text
		if e.Item then
			request.ObjectHandleDouble = Ext.HandleToDouble(e.Item.Handle)
			request.IsFromItem = true
		else
			request.IsFromItem = false
		end
		Game.Tooltip.TooltipHooks.Last.Request = request
	end
end, {Priority=0})

--Hack to clear the last tooltip being "World"
Ext.RegisterUINameInvokeListener("removeTooltip", function(ui, ...)
	local lastRequest = Game.Tooltip.TooltipHooks.Last.Request
	if lastRequest and lastRequest.Type == "World" then
		Game.Tooltip.TooltipHooks.Last.Request = nil
	end
end)

return RequestProcessor