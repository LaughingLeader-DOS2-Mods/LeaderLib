local WorldTooltipper = {
	TooltipMode = 2
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
	function WorldTooltipper.UpdateWorldItems()
		--local ids = {}
		for _,uuid in pairs(Ext.GetAllItems()) do
			local item = Ext.GetItem(uuid)
			if item then
				if item.RootTemplate.Tooltip ~= WorldTooltipper.TooltipMode then
					item.RootTemplate.Tooltip = WorldTooltipper.TooltipMode
					--ids[#ids+1] = item.NetID
				end
			end
		end
		--Ext.BroadcastMessage("LeaderLib_WorldTooltipper_UpdateClient", Ext.JsonStringify(ids))
	end

	---@param item EsvItem
	function WorldTooltipper.OnItemEnteredWorld(item, region)
		if item then
			--print("SERVER", item.DisplayName, item.RootTemplate.Tooltip)
			if item.RootTemplate.Tooltip ~= WorldTooltipper.TooltipMode then
				item.RootTemplate.Tooltip = WorldTooltipper.TooltipMode
			end
		else
			Ext.PrintError("[WorldTooltipper.OnItemEnteredWorld] Item is nil?")
		end
	end

	Ext.RegisterOsirisListener("ItemEnteredRegion", Data.OsirisEvents.ItemEnteredRegion, "after", function(uuid, region) WorldTooltipper.OnItemEnteredWorld(Ext.GetItem(uuid), region) end)

	RegisterListener("Initialized", WorldTooltipper.UpdateWorldItems)
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