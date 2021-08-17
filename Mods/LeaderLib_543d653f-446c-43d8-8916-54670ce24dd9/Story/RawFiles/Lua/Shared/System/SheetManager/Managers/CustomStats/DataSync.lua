local self = CustomStatSystem

local isClient = Ext.IsClient()

---@private
function CustomStatSystem:SyncAvailablePoints(character)
	if not isClient then
		self:SyncData()
	else
		character = character or self:GetCharacter()
		local data = {
			NetID = character.NetID,
			Stats = {}
		}
		for stat in self:GetAllStats() do
			if stat.AvailablePoints then
				local amount = stat.AvailablePoints[character.NetID]
				if amount then
					if not StringHelpers.IsNullOrWhitespace(stat.PointID) then
						data.Stats[stat.PointID] = amount
					else
						data.Stats[stat.ID] = amount
					end
				end
			end
		end
		Ext.PostMessageToServer("LeaderLib_SyncCustomStatAvailablePoints", Ext.JsonStringify(data))
	end
end

if not isClient then
	---@private
	---Creates a table of stat id to uuid, for sending stat UUIDs to the client
	function CustomStatSystem:GetSyncData()
		if self:GMStatsEnabled() then
			local data = {
				Registered = {},
				Unregistered = {}
			}
			for uuid,stats in pairs(self.Stats) do
				data.Registered[uuid] = {}
				for id,stat in pairs(stats) do
					if stat.UUID then
						data.Registered[uuid][id] = stat.UUID
					end
				end
			end
			for uuid,stat in pairs(self.UnregisteredStats) do
				data.Unregistered[uuid] = {
					DisplayName = stat.DisplayName,
					Description = stat.Description,
					LastValue = stat.LastValue or {}
				}
			end
			return data
		else
			return {}
		end
	end

	---@private
	function CustomStatSystem:SyncData(user)
		local availablePoints = {}
		for uuid,data in pairs(PersistentVars.CustomStatAvailablePoints) do
			if ObjectExists(uuid) == 1 then
				local character = Ext.GetCharacter(uuid)
				if character then
					if data[""] then
						data[""] = nil
					end
					availablePoints[character.NetID] = data
				end
			end
		end
		if self:GMStatsEnabled() then
			local payload = Ext.JsonStringify({
				CustomStats = self:GetSyncData(),
				AvailablePoints = availablePoints
			})
			if user then
				Ext.PostMessageToUser(user, "LeaderLib_SharedData_StoreCustomStatData", payload)
			else
				Ext.BroadcastMessage("LeaderLib_SharedData_StoreCustomStatData", payload)
			end
		else
			local payload = Ext.JsonStringify({
				CustomStats = {},
				AvailablePoints = availablePoints
			})
			if user then
				Ext.PostMessageToUser(user, "LeaderLib_SharedData_StoreCustomStatData", payload)
			else
				Ext.BroadcastMessage("LeaderLib_SharedData_StoreCustomStatData", payload)
			end
		end
	end

	Ext.RegisterNetListener("LeaderLib_SyncCustomStatAvailablePoints", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data and data.NetID and data.Stats then
			local character = Ext.GetCharacter(data.NetID)
			if character then
				for id,amount in pairs(data.Stats) do
					self:SetAvailablePoints(character, id, amount, true)
				end
			end
		end
	end)
else
	---@private
	---Loads a table of stat UUIDs from the server.
	function CustomStatSystem:LoadSyncData(stats, availablePoints)
		if stats then
			if self:GMStatsEnabled() then
				for uuid,stats in pairs(stats) do
					local existing = self.Stats[uuid]
					if existing then
						for id,statId in pairs(stats) do
							if existing[id] then
								existing[id].UUID = statId
							end
						end
					end
				end
			else
				self:UpdateStatMovieClips()
			end
		end

		if availablePoints then
			self.PointsPool = availablePoints
			self:UpdateAvailablePoints()
		end
		for stat in self:GetAllStats(false,false,true) do
			for player in GameHelpers.Character.GetPlayers() do
				stat:UpdateLastValue(player)
			end
		end
		self.Syncing = false
	end

	local function LoadSyncedCustomStatData(cmd, payload)
		local data = Common.JsonParse(payload)
		if data ~= nil then
			if CustomStatSystem:GMStatsEnabled() then
				if data.CustomStats or data.AvailablePoints then
					self:LoadSyncData(data.CustomStats.Registered, data.AvailablePoints)
				end
				self.UnregisteredStats = {}
				
				for uuid,statData in pairs(data.CustomStats.Unregistered) do
					local stat = {
						ID = uuid,
						UUID = uuid,
						DisplayName = statData.DisplayName,
						Description = statData.Description,
						IsUnregistered = true,
						Double = false,
						LastValue = statData.LastValue
					}
					setmetatable(stat, Classes.UnregisteredCustomStatData)
					self.UnregisteredStats[uuid] = stat
	
					for player in GameHelpers.Character.GetPlayers() do
						stat:UpdateLastValue(player)
					end
				end
			else
				self:LoadSyncData(data.CustomStats, data.AvailablePoints)
			end
			return true
		else
			error("Error parsing json?", payload)
		end
	end

	Ext.RegisterNetListener("LeaderLib_SharedData_StoreCustomStatData", function(cmd, payload)
		local b,err = xpcall(LoadSyncedCustomStatData, debug.traceback, cmd, payload)
		if not b then
			Ext.PrintError(err)
		end
	end)

	Ext.RegisterNetListener("LeaderLib_SharedData_StoreAvailablePoints", function(cmd, payload)
		local availablePoints = Common.JsonParse(payload)
		if availablePoints then
			self:LoadSyncData(nil, availablePoints)
		end
	end)
end

Ext.RegisterNetListener("LeaderLib_CustomStatSystem_RemoveStatByUUID", function(cmd, payload)
	local data = Ext.JsonParse(payload)
	if data then
		if StringHelpers.IsNullOrEmpty(data.UUID) then
			return
		end
		for mod,stats in pairs(CustomStatSystem.Stats) do
			for id,stat in pairs(stats) do
				if stat.UUID == data.UUID then
					stats[id] = nil
				end
			end
		end
		CustomStatSystem.UnregisteredStats[data.UUID] = nil
		if not isClient then
			Ext.BroadcastMessage("LeaderLib_CustomStatSystem_RemoveStatByUUID", data.UUID, data.Client)
		end
	end
end)