
---@class LeaderLibCombatVacuum
local CombatVacuum = {
	TimerTickRate = 2000,
	---enemy.Stats.DynamicStats[1].Sight is set to this value, to avoid pulled party members from getting kicked out of combat
	---This only seems to affect combat range on the server-side, leaving sneaking vision cones unchanged
	ServerSightOverride = 500,
}

QOL.CombatVacuum = CombatVacuum

---@param character EsvCharacter
---@param enemies EsvCharacter[]
---@param maxDist number
---@return boolean
local function HasNearbyEnemy(character, enemies, maxDist)
	for _,v in pairs(enemies) do
		if GameHelpers.Character.IsEnemy(character, v) and GameHelpers.Math.GetDistance(character, v) <= maxDist then
			return true
		end
	end
	return false
end

CombatVacuum.HasNearbyEnemy = HasNearbyEnemy


---@param player EsvCharacter
---@param enemies EsvCharacter[]
---@param maxDist number
---@return EsvCharacter
local function GetClosestEnemy(player, enemies, maxDist)
	local lastDist = 999
	local lastEnemy = nil
	for _,v in pairs(enemies) do
		local dist = GameHelpers.Math.GetDistance(player, v)
		if GameHelpers.Character.IsEnemy(player, v) and dist <= maxDist and dist < lastDist then
			lastDist = dist
			lastEnemy = v
		end
	end
	return lastEnemy
end

CombatVacuum.GetClosestEnemy = GetClosestEnemy

--Enabled with LeaderLib_PullPartyIntoCombat
function PullPartyIntoCombat()
	local settings = SettingsManager.GetLeaderLibSettings()

	---While 30m may be the max range in some cases, 25 is safer, as characters can end up getting infinitely kicked out of combat at 28m
	local absoluteMaxRange = GameHelpers.GetExtraData("LeaderLib_MaxCombatVacuumRange", 30)

	local maxDist = absoluteMaxRange
	if settings then
		if settings.Global:FlagEquals("LeaderLib_PullPartyIntoCombat", false) then
			return
		end
		maxDist = settings.Global:GetVariable("AutoCombatRange", absoluteMaxRange)
	end
	if maxDist <= 0 then
		return
	end

	local ignoreSneaking = settings.Global:FlagEquals("LeaderLib_CombatVacuum_IgnoreSneaking", true)

	--TODO Any way to unhardcode the 30m range from the engine? You get kicked out of combat otherwise.
	maxDist = math.min(maxDist, absoluteMaxRange)

	---@type EsvCharacter[]
	local players = GameHelpers.Character.GetPlayers(true, true)
	---@type EsvCharacter[]
	local outOfCombatPlayers = {}
	local totalOutOfCombat = 0
	local activeCombatId = nil
	local referencePlayer = nil
	for _,player in pairs(players) do
		if GameHelpers.Character.IsInCombat(player) then
			if referencePlayer == nil then
				activeCombatId = CombatGetIDForCharacter(player.MyGuid)
				referencePlayer = player
			end
		else
			totalOutOfCombat = totalOutOfCombat + 1
			outOfCombatPlayers[totalOutOfCombat] = player
		end
	end
	if activeCombatId and activeCombatId > 0 and totalOutOfCombat > 0 then
		---@type EsvCharacter[]
		local enemies = GameHelpers.Combat.GetCharacters(activeCombatId, "Enemy", referencePlayer, true)

		if enemies and #enemies > 0 then
			for _,player in pairs(outOfCombatPlayers) do
				if (ignoreSneaking or not GameHelpers.Character.IsSneakingOrInvisible(player)) then
					local enemy = GetClosestEnemy(player, enemies, maxDist)
					if enemy then
						if CharacterCanSee(player.MyGuid, enemy.MyGuid) == 0 then
							if enemy.Stats.DynamicStats[1].Sight < CombatVacuum.ServerSightOverride then
								enemy.Stats.DynamicStats[1].Sight = CombatVacuum.ServerSightOverride
							end
						end
						-- if QOL.CombatVacuum then
						-- 	QOL.CombatVacuum.SetArenaFlag(player.MyGuid)
						-- 	QOL.CombatVacuum.SetArenaFlag(enemy.MyGuid)
						-- end
						Osi.DB_LeaderLib_Combat_Temp_EnteredCombat(player.MyGuid, activeCombatId)
						EnterCombat(player.MyGuid, enemy.MyGuid)
						totalOutOfCombat = totalOutOfCombat - 1
					end
				end
			end
		end

		if totalOutOfCombat > 0 and settings.Global:FlagEquals("LeaderLib_CombatVacuum_TickCombat", true) then
			Timer.Restart("LeaderLib_CombatVacuum_TickCombat", CombatVacuum.TimerTickRate)
		else
			Timer.Cancel("LeaderLib_CombatVacuum_TickCombat")
		end
	else
		Timer.Cancel("LeaderLib_CombatVacuum_TickCombat")
	end
end

Timer.Subscribe({"LeaderLib_PullPartyIntoCombat", "LeaderLib_CombatVacuum_TickCombat"}, function (e)
	PullPartyIntoCombat()
end)

local function CheckCombatTick()
	if GameHelpers.Combat.IsAnyPlayerInCombat() then
		Timer.Restart("LeaderLib_CombatVacuum_TickCombat", CombatVacuum.TimerTickRate)
	else
		Timer.Cancel("LeaderLib_CombatVacuum_TickCombat")
	end
end

local function StartCombatTickTimer()
	local settings = SettingsManager.GetLeaderLibSettings()
	if settings.Global:FlagEquals("LeaderLib_PullPartyIntoCombat", true) and settings.Global:FlagEquals("LeaderLib_CombatVacuum_TickCombat", true) then
		Timer.Cancel("LeaderLib_CombatVacuum_CheckPartyCombat")
		Timer.StartOneshot("LeaderLib_CombatVacuum_CheckPartyCombat", 500, CheckCombatTick)
	end
end

Ext.Osiris.RegisterListener("CombatStarted", 1, "after", StartCombatTickTimer)
Ext.Osiris.RegisterListener("CombatEnded", 1, "after", StartCombatTickTimer)
Ext.Osiris.RegisterListener("ObjectLeftCombat", 2, "after", StartCombatTickTimer)

local function Teleported_StartTimer()
	local settings = SettingsManager.GetMod(ModuleUUID, false)
	if settings.Global:FlagEquals("LeaderLib_PullPartyIntoCombat", true) then
		Timer.Restart("LeaderLib_PullPartyIntoCombat", 2000)
	end
end

Ext.Osiris.RegisterListener("CharacterTeleportToWaypoint", 2, "after", Teleported_StartTimer)
Ext.Osiris.RegisterListener("CharacterTeleportToPyramid", 2, "after", Teleported_StartTimer)

Events.Initialized:Subscribe(function (e)
	StartCombatTickTimer()
end)