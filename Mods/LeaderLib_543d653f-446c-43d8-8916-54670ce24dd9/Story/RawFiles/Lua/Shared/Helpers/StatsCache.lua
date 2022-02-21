---@type table<string, table<StatType,boolean>>
local _statNameToType = {}

---@type table<StatType, StatEntryArmor|StatEntryCharacter|StatEntryObject|StatEntryPotion|StatEntryShield|StatEntrySkillData|StatEntryStatusData|StatEntryWeapon[]>
local _cachedStatData = {}

local _colorPattern = 'new itemcolor "(.+)","(.+)","(.*)","(.*)"'

local function _CacheItemColor()
	_cachedStatData.ItemColor = {}
	local order = Ext.GetModLoadOrder()
	for i=1,#order do
		local uuid = order[i]
		local info = Ext.GetModInfo(uuid)
		if info ~= nil then
			local filePath = string.format("Public/%s/Stats/Generated/Data/ItemColor.txt", info.Directory)
			local text = Ext.LoadFile(filePath, "data")
			--local filePathWithoutSpaces = string.format("Mods/%s/CharacterCreation/ClassPresets/%s.lsx", info.Directory, StringHelpers.RemoveWhitespace(classType))
			if text then
				for line in StringHelpers.GetLines(text) do
					local s,e,id,c1,c2,c3 = string.find(line, _colorPattern)
					if id and c3 then
						_cachedStatData.ItemColor[id] = {"#"..c1,"#"..c2,"#"..c3}
					end
				end
			end
		end
	end
	return _cachedStatData.ItemColor
end

local _validStatTypes = {
	Armor = true,
	DeltaMod = true,
	Object = true,
	Potion = true,
	Shield = true,
	SkillData = true,
	StatusData = true,
	Weapon = true,
	SkillSet = true,
	EquipmentSet = true,
	TreasureTable = true,
	TreasureCategory = true,
	ItemCombination = true,
	ItemComboProperty = true,
	CraftingPreviewData = true,
	ItemGroup = true,
	NameGroup = true,
}

---@param statType StatType
local function _GetCachedStatType(statType)
	if _cachedStatData[statType] == nil then
		if statType == "ItemColor" then
			return _CacheItemColor()
		elseif _validStatTypes[statType] then
			_cachedStatData[statType] = Ext.GetStatEntries(statType)
			local length = #_cachedStatData[statType]
			for i=1,length do
				local name = _cachedStatData[statType][i]
				--TODO Can stats of different type have the same ID?
				-- if not _statNameToType[name] then
				-- 	_statNameToType[name] = {}
				-- end
				-- _statNameToType[name][statType] = true
				_statNameToType[name] = statType
			end
		end
	end
	return _cachedStatData[statType]
end

---Stats that typically exists as some sort of object, whether it's an item or skill/status data passed by a function.
local _identifierStatType = {
	Armor = true,
	Object = true,
	Potion = true,
	Shield = true,
	SkillData = true,
	StatusData = true,
	Weapon = true,
}

local function _CacheAllStatTypes(absolutelyEverything)
	if absolutelyEverything then
		for statType,b in pairs(_validStatTypes) do
			_GetCachedStatType(statType)
		end
	else
		for statType,b in pairs(_identifierStatType) do
			_GetCachedStatType(statType)
		end
	end
end

local function IsStatTypeValid(statType)
	return _validStatTypes[statType] == true
end

---@param statType StatType
---@param asStatsEntry ?boolean Return the StatEntrySkillData instead of string.
---@return fun():string|StatEntrySkillData
function GameHelpers.Stats.GetStats(statType, asStatsEntry)
	assert(IsStatTypeValid(statType), "statType must be one of the following: Armor|DeltaMod|Potion|Shield|SkillData|StatusData|Weapon")
	local _cache = _GetCachedStatType(statType)
	GameHelpers.IO.SaveJsonFile("Dumps/Stats_" .. statType .. ".json", _cache)
	if not asStatsEntry then
		local i = nil
		return function ()
			i = next(_cache, i)
			if i then
				return _cache[i],i
			end
		end
	else
		local i = nil
		return function ()
			i = next(_cache, i)
			if i then
				return Ext.GetStat(_cache[i]),i
			end
		end
	end
end

---@param asStatsEntry ?boolean Return the StatEntrySkillData instead of string.
---@return fun():string|StatEntrySkillData
function GameHelpers.Stats.GetSkills(asStatsEntry)
	return GameHelpers.Stats.GetStats("SkillData", asStatsEntry)
end

---@param asStatsEntry ?boolean Return the StatEntrySkillData instead of string.
---@return fun():string|StatEntryStatusData
function GameHelpers.Stats.GetStatuses(asStatsEntry)
	return GameHelpers.Stats.GetStats("StatusData", asStatsEntry)
end

---@param id string
---@return StatType
function GameHelpers.Stats.GetStatType(id)
	_CacheAllStatTypes()
	local t = _statNameToType[id]
	if t then
		return t
		--TODO Can stats of different type have the same ID?
		-- if Common.TableLength(types, true) == 1 then
		-- 	local statType,b = next(types)
		-- 	return statType
		-- else
		-- 	return types
		-- end
	end
	return nil
end

---@param id string
---@param statType StatType
---@return boolean
function GameHelpers.Stats.IsStatType(id, statType)
	assert(IsStatTypeValid(statType), "statType must be one of the following: Armor|DeltaMod|Object|Potion|Shield|SkillData|StatusData|Weapon")
	_GetCachedStatType(statType)
	local t = _statNameToType[id]
	if t then
		return t == statType
	end
	return false
end

--local item = Ext.GetItem(66419); print(Mods.LeaderLib.GameHelpers.Stats.IsStatType(item.StatsId))

--- Returns an ItemColor stat's colors.
--- @param name string The ID of the ItemColor.
--- @param asMaterialValues ?boolean
--- @return string[]
function GameHelpers.Stats.GetItemColor(name, asMaterialValues)
	local _itemColors = _GetCachedStatType("ItemColor")
	local entry = _itemColors[name]
	if asMaterialValues and entry then
		local c1,c2,c3 = table.unpack(entry)
		return {GameHelpers.Math.HexToMaterialRGBA(c1), GameHelpers.Math.HexToMaterialRGBA(c2), GameHelpers.Math.HexToMaterialRGBA(c3)}
	end
	return entry
end

---@param id string
---@param statType ?StatType
---@return boolean
function GameHelpers.Stats.Exists(id, statType)
	if statType then
		assert(IsStatTypeValid(statType), "statType must be one of the following: Armor|DeltaMod|Object|Potion|Shield|SkillData|StatusData|Weapon")
		_GetCachedStatType(statType)
		local t = _statNameToType[id]
		return t ~= nil
	else
		local b,stat = pcall(Ext.GetStat, id)
		return b and stat ~= nil
	end
end