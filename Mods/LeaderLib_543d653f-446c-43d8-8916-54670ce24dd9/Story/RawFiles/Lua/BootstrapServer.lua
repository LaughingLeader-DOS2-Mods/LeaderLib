PersistentVars = {}
PersistentVars.TimerData = {}
PersistentVars.StatusSource = {}

-- local function LeaderLib_GameSessionLoad()
-- 	PrintDebug("[LeaderLib:Bootstrap.lua] Session is loading.")
-- end

-- local genericPresetOverrideTest = "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/CharacterCreation/OriginPresets/LeaderLib_GenericOverrideTest.lsx"
-- local pathOverrides = {
-- 	["Mods/Shared/CharacterCreation/OriginPresets/Generic.lsx"] = genericPresetOverrideTest,
-- 	["Mods/Shared/CharacterCreation/OriginPresets/Generic2.lsx"] = genericPresetOverrideTest,
-- 	["Mods/Shared/CharacterCreation/OriginPresets/Generic3.lsx"] = genericPresetOverrideTest,
-- 	["Mods/Shared/CharacterCreation/OriginPresets/Generic4.lsx"] = genericPresetOverrideTest,
-- }

local function ModuleResume()
	--PrintDebug("[LeaderLib:Bootstrap.lua] Module is loading.")
	-- if Ext.IsDeveloperMode() then
	-- 	for file,override in pairs(pathOverrides) do
	-- 		Ext.AddPathOverride(file, override)
	-- 	end
	-- end
	if #Listeners.ModuleResume > 0 then
		for i,callback in pairs(Listeners.ModuleResume) do
			local status,err = xpcall(callback, debug.traceback)
			if not status then
				Ext.PrintError("Error calling function for 'ModuleResume':\n", err)
			end
		end
	end
end
Ext.RegisterListener("ModuleResume", ModuleResume)

local function SessionLoaded()
	if #Listeners.SessionLoaded > 0 then
		for i,callback in pairs(Listeners.SessionLoaded) do
			local status,err = xpcall(callback, debug.traceback)
			if not status then
				Ext.PrintError("Error calling function for 'SessionLoaded':\n", err)
			end
		end
	end
end
Ext.RegisterListener("SessionLoaded", SessionLoaded)

-- Ext.RegisterListener("SessionLoading", LeaderLib_GameSessionLoad)

Ext.Require("BootstrapShared.lua")
Ext.Require("Server/_InitServer.lua")