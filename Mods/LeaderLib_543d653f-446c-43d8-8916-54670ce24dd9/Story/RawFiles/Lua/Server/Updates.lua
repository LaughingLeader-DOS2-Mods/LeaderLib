---@param lastVersion integer
---@param nextVersion integer
RegisterModListener("Loaded", ModuleUUID, function(lastVersion, nextVersion)
	if lastVersion < 386859008 then
		--Migrating Lua timer data
		for i,db in pairs(Osi.DB_LeaderLib_Helper_Temp_LuaTimer:Get(nil,nil)) do
			local timerName,uuid = table.unpack(db)
			Timer.StoreData(timerName, {uuid})
		end
		for i,db in pairs(Osi.DB_LeaderLib_Helper_Temp_LuaTimer:Get(nil,nil,nil)) do
			local timerName,uuid1,uuid2 = table.unpack(db)
			Timer.StoreData(timerName, {uuid1,uuid2})
		end
		Osi.DB_LeaderLib_Helper_Temp_LuaTimer:Delete(nil)
		Osi.DB_LeaderLib_Helper_Temp_LuaTimer:Delete(nil,nil)
		Osi.DB_LeaderLib_Helper_Temp_LuaTimer:Delete(nil,nil,nil)
	end
end)