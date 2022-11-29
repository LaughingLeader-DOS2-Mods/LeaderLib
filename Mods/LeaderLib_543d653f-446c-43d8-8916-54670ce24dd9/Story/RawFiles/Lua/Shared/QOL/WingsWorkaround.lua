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
			local stat = Ext.Stats.Get(v.Action, nil, false)
			if stat ~= nil then
				if stat.Items ~= nil then
					local itemStat = Ext.Stats.Get(stat.Items, nil, false) --[[@as StatEntryArmor]]
					if itemStat and itemStat.Slot == "Wings" then
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

function OverrideWings(shouldSync)
	if Features.WingsWorkaround == true then
		for statName,data in pairs(wingsOverride) do
			---@type StatEntryStatusData
			local stat = Ext.Stats.Get(statName, nil, false)
			if stat ~= nil then
				for attribute,v in pairs(data) do
					stat[attribute] = v
				end
				if shouldSync then
					Ext.Stats.Sync(statName, false)
				end
			end
		end
		for entryType,attribute in pairs(wingsProps) do
			for i,statName in pairs(Ext.Stats.GetStats(entryType)) do
				local props = GameHelpers.Stats.GetCurrentOrInheritedProperty(statName, attribute)
				if props ~= nil then
					-- Swaps WINGS for LEADERLIB_WINGS
					local wingsPropIndex = PropertiesHasWings(props)
					if wingsPropIndex ~= false and not PropertiesHasWingsVisual(props) then
						props[wingsPropIndex].Action = "LEADERLIB_WINGS"
						local stat = Ext.Stats.Get(statName, nil, false)
						if stat then
							stat[attribute] = props
							Ext.Stats.Sync(statName, false)
						end
					end
				end
			end
		end
	end
end

if Ext.IsServer() then
	Ext.Osiris.RegisterListener("GameStarted", 2, "after", function(region, isEditorMode)
		if Features.WingsWorkaround == true and IsGameLevel(region) == 1 and GlobalGetFlag("LeaderLib_SetupWingsWorkaroundForRegion") == 0 then
			for i,uuid in pairs(Ext.Entity.GetAllCharacterGuids(region)) do
				if HasActiveStatus(uuid, "WINGS") == 1 then
					local turns = GetStatusTurns(uuid, "WINGS")
					ApplyStatus(uuid, "LEADERLIB_WINGS", math.max(-1.0, turns * 6.0), 0, uuid)
				end
			end
			GlobalSetFlag("LeaderLib_SetupWingsWorkaroundForRegion")
		end
	end)
	Ext.Osiris.RegisterListener("RegionEnded", 1, "after", function(region)
		GlobalClearFlag("LeaderLib_SetupWingsWorkaroundForRegion")
	end)

	Events.Loaded:Subscribe(function (e)
		StatusManager.Subscribe.Applied("LEADERLIB_WINGS", function (e)
			---@type EclStatusFloating
			local wingsStatus = e.Target:GetStatus("WINGS")
			if wingsStatus then
				wingsStatus.CurrentLifeTime = -1.0
				wingsStatus.LifeTime = -1.0
				wingsStatus.RequestClientSync = true
			else
				GameHelpers.Status.Apply(e.Target, "WINGS", -1.0, false, e.Source or e.Target)
			end
		end)

		StatusManager.Subscribe.Removed("LEADERLIB_WINGS", function (e)
			GameHelpers.Status.Remove(e.Target, "WINGS")
		end)
	end)
end