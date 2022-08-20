---@class LeaderLibGameSettings
local DefaultSettings = {
	StarterTierSkillOverrides = false,
	LowerMemorizationRequirements = false,
	SpellsCanCritWithoutTalent = false,
	APSettings = {
		Player = {
			Enabled = false,
			Max = 8,
			Start = -1,
			Recovery = -1,
		},
		NPC = {
			Enabled = false,
			Max = 8,
			Start = -1,
			Recovery = -1,
		}
	},
	BackstabSettings = {
		AllowTwoHandedWeapons = false,
		MeleeSpellBackstabMaxDistance = 2.5,
		Player = {
			Enabled = false,
			TalentRequired = false,
			MeleeOnly = true,
			SpellsCanBackstab = false,
		},
		NPC = {
			Enabled = false,
			TalentRequired = false,
			MeleeOnly = true,
			SpellsCanBackstab = false,
		},
	},
	SurfaceSettings = {
		PoisonDoesNotIgnite = false,
	},
	SkipTutorial = {
		Enabled = false,
		Destination = "FJ_FortJoy_Main",
		AddRecipes = false,
		StartingCharacterLevel = {
			Enabled = true,
			FJ_FortJoy_Main = 2,
			LV_HoE_Main = 8,
			RC_Main = 8,
			CoS_Main = 16,
			ARX_Main = 18
		},
		StartingGold = {
			Enabled = true,
			FJ_FortJoy_Main = 200,
			LV_HoE_Main = 2000,
			RC_Main = 2000,
			CoS_Main = 4000,
			ARX_Main = 10000
		}
	},
	Client = {
		AlwaysDisplayWeaponScalingText = true,
		AlwaysExpandTooltips = false,
		AlwaysShowBarText = false,
		CondenseItemTooltips = false,
		CondenseStatusTooltips = false,
		DivineTalentsEnabled = false,
		FixStatusTooltips = true,
		HideChatLog = false,
		HideConsumableEffects = false,
		HideStatusSource = false,
		KeepTooltipInScreen = true,
		ShowModInTooltips = true,
		ToggleCombatLog = false,
		EnableTooltipDelay = {
			GlobalDelay = 0,
			CharacterSheet = false,
			Generic = false,
			Item = false,
			Skill = false,
			Status = false,
		},
		FadeInventoryItems = {
			Enabled = false,
			KnownSkillbooks = 30,
			ReadBooks = 30
		},
		StatusOptions = {
			HideAll = false,
			---A list of statuses to hide if HideAll is false.
			---@type table<string,boolean>
			Blacklist = {},
			---A list of statuses to show if HideAll is true.
			---@type table<string,boolean>
			Whitelist = {},
			AffectHealthbar = false,
		},
	},
	EnableDeveloperTests = false,
	Version = Ext.GetModInfo(ModuleUUID).Version
}

local _ISCLIENT = Ext.IsClient()

local function cloneTable(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

---@class LeaderLibGameSettingsWrapper
local LeaderLibGameSettings = {
	---@type LeaderLibGameSettings
	Settings = cloneTable(DefaultSettings),
	Default = cloneTable(DefaultSettings),
	Loaded = false
}
LeaderLibGameSettings.__index = LeaderLibGameSettings

---Seralizes GameSettings to string, which only includes the Settings table.
---@param forSync boolean|nil
---@return string
function LeaderLibGameSettings:ToString(forSync)
	local settings = TableHelpers.Clone(self.Settings)
	if forSync then 
		settings.Client = nil
	end
    return Common.JsonStringify({Settings=settings})
end

---@return LeaderLibGameSettingsWrapper
function LeaderLibGameSettings:Create()
    local this =
    {
		Settings = DefaultSettings
	}
	setmetatable(this, self)
    return this
end

---@param tbl table
function LeaderLibGameSettings:MigrateSettings(tbl)
	if tbl.MaxAP ~= nil then
		if tbl.MaxAPGroup == "Player" or tbl.MaxAPGroup == "All" then
			self.Settings.APSettings.Player.Max = tbl.MaxAP
		end
		if tbl.MaxAPGroup == "NPC" or tbl.MaxAPGroup == "All" then
			self.Settings.APSettings.NPC.Max = tbl.MaxAP
		end
	end
	if tbl.MaxAPGroup ~= nil then
		if tbl.MaxAPGroup == "All" then
			self.Settings.APSettings.Player.Enabled = true
			self.Settings.APSettings.NPC.Enabled = true
		elseif tbl.MaxAPGroup == "Player" then
			self.Settings.APSettings.Player.Enabled = true
		elseif tbl.MaxAPGroup == "NPC" then
			self.Settings.APSettings.NPC.Enabled = true
		end
	end
	if tbl.Client and tbl.Client.HideStatuses == true then
		self.Settings.Client.StatusOptions.HideAll = true
	end
end

local function ParseTableValue(settings, k, v)
	if type(v) == "table" then
		if settings[k] == nil then
			settings[k] = v
		else
			for k2,v2 in pairs(v) do
				ParseTableValue(settings[k], k2, v2)
			end
		end
	else
		settings[k] = v
	end
end

---@param tbl table
---@return boolean
function LeaderLibGameSettings:LoadTable(tbl)
	local b,result = xpcall(function()
		if tbl ~= nil then
			if tbl.Settings ~= nil and type(tbl.Settings) == "table" then
				pcall(self.MigrateSettings, self, tbl)
				for k,v in pairs(tbl.Settings) do
					ParseTableValue(self.Settings, k, v)
				end
			elseif tbl.Version == nil then
				for k,v in pairs(tbl) do
					ParseTableValue(self.Settings, k, v)
				end
			end
		end
		return true
	end, function(err)
		Ext.Utils.PrintError("[LeaderLibGameSettings:LoadTable] Error parsing table:\n" .. tostring(err))
	end, self, tbl)
	if b then
		self:Apply()
		return result
	end
	return false
end

---Converts a string to a table and applies its properties.
---@param str string
---@param skipApply boolean|nil
---@return boolean
function LeaderLibGameSettings:LoadString(str, skipApply)
	local b,result = xpcall(function()
		local tbl = Common.JsonParse(str)
		if tbl ~= nil then
			if tbl.Settings ~= nil and type(tbl.Settings) == "table" then
				for k,v in pairs(tbl.Settings) do
					ParseTableValue(self.Settings, k, v)
				end
			end
		end
		if tbl.Version ~= nil then
			self.Settings.Version = tbl.Verion
		end
		return true
	end, debug.traceback)
	if b then
		if not skipApply then
			self:Apply()
		end
		return result
	else
		Ext.Utils.PrintError("[LeaderLibGameSettings:CreateFromString] Error parsing string as table:\n" .. tostring(result))
	end
	return false
end

function LeaderLibGameSettings:ApplyAPChanges()
	local settings = self.Settings.APSettings.Player

	if Ext.GetGameState() == "Running" or SharedData.RegionData.Current ~= "" then
		for player in GameHelpers.Character.GetPlayers() do
			local stats = {}
			local baseStat = Ext.Stats.Get(player.Stats.Name)
			if settings.Enabled then
				if settings.Start > 0 then
					stats.APStart = settings.Start
				else
					stats.APStart = baseStat.APStart
				end
				if settings.Max > 0 then
					stats.APMaximum = settings.Max
				else
					stats.APMaximum = baseStat.APMaximum
				end
				if settings.Recovery > 0 then
					stats.APRecovery = settings.Recovery
				else
					stats.APRecovery = baseStat.APRecovery
				end
			else
				stats.APStart = baseStat.APStart
				stats.APMaximum = baseStat.APMaximum
				stats.APRecovery = baseStat.APRecovery
			end
			player.Stats.DynamicStats[1].APMaximum = stats.APMaximum
			player.Stats.DynamicStats[1].APRecovery = stats.APRecovery
			player.Stats.DynamicStats[1].APStart = stats.APStart
			baseStat.APStart = stats.APStart
			baseStat.APMaximum = stats.APMaximum
			baseStat.APRecovery = stats.APRecovery
			if not _ISCLIENT then
				Ext.Stats.Sync(baseStat.Name, false)
			end
		end
	end
end

function LeaderLibGameSettings:ApplyClient()
	if _ISCLIENT then
		StatusHider.RefreshStatusVisibility()
		if Mods.CharacterExpansionLib then
			Mods.CharacterExpansionLib.SheetManager.Talents.ToggleDivineTalents(self.Settings.Client.DivineTalentsEnabled)
		end
	end
end

function LeaderLibGameSettings:Apply()
	if self.Settings.BackstabSettings.Player.Enabled or self.Settings.BackstabSettings.NPC.Enabled then
		EnableFeature("BackstabCalculation")
	end
	self:ApplyClient()
	self:ApplyAPChanges()
end

Classes.LeaderLibGameSettings = LeaderLibGameSettings
GameSettings = LeaderLibGameSettings:Create()

Ext.RegisterNetListener("LeaderLib_SyncGameSettings", function(cmd, payload)
	--fprint(LOGLEVEL.TRACE, "[LeaderLib_SyncGameSettings:%s] Loading settings.", _ISCLIENT and "CLIENT" or "SERVER")
	if _ISCLIENT then
		if not GameSettings.Loaded then
			--Load client settings initially
			GameSettingsManager.LoadClientSettings()
		end
		local clientSettings = {}
		if GameSettings and GameSettings.Settings and GameSettings.Settings.Client then
			clientSettings = TableHelpers.Clone(GameSettings.Settings.Client)
		end
		GameSettings:LoadString(payload, true)
		TableHelpers.AddOrUpdate(GameSettings.Settings.Client, clientSettings, false, true)
	else
		GameSettings:LoadString(payload)
	end

	GameSettingsManager.Apply(false)

	Events.GameSettingsChanged:Invoke({Settings = GameSettings.Settings, FromSync=true})
end)