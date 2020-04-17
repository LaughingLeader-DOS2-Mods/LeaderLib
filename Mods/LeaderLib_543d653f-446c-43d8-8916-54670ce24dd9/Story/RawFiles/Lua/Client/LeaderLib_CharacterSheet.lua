local MessageData = LeaderLib.Classes["MessageData"]

local pointAddedSound = "UI_Game_CharacterSheet_Attribute_Plus_Click_Release"

local function OnSheetEvent(ui, call, ...)
	local params = LeaderLib.Common.FlattenTable({...})
	Ext.Print("[LeaderLib_CharacterSheet.lua:OnSheetEvent] Event called. call("..tostring(call)..") params("..tostring(LeaderLib.Common.Dump(params))..")")

	if call == "plusAbility" then
		local index = math.tointeger(params[1])
		if index ~= nil then
			local name = LeaderLib.Data.Ability[index]
			Ext.Print("[LeaderLib_CharacterSheet.lua:OnSheetEvent:plusAbility] A point was added to the ability ("..tostring(name)..")")
			Ext.PostMessageToServer("LeaderLib_GlobalMessage", MessageData:Create(LeaderLib.ID.MESSAGE.ABILITY_CHANGED, name))
		end
	elseif call == "plusStat" then
		local index = math.tointeger(params[1])
		if index ~= nil then
			local name = LeaderLib.Data.Attribute[index]
			Ext.Print("[LeaderLib_CharacterSheet.lua:OnSheetEvent:plusStat] A point was added to the attribute ("..tostring(name)..")")
			Ext.PostMessageToServer("LeaderLib_GlobalMessage", MessageData:Create(LeaderLib.ID.MESSAGE.ATTRIBUTE_CHANGED, name))
		end
	elseif call == "hotbarBtnPressed" then
		local buttonID = math.tointeger(params[1])
		if buttonID == LeaderLib.ID.HOTBAR.CharacterSheet then
			Ext.PostMessageToServer("LeaderLib_GlobalMessage", LeaderLib.ID.MESSAGE.STORE_PARTY_VALUES)
		end
	end
end

local sheetEvents = {
	"PlaySound",
	"minusAbility",
	"plusAbility",
	"minusSecStat",
	"plusSecStat",
	"minusStat",
	"plusStat",
	"minusTalent",
	"plusTalent",
	"minLevel",
	"getStats",
	"plusLevel",
	"minusCustomStat",
	"plusCustomStat",
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
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
	if ui ~= nil then
		for i,v in pairs(sheetEvents) do
			Ext.RegisterUICall(ui, v, OnSheetEvent)
		end
		Ext.Print("[LeaderLib_CharacterSheet.lua:RegisterListeners] Found (characterSheet.swf). Registered listeners.")
	else
		Ext.Print("[LeaderLib_CharacterSheet.lua:RegisterListeners] Failed to find Public/Game/GUI/characterSheet.swf")
	end

	-- Listen to the hotbar for when the sheet opens
	local hotbar = Ext.GetBuiltinUI("Public/Game/GUI/hotBar.swf")
	if hotbar ~= nil then
		Ext.RegisterUICall(hotbar, "hotbarBtnPressed", OnSheetEvent)
		Ext.Print("[LeaderLib_CharacterSheet.lua:RegisterListeners] Found (hotBar.swf). Registered listeners.")
	else
		Ext.Print("[LeaderLib_CharacterSheet.lua:RegisterListeners] Failed to find Public/Game/GUI/hotBar.swf")
	end
end

Ext.RegisterListener("SessionLoaded", RegisterListeners)