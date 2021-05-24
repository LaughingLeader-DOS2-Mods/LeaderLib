if CustomStatTooltipFixer == nil then
	CustomStatTooltipFixer = {}
end

if Ext.IsServer() then
	local canFix = Ext.GetCustomStatByName ~= nil
	Ext.RegisterNetListener("LeaderLib_CheckCustomStatCallback", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local statDouble = data.Stat
			local character = Ext.GetCharacter(data.Character)
			if character then
				if (character.IsPossessed or (not character.IsGameMaster and character.IsPlayer)) and character.UserID > -1 then
					if canFix then
						local stat = Ext.GetCustomStatByName(data.StatId)
						if stat then
							data.DisplayName = stat.Name
							data.ID = stat.Id
							data.Description = stat.Description
						else
							data.DisplayName = data.StatId
							data.Description = ""
						end
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
	CustomStatTooltipFixer.Visible = false
	CustomStatTooltipFixer.Requesting = false
	local lastTooltipX = 0
	local lastTooltipY = 0

	--ExternalInterface.call(param2,param1.statId,val3.x + val5,val3.y + val4,val6,param1.height,param1.tooltipAlign);
	Ext.RegisterUINameCall("showCustomStatTooltip", function(ui, call, statId, x, y, width, height, alignment)
		CustomStatTooltipFixer.Requesting = false
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
				StatId = statName or "",
				Value = statValue
			})
			CustomStatTooltipFixer.Requesting = true
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

	if Vars.DebugMode then
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
	end

	function CustomStatTooltipFixer.HideTooltip()
		CustomStatTooltipFixer.Requesting = false
		if CustomStatTooltipFixer.Visible then
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
				CustomStatTooltipFixer.Visible = false
			end
		end
	end

	function CustomStatTooltipFixer.OnToggleCharacterPane()
		if CustomStatTooltipFixer.Visible then
			CustomStatTooltipFixer.HideTooltip()
		end
	end

	Ext.RegisterUINameCall("hideTooltip", CustomStatTooltipFixer.HideTooltip)

	Ext.RegisterNetListener("LeaderLib_CreateCustomStatTooltip", function(cmd, payload)
		if CustomStatTooltipFixer.Requesting then
			CustomStatTooltipFixer.Requesting = false
			local data = Common.JsonParse(payload)
			if data then
				local statDouble = data.Stat
				local iconid = Game.Tooltip.GetCustomStatIconId(data.ID)

				if string.find(data.DisplayName, "_", 1, true) then
					data.DisplayName = GameHelpers.Tooltip.ReplacePlaceholders(GameHelpers.GetStringKeyText(data.DisplayName, data.DisplayName))
					print(data.DisplayName)
				end
				if string.find(data.Description, "_", 1, true) then
					data.Description = GameHelpers.Tooltip.ReplacePlaceholders(GameHelpers.GetStringKeyText(data.Description, data.Description))
				end

				Game.Tooltip.SaveCustomStat({
					HandleDouble = data.Stat,
					UUID = data.ID,
					StatId = data.StatId,
					DisplayName = data.DisplayName,
					Description = data.Description,
					Value = data.Value,
					IconId = iconid,
					IconAtlasKey = "Talent_BackStabber"--"Ability_Summoning"
				})
				local character = Ext.GetCharacter(data.Character)
				local ui = Ext.GetUIByType(Data.UIType.tooltip)
				if ui then
					local this = ui:GetRoot()
					if this and this.tooltip_array then
						-- this.tooltip_array[0] = Game.Tooltip.TooltipItemTypes.StatName
						-- this.tooltip_array[1] = data.DisplayName or ""
						-- this.tooltip_array[2] = Game.Tooltip.TooltipItemTypes.StatsDescription
						-- this.tooltip_array[3] = data.Description or ""
						--AbilityDescription = {{"AbilityId", "number"}, {"Description", "string"}, {"Description2", "string"}, {"CurrentLevelEffect", "string"}, {"NextLevelEffect", "string"}},
						this.tooltip_array[0] = Game.Tooltip.TooltipItemTypes.AbilityTitle
						this.tooltip_array[1] = data.DisplayName or ""
						this.tooltip_array[2] = Game.Tooltip.TooltipItemTypes.AbilityDescription
						this.tooltip_array[3] = iconid
						this.tooltip_array[4] = data.Description or ""
						this.tooltip_array[5] = ""
						this.tooltip_array[6] = ""
						this.tooltip_array[7] = ""
	
						--ui:ExternalInterfaceCall("showTooltip", "", data.X, data.Y,data.Width,data.Height,"right",true)
						--ui:ExternalInterfaceCall("clearAnchor")
						--ui:ExternalInterfaceCall("keepUIinScreen", false)
						--TODO Figure out how to move the tooltip UI to the proper x/y position.
						--It's like the contextMenu in that its position isn't 1:1 a screen position

						local tf = this.formatTooltip
						if tf then
							lastTooltipX = tf.x
							lastTooltipY = tf.y
						end
						
						-- ui:SetPosition(777,290)
						--ui:ExternalInterfaceCall("setAnchor","center","mouse","center")
						ui:ExternalInterfaceCall("setAnchor","left","mouse","left")
		
						ui:Invoke("addFormattedTooltip",0,0,true)
						ui:ExternalInterfaceCall("setTooltipSize", data.Width, data.Height)
						--ui:ExternalInterfaceCall("setAnchor","topright","mouse","bottomleft")
						ui:Invoke("showFormattedTooltipAfterPos", false)

						CustomStatTooltipFixer.Visible = true
						local tf = this.formatTooltip or this.tf
						if tf then
							tf.x = 50
							tf.y = 90
						end
						ui:ExternalInterfaceCall("keepUIinScreen", false)
						-- UIExtensions.StartTimer("tooltipText", 10, function()
						-- 	--ui:SetCustomIcon("i0", "Ability_Summoning", 128, 128)
						-- 	local tooltip_mc = this.tf.tooltip_mc
						-- 	if tooltip_mc then
						-- 		print("AbilityId", tooltip_mc.AbilityId)
						-- 		print("areInaccessibleObjectsUnderPoint", tooltip_mc.areInaccessibleObjectsUnderPoint)
						-- 		for i=0,#tooltip_mc.list.content_array-1 do
						-- 			local entry = tooltip_mc.list.content_array[i]
						-- 			print(i, entry and entry.name or "nil?")
						-- 			if entry then
						-- 				fprint(LOGLEVEL.TRACE, "groupID(%s) orderId(%s) iconId(%s)", entry.groupID or "nil", entry.orderId or "nil", entry.iconId or "nil")
						-- 				if entry.container_mc then
						-- 					---@type FlashMovieClip
						-- 					local container_mc = entry.container_mc
						-- 					fprint(LOGLEVEL.TRACE, "tt_statsIcon? numChildren(%s) child(%s)", container_mc.numChildren or "nil", container_mc.getChildAt(0) or "nil")
						-- 				end
						-- 			end
						-- 		end
						-- 	end
						-- end)
					end
				end
			end
		end
	end)
end