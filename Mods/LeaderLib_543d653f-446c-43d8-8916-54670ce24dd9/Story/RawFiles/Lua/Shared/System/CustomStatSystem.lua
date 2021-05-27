if CustomStatSystem == nil then
	CustomStatSystem = {}
end

---@class CustomStatTooltipType
CustomStatSystem.TooltipType = {
	Default = "Stat",
	Ability = "Ability", -- Icon
	Stat = "Stat",
	Tag = "Tag", -- Icon
}


---@class CustomStatCategoryData:CustomStatDataBase
---@field ID string
---@field Mod string The mod UUID that added this stat, if any. Auto-set.
---@field DisplayName string
---@field Description string
---@field Icon string|nil
---@field ShowAlways boolean|nil Whether to always show this category or not. If false, it will only show when a child stat is active.
---@field TooltipType CustomStatTooltipType|nil
---@field GroupId integer Auto-generated integer id used in the characterSheet swf.

---@class CustomStatData:CustomStatDataBase
---@field ID string
---@field Mod string The mod UUID that added this stat, if any. Auto-set.
---@field DisplayName string
---@field Description string
---@field Icon string|nil
---@field Create boolean|nil Whether the server should create this stat automatically.
---@field TooltipType CustomStatTooltipType|nil
---@field Category string The stat's category id, if any.
---@field Double number The stat's double (handle) value. Determined dynamically.

---@alias MOD_UUID string
---@alias STAT_ID string

---@type table<MOD_UUID, table<STAT_ID, CustomStatCategoryData>>
CustomStatSystem.Categories = {}
---@type table<MOD_UUID, table<STAT_ID, CustomStatData>>
CustomStatSystem.Stats = {}

---@type fun():table<string, table<string, CustomStatData>>
local loader = Ext.Require("Shared/Settings/CustomStatsConfigLoader.lua")

local function LoadCustomStatsData()
	local categories,stats = loader()
	TableHelpers.AddOrUpdate(CustomStatSystem.Categories, categories)
	TableHelpers.AddOrUpdate(CustomStatSystem.Stats, stats)

	if Ext.IsServer() then
		for uuid,stats in pairs(CustomStatSystem.Stats) do
			local modName = Ext.GetModInfo(uuid).Name
			for id,stat in pairs(stats) do
				if stat.Create == true and stat.DisplayName then
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
	else
		local categoryId = 1 -- 0 is Misc
		for category in CustomStatSystem.GetAllCategories() do
			category.GroupId = categoryId
			categoryId = categoryId + 1
		end
	end

	-- if Vars.DebugMode then
	-- 	print(Ext.IsServer() and "SERVER" or "CLIENT")
	-- 	print("Categories", Ext.JsonStringify(CustomStatSystem.Categories))
	-- 	print("Stats", Ext.JsonStringify(CustomStatSystem.Stats))
	-- end
end

Ext.RegisterListener("SessionLoaded", LoadCustomStatsData)
RegisterListener("LuaReset", LoadCustomStatsData)

--region Stat/Category Getting
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

---@param id string The stat id (not the UUID created by the game).
---@param mod string|nil Optional mod UUID to filter for.
---@return CustomStatData
function CustomStatSystem.GetStatByID(id, mod)
	if mod then
		local stats = CustomStatSystem.Stats[mod]
		if stats and stats[id] then
			return stats[id]
		end
	end
	for uuid,stats in pairs(CustomStatSystem.Stats) do
		local stat = stats[id]
		if stat then
			return stat
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

---@param id string
---@param mod string
---@return CustomStatCategoryData
function CustomStatSystem.GetCategoryById(id, mod)
	if mod then
		local categories = CustomStatSystem.Categories[mod]
		if categories and categories[id] then
			return categories[id]
		end
	end
	for uuid,categories in pairs(CustomStatSystem.Categories) do
		if categories[id] then
			return categories[id]
		end
	end
	return nil
end

---@param groupId integer
---@return CustomStatCategoryData
function CustomStatSystem.GetCategoryByGroupId(groupId)
	for uuid,categories in pairs(CustomStatSystem.Categories) do
		for id,category in pairs(categories) do
			if category.GroupId == groupId then
				return category
			end
		end
	end
	return nil
end

---@param id string
---@param mod string
---@return integer
function CustomStatSystem.GetCategoryGroupId(id, mod)
	if not id then
		return 0
	end
	if mod then
		local categories = CustomStatSystem.Categories[mod]
		if categories and categories[id] then
			return categories[id].GroupId or 0
		end
	end
	for uuid,categories in pairs(CustomStatSystem.Categories) do
		if categories[id] then
			return categories[id].GroupId or 0
		end
	end
	return 0
end

---Get an iterator of sorted categories.
---@param skipSort boolean|nil
---@return CustomStatCategoryData
function CustomStatSystem.GetAllCategories(skipSort)
	local allCategories = {}

	--To avoid duplicate categories by the same id, we set a dictionary first
	for uuid,categories in pairs(CustomStatSystem.Categories) do
		for id,category in pairs(categories) do
			allCategories[id] = category
		end
	end

	local categories = {}
	for k,v in pairs(allCategories) do
		categories[#categories+1] = v
	end
	if skipSort ~= true then
		table.sort(categories, function(a,b)
			return a:GetDisplayName() < b:GetDisplayName()
		end)
	end

	local i = 0
	local count = #categories
	return function ()
		i = i + 1
		if i <= count then
			return categories[i]
		end
	end
end
--endregion

--region Value Getters

---@param id string The stat ID or UUID.
---@param mod string|nil Optional mod UUID to filter for.
function CustomStatSystem.GetStatValueForCharacter(character, id, mod)
	if not character then
		if Ext.IsServer() then
			character = Ext.GetCharacter(CharacterGetHostCharacter())
		else
			character = Client:GetCharacter()
		end
	end
	local statValue = 0
	local stat = CustomStatSystem.GetStatByID(id, mod) or CustomStatSystem.GetStatByUUID(id)
	if stat then
		statValue = stat.Value or 0
		local characterObject = character
		local t = type(characterObject)
		if t == "string" or t == "number" then
			characterObject = Ext.GetCharacter(character)
		end
		if type(characterObject) == "userdata" and characterObject.GetCustomStat then
			statValue = characterObject:GetCustomStat(stat.UUID) or stat.Value or 0
		else
			fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem.GetStatValueForCharacter] Failed to get character from param (%s) stat(%s) mod(%s)", character, stat or "", mod or "")
		end
	end
	return statValue
end

---@param id string|integer The category ID or GroupId.
---@param mod string|nil Optional mod UUID to filter for.
function CustomStatSystem.GetStatValueForCategory(character, id, mod)
	if not character then
		if Ext.IsServer() then
			character = Ext.GetCharacter(CharacterGetHostCharacter())
		else
			character = Client:GetCharacter()
		end
	end
	local statValue = 0
	---@type CustomStatCategoryData
	local category = nil
	if Ext.IsClient() and type(id) == "number" then
		category = CustomStatSystem.GetCategoryByGroupId(id)
	else
		category = CustomStatSystem.GetCategoryById(id, mod)
	end
	if not category then
		return 0
	end
	for uuid,stats in pairs(CustomStatSystem.Stats) do
		for statId,stat in pairs(stats) do
			if stat.Category == category.ID then
				statValue = statValue + CustomStatSystem.GetStatValueForCharacter(character, id, mod)
			end
		end
	end
	return statValue
end

--endregion

---@param character EsvCharacter|EclCharacter
---@return boolean
function CustomStatSystem.IsTooltipWorking(character)
	if Ext.IsClient() then
		local characterData = Client:GetCharacterData()
		if characterData then
			return characterData.IsGameMaster and not characterData.IsPossessed
		end
	else
		character = character or (Client and Client:GetCharacter()) or nil
		if character then
			--return character.IsPossessed or (not character.IsGameMaster and character.IsPlayer) and character.UserID > -1
			return character.IsGameMaster and not character.IsPossessed
		end
	end
	return false
end

if Ext.IsServer() then
	local canFix = Ext.GetCustomStatByName ~= nil
	Ext.RegisterNetListener("LeaderLib_CheckCustomStatCallback", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local statDouble = data.Stat
			local character = Ext.GetCharacter(data.Character)
			if character and CustomStatSystem.IsTooltipWorking(character) then
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
	--Creates a table of stat id to uuid, for sending stat UUIDs to the client
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
	Ext.AddPathOverride("Public/Game/GUI/characterSheet.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/characterSheet.swf")
	--Ext.AddPathOverride("Public/Game/GUI/characterSheet.swf", "Public/Game/GUI/characterSheet.swf")
	--Loads a table of stat UUIDs from the server.
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

					mc.label_txt.htmlText = stat:GetDisplayName()

					print(stat, stat.UUID, stat.DisplayName, mc.label_txt.htmlText)
				end
			end
		end
	end

	local function OnSheetUpdating(ui, method)
		local this = ui:GetRoot()
		CustomStatSystem.SetupGroups(ui, method)
		local length = #this.customStats_array
		if length == 0 then
			return
		end
		--this.stats_mc.panelBg1_mc.visible = true;
		--this.stats_mc.panelBg2_mc.visible = true;
		local sortList = {}
		for i=0,length,3 do
			local doubleHandle = this.customStats_array[i]
			local displayName = this.customStats_array[i+1]
			local value = this.customStats_array[i+2]
			local groupId = 0

			if doubleHandle then
				local stat = CustomStatSystem.GetStatByName(displayName)
				if stat then
					stat.Double = doubleHandle
					this.customStats_array[i+1] = stat:GetDisplayName()
					groupId = CustomStatSystem.GetCategoryGroupId(stat.Category, stat.Mod)
				end
				sortList[#sortList+1] = {DisplayName=this.customStats_array[i+1], Handle=doubleHandle, Value=value, GroupId=groupId}
			end
		end

		if #sortList > 0 then
			table.sort(sortList, function(a,b)
				return a.DisplayName < b.DisplayName
			end)
	
			local arrayIndex = 0
			for _,v in pairs(sortList) do
				this.customStats_array[arrayIndex] = v.Handle
				this.customStats_array[arrayIndex+1] = v.DisplayName
				this.customStats_array[arrayIndex+2] = v.Value
				this.customStats_array[arrayIndex+3] = v.GroupId
				arrayIndex = arrayIndex + 4
			end
		end
	end

	local miscGroupDisplayName = Classes.TranslatedString:Create("hb8ed2061ge5a3g4f64g9d54g9a9b65e27e1e", "Miscellaneous")

	function CustomStatSystem.SetupGroups(ui, call)
		local this = ui:GetRoot().stats_mc.customStats_mc
		this.resetGroups()
		this.addGroup(0, miscGroupDisplayName.Value, false) -- Group for stats without an assigned category
		for category in CustomStatSystem.GetAllCategories() do
			this.addGroup(category.GroupId, category:GetDisplayName(), false)
		end
		this.positionElements()
	end

	function CustomStatSystem.OnGroupAdded(ui, call, id)
		local category = CustomStatSystem.GetCategoryByGroupId(id)
		if category and category.Description then
			local this = ui:GetRoot().stats_mc.customStats_mc
			this.setGroupTooltip(category.GroupId, category:GetDescription())
		end
	end

	--print(Ext.GetUIByType(119):GetRoot().stats_mc.customStats_mc.clearElements)
	--local array = Ext.GetUIByType(119):GetRoot().stats_mc.customStats_mc.list.content_array; print(#array)

	-- Ext.RegisterUITypeCall(Data.UIType.characterSheet, "selectedTab", function(ui, call, tab)
	-- 	if tab == 8 then
	-- 		local this = ui:GetRoot()
	-- 		this.stats_mc.panelBg1_mc.visible = true

	-- 		this.stats_mc.customStats_mc.y = 292;
	-- 		this.stats_mc.customStats_mc.x = 12;
	-- 		this.stats_mc.create_mc.x = 53;
	-- 	end
	-- end, "Before")
	Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", OnSheetUpdating)
	Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "clearStats", CustomStatSystem.SetupGroups)
	Ext.RegisterUITypeCall(Data.UIType.characterSheet, "customStatsGroupAdded", CustomStatSystem.OnGroupAdded)
	--Ext.RegisterUITypeCall(Data.UIType.characterSheet, "createCustomStatGroups", CustomStatSystem.SetupGroups)
	--Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "setPlayerInfo", AdjustCustomStatMovieClips)

	--ExternalInterface.call(param2,param1.statId,val3.x + val5,val3.y + val4,val6,param1.height,param1.tooltipAlign);
	function CustomStatSystem.OnRequestTooltip(ui, call, statId, x, y, width, height, alignment)
		CustomStatSystem.Requesting = false
		---@type EclCharacter
		local character = nil
		---@type CustomStatData
		local stat = nil
		local statName = ""
		local statValue = nil

		if ui:GetTypeId() == Data.UIType.characterSheet then
			character = Ext.GetCharacter(ui:GetPlayerHandle())
			local this = ui:GetRoot()
			local stats = this.stats_mc.customStats_mc.stats_array
			for i=0,#stats do
				local mc = stats[i]
				if mc and mc.statId == statId then
					statName = mc.label_txt.htmlText
					statValue = tonumber(mc.text_txt.htmlText)
					stat = CustomStatSystem.GetStatByDouble(statId)
				end
			end
		else
			character = GameHelpers.Client.GetCharacter()
			x,y,width,height = 0,0,413,196
			alignment = "right"
		end

		if stat then
			if not CustomStatSystem.IsTooltipWorking() then
				local displayName,description = stat:GetDisplayName(),stat:GetDescription()
				if stat.Icon and stat.TooltipType ~= CustomStatSystem.TooltipType.Stat then
					stat.IconId = CustomStatSystem.GetNextCustomStatIconId()
				end
				CustomStatSystem.CreateCustomStatTooltip(displayName, description, width, height, stat.TooltipType, stat.Icon, stat.IconId)
			else
				CustomStatSystem.UpdateCustomStatTooltip(stat)
			end
		else
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
		end
	end
	--Ext.RegisterUINameCall("showCustomStatTooltip", CustomStatSystem.OnRequestTooltip, "Before")

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

	---@param doubleHandle number
	---@param tooltip TooltipData
	function CustomStatSystem.UpdateStatTooltipArray(ui, doubleHandle, tooltip, req)
		local stat = CustomStatSystem.GetStatByDouble(doubleHandle)
		if stat then
			req.StatData = stat
			tooltip.Data = {}
			local displayName,description = stat:GetDisplayName(),stat:GetDescription()
			if stat.Icon and stat.TooltipType ~= CustomStatSystem.TooltipType.Stat then
				stat.IconId = CustomStatSystem.GetNextCustomStatIconId()
			end
			local resolved = false
			local tooltipType = stat.TooltipType
			if stat.Icon and stat.IconId then
				if tooltipType == CustomStatSystem.TooltipType.Ability then
					tooltip:AppendElement({
						Type="StatName",
						Label=displayName
					})
					tooltip:AppendElement({
						Type="AbilityDescription",
						Description=description,
						AbilityId = stat.IconId,
						Description2 = "",
						CurrentLevelEffect = "",
						NextLevelEffect = ""
					})
					Game.Tooltip.PrepareIcon(ui, string.format("tt_ability_%i", stat.IconId), stat.Icon, 128, 128)
					resolved = true
				elseif tooltipType == CustomStatSystem.TooltipType.Tag then
					tooltip:AppendElement({
						Type="StatName",
						Label=displayName
					})
					tooltip:AppendElement({
						Type="TagDescription",
						Label=description,
						Image = stat.IconId
					})
					Game.Tooltip.PrepareIcon(ui, string.format("tt_tag_%i", stat.IconId), stat.Icon, 128, 128)
					resolved = true
				end
			end
			if not resolved then
				tooltip:AppendElement({
					Type="StatName",
					Label=displayName
				})
				tooltip:AppendElement({
					Type="StatsDescription",
					Label=description
				})
			end
		end
	end

	function CustomStatSystem.UpdateCustomStatTooltip(displayName, description, width, height, tooltipType, icon, iconId)
		local request = Game.Tooltip.TooltipHooks.NextRequest
		if request and request.Type == "CustomStat" then
			request.RequestUpdate = true
		end
		-- local ui = Ext.GetUIByType(Data.UIType.tooltip)
		-- if ui then
		-- 	local this = ui:GetRoot()
		-- 	if this and this.tooltip_array then
		-- 		print("tooltip_array", #this.tooltip_array)
		-- 		for i=0,#this.tooltip_array-1 do
		-- 			print(i, this.tooltip_array[i])
		-- 		end
		-- 	end
		-- end
	end

	function CustomStatSystem.CreateCustomStatTooltip(displayName, description, width, height, tooltipType, icon, iconId)
		Ext.Print("CustomStatSystem.CreateCustomStatTooltip", displayName, description, width, height, tooltipType, icon, iconId)
		local ui = Ext.GetUIByType(Data.UIType.tooltip)
		if ui then
			local this = ui:GetRoot()
			if this and this.tooltip_array then
				local resolved = false
				if icon and iconId and tooltipType ~= CustomStatSystem.TooltipType.Stat then
					if tooltipType == CustomStatSystem.TooltipType.Tag then
						this.tooltip_array[0] = Game.Tooltip.TooltipItemTypes.StatName
						this.tooltip_array[1] = displayName or ""
						this.tooltip_array[2] = Game.Tooltip.TooltipItemTypes.TagDescription
						this.tooltip_array[3] = description or ""
						this.tooltip_array[4] = iconId
						Game.Tooltip.PrepareIcon(ui, string.format("tt_tag_%i", stat.IconId), stat.Icon, 128, 128)
						resolved = true
					else
						this.tooltip_array[0] = Game.Tooltip.TooltipItemTypes.StatName
						this.tooltip_array[1] = displayName or ""
						this.tooltip_array[2] = Game.Tooltip.TooltipItemTypes.AbilityDescription
						this.tooltip_array[3] = iconId
						this.tooltip_array[4] = description or ""
						this.tooltip_array[5] = ""
						this.tooltip_array[6] = ""
						this.tooltip_array[7] = ""

						Game.Tooltip.PrepareIcon(ui, string.format("tt_ability_%i", iconId), icon, 128, 128)
						resolved = true
					end
				end
				if not resolved then
					this.tooltip_array[0] = Game.Tooltip.TooltipItemTypes.StatName
					this.tooltip_array[1] = displayName or ""
					this.tooltip_array[2] = Game.Tooltip.TooltipItemTypes.StatsDescription
					this.tooltip_array[3] = description or ""
				end

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

				--Game.Tooltip.TooltipHooks:OnRenderTooltip(Game.Tooltip.TooltipArrayNames.Default, ui, 0, 0, true)

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
					data.DisplayName = GameHelpers.Tooltip.ReplacePlaceholders(GameHelpers.GetStringKeyText(data.DisplayName))
					print(data.DisplayName)
				end
				if string.find(data.Description, "_", 1, true) then
					data.Description = GameHelpers.Tooltip.ReplacePlaceholders(GameHelpers.GetStringKeyText(data.Description))
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