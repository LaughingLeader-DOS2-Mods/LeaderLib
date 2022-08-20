SkipTutorial = {
	Regions = {
		FJ_FortJoy_Main = 1,
		LV_HoE_Main = 2,
		RC_Main = 3,
		CoS_Main = 4,
		ARX_Main = 5,
		ARX_Endgame = 6
	}
}

local _EXTVERSION = Ext.Version()

local initialized = false

local function skipTutorialWakeup(uuid)
	fprint(LOGLEVEL.DEFAULT, "[LeaderLib:SkipTutorial] Speeding up Fort Joy beach wake-up for %s", uuid)
	Osi.ProcObjectTimerCancel(uuid, "FTJ_GameStart_FadeIn")
	Osi.ProcObjectTimerCancel(uuid, "FTJ_WakeUpTimer")
	RemoveStatus(uuid, "WET")
	CharacterUnfreeze(uuid)
	Osi.PROC_UnlockWaypoint("WAYP_FTJ_BeachStatue", uuid)
	CharacterSetAnimationOverride(uuid,"")
	--PlayAnimation(uuid,"knockdown_getup","")
	Osi.PROC_FTJ_StartWakeUpVoicebark(uuid)
	--Osi.Proc_FTJ_UnfreezePlayers()
	UserSetFlag(uuid,"QuestUpdate_FTJ_Voice_TUT_Voice", 0)
end

local function skipTutorialWakeupTimer(uuid, timerName)
	Timer.StartOneshot("Timers_LeaderLib_SkipWakeup", 50, function()
		skipTutorialWakeup(uuid)
	end)
	--Osi.PROC_FTJ_StartWakeUpVoicebark(uuid)
	--Osi.Proc_FTJ_UnfreezePlayers()
	--UserSetFlag(uuid,"QuestUpdate_FTJ_Voice_TUT_Voice",0)
end

function SkipTutorial.Initialize()
	if initialized then
		return
	end
	Ext.Utils.Print("[LeaderLib] Initializing Skip Tutorial options.")
	initialized = true
	local runSkipTutorialSetup = false
	local skipTutorialControlEnabled = false

	local attributeToPreset = {
		Strength = "Knight",
		Finesse = "Rogue",
		Intelligence = "Wizard",
	}

	local function GetMainAttributePreset(uuid)
		local highestVal = 0
		local targetPreset = "Inquisitor"
		local startingVal = Ext.ExtraData.AttributeBaseValue or 10
		for attribute,preset in pairs(attributeToPreset) do
			local amount = CharacterGetAttribute(uuid, attribute)
			if amount > highestVal and amount > startingVal then
				highestVal = amount
				targetPreset = preset
			end
		end
		return targetPreset
	end

	local ID = {
		Ifan = "ad9a3327-4456-42a7-9bf4-7ad60cc9e54f",
		Lohse = "bb932b13-8ebf-4ab4-aac0-83e6924e4295",
		Sebille = "c8d55eaf-e4eb-466a-8f0d-6a9447b5b24c",
		RedPrince = "a26a1efb-cdc8-4cf3-a7b2-b2f9544add6f",
		Fane = "02a77f1f-872b-49ca-91ab-32098c443beb",
		Beast = "f25ca124-a4d2-427b-af62-df66df41a978",
		ShapeshifterMask = "9e1dd03c-6ceb-47e6-b073-40cf228cb98e",
		Windego = "d783285f-d3be-4cba-8333-db8976cef182"
	}

	---@param settings table
	local function SkipTutorial_MainSetup(settings, region)
		fprint(LOGLEVEL.DEFAULT, "[LeaderLib] Skipping tutorial and going to region (%s).", region)

		local host = StringHelpers.GetUUID(CharacterGetHostCharacter())
		local db = Osi.DB_OriginRecruitmentLocation_Region:Get("TUT_Tutorial_A",nil,nil,nil)
		if db then
			for _,entry in pairs(db) do
				CharacterEnableAllCrimes(entry[2])
			end
		end

		local regionLevel = SkipTutorial.Regions[region] or 0
		for player in GameHelpers.Character.GetPlayers() do
			if settings.StartingCharacterLevel.Enabled then
				local targetLevel = settings.StartingCharacterLevel[region] or 1
				if targetLevel > 1 and player.Stats.Level < targetLevel then
					fprint(LOGLEVEL.DEFAULT, "[LeaderLib:SkipTutorial] Leveling up player (%s) to (%s).", player.DisplayName, targetLevel)
					GameHelpers.Character.SetLevel(player, targetLevel)
				end
			end
			
			-- Past Fort Joy, apply the _Act2 presets.
			if regionLevel > 1 then
				fprint(LOGLEVEL.TRACE, "[LeaderLib:SkipTutorial] Adding Bless to player (%s).", player.DisplayName)
				CharacterAddSkill(player.MyGuid, "Target_Bless", 0)
				-- if Vars.DebugMode then
				-- 	Timer.StartOneshot(string.format("LeaderLib_SkipTutorialPostSetup%s", uuid), 1000, function()
				-- 		local preset = GetVarFixedString(uuid, "LeaderLib_CurrentPreset")
				-- 		if StringHelpers.IsNullOrEmpty(preset) then
				-- 			preset = GetMainAttributePreset(uuid)
				-- 		end
				-- 		if not StringHelpers.IsNullOrEmpty(preset) then
				-- 			---@type PresetData
				-- 			local act2Preset = Data.Presets.Act2[preset]
				-- 			if act2Preset then
				-- 				fprint(LOGLEVEL.DEFAULT, "[LeaderLib:SkipTutorial] Applying preset (%s) to player (%s).", preset, uuid)
				-- 				act2Preset:ApplyToCharacter(uuid, "Uncommon", nil, true, true)
				-- 			end
				-- 		end
				-- 	end)
				-- end
			end
		end

		--Mods.LeaderLib.Data.Presets.Preview.LLWEAPONEX_Reaper:AddEquipmentToCharacter(CharacterGetHostCharacter(), "Epic", nil, false)
		--Mods.LeaderLib.Data.Presets.Preview.LLWEAPONEX_DragonSlayer:AddEquipmentToCharacter(CharacterGetHostCharacter(), "Uncommon", nil, false)

		if settings.StartingGold.Enabled then
			local gold = settings.StartingGold[region] or 0
			if gold > 0 then
				fprint(LOGLEVEL.DEFAULT, "[LeaderLib:SkipTutorial] Adding (%s) party gold.", gold)
				PartyAddGold(host, gold)
			end
		end

		Timer.StartOneshot("LeaderLib_SkipTutorial_CreateAutoSave", 5000, function ()
			if _OSIRIS() then
				AutoSave()
			end
		end)
	end

	--TODO Make StartTrigger another GameSettings configuration value.
	local LevelSettings = {
		TUT_Tutorial_A = {
			StartTrigger = "fe2995bf-aa16-8ce7-33a2-8cb8cf228152",
			Setup = function(settings)
				Osi.DB_GLO_FirstLevelAfterCharacterCreation("TUT_Tutorial_A")
				Osi.DB_CharacterCreationTransitionInfo("FJ_FortJoy_Main","34d67d87-441c-427d-97bb-4cc506b42fe0","CS_Drowning")
			end
		},
		FJ_FortJoy_Main = {
			StartTrigger = "34d67d87-441c-427d-97bb-4cc506b42fe0",
			---@param settings LeaderLibGameSettings
			Setup = function(settings)
				Ext.Utils.Print("[LeaderLib:SkipTutorial] Running Fort Joy setup.")

				--Thanks to Lady C's Skip Tutorial mod
				SetOnStage(ID.ShapeshifterMask, 1)
				ItemToInventory(ID.ShapeshifterMask, ID.Windego, 1, 0, 0)

				Osi.DB_TUT_OriginQuestStarts(ID.Ifan,"QuestAdd_FTJ_Ifan_DarkFaction","QuestUpdate_FTJ_Ifan_DarkFaction_Start_BeachWakeup")
				Osi.DB_TUT_OriginQuestStarts(ID.Lohse,"QuestAdd_FTJ_OriginLohse","QuestUpdate_FTJ_OriginLohse_Start_BeachWakeup")
				Osi.DB_TUT_OriginQuestStarts(ID.Sebille,"QuestAdd_FTJ_OriginSebille","QuestUpdate_FTJ_OriginSebille_Start_Dreamer")
				Osi.DB_TUT_OriginQuestStarts(ID.RedPrince,"QuestAdd_FTJ_OriginRedPrince","QuestUpdate_FTJ_OriginRedPrince_Start_BeachWakeup")
				Osi.DB_TUT_OriginQuestStarts(ID.Fane,"QuestAdd_FTJ_OriginFane","QuestUpdate_FTJ_OriginFane_Start_BoatWakeup")
				Osi.DB_TUT_OriginQuestStarts(ID.Beast,"QuestAdd_FTJ_OriginBeast","QuestUpdate_FTJ_OriginBeast_Start_BoatWakeup")

				-- She can fight again in Fort Joy
				CharacterSetReactionPriority(ID.Windego, "TutorialFight", 0)

				for _,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
					local uuid = StringHelpers.GetUUID(db[1])
					local questStartDB = Osi.DB_TUT_OriginQuestStarts:Get(uuid, nil, nil)
					if questStartDB and #questStartDB > 1 then
						for entry in questStartDB do
							ObjectSetFlag(uuid, entry[1], 0)
							ObjectSetFlag(uuid, entry[2], 0)
						end
					end
					Osi.DB_TUT_PlayerReceivedQuests(uuid)
					UserSetFlag(uuid,"QuestUpdate_CORE_Chapter1_TUT_Start", 0)
					UserSetFlag(uuid,"QuestUpdate_CORE_Chapter1_TUT_Lore", 0)
					UserSetFlag(uuid,"QuestUpdate_CORE_Chapter1_TUT_FTJ", 0)
					UserSetFlag(uuid,"QuestUpdate_CORE_Magisters_InitialSetup", 0)
					PartySetFlag(uuid,"QuestUpdate_TUT_ShipMurder_WakeUp", 0)
					if IsTagged(uuid, "AVATAR") == 1 then
						ObjectSetFlag(uuid, "QuestUpdate_RC_FTJ_SourceCollar_StartSourceCollar", 0)
						ItemTemplateAddTo("FUR_Humans_Camping_Sleepingbag_B 4d7216c9-c21e-4ab0-b98e-97d744798912", uuid, 1, 0)
					end

					if GameSettings.Settings.SkipTutorial.AddRecipes then
						CharacterUnlockRecipe(uuid, "CON_Food_PotatoBoiled_A_CON_Drink_Cup_A_Milk", 0)
						CharacterUnlockRecipe(uuid, "CON_Food_Potato_A_FUR_BoilingPot_A", 0)
						CharacterUnlockRecipe(uuid, "CON_Food_Potato_A_TOOL_Hammer", 0)
						CharacterUnlockRecipe(uuid, "CON_Food_Potato_Mash_Cold_A_FUR_BoilingPot_A", 0)
						CharacterUnlockRecipe(uuid, "Oven_CON_Food_Potato_Mash_Cold_A", 0)
						CharacterUnlockRecipe(uuid, "FUR_BoilingPot_A_CON_Food_Potato_Mash_Cold_A", 0)
					end

					--Windego's attitude toward the players has decreased due to the combat, but we want her to talk to them again in Fort Joy -> restore
					local winAttitude = CharacterGetAttitudeTowardsPlayer(ID.Windego, uuid)
					if winAttitude < 0 then
						CharacterAddAttitudeTowardsPlayer(ID.Windego, uuid, -winAttitude)
					end
				end

				-- Make neutral again to players
				-- TUT_WindegoInterrogation.txt
				Osi.SetRelationFactionToPlayers("FTJ_SW_Windego", 50)

				-- Give Beast Hat quest
				GlobalSetFlag("FTJ_BST_BeastEndedTutWithHat")

				-- Give Sebille Adrenaline from eating the arm
				if GameHelpers.Character.IsPlayer(ID.Sebille) and CharacterHasSkill(ID.Sebille, "Shout_Adrenaline") == 0 then
					CharacterAddSkill(ID.Sebille, "Shout_Adrenaline", 0)
				end

				GlobalSetFlag("TUT_LowerDeck_OriginsFleeingToTop")
				GlobalSetFlag("TUT_ChoseRescueOthers")

				Timer.StartOneshot("Timers_LeaderLib_SkipFTJWakeup", 50, function()
					for player in GameHelpers.Character.GetPlayers() do
						skipTutorialWakeup(player.MyGuid)
						if _EXTVERSION >= 56 then
							ObjectClearFlag(player.MyGuid, "DLC_SquirrelKnight_OwnerFlag", 0)
						end
					end
				end)

				if Vars.DebugMode then
					Ext.Utils.PrintWarning("Checking for Sir Lora bug...")
					--TRIGGERGUID_S_FTJ_DLC_SquirrelWizard_SpawnPoint_2fd623f7-34f5-470d-bce3-3aa60ce50c3b
					if ObjectExists("2fd623f7-34f5-470d-bce3-3aa60ce50c3b") == 0 then
						Ext.Utils.PrintError("Sir Lora spawnpoint trigger '2fd623f7-34f5-470d-bce3-3aa60ce50c3b' does not exist. He'll be teleported to the player")
					else
						Ext.Utils.Print("Sir Lora spawnpoint trigger '2fd623f7-34f5-470d-bce3-3aa60ce50c3b' exists!")
					end
				end

				-- if _EXTVERSION >= 56 and GlobalGetFlag("GLO_DLC_SquirrelWizard_Activated") == 1 then
				-- 	TeleportTo("9183620e-c7d1-4762-b7c6-512045da9325", "2fd623f7-34f5-470d-bce3-3aa60ce50c3b", "", 0, 1, 1)
				-- 	ClearVarObject("9183620e-c7d1-4762-b7c6-512045da9325", "owner")
				-- 	GlobalClearFlag("GLO_DLC_SquirrelWizard_Activated")
				-- 	Timer.StartOneshot("", 1000, function ()
				-- 		Osi.Proc_DLC_TrySpawn_SquirrelWizard()
				-- 	end)
				-- end
			end
		},
		LV_HoE_Main = {
			StartTrigger = "ce65a666-74e4-4903-bbcf-200251975965",
			Setup = function(settings)

			end
		},
		RC_Main = {
			StartTrigger = "e30fe0c4-9b40-4040-9670-e8edd53a34ce",
			Setup = function(settings)

			end
		},
		CoS_Main = {
			StartTrigger = "8c00afb8-43af-4de7-953a-a7456f996a4c",
			Setup = function(settings)

			end
		},
		ARX_Main = {
			StartTrigger = "fb573f96-d837-0033-4143-3bf31d88ae49",
			Setup = function(settings)

			end
		},
		ARX_Endgame = {
			StartTrigger = "bd166e2a-7623-490e-94df-78079e7cbacc",
			Setup = function(settings)

			end
		},
	}

	local function IsValidLevel(region)
		if not region or not SkipTutorial.Regions[region] then
			fprint(LOGLEVEL.ERROR, "[LeaderLib:SkipTutorial] region(%s) is not a valid value.", tostring(region))
			return false
		end
		if not LevelSettings[region] or not LevelSettings[region].StartTrigger then
			fprint(LOGLEVEL.WARNING, "[LeaderLib:SkipTutorial] No valid global StartTrigger for region (%s).", tostring(region))
			return false
		end
		return true
	end

	local function EnableSkipTutorial(targetRegion)
		local region = targetRegion or GameSettings.Settings.SkipTutorial.Destination
		if not IsValidLevel(region) then
			region = "FJ_FortJoy_Main"
		end

		--local host = StringHelpers.GetUUID(CharacterGetHostCharacter())
		-- NOT DB_GLO_FirstLevelAfterCharacterCreation("TUT_Tutorial_A");
		-- NOT DB_CharacterCreationTransitionInfo("FJ_FortJoy_Main",(TRIGGERGUID)TRIGGERGUID_StartPoint_001_34d67d87-441c-427d-97bb-4cc506b42fe0,"CS_Drowning");
		-- NOT DB_CharacterCreationTransitionInfo("TUT_Tutorial_A",(TRIGGERGUID)TRIGGERGUID_StartPoint_000__000_fe2995bf-aa16-8ce7-33a2-8cb8cf228152,"CS_Intro");
		
		-- Osi.DB_GLO_FirstLevelAfterCharacterCreation:Delete("TUT_Tutorial_A")
		-- Osi.DB_CharacterCreationTransitionInfo:Delete("FJ_FortJoy_Main",nil,"CS_Drowning")
		-- Osi.DB_CharacterCreationTransitionInfo:Delete("TUT_Tutorial_A",nil,"CS_Intro")
		Osi.DB_GLO_FirstLevelAfterCharacterCreation:Delete(nil)
		Osi.DB_CharacterCreationTransitionInfo:Delete(nil,nil,nil)
		Osi.DB_CharacterCreationTransitionInfo:Delete(nil,nil,nil)

		if _EXTVERSION >= 56 and region == "FJ_FortJoy_Main" then
			--Fix Sir Lora issues if the region loaded too fast
			GlobalSetFlag("GLO_DLC_SquirrelWizard_Activated")
		end

		local data = LevelSettings[region]
		Osi.DB_GLO_FirstLevelAfterCharacterCreation(region)
		fprint(LOGLEVEL.TRACE, "[LeaderLib:SkipTutorial] Teleporting to region (%s) and trigger (%s)", region, data.StartTrigger)
		Osi.DB_CharacterCreationTransitionInfo(region, data.StartTrigger,"")
	end

	Ext.RegisterNetListener("LeaderLib_SetSkipTutorial", function(cmd, level)
		if level == "None" then
			GameSettings.Settings.SkipTutorial.Enabled = false
		else
			GameSettings.Settings.SkipTutorial.Enabled = true
			GameSettings.Settings.SkipTutorial.Destination = level
		end
		runSkipTutorialSetup = GameSettings.Settings.SkipTutorial.Enabled
		GameSettingsManager.Save()
	end)

	local subscribeIndex = -1

	---@param e RegionChangedEventArgs
	local function SkipTutorial_RegionChanged(e)
		if SharedData.GameMode == GAMEMODE.CAMPAIGN and e.State == REGIONSTATE.GAME then
			if e.LevelType == LEVELTYPE.CHARACTER_CREATION then
				-- Skip setting up Skip Tutorial stuff if another mod is modifying that already.
				if GameHelpers.DB.HasValue("DB_GLO_FirstLevelAfterCharacterCreation", "TUT_Tutorial_A") then
					runSkipTutorialSetup = GameSettings.Settings.SkipTutorial.Enabled
					GameHelpers.Net.PostMessageToHost("LeaderLib_EnableSkipTutorialUI", SharedData.RegionData.Current)
				else
					Ext.Utils.Print("[LeaderLib] The tutorial is already being bypassed. Skipping Skip Tutorial setup.")
				end
			else
				if runSkipTutorialSetup and e.Region == GameSettings.Settings.SkipTutorial.Destination then
					local data = LevelSettings[e.Region]
					local settings = GameSettings.Settings.SkipTutorial
		
					SkipTutorial_MainSetup(settings, e.Region)
		
					if data and data.Setup then
						local b,err = xpcall(data.Setup, debug.traceback, settings)
						if not b then
							Ext.Utils.PrintError(err)
						end
					end
					runSkipTutorialSetup = false
					Events.RegionChanged:Unsubscribe(subscribeIndex)
				end
			end
		end
	end

	subscribeIndex = Events.RegionChanged:Subscribe(SkipTutorial_RegionChanged, {Priority=999})

	Ext.RegisterOsirisListener("CharacterCreationFinished", 1, "before", function(uuid)
		-- CharacterCreationFinished(NULL) means that everyone is ready
		if SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION then
			runSkipTutorialSetup = GameSettings.Settings.SkipTutorial.Enabled
			if StringHelpers.IsNullOrEmpty(uuid) and runSkipTutorialSetup then
				EnableSkipTutorial()
			end
		end
	end)
end