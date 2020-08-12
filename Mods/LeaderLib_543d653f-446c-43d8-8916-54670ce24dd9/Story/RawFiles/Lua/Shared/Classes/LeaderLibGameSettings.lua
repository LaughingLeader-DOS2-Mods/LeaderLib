---@class LeaderLibDefaultSettings
local DefaultSettings = {
	StarterTierSkillOverrides = false,
	MaxAP = -1,
	MaxAPGroup = "Player", -- All|Player|NPC
	EnableDeveloperTests = false,
	BackstabSettings = {
		Player = {
			Enabled = false,
			TalentRequired = true,
			MeleeOnly = true
		},
		NPC = {
			Enabled = true,
			TalentRequired = true,
			MeleeOnly = true
		}
	},
	Version = Ext.GetModInfo("7e737d2f-31d2-4751-963f-be6ccc59cd0c").Version
}

---@class LeaderLibGameSettings
local LeaderLibGameSettings = {
	Version = -1,
	---@type LeaderLibDefaultSettings
	Settings = DefaultSettings,
	Default = DefaultSettings
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
		Version = Ext.GetModInfo("7e737d2f-31d2-4751-963f-be6ccc59cd0c").Version,
		Settings = DefaultSettings
	}
	setmetatable(this, self)
    return this
end

local function ParseTableValue(settings, k, v)
	if type(v) == "table" then
		if settings[k] == nil then
			settings[k] = v
			PrintDebug("[LeaderLibGameSettings] Set null ",k," to table")
		else
			for k2,v2 in pairs(v) do
				ParseTableValue(settings[k], k2, v2)
			end
		end
	else
		settings[k] = v
		PrintDebug("[LeaderLibGameSettings] Set ",k," to ",v)
	end
end

---@param source table
---@return LeaderLibGameSettings
function LeaderLibGameSettings:LoadTable(tbl)
	local b,result = xpcall(function()
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

---Prepares a message for data transfer and converts it to string.
---@param str string
---@return LeaderLibGameSettings
function LeaderLibGameSettings:LoadString(str)
	local b,result = xpcall(function()
		local tbl = Ext.JsonParse(str)
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
			self.Version = tbl.Verion
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