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
	elseif call == "selectCharacter" or call == "centerCamOnCharacter" then
		local id = params[1]
		if id ~= nil then
			local handle = Ext.DoubleToHandle(id)
			if handle ~= nil then
				local character = Ext.GetCharacter(handle)
				if character ~= nil then
					UI.ClientCharacter = character.MyGuid
				end
			end
		end
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
	if GameSettings == nil or GameSettings.Default == nil then
		-- This function may run before the game is "Running" and the settings load normally.
		data = LoadGameSettings()
	end
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
			for i,callback in pairs(Listeners.TurnDelayed) do
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