local self = CustomStatSystem

function CustomStatSystem:SyncAvailablePoints()
	if Ext.IsServer() then
		self:SyncData()
	else
		local character = Client:GetCharacter()
		local data = {
			UUID = character.MyGuid,
			Stats = {}
		}
		for stat in self:GetAllStats() do
			if stat.AvailablePoints then
				local amount = stat.AvailablePoints[character.MyGuid]
				if amount then
					data.Stats[stat.ID] = amount
				end
				-- for uuid,amount in pairs(stat.AvailablePoints) do
				-- 	if not data[uuid] then
				-- 		data[uuid] = {}
				-- 	end
				-- 	data[uuid][stat.ID] = stat.AvailablePoints
				-- end
			end
		end
		Ext.PostMessageToServer("LeaderLib_SyncCustomStatAvailablePoints", Ext.JsonStringify(data))
	end
end

if Ext.IsServer() then
	--Creates a table of stat id to uuid, for sending stat UUIDs to the client
	function CustomStatSystem:GetSyncData()
		local data = {}
		for uuid,stats in pairs(self.Stats) do
			data[uuid] = {}
			for id,stat in pairs(stats) do
				if stat.UUID then
					data[uuid][id] = stat.UUID
				end
			end
		end
		return data
	end

	function CustomStatSystem:SyncData(user)
		local payload = Ext.JsonStringify({
			CustomStats = self:GetSyncData(),
			AvailablePoints = PersistentVars.CustomStatAvailablePoints
		})
		if user then
			Ext.PostMessageToUser(user, "LeaderLib_SharedData_StoreCustomStatData", payload)
		else
			Ext.BroadcastMessage("LeaderLib_SharedData_StoreCustomStatData", payload)
		end
	end

	Ext.RegisterNetListener("LeaderLib_SyncCustomStatAvailablePoints", function(cmd, payload)
		print(cmd,payload)
		local data = Common.JsonParse(payload)
		if data and data.UUID and data.Stats then
			local uuid = data.UUID
			for id,amount in pairs(data.Stats) do
				self:SetAvailablePoints(uuid, id, amount, true)
			end
		end
	end)
else
	--Loads a table of stat UUIDs from the server.
	function CustomStatSystem:LoadSyncData(uuidList, availablePoints)
		for uuid,stats in pairs(uuidList) do
			local existing = self.Stats[uuid]
			if existing then
				for id,statId in pairs(stats) do
					if existing[id] then
						existing[id].UUID = statId
					end
				end
			end
		end
		for uuid,stats in pairs(availablePoints) do
			for id,amount in pairs(stats) do
				local existing = self:GetStatByID(id)
				if existing then
					existing.AvailablePoints[uuid] = amount
				else
					Ext.PrintError("Failed to find custom stat data for id", id)
				end
			end
		end
		self:UpdateAvailablePoints()
	end

	local function LoadSyncedCustomStatData(cmd, payload)
		local data = Common.JsonParse(payload)
		if data ~= nil then
			if data.CustomStats then
				self:LoadSyncData(data.CustomStats, data.AvailablePoints)
			end
			return true
		else
			error("Error parsing json?", payload)
		end
	end

	Ext.RegisterNetListener("LeaderLib_SharedData_StoreCustomStatData", function(cmd, payload)
		print(cmd,payload)
		local b,err = xpcall(LoadSyncedCustomStatData, debug.traceback, cmd, payload)
		if not b then
			Ext.PrintError(err)
		end
	end)
end