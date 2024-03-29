--[[Experimental script that tries to make combat work outside of the 30m range limit]]

local CombatVacuum = QOL.CombatVacuum

local function SetArenaFlag(uuid)
	if Osi.ObjectGetFlag(uuid, "LeaderLib_ArenaModeEnabled") == 0 then
		Osi.ObjectSetFlag(uuid, "LeaderLib_ArenaModeEnabled", 0)
		Osi.SetInArena(uuid, 1)
		fprint(LOGLEVEL.TRACE, "[SetArenaFlag] Enabled flag for (%s)[%s]", GameHelpers.Character.GetDisplayName(uuid), uuid)
	end
end

CombatVacuum.SetArenaFlag = SetArenaFlag

local function ClearArenaFlag(uuid, skipTimer)
	if Osi.ObjectGetFlag(uuid, "LeaderLib_ArenaModeEnabled") == 1 then
		Osi.ObjectClearFlag(uuid, "LeaderLib_ArenaModeEnabled", 0)
		Osi.SetInArena(uuid, 0)

		fprint(LOGLEVEL.TRACE, "[ClearArenaFlag] Cleared flag for (%s)[%s]", GameHelpers.Character.GetDisplayName(uuid), uuid)

		if skipTimer ~= true then
			Timer.Start("LeaderLib_UpdateArenaFlags", 500)
		end
	end
end

CombatVacuum.ClearArenaFlag = ClearArenaFlag

---Used to update the InArena boolean for characters, which allows them to stay in combat when outside a 30m range.
---@param maxDist? number
---@param enabled? boolean
function CombatVacuum.UpdateArenaFlags(maxDist, enabled)
	if not maxDist then
		maxDist = 30
		local settings = SettingsManager.GetMod(ModuleUUID, false)
		if settings then
			maxDist = settings.Global:GetVariable("AutoCombatRange", 30)
		end
	end
	if enabled == nil then
		local settings = SettingsManager.GetMod(ModuleUUID, false)
		if settings then
			enabled = settings.Global:FlagEquals("LeaderLib_PullPartyIntoCombat", true)
		end
	end
	local clearAllArenaFlags = false
	if enabled and maxDist > 30 then
		local playerInCombat = false
		local processedCombats = {}
		for player in GameHelpers.Character.GetPlayers(true) do
			local combatid = GameHelpers.Combat.GetID(player)
			if combatid > 0 then
				playerInCombat = true
				if processedCombats[combatid] == nil then
					---@type EsvCharacter[]
					local combatCharacters = GameHelpers.Combat.GetCharacters(combatid, nil, nil, true)
					local hasNearbyEnemy = CombatVacuum.HasNearbyEnemy(player, combatCharacters, maxDist)
					if hasNearbyEnemy then
						for _,v in pairs(combatCharacters) do
							SetArenaFlag(v.MyGuid)
						end
					else
						ClearArenaFlag(player.MyGuid, true)
					end
					processedCombats[combatid] = hasNearbyEnemy
				else
					if processedCombats[combatid] then
						SetArenaFlag(player.MyGuid)
					else
						ClearArenaFlag(player.MyGuid, true)
					end
				end
			else
				ClearArenaFlag(player.MyGuid, true)
			end
		end
		if not playerInCombat then
			clearAllArenaFlags = true
		end
	else
		for player in GameHelpers.Character.GetPlayers(true) do
			if Osi.ObjectGetFlag(player.MyGuid, "LeaderLib_ArenaModeEnabled") == 1 then
				clearAllArenaFlags = true
				break
			end
		end
	end
	if clearAllArenaFlags then
		for _,v in pairs(Ext.Entity.GetAllCharacterGuids(SharedData.RegionData.Current)) do
			ClearArenaFlag(v, true)
		end
	end
end

Timer.Subscribe("LeaderLib_UpdateArenaFlags", function ()
	CombatVacuum.UpdateArenaFlags()
end)

RegisterProtectedOsirisListener("CharacterDying", 1, "before", ClearArenaFlag)
RegisterProtectedOsirisListener("CharacterLeftParty", 1, "after", ClearArenaFlag)

Ext.Osiris.RegisterListener("FleeCombat", 1, "before", ClearArenaFlag)

Ext.Osiris.RegisterListener("ObjectLeftCombat", 2, "before", function (uuid, id)
	ClearArenaFlag(uuid)
end)

Ext.Osiris.RegisterListener("ObjectTurnEnded", 1, "before", function (uuid)
	if GameHelpers.Character.IsPlayer(uuid) and Osi.ObjectGetFlag(uuid, "LeaderLib_ArenaModeEnabled") == 1 then
		Timer.Start("LeaderLib_UpdateArenaFlags", 500)
	end
end)

Events.Initialized:Subscribe(function (e)
	Timer.Start("LeaderLib_UpdateArenaFlags", 1500)
end)

Ext.Osiris.RegisterListener("CharacterSawCharacter", 2, "before", function (player, other)
	if Osi.CharacterIsInCombat(player) == 0 and
	Osi.ObjectGetFlag(player, "LeaderLib_ArenaModeEnabled") == 0
	and Osi.ObjectGetFlag(other, "LeaderLib_ArenaModeEnabled") == 1 then
		Timer.Start("LeaderLib_PullPartyIntoCombat", 500)
	end
end)