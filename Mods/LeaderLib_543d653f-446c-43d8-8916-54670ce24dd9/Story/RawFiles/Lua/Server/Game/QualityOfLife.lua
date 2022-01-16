local defaultPathInfluence = "Web,50;BloodCloudCursed,70;BloodCloudElectrified,100;BloodCloudElectrifiedCursed,100;BloodCursed,70;BloodElectrified,100;BloodElectrifiedCursed,100;BloodFrozen,30;BloodFrozenCursed,70;Fire,70;FireCloud,70;FireCloudCursed,100;FireCursed,100;Lava,700;Oil,30;OilCursed,70;Poison,70;PoisonCloud,70;PoisonCloudCursed,100;PoisonCursed,100;SmokeCloudCursed,70;WaterCloudCursed,70;WaterCloudElectrified,100;WaterCloudElectrifiedCursed,100;WaterCursed,70;WaterElectrified,100;WaterElectrifiedCursed,100;WaterFrozen,30;WaterFrozenCursed,70;Deathfog,200;"

local defaultUndeadPathInfluence = "Web,50;BloodCloudCursed,70;BloodCloudElectrified,100;BloodCloudElectrifiedCursed,100;BloodCursed,70;BloodElectrified,100;BloodElectrifiedCursed,100;BloodFrozen,30;BloodFrozenCursed,70;Fire,70;FireCloud,70;FireCloudCursed,100;FireCursed,100;Lava,700;Oil,30;OilCursed,70;PoisonCloudCursed,100;PoisonCursed,100;SmokeCloudCursed,70;WaterCloudCursed,70;WaterCloudElectrified,100;WaterCloudElectrifiedCursed,100;WaterCursed,70;WaterElectrified,100;WaterElectrifiedCursed,100;WaterFrozen,30;WaterFrozenCursed,70;"

local ignoreSurfacesPathInfluence = "Web,50;Lava,700;Deathfog,200"
local ignoreUndeadSurfacesPathInfluence = "Web,50;Lava,700"

local player_stats = {
	["HumanFemaleHero"] = true,
	["HumanMaleHero"] = true,
	["DwarfFemaleHero"] = true,
	["DwarfMaleHero"] = true,
	["ElfFemaleHero"] = true,
	["ElfMaleHero"] = true,
	["LizardFemaleHero"] = true,
	["LizardMaleHero"] = true,
	["Player_Ifan"] = "1301db3d-1f54-4e98-9be5-5094030916e4",
	["Player_Lohse"] = "1301db3d-1f54-4e98-9be5-5094030916e4",
	["Player_RedPrince"] = "1301db3d-1f54-4e98-9be5-5094030916e4",
	["Player_Sebille"] = "1301db3d-1f54-4e98-9be5-5094030916e4",
	["Player_Beast"] = "1301db3d-1f54-4e98-9be5-5094030916e4",
	["Player_Fane"] = "1301db3d-1f54-4e98-9be5-5094030916e4",
}

local player_stats_undead = {
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
	for statname,b in pairs(player_stats) do
		if b == true or (type(b) == "string" and Ext.IsModLoaded(b)) then
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
	for statname,b in pairs(player_stats_undead) do
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

local function GetClosestEnemy(player, enemies, maxDist)
	local lastDist = 999
	local lastEnemy = nil
	for _,v in pairs(enemies) do
		local dist = GameHelpers.Math.GetDistance(player, v)
		if dist <= maxDist and dist < lastDist then
			lastDist = dist
			lastEnemy = v
		end
	end
	return lastEnemy
end

--Enabled with LeaderLib_PullPartyIntoCombat
function PullPartyIntoCombat()
	local settings = SettingsManager.GetMod(ModuleUUID, false)
	local maxDist = 30
	if settings then
		maxDist = settings.Global:GetVariable("AutoCombatRange", 30)
	end
	if maxDist <= 0 then
		return
	end

	--TODO Any way to unhardcode the 30m range from the engine? You get kicked out of combat otherwise.
	maxDist = math.min(maxDist, 30)

	local players = GameHelpers.Character.GetPlayers(true, true)
	local activeCombatId = nil
	local referencePlayer = nil
	for _,player in pairs(players) do
		if GameHelpers.Character.IsInCombat(player) then
			activeCombatId = CombatGetIDForCharacter(player.MyGuid)
			referencePlayer = player
			break
		end
	end
	if activeCombatId and activeCombatId > 0 then
		local enemies = GameHelpers.Combat.GetCharacters(activeCombatId, "Enemy", referencePlayer, true)

		if #enemies > 0 then
			for _,player in pairs(players) do
				if not GameHelpers.Character.IsInCombat(player)
				and not GameHelpers.Character.IsSneakingOrInvisible(player)
				then
					local enemy = GetClosestEnemy(player, enemies, maxDist)
					if enemy then
						Osi.DB_LeaderLib_Combat_Temp_EnteredCombat(player.MyGuid, activeCombatId)
						EnterCombat(player.MyGuid, enemy.MyGuid)
					end
				end
			end
		end
	end
end

function StartAutosaving()
	if not Vars.IsEditorMode and SharedData.RegionData.LevelType == LEVELTYPE.GAME then
		local settings = SettingsManager.GetMod(ModuleUUID, false)
		local interval = 15
		if settings then
			interval = settings.Global:GetVariable("AutosaveInterval", 15)
		end
		Osi.LeaderLib_Autosaving_InitTimer(interval)
	end
end