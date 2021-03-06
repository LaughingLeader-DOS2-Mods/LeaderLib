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
	EnableDeveloperTests = false,
	Version = Ext.GetModInfo("7e737d2f-31d2-4751-963f-be6ccc59cd0c").Version
}

---@class LeaderLibGameSettings
local LeaderLibGameSettings = {
	---@type LeaderLibDefaultSettings
	Settings = Common.CopyTable(DefaultSettings),
	Default = Common.CopyTable(DefaultSettings)
}
LeaderLibGameSettings.__index = LeaderLibGameSettings

---Prepares a message for data transfer and converts it to string.
---@return string
function LeaderLibGameSettings:ToString()
    return Ext.JsonStringify(self)
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
---@return LeaderLibGameSettings
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
		return self
	end, function(err)
		Ext.PrintError("[LeaderLibGameSettings:LoadTable] Error parsing table:\n" .. tostring(err))
	end, self, tbl)
	if b then
		return result
	else
		return self
	end
end

---Converts a string to a table and applies its properties.
---@param str string
---@return LeaderLibGameSettings
function LeaderLibGameSettings:LoadString(str)
	local b,result = xpcall(function()
		local tbl = Common.JsonParse(str)
		if tbl ~= nil then
			if tbl.Settings ~= nil and type(tbl.Settings) == "table" then
				for k,v in pairs(tbl.Settings) do
					ParseTableValue(self.Settings, k, v)
				end
			elseif tbl.Version == nil then
				for k,v in pairs(tbl) do
					ParseTableValue(self.Settings, k, v)
				end
			end
		end
		if tbl.Version ~= nil then
			self.Settings.Version = tbl.Verion
		end
		return self
	end, debug.traceback)
	if b then
		return result
	else
		Ext.PrintError("[LeaderLibGameSettings:CreateFromString] Error parsing string as table:\n" .. tostring(result))
		return self
	end
end

Classes.LeaderLibGameSettings = LeaderLibGameSettings