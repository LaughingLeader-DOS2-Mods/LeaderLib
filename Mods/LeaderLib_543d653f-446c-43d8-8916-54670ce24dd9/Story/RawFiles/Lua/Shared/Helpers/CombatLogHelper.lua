if CombatLog == nil then
	CombatLog = {}
end

local isClient = Ext.IsClient()

if isClient then
	---@class CombatLogFilterData
	---@field DisplayName string
	---@field Index integer

	---@type table<string,CombatLogFilterData>
	CombatLog.Filters = {
		
	}
	---@type CombatLogFlashMainTimeline
	CombatLog.Instance = nil
	---@type UIObject
	CombatLog.UI = nil

	local self = CombatLog

	---@return CombatLogFlashMainTimeline
	function CombatLog.GetInstance()
		if self.Instance == nil or self.UI == nil then
			local ui = not Vars.ControllerEnabled and Ext.GetUIByType(Data.UIType.combatLog) or Ext.GetBuiltinUI("Public/Game/GUI/combatLog_c.swf")
			if ui then
				self.Instance = ui:GetRoot()
				self.UI = ui
			end
		end
		return self.Instance
	end

	---@param id string
	---@param tooltip string
	---@param enabled boolean|nil If true/false, the filter is enabled or disabled. Enabled by default if not set.
	---@param frame integer|nil
	function CombatLog.AddFilter(id, tooltip, enabled, frame)
		local this = self.GetInstance()
		if not this then 
			return false
		end
		local arr = this.log_mc.filterList.content_array
		frame = frame or 1
		local exists = false
		--Check if a filter already exists
		for i=0,#arr-1 do
			---@type CombatLogFlashFilter
			local filter = arr[i]
			if filter then
				if filter.registeredId == id or filter.tooltip == tooltip then
					CombatLog.Filters[id] = {
						Index = i,
						DisplayName = tooltip
					}
					filter.gotoAndStop(frame)
					exists = true
				end
			end
		end
		if not exists then
			local intId = #arr
			CombatLog.Filters[id] = {
				Index = intId,
				DisplayName = tooltip
			}
			this.addFilter(intId, tooltip, frame)
			local filter = arr[CombatLog.Filters[id].Index]
			if filter then
				filter.registeredId = id
			end
		end
		local data = CombatLog.Filters[id]
		if enabled ~= nil then
			this.setFilterSelection(data.Index, enabled)
		end
		return data
	end

	---@param id string
	function CombatLog.RemoveFilter(id)
		local filter = self.Filters[id]
		if filter then
			local this = self.GetInstance()
			if this then
				this.clearFilter(filter.Index)
				this.log_mc.filterList.removeElement(filter.Index)
			end
		else
			fprint(LOGLEVEL.WARNING, "[CombatLog.AddTextToFilter] Filter (%s) was not added!", id)
		end
	end

	---@param id string
	---@param tooltip string
	function CombatLog.AddTextToFilter(id, text)
		local this = self.GetInstance()
		if this then 
			local t = type(id)
			if t == "string" and not StringHelpers.IsNullOrWhitespace(id) then
				local filter = self.Filters[id]
				if filter then
					this.addTextToFilter(filter.Index, text)
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
	---@param tooltip string
	function CombatLog.AddTextToIndex(index, text)
		local this = self.GetInstance()
		if this then 
			this.addTextToFilter(index, text)
		end
	end

	function CombatLog.SetFilterEnabled(id, enabled)
		local filter = self.Filters[id]
		if filter then
			local this = self.GetInstance()
			if this then 
				this.setFilterSelection(filter.Index, enabled)
			end
		else
			fprint(LOGLEVEL.WARNING, "[CombatLog.AddTextToFilter] Filter (%s) was not added!", id)
		end
	end

	function CombatLog.Clear()
		local this = self.GetInstance()
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
else
	---@param filterId string
	---@param tooltip string
	function CombatLog.AddTextToHost(filterId, text)
		if type(filterId) == "string" then
			Ext.PostMessageToClient(CharacterGetHostCharacter(), "LeaderLib_CombatLog_AddTextToFilter", Ext.JsonStringify({ID=filterId, Text=text}))
		else
			Ext.PostMessageToClient(CharacterGetHostCharacter(), "LeaderLib_CombatLog_AddTextToIndex", Ext.JsonStringify({ID=filterId, Text=text}))
		end
	end
	
	---@param client EsvCharacter|UUID|NETID
	---@param filterId string
	---@param tooltip string
	function CombatLog.AddTextToPlayer(client, filterId, text)
		local uuid = GameHelpers.GetUUID(client)
		if type(filterId) == "string" then
			Ext.PostMessageToClient(uuid, "LeaderLib_CombatLog_AddTextToFilter", Ext.JsonStringify({ID=filterId, Text=text}))
		else
			Ext.PostMessageToClient(uuid, "LeaderLib_CombatLog_AddTextToIndex", Ext.JsonStringify({ID=filterId, Text=text}))
		end
	end

	---@param filterId string
	---@param tooltip string
	function CombatLog.AddTextToAllPlayers(filterId, text)
		if type(filterId) == "string" then
			Ext.BroadcastMessage("LeaderLib_CombatLog_AddTextToFilter", Ext.JsonStringify({ID=filterId, Text=text}))
		else
			Ext.BroadcastMessage("LeaderLib_CombatLog_AddTextToIndex", Ext.JsonStringify({ID=filterId, Text=text}))
		end
	end
end

if Vars.DebugMode then
	Ext.RegisterListener("SessionLoaded", function()
		AddConsoleVariable("combatlog", CombatLog)
	end)
end