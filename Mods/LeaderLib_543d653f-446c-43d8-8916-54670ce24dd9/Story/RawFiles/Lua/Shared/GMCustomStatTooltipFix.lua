if Ext.IsServer() then
	Ext.RegisterNetListener("LeaderLib_CheckCustomStatCallback", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local statDouble = data.Stat
			local character = Ext.GetCharacter(data.Character)
			if character then
				if (character.IsPossessed or (not character.IsGameMaster and character.IsPlayer)) and character.UserID > -1 then
					local stat = Ext.GetCustomStatByName(data.DisplayName)
					if stat then
						data.DisplayName = stat.Name
						data.ID = stat.Id
						data.Description = stat.Description
					end
					Ext.PostMessageToClient(character.MyGuid, "LeaderLib_CreateCustomStatTooltip", Ext.JsonStringify(data))
				end
			end
		end
	end)
	Ext.RegisterNetListener("LeaderLib_RequestCustomStatData", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local uuid = data.UUID
			local character = Ext.GetCharacter(data.Character)
			local statValue = NRD_CharacterGetCustomStat(character.MyGuid, uuid)
			--TODO Need some way to get a custom stat's name and tooltip from the UUID.
		end
	end)
else
	local showingCustomStatTooltip = false
	local requestingCustomStatTooltip = false
	local lastTooltipX = 0
	local lastTooltipY = 0

	--ExternalInterface.call(param2,param1.statId,val3.x + val5,val3.y + val4,val6,param1.height,param1.tooltipAlign);
	Ext.RegisterUINameCall("showCustomStatTooltip", function(ui, call, statId, x, y, width, height, alignment)
		requestingCustomStatTooltip = false
		---@type EclCharacter
		local character = nil
		---@type ObjectHandle
		local stat = nil
		local statDouble = nil
		local statName = ""
		local statValue = nil

		if ui:GetTypeId() == Data.UIType.characterSheet then
			character = Ext.GetCharacter(ui:GetPlayerHandle())
			statDouble = statId
			local this = ui:GetRoot()
			for i=0,#this.stats_mc.customStats_mc.list.content_array do
				local customStat = this.stats_mc.customStats_mc.list.content_array[i]
				if customStat and customStat.statId == statId then
					statName = customStat.label_txt.htmlText
					statValue = tonumber(customStat.text_txt.htmlText)
				end
			end
		else
			character = GameHelpers.Client.GetCharacter()
			statDouble = statId
			x,y,width,height = 0,0,413,196
			alignment = "right"
		end
		stat = Ext.DoubleToHandle(statDouble)
		if character then
			local payload = Ext.JsonStringify({
				Character=character.NetID, 
				Stat=statDouble, 
				UI=ui:GetTypeId(),
				X = x,
				Y = y,
				Width = width,
				Height = height,
				Alignment = alignment,
				DisplayName = statName or "",
				Value = statValue
			})
			requestingCustomStatTooltip = true
			Ext.PostMessageToServer("LeaderLib_CheckCustomStatCallback", payload)
		end
	end, "Before")

	local addedCustomTab = false

	local function addCustomStatsTab_Controller(ui)
		local title = Ext.GetTranslatedString("ha62e1eccgc1c2g4452g8d78g65ea010f3d85", "Custom Stats")
		ui:Invoke("addStatsTab", 6, 7, title)
		addedCustomTab = true
	end

	Ext.RegisterUITypeInvokeListener(Data.UIType.statsPanel_c, "addStatsTab", function(ui, method, id, imageId, title)
		if not addedCustomTab and id == 5 then
			addCustomStatsTab_Controller(ui)
		end
	end)

	Ext.RegisterUITypeInvokeListener(Data.UIType.statsPanel_c, "selectStatsTab", function(ui, method, id, imageId, title)
		if not addedCustomTab and id == 5 then
			addCustomStatsTab_Controller(ui)
		end
	end)

	RegisterListener("LuaReset", function()
		local ui = Ext.GetUIByType(Data.UIType.statsPanel_c)
		if ui then
			local tabBar_mc = ui:GetRoot().mainpanel_mc.stats_mc.tabBar_mc
			for i=0,tabBar_mc.tabList.length do
				local entry = tabBar_mc.tabList.content_array[i]
				if entry and entry.id == 6 then
					addedCustomTab = true
					break
				end
			end
		end
	end)

	Ext.RegisterUINameCall("hideTooltip", function(ui, call)
		requestingCustomStatTooltip = false
		if showingCustomStatTooltip then
			local ui = Ext.GetUIByType(Data.UIType.tooltip)
			if ui then
				ui:Invoke("removeTooltip")
				local this = ui:GetRoot()
				local tf = this.formatTooltip
				if tf then
					tf.x = lastTooltipX
					tf.y = lastTooltipY
					--ui:ExternalInterfaceCall("setAnchor","bottomRight","screen","bottomRight")
					--ui:ExternalInterfaceCall("keepUIinScreen",true)
				end
				showingCustomStatTooltip = false
			end
		end
	end)

	Ext.RegisterNetListener("LeaderLib_CreateCustomStatTooltip", function(cmd, payload)
		if requestingCustomStatTooltip then
			requestingCustomStatTooltip = false
			local data = Common.JsonParse(payload)
			if data then
				local statDouble = data.Stat
				Game.Tooltip.SaveCustomStat({
					HandleDouble = data.Stat,
					UUID = data.ID,
					DisplayName = data.DisplayName,
					Description = data.Description,
					Value = data.Value
				})
				local character = Ext.GetCharacter(data.Character)
				local ui = Ext.GetUIByType(Data.UIType.tooltip)
				if ui then
					local main = ui:GetRoot()
					if main and main.tooltip_array then
						main.tooltip_array[0] = 93
						main.tooltip_array[1] = data.DisplayName or ""
						main.tooltip_array[2] = 94
						main.tooltip_array[3] = data.Description or ""
	
						--ui:ExternalInterfaceCall("showTooltip", "", data.X, data.Y,data.Width,data.Height,"right",true)
						--ui:ExternalInterfaceCall("clearAnchor")
						--ui:ExternalInterfaceCall("keepUIinScreen", false)
						--TODO Figure out how to move the tooltip UI to the proper x/y position.
						--It's like the contextMenu in that its position isn't 1:1 a screen position
						
						-- ui:SetPosition(777,290)
						ui:ExternalInterfaceCall("setAnchor","topLeft","screen","topLeft")
		
						ui:Invoke("addFormattedTooltip",0,0,true)
						ui:ExternalInterfaceCall("setTooltipSize", data.Width, data.Height)
						--ui:ExternalInterfaceCall("setAnchor","topright","mouse","bottomleft")
						ui:Invoke("showFormattedTooltipAfterPos", false)

						showingCustomStatTooltip = true
	
						ui:ExternalInterfaceCall("setAnchor","topLeft","screen","topLeft")
						local tf = main.formatTooltip
						if tf then
							lastTooltipX = tf.x
							lastTooltipY = tf.y
							local x,y = UIExtensions.GetMousePosition()
							tf.x = x + 50
							tf.y = y - 20
						end
					end
				end
			end
		end
	end)
end