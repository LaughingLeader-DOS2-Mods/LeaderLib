--param1:Number, param2:Boolean, param3:String, param4:Boolean = false

---@param ui UIObject
local function PrintCall(ui, call, ...)
	print("[PrintCall]",call, Ext.JsonStringify({...}))
end

local PATTERN_HIDE_CURRENT = "%d+/"
local PATTERN_HIDE_MAX = "/%d+"

local PATTERNS = {
	[1] = PATTERN_HIDE_MAX,
	[2] = PATTERN_HIDE_CURRENT,
}

---@param ui UIObject
local function ModifyBarText(pattern, ui, call, percentage, doTween, text, someBool)
	if text ~= "" then
		return percentage, doTween, string.gsub(text, pattern, ""), someBool
	end
end

---@param ui UIObject
local function ModifyHealthText(pattern, ui, call, percentage, text, doTween)
	if text ~= "" then
		return percentage, doTween, string.gsub(text, pattern, ""), doTween
	end
end

---@type table<string,TranslatedString>
local TALENTS_RACIAL = {
	TALENT_Human_Inventive = Classes.TranslatedString:Create("h2646745cgf1b5g44a2gaf6ageef8ee73a923", "Ingenious"),
	TALENT_Human_Civil = Classes.TranslatedString:Create("h6c44d6c0g4603g429ag9f5bgc4ba0460fdec", "Thrify"),
	TALENT_Elf_Lore = Classes.TranslatedString:Create("hcfd646bdg491dg4d9cgaf1ag2ca5f4421f7b", "Ancestral Knowledge"),
	TALENT_Elf_CorpseEating = Classes.TranslatedString:Create("h8fcf368eg0abeg4314gacdcgb495473a9ade", "Corpse Eater"),
	TALENT_Dwarf_Sturdy = Classes.TranslatedString:Create("h477b8976gfac3g4cdag954bg5617876c6ef7", "Sturdy"),
	TALENT_Dwarf_Sneaking = Classes.TranslatedString:Create("h429e53b9ge574g4c77gbc1ag2cfd9844252f", "Dwarven Guile"),
	TALENT_Lizard_Resistance = Classes.TranslatedString:Create("ha4af67a7g7112g4e66gbaedg6bf024feb097", "Spellsong"),
	TALENT_Lizard_Persuasion = Classes.TranslatedString:Create("h7b9a0d2egff87g42afgbec4g6c01c4303401", "Sophisticated"),
	TALENT_Zombie = Classes.TranslatedString:Create("hffa022a2g03b0g46f7g8ee6gcb8e5811a4d3", "Undead"),
}

local TALENT_Backstab = Classes.TranslatedString:Create("h9836a401g63f6g49c3g8fa0g9564cbad7628", "Assassin")
local TALENT_RogueLoreDaggerBackStab = Classes.TranslatedString:Create("hce5fda5egaeb0g4e2bg8c94g595c0cd029b3", "Backstabber")

function UI.GetArrayIndexStart(ui, arrayName, offset)
	local i = 0
	while i < 9999 do
		local val = ui:GetValue(arrayName, "number", i)
		if val == nil then
			val = ui:GetValue(arrayName, "string", i)
			if val == nil then
				val = ui:GetValue(arrayName, "boolean", i)
			end
		end
		if val == nil then
			return i
		end
		i = i + offset
	end
	return -1
end

function UI.IsInArray(ui, arrayName, id, start, offset)
	local i = start
	while i < 200 do
		local check = ui:GetValue(arrayName,"number", i)
		if check ~= nil and math.tointeger(check) == id then
			return true
		end
		i = i + offset
	end
	return false
end

---@param ui UIObject
local function DisplayTalents(ui, call, ...)
	---@type EsvCharacter
	local player = nil
	local handle = ui:GetPlayerHandle()
	if handle ~= nil then
		player = Ext.GetCharacter(handle)
	elseif Client.Character ~= nil then
		player = Client:GetCharacter()
	end
	if player ~= nil then
		local root = ui:GetRoot()
		local talent_array = root.talent_array
		local lvlBtnTalent_array = root.lvlBtnTalent_array

		local i = #talent_array
		if Features.RacialTalentsDisplayFix then
			for talent,text in pairs(TALENTS_RACIAL) do
				if player.Stats[talent] == true then
					local talentId = string.gsub(talent, "TALENT_", "")
					local talentEnum = Data.TalentEnum[talentId]
					if not TalentManager.TalentIsInArray(talentEnum, talent_array) then
						if not Vars.ControllerEnabled then
							--addTalent(displayName:String, id:Number, talentState:Number)
							talent_array[i] = text.Value
							talent_array[i+1] = talentEnum
						else
							--addTalent(id:Number, displayName:String, talentState:Number)
							talent_array[i] = talentEnum
							talent_array[i+1] = text.Value
						end
						talent_array[i+2] = 0
						i = i + 3
						if Vars.ControllerEnabled then
							TalentManager.Gamepad.AddButton(lvlBtnTalent_array, talentEnum, false, false)
						end
					end
				end
			end
		end
		if player.Stats.TALENT_RogueLoreDaggerBackStab or 
			(GameSettings.Settings.BackstabSettings.Player.Enabled and GameSettings.Settings.BackstabSettings.Player.TalentRequired) 
		then
			local talentEnum = Data.TalentEnum.RogueLoreDaggerBackStab
			 -- Backstab doesn't have an icon check set, while this RogueLoreDaggerBackStab does
			--local talentEnumName = "RogueLoreDaggerBackStab" -- "Backstab"
			if not TalentManager.TalentIsInArray(Data.TalentEnum.RogueLoreDaggerBackStab, talent_array) then
				if not Vars.ControllerEnabled then
					--addTalent(displayName:String, id:Number, talentState:Number)
					talent_array[i] = TALENT_RogueLoreDaggerBackStab.Value
					talent_array[i+1] = talentEnum
				else
					--addTalent(id:Number, displayName:String, talentState:Number)
					talent_array[i] = talentEnum
					talent_array[i+1] = TALENT_RogueLoreDaggerBackStab.Value
				end
				talent_array[i+2] = player.Stats.TALENT_RogueLoreDaggerBackStab and 0 or 2
				i = i + 3
				if Vars.ControllerEnabled then
					local talentState = TalentManager.GetTalentState(player, "RogueLoreDaggerBackStab")
					local isSelected = TalentManager.Gamepad.IsSelectedInMenu("RogueLoreDaggerBackStab")
					local notSelectedHasPointsAndIsSelectable = (not isSelected and TalentManager.Gamepad.AvailablePoints > 0 and talentState == TalentManager.TalentState.Selectable)
					TalentManager.Gamepad.AddButton(lvlBtnTalent_array, talentEnum, isSelected, notSelectedHasPointsAndIsSelectable)
				end
			end
		end
		TalentManager.Update(ui, player)
		local length = #Listeners.OnTalentArrayUpdating
		if length > 0 then
			for i=1,length do
				local callback = Listeners.OnTalentArrayUpdating[i]
				local talentArrayStartIndex = UI.GetArrayIndexStart(ui, "talent_array", 3)
				local b,err = xpcall(callback, debug.traceback, ui, player, talentArrayStartIndex, Data.TalentEnum)
				if not b then
					Ext.PrintError("Error calling function for 'OnTalentArrayUpdating':\n", err)
				end
			end
		end
		--UI.PrintArray(ui, "talent_array")
	end
end

-- addTalentElement(talentId:uint, talentName:String, state:Boolean, choosable:Boolean, isRacial:Boolean) : *

---@param ui UIObject
local function DisplayTalents_CC(ui, call, ...)
	if GameSettings.Default == nil then
		-- This function may run before the game is "Running" and the settings load normally.
		LoadGameSettings()
	end

	---@type EsvCharacter
	local player = nil
	local handle = ui:GetPlayerHandle()
	if handle ~= nil then
		player = Ext.GetCharacter(handle)
	elseif  Client.Character ~= nil then
		player = Client:GetCharacter()
	end
	if player ~= nil then
		local root = ui:GetRoot()
		local talent_mc = root.CCPanel_mc.talents_mc
		if Features.RacialTalentsDisplayFix then
			--local i = UI.GetArrayIndexStart(ui, "racialTalentArray", 2)
			for talent,text in pairs(TALENTS_RACIAL) do
				if player.Stats[talent] == true then
					local talentEnumName = string.gsub(talent, "TALENT_", "")
					local talentId = Data.TalentEnum[talentEnumName]
					if not UI.IsInArray(ui, "racialTalentArray", talentId, 0, 2) then
						talent_mc.addTalentElement(talentId, text.Value, true, false, true)
					end
				end
			end
		end
		if player.Stats.TALENT_RogueLoreDaggerBackStab or (GameSettings ~= nil and (GameSettings.Settings.BackstabSettings.Player.Enabled and GameSettings.Settings.BackstabSettings.Player.TalentRequired)) then
			if not UI.IsInArray(ui, "talentArray", Data.TalentEnum.RogueLoreDaggerBackStab, 1, 4) then
				talent_mc.addTalentElement(Data.TalentEnum.RogueLoreDaggerBackStab, TALENT_RogueLoreDaggerBackStab.Value, player.Stats.TALENT_RogueLoreDaggerBackStab, true, false)
			end
			-- local i = GetArrayIndexStart(ui, "talentArray", 4)
			-- local talentId = Data.TalentEnum["Backstab"]
			-- if not IsInArray(ui, "talentArray", talentId, 1, 4) then
			-- 	ui:SetValue("talentArray", talentId, i)
			-- 	ui:SetValue("talentArray", TALENT_Backstab.Value, i+1)
			-- 	ui:SetValue("talentArray", player.Stats.TALENT_Backstab, i+2)
			-- 	ui:SetValue("talentArray", true, i+3)
			-- end
			-- UI.PrintArray(ui, "talentArray")
		end
		TalentManager.Update_CC(ui, talent_mc, player)
	end
end

local function AddToCombatLog(text)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/combatLog.swf")
	if ui ~= nil then
		ui:Invoke("addTextToTab", 0, text)
	end
end

Ext.RegisterListener("SessionLoaded", function()
	-- Ext.RegisterUINameInvokeListener("setHPBars", PrintCall)
	-- Ext.RegisterUINameInvokeListener("updateInfos", PrintCall)
	-- Ext.RegisterUINameInvokeListener("setHPBars", PrintCall)
	-- Ext.RegisterUINameInvokeListener("setArmourBar", PrintCall)
	-- Ext.RegisterUINameInvokeListener("setMagicArmourBar", PrintCall)

	-- Ext.RegisterUINameCall("setArmourBar", function(...)
	-- 	if Features.HideMaxArmor then
	-- 		ModifyBarText(...)
	-- 	end
	-- end)
	-- Ext.RegisterUINameCall("setMagicArmourBar", function(...)
	-- 	if Features.HideMaxMagicArmor then
	-- 		ModifyBarText(...)
	-- 	end
	-- end)
	-- Ext.RegisterUINameCall("setHPBars", function(...)
	-- 	if Features.HideMaxMagicArmor then
	-- 		ModifyHealthText(...)
	-- 	end
	-- end)

	local ui = Ext.GetBuiltinUI("Public/Game/GUI/enemyHealthBar.swf")
	if ui ~= nil then
		Ext.RegisterUIInvokeListener(ui, "setArmourBar", function(...)
			if Features.HideArmor > 0 then
				ModifyBarText(PATTERNS[Features.HideArmor], ...)
			end
		end)
		Ext.RegisterUIInvokeListener(ui, "setMagicArmourBar", function(...)
			if Features.HideMagicArmor > 0 then
				ModifyBarText(PATTERNS[Features.HideMagicArmor], ...)
			end
		end)
		Ext.RegisterUIInvokeListener(ui, "setHPBars", function(...)
			if Features.HideVitality > 0 then
				ModifyHealthText(PATTERNS[Features.HideVitality], ...)
			end
		end)
	end
	Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", DisplayTalents)
	Ext.RegisterUITypeInvokeListener(Data.UIType.statsPanel_c, "updateArraySystem", DisplayTalents)

	--characterCreation.swf
	Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation, "updateTalents", DisplayTalents_CC)
	Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation_c, "updateTalents", DisplayTalents_CC)

	TalentManager.Gamepad.RegisterListeners()
end)