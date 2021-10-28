-- WINGS or PURE is required to play the correct animations on a character
-- This workaround hides WINGS / removes ARM_Wings, and instead displays that with a secondary status.

local wingsOverride = {
	WINGS = {
		StatusType = "CONSUME",
		Items = "",
		Icon = "",
		ForGameMaster = "No",
		Skills = "",
		StatsId = "",
		StackId = "Stack_LeaderLib_Wings"
	}
}

local wingsVisualProps = {
	Type = "Status",
	Action = "LEADERLIB_WINGS",
	Context = {"Self"},
	Duration = 18.0,
	StatusChance = 1.0,
	StatsId = "",
	Arg4 = -1,
	Arg5 = -1,
	SurfaceBoost = false,
	SurfaceBoosts = {}
}

---@param props StatPropertyStatus[]
local function PropertiesHasWingsVisual(props)
	for i,v in pairs(props) do
		if v.Type == "Status" and v.Action ~= "WINGS" then
			local stat = Ext.GetStat(v.Action)
			if stat ~= nil then
				if stat.Items ~= nil then
					---@type StatItem
					local itemStat = Ext.GetStat(stat.Items)
					if itemStat ~= nil and itemStat.Slot == "Wings" then
						return true
					end
				end
			end
		end
	end
	return false
end

---@param props StatPropertyStatus[]
local function PropertiesHasWings(props)
	for i,v in pairs(props) do
		if v.Type == "Status" and v.Action == "WINGS" then
			return i
		end
	end
	return false
end

local wingsProps = {
	SkillData = "SkillProperties",
	Weapon = "ExtraProperties",
	Armor = "ExtraProperties",
	Shield = "ExtraProperties",
}

function OverrideWings(isServer)
	if Features.WingsWorkaround == true then
		if isServer == true then
			for statName,data in pairs(wingsOverride) do
				---@type StatEntryStatusData
				local stat = Ext.GetStat(statName)
				if stat ~= nil then
					for attribute,v in pairs(data) do
						stat[attribute] = v
					end
					Ext.SyncStat(statName, false)
				end
			end
		else
			for statName,data in pairs(wingsOverride) do
				for attribute,v in pairs(data) do
					Ext.StatSetAttribute(statName, attribute, v)
				end
			end
		end
		for entryType,attribute in pairs(wingsProps) do
			for i,statName in pairs(Ext.GetStatEntries(entryType)) do
				local props = GameHelpers.Stats.GetCurrentOrInheritedProperty(statName, attribute)
				if props ~= nil then
					-- Swaps WINGS for LEADERLIB_WINGS
					local wingsPropIndex = PropertiesHasWings(props)
					if wingsPropIndex ~= false and not PropertiesHasWingsVisual(props) then
						props[wingsPropIndex].Action = "LEADERLIB_WINGS"
						if isServer == true then
							--@type StatPropertyStatus[]
							local stat = Ext.GetStat(statName)
							if stat then
								stat[attribute] = props
								Ext.SyncStat(statName, false)
							end
						else
							Ext.StatSetAttribute(statName, attribute, props)
						end
					end
				end
			end
		end
	end
end

if Ext.IsServer() then
	Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region, isEditorMode)
		if Features.WingsWorkaround == true and IsGameLevel(region) == 1 and GlobalGetFlag("LeaderLib_SetupWingsWorkaroundForRegion") == 0 then
			for i,uuid in pairs(Ext.GetAllCharacters(region)) do
				if HasActiveStatus(uuid, "WINGS") == 1 then
					local turns = GetStatusTurns(uuid, "WINGS")
					ApplyStatus(uuid, "LEADERLIB_WINGS", math.max(-1.0, turns * 6.0), 0, uuid)
				end
			end
			GlobalSetFlag("LeaderLib_SetupWingsWorkaroundForRegion")
		end
	end)
	Ext.RegisterOsirisListener("RegionEnded", 1, "after", function(region)
		GlobalClearFlag("LeaderLib_SetupWingsWorkaroundForRegion")
	end)

	RegisterListener("Loaded", function()
		RegisterStatusListener("Applied", "LEADERLIB_WINGS", function(target, statusId, source, statusType)
			local obj = Ext.GetGameObject(target)
			---@type EsvStatusFloating
			local wingsStatus = obj:GetStatus("WINGS")
			if wingsStatus then
				wingsStatus.CurrentLifeTime = -1.0
				wingsStatus.LifeTime = -1.0
				wingsStatus.RequestClientSync = true
			else
				ApplyStatus(target, "WINGS", -1.0, 0, source)
			end
		end)
	
		RegisterStatusListener("Removed", "LEADERLIB_WINGS", function(target, statusId, source, statusType)
			RemoveStatus(target, "WINGS")
		end)
	end)
end