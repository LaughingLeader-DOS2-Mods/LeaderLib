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

-- Timer.RegisterListener("TestTimer", function(...) print(Lib.inspect({...})) end)
-- Timer.Start("TestTimer", 1500, "Test1", false, 49, "Hello")
--Mods.LeaderLib.Timer.RegisterListener("TestTimer", function(...) print("TimerFinished", Mods.LeaderLib.Lib.inspect({...})) end)
--Mods.LeaderLib.Timer.Start("TestTimer", 1500, "Test1", false, 49, "Hello", Ext.GetCharacter(host.MyGuid), function() print('test') end)
--Mods.LeaderLib.Timer.Start("TestTimer", 1500, "Test1", false, 49, "Hello", Ext.GetCharacter(host.MyGuid), function() print('test') end)

--Mods.LeaderLib.Timer.StartObjectTimer("TestTimer", host.MyGuid, 1500, {UUID = host.MyGuid, Success=true, ID = "Yoyoyo", Damage=54, [10]="Yes"}); Mods.LeaderLib.Timer.StartObjectTimer("TestTimer", "bbca13e7-5ea3-4da2-82bd-8a0a3d23c979", 5000, {UUID = "bbca13e7-5ea3-4da2-82bd-8a0a3d23c979", Success=false, ID = "Idk", Damage=98})

--Timer.StartObjectTimer("TestTimer", "bbca13e7-5ea3-4da2-82bd-8a0a3d23c979", 5000, {UUID = "bbca13e7-5ea3-4da2-82bd-8a0a3d23c979", Success=false, ID = "Idk", Damage=98})

-- Timer.RegisterListener("TestTimer", function(timerName, data, ...)
-- 	fprint("TestTimer(%s)", Ext.MonotonicTime())
-- 	print(Lib.inspect(data), ...)
-- end)