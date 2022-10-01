local _type = type

--TODO Replace with ModifierListIndex in v56?
---@type table<string, table<StatType,boolean>>
local _statNameToType = {}

---@type table<StatType, StatEntryType[]>
local _cachedStatData = {}

local _colorPattern = 'new itemcolor "(.+)","(.+)","(.*)","(.*)"'

local function _CacheItemColor()
	_cachedStatData.ItemColor = {}
	local order = Ext.Mod.GetLoadOrder()
	for i=1,#order do
		local uuid = order[i]
		local mod = Ext.Mod.GetMod(uuid)
		if mod then
			local info = mod.Info
			local filePath = string.format("Public/%s/Stats/Generated/Data/ItemColor.txt", info.Directory)
			local text = GameHelpers.IO.LoadFile(filePath, "data")
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
	Character = true,
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
			_cachedStatData[statType] = Ext.Stats.GetStats(statType)
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
---@param asStatsEntry boolean|nil Return the StatEntryType instead of string.
---@return fun():string|StatEntryType
function GameHelpers.Stats.GetStats(statType, asStatsEntry)
	assert(IsStatTypeValid(statType), "statType must be one of the following: Armor|DeltaMod|Potion|Shield|SkillData|StatusData|Weapon")
	local _cache = _GetCachedStatType(statType)
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
				return Ext.Stats.Get(_cache[i], nil, false),i
			end
		end
	end
end

---@param asStatsEntry boolean|nil Return the StatEntrySkillData instead of string.
---@return fun():string|StatEntrySkillData
function GameHelpers.Stats.GetSkills(asStatsEntry)
	return GameHelpers.Stats.GetStats("SkillData", asStatsEntry)
end

---@param asStatsEntry boolean|nil Return the StatEntrySkillData instead of string.
---@return fun():string|StatEntryStatusData
function GameHelpers.Stats.GetStatuses(asStatsEntry)
	return GameHelpers.Stats.GetStats("StatusData", asStatsEntry)
end

---@param asStatsEntry boolean|nil Return the StatEntrySkillData instead of string.
---@return fun():string|StatEntryObject
function GameHelpers.Stats.GetObjects(asStatsEntry)
	return GameHelpers.Stats.GetStats("Object", asStatsEntry)
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

--local item = GameHelpers.GetItem(66419); print(Mods.LeaderLib.GameHelpers.Stats.IsStatType(item.StatsId))

--- Returns an ItemColor stat's colors.
--- @param name string The ID of the ItemColor.
--- @param asMaterialValues boolean|nil
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
---@param statType StatType|nil
---@return boolean
function GameHelpers.Stats.Exists(id, statType)
	if statType then
		assert(IsStatTypeValid(statType), "statType must be one of the following: Armor|DeltaMod|Object|Potion|Shield|SkillData|StatusData|Weapon")
		_GetCachedStatType(statType)
		local t = _statNameToType[id]
		return t ~= nil
	else
		local b,stat = pcall(Ext.Stats.Get, id, nil, false)
		return b and stat ~= nil
	end
end

local _cachedSkillToSkillbook = {}

---@param stat StatEntryObject
local function _StatHasAbilityRequirement(stat)
	if stat.Requirements then
		for _,v in pairs(stat.Requirements) do
			if Data.Ability[v.Requirement] then
				return true
			end
		end
	end
	return false
end

---Get a root template GUID that grants a specific skill.  
---This helper will parse object stats to try and find associated skillbooks, if a result hasn't been found already.
---@param skill string The skill ID.
---@return string rootTemplate A root template that grants this skill, if any.
function GameHelpers.Stats.GetSkillbookForSkill(skill)
	local template = _cachedSkillToSkillbook[skill]
	if template then
		return template
	end
	for stat in GameHelpers.Stats.GetObjects(true) do
		if GameHelpers.Stats.HasParent(stat.Name, "_Skillbooks") or _StatHasAbilityRequirement(stat) then
			---@type ItemTemplate
			local root = Ext.Template.GetTemplate(stat.RootTemplate)
			--Ext.IO.SaveFile("Dumps/ECLRootTemplate_SKILLBOOK_Water_VampiricHungerAura.json", Ext.DumpExport(Ext.Template.GetTemplate("2398983b-d9f3-40ca-9269-9a4fb0860931")))
			if root and root.OnUsePeaceActions then
				for _,v in pairs(root.OnUsePeaceActions) do
					if v.Type == "SkillBook" and v.SkillID == skill then
						_cachedSkillToSkillbook[skill] = stat.RootTemplate
						return stat.RootTemplate
					end
				end
			end
		end
	end
	return nil
end