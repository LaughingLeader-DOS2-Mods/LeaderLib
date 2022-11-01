local _EXTVERSION = Ext.Utils.Version()
local _ISCLIENT = Ext.IsClient()

local WorldTooltips = {
	TooltipMode = 2, -- World and Hover
	UpdateDelay = 2000
}
QOL.WorldTooltips = WorldTooltips

function WorldTooltips:IsEnabled()
	return GameHelpers.IsLevelType(LEVELTYPE.GAME) and SettingsManager.GetMod(ModuleUUID).Global:FlagEquals("LeaderLib_AllTooltipsForItemsEnabled", true)
end

---@param templates table<FixedString,boolean>
local function _UpdateTemplates(templates)
	local level = Ext.Entity.GetCurrentLevel()
	if level then
		local levelTemplates = level.LocalTemplateManager.Templates
		local cachedTemplates = level.LevelCacheTemplateManager.Templates
		for id,b in pairs(templates) do
			local template = levelTemplates[id]
			---@cast template ItemTemplate
			if template then
				template.Tooltip = WorldTooltips.TooltipMode
			end
			template = cachedTemplates[id]
			if template then
				template.Tooltip = WorldTooltips.TooltipMode
			end
			template = Ext.Template.GetRootTemplate(id)
			if template then
				template.Tooltip = WorldTooltips.TooltipMode
			end
		end
	else
		for id,b in pairs(templates) do
			local template = Ext.Template.GetRootTemplate(id)
			if template then
				template.Tooltip = WorldTooltips.TooltipMode
			end
		end
	end
end

if _ISCLIENT then
	function WorldTooltips:UpdateItems(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			if data.Items then
				for i=1,#data.Items do
					local item = GameHelpers.GetItem(data.Items[i])
					if item and item.CurrentTemplate then
						item.CurrentTemplate.Tooltip = WorldTooltips.TooltipMode
					end
				end
			end
			if data.Templates then
				_UpdateTemplates(data.Templates)
			end
		end
	end
	Ext.RegisterNetListener("LeaderLib_WorldTooltips_UpdateClient", function(...) WorldTooltips:UpdateItems(...) end)
else
	---@param item EsvItem
	---@param force boolean|nil Skip the Tooltip ~= 2 check to update the client.
	local function _ShouldHaveTooltip(item, force)
		if item.CurrentTemplate and (item.CurrentTemplate.Tooltip ~= WorldTooltips.TooltipMode or force) and not StringHelpers.IsNullOrWhitespace(GameHelpers.GetDisplayName(item)) then
			return true
		end
		return false
	end

	---@return EsvItem[]
	local function _GetAllItems()
		local level = Ext.Entity.GetCurrentLevel()
		if level then
			local items = level.EntityManager.ItemConversionHelpers.RegisteredItems[level.LevelDesc.LevelName]
			if items then
				return items
			end
		end
		return {}
	end

	local _ValidUpdateStates = {
		Running = true,
		Paused = true,
		GameMasterPause = true,
	}

	---@param forceResync boolean|nil Force the client to update.
	function WorldTooltips.UpdateWorldItems(forceResync)
		Timer.Cancel("Timers_LeaderLib_WorldTooltips_UpdateItems")

		local state = tostring(Ext.GetGameState())

		--Don't try and modify items during Sync/etc
		if _ValidUpdateStates[state] and WorldTooltips:IsEnabled() then
			local time = Ext.Utils.MonotonicTime()
			local updateDataLen = 0
			local updateData = {
				Items = {},
				Templates = {},
			}
			for _,item in pairs(_GetAllItems()) do
				if _ShouldHaveTooltip(item, forceResync) then
					updateDataLen = updateDataLen + 1
					updateData.Items[updateDataLen] = item.NetID
					local template = GameHelpers.GetTemplate(item)
					updateData.Templates[template] = true
					item.CurrentTemplate.Tooltip = WorldTooltips.TooltipMode
				end
			end
			if updateDataLen > 0 then
				if Vars.LeaderDebugMode then
					fprint(LOGLEVEL.DEFAULT, "[LeaderLib:WorldTooltips.UpdateWorldItems] World tooltip updating took (%s) ms.", Ext.Utils.MonotonicTime()-time)
				end
				_UpdateTemplates(updateData.Templates)
				GameHelpers.Net.Broadcast("LeaderLib_WorldTooltips_UpdateClient", updateData)
			end
		end
	end

	---@param item EsvItem
	function WorldTooltips:OnItemEnteredWorld(item)
		if item and item.CurrentLevel ~= "" and _ShouldHaveTooltip(item) then
			item.CurrentTemplate.Tooltip = WorldTooltips.TooltipMode
			local template = GameHelpers.GetTemplate(item)
			GameHelpers.Net.Broadcast("LeaderLib_WorldTooltips_UpdateClient", {Items={item.NetID}, Templates={[template]=true}})
		end
	end

	Ext.Osiris.RegisterListener("ItemEnteredRegion", Data.OsirisEvents.ItemEnteredRegion, "after", function(uuid, region)
		--Sync state safety
		if _ValidUpdateStates[Ext.GetGameState()] and WorldTooltips:IsEnabled() then
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