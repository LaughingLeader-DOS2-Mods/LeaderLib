local self = CustomStatSystem

self.Visible = false
self.Requesting = false
local lastTooltipX = nil
local lastTooltipY = nil
self.LastIconId = 1212
self.TooltipValueEnabled = {}
self.MaxVisibleValue = 999 -- Values greater than this are truncated visually in the UI

---Called when a stat movieclip is added or updated in the UI.
---@alias CustomStatMovieClipAddedCallback fun(id:string, stat:CustomStatData, character:EsvCharacter, stat_mc:FlashCustomStat):void

---@type table<string, CustomStatMovieClipAddedCallback[]>
CustomStatSystem.Listeners.StatAdded = {All = {}}

---@param id string
---@param callback CustomStatMovieClipAddedCallback
function CustomStatSystem:RegisterStatAddedHandler(id, callback)
	if type(id) == "table" then
		for i=1,#id do
			self:RegisterStatAddedHandler(id[i], callback)
		end
	elseif self:CanAddListenerCallback(self.Listeners.StatAdded, id, callback) then
		table.insert(self.Listeners.StatAdded[id], callback)
	end
end

---@private
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

---@class CharacterSheetStatArrayData
---@field Index integer Original index
---@field DisplayName string
---@field Handle number
---@field Value number
---@field GroupId integer
---@field Stat CustomStatData|nil

---@private
---@param a CharacterSheetStatArrayData
---@param b CharacterSheetStatArrayData
function CustomStatSystem.SortStats(a,b)
	local name1 = a.DisplayName
	local name2 = b.DisplayName
	local sortVal1 = a.Index
	local sortVal2 = b.Index
	local trySortByValue = false
	if a.Stat then
		if a.Stat.SortName then
			name1 = a.Stat.SortName
		end
		if a.Stat.SortValue then
			sortVal1 = a.Stat.SortValue
			trySortByValue = true
		end
	end
	if b.Stat then
		if b.Stat.SortName then
			name2 = b.Stat.SortName
		end
		if b.Stat.SortValue then
			sortVal2 = b.Stat.SortValue
			trySortByValue = true
		end
	end
	if trySortByValue and sortVal1 ~= sortVal2 then
		return sortVal1 < sortVal2
	end
	return name1 < name2
end

local function OnSheetUpdating(ui, method)
	local this = ui:GetRoot()
	CustomStatSystem:SetupGroups(ui, method)

	local client = CustomStatSystem:GetCharacter(ui, this)
	if client then
		local changedStats = {NetID=client.NetID,Stats={}}
		for stat in CustomStatSystem:GetAllStats(false,false,true) do
			local last = stat:GetLastValue(client)
			local value = stat:GetValue(client)
			if last and value ~= last then
				changedStats.Stats[#changedStats.Stats+1] = {
					ID = stat.ID,
					Mod = stat.Mod,
					Last = last,
					Current = value
				}
				CustomStatSystem:InvokeStatValueChangedListeners(stat, client, last, value)
			end
			stat:UpdateLastValue(client)
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
		local groupId = self.MISC_CATEGORY
		local hideStat = false

		if doubleHandle then
			local stat = CustomStatSystem:GetStatByName(displayName)
			if stat then
				stat.Double = doubleHandle
				this.customStats_array[i+1] = stat:GetDisplayName()
				groupId = CustomStatSystem:GetCategoryGroupId(stat.Category, stat.Mod)
				if stat.Visible == false and not GameHelpers.Client.IsGameMaster(ui, this) then
					hideStat = true
				end
			end
			if not hideStat then
				sortList[#sortList+1] = {Index=i, DisplayName=this.customStats_array[i+1], Handle=doubleHandle, Value=value, GroupId=groupId, Stat=stat}
			end
		end
	end

	if #sortList > 0 then
		table.sort(sortList, CustomStatSystem.SortStats)

		--Remove any stats that were hidden
		this.clearArray("customStats_array")

		local arrayIndex = 0
		for i=1,#sortList do
			local v = sortList[i]
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

local initializedGroups = false
local lastScrollY = 0

---@private
function CustomStatSystem:SetupGroups(ui, call)
	local isGM = GameHelpers.Client.IsGameMaster()
	local this = ui:GetRoot().stats_mc.customStats_mc
	lastScrollY = this.list.m_scrollbar_mc.m_scrolledY
	if not initializedGroups then
		this.resetGroups()
	end
	-- Group for stats without an assigned category
	this.addGroup(CustomStatSystem.MISC_CATEGORY, miscGroupDisplayName.Value, false, self:GetTotalStatsInCategory(nil, true) > 0)
	for category in self:GetAllCategories() do
		local isVisible = isGM or category.ShowAlways or self:GetTotalStatsInCategory(category.ID, true) > 0
		this.addGroup(category.GroupId, category:GetDisplayName(), false, isVisible)
	end
	--this.positionElements(false)
	if not initializedGroups then
		this.positionElements(true, "groupId")
		initializedGroups = true
	end
end

---@private
function CustomStatSystem:OnUpdateDone(ui, call)
	local this = ui:GetRoot().stats_mc.customStats_mc
	this.recountAllPoints()
	self:UpdateAvailablePoints(ui, call)
	this.positionElements()
	this.list.m_scrollbar_mc.scrollTo(lastScrollY)
end

---@private
function CustomStatSystem:OnGroupAdded(ui, call, id, label, arrayIndex)
	local this = ui:GetRoot().stats_mc.customStats_mc
	local category = self:GetCategoryByGroupId(id)
	if this.groups_array then
		local group_mc = this.groups_array[arrayIndex]
		if group_mc then
			if category then
				if category.IsOpen ~= nil then
					group_mc.setIsOpen(category.IsOpen)
				end
				if category.HideTotalPoints == true then
					group_mc.hidePoints = true
					group_mc.amount_txt.visible = false
				else
					group_mc.hidePoints = false
					group_mc.amount_txt.visible = true
				end
			else
				group_mc.setIsOpen(true)
				group_mc.hidePoints = false
				group_mc.amount_txt.visible = true
			end
		end
	end
	if category and category.Description then
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

---@private
function CustomStatSystem:OnGroupClicked(ui, call, arrayIndex, groupId, isOpen, groupName)
	local category = self:GetCategoryByGroupId(groupId)
	if category then
		category.IsOpen = isOpen
	end
end

Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", OnSheetUpdating)
Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "clearStats", function(...) CustomStatSystem:SetupGroups(...) end)
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "customStatsGroupAdded", function(...) CustomStatSystem:OnGroupAdded(...) end)
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "characterSheetUpdateDone", function(...) CustomStatSystem:OnUpdateDone(...) end, "After")
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "customStatAdded", function(...) CustomStatSystem:OnStatAdded(...) end, "After")
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "statCategoryCollapseChanged", function(...) CustomStatSystem:OnGroupClicked(...) end, "After")
--Ext.RegisterUITypeCall(Data.UIType.characterSheet, "createCustomStatGroups", CustomStatSystem.SetupGroups)
--Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "setPlayerInfo", AdjustCustomStatMovieClips)


---@private
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

---@private
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
		--stat_mc.text_txt.x = 187.5;
		--stat_mc.text_txt.width = 64
	elseif stat and stat.DisplayValueInTooltip ~= true then
		self.TooltipValueEnabled[stat.ID] = nil
	end

	if stat then
		stat_mc.label_txt.htmlText = stat:GetDisplayName()
		if stat.DisplayMode == "Percentage" then
			local text = string.format("%s%%", math.floor(stat_mc.am))
			if stat_mc.text_txt.htmlText ~= text then
				stat_mc.text_txt.htmlText = text
			end
		end

		local character = Client:GetCharacter()
		for listener in self:GetListenerIterator(self.Listeners.StatAdded[stat.ID], self.Listeners.StatAdded.All) do
			local b,err = xpcall(listener, debug.traceback, stat.ID, stat, character, stat_mc)
			if not b then
				fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:OnStatPointRemoved] Error calling OnAvailablePointsChanged listener for stat (%s):\n%s", stat.ID, err)
			end
		end
	end
end

--ExternalInterface.call(param2,param1.statId,val3.x + val5,val3.y + val4,val6,param1.height,param1.tooltipAlign);

---@private
---@param statId number
---@param character EclCharacter
function CustomStatSystem:OnRequestTooltip(ui, call, statId, character, x, y, width, height, alignment)
	self.Requesting = false
	---@type CustomStatData
	local stat = self:GetStatByDouble(statId)
	local statName = ""
	local statValue = nil

	if not character then
		if ui:GetTypeId() == Data.UIType.characterSheet then
			character = Ext.GetCharacter(ui:GetPlayerHandle())
			if not character then
				character = Client:GetCharacter()
			end
		else
			character = GameHelpers.Client.GetCharacter()
		end
	end

	if stat then
		statName = stat:GetDisplayName()
		statValue = stat:GetValue(character)
	end

	if ui:GetTypeId() == Data.UIType.characterSheet then
		if not stat then
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
		end
	else
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
			self:CreateCustomStatTooltip(displayName, description, width, height, stat.TooltipType, stat.Icon, stat.IconId, stat.IconWidth, stat.IconHeight)
		else
			self:CreateCustomStatTooltip(statName, nil, width, height)
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

---@private
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

---@private
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

---@private
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

---@private
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

---@private
function CustomStatSystem:CreateCustomStatTooltip(displayName, description, width, height, tooltipType, icon, iconId, iconWidth, iconHeight)
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
					Game.Tooltip.PrepareIcon(ui, string.format("tt_tag_%i", iconId), icon, iconWidth or 128, iconHeight or 128)
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

					Game.Tooltip.PrepareIcon(ui, string.format("tt_ability_%i", iconId), icon, iconWidth or 128, iconHeight or 128)
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

---@private
function CustomStatSystem:NetRequestCustomStatTooltip(cmd, payload)
	if self.Requesting then
		self.Requesting = false
		local data = Common.JsonParse(payload)
		if data then
			local statDouble = data.Stat
			if string.find(data.DisplayName, "_", 1, true) then
				data.DisplayName = GameHelpers.Tooltip.ReplacePlaceholders(GameHelpers.GetStringKeyText(data.DisplayName))
			end
			if string.find(data.Description, "_", 1, true) then
				data.Description = GameHelpers.Tooltip.ReplacePlaceholders(GameHelpers.GetStringKeyText(data.Description))
			end

			if data.Icon and data.TooltipType ~= "Stat" then
				local iconId = self:GetNextCustomStatIconId()
				self:CreateCustomStatTooltip(data.DisplayName, data.Description, data.Width, data.Height, data.TooltipType, data.Icon, iconId, data.IconWidth, data.IconHeight)
			else
				self:CreateCustomStatTooltip(data.DisplayName, data.Description, data.Width, data.Height)
			end
		end
	end
end

Ext.RegisterNetListener("LeaderLib_CreateCustomStatTooltip", function(...)
	CustomStatSystem:NetRequestCustomStatTooltip(...)
end)

---@private
---Displays custom stat values in a stat tooltip if the stat config has enabled DisplayValueInTooltip.
---@param ui UIObject
---@param character EclCharacter
---@param stat CustomStatData
---@param tooltip TooltipData
function CustomStatSystem:OnTooltip(ui, character, stat, tooltip)
	if self.TooltipValueEnabled[stat.ID] then
		local element = tooltip:GetLastElement({"StatsDescription", "TagDescription"})
		if element then
			local valueFormatted = StringHelpers.CommaNumber(stat:GetValue(character))
			local total = Ext.GetTranslatedString("h79b967bcg4197g498fgb1dcged15f69f7913", "Total")
			local text = string.format("<font color='#11D77A'>%s: %s%s</font>", total, valueFormatted, stat.DisplayMode == stat.STAT_DISPLAY_MODE.Percentage and "%" or "")
			if StringHelpers.IsNullOrWhitespace(element.Label) then
				element.Label = text
			else
				element.Label = string.format("%s<br>%s", element.Label, text)
			end
		end
	end
end