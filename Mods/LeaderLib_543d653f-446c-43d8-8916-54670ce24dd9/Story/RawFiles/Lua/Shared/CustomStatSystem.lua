if CustomStatSystem == nil then
	CustomStatSystem = {}
end

---@class CustomStatTooltipType
CustomStatSystem.TooltipType = {
	Default = "Stat",
	Ability = "Ability",
	Stat = "Stat",
}


---@class CustomStatData:table
---@field ID string
---@field DisplayName string
---@field Description string
---@field Icon string|nil
---@field Create boolean|nil Whether the server should create this stat automatically.
---@field TooltipType CustomStatTooltipType|nil
---@field Mod string The mod UUID that added this stat, if any. Auto-set.
---@field Double number The stat's double (handle) value. Determined dynamically.

---@alias MOD_UUID string
---@alias STAT_ID string

---@type table<MOD_UUID, table<STAT_ID, CustomStatData>>
CustomStatSystem.Stats = {}

---@type fun():table<string, table<string, CustomStatData>>
local loader = Ext.Require("Shared/Settings/CustomStatsConfigLoader.lua")

local function LoadCustomStatsData()
	CustomStatSystem.Stats = loader() or {}
	print(Ext.IsServer() and "SERVER" or "CLIENT", Ext.JsonStringify(CustomStatSystem.Stats))

	if Ext.IsServer() then
		for uuid,stats in pairs(CustomStatSystem.Stats) do
			local modName = Ext.GetModInfo(uuid).Name
			for id,stat in pairs(stats) do
				if stat.Create == true then
					local existingData = Ext.GetCustomStatByName(stat.DisplayName)
					if not existingData then
						Ext.CreateCustomStat(stat.DisplayName, stat.Description)
						fprint(LOGLEVEL.DEFAULT, "[LeaderLib:LoadCustomStatsData] Created a new custom stat for mod [%s]. ID(%s) DisplayName(%s) Description(%s)", modName, id, stat.DisplayName, stat.Description)

						existingData = Ext.GetCustomStatByName(stat.DisplayName)
					else
						print("Found custom stat:", Common.Dump(existingData))
					end
					if existingData then
						stat.UUID = existingData.Id
					end
				end
			end
		end
	end
end

Ext.RegisterListener("SessionLoaded", LoadCustomStatsData)
RegisterListener("LuaReset", LoadCustomStatsData)

---@param displayName string
---@return CustomStatData
function CustomStatSystem.GetStatByName(displayName)
	for uuid,stats in pairs(CustomStatSystem.Stats) do
		for id,stat in pairs(stats) do
			if stat.DisplayName == displayName then
				return stat
			end
		end
	end
	return nil
end

---@param id string
---@param mod string
---@return CustomStatData
function CustomStatSystem.GetStatByID(id, mod)
	if mod then
		local stats = CustomStatSystem.Stats[mod]
		if stats and stats[id] then
			return stats[id]
		end
	else
		for uuid,stats in pairs(CustomStatSystem.Stats) do
			local stat = stats[id]
			if stat then
				return stat
			end
		end
	end
	return nil
end

---@param uuid string Unique UUID for the stat.
---@return CustomStatData
function CustomStatSystem.GetStatByUUID(uuid)
	for mod,stats in pairs(CustomStatSystem.Stats) do
		for id,stat in pairs(stats) do
			if stat.UUID == uuid then
				return stat
			end
		end
	end
	return nil
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
	function CustomStatSystem.GetSyncData()
		local data = {}
		for uuid,stats in pairs(CustomStatSystem.Stats) do
			data[uuid] = {}
			for id,stat in pairs(stats) do
				if stat.UUID then
					data[uuid][id] = stat.UUID
				end
			end
		end
		return data
	end
else
	function CustomStatSystem.LoadSyncData(data)
		for uuid,stats in pairs(data) do
			local existing = CustomStatSystem.Stats[uuid]
			if existing then
				for id,statId in pairs(stats) do
					if existing[id] then
						existing[id].UUID = statId
					end
				end
			end
		end
	end

	---@param double number
	---@return CustomStatData
	function CustomStatSystem.GetStatByDouble(double)
		for mod,stats in pairs(CustomStatSystem.Stats) do
			for id,stat in pairs(stats) do
				if stat.Double == double then
					return stat
				end
			end
		end
		return nil
	end

	CustomStatSystem.Visible = false
	CustomStatSystem.Requesting = false
	local lastTooltipX = nil
	local lastTooltipY = nil
	CustomStatSystem.LastIconId = 1212

	function CustomStatSystem.GetNextCustomStatIconId()
		CustomStatSystem.LastIconId = CustomStatSystem.LastIconId + 1
		return CustomStatSystem.LastIconId
	end

	local function AdjustCustomStatMovieClips(ui)
		local this = ui:GetRoot()
		local arr = this.stats_mc.customStats_mc.list.content_array
		for i=0,#arr do
			local mc = arr[i]
			if mc then
				local displayName = mc.label_txt.htmlText
				local stat = CustomStatSystem.GetStatByName(displayName)
				if stat then
					stat.Double = mc.statId

					if string.find(stat.DisplayName, "_", 1, true) then
						mc.label_txt.htmlText = GameHelpers.Tooltip.ReplacePlaceholders(GameHelpers.GetStringKeyText(stat.DisplayName))
					else
						mc.label_txt.htmlText = GameHelpers.Tooltip.ReplacePlaceholders(stat.DisplayName)
					end

					print(stat, stat.UUID, stat.DisplayName, mc.label_txt.htmlText)
				end
			end
		end
	end

	local function OnSheetUpdating(ui, method)
		local this = ui:GetRoot()
		local length = #this.customStats_array
		if length == 0 then
			return
		end
		for i=0,length,3 do
			local doubleHandle = this.customStats_array[i]
			local displayName = this.customStats_array[i+1]
			local value = this.customStats_array[i+2]

			if doubleHandle then
				local stat = CustomStatSystem.GetStatByName(displayName)
				if stat then
					stat.Double = doubleHandle
					if string.find(stat.DisplayName, "_", 1, true) then
						this.customStats_array[i+1] = GameHelpers.Tooltip.ReplacePlaceholders(GameHelpers.GetStringKeyText(stat.DisplayName))
					else
						this.customStats_array[i+1] = GameHelpers.Tooltip.ReplacePlaceholders(stat.DisplayName)
					end
				end
			end
		end
	end

	Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", OnSheetUpdating)
	--Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "setPlayerInfo", AdjustCustomStatMovieClips)

	--ExternalInterface.call(param2,param1.statId,val3.x + val5,val3.y + val4,val6,param1.height,param1.tooltipAlign);
	Ext.RegisterUINameCall("showCustomStatTooltip", function(ui, call, statId, x, y, width, height, alignment)
		CustomStatSystem.Requesting = false
		---@type EclCharacter
		local character = nil
		---@type ObjectHandle
		local stat = nil
		local statName = ""
		local statValue = nil

		if ui:GetTypeId() == Data.UIType.characterSheet then
			character = Ext.GetCharacter(ui:GetPlayerHandle())
			local this = ui:GetRoot()
			for i=0,#this.stats_mc.customStats_mc.list.content_array do
				local mc = this.stats_mc.customStats_mc.list.content_array[i]
				if mc and mc.statId == statId then
					statName = mc.label_txt.htmlText
					statValue = tonumber(mc.text_txt.htmlText)

					---@type CustomStatData
					local stat = CustomStatSystem.GetStatByDouble(statId)
					if stat then
						local displayName,description = stat.DisplayName,stat.Description
						if string.find(displayName, "_", 1, true) then
							displayName = GameHelpers.Tooltip.ReplacePlaceholders(GameHelpers.GetStringKeyText(displayName))
						end
						if string.find(description, "_", 1, true) then
							description = GameHelpers.Tooltip.ReplacePlaceholders(GameHelpers.GetStringKeyText(description))
						end

						stat.IconId = CustomStatSystem.GetNextCustomStatIconId()

						CustomStatSystem.CreateCustomStatTooltip(displayName, description, width, height, stat.TooltipType, stat.Icon, stat.IconId)
						return
					end
				end
			end
		else
			character = GameHelpers.Client.GetCharacter()
			x,y,width,height = 0,0,413,196
			alignment = "right"
		end
		if character then
			local payload = Ext.JsonStringify({
				Character=character.NetID, 
				Stat=statId, 
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
			CustomStatSystem.Requesting = true
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

	function CustomStatSystem.HideTooltip()
		CustomStatSystem.LastIconId = 1212
		CustomStatSystem.Requesting = false
		if CustomStatSystem.Visible then
			CustomStatSystem.Visible = false
			local ui = Ext.GetUIByType(Data.UIType.tooltip)
			if ui then
				ui:Invoke("removeTooltip")
				if lastTooltipX and lastTooltipY then
					local this = ui:GetRoot()
					local tf = this.formatTooltip
					if tf then
						tf.x = lastTooltipX
						tf.y = lastTooltipY
						lastTooltipX = nil
						lastTooltipY = nil
						--ui:ExternalInterfaceCall("setAnchor","bottomRight","screen","bottomRight")
						--ui:ExternalInterfaceCall("keepUIinScreen",true)
					end
				end
			end
		end
	end

	function CustomStatSystem.OnToggleCharacterPane()
		if CustomStatSystem.Visible then
			CustomStatSystem.HideTooltip()
		end
	end

	Ext.RegisterUINameCall("hideTooltip", CustomStatSystem.HideTooltip)
	---Workaround
	Ext.RegisterUITypeCall(Data.UIType.tooltip, "clearAnchor", function(ui)
		if CustomStatSystem.Visible then
			ui:ExternalInterfaceCall("setAnchor","left","mouse","left")
		end
	end, "After")

	function CustomStatSystem.CreateCustomStatTooltip(displayName, description, width, height, tooltipType, icon, abilityId)
		local ui = Ext.GetUIByType(Data.UIType.tooltip)
		if ui then
			local this = ui:GetRoot()
			if this and this.tooltip_array then
				if tooltipType == "Ability" and icon and abilityId then
					this.tooltip_array[0] = Game.Tooltip.TooltipItemTypes.AbilityTitle
					this.tooltip_array[1] = displayName or ""
					this.tooltip_array[2] = Game.Tooltip.TooltipItemTypes.AbilityDescription
					this.tooltip_array[3] = abilityId
					this.tooltip_array[4] = description or ""
					this.tooltip_array[5] = ""
					this.tooltip_array[6] = ""
					this.tooltip_array[7] = ""

					Game.Tooltip.PrepareIcon(ui, string.format("tt_ability_%i", abilityId), icon, 128, 128)
				else
					this.tooltip_array[0] = Game.Tooltip.TooltipItemTypes.StatName
					this.tooltip_array[1] = displayName or ""
					this.tooltip_array[2] = Game.Tooltip.TooltipItemTypes.StatsDescription
					this.tooltip_array[3] = description or ""
				end
				
				--AbilityDescription = {{"AbilityId", "number"}, {"Description", "string"}, {"Description2", "string"}, {"CurrentLevelEffect", "string"}, {"NextLevelEffect", "string"}},
				

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
				
				--ui:ExternalInterfaceCall("clearAnchor")
				ui:ExternalInterfaceCall("setAnchor","left","mouse","left")
				CustomStatSystem.Visible = true

				ui:Invoke("addFormattedTooltip",0,0,true)
				--ui:ExternalInterfaceCall("setTooltipSize", width, height)
				--ui:Invoke("showFormattedTooltipAfterPos", false)

				local tf = this.formatTooltip or this.tf
				if tf then
					tf.x = 50
					tf.y = 90
				end
				--ui:ExternalInterfaceCall("keepUIinScreen", false)
			end
		end
	end

	Ext.RegisterNetListener("LeaderLib_CreateCustomStatTooltip", function(cmd, payload)
		if CustomStatSystem.Requesting then
			CustomStatSystem.Requesting = false
			local data = Common.JsonParse(payload)
			if data then
				local statDouble = data.Stat
				if string.find(data.DisplayName, "_", 1, true) then
					data.DisplayName = GameHelpers.Tooltip.ReplacePlaceholders(GameHelpers.GetStringKeyText(data.DisplayName, data.DisplayName))
					print(data.DisplayName)
				end
				if string.find(data.Description, "_", 1, true) then
					data.Description = GameHelpers.Tooltip.ReplacePlaceholders(GameHelpers.GetStringKeyText(data.Description, data.Description))
				end

				if data.Icon then
					local iconId = CustomStatSystem.GetNextCustomStatIconId()
					CustomStatSystem.CreateCustomStatTooltip(data.DisplayName, data.Description, data.Width, data.Height, "Ability", data.Icon, iconId)
				else
					CustomStatSystem.CreateCustomStatTooltip(data.DisplayName, data.Description, data.Width, data.Height)
				end
			end
		end
	end)
end