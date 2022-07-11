local _EXTVERSION = Ext.Version()
local _ISCLIENT = Ext.IsClient()

local pairs = pairs

if _ISCLIENT then
	local _GetUseActionSkills = GameHelpers.Item.GetUseActionSkills
	local _TryGetItemFromDouble = GameHelpers.Client.TryGetItemFromDouble
	local _GetTemplate = GameHelpers.GetTemplate

	UI.InventoryTweaks = {}

	local PartyInventory = Classes.UIWrapper:CreateFromType(Data.UIType.partyInventory, {ControllerID=Data.UIType.partyInventory_c, IsControllerSupported=true})
	local ContainerInventory = Classes.UIWrapper:CreateFromType(Data.UIType.containerInventory.Default, {ControllerID=Data.UIType.containerInventory.Default, IsControllerSupported=true})
	local Trade = Classes.UIWrapper:CreateFromType(Data.UIType.trade, {ControllerID=Data.UIType.trade_c, IsControllerSupported=true})

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
		if settings and settings.Global:FlagEquals("LeaderLib_UnlockCharacterInventories", true) then
			return true
		end
		return false
	end

	local _inventoryWasOpened = false

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

	--#region Learned Skillbooks

	if _EXTVERSION >= 56 then

		---@return fun():{SlotMC:FlashMovieClip, Item:EclItem}
		local function GetInventoryItems()
			local entries = {}

			local b,err = xpcall(function ()
				local this = PartyInventory.Root
				if this then
					local arr = this.inventory_mc.list.content_array
					for i=0,#arr-1 do
						local inv = arr[i].inv
						if inv then
							for j=0,#inv.content_array-1 do
								local slot_mc = inv.content_array[j]
								if slot_mc then
									if slot_mc.itemHandle ~= 0 then
										local item = _TryGetItemFromDouble(slot_mc.itemHandle)
										if item then
											entries[#entries+1] = {SlotMC=slot_mc, Item = item}
										end
									else
										slot_mc.graphics.clear()
									end
								end
							end
						end
					end
				end
			end, debug.traceback)
			if not b and Vars.DebugMode then
				Ext.PrintError(err)
			end

			local i = 0
			local count = #entries
			return function ()
				i = i + 1
				if i <= count then
					return entries[i]
				end
			end
		end

		---@return fun():{SlotMC:FlashMovieClip, Item:EclItem}
		local function GetContainerItems()
			local entries = {}
			local b,err = xpcall(function ()
				local this = ContainerInventory.Root
				if this then
					local arr = this.inv_mc.slot_array
					for i=0,#arr-1 do
						local slot_mc = arr[i]
						if slot_mc then
							if slot_mc.itemHandle ~= 0 then
								local item = _TryGetItemFromDouble(slot_mc.itemHandle)
								if item then
									entries[#entries+1] = {SlotMC=slot_mc, Item = item}
								end
							else
								slot_mc.graphics.clear()
							end
						end
					end
				end
			end, debug.traceback)
			if not b and Vars.DebugMode then
				Ext.PrintError(err)
			end

			local i = 0
			local count = #entries
			return function ()
				i = i + 1
				if i <= count then
					return entries[i]
				end
			end
		end

		---@return fun():{SlotMC:FlashMovieClip, Item:EclItem}
		local function GetTradeItems(controllerEnabled)
			local entries = {}
			local b,err = xpcall(function ()
				local this = Trade.Root
				if this then
					local arr = not controllerEnabled and this.trade_mc.item_array or this.trade_mc.inventory_mc.item_array
					for i=0,#arr-1 do
						local slot_mc = arr[i]
						if slot_mc then
							if slot_mc.itemHandle ~= 0 then
								local item = _TryGetItemFromDouble(slot_mc.itemHandle)
								if item then
									entries[#entries+1] = {SlotMC=slot_mc, Item = item}
								end
							else
								slot_mc.graphics.clear()
							end
						end
					end
				end
			end, debug.traceback)
			if not b and Vars.DebugMode then
				Ext.PrintError(err)
			end

			local i = 0
			local count = #entries
			return function ()
				i = i + 1
				if i <= count then
					return entries[i]
				end
			end
		end

		local BACKGROUND_COLOR = 0xFF0b0907
		local SLOT_SETTINGS = {
			Inventory = {Offset=-1, Size=51},
			Container = {Offset=-1, Size=64},
			Trade = {Offset=-1, Size=51},
		}

		---@type boolean|nil
		local lastEnabled = false

		---RootTemplate to Skills
		---@type table<string, table<string, boolean>>
		local _cachedSkills = {}

		---RootTemplate to BookId
		---@type table<string, string>
		local _readBooks = {}

		UI.InventoryTweaks.ReadBooks = _readBooks

		---@param item EclItem
		---@param skillsDict table<string, table>
		---@param template string
		local function SkillbookIsKnown(item, skillsDict, template)
			local skills = _cachedSkills[template]
			local isSkillBook = skills ~= nil
			if not skills then
				local itemSkills,itemParams = _GetUseActionSkills(item, true, true)
				if itemParams.IsSkillbook then
					isSkillBook = true
					skills = itemSkills
					_cachedSkills[item.StatsId] = skills
				end
			end

			if isSkillBook then
				for id,b in pairs(skills) do
					if skillsDict[id] then
						return true
					end
				end
			end

			return false
		end

		---@param getItemsFunc fun(controllerEnabled:boolean):(fun():{SlotMC:FlashMovieClip, Item:EclItem})
		---@param slotSettings {Size:number, Offset:number}
		local function AdjustSlots(getItemsFunc, slotSettings)
			local posOffset = slotSettings.Offset -1
			local slotSize = slotSettings.Size or 51

			local settings = GameSettingsManager.GetSettings()
			local player = Client:GetCharacter()
			
			local enabled = settings.Client.FadeInventoryItems.Enabled

			local sfade = GameHelpers.Math.Clamp(1 - (settings.Client.FadeInventoryItems.KnownSkillbooks * 0.01), 0, 1)
			local bookFade = GameHelpers.Math.Clamp(1 - (settings.Client.FadeInventoryItems.ReadBooks * 0.01), 0, 1)

			if player and (enabled or lastEnabled ~= enabled) then
				lastEnabled = enabled
				local skillsDict = player.SkillManager.Skills
				local items = getItemsFunc(Vars.ControllerEnabled)
				for entry in items do
					local matched = false
					local gfx = entry.SlotMC.graphics
					if enabled then
						local template = _GetTemplate(entry.Item)
						if sfade > 0 then
							if SkillbookIsKnown(entry.Item, skillsDict, template) then
								--local size = entry.SlotMC.width
								--gfx.lineStyle(1,16711680)
								gfx.clear()
								gfx.beginFill(BACKGROUND_COLOR, sfade)
								--gfx.beginFill(0xFF0000, 1)
								--gfx.drawRect(-1,-1,51,51)
								gfx.drawRect(posOffset,posOffset,slotSize,slotSize)
								gfx.endFill()
								matched = true
							end
						end
						if not matched and bookFade > 0 then
							if _readBooks[template] then
								gfx.clear()
								gfx.beginFill(BACKGROUND_COLOR, bookFade)
								gfx.drawRect(posOffset,posOffset,slotSize,slotSize)
								gfx.endFill()
								matched = true
							end
						end
					end
					if not matched then
						gfx.clear()
					end
				end
			end
		end

		local function UpdateInventoryFade()
			--Force the update to run at least once on reset or upon changing settings
			lastEnabled = nil

			if PartyInventory.Visible then
				AdjustSlots(GetInventoryItems, SLOT_SETTINGS.Inventory)
			end
			if ContainerInventory.Visible then
				AdjustSlots(GetContainerItems, SLOT_SETTINGS.Container)
			end
			if Trade.Visible then
				AdjustSlots(GetTradeItems, SLOT_SETTINGS.Trade)
			end
		end

		Events.GameSettingsChanged:Subscribe(UpdateInventoryFade)
		Events.LuaReset:Subscribe(UpdateInventoryFade)
		
		PartyInventory:RegisterInvokeListener("updateItems", function (self, ui, event, ...)
			local settings = GameSettingsManager.GetSettings()
			if settings.Client.FadeInventoryItems.Enabled then
				Timer.StartOneshot("LeaderLib_PartyInventory_AdjustItems", 1, function() AdjustSlots(GetInventoryItems, SLOT_SETTINGS.Inventory) end)
			end
		end, "After", "Keyboard")
		
		ContainerInventory:RegisterInvokeListener("updateItems", function (self, ui, event, ...)
			local settings = GameSettingsManager.GetSettings()
			if settings.Client.FadeInventoryItems.Enabled then
				Timer.StartOneshot("LeaderLib_ContainerInventory_AdjustItems", 1, function() AdjustSlots(GetContainerItems, SLOT_SETTINGS.Container) end)
			end
		end, "After", "Keyboard")

		Trade:RegisterInvokeListener("updateItems", function (self, ui, event, ...)
			local settings = GameSettingsManager.GetSettings()
			if settings.Client.FadeInventoryItems.Enabled then
				Timer.StartOneshot("LeaderLib_ContainerInventory_AdjustItems", 1, function() AdjustSlots(GetTradeItems, SLOT_SETTINGS.Trade) end)
			end
		end, "After", "All")

		Ext.RegisterNetListener("LeaderLib_SyncReadBooks", function (cmd, payload)
			local data = Common.JsonParse(payload)
			if data then
				_readBooks = data
				UI.InventoryTweaks.ReadBooks = _readBooks

				UpdateInventoryFade()
			end
		end)
	end

	--#endregion

	--#region Open Container in Trade Window

	--[[ local _lastRightClickItemDoubleHandle = nil

	ContainerInventory:RegisterCallListener("startDragging", function (self, ui, event, doubleHandle)
		if Trade.Visible then
			local slot = Trade.Root.trade_mc.currentHLList
			Ext.PrintError("startDragging", slot, doubleHandle)
			local handle = Ext.DoubleToHandle(doubleHandle)
			local playerId = Client:GetCharacter().UserID
			Ext.UI.GetDragDrop():StartDraggingObject(playerId, handle)
			--Trade:ExternalInterfaceCall("startDragging", slot, doubleHandle)
		end
	end, "After", "Keyboard")

	--Allow opening containers in the trade UI
	Trade:RegisterCallListener("itemRightClick", function (self, ui, event, doubleHandle)
		_lastRightClickItemDoubleHandle = doubleHandle
		Ext.PrintError("itemRightClick", _lastRightClickItemDoubleHandle, UI.ContextMenu.IsOpening, UI.ContextMenu.Visible)
		if not UI.ContextMenu.Visible then
			UI.ContextMenu:OnRightClick()
		end
	end, "After", "Keyboard")

	Events.ShouldOpenContextMenu:Subscribe(function (e)
		if not GameHelpers.Math.IsNaN(_lastRightClickItemDoubleHandle) then
			Ext.PrintError(e.X, e.Y)
			e.ShouldOpen = true
		end
	end)

	Events.OnContextMenuOpening:Subscribe(function (e)
		if not GameHelpers.Math.IsNaN(_lastRightClickItemDoubleHandle) then
			local item = GameHelpers.Client.TryGetItemFromDouble(_lastRightClickItemDoubleHandle)
			_lastRightClickItemDoubleHandle = nil
			if item then
				local hasItems = #item:GetInventoryItems() > 0
				local hasOwner = item:GetOwnerCharacter() == Client.Character.UUID
				if (hasItems and hasOwner) or Vars.DebugMode then
					local netid = item.NetID
					e.ContextMenu:AddEntry("LeaderLib_Trade_OpenContainer", function ()
						Ext.PostMessageToServer("LeaderLib_Trade_OpenContainer", Common.JsonStringify({Item=netid, Player=Client:GetCharacter().NetID}))
					end, "Open")
				end
			end
		end
	end) ]]

	--#endregion

else
	Ext.RegisterNetListener("LeaderLib_Trade_OpenContainer", function (channel, payload, user)
		---@type {Item:NETID, Player:NETID}
		local data = Common.JsonParse(payload)
		if data then
			local item = GameHelpers.GetItem(data.Item)
			local player = GameHelpers.GetCharacter(data.Player)
			if item and player then
				CharacterUseItem(player.MyGuid, item.MyGuid, "")
			end
		end
	end)

	---@param id integer|nil
	local function SyncReadBooks(id)
		if id then
			local data = PersistentVars.ReadBooks[id]
			if data then
				GameHelpers.Net.PostToUser(id, "LeaderLib_SyncReadBooks", data)
			end
		else
			for userID,data in pairs(PersistentVars.ReadBooks) do
				GameHelpers.Net.PostToUser(userID, "LeaderLib_SyncReadBooks", data)
			end
		end
	end

	Events.SyncData:Subscribe(function (e)
		local data = PersistentVars.ReadBooks[e.UserID]
		if data then
			GameHelpers.Net.PostToUser(e.UserID, "LeaderLib_SyncReadBooks", data)
		end
	end)

	Ext.RegisterOsirisListener("CanUseItem", 3, "after", function (charGUID, itemGUID, requestID)
		if CharacterIsPlayer(charGUID) == 1 and IsTagged(itemGUID, "BOOK") == 1 then
			local updatedData = false
			local player = GameHelpers.GetCharacter(charGUID)
			local item = GameHelpers.GetItem(itemGUID)
			local userID = GameHelpers.GetUserID(player)
			if item and item.RootTemplate then
				local bookType = ""
				local textID = nil
				local template = GameHelpers.GetTemplate(item)
				for _,v in pairs(item.RootTemplate.OnUsePeaceActions) do
					if v.Type == "Book" and not StringHelpers.IsNullOrWhitespace(v.BookId) then
						if PersistentVars.ReadBooks[userID] == nil then
							PersistentVars.ReadBooks[userID] = {}
						end
						textID = v.BookId
						updatedData = PersistentVars.ReadBooks[userID][template] == nil
						PersistentVars.ReadBooks[userID][template] = v.BookId
						bookType = "Book"
						break
					elseif v.Type == "Recipe" and not StringHelpers.IsNullOrWhitespace(v.RecipeID) then
						if PersistentVars.ReadBooks[userID] == nil then
							PersistentVars.ReadBooks[userID] = {}
						end
						textID = v.RecipeID
						updatedData = PersistentVars.ReadBooks[userID][template] == nil
						PersistentVars.ReadBooks[userID][template] = v.RecipeID
						bookType = "Recipe"
						break
					elseif v.Type == "SkillBook" and v.Consume == true and not StringHelpers.IsNullOrWhitespace(v.SkillID) then
						textID = v.SkillID
						bookType = "Skillbook"
					end
				end
				if textID then
					---@cast textID string
					
					Events.OnBookRead:Invoke({
						Character = player,
						Item = item,
						Template = template,
						ID = textID,
						BookType = bookType
					})
				end
				if updatedData then
					SyncReadBooks(userID)
				end
			end
		end
	end)
end