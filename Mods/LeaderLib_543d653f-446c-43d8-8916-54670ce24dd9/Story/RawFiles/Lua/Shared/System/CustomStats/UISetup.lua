local self = CustomStatSystem

self.Visible = false
self.Requesting = false
local lastTooltipX = nil
local lastTooltipY = nil
self.LastIconId = 1212
self.TooltipValueEnabled = {}
self.MaxVisibleValue = 999 -- Values greater than this are truncated visually in the UI

function CustomStatSystem:GetNextCustomStatIconId()
	self.LastIconId = self.LastIconId + 1
	return self.LastIconId
end

--Ext.GetUIByType(63):GetRoot().showPanel(6)
--Ext.GetUIByType(63):GetRoot().addStatsTab(6, 0, "Extra Stats")

local function AdjustCustomStatMovieClips(ui)
	local this = ui:GetRoot()
	local arr = this.stats_mc.customStats_mc.list.content_array
	for i=0,#arr do
		local mc = arr[i]
		if mc then
			local displayName = mc.label_txt.htmlText
			local stat = CustomStatSystem:GetStatByName(displayName)
			if stat then
				stat.Double = mc.statId
				mc.label_txt.htmlText = stat:GetDisplayName()
			end
		end
	end
end

local function OnSheetUpdating(ui, method)
	local this = ui:GetRoot()
	CustomStatSystem:SetupGroups(ui, method)

	local client = Client:GetCharacter()
	if client then
		local changedStats = {NetID=client.NetID,Stats={}}
		for stat in CustomStatSystem:GetAllStats() do
			local last = stat.LastValue[client.MyGuid] or 0
			local value = stat:GetValue(client)
			if value ~= last then
				changedStats.Stats[#changedStats.Stats+1] = {
					ID = stat.ID,
					Mod = stat.Mod
				}
				CustomStatSystem:InvokeStatValueChangedListeners(stat, client, last, value)
			end
			stat.LastValue[client.MyGuid] = value
		end

		if #changedStats.Stats > 0 then
			Ext.PostMessageToServer("LeaderLib_CustomStatSystem_StatValuesChanged", Ext.JsonStringify(changedStats))
		end
	end

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
			local stat = CustomStatSystem:GetStatByName(displayName)
			if stat then
				stat.Double = doubleHandle
				this.customStats_array[i+1] = stat:GetDisplayName()
				groupId = CustomStatSystem:GetCategoryGroupId(stat.Category, stat.Mod)
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
			this.customStats_array[arrayIndex+4] = self:GetCanAddPoints(ui, v.Handle)
			this.customStats_array[arrayIndex+5] = self:GetCanRemovePoints(ui, v.Handle)
			arrayIndex = arrayIndex + 6
		end
	end
end

local miscGroupDisplayName = Classes.TranslatedString:Create("hb8ed2061ge5a3g4f64g9d54g9a9b65e27e1e", "Miscellaneous")

function CustomStatSystem:SetupGroups(ui, call)
	local this = ui:GetRoot().stats_mc.customStats_mc
	this.resetGroups()
	-- Group for stats without an assigned category
	this.addGroup(0, miscGroupDisplayName.Value, false, self:GetTotalStatsInCategory(nil, true) > 0)
	for category in self:GetAllCategories() do
		local isVisible = category.ShowAlways or self:GetTotalStatsInCategory(category.ID, true) > 0
		this.addGroup(category.GroupId, category:GetDisplayName(), false, isVisible)
	end
	this.positionElements()
end

function CustomStatSystem:OnUpdateDone(ui, call)
	self:UpdateAvailablePoints(ui, call)
end

function CustomStatSystem:OnGroupAdded(ui, call, id)
	local category = self:GetCategoryByGroupId(id)
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
Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "clearStats", function(...) CustomStatSystem:SetupGroups(...) end)
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "customStatsGroupAdded", function(...) CustomStatSystem:OnGroupAdded(...) end)
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "characterSheetUpdateDone", function(...) CustomStatSystem:OnUpdateDone(...) end, "After")
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "customStatAdded", function(...) CustomStatSystem:OnStatAdded(...) end, "After")
--Ext.RegisterUITypeCall(Data.UIType.characterSheet, "createCustomStatGroups", CustomStatSystem.SetupGroups)
--Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "setPlayerInfo", AdjustCustomStatMovieClips)


---@return FlashCustomStat
function CustomStatSystem:GetStatMovieClipByDouble(ui, statId)
	if ui:GetTypeId() == Data.UIType.characterSheet then
		character = Ext.GetCharacter(ui:GetPlayerHandle())
		local this = ui:GetRoot()
		local stats = this.stats_mc.customStats_mc.stats_array
		for i=0,#stats do
			local mc = stats[i]
			if mc and mc.statId == statId then
				return mc
			end
		end
	end
	return nil
end

function CustomStatSystem:OnStatAdded(ui, call, doubleHandle, index)
	---@type CharacterSheetMainTimeline
	local this = ui:GetRoot()

	local stat_mc = this.stats_mc.customStats_mc.stats_array[index]
	local stat = self:GetStatByDouble(doubleHandle)

	--[[
		Stat values greater than a certain amount have issues fitting into the UI, 
		so display a small version and use the tooltip to display the full value.
	]]
	if stat_mc.am > self.MaxVisibleValue then
		stat_mc.text_txt.htmlText = StringHelpers.GetShortNumberString(stat_mc.am)
		if stat and stat.DisplayValueInTooltip ~= false then
			self.TooltipValueEnabled[stat.ID] = true
		end
	elseif stat and stat.DisplayValueInTooltip ~= true then
		self.TooltipValueEnabled[stat.ID] = nil
	end
end

--ExternalInterface.call(param2,param1.statId,val3.x + val5,val3.y + val4,val6,param1.height,param1.tooltipAlign);
function CustomStatSystem:OnRequestTooltip(ui, call, statId, x, y, width, height, alignment)
	self.Requesting = false
	---@type EclCharacter
	local character = nil
	---@type CustomStatData
	local stat = nil
	local statName = ""
	local statValue = nil

	if ui:GetTypeId() == Data.UIType.characterSheet then
		character = Ext.GetCharacter(ui:GetPlayerHandle())
		---@type CharacterSheetMainTimeline
		local this = ui:GetRoot()
		local stats = this.stats_mc.customStats_mc.stats_array
		for i=0,#stats do
			local mc = stats[i]
			if mc and mc.statId == statId then
				statName = mc.label_txt.htmlText
				statValue = mc.am
				stat = self:GetStatByDouble(statId)
			end
		end
	else
		character = GameHelpers.Client.GetCharacter()
		x,y,width,height = 0,0,413,196
		alignment = "right"
	end

	if not stat then
		stat = self:GetStatByName(statName)
	end

	if not self:IsTooltipWorking() then
		if stat then
			local displayName,description = stat:GetDisplayName(),stat:GetDescription()
			if stat.Icon and stat.TooltipType ~= self.TooltipType.Stat then
				stat.IconId = self:GetNextCustomStatIconId()
			end
			self:CreateCustomStatTooltip(displayName, description, width, height, stat.TooltipType, stat.Icon, stat.IconId)
		else
			self:CreateCustomStatTooltip(statName, nil, width, height, stat.TooltipType, stat.Icon, stat.IconId)
		end
	else
		self:UpdateCustomStatTooltip(stat)
	end
	-- if character then
	-- 	local payload = Ext.JsonStringify({
	-- 		Character=character.NetID, 
	-- 		Stat=statId, 
	-- 		UI=ui:GetTypeId(),
	-- 		X = x,
	-- 		Y = y,
	-- 		Width = width,
	-- 		Height = height,
	-- 		Alignment = alignment,
	-- 		DisplayName = statName or "",
	-- 		StatId = statName or "",
	-- 		Value = statValue
	-- 	})
	-- 	self.Requesting = true
	-- 	Ext.PostMessageToServer("LeaderLib_CheckCustomStatCallback", payload)
	-- end
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

function CustomStatSystem:HideTooltip()
	self.LastIconId = 1212
	self.Requesting = false
	if self.Visible then
		self.Visible = false
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

function CustomStatSystem:OnToggleCharacterPane()
	if self.Visible then
		self:HideTooltip()
	end
end

Ext.RegisterUINameCall("hideTooltip", function(...) CustomStatSystem:HideTooltip(...) end)
---Workaround
Ext.RegisterUITypeCall(Data.UIType.tooltip, "clearAnchor", function(ui)
	if CustomStatSystem.Visible then
		ui:ExternalInterfaceCall("setAnchor","left","mouse","left")
	end
end, "After")

---@param doubleHandle number
---@param tooltip TooltipData
function CustomStatSystem:UpdateStatTooltipArray(ui, doubleHandle, tooltip, req)
	local stat = self:GetStatByDouble(doubleHandle)
	if stat then
		req.StatData = stat
		tooltip.Data = {}
		local displayName,description = stat:GetDisplayName(),stat:GetDescription()
		if stat.Icon and stat.TooltipType ~= self.TooltipType.Stat then
			stat.IconId = self:GetNextCustomStatIconId()
		end
		local resolved = false
		local tooltipType = stat.TooltipType
		if stat.Icon and stat.IconId then
			if tooltipType == self.TooltipType.Ability then
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
			elseif tooltipType == self.TooltipType.Tag then
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

function CustomStatSystem:UpdateCustomStatTooltip(displayName, description, width, height, tooltipType, icon, iconId)
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

function CustomStatSystem:CreateCustomStatTooltip(displayName, description, width, height, tooltipType, icon, iconId)
	Ext.Print("CustomStatSystem.CreateCustomStatTooltip", displayName, description, width, height, tooltipType, icon, iconId)
	local ui = Ext.GetUIByType(Data.UIType.tooltip)
	if ui then
		local this = ui:GetRoot()
		if this and this.tooltip_array then
			local resolved = false
			if icon and iconId and tooltipType ~= self.TooltipType.Stat then
				if tooltipType == self.TooltipType.Tag then
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
				if not StringHelpers.IsNullOrEmpty(description) then
					this.tooltip_array[2] = Game.Tooltip.TooltipItemTypes.StatsDescription
					this.tooltip_array[3] = description
				end
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
			self.Visible = true

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

function CustomStatSystem:NetRequestCustomStatTooltip(cmd, payload)
	if self.Requesting then
		self.Requesting = false
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
				local iconId = self:GetNextCustomStatIconId()
				self:CreateCustomStatTooltip(data.DisplayName, data.Description, data.Width, data.Height, "Ability", data.Icon, iconId)
			else
				self:CreateCustomStatTooltip(data.DisplayName, data.Description, data.Width, data.Height)
			end
		end
	end
end

Ext.RegisterNetListener("LeaderLib_CreateCustomStatTooltip", function(...)
	CustomStatSystem:NetRequestCustomStatTooltip(...)
end)

---Displays custom stat values in a stat tooltip if the stat config has enabled DisplayValueInTooltip.
---@param ui UIObject
---@param character EclCharacter
---@param stat CustomStatData
---@param tooltip TooltipData
function CustomStatSystem:OnTooltip(ui, character, stat, tooltip)
	if self.TooltipValueEnabled[stat.ID] then
		local element = tooltip:GetLastElement({"StatsDescription", "TagDescription"})
		if element then
			if StringHelpers.IsNullOrWhitespace(element.Label) then
				element.Label = string.format("(%s)", stat:GetValue(character))
			else
				element.Label = string.format("%s<br>(%s)", element.Label, stat:GetValue(character))
			end
		end
	end
end