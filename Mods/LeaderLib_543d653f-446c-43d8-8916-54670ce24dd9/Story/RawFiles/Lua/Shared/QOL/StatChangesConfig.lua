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

function StatChangesConfig:_Apply()
	local doSync = not _ISCLIENT and _validSyncStates[Ext.Server.GetGameState()]
	for id,attributes in pairs(self._Data) do
		if GameHelpers.Stats.Exists(id) then
			local stat = Ext.Stats.Get(id, nil, false)
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
		else
			fprint(LOGLEVEL.WARNING, "[LeaderLib:StatChangesConfig] Stat (%s) does not exist. Skipping.", id)
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