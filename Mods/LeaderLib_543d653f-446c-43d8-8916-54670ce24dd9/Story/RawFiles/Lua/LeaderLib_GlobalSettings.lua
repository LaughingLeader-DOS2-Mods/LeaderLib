local global_settings_base = {
	GlobalFlags = {
		"LeaderLib_DialogRedirectionEnabled",
		"LeaderLib_DialogRedirection_HighestPersuasionEnabled",
		"LeaderLib_DialogRedirection_DisableUserRestriction",
		"LeaderLib_AutoBalancePartyExperience",
		"LeaderLib_AutoAddModMenuBooksDisabled",
	},
	Autosaving = {
		GlobalFlags = {
			"LeaderLib_AutosavingEnabled",
			"LeaderLib_AutosaveOnCombatStart",
			"LeaderLib_DisableAutosavingInCombat",
		},
		Interval = "LeaderLib_Autosave_Interval_15"
	}
}

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
		elseif k == "Interval" then
			if type(v) == "string" then
				GlobalSetFlag(v)
				break
			end
		end
		if type(v) == "table" then
			parse_settings(v)
		end
	end
end

local function LoadGlobalSettings()
	local global_settings = Ext.JsonParse("LeaderLib_GlobalSettings")
	Ext.Print("[LeaderLib:GlobalSettings.lua] Loaded global settings. {" .. LeaderLib.Common.Dump(global_settings) .. "}")
	parse_settings(global_settings)
end

local function LoadGlobalSettings_Error (x)
	Ext.Print("[LeaderLib:GlobalSettings.lua] Error loading global settings: ", x)
	return false
end

local function LoadGlobalSettings_Run()
	Ext.Print("[LeaderLib:GlobalSettings.lua] Loading global settings.")
	xpcall(LoadGlobalSettings, LoadGlobalSettings_Error)
end

local function build_settings(tbl, target)
	for k,v in pairs(tbl) do
		if k == "GlobalFlags" then
			target["GlobalFlags"] = {}
			for _,flag in ipairs(k) do
				if type(flag) == "string" then
					local flag_set = GlobalGetFlag(flag)
					if flag_set == 1 then
						target[#target+1] = flag
					end
				end
			end
		elseif k == "Interval" then
			for _,interval_flag in autosaving_interval do
				local flag_set = GlobalGetFlag(interval_flag)
				if flag_set == 1 then
					v = interval_flag
					break
				end
			end
		end
		if type(v) == "table" then
			build_settings(v, target)
		end
	end
end

local function SaveGlobalSettings()
	local LeaderLib_GlobalSettings = {}
	build_settings(global_settings_base, LeaderLib_GlobalSettings)
	local json = Ext.JsonStringify(LeaderLib_GlobalSettings)
	Ext.Print("[LeaderLib:GlobalSettings.lua] Saved global settings. {" .. json .. "}")
end

local function SaveGlobalSettings_Error (x)
	Ext.Print("[LeaderLib:GlobalSettings.lua] Error saving global settings: ", x)
	return false
end

local function SaveGlobalSettings_Run()
	Ext.Print("[LeaderLib:GlobalSettings.lua] Saved global settings.")
	xpcall(SaveGlobalSettings, SaveGlobalSettings_Error)
end

LeaderLib.Settings = {
	LoadGlobalSettings = LoadGlobalSettings_Run,
	SaveGlobalSettings = SaveGlobalSettings_Run,
}

--Export local functions to global for now
for name,func in pairs(LeaderLib.Settings) do
    _G["LeaderLib_Ext_" .. name] = func
end