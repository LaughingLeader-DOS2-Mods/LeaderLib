Ext.RegisterConsoleCommand("luareset", function(cmd, delay)
	Ext.PostMessageToServer("LeaderLib_Client_RequestLuaReset", delay or "")
end)