local global_flags = {
	"LeaderLib_DialogRedirectionEnabled",
	"LeaderLib_DialogRedirection_HighestPersuasionEnabled",
	"LeaderLib_DialogRedirection_DisableUserRestriction",
	"LeaderLib_AutoBalancePartyExperience",
	"LeaderLib_AutoAddModMenuBooksDisabled",
	"LeaderLib_FriendlyFireEnabled",
	"LeaderLib_AutosavingEnabled",
	"LeaderLib_AutosaveOnCombatStart",
	"LeaderLib_DisableAutosavingInCombat"
}

--[[ local global_settings_example = {
	GlobalFlags = {
		"LeaderLib_DialogRedirectionEnabled",
		"LeaderLib_DialogRedirection_HighestPersuasionEnabled",
		"LeaderLib_DialogRedirection_DisableUserRestriction",
		"LeaderLib_AutoBalancePartyExperience",
		"LeaderLib_AutoAddModMenuBooksDisabled",
		"LeaderLib_AutosavingEnabled",
		"LeaderLib_AutosaveOnCombatStart",
		"LeaderLib_DisableAutosavingInCombat",
	},
	AutosavingInterval = "LeaderLib_Autosave_Interval_15"
} ]]

local autosaving_interval = {
	"LeaderLib_Autosave_Interval_2",
	"LeaderLib_Autosave_Interval_5",
	"LeaderLib_Autosave_Interval_10",
	"LeaderLib_Autosave_Interval_15",
	"LeaderLib_Autosave_Interval_20",
	"LeaderLib_Autosave_Interval_25",
	"LeaderLib_Autosave_Interval_30",
	"LeaderLib_Autosave_Interval_35",
	"LeaderLib_Autosave_Interval_40",
	"LeaderLib_Autosave_Interval_45",
	"LeaderLib_Autosave_Interval_60",
	"LeaderLib_Autosave_Interval_90",
	"LeaderLib_Autosave_Interval_120",
	"LeaderLib_Autosave_Interval_180",
	"LeaderLib_Autosave_Interval_240",
}

local function parse_settings(tbl)
	for k,v in pairs(tbl) do
		if k == "GlobalFlags" then
			for _,flag in ipairs(k) do
				if type(flag) == "string" then
					GlobalSetFlag(flag)
				end
			end
		elseif k == "AutosavingInterval" then
			if type(v) == "string" then
				GlobalSetFlag(v)
				break
			end
		end
		if type(v) == "table" then
			parse_settings(v)
		end
	end

	for _,flag in ipairs(global_flags) do
		if LeaderLib.Common.TableHasEntry(tbl, flag) == false then
			GlobalClearFlag(flag)
		end
	end
end

local function LoadGlobalSettings()
	local json = NRD_LoadFile("LeaderLib_GlobalSettings.json")
	if json ~= nil and json ~= "" then
		local global_settings = Ext.JsonParse(json)
		Ext.Print("[LeaderLib:GlobalSettings.lua] Loaded global settings. {" .. LeaderLib.Common.Dump(global_settings) .. "}")
		parse_settings(global_settings)
	else
		Ext.Print("[LeaderLib:GlobalSettings.lua] No global settings found.")
	end
	return true
end

local function LoadGlobalSettings_Error (x)
	Ext.Print("[LeaderLib:GlobalSettings.lua] Error loading global settings: ", x)
	return false
end

local function LoadGlobalSettings_Run()
	if (xpcall(LoadGlobalSettings, LoadGlobalSettings_Error)) then
		Osi.LeaderLog_Log("DEBUG", "[LeaderLib:GlobalSettings.lua] Loaded global settings.")
	end
end

local function build_settings(tbl)
	for k,v in pairs(tbl) do
		if k == "GlobalFlags" then
			for _,flag in ipairs(global_flags) do
				local flag_set = GlobalGetFlag(flag)
				if flag_set == 1 then
					if LeaderLib.Common.TableHasEntry(v, flag) == false then
						v[#v+1] = flag
					end
				end
			end
			table.sort(v)
		end
		-- if type(v) == "table" then
		-- 	build_settings(v, tbl)
		-- end
	end
	if GlobalGetFlag("LeaderLib_AutosavingEnabled") == 1 then
		for _,interval_flag in ipairs(autosaving_interval) do
			local flag_set = GlobalGetFlag(interval_flag)
			if flag_set == 1 then
				tbl["Autosaving_Interval"] = interval_flag
				break
			end
		end
	end
end

local function SaveGlobalSettings()
	local LeaderLib_GlobalSettings = { GlobalFlags = {} }
	build_settings(LeaderLib_GlobalSettings)
	table.sort(LeaderLib_GlobalSettings)
	local json = Ext.JsonStringify(LeaderLib_GlobalSettings)
	NRD_SaveFile("LeaderLib_GlobalSettings.json", json)
	Ext.Print("[LeaderLib:GlobalSettings.lua] Saved global settings. {" .. json .. "}")
	return true
end

local function SaveGlobalSettings_Error (x)
	Ext.Print("[LeaderLib:GlobalSettings.lua] Error saving global settings: ", x)
	return false
end

local function SaveGlobalSettings_Run()
	if (xpcall(SaveGlobalSettings, SaveGlobalSettings_Error)) then
		Osi.LeaderLog_Log("DEBUG", "[LeaderLib:GlobalSettings.lua] Saved global settings.")
	end
end

LeaderLib.Settings = {
	LoadGlobalSettings = LoadGlobalSettings_Run,
	SaveGlobalSettings = SaveGlobalSettings_Run,
}

--Export local functions to global for now
for name,func in pairs(LeaderLib.Settings) do
    _G["LeaderLib_Ext_" .. name] = func
end