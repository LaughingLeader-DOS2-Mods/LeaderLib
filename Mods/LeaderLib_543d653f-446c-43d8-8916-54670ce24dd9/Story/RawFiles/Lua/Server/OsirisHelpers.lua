---@param object string
---@param event string
---@return integer
local function TurnSystem_GetRemainingTurns(object, event)
	-- DB_LeaderLib_Turns_ActiveTracker_Data(_ID, _Object, _x, _y, _z, _Type, _AnyTurns)
	local status,err = xpcall(function()
		local data = Osi.DB_LeaderLib_Turns_ActiveTracker_Data:Get(nil, object, nil, nil, nil, nil, nil)
		if data ~= nil then
			local id = data[1][1]
			-- DB_LeaderLib_Turns_ActiveTracker(_ID, _CompletionEvent, _Turns)
			local turnsData = Osi.DB_LeaderLib_Turns_ActiveTracker:Get(id, event, nil)
			if turnsData ~= nil then
				local turns = turnsData[1][3]
				if turns ~= nil then
					return turns
				end
			end
		end
		return 0
	end, debug.traceback())
	if not status then
		Ext.PrintError("[LeaderLib:OsirisHelpers.lua] (LeaderLib_Turns_QRY_GetRemainingTurns) error: ", err)
	else
		return err
	end

	return 0
end
Ext.NewQuery(TurnSystem_GetRemainingTurns, "LeaderLib_Turns_QRY_GetRemainingTurns", "[in](GUIDSTRING)_Object, [in](STRING)_CompletionEvent, [out](INTEGER)_Turns")