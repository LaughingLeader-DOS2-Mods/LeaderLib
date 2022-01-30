if GameHelpers.Stats == nil then
	GameHelpers.Stats = {}
end

--- @param stat string
--- @param match string
--- @return boolean
function GameHelpers.Stats.HasParent(stat, match)
	local parent = Ext.StatGetAttribute(stat, "Using")
	if parent ~= nil and parent ~= "" then
		if parent == match then
			return true
		else
			return GameHelpers.Stats.HasParent(parent, match)
		end
	end
	return false
end

--- @param stat string
--- @param findParent string
--- @param attribute string
--- @return boolean
function GameHelpers.Stats.HasParentAttributeValue(stat, findParent, attribute)
	local parent = Ext.StatGetAttribute(stat, "Using")
	if parent ~= nil and parent ~= "" then
		if parent == findParent then
			return Ext.StatGetAttribute(stat, attribute) == Ext.StatGetAttribute(parent, attribute)
		else
			return GameHelpers.Stats.HasParentAttributeValue(parent, findParent, attribute)
		end
	end
	return false
end

local RuneAttributes = {
	"RuneEffectWeapon",
	"RuneEffectUpperbody",
	"RuneEffectAmulet",
}

---@class RuneBoostAttributes:table
---@field RuneEffectWeapon string
---@field RuneEffectUpperbody string
---@field RuneEffectAmulet string

---@class RuneBoostsTableResult:table
---@field Name string
---@field Boosts RuneBoostAttributes
---@field Slot integer

---@param item StatItem
---@return RuneBoostsTableResult[]
function GameHelpers.Stats.GetRuneBoosts(item)
	---@type RuneBoostsTableResult[]
	local boosts = {}
	if item ~= nil then
		for i=3,5,1 do
			local boost = item.DynamicStats[i]
			if boost ~= nil and boost.BoostName ~= "" then
				---@type RuneBoostsTableResult
				local runeEntry = {
					Name = boost.BoostName,
					Boosts = {},
					Slot = i - 3
				}
				table.insert(boosts, runeEntry)
				for i,attribute in pairs(RuneAttributes) do
					runeEntry.Boosts[attribute] = ""
					local boostStat = Ext.StatGetAttribute(boost.BoostName, attribute)
					if boostStat ~= nil then
						runeEntry.Boosts[attribute] = boostStat
					end
				end
			end
		end
	end
	return boosts
end

function GameHelpers.Stats.GetCurrentOrInheritedProperty(statName, attribute)
	local stat = Ext.GetStat(statName)
	if stat then
		if stat[attribute] ~= nil then
			return stat[attribute]
		else
			if not StringHelpers.IsNullOrEmpty(stat.Using) then
				return GameHelpers.Stats.GetCurrentOrInheritedProperty(stat.Using, attribute)
			end
		end
	end
	return nil
end

---@param statName string
---@return StatProperty[]
function GameHelpers.Stats.GetSkillProperties(statName)
	return GameHelpers.Stats.GetCurrentOrInheritedProperty(statName, "SkillProperties") or {}
end

---@param statName string
---@return StatProperty[]
function GameHelpers.Stats.GetExtraProperties(statName)
	return GameHelpers.Stats.GetCurrentOrInheritedProperty(statName, "ExtraProperties") or {}
end

---Returns true if the skill applies a HEAL status.
---@param skillId string
---@param healTypes HealType[] If set, will return true only if the applied statuses matches a provided healing type.
---@return boolean
function GameHelpers.Stats.IsHealingSkill(skillId, healTypes)
	local props = GameHelpers.Stats.GetSkillProperties(skillId)
	if props then
		for _,v in pairs(props) do
			if v.Type == "Status" then
				local statusType = GameHelpers.Status.GetStatusType(v.Action)
				if statusType == "HEAL" or statusType == "HEALING" then
					if not healTypes then
						return true
					else
						local healType = Ext.StatGetAttribute(v.Action, "HealStat")
						if Common.TableHasValue(healTypes, healType) then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

local _initializedItemColors = false
local _ItemColors = {}
local _colorPattern = 'new itemcolor "(.+)","(.+)","(.*)","(.*)"'

local function _buildItemColors()
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
						_ItemColors[id] = {"#"..c1,"#"..c2,"#"..c3}
					end
				end
			end
		end
	end
end

--- Returns an ItemColor stat's colors.
--- @param name string The ID of the ItemColor.
--- @param asMaterialValues ?boolean
--- @return string[]
function GameHelpers.Stats.GetItemColor(name, asMaterialValues)
	if not _initializedItemColors then
		_buildItemColors()
		_initializedItemColors = true
	end
	local entry = _ItemColors[name]
	if asMaterialValues and entry then
		local c1,c2,c3 = table.unpack(entry)
		return {GameHelpers.Math.HexToMaterialRGBA(c1), GameHelpers.Math.HexToMaterialRGBA(c2), GameHelpers.Math.HexToMaterialRGBA(c3)}
	end
	return entry
end