SkipTutorial = {
	Regions = {
		FJ_FortJoy_Main = true,
		LV_HoE_Main = true,
		RC_Main = true,
		CoS_Main = true,
		Arx_Main = true
	}
}

if Ext.IsServer() then
	local function IsPlayer(uuid)
		return CharacterIsPlayer(uuid) == 1 or # Osi.DB_IsPlayer:Get(uuid) > 1
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

	---@param settings LeaderLibDefaultSettings
	local function SkipTutorial_MainSetup(settings, region)
		for entry in Osi.DB_OriginRecruitmentLocation_Region:Get("TUT_Tutorial_A",nil,nil,nil) do
			CharacterEnableAllCrimes(entry[2])
		end
		if settings.StartingCharacterLevel.Enabled then
			local targetLevel = settings.StartingCharacterLevel[region] or 1
			if targetLevel > 1 then
				for db in pairs(Osi.DB_IsPlayer(nil)) do
					local uuid = db[1]
					if CharacterGetLevel(uuid) < targetLevel then
						CharacterLevelUpTo(uuid, targetLevel)
					end
				end
			end
		end

		if settings.StartingGold.Enabled then
			local gold = settings.StartingGold[region] or 0
			if gold > 0 then
				PartyAddGold(host, gold)
			end
		end
	end

	local LevelSettings = {
		FJ_FortJoy_Main = {
			StartTrigger = "34d67d87-441c-427d-97bb-4cc506b42fe0",
			---@param settings LeaderLibDefaultSettings
			Setup = function(settings)
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

				for db in pairs(Osi.DB_IsPlayer(nil)) do
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
				SetRelationFactionToPlayers("FTJ_SW_Windego", 50)

				-- Give Beast Hat quest
				GlobalSetFlag("FTJ_BST_BeastEndedTutWithHat")

				-- Give Sebille Adrenaline from eating the arm
				if IsPlayer(ID.Sebille) and CharacterHasSkill(ID.Sebille, "Shout_Adrenaline") == 0 then
					CharacterAddSkill(ID.Sebille, "Shout_Adrenaline", 0)
				end

				GlobalSetFlag("TUT_LowerDeck_OriginsFleeingToTop")
				GlobalSetFlag("TUT_ChoseRescueOthers")
			end
		}
	}

	local function IsValidLevel(region)
		return region and SkipTutorial.Regions[region] == true
	end

	local function SkipTutorial(region)
		region = region or GameSettings.Settings.SkipTutorial.Destination
		if not IsValidLevel(region) then
			region = "FJ_FortJoy_Main"
		end

		local host = StringHelpers.GetUUID(CharacterGetHostCharacter())
		-- NOT DB_GLO_FirstLevelAfterCharacterCreation("TUT_Tutorial_A");
		-- NOT DB_CharacterCreationTransitionInfo("FJ_FortJoy_Main",(TRIGGERGUID)TRIGGERGUID_StartPoint_001_34d67d87-441c-427d-97bb-4cc506b42fe0,"CS_Drowning");
		-- NOT DB_CharacterCreationTransitionInfo("TUT_Tutorial_A",(TRIGGERGUID)TRIGGERGUID_StartPoint_000__000_fe2995bf-aa16-8ce7-33a2-8cb8cf228152,"CS_Intro");
		
		Osi.DB_GLO_FirstLevelAfterCharacterCreation:Delete("TUT_Tutorial_A")
		Osi.DB_CharacterCreationTransitionInfo:Delete("FJ_FortJoy_Main",nil,"CS_Drowning")
		Osi.DB_CharacterCreationTransitionInfo:Delete("TUT_Tutorial_A",nil,"CS_Intro")

		local data = LevelSettings[region]
		Osi.DB_GLO_FirstLevelAfterCharacterCreation(region)
		Osi.DB_CharacterCreationTransitionInfo(region, data.StartTrigger,"")

		local settings = GameSettings.Settings.SkipTutorial

		SkipTutorial_MainSetup(settings, region)

		if data.Setup then
			local b,err = xpcall(data.Setup, debug.traceback, settings)
			if not b then
				Ext.PrintError(err)
			end
		end
	end

	local addedSkipTutorialCheckbox = false

	RegisterListener("Initialized", function(region)
		if IsCharacterCreationLevel(region) == 1 then
			local host = StringHelpers.GetUUID(CharacterGetHostCharacter())
			Ext.PostMessageToClient(host, "LeaderLib_SetupSkipTutorialUI", region)
			addedSkipTutorialCheckbox = true
		end
	end)

elseif Ext.IsClient() then
	local createdCheckboxID = -1

	---@param ui LeaderLibUIExtensions
	---@param controlType string
	---@param id number
	---@param state number
	local function SetSkipTutorial(ui, controlType, id, state)
		Ext.PostMessageToServer("LeaderLib_SetSkipTutorial", state == 0 and "false" or "true")
	end

	---@param event InputEvent
	---@param inputMap table<int,boolean>
	---@param controllerEnabled boolean
	local function OnInput(event, inputMap, controllerEnabled)
		if controllerEnabled and createdCheckboxID > -1 and 
			(inputMap[Data.Input.UICreationTabPrev] and event.Press and event.EventId == Data.Input.ConnectivityMenu) then
			local main = UIExtensions.Instance:GetRoot()
			if main then
				main.toggleCheckbox(createdCheckboxID)
			end
		end
	end

	local function GetCheckboxPos()
		if not Vars.ControllerEnabled then
			--return 50,58
			return 0,0
		else
			return 0,0
		end
	end

	Ext.RegisterNetListener("LeaderLib_SetupSkipTutorialUI", function(cmd, payload)
		print("LeaderLib_SetupSkipTutorialUI", cmd, payload)
		local title = "Skip Tutorial"
		if not Vars.ControllerEnabled then
			title = GameHelpers.GetStringKeyText("LeaderLib_UI_SkipTutorial_DisplayName", "Skip Tutorial")
		else
			title = GameHelpers.GetStringKeyText("LeaderLib_UI_SkipTutorial_Controller_DisplayName", "Skip Tutorial (LB + Start)")
		end
		local levelName = GameHelpers.GetStringKeyText(GameSettings.Settings.SkipTutorial.Destination, "Unknown")
		local description = string.format(GameHelpers.GetStringKeyText("LeaderLib_UI_SkipTutorial_Description", "If enabled, the game will skip the tutorial and go right to the configured starting level (%s)."), levelName)
		
		local x,y = GetCheckboxPos()
		createdCheckboxID = UIExtensions.AddCheckbox(SetSkipTutorial, title, description, GameSettings.Settings.SkipTutorial.Enabled and 1 or 0, x, y)

		Input.RegisterListener(OnInput)
	end)

	Ext.RegisterListener("SessionLoaded", function()
		Ext.RegisterUINameCall("startGame", function(...)
			if createdCheckboxID > -1 then
				UIExtensions.RemoveControl(createdCheckboxID)
				Input.RemoveListener(OnInput)
				createdCheckboxID = -1
			end
		end)
		--Ext.RegisterUITypeCall(Data.UIType.characterCreation, "", SetupCreation)
		--Ext.RegisterUITypeCall(Data.UIType.characterCreation_c, "", SetupCreation)
		
		--public function addCheckbox(id:Number, label:String, tooltip:String, stateID:Number=0, x:Number=0, y:Number=0, filterBool:Boolean = false, enabled:Boolean = true)
		
	end)
end