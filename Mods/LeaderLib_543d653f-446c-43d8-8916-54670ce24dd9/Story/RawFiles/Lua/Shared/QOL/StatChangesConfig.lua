local _ISCLIENT = Ext.IsClient()

---@class LeaderLibStatChangesConfig
local StatChangesConfig = {
	_PATH = "LeaderLib_StatChanges.json",
	_Data = {}
}

local function _TrySetStat(stat, k, v)
	stat[k] = v
end

local _validSyncStates = {
	Running = true,
	Paused = true,
	GameMasterPause = true,
}

local function _ParseSpecialKey(id, tbl)
	if id == "Data" or id == "ExtraData" then
		local extraData = Ext.ExtraData
		for k,v in pairs(tbl) do
			if extraData[k] then
				local t1 = type(v)
				local t2 = type(extraData[k])
				if t1 ~= t2 then
					fprint(LOGLEVEL.WARNING, "[LeaderLib:StatChangesConfig] Data key (%s) type (%s) does not equal the type in LeaderLib_StatChanges (%s). This may lead to issues.", k, t1, t2)
					if t2 == "string" then
						local x = tonumber(v)
						if x then
							extraData[k] = x
						end
					end
				else
					extraData[k] = v
				end
			else
				extraData[k] = v
			end
		end
		return true
	elseif id == "TreasureTable" then
		if not _ISCLIENT then
			for tableID,attributes in pairs(tbl) do
				local tt = Ext.Stats.TreasureTable.GetLegacy(tableID)
				if tt then
					TableHelpers.AddOrUpdate(tt, attributes, false, true)
					Ext.Stats.TreasureTable.Update(tt)
				end
			end
		end
		return true
	end
	return false
end

function StatChangesConfig:_Apply()
	local doSync = not _ISCLIENT and _validSyncStates[Ext.Server.GetGameState()]
	for id,attributes in pairs(self._Data) do
		if not _ParseSpecialKey(id, attributes) then
			if GameHelpers.Stats.Exists(id) then
				local stat = Ext.Stats.Get(id, nil, false)
				if stat then
					fprint(LOGLEVEL.TRACE, "[LeaderLib:StatChangesConfig] Modifying stat (%s):", id)
					for k,v in pairs(attributes) do
						fprint(LOGLEVEL.TRACE, "  [%s] = %s", k, Lib.serpent.line(v, {comment=false}))
						local b,err = xpcall(_TrySetStat, debug.traceback, stat, k, v)
						if not b then
							fprint(LOGLEVEL.ERROR, "[LeaderLib:StatChangesConfig] Error setting attribute (%s) for stat (%s)':\n%s", k, id, err)
						end
					end
					if doSync then
						Ext.Stats.Sync(id, false)
					end
				end
			else
				fprint(LOGLEVEL.WARNING, "[LeaderLib:StatChangesConfig] Stat (%s) does not exist. Skipping.", id)
			end
		end
	end
end

function StatChangesConfig:_Load()
	local fileData,loaded = GameHelpers.IO.LoadJsonFile(self._PATH)
	if loaded then
		self._Data = fileData
		return true
	else
		self._Data = {}
		GameHelpers.IO.SaveFile(self._PATH, "{\n\t\n}")
	end
	return false
end

---load and apply stat changes from the config file. Calls _Load() and _Apply()
function StatChangesConfig:Run()
	if self:_Load() then
		self:_Apply()
	end
end

Ext.RegisterNetListener("LeaderLib_StatChangesConfig_Run", function (channel, payload, user)
	StatChangesConfig:Run()
end)

QOL.StatChangesConfig = StatChangesConfig

Ext.Events.StatsLoaded:Subscribe(function (e)
	--Run here so other mods will be able to adapt to the changes
	QOL.StatChangesConfig:Run()
end, {Priority=9999})