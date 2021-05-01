if Ext.IsServer() then
	Ext.RegisterNetListener("LeaderLib_CheckCustomStatCallback", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local statDouble = data.Stat
			local character = Ext.GetCharacter(data.Character)
			if character then
				if (character.IsPossessed or (not character.IsGameMaster and character.IsPlayer)) and character.UserID > -1 then
					Ext.PostMessageToClient(character.MyGuid, "LeaderLib_InvokeCustomStatMethods", payload)
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

	--ExternalInterface.call(param2,param1.statId,val3.x + val5,val3.y + val4,val6,param1.height,param1.tooltipAlign);
	Ext.RegisterUINameCall("showCustomStatTooltip", function(ui, call, statId, x, y, width, height, alignment)
		---@type EclCharacter
		local character = nil
		---@type ObjectHandle
		local stat = nil
		local statDouble = nil

		if ui:GetTypeId() == Data.UIType.characterSheet then
			character = Ext.GetCharacter(ui:GetPlayerHandle())
			statDouble = statId
		else
			character = GameHelpers.Client.GetCharacter()
			statDouble = statId
			x,y,width,height = 0,0,413,196
			alignment = "right"
		end
		stat = Ext.DoubleToHandle(statDouble)

		if character then
			print(character.NetID, character.MyGuid, character.UserID)
			Ext.PostMessageToServer("LeaderLib_CheckCustomStatCallback", Ext.JsonStringify({
				Character=character.NetID, 
				Stat=statDouble, 
				UI=ui:GetTypeId(),
				X = x,
				Y = y,
				Width = width,
				Height = height,
				Alignment = alignment
			}))
		end
	end)

	Ext.RegisterUINameCall("hideTooltip", function(ui, call)
		if showingCustomStatTooltip then
			showingCustomStatTooltip = false
			local ui = Ext.GetUIByType(Data.UIType.tooltip)
			if ui then
				ui:Invoke("removeTooltip")
			end
		end
	end)

	Ext.RegisterNetListener("LeaderLib_InvokeCustomStatMethods", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local statDouble = data.Stat
			local character = Ext.GetCharacter(data.Character)
			local ui = Ext.GetUIByType(Data.UIType.tooltip)
			if ui then
				local main = ui:GetRoot()
				if main and main.tooltip_array then
					main.tooltip_array[0] = 93
					main.tooltip_array[1] = "" -- Name
					main.tooltip_array[2] = 94
					main.tooltip_array[3] = "" -- Tooltip
	
					ui:Invoke("addFormattedTooltip", data.X, data.Y, false)
					ui:Invoke("setTooltipSize", data.Width, data.Height)
					ui:Invoke("showFormattedTooltipAfterPos", false)
					showingCustomStatTooltip = true
				end
			end
		end
	end)
end