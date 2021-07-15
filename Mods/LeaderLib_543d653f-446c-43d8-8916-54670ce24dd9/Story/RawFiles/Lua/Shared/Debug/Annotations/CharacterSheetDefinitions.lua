---@class abilitiesholder_9
---@field listHolder_mc empty
---@field list scrollListGrouped
---@field init fun():void

---@class customStatsHolder_14
---@field create_mc btnCreateCustomStat
---@field listHolder_mc empty
---@field list scrollListGrouped
---@field stats_array table
---@field groups_array table
---@field init fun():void
---@field onCreateBtnClicked fun():void
---@field positionElements fun(sortElements:boolean, sortValue:string="groupName"):void
---@field clearElements fun():void
---@field resetGroups fun():void
---@field setGameMasterMode fun(isGM:boolean):void
---@field OnGroupClicked fun(group_mc:StatCategory):void
---@field addGroup fun(groupId:number, labelText:string, reposition:boolean, visible:boolean):void
---@field setGroupTooltip fun(groupId:number, text:string):void
---@field setGroupVisibility fun(groupId:number, visible:boolean):void
---@field recountAllPoints fun():void
---@field addCustomStat fun(doubleHandle:number, labelText:string, valueText:string, groupId:number, plusVisible:boolean, minusVisible:boolean):void

---@class CharacterSheetMainTimeline:FlashMainTimeline
---@field stats_mc stats_1
---@field initDone boolean
---@field events table
---@field layout string
---@field alignment string
---@field curTooltip integer
---@field hasTooltip boolean
---@field availableStr string
---@field uiLeft integer
---@field uiRight integer
---@field uiTop integer
---@field uiMinHeight integer
---@field uiMinWidth integer
---@field charList_array table
---@field invRows integer
---@field invCols integer
---@field invCellSize integer
---@field invCellSpacing integer
---@field skillList table
---@field tabsTexts table
---@field primStat_array table
---@field secStat_array table
---@field ability_array table
---@field tags_array table
---@field talent_array table
---@field visual_array table
---@field visualValues_array table
---@field customStats_array table
---@field lvlBtnAbility_array table
---@field lvlBtnStat_array table
---@field lvlBtnSecStat_array table
---@field lvlBtnTalent_array table
---@field allignmentArray table
---@field aiArray table
---@field inventoryUpdateList table
---@field isGameMasterChar boolean
---@field EQContainer FlashMovieClip
---@field slotAmount number
---@field cellSize number
---@field slot_array table
---@field itemsUpdateList table
---@field renameBtnTooltip string
---@field alignmentTooltip string
---@field aiTooltip string
---@field createNewStatBtnLabel string
---@field isDragging boolean
---@field draggingSkill boolean
---@field tabState number
---@field screenWidth number
---@field screenHeight number
---@field text_array table
---@field strSelectTreasure string
---@field strGenerate string
---@field strClear string
---@field strLevel string
---@field listRarity table
---@field listTreasures table
---@field generateTreasureRarityId integer
---@field generateTreasureId integer
---@field generateTreasureLevel integer
---@field characterHandle number
---@field charHandle number
---@field onWheel fun():void
---@field onEventResize fun():void
---@field updateVisuals fun():void
---@field updateSkills fun():void
---@field GMShowTargetSkills fun():void
---@field resetSkillDragging fun():void
---@field updateInventory fun():void
---@field updateAllignmentList fun():void
---@field selectAllignment fun(id:integer):void
---@field updateAIList fun():void
---@field selectAI fun(id:integer):void
---@field setGameMasterMode fun(isGameMasterMode:boolean, isGameMasterChar:boolean, isPossessed:boolean):void
---@field onEventUp fun(index:number):void
---@field onEventDown fun(index:number):void
---@field onEventResolution fun(width:number, height:number):void
---@field onEventInit fun():void
---@field setPossessedState fun(param1:boolean):void
---@field getGlobalPositionOfMC fun(mc:FlashMovieClip):Point
---@field showTooltipForMC fun(mc:FlashMovieClip, externalCall:string):void
---@field showCustomTooltipForMC fun(mc:FlashMovieClip, externalCall:string, statID:number):void
---@field setActionsDisabled fun(disabled:boolean):void
---@field updateItems fun():void
---@field setHelmetOptionState fun(state:number):void
---@field setHelmetOptionTooltip fun(text:string):void
---@field setPlayerInfo fun(text:string):void
---@field setAvailableLabels fun(text:string):void
---@field pointsTextfieldChanged fun(tf:TextField):void
---@field selectCharacter fun(id:number):void
---@field setText fun(tabId:number, text:string):void
---@field setTitle fun(text:string):void
---@field addText fun(labelText:string, tooltipText:string, isSecondary:boolean):void
---@field addPrimaryStat fun(statID:number, labelText:string, valueText:string, tooltipType:number):void
---@field addSecondaryStat fun(statType:number, labelText:string, valueText:string, statID:number, frame:number, boostValue:number):void
---@field clearSecondaryStats fun():void
---@field addAbilityGroup fun(isCivil:boolean, groupId:number, labelText:string):void
---@field addAbility fun(isCivil:boolean, groupId:number, statID:number, labelText:string, valueText:string, plusTooltip:string = "", minusTooltip:string = ""):void
---@field addTalent fun(labelText:string, statID:number, talentState:number):void
---@field addTag fun(tooltipText:string, labelText:string, descriptionText:string, statID:number):void
---@field addVisual fun(titleText:string, contentID:number):void
---@field addVisualOption fun(id:number, optionId:number, select:boolean):void
---@field updateCharList fun():void
---@field cycleCharList fun(previous:boolean):void
---@field clearArray fun(name:string):void
---@field updateArraySystem fun():void
---@field setStatPlusVisible fun(statID:number, isVisible:boolean):void
---@field setStatMinusVisible fun(statID:number, isVisible:boolean):void
---@field setupSecondaryStatsButtons fun(id:integer, showBoth:boolean, minusVisible:boolean, plusVisible:boolean, maxChars:number):void
---@field setAbilityPlusVisible fun(isCivil:boolean, groupId:number, statID:number, isVisible:boolean):void
---@field setAbilityMinusVisible fun(isCivil:boolean, groupId:number, statID:number, isVisible:boolean):void
---@field setTalentPlusVisible fun(statID:number, isVisible:boolean):void
---@field setTalentMinusVisible fun(statID:number, isVisible:boolean):void
---@field addTitle fun(param1:string):void
---@field hideLevelUpStatButtons fun():void
---@field hideLevelUpAbilityButtons fun():void
---@field hideLevelUpTalentButtons fun():void
---@field clearStats fun():void
---@field clearTags fun():void
---@field clearTalents fun():void
---@field clearAbilities fun():void
---@field setPanelTitle fun(param1:number, param2:string):void
---@field showAcceptStatsAcceptButton fun(b:boolean):void
---@field showAcceptAbilitiesAcceptButton fun(b:boolean):void
---@field showAcceptTalentAcceptButton fun(b:boolean):void
---@field setAvailableStatPoints fun(amount:number):void
---@field setAvailableCombatAbilityPoints fun(amount:number):void
---@field setAvailableCivilAbilityPoints fun(amount:number):void
---@field setAvailableTalentPoints fun(amount:number):void
---@field setAvailableCustomStatPoints fun(amount:number):void
---@field addSpacing fun(param1:number, param2:number):void
---@field addGoldWeight fun(param1:string, param2:string):void
---@field startsWith fun(param1:string, param2:string):boolean
---@field ShowItemUnEquipAnim fun(param1:integer, param2:integer):void
---@field ShowItemEquipAnim fun(param1:integer, param2:integer):void
---@field setupStrings fun():void
---@field setupRarity fun():void
---@field setupTreasures fun():void
---@field onOpenDropList fun(mc:FlashMovieClip):void
---@field closeDropLists fun():void
---@field setGenerationRarity fun(id:integer):void
---@field onSelectGenerationRarity fun(id:integer):void
---@field onChangeGenerationLevel fun(level:number):void
---@field onSelectTreasure fun(index:integer):void
---@field onBtnGenerateStock fun():void
---@field onBtnClearInventory fun():void

---@class minusButton_65
---@field bg_mc FlashMovieClip
---@field hit_mc FlashMovieClip
---@field base FlashMovieClip
---@field stat FlashMovieClip
---@field callbackStr string
---@field tooltip string
---@field currentTooltip string
---@field onMouseOver fun(param1:MouseEvent):void
---@field onMouseOut fun(param1:MouseEvent):void
---@field onDown fun(param1:MouseEvent):void
---@field onUp fun(param1:MouseEvent):void

---@class plusButton_62
---@field bg_mc FlashMovieClip
---@field hit_mc FlashMovieClip
---@field base FlashMovieClip
---@field stat FlashMovieClip
---@field callbackStr string
---@field tooltip string
---@field currentTooltip string
---@field onMouseOver fun(param1:MouseEvent):void
---@field onMouseOut fun(param1:MouseEvent):void
---@field onDown fun(param1:MouseEvent):void
---@field onUp fun(param1:MouseEvent):void

---@class pointsAvailable_56
---@field civilAbilPoints_txt TextField
---@field combatAbilPoints_txt TextField
---@field label_txt TextField
---@field statPoints_txt TextField
---@field talentPoints_txt TextField
---@field customStatPoints_txt TextField
---@field setTab fun(tabIndex:integer):void

---@class stats_1
---@field aiSel_mc comboBox
---@field alignments_mc comboBox
---@field attrPointsWrn_mc FlashMovieClip
---@field bg_mc FlashMovieClip
---@field charInfo_mc FlashMovieClip
---@field charList_mc empty
---@field civicAbilityHolder_mc FlashMovieClip
---@field civilAbilityPointsWrn_mc FlashMovieClip
---@field close_mc FlashMovieClip
---@field combatAbilityHolder_mc FlashMovieClip
---@field combatAbilityPointsWrn_mc FlashMovieClip
---@field customStats_mc customStatsHolder_14
---@field customStatsPointsWrn_mc mcPlus_Anim_69
---@field customStatsPoints_txt TextField
---@field dragHit_mc FlashMovieClip
---@field equip_mc FlashMovieClip
---@field equipment_txt TextField
---@field hitArea_mc FlashMovieClip
---@field invTabHolder_mc FlashMovieClip
---@field leftCycleBtn_mc FlashMovieClip
---@field mainStats_mc FlashMovieClip
---@field onePlayerOverlay_mc FlashMovieClip
---@field panelBg1_mc FlashMovieClip
---@field panelBg2_mc FlashMovieClip
---@field pointsFrame_mc FlashMovieClip
---@field rightCycleBtn_mc FlashMovieClip
---@field scrollbarHolder_mc empty
---@field skillTabHolder_mc FlashMovieClip
---@field tabTitle_txt TextField
---@field tabsHolder_mc empty
---@field tagsHolder_mc FlashMovieClip
---@field talentHolder_mc FlashMovieClip
---@field talentPointsWrn_mc FlashMovieClip
---@field title_txt TextField
---@field visualHolder_mc FlashMovieClip
---@field myText string
---@field closeCenterX number
---@field closeSideX number
---@field buttonY number
---@field base FlashMovieClip
---@field lvlUP boolean
---@field cellSize number
---@field statholderListPosY number
---@field listOffsetY number
---@field tabsList horizontalList
---@field charList horizontalScrollList
---@field primaryStatList listDisplay
---@field secondaryStatList listDisplay
---@field expStatList listDisplay
---@field resistanceStatList listDisplay
---@field infoStatList listDisplay
---@field secELSpacing number
---@field currentOpenPanel number
---@field panelArray table
---@field selectedTabY number
---@field deselectedTabY number
---@field selectedTabAlpha number
---@field deselectedTabAlpha number
---@field tabsArray table
---@field pointsWarn table
---@field pointTexts table
---@field root_mc FlashMovieClip
---@field gmSkillsString string
---@field customStatIconOffsetX number
---@field customStatIconOffsetY number
---@field pointWarningOffsetX number
---@field customStatPointsTextOffsetX number
---@field mainStatsList scrollListGrouped
---@field GROUP_MAIN_ATTRIBUTES integer
---@field GROUP_MAIN_STATS integer
---@field GROUP_MAIN_EXPERIENCE integer
---@field GROUP_MAIN_RESISTANCES integer
---@field init fun():void
---@field selectAI fun():void
---@field selectAlignment fun():void
---@field renameCallback fun():void
---@field updateInventorySlots fun(arr:table):void
---@field resetListPositions fun():void
---@field buildTabs fun(tabState:number, initializeTabs:boolean):void
---@field alignPointWarningsToButtons fun():void
---@field pushTabTooltip fun(tabId:number, text:string):void
---@field initTabs fun(bInitTab:boolean, resetTabs:boolean):void
---@field selectCharacter fun(id:number):void
---@field addCharPortrait fun(id:number, iconId:string, order:integer):void
---@field cleanupCharListObsoletes fun():void
---@field removeChildrenOf fun(mc:FlashMovieClip):void
---@field ClickTab fun(tabIndex:number):void
---@field selectTab fun(index:number):void
---@field getTabById fun(tabId:number):FlashMovieClip
---@field setPanelTitle fun(index:number, titleText:string):void
---@field resetScrollBarsPositions fun():void
---@field INTSetWarnAndPoints fun(index:number, pointsValue:number):void
---@field INTSetAvailablePointsVisible fun():void
---@field setAvailableStatPoints fun(points:number):void
---@field setAvailableCombatAbilityPoints fun(points:number):void
---@field setAvailableCivilAbilityPoints fun(points:number):void
---@field setAvailableTalentPoints fun(points:number):void
---@field setVisibilityStatButtons fun(isVisible:boolean):void
---@field setStatPlusVisible fun(id:number, isVisible:boolean):void
---@field setStatMinusVisible fun(id:number, isVisible:boolean):void
---@field setupSecondaryStatsButtons fun(id:integer, showBoth:boolean, minusVisible:boolean, plusVisible:boolean, maxChars:number):void
---@field getStat fun(statID:number, isCustom:boolean):FlashMovieClip
---@field getSecStat fun(statID:number, isCustom:boolean):FlashMovieClip
---@field getAbility fun(isCivil:boolean, groupId:number, statID:number, isCustom:boolean):FlashMovieClip
---@field getTalent fun(statID:number, isCustom:boolean):FlashMovieClip
---@field getTag fun(statID:number):FlashMovieClip
---@field setVisibilityAbilityButtons fun(isCivil:boolean, isVisible:boolean):void
---@field setAbilityPlusVisible fun(param1:boolean, param2:number, param3:number, param4:boolean):void
---@field setAbilityMinusVisible fun(param1:boolean, param2:number, param3:number, param4:boolean):void
---@field setVisibilityTalentButtons fun(isVisible:boolean):void
---@field setTalentPlusVisible fun(talentId:number, visible:boolean):void
---@field setTalentMinusVisible fun(talentId:number, visible:boolean):void
---@field addText fun(text:string, tooltip:string, isSecondary:boolean):void
---@field addSpacing fun(listId:number, height:number):void
---@field addAbilityGroup fun(isCivil:boolean, groupId:number, labelText:string):void
---@field addAbility fun(isCivil:boolean, groupId:number, statID:number, labelText:string, valueText:string, plusTooltip:string = "", minusTooltip:string = "", plusVisible:boolean, minusVisible:boolean, isCustom:boolean):void
---@field recountAbilityPoints fun(isCivil:boolean):void
---@field addTalent fun(labelText:string, statID:number, talentState:number, plusVisible:boolean, minusVisible:boolean, isCustom:boolean):void
---@field getTalentStateFrame fun(state:number):number
---@field addPrimaryStat fun(statID:number, displayName:string, value:string, tooltipId:number, plusVisible:boolean, minusVisible:boolean, isCustom:boolean):void
---@field addSecondaryStat fun(statID:number, labelText:string, valueText:string, tooltipId:number, iconFrame:number, boostValue:number, plusVisible:boolean, minusVisible:boolean, isCustom:boolean):void
---@field addTag fun(labelText:string, statID:number, tooltipText:string, descriptionText:string):void
---@field addToListWithId fun(id:number, mc:FlashMovieClip):void
---@field clearSecondaryStats fun():void
---@field addTitle fun(param1:string):void
---@field clearStats fun():void
---@field clearAbilities fun():void
---@field addVisual fun(titleText:string, contentID:number):void
---@field clearVisualOptions fun():void
---@field addVisualOption fun(id:number, optionId:number, select:boolean):void
---@field getVisual fun(contentID:number):FlashMovieClip
---@field clearCustomStatsOptions fun():void
---@field addCustomStat fun(doubleHandle:number, labelText:string, valueText:string):void
---@field justEatClick fun(param1:MouseEvent):void
---@field onBGOut fun(param1:MouseEvent):void
---@field closeUIOnClick fun(param1:MouseEvent):void
---@field closeUI fun():void
---@field addIcon fun(param1:FlashMovieClip, param2:string, param3:number):void
---@field updateAIs fun(param1:table):void
---@field updateAllignments fun(param1:table):void
---@field recheckScrollbarVisibility fun():void
---@field setMainStatsGroupName fun(groupId:integer, name:string):void

---@class talentsHolder_11
---@field bgGlow_mc FlashMovieClip
---@field listHolder_mc empty
---@field list scrollList
---@field init fun():void
---@field updateBGPos fun(e:Event):void

---@class AbilityEl
---@field abilTooltip_mc FlashMovieClip
---@field hl_mc FlashMovieClip
---@field texts_mc FlashMovieClip
---@field timeline larTween
---@field base FlashMovieClip
---@field isCivil boolean
---@field statID number
---@field callbackStr string
---@field isCustom boolean
---@field MakeCustom fun(id:number, b:boolean):void
---@field onOver fun(param1:MouseEvent):void
---@field onOut fun(e:MouseEvent):void
---@field onHLOver fun(e:MouseEvent):void
---@field onHLOut fun(e:MouseEvent):void
---@field hlInvis fun():void

---@class CustomStat
---@field delete_mc btnDeleteCustomStat
---@field edit_mc btnEditCustomStat
---@field hl_mc FlashMovieClip
---@field label_txt TextField
---@field line_mc FlashMovieClip
---@field minus_mc FlashMovieClip
---@field plus_mc FlashMovieClip
---@field text_txt TextField
---@field timeline larTween
---@field base FlashMovieClip
---@field tooltip string
---@field statID number
---@field am number
---@field id integer
---@field statIndex integer
---@field init fun():void
---@field onOver fun(param1:MouseEvent):void
---@field onOut fun(param1:MouseEvent):void
---@field onEditBtnClicked fun():void
---@field onDeleteBtnClicked fun():void

---@class InfoStat
---@field hl_mc FlashMovieClip
---@field icon_mc FlashMovieClip
---@field minus_mc FlashMovieClip
---@field plus_mc FlashMovieClip
---@field texts_mc FlashMovieClip
---@field timeline larTween
---@field base FlashMovieClip
---@field statID number
---@field tooltip number
---@field callbackStr string
---@field isCustom boolean
---@field MakeCustom fun(statID:number, b:boolean):void
---@field onOver fun(e:MouseEvent):void
---@field onOut fun(e:MouseEvent):void
---@field hlInvis fun():void

---@class SecStat
---@field editText_txt TextField
---@field hl_mc FlashMovieClip
---@field icon_mc FlashMovieClip
---@field minus_mc FlashMovieClip
---@field mod_txt TextField
---@field plus_mc FlashMovieClip
---@field texts_mc FlashMovieClip
---@field timeline larTween
---@field base FlashMovieClip
---@field boostValue number
---@field statID number
---@field tooltip number
---@field callbackStr string
---@field isCustom boolean
---@field MakeCustom fun(statID:number, b:boolean):void
---@field setupButtons fun(param1:boolean, minusVisible:boolean, plusVisible:boolean, maxChars:number):void
---@field onTextPress fun(e:MouseEvent):void
---@field onValueAccept fun(e:FocusEvent):void
---@field onOver fun(e:MouseEvent):void
---@field onOut fun(param1:MouseEvent):void
---@field hlInvis fun():void

---@class skillEl
---@field hl_mc FlashMovieClip
---@field itemSkillFrame_mc FlashMovieClip
---@field removeSkillBtn_mc deleteBtn
---@field root_mc FlashMovieClip
---@field dragTreshHold integer
---@field mousePosDown Point
---@field _canBeRemoved boolean
---@field onInit fun(param1:FlashMovieClip):void
---@field set canBeRemoved fun(param1:boolean):void
---@field get canBeRemoved fun():boolean
---@field onRemoveSkillButtonPressed fun(param1:FlashMovieClip):void
---@field onOver fun(param1:MouseEvent):void
---@field onOut fun(param1:MouseEvent):void
---@field onDown fun(param1:MouseEvent):void
---@field onUp fun(param1:MouseEvent):void
---@field onDragging fun(param1:MouseEvent):void

---@class Stat
---@field hl_mc FlashMovieClip
---@field icon_mc FlashMovieClip
---@field label_txt TextField
---@field minus_mc FlashMovieClip
---@field plus_mc FlashMovieClip
---@field text_txt TextField
---@field timeline larTween
---@field base FlashMovieClip
---@field statID number
---@field tooltip number
---@field callbackStr string
---@field isCustom boolean
---@field MakeCustom fun(statID:number, b:boolean):void
---@field onOver fun(param1:MouseEvent):void
---@field onOut fun(param1:MouseEvent):void

---@class StatCategory
---@field amount_txt TextField
---@field bg_mc FlashMovieClip
---@field listContainer_mc empty
---@field title_txt TextField
---@field isOpen boolean
---@field hidePoints boolean
---@field texty number
---@field groupName string
---@field setIsOpen fun(b:boolean):void
---@field onMouseOver fun(e:MouseEvent):void
---@field onMouseOut fun(e:MouseEvent):void
---@field onDown fun(e:MouseEvent):void
---@field onUp fun(e:MouseEvent):void
---@field get length fun():number
---@field get content_array fun():table

---@class Talent
---@field bullet_mc FlashMovieClip
---@field hl_mc FlashMovieClip
---@field label_txt TextField
---@field minus_mc FlashMovieClip
---@field plus_mc FlashMovieClip
---@field timeline larTween
---@field base FlashMovieClip
---@field statID number
---@field callbackStr string
---@field isCustom boolean
---@field MakeCustom fun(statID:number, b:boolean):void
---@field onOver fun(e:MouseEvent):void
---@field onOut fun(e:MouseEvent):void