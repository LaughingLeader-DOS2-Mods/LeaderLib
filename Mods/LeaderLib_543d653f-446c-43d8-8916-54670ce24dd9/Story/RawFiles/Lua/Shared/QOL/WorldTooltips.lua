local WorldTooltips = {
	TooltipMode = 2, -- World and Hover
	UpdateDelay = 2000
}

if Ext.IsClient() then
	--Unused since setting RootTemplate.Tooltip on the server makes the client update as well.
	if Vars.DebugMode then
		function WorldTooltips.OnUpdate(ui, event, removeNotUpdated)
			-- if Input.IsPressed(Data.Input.ShowWorldTooltips) then
			-- 	--local player = Client:GetCharacter()
			-- 	local this = ui:GetRoot()
			-- 	local arr = this.worldTooltip_array
			-- 	for i=0,#arr-1 do
			-- 		PrintDebug("worldTooltip_array", i, arr[i])
			-- 	end
			-- 	arr = this.repos_array
			-- 	for i=0,#arr-1 do
			-- 		PrintDebug("repos_array", i, arr[i])
			-- 	end
			-- end
		end
		
		--Ext.RegisterUITypeInvokeListener(Data.UIType.worldTooltip, "updateTooltips", WorldTooltips.OnUpdate)
	
		function WorldTooltips.UpdateItems(cmd, payload)
			local ids = Common.JsonParse(payload)
			if ids then
				for i=1,#ids do
					local item = Ext.GetItem(ids[i])
					if item and item.RootTemplate then
						if item.RootTemplate.Tooltip ~= WorldTooltips.TooltipMode then
							item.RootTemplate.Tooltip = WorldTooltips.TooltipMode
						end
					end
				end
			end
		end
		Ext.RegisterNetListener("LeaderLib_WorldTooltips_UpdateClient", WorldTooltips.UpdateItems)
	end
else
	---@param item EsvItem
	local function ShouldHaveTooltip(item)
		if item.RootTemplate and item.RootTemplate.Tooltip ~= WorldTooltips.TooltipMode and not StringHelpers.IsNullOrWhitespace(item.DisplayName) then
			return true
		end
		return false
	end

	function WorldTooltips.UpdateWorldItems()
		--Don't try and modify items during Sync/etc
		if Ext.GetGameState() == "Running" then
			if SettingsManager.GetMod(ModuleUUID).Global:FlagEquals("LeaderLib_AllTooltipsForItemsEnabled", true) then
				local time = Ext.MonotonicTime()
				for _,uuid in pairs(Ext.GetAllItems()) do
					local item = Ext.GetItem(uuid)
					if item and ShouldHaveTooltip(item) then
						item.RootTemplate.Tooltip = WorldTooltips.TooltipMode
					end
				end
				if Vars.LeaderDebugMode then
					fprint(LOGLEVEL.DEFAULT, "[LeaderLib:WorldTooltips.UpdateWorldItems] World tooltip updating took (%s) ms.", Ext.MonotonicTime()-time)
				end
			end
		end
	end

	function WorldTooltips.OnGameStarted(region, editorMode)
		Timer.StartOneshot("Timers_LeaderLib_WorldTooltips_UpdateItems", WorldTooltips.UpdateDelay, WorldTooltips.UpdateWorldItems)
	end

	function UpdateWorldTooltips()
		Timer.StartOneshot("Timers_LeaderLib_WorldTooltips_UpdateItems", WorldTooltips.UpdateDelay, WorldTooltips.UpdateWorldItems)
	end

	---@param item EsvItem
	function WorldTooltips.OnItemEnteredWorld(item, region)
		if item and ShouldHaveTooltip(item) then
			--print("SERVER", item.DisplayName, item.RootTemplate.Tooltip)
			item.RootTemplate.Tooltip = WorldTooltips.TooltipMode
		end
	end

	Ext.RegisterOsirisListener("ItemEnteredRegion", Data.OsirisEvents.ItemEnteredRegion, "after", function(uuid, region)
		--Sync state safety
		if Ext.GetGameState() == "Running" 
		and SharedData.RegionData.State == REGIONSTATE.GAME
		and SettingsManager.GetMod(ModuleUUID).Global:FlagEquals("LeaderLib_AllTooltipsForItemsEnabled", true)
		then
			local item = GameHelpers.GetItem(uuid)
			if item and not StringHelpers.IsNullOrEmpty(item.CurrentLevel) then
				WorldTooltips.OnItemEnteredWorld(item, region)
			end
		end
	end)

	Ext.RegisterOsirisListener("GameStarted", Data.OsirisEvents.GameStarted, "after", WorldTooltips.OnGameStarted)
	if Vars.DebugMode then
		Events.LuaReset:Subscribe(function(e)
			WorldTooltips.UpdateWorldItems()
		end)
	end
end

Ext.RegisterConsoleCommand("llwtipper", function(cmd, param, val)
	if param == "mode" then
		WorldTooltips.TooltipMode = tonumber(val or "2") or 2
		WorldTooltips.UpdateWorldItems()
	end
end)