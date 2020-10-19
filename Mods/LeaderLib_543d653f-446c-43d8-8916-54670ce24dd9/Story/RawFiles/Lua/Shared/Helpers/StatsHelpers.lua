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