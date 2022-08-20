local _initialized = false

local _format = string.format

local Init = function()
	if _initialized then
		return
	end

	local UIListenerWrapper = Classes.UIListenerWrapper

	local _logText = ""
	local _logPrefix = Ext.MonotonicTime()
	local _logName = _format("Logs/UI/%s_All.log", _logPrefix)

	local function _print(str, ...)
		if not UI.Debug.PrintAll then
			fprint(LOGLEVEL.TRACE, ...)
		else
			_logText = _logText .. "\n" .. _format(str, ...)
			Timer.Cancel("LeaderLib_Debug_SaveUILog")
			Timer.StartOneshot("LeaderLib_Debug_SaveUILog", 500, function ()
				GameHelpers.IO.SaveFile(_logName, _logText)
			end)
		end
	end
	---@param self UIListenerWrapper
	---@param ui UIObject
	local function OnUIListener(self, eventType, ui, event, ...)
		if self.Enabled and (Vars.DebugMode and (Vars.Print.UI or UI.Debug.PrintAll)) and not self.Ignored[event] then
			local name = self.Name
			if StringHelpers.IsNullOrEmpty(name) then
				local _,_,fname = string.find(ui.Path, ".-Public/.+/GUI/(.+).swf")
				if fname then
					name = fname
				else
					name = ui.AnchorObjectName
				end
				if StringHelpers.IsNullOrEmpty(name) then
					name = ui.Path
				end
			end
			if event == "addTooltip" then
				local txt = table.unpack({...})
				if string.find(txt, "Experience:", 1, true) then
					return
				end
			-- elseif lastEvent == event and Ext.GetGameState() ~= "Running" then
			-- 	return
			end
			if self.PrintParams then
				_print("[%s(%s)][%s] %s(%s) [%s]", name, ui.Type, eventType, event, StringHelpers.DebugJoin(", ", {...}), Ext.MonotonicTime())
			else
				_print("[%s(%s)][%s] %s [%s]", name, ui.Type, eventType, event, Ext.MonotonicTime())
			end

			if self.CustomCallback[event] then
				self.CustomCallback[event](self, ui, event, ...)
			end
		end
	end

	local defaultIgnored = {
		hideTooltip = true,
		PlaySound = true,
		dollOut = true,
		slotUp = true,
		update = true,
		updateStatuses = true,
		removeLabel = true,
		LeaderLib_UIExtensions_InputEvent = true,
		blockMouseWheelInput = true,
		setAllSlotsEnabled = true,
		setButtonEnable = true,
		updateSlotData = true,
		updateSlots = true,
		showExpTooltip = true,
		SlotHoverOut = true,
		setInputDevice = true,
		updateTooltips = true,
		moveText = true,
		clearAnchor = true,
		clearAll = true,
		removeTooltip = true,
		updateOHs = true,
		updateStatusses = true,
		clearObsoleteOHTs = true,
		removingOHT = true,
		updateBtnInfos = true,
		setBar1Progress = true,
		updateButtonHints = true,
		clearTooltipText = 43,
		removeText = 43,
		addText = 43,
	}

	local lastTimeSinceIgnored = {}
	local version = Ext.Utils.Version()

	---@param ui UIObject
	Ext.RegisterListener("UICall", function(ui, event, arg1, ...)
		if defaultIgnored[event] then
			return
			-- local lastTime = lastTimeSinceIgnored[event] or 0
			-- if Ext.MonotonicTime() - lastTime <= 1000 then
			-- 	lastTimeSinceIgnored[event] = Ext.MonotonicTime()
			-- 	return
			-- end
		end
		local t = ui.Type
		if UI.Debug.PrintAll then
			local name = Data.UITypeToName[t]
			if StringHelpers.IsNullOrEmpty(name) then
				local _,_,fname = string.find(ui.Path, ".-Public/.+/GUI/(.+).swf")
				if fname then
					name = fname
				else
					name = ui.AnchorObjectName
				end
				if StringHelpers.IsNullOrEmpty(name) then
					name = ui.Path
				end
			end
			_print("[%s(%s)][%s] %s(%s) [%s]", name, t, "call", event, StringHelpers.DebugJoin(", ", {...}), Ext.MonotonicTime())
		else
			local listener = UIListenerWrapper._TypeListeners[t]
			if listener then
				if version < 56 then
					OnUIListener(listener, "call", ui, event, arg1, ...)
				else
					--arg1 is "When" now.
					OnUIListener(listener, "call", ui, event, ...)
				end
			end
		end
	end)

	Ext.RegisterListener("UIInvoke", function(ui, event, arg1, ...)
		if defaultIgnored[event] then
			return
			-- local lastTime = lastTimeSinceIgnored[event] or 0
			-- if Ext.MonotonicTime() - lastTime < 1000 then
			-- 	lastTimeSinceIgnored[event] = Ext.MonotonicTime()
			-- 	return
			-- end
		end
		local t = ui.Type
		if UI.Debug.PrintAll then
			local name = Data.UITypeToName[t]
			if StringHelpers.IsNullOrEmpty(name) then
				local _,_,fname = string.find(ui.Path, ".-Public/.+/GUI/(.+).swf")
				if fname then
					name = fname
				else
					name = ui.AnchorObjectName
				end
				if StringHelpers.IsNullOrEmpty(name) then
					name = ui.Path
				end
			end
			_print("[%s(%s)][%s] %s(%s) [%s]", name, t, "invoke", event, StringHelpers.DebugJoin(", ", {...}), Ext.MonotonicTime())
		else
			local listener = UIListenerWrapper._TypeListeners[t]
			if listener then
				if version < 56 then
					OnUIListener(listener, "method", ui, event, arg1, ...)
				else
					--arg1 is "When" now.
					OnUIListener(listener, "method", ui, event, ...)
				end
			end
		end
	end)

	---@param ui UIObject
	Ext.RegisterListener("UIObjectCreated", function(ui)
		for path,data in pairs(UIListenerWrapper._DeferredRegistrations) do
			local ui2 = Ext.GetBuiltinUI(path)
			if ui2 and (ui2:GetTypeId() == ui:GetTypeId() or ui == ui2) then
				data.ID = ui2:GetTypeId()
				UIListenerWrapper._DeferredRegistrations[path] = nil
				if data.Initialized then
					local this = ui2:GetRoot()
					local b,err = xpcall(this.Initialized, debug.traceback, ui)
					if not b then
						Ext.Utils.PrintError(err)
					end
				end
			end
		end
	end)

	local enabledParam = {Enabled=true}

	--local contextMenu = UIListenerWrapper:Create(Data.UIType.contextMenu, enabledParam)
	--local characterSheet = UIListenerWrapper:Create(Data.UIType.characterSheet, enabledParam)
	--local characterCreation = UIListenerWrapper:Create(Data.UIType.characterCreation, enabledParam)
	--local chatLog = UIListenerWrapper:Create(Data.UIType.chatLog, enabledParam)
	-- local areaInteract_c = UIListenerWrapper:Create(Data.UIType.areaInteract_c)
	-- local containerInventory = UIListenerWrapper:Create(Data.UIType.containerInventory, enabledParam)
	-- local uiCraft = UIListenerWrapper:Create(Data.UIType.uiCraft, enabledParam)
	-- local dialog = UIListenerWrapper:Create(Data.UIType.dialog,enabledParam)
	-- local enemyHealthBar = UIListenerWrapper:Create(Data.UIType.enemyHealthBar)
	local examine = UIListenerWrapper:Create(Data.UIType.examine, enabledParam)
	-- local gmPanelHUD = UIListenerWrapper:Create(Data.UIType.GMPanelHUD)
	-- local journal_csp = UIListenerWrapper:Create(Data.UIType.journal_csp)
	-- local LeaderLib_UIExtensions = UIListenerWrapper:Create("Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/LeaderLib_UIExtensions.swf", enabledParam)
	-- local mainMenu = UIListenerWrapper:Create(Data.UIType.mainMenu)
	-- local msgBox = UIListenerWrapper:Create(Data.UIType.msgBox, enabledParam)
	-- local msgBox_c = UIListenerWrapper:Create(Data.UIType.msgBox_c, enabledParam)
	local overhead = UIListenerWrapper:Create(Data.UIType.overhead)
	overhead.CustomCallback.updateOHs = function(self, ui, method)
		local root = ui:GetRoot()
		local data = {
			addOH_array = {},
			selectionInfo_array = {},
			hp_array = {},
			instance = ui,
		}
		local hasData = false
		for i=0,#root.addOH_array-1 do
			data.addOH_array[i] = root.addOH_array[i]
			hasData = true
		end
		for i=0,#root.selectionInfo_array-1 do
			data.selectionInfo_array[i] = root.selectionInfo_array[i]
			hasData = true
		end
		for i=0,#root.hp_array-1 do
			data.hp_array[i] = root.hp_array[i]
			hasData = true
		end
		if hasData then
			--GameHelpers.IO.SaveJsonFile(_format("Dumps/overhead_%s.json", Ext.MonotonicTime()), Ext.DumpExport(data))
			GameHelpers.IO.SaveJsonFile("Dumps/overhead.json", Ext.DumpExport(data))
		end
	end
	-- local partyInventory = UIListenerWrapper:Create(Data.UIType.partyInventory, enabledParam)
	-- local playerInfo = UIListenerWrapper:Create(Data.UIType.playerInfo, {Enabled=true, Ignored={updateStatuses=true}})
	-- local possessionBar = UIListenerWrapper:Create(Data.UIType.possessionBar)
	-- local pyramid = UIListenerWrapper:Create(Data.UIType.pyramid, enabledParam)
	-- local reward = UIListenerWrapper:Create(Data.UIType.reward, enabledParam)
	-- local reward_c = UIListenerWrapper:Create(Data.UIType.reward_c, enabledParam)
	-- local optionsSettings = UIListenerWrapper:Create(Data.UIType.optionsSettings, enabledParam)
	-- local skills = UIListenerWrapper:Create(Data.UIType.skills)
	-- local statusConsole = UIListenerWrapper:Create(Data.UIType.statusConsole)
	--local tooltipMain = UIListenerWrapper:Create(Data.UIType.tooltip, enabledParam)
	--UIListenerWrapper:Create(Data.UIType.journal, enabledParam)
	--local worldTooltip = UIListenerWrapper:Create(Data.UIType.worldTooltip, enabledParam)
	--local textDisplay = UIListenerWrapper:Create(Data.UIType.textDisplay, enabledParam)

	-- characterCreation.CustomCallback.updateContent = function(self, ui, method)
	-- 	local this = ui:GetRoot()
	-- 	if this then
	-- 		local content = {}
	-- 		for i=0,#this.contentArray-1 do
	-- 			content[#content+1] = this.contentArray[i]
	-- 		end
	-- 		Ext.SaveFile("ConsoleDebug/characterCreation_updateContent.lua", TableHelpers.ToString(content))
	-- 	end
	-- end

	local printArrays = {
		"lvlBtnAbility_array",
		"lvlBtnStat_array",
		"lvlBtnTalent_array",
		"lvlBtnSecStat_array",
	}

	-- characterSheetDebug.CustomCallback.updateArraySystem = function(self, ui, method)
	-- 	local this = ui:GetRoot()
	-- 	for _,arrName in pairs(printArrays) do
	-- 		local array = this[arrName]
	-- 		if array and #array > 0 then
	-- 			for i=0,#array-1 do
	-- 				print(arrName, i, array[i])
	-- 			end
	-- 		end
	-- 	end
	-- end

	local statsPanelDebug = UIListenerWrapper:Create(Data.UIType.statsPanel_c)
	statsPanelDebug.CustomCallback["updateArraySystem"] = function(self, ui, method)
		local arr = ui:GetRoot().customStats_array
		if arr then
			local length = #arr
			Ext.Utils.Print("customStats_array", length)
			if length > 0 then
				for i=0,length do
				Ext.Utils.Print(i, arr[i])
				end
			end
		end
	end

	---@param ui UIObject
	-- contextMenu.CustomCallback["updateButtons"] = function(self, ui, method)
	-- 	local this = ui:GetRoot()
	-- 	local buttons = {}
	-- 	local arr = this.buttonArr
	-- 	if arr then
	-- 		local length = #arr
	-- 		if length > 0 then
	-- 			for i=0,length,7 do
	-- 				buttons[#buttons+1] = {
	-- 					Index = i,
	-- 					id = arr[i],
	-- 					actionID = arr[i+1],
	-- 					clickSound = arr[i+2],
	-- 					text = arr[i+3],
	-- 					disabled = arr[i+4],
	-- 					legal = arr[i+5],
	-- 					unused = arr[i+6],
	-- 				}
	-- 			end
	-- 		end
	-- 	end
	-- 	Ext.Utils.Print(method,Lib.serpent.block(buttons))
	-- end

	--local hotbar = UIListenerWrapper:Create(Data.UIType.hotBar, enabledParam)
	--[[
	---@param ui UIObject
	hotbar.CustomCallback["updateSlotData"] = function(self, ui, method)
		local this = ui:GetRoot()
		local array = this.slotUpdateDataList
		for i=0,#array-1 do
			local entry = array[i]
			if entry then
				Ext.Utils.Print(i, entry)
			else
				Ext.Utils.Print(i, "nil")
			end
		end
	end

	---@param ui UIObject
	hotbar.CustomCallback["updateSlots"] = function(self, ui, method)
		local this = ui:GetRoot()
		local array = this.slotUpdateList
		for i=0,#array do
			local entry = array[i]
			if entry then
				Ext.Utils.Print(i, entry)
			else
				Ext.Utils.Print(i, "nil")
			end
		end
	end
	]]

	for k,v in pairs(Data.UIType.optionsSettings) do
		UIListenerWrapper:Create(v, enabledParam)
	end
	for k,v in pairs(Data.UIType.optionsSettings_c) do
		UIListenerWrapper:Create(v, enabledParam)
	end

	---@param ui UIObject
	-- skills.CustomCallback["updateSkills"] = function(self, ui, method, b)
	-- 	local this = ui:GetRoot()
	-- 	local array = this.skillsUpdateList
	-- 	for i=0,#array do
	-- 		local entry = array[i]
	-- 		if entry then
	-- 			print(i, entry)
	-- 			if type(entry) == "string" then
	-- 				local stat = Ext.Stats.Get(entry)
	-- 				if stat then
	-- 					this.skillsUpdateList[i] = "Projectile_Fireball"
	-- 				end
	-- 			end
	-- 		else
	-- 			print(i, "nil")
	-- 		end
	-- 	end
	-- end

	local combatLog = UIListenerWrapper:Create(Data.UIType.combatLog, enabledParam)
	local GMPanelHUD = UIListenerWrapper:Create(Data.UIType.GMPanelHUD,{
		---@param ui UIObject
		Initialized = function(ui)
			Ext.Utils.PrintError("GMPANELHUD")
			local this = ui:GetRoot()
			if this then
				local printArr = function(name, arr)
					Ext.Utils.Print(name, #arr)
					for i=0,#arr-1 do
						Ext.Utils.Print(name, i, arr[i].id)
					end
				end
				local arr = this.GMBar_mc.slotList.content_array
				printArr("GMBar_mc", this.GMBar_mc.slotList.content_array)
				printArr("targetBar_mc", this.targetBar_mc.slotList.content_array)
				printArr("secActionList", this.secActionList.content_array)
			end
		end
	})
	GMPanelHUD.Enabled = true

	local roll = UIListenerWrapper:Create(Data.UIType.roll, {
		---@param ui UIObject
		Initialized = function(ui)
			Ext.Utils.PrintError("roll")
			local this = ui:GetRoot()
			if this then
				this.setIsGM(Client.Character.IsGameMaster)
			end
		end
	})
	roll.Enabled = true
	roll.CustomCallback["updateRolls"] = function(self, ui, call, b)
		local this = ui:GetRoot()
		this.ownerCharacter = Ext.UI.HandleToDouble(Client:GetCharacter().Handle)
		this.isGM = Client.Character.IsGameMaster
		this.Initialize()
	end
	
	_initialized = true
end

return Init