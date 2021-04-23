---@class LeaderLibDefaultSettings
local DefaultSettings = {
	StarterTierSkillOverrides = false,
	LowerMemorizationRequirements = false,
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
			TalentRequired = true,
			MeleeOnly = true,
			SpellsCanBackstab = false,
		},
		NPC = {
			Enabled = true,
			TalentRequired = true,
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
			Arx_Main = 18
		},
		StartingGold = {
			Enabled = true,
			FJ_FortJoy_Main = 200,
			LV_HoE_Main = 2000,
			RC_Main = 2000,
			CoS_Main = 4000,
			Arx_Main = 10000
		}
	},
	Client = {
		HideStatuses = false,
		AlwaysDisplayWeaponScalingText = true,
		DivineTalentsEnabled = false,
	},
	EnableDeveloperTests = false,
	Version = Ext.GetModInfo("7e737d2f-31d2-4751-963f-be6ccc59cd0c").Version
}

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

---@class LeaderLibGameSettings
local LeaderLibGameSettings = {
	---@type LeaderLibDefaultSettings
	Settings = cloneTable(DefaultSettings),
	Default = cloneTable(DefaultSettings),
	Loaded = false
}
LeaderLibGameSettings.__index = LeaderLibGameSettings

---Seralizes GameSettings to string, which only includes the Settings table.
---@return string
function LeaderLibGameSettings:ToString()
	local copy = {
		Settings = self.Settings
	}
    return Ext.JsonStringify(copy)
end

function LeaderLibGameSettings:__tostring()
    return self:ToString()
end

---@return LeaderLibGameSettings
function LeaderLibGameSettings:Create()
    local this =
    {
		Settings = DefaultSettings
	}
	setmetatable(this, self)
    return this
end

---@param tbl LeaderLibDefaultSettings
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
end

local function ParseTableValue(settings, k, v)
	if type(v) == "table" then
		if settings[k] == nil then
			settings[k] = v
			--PrintDebug("[LeaderLibGameSettings] Set null ",k," to table")
		else
			for k2,v2 in pairs(v) do
				ParseTableValue(settings[k], k2, v2)
			end
		end
	else
		settings[k] = v
		--PrintDebug("[LeaderLibGameSettings] Set ",k," to ",v)
	end
end

---@param source table
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
		Ext.PrintError("[LeaderLibGameSettings:LoadTable] Error parsing table:\n" .. tostring(err))
	end, self, tbl)
	if b then
		self:Apply()
		return result
	end
	return false
end

---Converts a string to a table and applies its properties.
---@param str string
---@return boolean
function LeaderLibGameSettings:LoadString(str)
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
		self:Apply()
		return result
	else
		Ext.PrintError("[LeaderLibGameSettings:CreateFromString] Error parsing string as table:\n" .. tostring(result))
	end
	return false
end

function LeaderLibGameSettings:Sync()
	if Ext.IsServer() then
		--GameHelpers.UI.SetStatusVisibility(self.Settings.Client.HideStatuses)
		local settings = self.Settings.APSettings.Player
		local statChanges = {}
		for i,v in pairs(Osi.DB_IsPlayer:Get(nil)) do
			local character = Ext.GetCharacter(v[1])
			if character ~= nil then
				local userid = CharacterGetReservedUserID(v[1])
				local stats = {}
				local baseStat = Ext.GetStat(character.Stats.Name)
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
				
				table.insert(statChanges, {
					NetID = character.NetID,
					Stats = stats
				})
			end
		end
		if statChanges and #statChanges > 0 then
			Ext.BroadcastMessage("LeaderLib_SetGameSettingsStats", Ext.JsonStringify(statChanges), nil)
		end
	end
end

function LeaderLibGameSettings:Apply()
	if self.Settings.BackstabSettings.Player.Enabled or self.Settings.BackstabSettings.NPC.Enabled then
		EnableFeature("BackstabCalculation")
	end
	if Ext.IsClient() then
		UI.ToggleStatusVisibility(not self.Settings.Client.HideStatuses)
		TalentManager.ToggleDivineTalents(self.Settings.Client.DivineTalentsEnabled)
	end
end

Ext.RegisterNetListener("LeaderLib_GameSettings_Apply", function(cmd, payload)
	GameSettings:Apply()
end)

Classes.LeaderLibGameSettings = LeaderLibGameSettings
GameSettings = LeaderLibGameSettings:Create()