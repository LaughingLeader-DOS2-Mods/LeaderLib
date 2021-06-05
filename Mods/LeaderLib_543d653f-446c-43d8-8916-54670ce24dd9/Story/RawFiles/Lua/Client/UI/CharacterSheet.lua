local MessageData = Classes["MessageData"]

local pointAddedSound = "UI_Game_CharacterSheet_Attribute_Plus_Click_Release"

local lastHelmetState = {}

local function OnSetHelmetOptionState(ui, method, state)
	local character = GameHelpers.Client.GetCharacter()
	if character ~= nil then
		local id = character.NetID
		if id ~= nil and lastHelmetState[id] ~= state then
			local state = math.floor(state)
			local data = {
				NetID = id,
				State = state
			}
			Ext.PostMessageToServer("LeaderLib_OnHelmetToggled", Ext.JsonStringify(data))
			lastHelmetState[id] = state
		end
	end
end

local function FireCharacterSheetPointListeners(character, stat, statType)
	InvokeListenerCallbacks(Listeners.CharacterSheetPointChanged, character, stat, statType)
end

local function OnSheetEvent(ui, call, param1, ...)
	--local params = Common.FlattenTable({...})
	--PrintDebug("[LeaderLib_CharacterSheet.lua:OnSheetEvent] Event called. call("..tostring(call)..") params("..tostring(Common.Dump(params))..")")
	local character = GameHelpers.Client.GetCharacter()
	if call == "plusAbility" then
		local index = math.floor(param1)
		if index ~= nil then
			local stat = Data.Ability[index]
			PrintDebug(string.format("[LeaderLib_CharacterSheet.lua:OnSheetEvent:plusAbility] A point was added to the ability [%s](%s).", index, stat))
			local payload = Ext.JsonStringify({Stat=stat, NetID=character.NetID})
			Ext.PostMessageToServer("LeaderLib_CharacterSheet_AbilityChanged", payload)
			FireCharacterSheetPointListeners(character, stat, "ability")
		end
	elseif call == "plusStat" then
		local index = math.floor(param1)
		if index ~= nil then
			local stat = Data.Attribute[index]
			PrintDebug(string.format("[LeaderLib_CharacterSheet.lua:OnSheetEvent:plusStat] A point was added to the attribute [%s](%s).", index, stat))
			local payload = Ext.JsonStringify({Stat=stat, NetID=character.NetID})
			Ext.PostMessageToServer("LeaderLib_CharacterSheet_AttributeChanged", payload)
			FireCharacterSheetPointListeners(character, stat, "attribute")
		end
	elseif call == "hotbarBtnPressed" then
		local buttonID = math.floor(param1)
		if buttonID == ID.HOTBAR.CharacterSheet then
			Ext.PostMessageToServer("LeaderLib_CharacterSheet_StorePartyValues", "")
		end
	elseif call == "setHelmetOption" then
		local state = math.floor(param1)
		local data = {
			NetID = character.NetID,
			State = state
		}
		Ext.PostMessageToServer("LeaderLib_OnHelmetToggled", Ext.JsonStringify(data))
	end
end

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

---@param ui UIObject
local function OnCharacterSheetUpdating(ui)
	local main = ui:GetRoot()
	AbilityManager.OnCharacterSheetUpdating(ui, main, #main.ability_array > 0)

end

local function OnCharacterSheetUpdateDone(ui)
	local this = ui:GetRoot()
	if this.isGameMasterChar then
		this.stats_mc.setVisibilityStatButtons(true)
		this.stats_mc.setVisibilityAbilityButtons(true, true)
		this.stats_mc.setVisibilityAbilityButtons(false, true)
		this.stats_mc.setVisibilityTalentButtons(true)
	end
end

---@param ui UIObject
local function UpdateCharacterSheetPoints(ui, method, amount)
	if method == "setAvailableCombatAbilityPoints" or method == "setAvailableCivilAbilityPoints" then
		AbilityManager.UpdateCharacterSheetPoints(ui, method, ui:GetRoot(), amount)
	end
end

---@param ui UIObject
local function OnCharacterCreationUpdating(ui, method)
	AbilityManager.OnCharacterCreationUpdating(ui, method, ui:GetRoot())
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
	local data = GameSettings
	if GameSettings == nil or GameSettings.Loaded == false then
		-- This function may run before the game is "Running" and the settings load normally.
		data = LoadGameSettings()
	end
	if not Vars.ControllerEnabled then
		for i,v in pairs(pointEvents) do
			Ext.RegisterUITypeCall(Data.UIType.characterSheet, v, OnSheetEvent)
		end
		for i,v in pairs(sheetEvents) do
			Ext.RegisterUITypeCall(Data.UIType.characterSheet, v, OnSheetEvent)
		end
		Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", OnCharacterSheetUpdating)
		Ext.RegisterUITypeCall(Data.UIType.characterSheet, "characterSheetUpdateDone", OnCharacterSheetUpdateDone)
		Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "setAvailableStatPoints", UpdateCharacterSheetPoints)
		Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "setAvailableCombatAbilityPoints", UpdateCharacterSheetPoints)
		Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "setAvailableCivilAbilityPoints", UpdateCharacterSheetPoints)

		local function ResetAbilityPoints(ui, method, ...)
			UpdateCharacterSheetPoints(ui, "setAvailableCombatAbilityPoints", 0)
			UpdateCharacterSheetPoints(ui, "setAvailableCivilAbilityPoints", 0)
		end

		Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "setAvailableLabels", ResetAbilityPoints)
		Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "hideLevelUpAbilityButtons", ResetAbilityPoints)

		Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "setHelmetOptionState", OnSetHelmetOptionState)

		Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation, "updateAbilities", OnCharacterCreationUpdating)

		Ext.RegisterUITypeCall(Data.UIType.statusConsole, "GuardPressed", function(ui, call, ...)
			Ext.PostMessageToServer("LeaderLib_OnDelayTurnClicked", Client.Character.UUID)
			InvokeListenerCallbacks(Listeners.TurnDelayed, Client.Character.UUID)
		end)
	else
		Ext.RegisterUITypeInvokeListener(Data.UIType.statsPanel_c, "updateArraySystem", OnCharacterSheetUpdating)
		---@param ui UIObject
		---@param method string
		---@param pointType number One of 4 values: 0,1,2,3 | 0 = attribute, 1 = combat ability points, 2 = civil points, 3 = talent points
		Ext.RegisterUITypeInvokeListener(Data.UIType.statsPanel_c, "setStatPoints", function(ui, method, pointType, amountString)
			local points = tonumber(amountString)
			if pointType == 1 then
				UpdateCharacterSheetPoints(ui, "setAvailableCombatAbilityPoints", points)
			elseif pointType == 2 then
				UpdateCharacterSheetPoints(ui, "setAvailableCivilAbilityPoints", points)
			end
		end)
		Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation_c, "updateAbilities", OnCharacterCreationUpdating)
	end
end

Ext.RegisterListener("SessionLoaded", RegisterListeners)