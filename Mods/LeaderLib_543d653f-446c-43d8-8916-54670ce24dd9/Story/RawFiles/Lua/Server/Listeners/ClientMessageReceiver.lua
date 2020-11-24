
local MessageData = Classes["MessageData"]

local function LeaderLib_OnGlobalMessage(call, data)
	print(call, data)
end

--Ext.RegisterNetListener("LeaderLib_GlobalMessage", LeaderLib_OnGlobalMessage)

Ext.RegisterNetListener("LeaderLib_UI_StartControllerTooltipTimer", function(cmd, payload)
	local data = MessageData:CreateFromString(payload)
	if data ~= nil and data.Params.Client ~= nil then
		StartOneshotTimer(string.format("Timers_LL_TooltipPositioned_%s%s", data.Params.Client, data.Params.UIType), 2, function()
			Ext.PostMessageToClient(data.Params.Client, "LeaderLib_UI_OnControllerTooltipPositioned", tostring(data.Params.UIType))
		end)
	end
end)