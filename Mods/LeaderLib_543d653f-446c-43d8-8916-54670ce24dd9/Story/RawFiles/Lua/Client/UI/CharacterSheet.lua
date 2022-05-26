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
			Ext.PostMessageToServer("LeaderLib_OnHelmetToggled", Common.JsonStringify(data))
			lastHelmetState[id] = state
		end
	end
end

local function FireCharacterSheetPointListeners(character, stat, statType)
	InvokeListenerCallbacks(Listeners.CharacterSheetPointChanged, character, stat, statType)
end

local hotBarButtons = {
	CharacterSheet = 1
}
local function OnSheetEvent(ui, call, param1, ...)
	local character = GameHelpers.Client.GetCharacter()
	if call == "plusAbility" then
		local index = math.floor(param1)
		if index ~= nil then
			local stat = Data.Ability[index]
			local payload = Common.JsonStringify({Stat=stat, NetID=character.NetID})
			Ext.PostMessageToServer("LeaderLib_CharacterSheet_AbilityChanged", payload)
			FireCharacterSheetPointListeners(character, stat, "ability")
		end
	elseif call == "plusStat" then
		local index = math.floor(param1)
		if index ~= nil then
			local stat = Data.Attribute[index]
			local payload = Common.JsonStringify({Stat=stat, NetID=character.NetID})
			Ext.PostMessageToServer("LeaderLib_CharacterSheet_AttributeChanged", payload)
			FireCharacterSheetPointListeners(character, stat, "attribute")
		end
	elseif call == "hotbarBtnPressed" then
		local buttonID = math.floor(param1)
		if buttonID == hotBarButtons.CharacterSheet then
			Ext.PostMessageToServer("LeaderLib_CharacterSheet_StorePartyValues", "")
		end
	elseif call == "setHelmetOption" then
		local state = math.floor(param1)
		local data = {
			NetID = GameHelpers.GetNetID(character),
			State = state
		}
		Ext.PostMessageToServer("LeaderLib_OnHelmetToggled", Common.JsonStringify(data))
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
		data = GameSettingsManager.Load(false)
	end
	if not Vars.ControllerEnabled then
		for i,v in pairs(pointEvents) do
			Ext.RegisterUITypeCall(Data.UIType.characterSheet, v, OnSheetEvent)
		end
		for i,v in pairs(sheetEvents) do
			Ext.RegisterUITypeCall(Data.UIType.characterSheet, v, OnSheetEvent)
		end
		--Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", OnCharacterSheetUpdating)

		Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "setHelmetOptionState", OnSetHelmetOptionState)

		--Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation, "updateAbilities", OnCharacterCreationUpdating)

		Ext.RegisterUITypeCall(Data.UIType.statusConsole, "GuardPressed", function(ui, call, ...)
			Ext.PostMessageToServer("LeaderLib_OnDelayTurnClicked", Client.Character.UUID)
			InvokeListenerCallbacks(Listeners.TurnDelayed, Client.Character.UUID)
		end)
	end
end
Ext.RegisterListener("SessionLoaded", RegisterListeners)