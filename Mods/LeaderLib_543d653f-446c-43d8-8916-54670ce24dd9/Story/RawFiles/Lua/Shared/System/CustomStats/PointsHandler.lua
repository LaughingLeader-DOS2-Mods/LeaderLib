local self = CustomStatSystem

---@alias CustomStatGetAvailablePointsCallback fun(id:string, currentValue:integer, character:EclCharacter, stat:CustomStatData):integer
---@alias CustomStatPointsAssignedCallback fun(id:string, currentValue:integer, character:EsvCharacter, stat:CustomStatData):void


self.Listeners = {}

function CustomStatSystem:RegisterPointHandler(id, callback)

end

if Ext.IsClient() then

local points = {
	Lucky = 2
}

function CustomStatSystem:GetCanAddPoints(ui, call, doubleHandle)
	local stat = self:GetStatByDouble(doubleHandle)
	if stat then
		if not points[stat.ID] then
			points[stat.ID] = 4
		end
		local points = points[stat.ID] or 0
		return points > 0
	end
	return false
end

function CustomStatSystem:GetCanRemovePoints(ui, call, doubleHandle)
	local stat = self:GetStatByDouble(doubleHandle)
	local value = self:GetStatValueForCharacter(nil, stat.ID, stat.Mod)
	return value > 0
end

function CustomStatSystem:OnStatAdded(ui, call, doubleHandle, index)
	print(call, doubleHandle, index)
	---@type CharacterSheetMainTimeline
	local this = ui:GetRoot()
	local stat_mc = this.stats_mc.customStats_mc.stats_array[index]
	local stat = self:GetStatByDouble(doubleHandle)

	-- stat_mc.plus_mc.visible = true
	-- stat_mc.minus_mc.visible = false
end

function CustomStatSystem:OnStatPointAdded(ui, call, doubleHandle)
	local stat = self:GetStatByDouble(doubleHandle)
	local stat_mc = self:GetStatMovieClipByDouble(ui, doubleHandle)

	if points[stat.ID] and points[stat.ID] > 0 then
		points[stat.ID] = math.max(points[stat.ID] - 1, 0)
	end
	if points[stat.ID] == 0 then
		stat_mc.plus_mc.visible = false
	end
end

function CustomStatSystem:OnStatPointRemoved(ui, call, doubleHandle)
	local stat = self:GetStatByDouble(doubleHandle)
	local stat_mc = self:GetStatMovieClipByDouble(ui, doubleHandle)

	if not points[stat.ID] then
		points[stat.ID] = 0
	end
	points[stat.ID] = points[stat.ID] + 1
end

Ext.RegisterUITypeCall(Data.UIType.characterSheet, "customStatAdded", function(...) CustomStatSystem:OnStatAdded(...) end)
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "plusCustomStat", function(...) CustomStatSystem:OnStatPointAdded(...) end)
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "minusCustomStat", function(...) CustomStatSystem:OnStatPointRemoved(...) end)
end