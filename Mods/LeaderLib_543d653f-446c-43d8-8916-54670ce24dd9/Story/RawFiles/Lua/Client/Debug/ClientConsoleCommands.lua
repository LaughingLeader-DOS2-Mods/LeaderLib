Ext.RegisterConsoleCommand("luareset", function(cmd, delay)
	Ext.PostMessageToServer("LeaderLib_Client_RequestLuaReset", delay or "")
end)

Input.RegisterListener("ToggleCraft", function(event, pressed)
	print("ToggleCraft", pressed, "ToggleInfo", Input.IsPressed("ToggleInfo"))
	if Input.IsPressed("ToggleInfo") then
		local this = Ext.GetUIByType(Data.UIType.characterSheet):GetRoot()
		Ext.Print("Toggling GM mode in character sheet: ", not this.isGameMasterChar)
		if this.isGameMasterChar then
			this.setGameMasterMode(false, false, false)
		else
			this.setGameMasterMode(true, true, false)
		end
	end
end)