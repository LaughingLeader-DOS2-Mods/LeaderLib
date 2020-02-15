local global_flags = {
	"LeaderLib_DialogRedirectionEnabled",
	"LeaderLib_DialogRedirection_HighestPersuasionEnabled",
	"LeaderLib_DialogRedirection_DisableUserRestriction",
	--"LeaderLib_AutoBalancePartyExperience",
	"LeaderLib_AutoAddModMenuBooksDisabled",
	"LeaderLib_FriendlyFireEnabled",
	"LeaderLib_AutosavingEnabled",
	"LeaderLib_AutosaveOnCombatStart",
	"LeaderLib_DisableAutosavingInCombat",
	"LeaderLog_Debug_Enabled",
	"LeaderLog_CombatLog_Disabled",
	"LeaderLog_Status_Disabled",
	"LeaderLib_DebugMode"
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

local global_settings = {}

---@class LeaderLibIntegerVariable
local LeaderLibIntegerVariable = { 
	name = "",
	value = 0,
	defaultValue = 0
}

LeaderLibIntegerVariable.__index = LeaderLibIntegerVariable

function LeaderLibIntegerVariable:Create(name,defaultValue)
    local this =
    {
		name = name,
		defaultValue = defaultValue
	}
	setmetatable(this, self)
    return this
end

---@class LeaderLibFlagVariable
local LeaderLibFlagVariable = {
	name = "",
	saveWhenFalse = false
}

LeaderLibFlagVariable.__index = LeaderLibFlagVariable

function LeaderLibFlagVariable:Create(name)
    local this =
    {
		name = name
	}
	setmetatable(this, self)
    return this
end

---@class LeaderLibModSettings
local LeaderLibModSettings = {
	name = "Mod", 
	author = "Author",
	globalflags = {},
	integers = {},
	version = "0.0.0.0",
	uuid = ""
}

LeaderLibModSettings.__index = LeaderLibModSettings

function LeaderLibModSettings:Create(name,author)
    local this =
    {
		name = name,
		author = author,
		globalflags = {},
		integers = {},
		uuid = ""
	}
	setmetatable(this, self)
    return this
end

local function do_addflags(tbl, x)
	if type(x) == "string" then
		tbl[x] = LeaderLibFlagVariable:Create(x)
	elseif type(x) == "table" then
		for _,y in ipairs(x) do
			do_addflags(tbl, y)
		end
	end
end

function LeaderLibModSettings:AddFlags(...)
	local flags = {...}
	local target = self.globalflags
	for _,f in ipairs(flags) do
		do_addflags(target, f)
	end
	self.globalflags = target
	--Ext.Print("Test: " .. LeaderLib.Common.Dump(self))
end

function LeaderLibModSettings:Export()
	Ext.Print("Exporting: " .. LeaderLib.Common.Dump(self))
	local export_table = LeaderLibModSettings:Create(self.name, self.author)
	export_table.uuid = self.uuid
	export_table.version = self.version
	--export_table.globalflags = {}
	table.sort(self.globalflags)
	for flag,v in pairs(self.globalflags) do
		if GlobalGetFlag(flag) == 1 then
			export_table.globalflags[flag] = true
		elseif v.saveWhenFalse == true then
			export_table.globalflags[flag] = false
		end
		--Ext.Print("Flag: " .. flag .. " | " .. GlobalGetFlag(flag))
	end
	local last_pricemod = GetGlobalPriceModifier()
	for name,v in pairs(self.integers) do
		SetGlobalPriceModifier(123456)
		if self.uuid ~= nil and self.uuid ~= "" then
			Osi.LeaderLib_GlobalSettings_Internal_GetIntegerVariable(self.uuid, name)
		else
			Osi.LeaderLib_GlobalSettings_Internal_GetIntegerVariable_Old(self.name, self.author, name)
		end
		local int_value = GetGlobalPriceModifier()
		if int_value ~= 123456 then
			export_table.integers[name] = int_value
			--GlobalClearFlag("LeaderLib_Internal_GlobalSettings_IntegerVarSet")
		end
		--Ext.Print("Got int var ("..name..") Value ("..int_value..")")
	end
	SetGlobalPriceModifier(last_pricemod)
	Ext.Print("GlobalPriceModifier reverted back to ("..GetGlobalPriceModifier()..")")
	return export_table
end

---@class LeaderLibGlobalSettings
local LeaderLibGlobalSettings = { 
	mods = {}
}

LeaderLibGlobalSettings.__index = LeaderLibGlobalSettings

function LeaderLibGlobalSettings:Create()
    local this =
    {
		mods = {}
	}
	
	for _,v in ipairs(global_settings) do
		local export = v:Export()
		this.mods[#this.mods+1] = export
	end
	
	table.sort(this.mods, function(a,b)
		if a.name ~= nil and b.name ~= nil then
			return string.upper(a.name) < string.upper(b.name)
		else
			return false
		end
	end)
	
	setmetatable(this, self)
    return this
end

---Fetches stored settings, or returns a new settings table.
---@param uuid string
---@param name string
---@param author string
---@return LeaderLibModSettings
local function Get_Settings(uuid, name, author)
	if #global_settings > 0 then
		for _,v in pairs(global_settings) do
			if (v.uuid == uuid) or (LeaderLib.Common.StringEquals(v.name == name) and LeaderLib.Common.StringEquals(v.author, author)) then
				return v
			end
		end
	end
	local new_settings = LeaderLibModSettings:Create(name, author)
	new_settings.uuid = uuid
	global_settings[#global_settings+1] = new_settings
	return new_settings
end

---Fetches stored settings, or returns a new settings table.
---@param modid string
---@param author string
---@return LeaderLibModSettings
local function Get_Settings_Old(modid, author)
	if #global_settings > 0 then
		for _,v in pairs(global_settings) do
			if v.name ~= nil and v.author ~= nil and author ~= nil and modid ~= nil then
				if LeaderLib.Common.StringEquals(v.name, modid) and LeaderLib.Common.StringEquals(v.author, author) then
					return v
				end
			end
		end
	end
	local new_settings = LeaderLibModSettings:Create(modid, author)
	global_settings[#global_settings+1] = new_settings
	return new_settings
end

---@param uuid string
---@param name string
---@param author string
---@param flag string
local function GlobalSettings_StoreGlobalFlag(uuid, name, author, flag, saveWhenFalse)
	local mod_settings = Get_Settings(uuid, name, author)
	if flag ~= nil then
		local flagvar = LeaderLibFlagVariable:Create(flag)
		if saveWhenFalse == "1" then flagvar.saveWhenFalse = true end
		mod_settings.globalflags[flag] = flagvar
	end
end

---@param modid string
---@param author string
---@param flag string
local function GlobalSettings_StoreGlobalFlag_Old(modid, author, flag, saveWhenFalse)
	local mod_settings = Get_Settings_Old(modid, author)
	if flag ~= nil then
		local flagvar = LeaderLibFlagVariable:Create(flag)
		if saveWhenFalse == "1" then flagvar.saveWhenFalse = true end
		mod_settings.globalflags[flag] = flagvar
	end
end

---@param uuid string
---@param name string
---@param author string
---@param varname string
---@param defaultvalue string
local function GlobalSettings_StoreGlobalInteger(uuid, name, author, varname, defaultvalue)
	Ext.Print("[LeaderLib:GlobalSettings.lua] Storing int: ", uuid, name, author, varname, defaultvalue)
	local mod_settings = Get_Settings(uuid, name, author)
	mod_settings.integers[varname] = tonumber(defaultvalue)
end

---@param modid string
---@param author string
---@param varname string
---@param defaultvalue string
local function GlobalSettings_StoreGlobalInteger_Old(modid, author, varname, defaultvalue)
	Ext.Print("[LeaderLib:GlobalSettings.lua] Storing int: ", modid, author, varname, defaultvalue)
	local mod_settings = Get_Settings_Old(modid, author)
	mod_settings.integers[varname] = tonumber(defaultvalue)
end

---@param modid string
---@param author string
---@param version string
local function GlobalSettings_StoreModVersion(modid, author, version)
	local mod_settings = Get_Settings(modid, author)
	mod_settings.version = version
end

---@param modid string
---@param author string
---@param version string
local function GlobalSettings_StoreModVersion_New(uuid, modid, author, version)
	local versionInt = tonumber(version)
	local major = math.floor(versionInt >> 28)
	local minor = math.floor(versionInt >> 24) & 0x0F
	local revision = math.floor(versionInt >> 16) & 0xFF
	local build = math.floor(versionInt & 0xFFFF)
	local versionString = tostring(major).."."..tostring(minor).."."..tostring(revision).."."..tostring(build)
	local mod_settings = Get_Settings(modid, author)
	mod_settings.uuid = uuid
	mod_settings.version = version
end

local function parse_mod_data(uuid, modid, author, tbl)
	local flags = tbl["globalflags"]
	if flags ~= nil and type(flags) == "table" then
		for flag,v in pairs(flags) do
			Ext.Print("[LeaderLib:GlobalSettings.lua] Found global flag ("..flag..")["..tostring(v).."] for mod ["..uuid.."](".. modid.."|"..author..")")
			if v == false then
				GlobalClearFlag(flag)
			else
				GlobalSetFlag(flag)
			end
			if LeaderLib.Common.StringIsNullOrEmpty(uuid) == false then
				GlobalSettings_StoreGlobalFlag(uuid, flag, 0)
			else
				GlobalSettings_StoreGlobalFlag(modid, author, flag, 0)
			end
		end
	end
	local integers = tbl["integers"]
	if integers ~= nil and type(integers) == "table" then
		for varname,v in pairs(integers) do
			local num = 0
			if type(v) == "number" then
				num = v
			elseif type(v) == "string" then
				num = tonumber(v)
			end
			num = math.floor(num)
			Ext.Print("[LeaderLib:GlobalSettings.lua] Found global integer variable ("..varname..")["..tostring(num).."] for mod (".. modid.."|"..author..")")
			if LeaderLib.Common.StringIsNullOrEmpty(uuid) == false then
				Osi.LeaderLib_GlobalSettings_SetIntegerVariable(uuid, varname, num)
				GlobalSettings_StoreGlobalInteger(uuid, 0)
			else
				Osi.LeaderLib_GlobalSettings_SetIntegerVariable(modid, author, varname, num)
				GlobalSettings_StoreGlobalInteger(modid, author, varname, 0)
			end
		end
	end
	return true
end

local function parse_settings(tbl)
	for k,v in pairs(tbl) do
		if LeaderLib.Common.StringEquals(k, "mods") then
			for k2,v2 in pairs(v) do
				local modid = v2["name"]
				local author = v2["author"]
				local uuid = v2["uuid"]
				local canParse = LeaderLib.Common.StringIsNullOrEmpty(uuid) == false or (LeaderLib.Common.StringIsNullOrEmpty(modid) == false and LeaderLib.Common.StringIsNullOrEmpty(author) == false)
				if canParse then
					xpcall(parse_mod_data, function(err)
						Ext.Print("[LeaderLib:GlobalSettings.lua] Error parsing mod data in global settings: ", err)
						Ext.Print(debug.traceback())
						return false
					end, uuid, modid, author, v2)
				end
			end
		end
	end
end

local function LoadGlobalSettings()
	local json = NRD_LoadFile("LeaderLib_GlobalSettings.json")
	if json ~= nil and json ~= "" then
		local json_tbl = Ext.JsonParse(json)
		--Ext.Print("[LeaderLib:GlobalSettings.lua] Loaded global settings. {" .. LeaderLib.Common.Dump(json_tbl) .. "}")
		Ext.Print("[LeaderLib:GlobalSettings.lua] Loaded global settings.")
		parse_settings(json_tbl)
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

local function SaveGlobalSettings()
	local export_settings = LeaderLibGlobalSettings:Create()
	--Ext.Print(LeaderLib.Common.Dump(export_settings))
	local mods = export_settings.mods
	if #mods > 0 then
		local json = Ext.JsonStringify(export_settings)
		NRD_SaveFile("LeaderLib_GlobalSettings.json", json)
		Ext.Print("[LeaderLib:GlobalSettings.lua] Saved global settings. {" .. json .. "}")
	else
		Ext.Print("[LeaderLib:GlobalSettings.lua] No global settings to save. Skipping.")
	end
	return true
end

local function SaveGlobalSettings_Error (x)
	Ext.Print("[LeaderLib:GlobalSettings.lua] Error saving global settings: ", x)
	Ext.Print(debug.traceback())
	return false
end

local function SaveGlobalSettings_Run()
	if (xpcall(SaveGlobalSettings, SaveGlobalSettings_Error)) then
		Osi.LeaderLog_Log("DEBUG", "[LeaderLib:GlobalSettings.lua] Saved global settings.")
	end
end

local function GlobalSettings_Initialize()
	Osi.LeaderLib_GlobalSettings_Internal_Init()
	--local LeaderLib_Settings = Get_Settings("LeaderLib", "LaughingLeader")
	--LeaderLib_Settings:AddFlags(global_flags)
	--LeaderLib_Settings:AddFlags(autosaving_interval)
	--Ext.Print(LeaderLib.Common.Dump(LeaderLib_Settings))
end

LeaderLib.Settings = {
	LoadGlobalSettings = LoadGlobalSettings_Run,
	SaveGlobalSettings = SaveGlobalSettings_Run,
	GlobalSettings_StoreGlobalFlag = GlobalSettings_StoreGlobalFlag,
	GlobalSettings_StoreGlobalInteger = GlobalSettings_StoreGlobalInteger,
	GlobalSettings_StoreModVersion = GlobalSettings_StoreModVersion,
	GlobalSettings_StoreModVersion_New = GlobalSettings_StoreModVersion_New,
	GlobalSettings_Initialize = GlobalSettings_Initialize,
}

--Export local functions to global for now
for name,func in pairs(LeaderLib.Settings) do
    _G["LeaderLib_Ext_" .. name] = func
end