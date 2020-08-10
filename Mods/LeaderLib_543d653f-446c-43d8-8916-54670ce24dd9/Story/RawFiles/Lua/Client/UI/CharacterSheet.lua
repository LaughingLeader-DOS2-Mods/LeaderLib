local MessageData = Classes["MessageData"]

local pointAddedSound = "UI_Game_CharacterSheet_Attribute_Plus_Click_Release"

local function OnSheetEvent(ui, call, ...)
	local params = Common.FlattenTable({...})
	--PrintDebug("[LeaderLib_CharacterSheet.lua:OnSheetEvent] Event called. call("..tostring(call)..") params("..tostring(Common.Dump(params))..")")

	if call == "plusAbility" then
		local index = math.tointeger(params[1])
		if index ~= nil then
			local name = Data.Ability[index]
			PrintDebug(string.format("[LeaderLib_CharacterSheet.lua:OnSheetEvent:plusAbility] A point was added to the ability [%s](%s).", index, name))
			Ext.PostMessageToServer("LeaderLib_GlobalMessage", MessageData:Create(ID.MESSAGE.ABILITY_CHANGED, name):ToString())
		end
	elseif call == "plusStat" then
		local index = math.tointeger(params[1])
		if index ~= nil then
			local name = Data.Attribute[index]
			PrintDebug(string.format("[LeaderLib_CharacterSheet.lua:OnSheetEvent:plusStat] A point was added to the attribute [%s](%s).", index, name))
			Ext.PostMessageToServer("LeaderLib_GlobalMessage", MessageData:Create(ID.MESSAGE.ATTRIBUTE_CHANGED, name):ToString())
		end
	elseif call == "hotbarBtnPressed" then
		local buttonID = math.tointeger(params[1])
		if buttonID == ID.HOTBAR.CharacterSheet then
			Ext.PostMessageToServer("LeaderLib_GlobalMessage", ID.MESSAGE.STORE_PARTY_VALUES)
		end
	end
end

local combatAbilityGroupID = {
	[0] = "Weapons",
	[1] = "Defense",
	[2] = "Skills",
}

local civilAbilityGroupID = {
	[0] = "Personality",
	[1] = "Craftsmanship",
	[2] = "Nasty Deeds",
}

local missingAbilities = {
	Shield = {Group=0, Civil=false},
	Reflexes = {Group=1, Civil=false},
	PhysicalArmorMastery = {Group=1, Civil=false},
	Sourcery = {Group=2, Civil=false},
	Sulfurology = {Group=2, Civil=false},
	Repair = {Group=1, Civil=true},
	Crafting = {Group=1, Civil=true},
	Charm = {Group=3, Civil=true},
	Intimidate = {Group=3, Civil=true},
	Reason = {Group=3, Civil=true},
	Wand = {Group=0, Civil=false},
	MagicArmorMastery = {Group=1, Civil=false},
	VitalityMastery = {Group=1, Civil=false},
	Runecrafting = {Group=4, Civil=true},
	Brewmaster = {Group=4, Civil=true},
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

--[[ 
ability_array Mapping:
0 = isCivilAbility:boolean
1 = groupId:number, 
2 = statId:number
3 = displayName:string
4 = valueText:string
5 = addTooltipText:string
6 = removeTooltipText:string
]]

---@param ui UIObject
local function addMissingAbilities(ui)
	local i = GetArrayIndexStart(ui, "ability_array", "boolean", 7)
	if i > -1 then
		local total = 0
		for abilityName,data in pairs(missingAbilities) do
			local abilityID = Data.AbilityEnum[abilityName]
			ui:SetValue("ability_array", data.Civil, i) -- isCivilAbility
			ui:SetValue("ability_array", data.Group, i+1) -- groupId
			ui:SetValue("ability_array", abilityID, i+2) -- statId
			ui:SetValue("ability_array", GameHelpers.GetAbilityName(abilityName), i+3) -- displayName
			ui:SetValue("ability_array", Ext.Random(1,10), i+4) -- valueText
			ui:SetValue("ability_array", LocalizedText.AbilityPlusTooltip.UI.Value:gsub("%[1%]", Ext.ExtraData.CombatAbilityLevelGrowth), i+5) -- addTooltipText
			ui:SetValue("ability_array", "", i+6) -- removeTooltipText
			--PrintDebug(string.format("[LeaderLib:addMissingAbilities] Added ability [%s] = (%s)", abilityID, abilityName))
			i = i + 7
			total = total + 1
		end
		PrintDebug(string.format("[LeaderLib:addMissingAbilities] Added abilities to the character sheet. i[%s] Total(%s)", i, total))
	else
		Ext.PrintError("[LeaderLib:addMissingAbilities] Failed to finding starting index for ability_array!")
	end
end

--[[ 
Array Mapping:
0 - hasPoints:boolean
1 = isCivilAbility:boolean
2 = groupId:number, 
3 = statId:number
4 = isVisible:boolean
]]
---@param ui UIObject
---@param hasPoints boolean
local function toggleAbilityButtonVisibility(ui, hasPoints)
	local i = GetArrayIndexStart(ui, "lvlBtnAbility_array", "boolean", 5)
	if i > -1 then
		for abilityName,data in pairs(missingAbilities) do
			local abilityID = Data.AbilityEnum[abilityName]
			ui:SetValue("lvlBtnAbility_array", true, i) -- hasPoints
			ui:SetValue("lvlBtnAbility_array", data.Civil, i+1) -- isCivilAbility
			ui:SetValue("lvlBtnAbility_array", data.Group, i+2) -- groupId
			ui:SetValue("lvlBtnAbility_array", abilityID, i+3) -- statId
			ui:SetValue("lvlBtnAbility_array", true, i+4) -- isVisible
			--PrintDebug(string.format("[LeaderLib:addMissingAbilities] Enabled point button for [%s] = (%s)", abilityID, abilityName))
			i = i + 5
		end
	else
		Ext.PrintError("[LeaderLib:addMissingAbilities] Failed to finding starting index for ability_array!")
	end
end

---@param ui UIObject
local function OnCharacterSheetUpdating(ui)
	local arrayValueSet = ui:GetValue("ability_array", "boolean", 0)
	if arrayValueSet ~= nil then
		addMissingAbilities(ui)
	end
	local hasPoints = ui:GetValue("lvlBtnAbility_array", "boolean", 0)
	if hasPoints ~= nil then
		toggleAbilityButtonVisibility(ui)
	end
end

local pointEvents = {
	"minusAbility",
	"plusAbility",
	"minusSecStat",
	"plusSecStat",
	"minusStat",
	"plusStat",
	"minusTalent",
	"plusTalent",
	"minLevel",
	"plusLevel",
	"minusCustomStat",
	"plusCustomStat",
}

local sheetEvents = {
	--"PlaySound",
	"getStats",
	"editCustomStat",
	"removeCustomStat",
	"selectCharacter",
	"UnlearnSkill",
	"slotUp",
	"slotDown",
	"getItemList",
	"openContextMenu",
	"doubleClickItem",
	"setHelmetOption",
	"selectOption",
	"stopDragging",
	"closeCharacterUIs",
	--"clearAnchor",
	--"hideTooltip",
	"hideUI",
	--"inputFocus",
	--"inputFocusLost",
	--"keepUIinScreen",
	--"onClearInventory",
	--"onGenerateTreasure",
	--"openContextMenu",
	--"registerAnchorId",
	--"setAnchor",
	--"setMcSize",
	"setPosition",
	--"showCustomStatTooltip",
	--"showStatTooltip",
	--"showTalentTooltip",
	--"UIAssert",
	--"unregisterAnchorId",
}

local function RegisterListeners()
	---@type LeaderLibGameSettings
	local data = LoadGameSettings()
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
	if ui ~= nil then
		for i,v in pairs(pointEvents) do
			Ext.RegisterUICall(ui, v, OnSheetEvent)
		end
		for i,v in pairs(sheetEvents) do
			Ext.RegisterUICall(ui, v, OnSheetEvent)
		end
		if data.Settings.EnableDeveloperTests == true and Ext.IsDeveloperMode() then
			Ext.RegisterUIInvokeListener(ui, "updateArraySystem", OnCharacterSheetUpdating)
		end
		PrintDebug("[LeaderLib_CharacterSheet.lua:RegisterListeners] Found (characterSheet.swf). Registered listeners.")
	else
		PrintDebug("[LeaderLib_CharacterSheet.lua:RegisterListeners] Failed to find Public/Game/GUI/characterSheet.swf")
	end

	-- local ui = Ext.GetBuiltinUI("Public/Game/GUI/statusConsole.swf")
	-- if ui ~= nil then
	-- 	---@param ui UIObject
	-- 	Ext.RegisterUICall(ui, "GuardPressed", function(ui, call, ...)
	-- 		print("GuardPressed", ui:GetTypeId(), Ext.JsonStringify({...}))
	-- 	end)
	-- end
	-- When the delay turn button is clicked
	Ext.RegisterUITypeCall(117, "GuardPressed", function(ui, call, ...)
		Ext.PostMessageToServer("LeaderLib_OnDelayTurnClicked", UI.ClientCharacter)
		if #Listeners.TurnDelayed > 0 then
			for i,callback in ipairs(Listeners.TurnDelayed) do
				local status,err = xpcall(callback, debug.traceback, UI.ClientCharacter)
				if not status then
					Ext.PrintError("Error calling function for 'TurnDelayed':\n", err)
				end
			end
		end
	end)
	-- Listen to the hotbar for when the sheet opens
	--[[ local hotbar = Ext.GetBuiltinUI("Public/Game/GUI/hotBar.swf")
	if hotbar ~= nil then
		Ext.RegisterUICall(hotbar, "hotbarBtnPressed", OnSheetEvent)
		Ext.RegisterUICall(hotbar, "PlaySound", OnSheetEvent)
		PrintDebug("[LeaderLib_CharacterSheet.lua:RegisterListeners] Found (hotBar.swf). Registered listeners.")
	else
		PrintDebug("[LeaderLib_CharacterSheet.lua:RegisterListeners] Failed to find Public/Game/GUI/hotBar.swf")
	end ]]
	--[[ local characterCreation = Ext.GetBuiltinUI("Public/Game/GUI/characterCreation.swf")
	if characterCreation ~= nil then
		Ext.RegisterUICall(characterCreation, "selectOption", OnSheetEvent)
		for i,v in pairs(pointEvents) do
			Ext.RegisterUICall(characterCreation, v, OnSheetEvent)
		end
		PrintDebug("[LeaderLib_CharacterSheet.lua:RegisterListeners] Found (characterCreation.swf). Registered listeners.")
	else
		PrintDebug("[LeaderLib_CharacterSheet.lua:RegisterListeners] Failed to find Public/Game/GUI/characterCreation.swf")
	end ]]
end

Ext.RegisterListener("SessionLoaded", RegisterListeners)