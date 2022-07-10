local _EXTVERSION = Ext.Version()

local pairs = pairs

local _GetUseActionSkills = GameHelpers.Item.GetUseActionSkills
local _TryGetItemFromDouble = GameHelpers.Client.TryGetItemFromDouble
local _GetTemplate = GameHelpers.GetTemplate

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
				for i=0,#this.inventory_mc.list.content_array-1 do
					local inv = this.inventory_mc.list.content_array[i].inv
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
				for i=0,#this.inv_mc.slot_array-1 do
					local slot_mc = this.inv_mc.slot_array[i]
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
	---RootTemplate to Skills
	---@type table<string, table<string, boolean>>
	local _cachedSkills = {}

	---@param item EclItem
	---@param skillsDict table<string, table>
	local function SkillbookIsKnown(item, skillsDict)
		local template = _GetTemplate(item)
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

	local function AdjustSlots(isContainer, slotSize, posOffset)
		posOffset = posOffset or -1
		slotSize = slotSize or 51
		local settings = GameSettingsManager.GetSettings()
		local skillbookFade = settings.Client.FadeInventoryItems.KnownSkillbooks
		local sfade = GameHelpers.Math.Clamp(1 - (skillbookFade * 0.01), 0, 1)
		local enabled = settings.Client.FadeInventoryItems.Enabled
		local player = Client:GetCharacter()
		if player then
			local skillsDict = player.SkillManager.Skills
			local items = nil
			if not isContainer then
				items = GetInventoryItems()
			else
				items = GetContainerItems()
			end
			for entry in items do
				local matched = false
				local gfx = entry.SlotMC.graphics
				if enabled and sfade > 0 then
					if SkillbookIsKnown(entry.Item, skillsDict) then
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
				if not matched then
					gfx.clear()
				end
			end
		end
	end

	local function UpdateInventoryFade()
		if PartyInventory.Visible then
			AdjustSlots()
		end
		if ContainerInventory.Visible then
			AdjustSlots(true, 64, 0)
		end
	end

	Events.GameSettingsChanged:Subscribe(UpdateInventoryFade)
	Events.LuaReset:Subscribe(UpdateInventoryFade)
	
	PartyInventory:RegisterInvokeListener("updateItems", function (self, ui, event, ...)
		local settings = GameSettingsManager.GetSettings()
		if settings.Client.FadeInventoryItems.Enabled then
			Timer.StartOneshot("LeaderLib_PartyInventory_AdjustItems", 1, function() AdjustSlots(false) end)
		end
	end, "After", "Keyboard")
	
	ContainerInventory:RegisterInvokeListener("updateItems", function (self, ui, event, ...)
		local settings = GameSettingsManager.GetSettings()
		if settings.Client.FadeInventoryItems.Enabled then
			Timer.StartOneshot("LeaderLib_ContainerInventory_AdjustItems", 1, function() AdjustSlots(true, 64, -1) end)
		end
	end, "After", "Keyboard")
end

--#endregion