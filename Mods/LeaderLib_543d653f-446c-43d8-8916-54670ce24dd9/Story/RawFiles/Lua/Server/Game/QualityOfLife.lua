local defaultPathInfluence = "Web,50;BloodCloudCursed,70;BloodCloudElectrified,100;BloodCloudElectrifiedCursed,100;BloodCursed,70;BloodElectrified,100;BloodElectrifiedCursed,100;BloodFrozen,30;BloodFrozenCursed,70;Fire,70;FireCloud,70;FireCloudCursed,100;FireCursed,100;Lava,700;Oil,30;OilCursed,70;Poison,70;PoisonCloud,70;PoisonCloudCursed,100;PoisonCursed,100;SmokeCloudCursed,70;WaterCloudCursed,70;WaterCloudElectrified,100;WaterCloudElectrifiedCursed,100;WaterCursed,70;WaterElectrified,100;WaterElectrifiedCursed,100;WaterFrozen,30;WaterFrozenCursed,70;Deathfog,200;"

local defaultUndeadPathInfluence = "Web,50;BloodCloudCursed,70;BloodCloudElectrified,100;BloodCloudElectrifiedCursed,100;BloodCursed,70;BloodElectrified,100;BloodElectrifiedCursed,100;BloodFrozen,30;BloodFrozenCursed,70;Fire,70;FireCloud,70;FireCloudCursed,100;FireCursed,100;Lava,700;Oil,30;OilCursed,70;PoisonCloudCursed,100;PoisonCursed,100;SmokeCloudCursed,70;WaterCloudCursed,70;WaterCloudElectrified,100;WaterCloudElectrifiedCursed,100;WaterCursed,70;WaterElectrified,100;WaterElectrifiedCursed,100;WaterFrozen,30;WaterFrozenCursed,70;"

local ignoreSurfacesPathInfluence = "Web,50;Lava,700;Deathfog,200"
local ignoreUndeadSurfacesPathInfluence = "Web,50;Lava,700"

local playerStats = {
	["HumanFemaleHero"] = true,
	["HumanMaleHero"] = true,
	["DwarfFemaleHero"] = true,
	["DwarfMaleHero"] = true,
	["ElfFemaleHero"] = true,
	["ElfMaleHero"] = true,
	["LizardFemaleHero"] = true,
	["LizardMaleHero"] = true,
	["Player_Ifan"] = Ext.IsModLoaded("1301db3d-1f54-4e98-9be5-5094030916e4"),
	["Player_Lohse"] = Ext.IsModLoaded("1301db3d-1f54-4e98-9be5-5094030916e4"),
	["Player_RedPrince"] = Ext.IsModLoaded("1301db3d-1f54-4e98-9be5-5094030916e4"),
	["Player_Sebille"] = Ext.IsModLoaded("1301db3d-1f54-4e98-9be5-5094030916e4"),
	["Player_Beast"] = Ext.IsModLoaded("1301db3d-1f54-4e98-9be5-5094030916e4"),
}

local undeadPlayerStats = {
	["HumanUndeadFemaleHero"] = true,
	["HumanUndeadMaleHero"] = true,
	["DwarfUndeadFemaleHero"] = true,
	["DwarfUndeadMaleHero"] = true,
	["ElfUndeadFemaleHero"] = true,
	["ElfUndeadMaleHero"] = true,
	["LizardUndeadFemaleHero"] = true,
	["LizardUndeadMaleHero"] = true,
	["Player_Fane"] = Ext.IsModLoaded("1301db3d-1f54-4e98-9be5-5094030916e4"),
}

function ModifyPathInfluenceForAllPlayers(revert)
	for statname,b in pairs(playerStats) do
		if b then
			---@type StatEntryCharacter
			local stat = Ext.GetStat(statname)
			if stat ~= nil then
				if revert == nil then
					stat.PathInfluence = ignoreSurfacesPathInfluence
				else
					stat.PathInfluence = defaultPathInfluence
				end
				Ext.SyncStat(statname, true)
			end
		end
	end
	for statname,b in pairs(undeadPlayerStats) do
		if b then
			---@type StatEntryCharacter
			local stat = Ext.GetStat(statname)
			if stat ~= nil then
				if revert == nil then
					stat.PathInfluence = ignoreUndeadSurfacesPathInfluence
				else
					stat.PathInfluence = defaultUndeadPathInfluence
				end
				Ext.SyncStat(statname, true)
			end
		end
	end
	local players = Osi.DB_IsPlayer:Get(nil) or {}
	for i,v in pairs(players) do
		ModifyPathInfluenceForPlayer(v[1], revert)
	end
end

function ModifyPathInfluenceForPlayer(uuid, revert)
	local player = Ext.GetCharacter(uuid)
	local stat = Ext.GetStat(player.Stats.Name)
	if stat ~= nil then
		if player.Stats.TALENT_Zombie then
			if revert == nil then
				stat.PathInfluence = ignoreUndeadSurfacesPathInfluence
			else
				stat.PathInfluence = defaultUndeadPathInfluence
			end
		else
			if revert == nil then
				stat.PathInfluence = ignoreSurfacesPathInfluence
			else
				stat.PathInfluence = defaultPathInfluence
			end
		end
		Ext.SyncStat(player.Stats.Name, true)
	end
end

if Vars.DebugMode then
	Ext.RegisterOsirisListener("DB_RC_DW_DwarfCommoner_02_ADs", 4, "after", function(event, chance, uuid, dialog)
		Osi.DB_RC_DW_DwarfCommoner_02_ADs:Delete(nil,nil,nil,nil)
	end)
	RegisterListener("Initialized", function()
		if SharedData.RegionData.Current == "RC_Main" then
			Osi.DB_RC_DW_DwarfCommoner_02_ADs:Delete(nil,nil,nil,nil)
		end
	end)
end