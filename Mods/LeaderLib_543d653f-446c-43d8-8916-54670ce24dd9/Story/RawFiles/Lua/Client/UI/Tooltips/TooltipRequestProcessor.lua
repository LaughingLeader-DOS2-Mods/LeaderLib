local _EXTVERSION = Ext.Version()
local _DEBUG = Ext.IsDeveloperMode()

local _type = type

local _IsValidHandle = GameHelpers.IsValidHandle
local _DoubleToHandle = Ext.DoubleToHandle
local _HandleToDouble = Ext.HandleToDouble

local _IsNaN = GameHelpers.Math.IsNaN

local _GetUIByType = Ext.GetUIByType
local _GetUIGetByPath = Ext.GetBuiltinUI
local _ObjectIsItem = GameHelpers.Ext.ObjectIsItem
local _ItemIsObject = GameHelpers.Item.IsObject

local _GetStat = Ext.GetStat
local _GetTranslatedString = Ext.GetTranslatedString
local _GetTranslatedStringFromKey = Ext.GetTranslatedStringFromKey

local _GetAiGrid = Ext.GetAiGrid
local _GetStatus = Ext.GetStatus
local _GetGameObject = GameHelpers.TryGetObject
local _GetCharacter = Ext.GetCharacter
local _GetItem = Ext.GetItem
local _GetPickingState = Ext.GetPickingState

local _GetGameMode = Ext.GetGameMode

local _EnumIndexToLabel = Ext.EnumIndexToLabel

local _PrintWarning = Ext.PrintWarning
local _PrintError = Ext.PrintError
local _Print = Ext.Print

local _UITYPE = Data.UIType

---@class GameTooltipRequestProcessor
local RequestProcessor = {
	---@type table<string,fun(request:TooltipRequest, ui:UIObject, uiType:integer, event:string, ...:boolean|string|number):TooltipRequest>
	CallbackHandler = {},
	---@type TooltipHooks
	Tooltip = nil,
	ControllerEnabled = false,
}

---@class GameTooltipRequestProcessorInternals
local _INTERNAL = {}
RequestProcessor._Internal = _INTERNAL

RequestProcessor.ControllerEnabled = (_GetUIGetByPath("Public/Game/GUI/msgBox_c.swf") or _GetUIByType(_UITYPE.msgBox_c)) ~= nil

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
	PlayerPortrait = "showCharTooltip",
	-- World = "updateTooltips",
	-- WorldHover = "setText",
}

local TooltipInvokes = {
	Surface = "displaySurfaceText"
}

local ControllerCharacterCreationCalls = {
	Skill = "requestSkillTooltip",
	Stat = "requestAttributeTooltip",
	Ability = "requestAbilityTooltip",
	Talent = "requestTalentTooltip",
	Tag = "requestTagTooltip",
}

---@alias GameTooltipRequestProcessorInternals.GetObjectFunction fun(handle:ComponentHandle|number|string):EclCharacter|EclItem|nil

---@param doubleHandle integer
---@param getObjectFunc GameTooltipRequestProcessorInternals.GetObjectFunction|nil
---@return EclCharacter|EclItem|nil
local function __TryGetObjectFromDouble(doubleHandle, getObjectFunc)
	if _IsNaN(doubleHandle) then
		return nil
	end
	local handle = _DoubleToHandle(doubleHandle)
	if _IsValidHandle(handle) then
		getObjectFunc = getObjectFunc or _GetGameObject
		return getObjectFunc(handle)
	end
	return nil
end

---@param doubleHandle number
---@param getObjectFunc function|nil
---@return EclCharacter|EclItem|nil
local function _GetObjectFromDouble(doubleHandle, getObjectFunc)
	local b,result = pcall(__TryGetObjectFromDouble, doubleHandle, getObjectFunc)
	if b then
		return result
	elseif _DEBUG then
		Ext.PrintError(result)
	end
	return nil
end

---@param handle ComponentHandle|nil
---@param getObjectFunc function|nil
---@return EclCharacter|EclItem|nil
local function _GetObjectFromHandle(handle, getObjectFunc)
	if _IsValidHandle(handle) then
		if not getObjectFunc then
			getObjectFunc = _GetGameObject
		end
		local b,result = pcall(getObjectFunc, handle)
		if b then
			return result
		elseif _DEBUG then
			Ext.PrintError(result)
			Ext.PrintError("_GetObjectFromHandle", handle)
		end
	end
	return nil
end

---Get the GM's target character in GM mode.
---@return EclCharacter
local function _GetGMTargetCharacter()
	local ui = _GetUIByType(_UITYPE.GMPanelHUD)
	if ui then
		local this = ui:GetRoot()
		if this then
			return _GetObjectFromDouble(this.targetHandle, _GetCharacter)
		end
	end
	return nil
end

---Tries to get the client's current character.
---@return EclCharacter|nil
local function _GetClientCharacter()
	local character = nil
	if not RequestProcessor.ControllerEnabled then
		local ui = _GetUIByType(_UITYPE.hotBar)
		if ui ~= nil then
			local this = ui:GetRoot()
			if this ~= nil then
				character = _GetObjectFromDouble(this.hotbar_mc.characterHandle, _GetCharacter)
			end
		end
		if not character then
			local ui = _GetUIByType(_UITYPE.statusConsole)
			if ui then
				character = _GetObjectFromHandle(ui:GetPlayerHandle(), _GetCharacter)
			end
		end
		if not character and _GetGameMode() == "GameMaster" then
			character = _GetGMTargetCharacter()
		end
	else
		local ui = _GetUIByType(_UITYPE.bottomBar_c)
		if ui ~= nil then
			local this = ui:GetRoot()
			if this ~= nil then
				character = _GetObjectFromDouble(this.characterHandle, _GetCharacter)
			end
		end
		if not character then
			local ui = _GetUIByType(_UITYPE.statusConsole)
			if ui ~= nil then
				character = _GetObjectFromHandle(ui:GetPlayerHandle(), _GetCharacter)
			end
		end
	end
	return character
end

---Get the current character stored in characterSheet's main timeline.
---@param this {characterHandle:number|nil}|nil
---@return EclCharacter
local function _GetCharacterSheetCharacter(this)
	local character = nil
	if this == nil then
		if not RequestProcessor.ControllerEnabled then
			local ui = _GetUIByType(_UITYPE.characterSheet)
			if ui then
				this = ui:GetRoot()
			end
		else
			local ui = _GetUIByType(_UITYPE.statsPanel_c)
			if ui then
				this = ui:GetRoot()
			end
		end
	end
	if this ~= nil then
		character = _GetObjectFromDouble(this.characterHandle, _GetCharacter)
	end
	return character or _GetClientCharacter()
end

local _StatsIdTooltipTypes = {
	Item = true,
	Pyramid = true,
	Rune = true,
}

local _ObjectParamNames = {
	Character = true,
	Item = true,
	RuneItem = true,
	Object = true,
}

---@return TooltipRequest
local function _CreateRequest()
	local request = {
		Type = ""
	}
	--Support lifetime changes by getting the object on the fly
	setmetatable(request, {
		__index = function(tbl,k)
			local tooltipType = rawget(tbl, "Type")
			if _ObjectParamNames[k] then
				local objectHandleDouble = rawget(tbl, "ObjectHandleDouble")
				if objectHandleDouble then
					if k == "Character" then
						return _GetObjectFromDouble(objectHandleDouble, _GetCharacter)
					elseif k == "Item" or k == "RuneItem" then
						return _GetObjectFromDouble(objectHandleDouble, _GetItem)
					elseif "Object" then
						return _GetObjectFromDouble(objectHandleDouble)
					end
				end
			else
				if k == "Owner" and tooltipType == "Item" then
					local objectHandleDouble = rawget(tbl, "OwnerDoubleHandle")
					if objectHandleDouble then
						return _GetObjectFromDouble(objectHandleDouble)
					end
				elseif k == "StatsId" and _StatsIdTooltipTypes[tooltipType] then
					local objectHandleDouble = rawget(tbl, "ObjectHandleDouble")
					if objectHandleDouble then
						local obj = _GetObjectFromDouble(objectHandleDouble)
						if obj and _ObjectIsItem(obj) then
							rawset(tbl, "StatsId", obj.StatsId)
							return obj.StatsId
						end
					end
				elseif k == "Status" or k == "StatusId" then
					local objectHandleDouble = rawget(tbl, "ObjectHandleDouble")
					local statusHandleDouble = rawget(tbl, "StatusHandleDouble")
					if statusHandleDouble and objectHandleDouble then
						local handle = _DoubleToHandle(objectHandleDouble)
						local statusHandle = _DoubleToHandle(request.StatusHandleDouble)
						if _IsValidHandle(handle) and _IsValidHandle(statusHandle) then
							local status = _GetStatus(handle, statusHandle)
							if status then
								if k == "StatusId" then
									rawset(tbl, "StatusId", status.StatusId)
									return status.StatusId
								else
									return status
								end
							end
						end
					end
				elseif k == "Rune" then
					local statsId = rawget(tbl, "StatsId")
					if statsId ~= nil and statsId ~= "" then
						return _GetStat(statsId)
					end
				end
			end
		end
	})
	return request
end

RequestProcessor.CreateRequest = _CreateRequest

RequestProcessor.CallbackHandler[TooltipCalls.Skill] = function(request, ui, uiType, event, id)
	request.Skill = id
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Status] = function(request, ui, uiType, event, id)
	request.StatusHandleDouble = id
	local b,status = pcall(_GetStatus, _DoubleToHandle(request.ObjectHandleDouble), _DoubleToHandle(id))
	if b and status then
		request.StatusId = status and status.StatusId or ""
	end
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Item] = function (request, ui, uiType, event, ...)
	local params = {...}
	if uiType == _UITYPE.partyInventory_c then
		local this = ui:GetRoot()
		local id = params[1]
		local slot = params[2]
		local handleDouble = params[3]
		local ownerHandle = handleDouble
		if ownerHandle == nil then
			ownerHandle = this.ownerHandle
		end
		if id == nil then
			local inventoryArray = this.inventoryPanel_mc.inventoryList.content_array
			for i=0,#inventoryArray do
				local playerInventory = inventoryArray[i]
				if playerInventory ~= nil then
					if ownerHandle == nil then
						ownerHandle = playerInventory.ownerHandle
					end
					local localInventory = playerInventory.localInventory
					if localInventory._currentIdx >= 0 then
						local currentItem = localInventory._itemArray[localInventory._currentIdx]
						if currentItem ~= nil then
							id = currentItem.itemHandle
							break
						end
					end
				end
			end
		end
		if id then
			request.ObjectHandleDouble = id
		end
		if ownerHandle ~= nil and ownerHandle ~= 0 then
			local inventoryHandle = _DoubleToHandle(ownerHandle)
			if _IsValidHandle(inventoryHandle) then
				request.OwnerDoubleHandle = ownerHandle
			end
		end
	elseif uiType == _UITYPE.uiCraft then
		--Tooltip support for ingredient tooltips
		local id,x,y,width,height,contextParam,side = table.unpack(params)
		if id == 0 then
			--mc.itemHandle is always 0 for ingredients in the recipe UI, which is the first param		
			request.ObjectHandleDouble = nil
			request.Type = "Generic"
			request.X = x
			request.Y = y
			request.Width = width
			request.Height = height
			request.Side = side
			request.AllowDelay = false
		elseif id ~= nil then
			--The Combine tab sends a proper handle
			request.ObjectHandleDouble = id
		else
			_PrintWarning(string.format("[Game.Tooltip.RequestProcessor:%s] Item handle (%s) is nil? UI(%s)", event, id, uiType))
		end
	elseif uiType == _UITYPE.containerInventory.Default or uiType == _UITYPE.containerInventory.Pickpocket then
		local doubleHandle = params[1]
		if not _IsNaN(doubleHandle) and doubleHandle > 0 then
			request.ObjectHandleDouble = doubleHandle
		end
	else
		local id = params[1]
		if _IsNaN(id) then
			_PrintWarning(string.format("[Game.Tooltip.RequestProcessor:%s] Item handle (%s) is nil? UI(%s)", event, id, uiType))
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
	if request.Stat == nil then
		local stat = Game.Tooltip.TooltipStatAttributes[id]
		request.Stat = stat or id
	end
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.CustomStat] = function(request, ui, uiType, event, id, index)
	if request.Stat == nil then
		request.Stat = id or -1
		request.StatIndex = index or -1
	end
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Ability] = function(request, ui, uiType, event, id)
	if request.Ability == nil then
		request.Ability = _EnumIndexToLabel("AbilityType", id) or id
	end
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Talent] = function(request, ui, uiType, event, id, ...)
	if request.Talent == nil then
		request.Talent = _EnumIndexToLabel("TalentType", id) or id
	end
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Tag] = function(request, ui, uiType, event, id, arg2)
	request.Tag = id
	request.Category = ""
	if uiType == _UITYPE.characterCreation then
		local this = ui:GetRoot()
		for i=0,#this.CCPanel_mc.tags_mc.tagList.content_array-1 do
			local tag = this.CCPanel_mc.tags_mc.tagList.content_array[i]
			if tag and tag.tagID == id then
				request.Category = tag.categoryID
				break
			end
		end
	elseif uiType == _UITYPE.characterCreation_c then
		request.Tag = arg2
		request.Category = id
	end
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.PlayerPortrait] = function(request, ui, uiType, event, id, x, y, width, height, side)
	request.ObjectHandleDouble = id
	return request
end

RequestProcessor.CallbackHandler[TooltipCalls.Rune] = function(request, ui, uiType, event, slot)
	request.Rune = nil
	request.Slot = slot
	request.StatsId = nil

	local this = ui:GetRoot()
	if this then
		if uiType == _UITYPE.uiCraft then
			local doubleHandle = this.craftPanel_mc.runesPanel_mc.targetHit_mc.itemHandle
			local item = _GetObjectFromDouble(doubleHandle)
			if item then
				request.ObjectHandleDouble = doubleHandle
				local boostEntry = item.Stats.DynamicStats[3+slot]
				if boostEntry then
					request.StatsId = boostEntry.BoostName
				end
			end
		elseif uiType == _UITYPE.craftPanel_c then
			--The tooltip may not be visible yet, but we can still update it
			local runePanel = this.craftPanel_mc.runePanel_mc
			if runePanel then
				request.ObjectHandleDouble = runePanel.runes_mc.runeTargetHandle
				local item = _GetObjectFromDouble(request.ObjectHandleDouble)
				if slot == 0 then
					-- The target item is selected instead of a rune, so this should be an item tooltip
					request.Type = "Item"
					return request
				else
					slot = slot - 1
					request.Slot = slot
					request.ObjectHandleDouble = runePanel.item_array[runePanel.currentHLSlot].itemHandle
					local rune = _GetObjectFromDouble(request.ObjectHandleDouble)
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

local SurfaceFlags = {
	Ground = {
		Type = {
			Fire = 0x1000000,
			Water = 0x2000000,
			Blood = 0x4000000,
			Poison = 0x8000000,
			Oil = 0x10000000,
			Lava = 0x20000000,
			Source = 0x40000000,
			Web = 0x80000000,
			Deepwater = 0x100000000,
			Sulfurium = 0x200000000,
			--UNUSED = 0x400000000
		},
		State = {
			Blessed = 0x400000000000,
			Cursed = 0x800000000000,
			Purified = 0x1000000000000,
			--??? = 0x2000000000000
		},
		Modifier = {
			Electrified = 0x40000000000000,
			Frozen = 0x80000000000000,
		},
	},
	Cloud = {
		Type = {
			FireCloud = 0x800000000,
			WaterCloud = 0x1000000000,
			BloodCloud = 0x2000000000,
			PoisonCloud = 0x4000000000,
			SmokeCloud = 0x8000000000,
			ExplosionCloud = 0x10000000000,
			FrostCloud = 0x20000000000,
			Deathfog = 0x40000000000,
			ShockwaveCloud = 0x80000000000,
			--UNUSED = 0x100000000000
			--UNUSED = 0x200000000000
		},
		State = {
			Blessed = 0x4000000000000,
			Cursed = 0x8000000000000,
			Purified = 0x10000000000000,
			--UNUSED = 0x20000000000000
		},
		Modifier = {
			Electrified = 0x100000000000000,
			-- ElectrifiedDecay = 0x200000000000000,
			-- SomeDecay = 0x400000000000000,
			--UNUSED = 0x800000000000000
		}
	},
	--AI grid painted flags
	-- Irreplaceable = 0x4000000000000000,
	-- IrreplaceableCloud = 0x800000000000000,
}

---@param flags integer
---@param data {Cell:_GameTooltipGridCell, Ground:string, Cloud:string}
local function SetSurfaceFromFlags(flags, data)
	for k,f in pairs(SurfaceFlags.Ground.Type) do
		if (flags & f) ~= 0 then
			data.Ground = k
		end
	end
	if data.Ground then
		for k,f in pairs(SurfaceFlags.Ground.Modifier) do
			if (flags & f) ~= 0 then
				data.Ground = data.Ground .. k
			end
		end
		for k,f in pairs(SurfaceFlags.Ground.State) do
			if (flags & f) ~= 0 then
				data.Ground = data.Ground .. k
			end
		end
	end
	for k,f in pairs(SurfaceFlags.Cloud.Type) do
		if (flags & f) ~= 0 then
			data.Cloud = k
		end
	end
	if data.Cloud then
		for k,f in pairs(SurfaceFlags.Cloud.Modifier) do
			if (flags & f) ~= 0 then
				data.Cloud = data.Cloud .. k
			end
		end
		for k,f in pairs(SurfaceFlags.Cloud.State) do
			if (flags & f) ~= 0 then
				data.Cloud = data.Cloud .. k
			end
		end
	end
end

---@alias _GameTooltipGridCell {Flags:integer, Height:number, Objects:ComponentHandle[]|nil}

---@param x number
---@param z number
---@param grid EocAiGrid
---@return {Cell:_GameTooltipGridCell, Ground:string|nil, Cloud:string|nil}
local function _GetSurfaces(x, z, grid)
	local cell = grid:GetCellInfo(x, z)
	if cell then
		local data = { Cell=cell }
		if cell.Flags then
			SetSurfaceFromFlags(cell.Flags, data)
		end
		return data
	end
end

RequestProcessor.CallbackHandler[TooltipInvokes.Surface] = function(request, ui, uiType, event, x, y)
	local surfaces = nil
	local cursor = _GetPickingState()
	if cursor and cursor.WalkablePosition then
		request.Position = cursor.WalkablePosition
		if _EXTVERSION >= 56 then
			local grid = _GetAiGrid()
			if grid then
				surfaces = _GetSurfaces(cursor.WalkablePosition[1], cursor.WalkablePosition[3], grid)
			end
		end
	end
	if surfaces then
		request.Flags = surfaces.Flags
		request.Ground = surfaces.Ground
		request.Cloud = surfaces.Cloud
	end
	return request
end

---The last double handle of the object under the cursor in KB+M mode, when the context menu was opened.
---@type number|nil
local lastCursorObjectDoubleHandle = nil

local function _CaptureCursorObject(ui, event)
	local cursor = _GetPickingState()
	if cursor then
		if _IsValidHandle(cursor.HoverCharacter) then
			lastCursorObjectDoubleHandle = _HandleToDouble(cursor.HoverCharacter)
		elseif _IsValidHandle(cursor.HoverCharacter2) then
			lastCursorObjectDoubleHandle = _HandleToDouble(cursor.HoverCharacter2)
		elseif _IsValidHandle(cursor.HoverItem) then
			lastCursorObjectDoubleHandle = _HandleToDouble(cursor.HoverItem)
		end
	end
end

local function _OnExamineWindowClosed(ui, event)
	lastCursorObjectDoubleHandle = nil
end

Ext.RegisterUITypeInvokeListener(_UITYPE.contextMenu.Object, "open", _CaptureCursorObject)
Ext.RegisterUITypeCall(_UITYPE.examine, "hideUI", _OnExamineWindowClosed)

function RequestProcessor.OnExamineTooltip(ui, event, typeIndex, id, ...)
	---@type EclCharacter|EclItem
	local object = nil

	--GetPlayerHandle returns the examined character or item
	object = _GetObjectFromHandle(ui:GetPlayerHandle())

	if not object and lastCursorObjectDoubleHandle then
		object = _GetObjectFromDouble(lastCursorObjectDoubleHandle)
	end

	if not object then
		object = _GetClientCharacter()
	end

	local request = _CreateRequest()

	if object then
		request.ObjectHandleDouble = _HandleToDouble(object.Handle)
	end

	if typeIndex == 1 then
		request.Type = "Stat"
		request.Stat = Game.Tooltip.TooltipStatAttributes[id]

		if request.Stat == nil then
			_PrintWarning("Requested tooltip for unknown stat ID " .. id)
		end
	elseif typeIndex == 2 then
		request.Type = "Ability"
		request.Ability = _EnumIndexToLabel("AbilityType", id) or id
	elseif typeIndex == 3 then
		if id == 0 then
			--Tooltip for "This character has no talents" doesn't exist.
			RequestProcessor.Tooltip.Last.Event = event
			RequestProcessor.Tooltip.Last.UIType = ui:GetTypeId()
			return
		else
			request.Type = "Talent"
			request.Talent = _EnumIndexToLabel("TalentType", id) or id
		end
	elseif typeIndex == 7 then
		request.Type = "Status"
		if not _IsNaN(id) then
			local statusHandle = _DoubleToHandle(id)
			if _IsValidHandle(statusHandle) then
				request.StatusHandleDouble = id
				if object then
					local status = _GetStatus(object.Handle, statusHandle)
					if status then
						request.StatusId = status.StatusId
					end
				end
			end
		end
	else
		local text = typeIndex
		local x = id
		local y, width, height, side, allowDelay = table.unpack({...})
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
		_PrintWarning("[Game.Tooltip.RequestProcessor.OnExamineTooltip] Previous tooltip request not cleared in render callback?")
	end

	RequestProcessor.Tooltip.NextRequest = request
	RequestProcessor.Tooltip:InvokeRequestListeners(request, "before", ui, request.UIType, event, typeIndex, id, ...)

	RequestProcessor.Tooltip.Last.Event = event
	RequestProcessor.Tooltip.Last.UIType = request.UIType
	RequestProcessor.Tooltip:InvokeRequestListeners(request, "after", ui, request.UIType, event, typeIndex, id, ...)
end

---@param ui UIObject
---@param event string
---@param id string
---@param objectHandle number|nil
function RequestProcessor.OnControllerExamineTooltip(ui, event, id, objectHandle)
	local request = RequestProcessor.CreateRequest()
	local uiTypeId = ui:GetTypeId()
	request.UIType = uiTypeId

	---@type EclItem|EclCharacter
	local object = nil

	if not _IsNaN(objectHandle) then
		object = _GetObjectFromDouble(objectHandle)
	end

	if not object then
		object = _GetObjectFromHandle(ui:GetPlayerHandle())
	end

	if not object then
		local uiType = ui:GetTypeId()
		if uiType == _UITYPE.examine_c then
			object = _GetObjectFromDouble(Game.Tooltip.ControllerVars.LastOverhead)
		else
			object = _GetObjectFromHandle(ui:GetPlayerHandle())
			if not object and uiType == _UITYPE.statsPanel_c then
				object = _GetClientCharacter()
			end
		end
	end

	if not object then
		object = _GetClientCharacter()
	end

	if object then
		request.ObjectHandleDouble = _HandleToDouble(object.Handle)
	end

	if event == "selectStatus" then
		request.Type = "Status"
		if not _IsNaN(id) then
			local statusHandle = _DoubleToHandle(id)
			if _IsValidHandle(statusHandle) then
				request.StatusHandleDouble = id
				if object then
					local status = _GetStatus(object.Handle, statusHandle)
					if status then
						request.StatusId = status.StatusId
					end
				end
			end
		end
	elseif event == "selectAbility" then
		request.Type = "Ability"
		request.Ability = _EnumIndexToLabel("AbilityType", id)
	elseif event == "selectTalent" then
		request.Type = "Talent"
		request.Talent = _EnumIndexToLabel("TalentType", id)
	elseif event == "selectStat" or event == "selectedAttribute" then
		request.Type = "Stat"
		request.Stat = id
		local stat = Game.Tooltip.TooltipStatAttributes[request.Stat]
		if stat ~= nil then
			request.Stat = stat
		else
			_PrintWarning(string.format("[RequestProcessor.OnControllerExamineTooltip] Requested tooltip for unknown stat ID (%s)", request.Stat))
		end
	elseif event == "selectCustomStat" then
		request.Type = "CustomStat"
		request.Stat = id
	elseif event == "selectTag" then
		request.Type = "Tag"
		request.Tag = id
		request.Category = ""
	end

	RequestProcessor.Tooltip.NextRequest = request
	RequestProcessor.Tooltip:InvokeRequestListeners(request, "before", ui, request.UIType, event, id, objectHandle)
	if object then
		Game.Tooltip.ControllerVars.LastPlayer = request.ObjectHandleDouble
	end

	RequestProcessor.Tooltip.Last.Event = event
	RequestProcessor.Tooltip.Last.UIType = request.UIType
	RequestProcessor.Tooltip:InvokeRequestListeners(request, "after", ui, request.UIType, event, id, objectHandle)
end

function RequestProcessor.OnGenericTooltip(ui, event, text, x, y, width, height, side, allowDelay)
	if RequestProcessor.Tooltip.NextRequest == nil then
		---@type TooltipGenericRequest
		local request = _CreateRequest()
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
		RequestProcessor.Tooltip:InvokeRequestListeners(request, "before", ui, request.UIType, event, text, x, y, width, height, side, allowDelay)

		RequestProcessor.Tooltip.Last.Event = event
		RequestProcessor.Tooltip.Last.UIType = request.UIType
		RequestProcessor.Tooltip:InvokeRequestListeners(request, "after", ui, request.UIType, event, text, x, y, width, height, side, allowDelay)
	end
end

function RequestProcessor.SetWorldTooltipRequest(request, ui, uiType, event, text, x, y, isItem, item)
	request.Type = "World"
	request.Text = text
	request.IsFromItem = false
	if isItem and item then
		request.ObjectHandleDouble = _HandleToDouble(item.Handle)
		request.IsFromItem = true
	end
	return request
end

---@param request TooltipRequest
---@param ui UIObject
---@param uiType integer
---@param event string
---@param text string
---@param levelText string
---@param shortenWidth boolean
---@param item EclItem
---@param objectHandleDouble number
function RequestProcessor.SetWorldHoverTooltipRequest(request, ui, uiType, event, text, levelText, shortenWidth, item, objectHandleDouble)
	request.Type = "WorldHover"
	request.Text = text
	request.IsFromItem = item ~= nil
	request.ObjectHandleDouble = objectHandleDouble
	return request
end

local _requestDumpOpts = {Beautify = true,
StringifyInternalTypes = true,
IterateUserdata = false,
AvoidRecursion = true}

---@param requestType string
---@param ui UIObject
---@param uiType integer
---@param event string Call or method.
---@param idOrDoubleHandle any
---@param statOrWidth any
---@param ... any
function RequestProcessor.HandleCallback(requestType, ui, uiType, event, idOrDoubleHandle, statOrWidth, ...)
	---@type {characterHandle:number|nil}
	local this = ui:GetRoot()

	---@type EclCharacter
	local character = _GetObjectFromHandle(ui:GetPlayerHandle())
	local id = idOrDoubleHandle

	if (event == "showSkillTooltip" or event == "showStatusTooltip") then
		id = statOrWidth
		if not character then
			character = _GetObjectFromDouble(idOrDoubleHandle)
		end
	end

	if not character and event == "showSkillTooltip" and _GetGameMode() == "GameMaster" then
		character = _GetGMTargetCharacter()
	end

	if not character and this and this.characterHandle then
		character = _GetObjectFromDouble(this.characterHandle)
	end

	if not character then
		if (uiType == _UITYPE.characterSheet or uiType == _UITYPE.statsPanel_c) then
			character = _GetCharacterSheetCharacter(this)
		elseif (uiType == _UITYPE.playerInfo or uiType == _UITYPE.playerInfo_c) then
			--[[ Help! This shouldn't ever happen because the character handle is passed into the external call.
			We have no idea which row of statuses/whatever is being looked at for a character otherwise.--]]
		end
	end

	if not character then
		character = _GetClientCharacter()
	end

	if uiType == _UITYPE.characterCreation then
		id = statOrWidth
	end

	local request = _CreateRequest()
	request.Type = requestType
	if character then
		request.ObjectHandleDouble = _HandleToDouble(character.Handle)
	end
	request.UIType = uiType

	RequestProcessor.Tooltip.NextRequest = request

	RequestProcessor.Tooltip:InvokeRequestListeners(request, "before", ui, uiType, event, id, statOrWidth, ...)
	if RequestProcessor.CallbackHandler[event] then
		local b,r = xpcall(RequestProcessor.CallbackHandler[event], debug.traceback, request, ui, uiType, event, id, statOrWidth, ...)
		if b then
			RequestProcessor.Tooltip.NextRequest = r
			request = r
		else
			_PrintError(string.format("[Game.Tooltips.RequestProcessor] Error invoking tooltip handler for event (%s):\n%s", event, r))
		end
	end
	if RequestProcessor.ControllerEnabled and character then
		Game.Tooltip.ControllerVars.LastPlayer = _HandleToDouble(character.Handle)
	end
	RequestProcessor.Tooltip.Last.Event = event
	RequestProcessor.Tooltip.Last.UIType = uiType

	--_Print("RequestProcessor.HandleCallback", Ext.Json.Stringify({Character = character and character.DisplayName or "nil", ObjectHandleDouble = request.ObjectHandleDouble, Object = request.Object, TypeId = uiType}, _requestDumpOpts))

	RequestProcessor.Tooltip:InvokeRequestListeners(request, "after", ui, uiType, event, id, statOrWidth, ...)
end

local function OnControllerSlotOver(ui, event, id, ...)
	if id ~= 0 then
		RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), TooltipCalls.Item, id, ...)
	end
end

local function RedirectControllerTooltip(tooltipType, ui, event, ...)
	--Redirect to standard events, so the regular handlers work
	local event = TooltipCalls[tooltipType] or event
	RequestProcessor.HandleCallback(tooltipType, ui, ui:GetTypeId(), event, ...)
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
		Ext.RegisterUITypeCall(_UITYPE.characterCreation_c, v, RedirectControllerTooltip, "Before")
	end

	--Custom controller tooltip calls.
	Ext.RegisterUITypeCall(_UITYPE.bottomBar_c, "SlotHover", function (ui, event, slotNum)
		---@type {bottombar_mc:{slotsHolder_mc:{tooltipSlotType:integer, tooltipSlot:number}}}
		local this = ui:GetRoot()
		if this then
			local slotsHolder_mc = this.bottombar_mc.slotsHolder_mc
			local slotType = slotsHolder_mc.tooltipSlotType
			local slotHandle = slotsHolder_mc.tooltipSlot
	
			local requestType = "Skill"
			local id = nil
			-- 4 is for non-skills like Flee, Sheathe etc
			if slotType == 1 or slotType == 4 then
				event = TooltipCalls.Skill
				RequestProcessor.HandleCallback(requestType, ui, ui:GetTypeId(), event, nil, slotsHolder_mc.tooltipStr)
			elseif slotType == 2 then
				-- Sometimes tooltipSlot will be set to the tooltip index instead of the slot's handle value
				if slotNum == slotHandle then
					local slot = slotsHolder_mc.slot_array[slotNum]
					if slot then
						slotHandle = slot.handle
					end
				end
				if slotHandle and slotNum ~= slotHandle then
					local handle = _DoubleToHandle(slotHandle)
					if _IsValidHandle(handle) then
						requestType = "Item"
						event = TooltipCalls.Item
						RequestProcessor.HandleCallback(requestType, ui, ui:GetTypeId(), event, slotHandle)
					end
				end
			end
		end
	end, "Before")
	-- slotOver is called when selecting any slot, item or not
	Ext.RegisterUITypeCall(_UITYPE.equipmentPanel_c, "slotOver", OnControllerSlotOver, "Before")
	-- itemOver is called when selecting a slot with an item, in addition to slotOver
	-- Ext.RegisterUITypeCall(_uiType.equipmentPanel_c, "itemOver", function (ui, event, ...)
	-- 	RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), event, ...)
	-- end, "Before")
	Ext.RegisterUITypeCall(_UITYPE.craftPanel_c, "slotOver", OnControllerSlotOver, "Before")
	Ext.RegisterUITypeCall(_UITYPE.partyInventory_c, "slotOver", OnControllerSlotOver, "Before")
	Ext.RegisterUITypeCall(_UITYPE.containerInventory.Default, "slotOver", OnControllerSlotOver, "Before")
	Ext.RegisterUITypeCall(_UITYPE.containerInventory.Pickpocket, "slotOver", OnControllerSlotOver, "Before")
	-- Ext.RegisterUITypeCall(_uiType.craftPanel_c, "overItem", function (ui, event, ...)
	-- 	RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), event, ...)
	-- end, "Before")
	
	Ext.RegisterUITypeCall(_UITYPE.craftPanel_c, "runeSlotOver", function (ui, event, id, ...)
		if id ~= -1 then
			RequestProcessor.HandleCallback("Rune", ui, ui:GetTypeId(), TooltipCalls.Rune, id, ...)
		end
	end, "Before")
	Ext.RegisterUITypeCall(_UITYPE.equipmentPanel_c, "itemDollOver", OnControllerSlotOver, "Before")
	-- Ext.RegisterUITypeCall(_uiType.equipmentPanel_c, "setTooltipPanelVisible", function (ui, event, visible, ...)
	-- 	RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), event, nil, nil, ...)
	-- end, "Before")
	-- When the tooltip is opened without moving slots
	Ext.RegisterUITypeCall(_UITYPE.partyInventory_c, "setTooltipVisible", function (ui, event, visible, ...)
		if visible == true then
			RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), TooltipCalls.Item)
		end
	end, "Before")

	Ext.RegisterUITypeCall(_UITYPE.trade_c, "overItem", function(ui, event, itemHandleDouble)
		RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), TooltipCalls.Item, itemHandleDouble)
	end)

	Ext.RegisterUITypeCall(_UITYPE.reward_c, "refreshTooltip", function(ui, event, itemHandleDouble)
		RequestProcessor.HandleCallback("Item", ui, ui:GetTypeId(), TooltipCalls.Item, itemHandleDouble)
	end)

	-- Disabled for now since this function doesn't include any ID for the tag.
	-- Ext.RegisterUICall(statsPanel, "selectTag", function(ui, method, emptyWorthlessTagTooltip)
	-- 	print(method, emptyWorthlessTagTooltip)
	-- 	local main = ui:GetRoot()
	-- 	local tags_mc = main.mainpanel_mc.stats_mc.tags_mc
	-- 	local selectedTag = tags_mc.statList.m_CurrentSelection
	-- 	if selectedTag ~= nil then
	-- 		local tagNameText = selectedTag.label_txt.htmlText
	-- 		self:OnRequestConsoleExamineTooltip(ui, method, tagNameText)
	-- 	end
	-- end)

	Ext.RegisterUITypeCall(_UITYPE.statsPanel_c, "selectedAttribute", function(ui, method, id)
		RequestProcessor.OnControllerExamineTooltip(ui, method, id)
	end)

	Ext.RegisterUITypeCall(_UITYPE.statsPanel_c, "selectCustomStat", function(ui, method, id)
		RequestProcessor.OnControllerExamineTooltip(ui, method, id)
	end)

	local selectEvents = {
		"selectStat",
		"selectAbility",
		"selectAbility",
		"selectTalent",
		"selectStatus",
		"selectTitle",
	}

	for i,v in pairs(selectEvents) do
		Ext.RegisterUITypeCall(_UITYPE.statsPanel_c, v, function(ui, ...)
			RequestProcessor.OnControllerExamineTooltip(ui, ...)
		end)
		Ext.RegisterUITypeCall(_UITYPE.examine_c, v, function(ui, ...)
			RequestProcessor.OnControllerExamineTooltip(ui, ...)
		end)
	end

	--Generic tooltips
	Ext.RegisterUINameCall("showTooltip", function(ui, ...)
		if ui:GetTypeId() == _UITYPE.examine then
			RequestProcessor.OnExamineTooltip(ui, ...)
		else
			RequestProcessor.OnGenericTooltip(ui, ...)
		end
	end, "Before")
end

local UNSET_HANDLE = "ls::TranslatedStringRepository::s_HandleUnknown"

local function _GetTranslatedStringValue(ts)
	local refString = ts.Handle and ts.Handle.ReferenceString or ""
	if refString == "" and ts.ArgumentString then
		refString = ts.ArgumentString.ReferenceString
	end
	if ts.Handle and ts.Handle.Handle ~= UNSET_HANDLE then
		return _GetTranslatedString(ts.Handle.Handle, ts.Handle.ReferenceString)
	end
	return refString
end

local _itemRarity = {
	Common = 0,
	Unique = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Divine = 6,
}

---@param item EclItem
local function _GetItemDisplayName(item)
	local statsId = nil
	if item.StatsId ~= "" and item.StatsId ~= nil and not _itemRarity[item.StatsId] then
		statsId = item.StatsId
	end
	if string.find(item.DisplayName, "|") or item.RootTemplate.DisplayName.Handle == nil or item.DisplayName == statsId then
		if statsId then
			local name = _GetTranslatedStringFromKey(item.StatsId)
			if name ~= nil and name ~= "" then
				return name
			end
		end
		local translatedName = _GetTranslatedStringValue(item.RootTemplate.DisplayName)
		if translatedName ~= nil and translatedName ~= "" then
			return translatedName
		end
	end
	return item.DisplayName
end

local _SlotNames = {
	Helmet = {"hd4b98ff5g33a8g44e0ga6a9gdb1ab7d70bf3", "Helmet"},
	Breast = {"hb5c52d20g6855g4929ga78ege3fe776a1f2e", "Chest Armour"},
	Leggings = {"he7042b52g54d7g4f46g8f69g509460dfe595", "Leggings"},
	Weapon = {"h102d1ef8g3757g4ff3g8ef2gd68007c6268d", "Weapon"},
	Shield = {"h77557ac7g4f6fg49bdga76cg404de43d92f5", "Shield"},
	Ring = {"h970199f8ge650g4fa3ga0deg5995696569b6", "Ring"},
	Belt = {"h2a76a9ecg2982g4c7bgb66fgbe707db0ac9e", "Belt"},
	Boots = {"h9b65aab2gf4c4g4b81g96e6g1dcf7ffa8306", "Boots"},
	Gloves = {"h185545eagdaf0g4286ga411gd50cbdcabc8b", "Gloves"},
	Amulet = {"hb9d79ca5g59afg4255g9cdbgf614b894be68", "Amulet"},
	Ring2 = {"h970199f8ge650g4fa3ga0deg5995696569b6", "Ring"},
	Wings = {"hd716a074gd36ag4dfcgbf79g53bd390dd202", "Wings"},
	Horns = {"ha35fc503g56dbg4adag963dga359d961e0c8", "Horns"},
	Overhead = {"hda749a3fg52c0g48d5gae3bgd522dd34f65c", "Overhead"},
	Offhand = {"h50110389gc98ag49dbgb58fgae2fd227dff4", "Offhand"},
}

---@param item EclItem
local function _GetItemSlotName(item)
	if not _ItemIsObject(item) and item.StatsId ~= "" and item.StatsId ~= nil and not _itemRarity[item.StatsId] then
		---@type StatEntryWeapon
		local stat = _GetStat(item.StatsId)
		if stat then
			local tsData = _SlotNames[stat.Slot]
			if tsData then
				return _GetTranslatedString(tsData[1], tsData[2])
			end
		end
	end
end

local _equipmentPattern = "<font color=\"#ffffff\">%s</font><font size=\"15\"><br>%s</font>"

--Called before a world hover tooltip is shown. text may be "" if it's an item without health.
--[enemyHealthBar(42)][invoke] setText("<font color="#ffffff">Barrel</font>", "Level 1", false)
--TODO Figure out if there's an equivalent for controllers.
Ext.RegisterUITypeInvokeListener(_UITYPE.enemyHealthBar, "setText", function(ui, event, text, levelText, shortenWidth)
	local cursor = _GetPickingState()
	if cursor and _IsValidHandle(cursor.HoverItem) then
		local item = _GetItem(cursor.HoverItem)
		---@cast item EclItem
		if item and item.RootTemplate and item.RootTemplate.Tooltip > 0 then
			local objectHandleDouble = _HandleToDouble(cursor.HoverItem)
			local request = _CreateRequest()
			if text == nil or text == "" then
				local name = _GetItemDisplayName(item)
				local slotName = _GetItemSlotName(item)
				if slotName then
					text = _equipmentPattern:format(name, slotName)
				else
					text = name
				end
			end
			RequestProcessor.Tooltip.NextRequest = RequestProcessor.SetWorldHoverTooltipRequest(request, ui, _UITYPE.enemyHealthBar, event, text, levelText, shortenWidth, item, objectHandleDouble)
		end
	end
end)

---@return string
local function _CreateWorldTooltipRequest(ui, event, text, x, y, isItem, item)
	local uiType = ui:GetTypeId()
	---@type TooltipWorldRequest
	local request = _CreateRequest()
	RequestProcessor.Tooltip:InvokeRequestListeners(request, "before", ui, uiType, event, text, x, y, isItem, item)
	local b,r = xpcall(RequestProcessor.SetWorldTooltipRequest, debug.traceback, request, ui, uiType, event, text, x, y, isItem, item)
	if b then
		request = r
		RequestProcessor.Tooltip.NextRequest = request
	else
		_PrintError(string.format("[Game.Tooltip.RequestProcessor:_CreateWorldTooltipRequest] Error invoking tooltip handler for event (%s):\n%s", event, r))
	end

	RequestProcessor.Tooltip.Last.Event = event
	RequestProcessor.Tooltip.Last.UIType = uiType
	RequestProcessor.Tooltip.Last.Request = request
	
	RequestProcessor.Tooltip:InvokeRequestListeners(request, "after", ui, uiType, event, text, x, y, isItem, item)
	
	local tooltipData = Game.Tooltip.TooltipData:Create({{
		Type = "Description",
		Label = text,
		X = x,
		Y = y,
	}}, uiType, uiType)
	
	RequestProcessor.Tooltip.ActiveType = request.Type
	RequestProcessor.Tooltip:NotifyListeners("World", nil, request, tooltipData, request.Item)

	local desc = tooltipData:GetDescriptionElement()
	return desc and desc.Label or nil
end

_INTERNAL.CreateWorldTooltipRequest = _CreateWorldTooltipRequest

Ext.RegisterUITypeInvokeListener(_UITYPE.worldTooltip, "updateTooltips", function(ui, event)
	---@type {worldTooltip_array:table<integer,number|string|boolean>}
	local this = ui:GetRoot()
	if this then
		--public function setTooltip(param1:uint, param2:Number, param3:Number, param4:Number, param5:String, param6:Number, param7:Boolean, param8:uint = 16777215, param9:uint = 0
		--this.setTooltip(val2,val3,val4,val5,val6,this.worldTooltip_array[val2++],this.worldTooltip_array[val2++]);
		for i=0,#this.worldTooltip_array-1,6 do
			---@type number
			local doubleHandle = this.worldTooltip_array[i]
			if doubleHandle then
				local x = this.worldTooltip_array[i+1]
				local y = this.worldTooltip_array[i+2]
				local text = this.worldTooltip_array[i+3]
				--local sortHelper = main.worldTooltip_array[i+4]
				local isItem = this.worldTooltip_array[i+5]
				if isItem then
					local item = _GetObjectFromDouble(doubleHandle)
					if item then
						local textReplacement = _CreateWorldTooltipRequest(ui, "updateTooltips", text, x, y, true, item)
						if textReplacement and textReplacement ~= text then
							this.worldTooltip_array[i+3] = textReplacement
						end
					end
				else
					local textReplacement = _CreateWorldTooltipRequest(ui, "updateTooltips", text, x, y, false, nil)
					if textReplacement and textReplacement ~= text then
						this.worldTooltip_array[i+3] = textReplacement
					end
				end
			end
		end
	end
end)

--Hack to clear the last tooltip being "World"
Ext.RegisterUINameInvokeListener("removeTooltip", function(ui, ...)
	local lastRequest = RequestProcessor.Tooltip.Last.Request
	if lastRequest and lastRequest.Type == "World" then
		Game.Tooltip.TooltipHooks.Last.Request = nil
	end
end)

RequestProcessor.Utils = {
	GetObjectFromDouble = _GetObjectFromDouble,
	GetObjectFromHandle = _GetObjectFromHandle,
	GetGMTargetCharacter = _GetGMTargetCharacter,
	GetClientCharacter = _GetClientCharacter,
	GetCharacterSheetCharacter = _GetCharacterSheetCharacter,
	GetSurfaces = _GetSurfaces,
	ItemRarity = _itemRarity
}

return RequestProcessor