local WorldTooltipper = {
	TooltipMode = 2,
	UpdateDelay = 2000
}
WorldTooltipper.__index = WorldTooltipper

if Ext.IsClient() then
	function WorldTooltipper.OnUpdate(ui, event, removeNotUpdated)
		if Input.IsPressed(Data.Input.ShowWorldTooltips) then
			--local player = Client:GetCharacter()
			local this = ui:GetRoot()
			local arr = this.worldTooltip_array
			for i=0,#arr-1 do
				print("worldTooltip_array", i, arr[i])
			end
			arr = this.repos_array
			for i=0,#arr-1 do
				print("repos_array", i, arr[i])
			end
		end
	end
	
	--Ext.RegisterUITypeInvokeListener(Data.UIType.worldTooltip, "updateTooltips", WorldTooltipper.OnUpdate)

	function WorldTooltipper.UpdateItems(cmd, payload)
		local ids = Common.JsonParse(payload)
		if ids then
			for i=1,#ids do
				local item = Ext.GetItem(ids[i])
				if item then
					print("CLIENT", item.DisplayName, item.RootTemplate.Tooltip)
					if item.RootTemplate.Tooltip ~= WorldTooltipper.TooltipMode then
						item.RootTemplate.Tooltip = WorldTooltipper.TooltipMode
					end
				end
			end
		end
	end
	Ext.RegisterNetListener("LeaderLib_WorldTooltipper_UpdateClient", WorldTooltipper.UpdateItems)
else
	---@param item EsvItem
	local function ShouldHaveTooltip(item)
		if item.RootTemplate and item.RootTemplate.Tooltip ~= WorldTooltipper.TooltipMode and not StringHelpers.IsNullOrWhitespace(item.DisplayName) then
			return true
		end
		return false
	end

	function WorldTooltipper.UpdateWorldItems()
		if SettingsManager.GetMod("7e737d2f-31d2-4751-963f-be6ccc59cd0c").Global:FlagEquals("LeaderLib_AllTooltipsForItemsEnabled", true) then
			local time = Ext.MonotonicTime()
			for _,uuid in pairs(Ext.GetAllItems()) do
				local item = Ext.GetItem(uuid)
				if item and ShouldHaveTooltip(item) then
					item.RootTemplate.Tooltip = WorldTooltipper.TooltipMode
				end
			end
			fprint(LOGLEVEL.DEFAULT, "[LeaderLib:WorldTooltips.UpdateWorldItems] World tooltip updating took (%s) ms.", Ext.MonotonicTime()-time)
		end
	end

	function WorldTooltipper.OnGameStarted(region, editorMode)
		Timer.StartOneshot("Timers_LeaderLib_WorldTooltipper_UpdateItems", WorldTooltipper.UpdateDelay, WorldTooltipper.UpdateWorldItems)
	end

	function UpdateWorldTooltips()
		Timer.StartOneshot("Timers_LeaderLib_WorldTooltipper_UpdateItems", WorldTooltipper.UpdateDelay, WorldTooltipper.UpdateWorldItems)
	end

	---@param item EsvItem
	function WorldTooltipper.OnItemEnteredWorld(item, region)
		if item and ShouldHaveTooltip(item) then
			--print("SERVER", item.DisplayName, item.RootTemplate.Tooltip)
			item.RootTemplate.Tooltip = WorldTooltipper.TooltipMode
		end
	end

	Ext.RegisterOsirisListener("ItemEnteredRegion", Data.OsirisEvents.ItemEnteredRegion, "after", function(uuid, region)
		if SettingsManager.GetMod("7e737d2f-31d2-4751-963f-be6ccc59cd0c").Global:FlagEquals("LeaderLib_AllTooltipsForItemsEnabled", true) then
			WorldTooltipper.OnItemEnteredWorld(Ext.GetItem(uuid), region)
		end
	end)

	Ext.RegisterOsirisListener("GameStarted", Data.OsirisEvents.GameStarted, "after", WorldTooltipper.OnGameStarted)
	if Vars.DebugMode then
		RegisterListener("LuaReset", WorldTooltipper.UpdateWorldItems)
	end
end

Ext.RegisterConsoleCommand("llwtipper", function(cmd, param, val)
	if param == "mode" then
		WorldTooltipper.TooltipMode = tonumber(val or "2") or 2
		WorldTooltipper.UpdateWorldItems()
	end
end)