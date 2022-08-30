local _EXTVERSION = Ext.Utils.Version()

local WorldTooltips = {
	TooltipMode = 2, -- World and Hover
	UpdateDelay = 2000
}
QOL.WorldTooltips = WorldTooltips

function WorldTooltips:IsEnabled()
	return GameHelpers.IsLevelType(LEVELTYPE.GAME) and SettingsManager.GetMod(ModuleUUID).Global:FlagEquals("LeaderLib_AllTooltipsForItemsEnabled", true)
end

if Ext.IsClient() then
	function WorldTooltips:UpdateItems(cmd, payload)
		local ids = Common.JsonParse(payload)
		if ids then
			for i=1,#ids do
				local item = GameHelpers.GetItem(ids[i])
				if item and item.RootTemplate then
					item.RootTemplate.Tooltip = WorldTooltips.TooltipMode
				end
			end
		end
	end
	Ext.RegisterNetListener("LeaderLib_WorldTooltips_UpdateClient", function(...) WorldTooltips:UpdateItems(...) end)
else
	---@param item EsvItem
	---@param force boolean|nil Skip the Tooltip ~= 2 check to update the client.
	local function _ShouldHaveTooltip(item, force)
		if item.RootTemplate and (item.RootTemplate.Tooltip ~= WorldTooltips.TooltipMode or force) and not StringHelpers.IsNullOrWhitespace(GameHelpers.GetDisplayName(item)) then
			return true
		end
		return false
	end

	---@return EsvItem[]
	local function _GetAllItems()
		local items = {}
		if _EXTVERSION < 57 then
			for i,v in pairs(Ext.Entity.GetAllItemGuids()) do
				local item = GameHelpers.GetItem(v)
				if item then
					items[#items+1] = item
				end
			end
			return items
		else
			local level = Ext.Entity.GetCurrentLevel()
			if level then
				return level.EntityManager.ItemConversionHelpers.RegisteredItems[level.LevelDesc.LevelName]
			end
		end
		return items
	end

	local _ValidUpdateStates = {
		Running = true,
		Paused = true,
		GameMasterPause = true,
	}

	---@param forceResync boolean|nil Force the client to update.
	function WorldTooltips.UpdateWorldItems(forceResync)
		Timer.Cancel("Timers_LeaderLib_WorldTooltips_UpdateItems")

		--Don't try and modify items during Sync/etc
		if _ValidUpdateStates[Ext.GetGameState()] and WorldTooltips:IsEnabled() then
			local time = Ext.Utils.MonotonicTime()
			local updateDataLen = 0
			local updateData = {}
			if not forceResync then
				forceResync = Vars.LeaderDebugMode
			end
			for _,item in pairs(_GetAllItems()) do
				if _ShouldHaveTooltip(item, forceResync) then
					updateDataLen = updateDataLen + 1
					updateData[updateDataLen] = item.NetID
					item.RootTemplate.Tooltip = WorldTooltips.TooltipMode
				end
				if item.MyGuid == "01adffd4-26f1-4aaa-a450-25b38804f5e2" then
					Ext.PrintError("Vase.RootTemplate.Tooltip:", item.RootTemplate.Tooltip)
				end
			end
			if updateDataLen > 0 then
				if Vars.LeaderDebugMode then
					fprint(LOGLEVEL.DEFAULT, "[LeaderLib:WorldTooltips.UpdateWorldItems] World tooltip updating took (%s) ms.", Ext.Utils.MonotonicTime()-time)
				end
				GameHelpers.Net.Broadcast("LeaderLib_WorldTooltips_UpdateClient", updateData)
			end
		end
	end

	---@param item EsvItem
	function WorldTooltips:OnItemEnteredWorld(item)
		if item and item.CurrentLevel ~= "" and _ShouldHaveTooltip(item) then
			item.RootTemplate.Tooltip = WorldTooltips.TooltipMode
			GameHelpers.Net.Broadcast("LeaderLib_WorldTooltips_UpdateClient", {item.NetID})
		end
	end

	Ext.Osiris.RegisterListener("ItemEnteredRegion", Data.OsirisEvents.ItemEnteredRegion, "after", function(uuid, region)
		--Sync state safety
		if Ext.GetGameState() == "Running" and WorldTooltips:IsEnabled() then
			WorldTooltips:OnItemEnteredWorld(GameHelpers.GetItem(uuid))
		end
	end)

	---@param forceResync boolean|nil
	---@param delayOverride integer|nil
	function WorldTooltips:StartTimer(forceResync, delayOverride)
		Timer.Cancel("Timers_LeaderLib_WorldTooltips_UpdateItems")
		Timer.StartOneshot("Timers_LeaderLib_WorldTooltips_UpdateItems", delayOverride or WorldTooltips.UpdateDelay, function (e)
			WorldTooltips.UpdateWorldItems(forceResync == true)
		end)
	end

	Events.RegionChanged:Subscribe(function (e)
		if e.LevelType == LEVELTYPE.GAME then
			WorldTooltips:StartTimer()
		end
	end)
end