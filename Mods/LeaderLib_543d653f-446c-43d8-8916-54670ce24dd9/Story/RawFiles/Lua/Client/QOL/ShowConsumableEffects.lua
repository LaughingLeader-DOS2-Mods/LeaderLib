local changedStats = {}
local hasStatChanges = false

Ext.Events.SessionLoaded:Subscribe(function (e)
	Game.Tooltip.RegisterRequestListener("Item", function (request, ui, uiType, event, id, ...)
		if request.ObjectHandleDouble then
			local settings = SettingsManager.GetMod(ModuleUUID)
			local gameSettings = GameSettingsManager.GetSettings()
			if settings.Global:FlagEquals("LeaderLib_ShowConsumableEffectsEnabled", true) and not gameSettings.Client.HideConsumableEffects then
				local item = GameHelpers.Client.TryGetItemFromDouble(request.ObjectHandleDouble)
				if item and item.StatsFromName then
					local statEntry = item.StatsFromName.StatsEntry
					local itemType = item.StatsFromName.ModifierListIndex
					-- 3 = Potion, 4 = Object
					if itemType == 3 and statEntry.UnknownBeforeConsume == "Yes" then
						changedStats[statEntry.Name] = true
						hasStatChanges = true
						statEntry.UnknownBeforeConsume = "No"
					end
				end
			end
		end
	end, "After")
end)

local function ResetStatChanges()
	if hasStatChanges then
		for statId,b in pairs(changedStats) do
			Ext.Stats.SetAttribute(statId, "UnknownBeforeConsume", "Yes")
		end
		changedStats = {}
		hasStatChanges = false
	end
end

Ext.RegisterUINameCall("hideTooltip", function (ui, event, ...)
	ResetStatChanges()
end, "Before")

Events.BeforeLuaReset:Subscribe(ResetStatChanges)

-- Events.ModSettingsChanged:Subscribe(function (e)
-- 	if e.Value == false then
-- 		ResetStatChanges()
-- 	end
-- end, {MatchArgs={ID="LeaderLib_ShowConsumableEffectsEnabled"}})