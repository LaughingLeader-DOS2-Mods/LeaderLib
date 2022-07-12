--[[ 
local hotBarButtons = {
	CharacterSheet = 1
}
if call == "hotbarBtnPressed" then
	local buttonID = math.floor(param1)
	if buttonID == hotBarButtons.CharacterSheet then
		Ext.PostMessageToServer("LeaderLib_CharacterSheet_StorePartyValues", "")
	end
end
]]

Ext.RegisterUITypeCall(Data.UIType.characterSheet, "plusStat", function (ui, event, id)
	if not GameHelpers.Math.IsNaN(id) then
		local stat = Data.Attribute[id]
		local character = GameHelpers.Client.GetCharacter()
		if stat and character then
			Events.CharacterSheetPointChanged:Invoke({Character = character, Stat = stat, StatType = "Attribute"})
			Ext.PostMessageToServer("LeaderLib_CharacterSheet_PointsChanged", "")
		end
	end
end)

Ext.RegisterUITypeCall(Data.UIType.characterSheet, "plusAbility", function (ui, event, id)
	if not GameHelpers.Math.IsNaN(id) then
		local stat = Data.Attribute[id]
		local character = GameHelpers.Client.GetCharacter()
		if stat and character then
			Events.CharacterSheetPointChanged:Invoke({Character = character, Stat = stat, StatType = "Ability"})
			Ext.PostMessageToServer("LeaderLib_CharacterSheet_PointsChanged", "")
		end
	end
end)

Ext.RegisterUITypeCall(Data.UIType.characterSheet, "plusTalent", function (ui, event, id)
	if not GameHelpers.Math.IsNaN(id) then
		local stat = Data.Attribute[id]
		local character = GameHelpers.Client.GetCharacter()
		if stat and character then
			Events.CharacterSheetPointChanged:Invoke({Character = character, Stat = stat, StatType = "Attribute"})
			Ext.PostMessageToServer("LeaderLib_CharacterSheet_PointsChanged", "")
		end
	end
end)

local lastHelmetState = {}

local function OnSetHelmetOptionState(ui, method, state)
	if not GameHelpers.Math.IsNaN(state) then
		local character = GameHelpers.Client.GetCharacter()
		if character ~= nil then
			local id = character.NetID
			local state = math.floor(state)
			if id ~= nil and lastHelmetState[id] ~= state then
				local data = {
					NetID = id,
					State = state
				}
				Ext.PostMessageToServer("LeaderLib_OnHelmetToggled", Common.JsonStringify(data))
				lastHelmetState[id] = state
			end
		end
	end
end

Ext.RegisterUITypeCall(Data.UIType.characterSheet, "setHelmetOptionState", OnSetHelmetOptionState)
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "setHelmetOption", OnSetHelmetOptionState)

Ext.RegisterUITypeCall(Data.UIType.statusConsole, "GuardPressed", function(ui, call, ...)
	local character = GameHelpers.Client.GetCharacter()
	if character then
		Ext.PostMessageToServer("LeaderLib_OnDelayTurnClicked", tostring(character.NetID))
		Events.TurnDelayed:Invoke({UUID = GameHelpers.GetUUID(character) or Client.Character.UUID, Character=character})
	end
end)