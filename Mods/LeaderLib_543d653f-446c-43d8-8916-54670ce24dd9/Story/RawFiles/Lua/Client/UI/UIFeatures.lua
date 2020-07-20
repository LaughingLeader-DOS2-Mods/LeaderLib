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

local function GetArrayIndexStart(ui, arrayName, checkType, offset)
	local i = 0
	while i < 9999 do
		local arrayValue = ui:GetValue(arrayName, checkType, i)
		if arrayValue == nil then
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
local function DisplayRacialTalents(ui, call, ...)
	---@type EsvCharacter
	local player = nil
	local handle = ui:GetPlayerHandle()
	if handle ~= nil then
		player = Ext.GetCharacter(handle)
	end
	if player ~= nil then
		local i = GetArrayIndexStart(ui, "talent_array", "string", 1)
		for talent,text in pairs(TALENTS_RACIAL) do
			if player.Stats[talent] == true then
				local talentEnumName = string.gsub(talent, "TALENT_", "")
				local talentId = Data.TalentEnum[talentEnumName]
				if not IsInArray(ui, "talent_array", talentId, 1, 2) then
					ui:SetValue("talent_array", text.Value, i)
					ui:SetValue("talent_array", talentId, i+1)
					ui:SetValue("talent_array", 0, i+2)
					i = i + 3
				end
			end
		end
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
				DisplayRacialTalents(...)
			end
		end)
	end
end)

Ext.RegisterNetListener("LeaderLib_EnableUIFeatures", function(call, featuresString)
	Features = Ext.JsonParse(featuresString)
end)