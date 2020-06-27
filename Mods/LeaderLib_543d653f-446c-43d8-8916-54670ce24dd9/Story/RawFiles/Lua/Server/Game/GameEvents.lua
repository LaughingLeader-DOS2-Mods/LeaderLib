function OnInitialized()
	if #Listeners.Initialized > 0 then
		for i,callback in ipairs(Listeners.Initialized) do
			local status,err = xpcall(callback, debug.traceback)
			if not status then
				Ext.PrintError("[LeaderLib:OnInitialized] Error calling function for 'Initialized':\n", err)
			end
		end
	end
end