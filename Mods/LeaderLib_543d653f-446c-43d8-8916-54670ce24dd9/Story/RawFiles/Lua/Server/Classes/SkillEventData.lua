---Data passed to callbacks for the various functions in SkillListeners.lua
---@class SkillEventData
---@field SourceItemGUID UUID|nil Possible item GUID that this skill is originating from, such as a scroll or grenade.
---@field SkillData StatEntrySkillData
local SkillEventData = {
	Type = "SkillEventData",
	Source = nil,
	Skill = "",
	SkillType = "",
	Ability = "",
	---@type string[]
	TargetObjects = {},
	---@type number[][]
	TargetPositions = {},
	TotalTargetObjects = 0,
	TotalTargetPositions = 0,
	TargetMode = {
		All = -1,
		Objects = 0,
		Positions = 1
	}
}
SkillEventData.__index = SkillEventData

---@param skillSource string The source of the skill.
---@param skill string
---@param skillType string
---@param skillAbility string
---@return SkillEventData
function SkillEventData:Create(skillSource, skill, skillType, skillAbility)
    local this =
    {
		Source = skillSource,
		Skill = skill,
		SkillType = StringHelpers.Capitalize(skillType),
		Ability = StringHelpers.Capitalize(skillAbility),
		TargetObjects = {},
		TargetPositions = {},
		TotalTargetObjects = 0,
		TotalTargetPositions = 0,
		SkillData = GameHelpers.Ext.CreateSkillTable(skill)
	}
	---@deprecated
	---Use SkillData instead.
	this.Stat = this.SkillData
	setmetatable(this, self)
    return this
end

---@param target string
function SkillEventData:AddTargetObject(target)
	self.TargetObjects[#self.TargetObjects+1] = StringHelpers.GetUUID(target)
	self.TotalTargetObjects = self.TotalTargetObjects + 1
end

---@param x number
---@param y number
---@param z number
function SkillEventData:AddTargetPosition(x,y,z)
	self.TargetPositions[#self.TargetPositions+1] = {x,y,z}
	self.TotalTargetPositions = self.TotalTargetPositions + 1
end

---@return number[]
function SkillEventData:GetSkillTargetPosition()
	if self.TotalTargetPositions > 0 then
		return self.TargetPositions[1]
	elseif self.TotalTargetObjects > 0 then
		return table.pack(GetPosition(self.TargetObjects[1]))
	end
	return nil
end

function SkillEventData:Clear()
	self.TargetObjects = {}
	self.TargetPositions = {}
	self.TotalTargetObjects = 0
	self.TotalTargetPositions = 0
end

---@alias SkillEventDataTarget string|number[]
---@alias SkillEventDataForEachTargetType string|'"string"'|'"table"'
---@alias SkillEventDataForEachCallback fun(target:SkillEventDataTarget, targetType:SkillEventDataForEachTargetType, self:SkillEventData):void

---Run a function on all target objects. The function is wrapped in an error handler.
---@param func SkillEventDataForEachCallback
---@param mode integer Run the function on objects, positions, or both. Defaults to just objects. 0:Objects, 1:Positions, 2:All
function SkillEventData:ForEach(func, mode)
	mode = mode or SkillEventData.TargetMode.Objects
	local runOnObjects = mode ~= 1 and self.TotalTargetObjects > 0
	local runOnPositions = mode ~= 0 and self.TotalTargetPositions > 0

	if runOnObjects then
		for i,v in pairs(self.TargetObjects) do
			local b,err = xpcall(func, debug.traceback, v, "string", self)
			if not b then
				Ext.PrintError("[LeaderLib:SkillEventData:ForEach] Error:")
				Ext.PrintError(err)
			end
		end
	end
	
	if runOnPositions then
		for i,v in pairs(self.TargetPositions) do
			local b,err = xpcall(func, debug.traceback, v, "table", self)
			if not b then
				Ext.PrintError("[LeaderLib:SkillEventData:ForEach] Error:")
				Ext.PrintError(err)
			end
		end
	end
end

function SkillEventData:Print()
	PrintDebug("[LeaderLib:SkillEventData]")
	PrintDebug("============")
	for k,v in pairs(SkillEventData) do
		if type(v) ~= "function" and k ~= "__index" then
			PrintDebug("["..k.."] = "..Common.Dump(self[k]))
		end
	end
	PrintDebug("============")
end

function SkillEventData:ToString()
	local printableData = {}
	for k,v in pairs(self) do
		printableData[k] = v
	end
	for k,v in pairs(SkillEventData) do
		if k ~= "__index" then
			local varType = type(v)
			if varType == "number" or varType == "string" or varType == "table" then
				printableData[k] = self[k]
			else
				if varType == "function" then
					if printableData["Functions"] == nil then
						printableData["Functions"] = {}
					end
					printableData["Functions"][k] = ""
				else
					printableData[k] = varType
				end
			end
		end
	end
	return Common.JsonStringify(printableData)
end

function SkillEventData:PrintTargets()
	fprint(LOGLEVEL.TRACE, "[SkillEventData:%s] Objects(%s) Positions(%s)", self.Skill, self.TotalTargetObjects > 0 and Common.Dump(self.TargetObjects) or "", self.TotalTargetPositions > 0 and Common.Dump(self.TargetPositions) or "")
end

function SkillEventData:Serialize()
	local tbl = {
		Source = self.Source,
		Skill = self.Skill,
		TargetObjects = self.TargetObjects,
		TargetPositions = self.TargetPositions,
	}
	return tbl
end

function SkillEventData:LoadFromSave(tbl)
	if not tbl or type(tbl) ~= "table" then
		return
	end
	if not StringHelpers.IsNullOrWhitespace(tbl.Source) then
		self.Source = tbl.Source
	end
	if not StringHelpers.IsNullOrWhitespace(tbl.Skill) then
		self.Skill = tbl.Skill
		local stat = Ext.Stats.Get(self.Skill)
		if stat then
			self.Ability = stat.Ability
			self.SkillType = stat.SkillType
		end
	end
	if tbl.TargetObjects then
		for i,v in pairs(tbl.TargetObjects) do
			self:AddTargetObject(v)
		end
	end
	if tbl.TargetPositions then
		for i,v in pairs(tbl.TargetPositions) do
			self:AddTargetPosition(table.unpack(v))
		end
	end
end

Classes.SkillEventData = SkillEventData