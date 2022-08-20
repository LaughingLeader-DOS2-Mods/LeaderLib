local _ISCLIENT = Ext.IsClient()

if not _ISCLIENT then
	local _ranPatch = {
		FortJoyWarmSpamFix = false,
		ReapersCoastSpiritVisionVoiceBark = false,
	}
	
	local function _isSpiritVisionVoiceBarkDone()
		local db = Osi.DB_OnlyOnce:Get("RC_DW_VB_DrownedSourcerer_SpiritVision")
		if db and db[1] ~= nil and db[1][1] ~= nil then
			return true
		end
		return false
	end
	
	local function _RunPatches(region)
		if region == "FJ_FortJoy_Main" then
			if not _ranPatch.FortJoyEternalFightingFix then
				--Fixes the eternal fighting Gods partake in when no players are anywhere near them
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
							local character = Ext.Entity.GetCharacter(uuid)
							if character then
								if CharacterCanFight(uuid) == 1 then
									SetCanFight(uuid, 0)
									SetCanJoinCombat(uuid, 0)
									fixed = true
								end
								if character.ScriptForceUpdateCount > 0 then
									fixed = true
									character.ScriptForceUpdateCount = 0
									CharacterSetForceUpdate(uuid, 0)
								end
							end
						end
					end
					if fixed then
						_ranPatch.FortJoyEternalFightingFix = true
						Ext.Utils.PrintWarning("[LeaderLib:OriginFixes] Fixed the eternal, spammy battle of the gods.")
					end
				end
			end
			if not _ranPatch.FortJoyWarmSpamFix then
				--[[ WARM Attempt Spam Fix
					Fix for this corpse in an ArmorSets area in Fort Joy getting a "WARM" status influence, 
					due to it "entering" the trigger before it died.
					Trigger:"ccac77ee-d0b8-4d1f-b25c-dc53632a9a33"]]
				if ObjectExists("702becec-f2c1-44b2-b7ab-c247f8da97ac") == 1 then
					SetVarFixedString("702becec-f2c1-44b2-b7ab-c247f8da97ac", "LeaderLib_RemoveStatusInfluence_ID", "WARM")
					SetStoryEvent("702becec-f2c1-44b2-b7ab-c247f8da97ac", "LeaderLib_Commands_RemoveStatusInfluence")
					_ranPatch.FortJoyWarmSpamFix = true
				end
			end
		elseif region == "RC_Main" then
			if not _ranPatch.ReapersCoastSpiritVisionVoiceBark then
				_ranPatch.ReapersCoastSpiritVisionVoiceBark = _isSpiritVisionVoiceBarkDone()
			end
			if not _ranPatch.ReapersCoastSpiritVisionVoiceBark then
				--[[ Permanent Spirit Vision fix
					The original rule only starts this voice bark when applying SPIRIT_VISION.
					If it's permanent and already applied, the bark may not play.
				]]
				Ext.Osiris.RegisterListener("CharacterSawCharacter", 2, "after", function (player, npc)
					local npcGUID = StringHelpers.GetUUID(npc)
					--S_RC_DW_DrownedSourcerer_Corpse_cd81fcc1-7306-4bd0-bd68-bd7df15db801
					if npcGUID == "cd81fcc1-7306-4bd0-bd68-bd7df15db801" 
					and HasActiveStatus(player, "SPIRIT_VISION") == 1
					and not _isSpiritVisionVoiceBarkDone() then
						Osi.DB_OnlyOnce("RC_DW_VB_DrownedSourcerer_SpiritVision")
						StartVoiceBark("RC_DW_VB_DrownedSourcerer_SpiritVision", npcGUID)
					end
				end)
				_ranPatch.ReapersCoastSpiritVisionVoiceBark = true
			end
		end
	end
	
	Events.RegionChanged:Subscribe(function(e)
		if Ext.Mod.IsModLoaded(Data.ModID.DivinityOriginalSin2) and not Ext.Mod.IsModLoaded(Data.ModID.UnofficialPatch) then
			if e.LevelType == LEVELTYPE.GAME and e.State == REGIONSTATE.GAME then
				Timer.StartOneshot("LeaderLib_RunOriginFixes", 1000, function()
					_RunPatches(e.Region)
				end)
			else
				_ranPatch.FortJoyEternalFightingFix = false
			end
		end
	end,{Priority=2})
end