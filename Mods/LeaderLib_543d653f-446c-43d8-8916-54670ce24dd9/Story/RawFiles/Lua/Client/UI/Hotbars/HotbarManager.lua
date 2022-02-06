UIExtensions.Hotbars = {}
local self = UIExtensions.Hotbars

local Hotbar = Classes.UIWrapper:CreateFromType(Data.UIType.hotBar, {ControllerID = Data.UIType.bottomBar_c, IsControllerSupported = true})
local StatusConsole = Classes.UIWrapper:CreateFromType(Data.UIType.statusConsole, {ControllerID = Data.UIType.statusPanel, IsControllerSupported = true})

local draws = {}

local function ClearCustomDrawsForHotbar(hotbarIndex)
	local data = draws[hotbarIndex]
	if data then
		local inst = UIExtensions.Instance
		for name,b in pairs(data) do
			inst:ClearCustomIcon(name)
		end
	end
end

local function RegisterCustomDraw(inst, hotbarIndex, name, icon)
	if draws[hotbarIndex] == nil then
		draws[hotbarIndex] = {}
	end
	draws[hotbarIndex][name] = icon
	inst:SetCustomIcon(name, icon, 50, 50)
end

local function ClearCustomDraw(inst, hotbarIndex, name)
	if draws[hotbarIndex] ~= nil then
		inst:ClearCustomIcon(name)
		draws[hotbarIndex][name] = nil
	end
end

RegisterListener("BeforeLuaReset", function ()
	local inst = UIExtensions.Instance
	for hotbarIndex,data in pairs(draws) do
		for name,b in pairs(data) do
			inst:ClearCustomIcon(name)
		end
	end
end)

local function UpdateHotbar(hotbar, playerData, playerDoubleHandle)
	local inst = UIExtensions.Instance
	local currentHotbarIndex = hotbar.currentHotBarIndex
	local hotbarIndexOffset = (hotbar.currentHotBarIndex-1) * hotbar.maxSlots
	ClearCustomDrawsForHotbar(currentHotbarIndex)
	draws[currentHotbarIndex] = {}
	for i=0,hotbar.maxSlots-1 do
		local slotDataIndex = (i+1) + hotbarIndexOffset
		local iconName = string.format("LeaderLib_Hotbar_Slot%i", slotDataIndex)
		local usesSource = false
		local slotData = playerData.Skillbar[slotDataIndex]
		if slotData then
			Ext.Dump({RealSlot = hotbarIndexOffset + i, Index = i, SlotData = slotData or "nil", HotbarIndex = hotbar.currentHotBarIndex})
			local iggyIconName = "iggy_" .. iconName
			if slotData.Type ~= "Item" then
				if slotData.Type == "Skill" then
					local stat = Ext.GetStat(slotData.SkillOrStatId)
					if stat then
						if stat["Magic Cost"] > 0 then
							usesSource = true
						end
						if not StringHelpers.IsNullOrEmpty(stat.Icon) then
							RegisterCustomDraw(inst, currentHotbarIndex, iconName, stat.Icon)
						end
					end
				end
				--slotNum:Number, tooltip:String, isEnabled:Boolean, handle:Number, slotType:Number, amount:Number = -1, iconName:String = ""
				hotbar.slotholder_mc.setSlot(i, slotData.SkillOrStatId, true, playerDoubleHandle, 1, -1, iggyIconName)
			else
				local item = Ext.GetItem(slotData.ItemHandle)
				if item then
					if not StringHelpers.IsNullOrEmpty(item.RootTemplate.Icon) then
						RegisterCustomDraw(inst, currentHotbarIndex, iconName, item.RootTemplate.Icon)
					end
					local itemDouble = Ext.HandleToDouble(item.Handle)
					Ext.PrintError(item.NetID, itemDouble, item.DisplayName)
					hotbar.slotholder_mc.setSlot(i, item.DisplayName, true, itemDouble, 2, slotData.Amount, iggyIconName)
				else
					hotbar.slotholder_mc.setSlot(i, slotData.SkillOrStatId, true, playerDoubleHandle, 1, -1)
				end
			end
			hotbar.slotholder_mc.setSourceVisible(i, usesSource)
		else
			ClearCustomDraw(inst, currentHotbarIndex, iconName)
			hotbar.slotholder_mc.setSlotIcon(i)
		end
	end
	Ext.Dump(draws)
end

Ext.RegisterUINameCall("LeaderLib_Hotbars_CycleHotbar", function (ui, call, hotbarId, barIndex)
	local this = UIExtensions.Root
	if this then
		this = this.hotbars_mc
		local index = this.getIndexByID(hotbarId)
		if index > -1 then
			local hotbar = this.entries[index]
			if hotbar then
				local playerData = Client:GetCharacterData()
				local player = Client:GetCharacter()
				local doubleHandle = Ext.HandleToDouble(player.Handle)
				UpdateHotbar(hotbar, playerData, doubleHandle)
			end
		end
	end
end, "Before")

local function GetEngineSlotIndex(index, hotbarIndex)
	return index + ((hotbarIndex - 1) * 29)
end

Ext.RegisterUINameCall("LeaderLib_Hotbar_SlotPressed", function (ui, call, slotIndex, isEnabled, hotbarIndex)
	Hotbar:ExternalInterfaceCall("SlotPressed", GetEngineSlotIndex(slotIndex, hotbarIndex), isEnabled)
end, "Before")

Ext.RegisterUINameCall("LeaderLib_Hotbar_SlotHover", function (ui, call, slotIndex, hotbarIndex)
	Hotbar:ExternalInterfaceCall("SlotHover", GetEngineSlotIndex(slotIndex, hotbarIndex))
end, "Before")

Ext.RegisterUINameCall("LeaderLib_Hotbar_SlotHoverOut", function (ui, call, slotIndex, hotbarIndex)
	Hotbar:ExternalInterfaceCall("SlotHoverOut", GetEngineSlotIndex(slotIndex, hotbarIndex))
end, "Before")

Ext.RegisterUINameCall("LeaderLib_Hotbar_ShowItemTooltip", function (ui, call, itemDouble, x, y, width, height, extra, side)
	Hotbar:ExternalInterfaceCall("showItemTooltip", itemDouble, x, y, width, height, extra, side)
end, "Before")

local function GetHotbarStartPosition(inst, hotbarRoot, hotbarInst)
	--local x = hotbarRoot.x + hotbarRoot.hotbar_mc.x + hotbarRoot.hotbar_mc.slotholder_mc.x
	local x = hotbarRoot.showLog_mc.x - 1647.2
	--local x = (hotbarInst.FlashSize[1]/hotbarInst.FlashMovieSize[1]) * hotbarRoot.showLog_mc.x - (1647.2 * (inst.FlashSize[1]/inst.FlashMovieSize[1]))
	local y = (inst.FlashMovieSize[2] - 126) - 4
	x = Game.Math.ConvertScreenCoordinates(x, y, hotbarInst.FlashSize[1], hotbarInst.FlashSize[2], inst.FlashSize[1], inst.FlashSize[2])
	--x = x - 1647.2
	Ext.Dump({UIExt = inst.FlashSize, Hotbar = hotbarInst.FlashSize, X = x, Y = y})
	return x,y
end

local function PositionHotbar()
	local inst = UIExtensions.Instance
	local this = inst:GetRoot()
	local hotbarInst = Hotbar.Instance
	local hotbarRoot = hotbarInst:GetRoot()

	if this then
		local hotbars_mc = this.hotbars_mc
		local x,y = 0,0
		if hotbarRoot then
			-- x = hotbarRoot.hotbar_mc.x + hotbarRoot.hotbar_mc.lockButton_mc.x
			-- y = hotbarRoot.hotbar_mc.y + hotbarRoot.hotbar_mc.lockButton_mc.y - hotbarRoot.hotbar_mc.lockButton_mc.height
			--300.5627044711  1008.7321466525
			--333.48413085938 950.60906982422
			--318
			x,y = GetHotbarStartPosition(inst, hotbarRoot, hotbarInst)
			hotbarRoot.showLog_mc.y = (874 - 64)
		end
		local hotbar = hotbars_mc.entries[0]
		hotbar.x = x
		hotbar.y = y

		local sc = StatusConsole.Root
		if sc then
			local offset = 64 + sc.bottomBarHeight
			sc.fightButtons_mc.y = 1080 - offset
			sc.turnNotice_mc.y = 1080 - offset
			sc.console_mc.y = 1080 - offset
		end
	end
end

Hotbar:RegisterCallListener("updateSlots", function (self, ui, call)
	PositionHotbar()
end)

RegisterListener("UIExtensionsResized", function (ui, w, h)
	PositionHotbar()
end)

function UIExtensions.Hotbars.Init()
	local inst = UIExtensions.Instance
	local this = inst:GetRoot()
	local hotbarInst = Hotbar.Instance
	local hotbarRoot = hotbarInst:GetRoot()

	if this then
		local hotbars_mc = this.hotbars_mc
		local x,y = 0,0
		if hotbarRoot then
			-- x = hotbarRoot.hotbar_mc.x + hotbarRoot.hotbar_mc.lockButton_mc.x
			-- y = hotbarRoot.hotbar_mc.y + hotbarRoot.hotbar_mc.lockButton_mc.y - hotbarRoot.hotbar_mc.lockButton_mc.height
			--300.5627044711  1008.7321466525
			--333.48413085938 950.60906982422
			x,y = GetHotbarStartPosition(inst, hotbarRoot, hotbarInst)
			hotbarRoot.showLog_mc.y = (874 - 64)
		end
		hotbars_mc.add(1, x, y)

		local sc = StatusConsole.Root
		if sc then
			local offset = 64 + sc.bottomBarHeight
			sc.fightButtons_mc.y = 1080 - offset
			sc.turnNotice_mc.y = 1080 - offset
			sc.console_mc.y = 1080 - offset
		end
	end
	if Client.Character ~= nil then
		self.Update()
	end
end

function UIExtensions.Hotbars.Update()
	local this = UIExtensions.Root
	if this then
		local hotbars_mc = this.hotbars_mc
		local playerData = Client:GetCharacterData()
		local player = Client:GetCharacter()
		local doubleHandle = 0
		if player then
			doubleHandle = Ext.HandleToDouble(player.Handle)
		end
		local count = hotbars_mc.length
		if count > 0 then
			for i=0,count-1 do
				local hotbar = hotbars_mc.entries[i]
				if hotbar then
					UpdateHotbar(hotbar, playerData, doubleHandle)
					hotbar.slotholder_mc.updateClearOldSlots()
				end
			end
		end
	end
end

RegisterListener("ClientDataSynced", function (modData, sharedData)
	if Ext.GetGameState() == "Running" then
		local hotbar = Hotbar.Root
		if hotbar and hotbar.hotbar_mc.isSkillBarShown then
			UIExtensions.Hotbars.Update()
		end
	end
end)

--local ui = Ext.GetUIByType(40); ui:ExternalInterfaceCall("SlotPressed", 1, true);

Ext.RegisterUITypeInvokeListener(Data.UIType.hotBar, "updateSlots", function (ui, event)
	local data = {}
	local this = ui:GetRoot()
	for i=0,#this.slotUpdateList-1,7 do
		data[#data+1] = {
			SlotIndex = this.slotUpdateList[i],
			Amount = this.slotUpdateList[i+1],
			Tooltip = this.slotUpdateList[i+2],
			IsEnabled = this.slotUpdateList[i+3],
			Handle = this.slotUpdateList[i+4],
			SlotType = this.slotUpdateList[i+5],
			SourceVisible = this.slotUpdateList[i+6],
		}
	end
	GameHelpers.IO.SaveJsonFile("Dumps/hotBar_updateSlots.json", data)
end)

Ext.RegisterUITypeInvokeListener(Data.UIType.hotBar, "updateSlotData", function (ui, event)
	local data = {}
	local this = ui:GetRoot()
	for i=0,#this.slotUpdateDataList-1,3 do
		data[#data+1] = {
			SlotIndex = this.slotUpdateDataList[i],
			SlotType = this.slotUpdateDataList[i+1],
			IsEnabled = this.slotUpdateDataList[i+2]
		}
	end
	GameHelpers.IO.SaveJsonFile("Dumps/hotBar_updateSlotData.json", data)
end)