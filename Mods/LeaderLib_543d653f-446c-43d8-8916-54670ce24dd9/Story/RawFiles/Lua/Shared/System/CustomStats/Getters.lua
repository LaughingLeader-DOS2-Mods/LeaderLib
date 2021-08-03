local self = CustomStatSystem
local isClient = Ext.IsClient() 

--region Stat/Category Getting
---@param displayName string
---@return CustomStatData
function CustomStatSystem:GetStatByName(displayName)
	for uuid,stats in pairs(self.Stats) do
		for id,stat in pairs(stats) do
			if stat.DisplayName == displayName or stat:GetDisplayName() == displayName then
				return stat
			end
		end
	end
	for uuid,stat in pairs(self.UnregisteredStats) do
		if stat.DisplayName == displayName then
			return stat
		end
	end
	return nil
end

---@param id string The stat id (not the UUID created by the game).
---@param mod string|nil Optional mod UUID to filter for.
---@return CustomStatData
function CustomStatSystem:GetStatByID(id, mod)
	if not self.Loaded then
		return nil
	end
	if not StringHelpers.IsNullOrWhitespace(mod) then
		local stats = self.Stats[mod]
		if stats and stats[id] then
			return stats[id]
		end
	end
	for uuid,stats in pairs(self.Stats) do
		local stat = stats[id]
		if stat then
			return stat
		end
	end
	local stat = self.UnregisteredStats[id]
	if stat then
		return stat
	end
	fprint(LOGLEVEL.WARNING, "[CustomStatSystem:GetStatByID] Failed to find stat for id(%s) and mod(%s)", id, mod or "")
	return nil
end

---@param uuid string Unique UUID for the stat.
---@return CustomStatData
function CustomStatSystem:GetStatByUUID(uuid)
	for mod,stats in pairs(self.Stats) do
		for id,stat in pairs(stats) do
			if stat.UUID == uuid then
				return stat
			end
		end
	end
	return nil
end

---Get an iterator of all stats.
---@param inSheetOnly boolean|nil Only get stats in the character sheet,
---@param sortStats boolean|nil
---@param includeUnregisteredStats boolean|nil
---@return fun():CustomStatData
function CustomStatSystem:GetAllStats(inSheetOnly, sortStats, includeUnregisteredStats)
	local allStats = {}

	local findAll = true

	if inSheetOnly == true and isClient then
		local ui = Ext.GetUIByType(Data.UIType.characterSheet)
		if ui then
			local this = ui:GetRoot()
			if not this then
				return
			end
			findAll = false
			local arr = this.stats_mc.customStats_mc.stats_array
			for i=0,#arr-1 do
				local stat_mc = arr[i]
				if stat_mc and stat_mc.statID then
					local stat = self:GetStatByDouble(stat_mc.statID)
					if stat then
						allStats[#allStats+1] = stat
					end
				end
			end
		end
	end

	if findAll then
		for uuid,stats in pairs(self.Stats) do
			for id,stat in pairs(stats) do
				allStats[#allStats+1] = stat
			end
		end
		if includeUnregisteredStats then
			for uuid,stat in pairs(self.UnregisteredStats) do
				allStats[#allStats+1] = stat
			end
		end
	end

	if sortStats == true then
		-- table.sort(allStats, function(a,b)
		-- 	return a:GetDisplayName() < b:GetDisplayName()
		-- end)
		table.sort(allStats, CustomStatSystem.SortStats)
	end

	local i = 0
	local count = #allStats
	return function ()
		i = i + 1
		if i <= count then
			return allStats[i]
		end
	end
end

---@param id string
---@param mod string
---@return CustomStatCategoryData
function CustomStatSystem:GetCategoryById(id, mod)
	if mod then
		local categories = self.Categories[mod]
		if categories and categories[id] then
			return categories[id]
		end
	end
	for uuid,categories in pairs(self.Categories) do
		if categories[id] then
			return categories[id]
		end
	end
	return nil
end

---@param groupId integer
---@return CustomStatCategoryData
function CustomStatSystem:GetCategoryByGroupId(groupId)
	for uuid,categories in pairs(self.Categories) do
		for id,category in pairs(categories) do
			if category.GroupId == groupId then
				return category
			end
		end
	end
	return nil
end

---Gets the Group ID for a stat that will be used in the characterSheet.
---@param id string The category ID.
---@param mod string Optional mod UUID.
---@return integer
function CustomStatSystem:GetCategoryGroupId(id, mod)
	if not id then
		return self.MISC_CATEGORY
	end
	if mod then
		local categories = self.Categories[mod]
		if categories and categories[id] then
			return categories[id].GroupId or self.MISC_CATEGORY
		end
	end
	for uuid,categories in pairs(self.Categories) do
		if categories[id] then
			return categories[id].GroupId or self.MISC_CATEGORY
		end
	end
	return self.MISC_CATEGORY
end

---Get an iterator of sorted categories.
---@param skipSort boolean|nil
---@return fun():CustomStatCategoryData
function CustomStatSystem:GetAllCategories(skipSort)
	local allCategories = {}

	local index = 0
	--To avoid duplicate categories by the same id, we set a dictionary first
	for uuid,categories in pairs(self.Categories) do
		for id,category in pairs(categories) do
			category.Index = index
			index = index + 1
			allCategories[id] = category
		end
	end

	---@type CustomStatCategoryData[]
	local categories = {}
	for k,v in pairs(allCategories) do
		categories[#categories+1] = v
	end
	if skipSort ~= true then
		table.sort(categories, function(a,b)
			local name1 = a:GetDisplayName()
			local name2 = b:GetDisplayName()
			local sortVal1 = a.Index
			local sortVal2 = b.Index
			local trySortByValue = false
			if a.SortName then
				name1 = a.SortName
			end
			if a.SortValue then
				sortVal1 = a.SortValue
				trySortByValue = true
			end
			if b.SortName then
				name2 = b.SortName
			end
			if b.SortValue then
				sortVal2 = b.SortValue
				trySortByValue = true
			end
			if trySortByValue and sortVal1 ~= sortVal2 then
				return sortVal1 < sortVal2
			end
			return name1 < name2
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

---Gets the total number of registered stats for a category.
---@param categoryId string
---@param visibleOnly boolean|nil
---@return integer
function CustomStatSystem:GetTotalStatsInCategory(categoryId, visibleOnly)
	local total = 0
	local isUnsortedCategory = StringHelpers.IsNullOrWhitespace(categoryId)
	for mod,stats in pairs(self.Stats) do
		for id,stat in pairs(stats) do
			local statIsVisible = not StringHelpers.IsNullOrWhitespace(stat.UUID) and self:GetStatVisibility(nil, stat.Double, stat) == true
			if (not visibleOnly or (visibleOnly == true and statIsVisible))
			and ((isUnsortedCategory and StringHelpers.IsNullOrWhitespace(stat.Category)) 
			or stat.Category == categoryId)
			then
				total = total + 1
			end
		end
	end
	if isUnsortedCategory then
		for uuid,stat in pairs(self.UnregisteredStats) do
			total = total + 1
		end
	end
	return total
end

---@param double number
---@return CustomStatData
function CustomStatSystem:GetStatByDouble(double)
	for mod,stats in pairs(CustomStatSystem.Stats) do
		for id,stat in pairs(stats) do
			if stat.Double == double then
				return stat
			end
		end
	end
	for uuid,stat in pairs(CustomStatSystem.UnregisteredStats) do
		if stat.Double == double then
			return stat
		end
	end
	return nil
end
--endregion

--region Value Getters

---@param id string The stat ID or UUID.
---@param mod string|nil Optional mod UUID to filter for.
function CustomStatSystem:GetStatValueForCharacter(character, id, mod)
	if not character then
		if Ext.IsServer() then
			character = Ext.GetCharacter(CharacterGetHostCharacter())
		else
			character = self:GetCharacter()
		end
	end
	local statValue = 0
	local stat = self:GetStatByID(id, mod) or self:GetStatByUUID(id)
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
function CustomStatSystem:GetStatValueForCategory(character, id, mod)
	if not character then
		if Ext.IsServer() then
			character = Ext.GetCharacter(CharacterGetHostCharacter())
		else
			character = self:GetCharacter()
		end
	end
	local statValue = 0
	---@type CustomStatCategoryData
	local category = nil
	if Ext.IsClient() and type(id) == "number" then
		category = self:GetCategoryByGroupId(id)
	else
		category = self:GetCategoryById(id, mod)
	end
	if not category then
		return 0
	end
	for uuid,stats in pairs(self.Stats) do
		for statId,stat in pairs(stats) do
			if stat.Category == category.ID then
				statValue = statValue + self:GetStatValueForCharacter(character, id, mod)
			end
		end
	end
	return statValue
end

--endregion

---@private
---@vararg function[]
function CustomStatSystem:GetListenerIterator(...)
	local tables = {...}
	local totalCount = #tables
	if totalCount == 0 then
		return
	end
	local listeners = {}
	for _,v in pairs(tables) do
		local t = type(v)
		if t == "table" then
			for _,v2 in pairs(v) do
				listeners[#listeners+1] = v2
			end
		elseif t == "function" then
			listeners[#listeners+1] = v
		end
	end
	local i = 0
	return function ()
		i = i + 1
		if i <= totalCount then
			return listeners[i]
		end
	end
end

local function TryGetSheetCharacter(this)
	if this.charHandle ~= nil and not GameHelpers.Math.IsNaN(this.charHandle) then
		return Ext.GetCharacter(Ext.DoubleToHandle(this.charHandle))
	end
end

---@return EclCharacter
function CustomStatSystem:GetCharacter(ui, this)
	if isClient then
		ui = ui or Ext.GetUIByType(Data.UIType.characterSheet)
		if ui then
			this = this or ui:GetRoot()
			if this then
				local b,client = xpcall(TryGetSheetCharacter, debug.traceback, this)
				if b and client ~= nil then
					return client
				end
			end
		end
		return Client:GetCharacter()
	end
end

if isClient then
	---@private
	function CustomStatSystem:GetStatVisibility(ui, doubleHandle, stat, character)
		if GameHelpers.Client.IsGameMaster(ui) == true then
			return true
		end
		character = character or self:GetCharacter()
		stat = stat or (doubleHandle and self:GetStatByDouble(doubleHandle))
		if stat then
			local isVisible = true
			if stat.Visible ~= nil then
				isVisible = stat.Visible
			end
			for listener in self:GetListenerIterator(self.Listeners.GetStatVisibility[stat.ID], self.Listeners.GetStatVisibility.All) do
				local b,result = xpcall(listener, debug.traceback, stat.ID, stat, character, isVisible)
				if b then
					if type(result) == "boolean" then
						isVisible = result
					end
				else
					fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:GetStatVisibility] Error calling GetStatVisibility listener for stat (%s):\n%s", stat.ID, result)
				end
			end
			return isVisible
		end
		return true
	end
end