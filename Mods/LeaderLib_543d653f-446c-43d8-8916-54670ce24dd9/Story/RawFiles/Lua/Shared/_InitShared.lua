function PrintDebug(...)
	if Ext.IsDeveloperMode() then
		--local lineNum = debug.getinfo(1).currentline
		--local lineInfo = string.format("[%s:%s]", currentFileName(), debug.getinfo(1).currentline)
		print(...)
	end
end

Classes = {}
Common = {}
---@class GameHelpers
GameHelpers = {
	Item = {},
	Math = {},
	Skill = {},
	Status = {},
	Tooltip = {},
	UI = {},
	Ext = {},
}
Vars = {
	Initialized = false,
	PostLoadEnableLuaListeners = false,
	JustReset = false,
	LeaveActionData = {
		Prefixes = {},
		Statuses = {},
		Total = 0
	}
}

--- Adds a prefix to check statuses for when building Vars.LeaveActionData
---@param prefix string
function RegisterLeaveActionPrefix(prefix)
	table.insert(Vars.LeaveActionData.Prefixes, prefix)
end

Main = {}
ModRegistration = {}
Register = {}

---@type LeaderLibGameSettings
GameSettings = {Settings = {}}

---@class GlobalSettings
GlobalSettings = {
	---@type table<string, ModSettings>
	Mods = {},
	Version = Ext.GetModInfo("7e737d2f-31d2-4751-963f-be6ccc59cd0c").Version,
}

StatusTypes = {
	ACTIVE_DEFENSE = {},
	BLIND = {},
	CHARMED = { CHARMED = true },
	DAMAGE_ON_MOVE = {},
	DISARMED = {},
	INCAPACITATED = {},
	INVISIBLE = {},
	KNOCKED_DOWN = {},
	MUTED = {},
	POLYMORPHED = {},
}
IgnoredMods = {
	--["7e737d2f-31d2-4751-963f-be6ccc59cd0c"] = true,--LeaderLib
	["2bd9bdbe-22ae-4aa2-9c93-205880fc6564"] = true,--Shared
	["eedf7638-36ff-4f26-a50a-076b87d53ba0"] = true,--Shared_DOS
	["1301db3d-1f54-4e98-9be5-5094030916e4"] = true,--Divinity: Original Sin 2
	["a99afe76-e1b0-43a1-98c2-0fd1448c223b"] = true,--Arena
	["00550ab2-ac92-410c-8d94-742f7629de0e"] = true,--Game Master
	["015de505-6e7f-460c-844c-395de6c2ce34"] = true,--Nine Lives
	["38608c30-1658-4f6a-8adf-e826a5295808"] = true,--Herb Gardens
	["1273be96-6a1b-4da9-b377-249b98dc4b7e"] = true,--Source Meditation
	["af4b3f9c-c5cb-438d-91ae-08c5804c1983"] = true,--From the Ashes
	["ec27251d-acc0-4ab8-920e-dbc851e79bb4"] = true,--Endless Runner
	["b40e443e-badd-4727-82b3-f88a170c4db7"] = true,--Character_Creation_Pack
	["9b45f7e5-d4e2-4fc2-8ef7-3b8e90a5256c"] = true,--8 Action Points
	["f33ded5d-23ab-4f0c-b71e-1aff68eee2cd"] = true,--Hagglers
	["68a99fef-d125-4ed0-893f-bb6751e52c5e"] = true,--Crafter's Kit
	["ca32a698-d63e-4d20-92a7-dd83cba7bc56"] = true,--Divine Talents
	["f30953bb-10d3-4ba4-958c-0f38d4906195"] = true,--Combat Randomiser
	["423fae51-61e3-469a-9c1f-8ad3fd349f02"] = true,--Animal Empathy
	["2d42113c-681a-47b6-96a1-d90b3b1b07d3"] = true,--Fort Joy Magic Mirror
	["8fe1719c-ef8f-4cb7-84bd-5a474ff7b6c1"] = true,--Enhanced Spirit Vision
	["a945eefa-530c-4bca-a29c-a51450f8e181"] = true,--Sourcerous Sundries
	["f243c84f-9322-43ac-96b7-7504f990a8f0"] = true,--Improved Organisation
	["d2507d43-efce-48b8-ba5e-5dd136c715a7"] = true,--Pet Power
	["3da57b9d-8b41-46c7-a33c-afb31eea38a3"] = true,--Armor Sets
}
Listeners = {
	CharacterSheetPointChanged = {},
	CharacterBasePointsChanged = {},
	TimerFinished = {},
	FeatureEnabled = {},
	FeatureDisabled = {},
	Initialized = {},
	ModuleResume = {},
	SessionLoaded = {},
	OnPrepareHit = {},
	OnHit = {},
	OnSkillHit = {},
	LuaReset = {},
	ModSettingsLoaded = {},
	TurnDelayed = {},
	GetTooltipSkillDamage = {},
	GetTooltipSkillParam = {},
}

SkillListeners = {}
ModListeners = {
	Registered = {},
	Updated = {},
}

---@class LeaderLibLocalizedText A table of translated strings used by the game.
---@field DamageTypeHandles table<string, ColoredTranslatedStringEntry>
---@field DamageTypeNames table<string, ColoredTranslatedStringEntry>
---@field AbilityNames table<string, TranslatedString>
---@field AttributeNames table<string, TranslatedString>
---@field Slots table<string, TranslatedString>
---@field ItemBoosts table<string, TranslatedString>
---@field UI table<string, TranslatedString> Misc UI text like Confirm/Close.

---@type LeaderLibLocalizedText
LocalizedText = {}

---@type TranslatedString[]
TranslatedStringEntries = {}

---@type table<string,boolean>
Features = {
	BackstabCalculation = false,
	FixChaosDamageDisplay = false,
	FixCorrosiveMagicDamageDisplay = false,
	FixItemAPCost = true,
	HideArmor = 0,
	HideMagicArmor = 0,
	HideVitality = 0,
	RacialTalentsDisplayFix = true,
	ReduceTooltipSize = true,
	ReplaceTooltipPlaceholders = false,
	ResistancePenetration = false,
	StatusParamSkillDamage = false,
	TooltipGrammarHelper = false,
	WingsWorkaround = false,
}

if Ext.IsDeveloperMode() then
	-- Features.HideArmor = 2
	-- Features.HideMagicArmor = 2
	-- Features.HideVitality = 2
	Features.RacialTalentsDisplayFix = true
end

function LoadGameSettings(sync)
	local b,result = xpcall(function(settings)
		if settings == nil then
			settings = Classes.LeaderLibGameSettings:Create()
		end
		local tblString = Ext.LoadFile("LeaderLib_GameSettings.json")
		if tblString ~= nil then
			settings = settings:LoadString(tblString)
			return settings
		else
			Ext.PrintError("Failed to load LeaderLib_GameSettings.json. Does it exist?")
			return false
		end
	end, debug.traceback)
	if b and result ~= false then
		GameSettings = result
		if GameSettings.Settings ~= nil and GameSettings.Settings.Version ~= nil then
			if GameSettings.Settings.Version < GameSettings.Default.Version then
				GameSettings.Settings.Version = GameSettings.Default.Version
				SaveGameSettings()
			end
		end
	else
		if result == false then
			Ext.Print("[LeaderLib] Generating and saving LeaderLib_GameSettings.json")
		end
		--Ext.PrintError("[LeaderLib:LoadGameSettings]", result)
		GameSettings = Classes.LeaderLibGameSettings:Create()
		SaveGameSettings()
	end
	if GameSettings.Settings.BackstabSettings.Player.Enabled or GameSettings.Settings.BackstabSettings.NPC.Enabled then
		EnableFeature("BackstabCalculation")
	end
	if sync ~= nil and Ext.IsServer() and Ext.GetGameState() == "Running" then
		SyncGameSettings()
	end
	return GameSettings
end

function SaveGameSettings()
	if GameSettings ~= nil then
		pcall(function() 
			Ext.SaveFile("LeaderLib_GameSettings.json", GameSettings:ToString())
		end)
	end
end

function SyncGameSettings(id)
	if Ext.IsServer() then
		if id ~= nil then
			Ext.PostMessageToUser(id, "LeaderLib_SyncGameSettings", Classes.MessageData:CreateFromTable("LeaderLibGameSettings", {Settings = GameSettings}):ToString())
		else
			Ext.BroadcastMessage("LeaderLib_SyncGameSettings", Classes.MessageData:CreateFromTable("LeaderLibGameSettings", {Settings = GameSettings}):ToString(), nil)
		end
	end
end

if Ext.IsClient() then
	Ext.RegisterNetListener("LeaderLib_SyncGameSettings", function(call, gameSettingsStr)
		local settings = Classes.MessageData:CreateFromString(gameSettingsStr)
		GameSettings = settings.Params.Settings
		Ext.Print("[LeaderLib_SyncGameSettings] Synced game settings from server.")
	end)
end

--Ext.RegisterListener("ModuleLoadStarted", LoadSettings)

Ext.RegisterListener("ModuleLoadStarted", function()
	--- So we can initialize the settings file in the main menu.
	LoadGameSettings()
end)