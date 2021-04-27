local function GetStatusVisibility(statusId, allVisible, whitelist, blacklist)
	local blacklisted = blacklist[statusId] == true
	local whitelisted = whitelist[statusId] == true
	if allVisible then
		if blacklisted then
			return false
		end
		return true
	elseif not allVisible then
		if whitelisted then
			return true
		end
		return false
	end
end

local function SetStatusesVisibility(ui, statusHolder_mc, array, allVisible, whitelist, blacklist)
	local makeParentVisible = false
	local changedVisibility = true
	for i=0,#array do
		local statusEntry = array[i]
		if statusEntry then
			local statusHandle = Ext.DoubleToHandle(statusEntry.id)
			local ownerHandle = Ext.DoubleToHandle(statusEntry.owner)
			local player = Ext.GetCharacter(ownerHandle)
			local status = Ext.GetStatus(ownerHandle, statusHandle)
			if status then
				local visible = GetStatusVisibility(status.StatusId, allVisible, blacklist, whitelist)
				if visible then
					if not allVisible then
						makeParentVisible = true
					end
					statusEntry.visible = true
					statusEntry.alive = true
				else
					statusEntry.visible = false
					statusEntry.alive = false
				end
				--fprint("[%s] Owner(%s) Status(%s) Blacklisted(%s) Whitelisted(%s) Visible(%s)", i, player.Stats.Name, status.StatusId, blacklisted, whitelisted, statusEntry.visible)
			end
		end
	end
	if makeParentVisible then
		statusHolder_mc.visible = true
	end
	return changedVisibility
end

---Checks if the parent statusHolder_mc should be visible.
local function CheckStatusEntries(ui, statusHolder_mc, array, allVisible, whitelist, blacklist)
	for i=0,#array do
		local statusEntry = array[i]
		if statusEntry then
			local statusHandle = Ext.DoubleToHandle(statusEntry.id)
			local ownerHandle = Ext.DoubleToHandle(statusEntry.owner)
			local player = Ext.GetCharacter(ownerHandle)
			local status = Ext.GetStatus(ownerHandle, statusHandle)
			if status then
				local visible = GetStatusVisibility(status.StatusId, allVisible, blacklist, whitelist)
				if visible then
					if not allVisible then
						return true
					end
				end
			end
		end
	end
	return false
end

function UI.ToggleStatusVisibility(allVisible)
	local whitelist = {}
	local blacklist = {}

	if allVisible then
		for i,v in pairs(GameSettings.Settings.Client.StatusOptions.Blacklist) do
			if type(i) == "string" then
				blacklist[i] = v
			elseif type(v) == "string" then
				blacklist[v] = true
			end
		end
	elseif allVisible == false then
		for i,v in pairs(GameSettings.Settings.Client.StatusOptions.Whitelist) do
			if type(i) == "string" then
				whitelist[i] = v
			elseif type(v) == "string" then
				whitelist[v] = true
			end
		end
	end

	if allVisible == nil then
		allVisible = true
	end

	if Vars.DebugMode then
		if allVisible then
			blacklist["LEADERSHIP"] = true
			blacklist["HASTED"] = true
		else
			whitelist["LEADERSHIP"] = true
			whitelist["HASTED"] = true
		end
	end

	local ui = not Vars.ControllerEnabled and Ext.GetUIByType(Data.UIType.playerInfo) or Ext.GetUIByType(Data.UIType.playerInfo_c)
	if ui then
		local main = ui:GetRoot()
		if main then
			local b,err = xpcall(function()
				for i=0,#main.player_array do
					local player_mc = main.player_array[i]
					if player_mc and player_mc.statusHolder_mc then
						player_mc.statusHolder_mc.allVisible = allVisible
						if not allVisible and #whitelist > 0 and CheckStatusEntries(ui, player_mc.statusHolder_mc, player_mc.status_array, allVisible, whitelist, blacklist) then
							player_mc.statusHolder_mc.visible = true
						end
						if player_mc.summonList then
							for j=0,#player_mc.summonList.content_array do
								local summon_mc = player_mc.summonList.content_array[j]
								if summon_mc then
									summon_mc.statusHolder_mc.allVisible = allVisible
									if not allVisible and #whitelist > 0 and CheckStatusEntries(ui, summon_mc.statusHolder_mc, summon_mc.status_array, allVisible, whitelist, blacklist) then
										summon_mc.statusHolder_mc.visible = true
									end
								end
							end
						end
					end
				end
			end, debug.traceback)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
end

Ext.RegisterNetListener("LeaderLib_UI_SetStatusMCVisibility", function(cmd, payload)
	UI.ToggleStatusVisibility(payload ~= "false")
end)

Ext.RegisterNetListener("LeaderLib_UI_RefreshStatusMCVisibility", function(cmd, payload)
	UI.ToggleStatusVisibility(not GameSettings.Settings.Client.StatusOptions.HideAll)
end)

local function OnUpdateStatuses(ui, method, addIfNotExists, cleanupAll)
	if cleanupAll then
		return
	end
		
	local allVisible = not GameSettings.Settings.Client.StatusOptions.HideAll
	local whitelist = {}
	local blacklist = {}

	if allVisible then
		for i,v in pairs(GameSettings.Settings.Client.StatusOptions.Blacklist) do
			if type(i) == "string" then
				blacklist[i] = v
			elseif type(v) == "string" then
				blacklist[v] = true
			end
		end
	else
		for i,v in pairs(GameSettings.Settings.Client.StatusOptions.Whitelist) do
			if type(i) == "string" then
				whitelist[i] = v
			elseif type(v) == "string" then
				whitelist[v] = true
			end
		end
	end

	if Vars.DebugMode then
		if allVisible then
			blacklist["LEADERSHIP"] = true
			--blacklist["HASTED"] = true
		else
			--whitelist["LEADERSHIP"] = true
			whitelist["HASTED"] = true
		end
	end

	local main = ui:GetRoot()
	local status_array = main.status_array
	for i=0,#status_array,6 do
		-- print(i, status_array[i])
		-- print(i+1, status_array[i+1])
		-- print(i+2, status_array[i+2])
		-- print(i+3, status_array[i+3])
		-- print(i+4, status_array[i+4])
		-- print(i+5, status_array[i+5])
		--[[
			val4 = Number(this.status_array[val3]);
			val5 = Number(this.status_array[val3 + 1]);
			val6 = Number(this.status_array[val3 + 2]);
			val7 = Number(this.status_array[val3 + 3]);
			val8 = Number(this.status_array[val3 + 4]);
			val9 = String(this.status_array[val3 + 5]);
			this.setStatus(param1,val4,val5,val6,val7,val8,val9);
		]]
		local ownerDouble = status_array[i]
		if ownerDouble then
			local ownerHandle = Ext.DoubleToHandle(ownerDouble)
			if ownerHandle then
				local statusHandle = Ext.DoubleToHandle(status_array[i+1])
				--local iconId = status_array[i+2]
				--local turns = status_array[i+3]
				--local cooldown = status_array[i+4]
				--local tooltip = status_array[i+5]
		
				local status = Ext.GetStatus(ownerHandle, statusHandle)
				if status then
					if not GetStatusVisibility(status.StatusId, allVisible, whitelist, blacklist) then
						status_array[i] = ""
					end
				end
			end
		end
	end
	-- UIExtensions.StartTimer("LeaderLib_playerInfo_updateStatuses", 10, function()
	-- 	UI.ToggleStatusVisibility(not GameSettings.Settings.Client.StatusOptions.HideAll)
	-- end)
end

Ext.RegisterUITypeInvokeListener(Data.UIType.playerInfo, "updateStatuses", OnUpdateStatuses)
Ext.RegisterUITypeInvokeListener(Data.UIType.playerInfo_c, "updateStatuses", OnUpdateStatuses)