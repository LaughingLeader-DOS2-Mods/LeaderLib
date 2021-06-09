local self = CustomStatSystem

--region Stat/Category Getting
---@param displayName string
---@return CustomStatData
function CustomStatSystem:GetStatByName(displayName)
	for uuid,stats in pairs(self.Stats) do
		for id,stat in pairs(stats) do
			if stat.DisplayName == displayName then
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
	if mod then
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
---@param visibleOnly boolean|nil
---@param sortByDisplayName boolean|nil
---@return fun():CustomStatData
function CustomStatSystem:GetAllStats(visibleOnly, sortByDisplayName)
	local allStats = {}

	local findAll = true
	if visibleOnly == true and Ext.IsClient() then
		local ui = Ext.GetUIByType(Data.UIType.characterSheet)
		if ui then
			findAll = false
			local arr = ui:GetRoot().stats_mc.customStats_mc.stats_array
			for i=0,#arr-1 do
				local stat_mc = arr[i]
				if stat_mc and stat_mc.statId then
					local stat = self:GetStatByDouble(stat_mc.statId)
					if stat then
						allStats[#allStats+1] = stat
					end
				end
			end
		end
	end
	--If visibleOnly is false or we failed to get the UI
	if findAll then
		for uuid,stats in pairs(self.Stats) do
			for id,stat in pairs(stats) do
				allStats[#allStats+1] = stat
			end
		end
		-- for uuid,stats in pairs(self.UnregisteredStats) do
		-- 	for id,stat in pairs(stats) do
		-- 		allStats[#allStats+1] = stat
		-- 	end
		-- end
	end

	if sortByDisplayName == true then
		table.sort(allStats, function(a,b)
			return a:GetDisplayName() < b:GetDisplayName()
		end)
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

---@param id string
---@param mod string
---@return integer
function CustomStatSystem:GetCategoryGroupId(id, mod)
	if not id then
		return 0
	end
	if mod then
		local categories = self.Categories[mod]
		if categories and categories[id] then
			return categories[id].GroupId or 0
		end
	end
	for uuid,categories in pairs(self.Categories) do
		if categories[id] then
			return categories[id].GroupId or 0
		end
	end
	return 0
end

---Get an iterator of sorted categories.
---@param skipSort boolean|nil
---@return fun():CustomStatCategoryData
function CustomStatSystem:GetAllCategories(skipSort)
	local allCategories = {}

	--To avoid duplicate categories by the same id, we set a dictionary first
	for uuid,categories in pairs(self.Categories) do
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

---Gets the total number of registered stats for a category.
---@param categoryId string
---@param visibleOnly boolean|nil
---@return integer
function CustomStatSystem:GetTotalStatsInCategory(categoryId, visibleOnly)
	local total = 0
	local isUnsortedCategory = StringHelpers.IsNullOrWhitespace(id)
	for mod,stats in pairs(CustomStatSystem.Stats) do
		for id,stat in pairs(stats) do
			local statIsVisible = stat.Visible ~= false and not StringHelpers.IsNullOrWhitespace(stat.UUID)
			if (not visibleOnly or (visibleOnly == true and statIsVisible))
			and ((isUnsortedCategory and StringHelpers.IsNullOrWhitespace(stat.Category)) 
			or stat.Category == categoryId)
			then
				total = total + 1
			end
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
			character = Client:GetCharacter()
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
			character = Client:GetCharacter()
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