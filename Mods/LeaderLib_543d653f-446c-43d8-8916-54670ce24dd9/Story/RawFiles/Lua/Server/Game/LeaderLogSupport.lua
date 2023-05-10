local maxArity = 16

local function _OnLeaderLog(logType, ...)
	local str = StringHelpers.Join("", {...})
	Osi.LeaderLog_Internal_RunString(logType, str)
end

for i=1,maxArity do
	Ext.Osiris.RegisterListener("LeaderLog_Log", i, "before", _OnLeaderLog)
end