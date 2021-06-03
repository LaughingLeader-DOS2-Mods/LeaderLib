local function RunOriginFixes(region)
	if Vars.DebugMode then
		Ext.Print("[LeaderLib:RunOriginFixes]", region)
	end
	if region == "FJ_FortJoy_Main" then
		--Fix Disables the eternal fighting Gods partake in when no players are anywhere near them
		local isInTrigger = false
		for player in GameHelpers.Character.GetPlayers() do
			--TRIGGERGUID_S_FTJ_SW_SUB_HallOfEchoes_3451f5d3-5b43-49d7-876b-82f5b7c9b65d
			if ObjectIsInTrigger(player.MyGuid, "3451f5d3-5b43-49d7-876b-82f5b7c9b65d") == 1 then
				isInTrigger = true
				break
			end
		end
		if not isInTrigger then
			local fixed = false
			for i,entry in pairs(Osi.DB_FTJ_SW_HoECombatants:Get(nil)) do
				local uuid = entry[1]
				if ObjectExists(uuid) == 1 then
					local character = Ext.GetCharacter(uuid)
					if character then
						if CharacterCanFight(uuid) == 1 then
							SetCanFight(uuid, 0)
							SetCanJoinCombat(uuid, 0)
							fixed = true
						end
						if character.ScriptForceUpdateCount > 0 then
							fixed = true
							CharacterSetForceUpdate(uuid, 0)
						end
					end
				end
			end
			if fixed then
				Ext.PrintWarning("[LeaderLib:OriginFixes] Fixed the eternal, spammy battle of the gods.")
			end
		end
	end
end

--Origins
if Ext.IsModLoaded("1301db3d-1f54-4e98-9be5-5094030916e4") then
	RegisterListener("Initialized", function(region)
		StartOneshotTimer("Timers_LeaderLib_RunOriginFixes", 1000, function()
			RunOriginFixes(region)
		end)
	end)
end