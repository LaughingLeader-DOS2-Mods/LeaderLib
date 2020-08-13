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

local function GetArrayIndexStart(ui, arrayName, offset)
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

local function IsInArray(ui, arrayName, id, start, offset)
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
	else
		player = Ext.GetCharacter(UI.ClientCharacter)
	end
	if player ~= nil then
		local root = ui:GetRoot()
		local i = GetArrayIndexStart(ui, "talent_array", 3)
		if Features.RacialTalentsDisplayFix then
			for talent,text in pairs(TALENTS_RACIAL) do
				if player.Stats[talent] == true then
					local talentEnumName = string.gsub(talent, "TALENT_", "")
					local talentId = Data.TalentEnum[talentEnumName]
					if not IsInArray(ui, "talent_array", talentId, 1, 3) then
						--UI.PrintArray(ui, "talent_array")
						--print("Added talent to array", talent, player.Stats[talent], talentEnumName, talentId, text.Value)
						ui:SetValue("talent_array", text.Value, i)
						ui:SetValue("talent_array", talentId, i+1)
						ui:SetValue("talent_array", 0, i+2)
						i = i + 3
					end
				end
			end
		end
		if player.Stats.TALENT_RogueLoreDaggerBackStab or (GameSettings.Settings.BackstabSettings.Player.Enabled and GameSettings.Settings.BackstabSettings.Player.TalentRequired) then
			 -- Backstab doesn't have an icon check set, while this RogueLoreDaggerBackStab does
			--local talentEnumName = "RogueLoreDaggerBackStab" -- "Backstab"
			if not IsInArray(ui, "talent_array", Data.TalentEnum.RogueLoreDaggerBackStab, 1, 3) then
				ui:SetValue("talent_array", TALENT_RogueLoreDaggerBackStab.Value, i)
				ui:SetValue("talent_array", Data.TalentEnum.RogueLoreDaggerBackStab, i+1)
				if player.Stats.TALENT_RogueLoreDaggerBackStab then
					ui:SetValue("talent_array", 0, i+2)
				else
					ui:SetValue("talent_array", 2, i+2)
				end
			end
			-- local talentPoints = root.stats_mc.pointsWarn[3].avPoints;
			-- print("talentPoints", talentPoints, player.Stats.TALENT_RogueLoreDaggerBackStab, #root.lvlBtnTalent_array)
			-- if player.Stats.TALENT_RogueLoreDaggerBackStab then
			-- 	if #root.lvlBtnTalent_array > 0 then
			-- 		for i=1,#root.lvlBtnTalent_array,3 do
			-- 			print(i, root.lvlBtnTalent_array[i+1])
			-- 			if root.lvlBtnTalent_array[i+1] == Data.TalentEnum.RogueLoreDaggerBackStab then
			-- 				print("root.lvlBtnTalent_array", root.lvlBtnTalent_array[i], root.lvlBtnTalent_array[i+1], root.lvlBtnTalent_array[i+2])
			-- 				ui:SetValue("lvlBtnTalent_array", false, i+2)
			-- 			end
			-- 		end
			-- 	else
			-- 		root.setTalentMinusVisible(Data.TalentEnum.RogueLoreDaggerBackStab, true)
			-- 		ui:SetValue("lvlBtnTalent_array", false, 0)
			-- 		ui:SetValue("lvlBtnTalent_array", Data.TalentEnum.RogueLoreDaggerBackStab, 1)
			-- 		ui:SetValue("lvlBtnTalent_array", true, 2)
			-- 		print("lvlBtnTalent_array", #root.lvlBtnTalent_array)
			-- 	end
			-- 	--root.setTalentMinusVisible(Data.TalentEnum.RogueLoreDaggerBackStab, true);
			-- end
			-- print("root.lvlBtnTalent_array", root.lvlBtnTalent_array[0], #root.lvlBtnTalent_array)
			-- for i=1,#root.lvlBtnTalent_array,1 do
			-- 	print(i, root.lvlBtnTalent_array[i])
			-- end
			-- local hasPoints = root.lvlBtnTalent_array[0] == true
			-- if hasPoints then
			-- 	local talentIsInArray = false
			-- 	local i = #root.lvlBtnTalent_array - 1
			-- 	for i=1,#root.lvlBtnTalent_array,2 do
			-- 		print(i, root.lvlBtnTalent_array[i])
			-- 		if root.lvlBtnTalent_array[i] == Data.TalentEnum.RogueLoreDaggerBackStab then
			-- 			talentIsInArray = true
			-- 			break
			-- 		end
			-- 	end
			-- 	if not talentIsInArray then
			-- 		ui:SetValue("lvlBtnTalent_array", Data.TalentEnum.RogueLoreDaggerBackStab, i)
			-- 		ui:SetValue("lvlBtnTalent_array", player.Stats.TALENT_RogueLoreDaggerBackStab, i+1)
			-- 	end
			-- end
		end
	end
end

-- addTalentElement(talentId:uint, talentName:String, state:Boolean, choosable:Boolean, isRacial:Boolean) : *

---@param ui UIObject
local function DisplayTalents_CC(ui, call, ...)
	---@type EsvCharacter
	local player = nil
	local handle = ui:GetPlayerHandle()
	if handle ~= nil then
		player = Ext.GetCharacter(handle)
	else
		player = Ext.GetCharacter(UI.ClientCharacter)
	end
	if player ~= nil then
		local root = ui:GetRoot()
		local talent_mc = root.CCPanel_mc.talents_mc
		if Features.RacialTalentsDisplayFix then
			--local i = GetArrayIndexStart(ui, "racialTalentArray", 2)
			for talent,text in pairs(TALENTS_RACIAL) do
				if player.Stats[talent] == true then
					local talentEnumName = string.gsub(talent, "TALENT_", "")
					local talentId = Data.TalentEnum[talentEnumName]
					if not IsInArray(ui, "racialTalentArray", talentId, 0, 2) then
						talent_mc.addTalentElement(talentId, text.Value, true, false, true)
					end
				end
			end
		end
		if player.Stats.TALENT_RogueLoreDaggerBackStab or (GameSettings.Settings.BackstabSettings.Player.Enabled and GameSettings.Settings.BackstabSettings.Player.TalentRequired) then
			if not IsInArray(ui, "talentArray", Data.TalentEnum.RogueLoreDaggerBackStab, 1, 4) then
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
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
	if ui ~= nil then
		---@param ui UIObject
		Ext.RegisterUIInvokeListener(ui, "updateArraySystem", function(...)
			if Features.RacialTalentsDisplayFix then
				DisplayTalents(...)
			end
		end)
	end

	--characterCreation.swf
	Ext.RegisterUITypeInvokeListener(3, "updateTalents", function(...)
		if Features.RacialTalentsDisplayFix then
			DisplayTalents_CC(...)
		end
	end)
end)