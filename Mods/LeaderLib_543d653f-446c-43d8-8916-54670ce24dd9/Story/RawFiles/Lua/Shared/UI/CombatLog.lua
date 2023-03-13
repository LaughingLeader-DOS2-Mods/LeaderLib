local _ISCLIENT = Ext.IsClient()

---@class LeaderLibCombatLog
---@field Instance UIObject
---@field Root CombatLogFlashMainTimeline
---@field PrintFilters function Prints this.log_mc.filterList.content_array contents.
CombatLog = {}

setmetatable(CombatLog, {
	__index = function(tbl,k)
		if _ISCLIENT then
			if k == "Instance" then
				return CombatLog.GetInstance()
			elseif k == "Root" then
				local ui = CombatLog.GetInstance()
				if ui then
					return ui:GetRoot()
				end
			elseif k == "PrintFilters" then
				if not Vars.ControllerEnabled then
					local ui = CombatLog.GetInstance()
					if ui then
						local this = ui:GetRoot()
						if this then
							local arr = this.log_mc.filterList.content_array
							for i=0,#arr-1 do
								local mc = arr[i]
								fprint(LOGLEVEL.TRACE, "log_mc.filterList.content_array[%s] = id(%s) tooltip(%s)", i, mc.id, mc.tooltip)
							end
						end
					end
				end
			end
		end
	end
})

---@class CombatLogFilterData
---@field DisplayName string
---@field Index integer The index in the content_array.
---@field ID integer Generated ID.

---@class LeaderLibCombatLogFilters
CombatLog.Filters = {
	Combat = {
		Index = 0,
		ID = 0,
		DisplayName = "Combat"
	},
	Dialog = {
		Index = 1,
		ID = 2,
		DisplayName = "Dialogue"
	},
	Banter = {
		Index = 2,
		ID = 1,
		DisplayName = "Dialogue"
	}
}

if _ISCLIENT then
	CombatLog.LastID = 776

	local self = CombatLog

	---@return UIObject
	function CombatLog.GetInstance()
		local ui = not Vars.ControllerEnabled and Ext.UI.GetByType(Data.UIType.combatLog) or Ext.UI.GetByType(Data.UIType.combatLog_c)
		if ui then
			return ui
		end
		return nil
	end

	---@private
	function CombatLog.UpdateIndexes()
		if Vars.ControllerEnabled then
			return
		end
		local this = self.Root
		if not this then 
			return
		end
		local arr = this.log_mc.filterList.content_array
		for i=0,#arr-1 do
			---@type CombatLogFlashFilter
			local filter = arr[i]
			if filter then
				if type(filter.registeredId) == "string" then
					local data = CombatLog.Filters[filter.registeredId]
					if not data then
						CombatLog.Filters[filter.registeredId] = {
							DisplayName = filter.tooltip,
							ID = filter.id
						}
						data = CombatLog.Filters[filter.registeredId]
					end
					data.Index = i
				else
					for k,v in pairs(CombatLog.Filters) do
						if v.ID == filter.id then
							v.Index = i
							filter.registeredId = k
							break
						end
					end
				end
			end
		end
	end

	---@param id string
	---@param tooltip string
	---@param enabled boolean|nil If true/false, the filter is enabled or disabled. Enabled by default if not set.
	---@param frame integer|nil
	function CombatLog.AddFilter(id, tooltip, enabled, frame)
		if Vars.ControllerEnabled then
			return
		end
		local this = self.Root
		if not this then 
			return false
		end
		local arr = this.log_mc.filterList.content_array
		frame = frame or 1
		local exists = false
		--Check if a filter already exists
		for i=0,#arr-1 do
			---@type {registeredId:string, tooltip:string, gotoAndStop:fun(frame:string|integer)}
			local filter = arr[i]
			if filter then
				if filter.registeredId == id or filter.tooltip == tooltip then
					CombatLog.LastID = CombatLog.LastID + 1
					CombatLog.Filters[id] = {
						Index = i,
						ID = CombatLog.LastID,
						DisplayName = tooltip
					}
					filter.gotoAndStop(frame)
					exists = true
				end
			end
		end
		if not exists then
			local intId = #arr
			CombatLog.LastID = CombatLog.LastID + 1
			CombatLog.Filters[id] = {
				Index = intId,
				ID = CombatLog.LastID,
				DisplayName = tooltip
			}
			this.addFilter(intId, tooltip, frame)
			local filter = arr[CombatLog.Filters[id].ID]
			if filter then
				filter.registeredId = id
			end
		end
		local data = CombatLog.Filters[id]
		if enabled ~= nil then
			this.setFilterSelection(data.ID, enabled)
		end
		return data
	end

	---@param id string
	function CombatLog.RemoveFilter(id)
		if Vars.ControllerEnabled then
			return
		end
		local filter = self.Filters[id]
		if filter then
			local this = self.Root
			if this then
				this.clearFilter(filter.ID)
				this.log_mc.filterList.removeElement(filter.ID)
			end
		else
			fprint(LOGLEVEL.WARNING, "[CombatLog.AddTextToFilter] Filter (%s) was not added!", id)
		end
	end

	---@param id string
	---@param text string
	function CombatLog.AddTextToFilter(id, text)
		local this = self.Root
		if this then 
			local t = type(id)
			if t == "string" and not StringHelpers.IsNullOrWhitespace(id) then
				local filter = self.Filters[id]
				if filter then
					this.addTextToFilter(filter.ID, text)
				else
					fprint(LOGLEVEL.WARNING, "[CombatLog.AddTextToFilter] Filter (%s) was not added!", id)
				end
			elseif t == "number" then
				this.addTextToFilter(id, text)
			else
				this.addTextToFilter(0, text)
			end
		end
	end

	---@param index integer
	---@param text string
	function CombatLog.AddTextToIndex(index, text)
		local this = self.Root
		if this then 
			this.addTextToFilter(index, text)
		end
	end

	function CombatLog.SetFilterEnabled(id, enabled)
		local filter = self.Filters[id]
		if filter then
			local this = self.Root
			if this then 
				this.setFilterSelection(filter.ID, enabled)
			end
		else
			fprint(LOGLEVEL.WARNING, "[CombatLog.AddTextToFilter] Filter (%s) was not added!", id)
		end
	end

	function CombatLog.Clear()
		local this = self.Root
		if this then
			if not Vars.ControllerEnabled then
				this.clearAllTexts()
			else
				this.clearAll()
			end
		end
	end

	Ext.RegisterNetListener("LeaderLib_CombatLog_AddTextToFilter", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data.ID and data.Text then
			CombatLog.AddTextToFilter(data.ID, data.Text)
		end
	end)

	Ext.RegisterNetListener("LeaderLib_CombatLog_AddTextToIndex", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data.ID and data.Text then
			CombatLog.AddTextToFilter(tonumber(data.ID) or 0, data.Text)
		end
	end)

	local clientHidCombatLog = false

	Ext.RegisterUITypeInvokeListener(Data.UIType.combatLog, "setLogVisible", function(ui, event, b)
		if b == true then
			CombatLog.UpdateIndexes()
			clientHidCombatLog = false
		end
	end)


	Ext.RegisterUITypeCall(Data.UIType.hotBar, "CombatLogBtnPressed", function ()
		clientHidCombatLog = false
		local this = CombatLog.Root
		if this and this.log_mc.visible then
			clientHidCombatLog = true			
		end
	end, "Before")

	Events.RegionChanged:Subscribe(function(e)
		if not clientHidCombatLog and e.LevelType == LEVELTYPE.GAME and e.State == REGIONSTATE.GAME then
			Timer.StartOneshot("LeaderLib_CombatLog_Enable", 1250, function ()
				local settings = GameSettingsManager.GetSettings()
				if settings and settings.Client.ToggleCombatLog == true then
					local this = CombatLog.Root
					if this and not this.log_mc.visible then
						--[[ if not Vars.ControllerEnabled then
							local hotbar = Ext.UI.GetByType(Data.UIType.hotBar)
							if hotbar then
								hotbar:ExternalInterfaceCall("CombatLogBtnPressed")
							end
						end ]]
						this.log_mc.visible = true
					end
				end
			end)
		end
	end)
else
	---@param filterId string|integer
	---@param text string
	function CombatLog.AddTextToHost(filterId, text)
		if type(filterId) == "number" then
			GameHelpers.Net.PostToUser(CharacterGetHostCharacter(), "LeaderLib_CombatLog_AddTextToIndex", Common.JsonStringify({ID=filterId, Text=text}))
		else
			GameHelpers.Net.PostToUser(CharacterGetHostCharacter(), "LeaderLib_CombatLog_AddTextToFilter", Common.JsonStringify({ID=filterId, Text=text}))
		end
	end

	---@param client CharacterParam
	---@param filterId string|integer
	---@param text string
	function CombatLog.AddTextToPlayer(client, filterId, text)
		local uuid = GameHelpers.GetUUID(client)
		if type(filterId) == "number" then
			GameHelpers.Net.PostToUser(uuid, "LeaderLib_CombatLog_AddTextToIndex", Common.JsonStringify({ID=filterId, Text=text}))
		else
			GameHelpers.Net.PostToUser(uuid, "LeaderLib_CombatLog_AddTextToFilter", Common.JsonStringify({ID=filterId, Text=text}))
		end
	end

	---@param filterId string|integer
	---@param text string
	function CombatLog.AddTextToAllPlayers(filterId, text)
		if type(filterId) == "number" then
			GameHelpers.Net.Broadcast("LeaderLib_CombatLog_AddTextToIndex", Common.JsonStringify({ID=filterId, Text=text}))
		else
			GameHelpers.Net.Broadcast("LeaderLib_CombatLog_AddTextToFilter", Common.JsonStringify({ID=filterId, Text=text}))
		end
	end

	---Adds text to the combat filter for all players.
	---@param text string
	---@param onlyClient CharacterParam|UserId|nil
	function CombatLog.AddCombatText(text, onlyClient)
		if not onlyClient then
			GameHelpers.Net.Broadcast("LeaderLib_CombatLog_AddTextToFilter", {ID=CombatLog.Filters.Combat, Text=text})
		else
			GameHelpers.Net.PostToUser(onlyClient, "LeaderLib_CombatLog_AddTextToFilter", {ID=CombatLog.Filters.Combat, Text=text})
		end
	end

	---Adds standard damage text to the combat log.
	---@param targetDisplayName string
	---@param damageType string
	---@param damageAmount integer
	---@param isFromSurface boolean|nil If true, the text is "x was hit for y by surface" instead.
	---@param filterId string|integer|nil Optional filter. Defaults to the Combat filter.
	function CombatLog.AddDamageText(targetDisplayName, damageType, damageAmount, isFromSurface, filterId)
		if filterId == nil then
			filterId = CombatLog.Filters.Combat
		end
		local damageText = GameHelpers.GetDamageText(damageType, damageAmount)
		local text = not isFromSurface and LocalizedText.CombatLog.WasHitFor:ReplacePlaceholders(targetDisplayName, LocalizedText.Keywords.Hit, damageText) or LocalizedText.CombatLog.WasHitBySurface:ReplacePlaceholders(targetDisplayName, LocalizedText.Keywords.Hit, damageText)
		if type(filterId) == "number" then
			GameHelpers.Net.Broadcast("LeaderLib_CombatLog_AddTextToIndex", Common.JsonStringify({ID=filterId, Text=text}))
		else
			GameHelpers.Net.Broadcast("LeaderLib_CombatLog_AddTextToFilter", Common.JsonStringify({ID=filterId, Text=text}))
		end
	end
end

if Vars.DebugMode then
	Ext.Events.SessionLoaded:Subscribe(function()
		AddConsoleVariable("combatlog", CombatLog)
	end)
end