
local MessageData = Classes["MessageData"]

local function LeaderLib_OnGlobalMessage(call, data)
	print(call, data)
end

--Ext.RegisterNetListener("LeaderLib_GlobalMessage", LeaderLib_OnGlobalMessage)