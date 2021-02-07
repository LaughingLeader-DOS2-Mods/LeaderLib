---Data passed to callbacks for the various functions in SkillListeners.lua
---@class SkillEventData
local SkillEventData = {
	ID = "SkillEventData",
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
	}
	setmetatable(this, self)
    return this
end

---@param target string
function SkillEventData:AddTargetObject(target)
	self.TargetObjects[#self.TargetObjects+1] = GetUUID(target)
	self.TotalTargetObjects = self.TotalTargetObjects + 1
end

---@param x number
---@param y number
---@param z number
function SkillEventData:AddTargetPosition(x,y,z)
	self.TargetPositions[#self.TargetPositions+1] = {x,y,z}
	self.TotalTargetPositions = self.TotalTargetPositions + 1
end

function SkillEventData:Clear()
	self.TargetObjects = {}
	self.TargetPositions = {}
	self.TotalTargetObjects = 0
	self.TotalTargetPositions = 0
end

---@alias SkillEventDataTarget string|number[]
---@alias SkillEventDataForEachCallback fun(target:SkillEventDataTarget, targetType:string, self:SkillEventData):void

---Run a function on all target objects. The function is wrapped in an error handler.
---@param func SkillEventDataForEachCallback
---@param mode integer Run the function on objects, positions, or both. Defaults to just objects. 0:Objects, 1:Positions, 2:All
function SkillEventData:ForEach(func, mode)
	if mode == nil then mode = 0 end
	local runOnObjects = mode ~= 1 and self.TotalTargetObjects > 0
	if runOnObjects then
		for i,v in pairs(self.TargetObjects) do
			local status,err = xpcall(func, debug.traceback, v, "string", self)
			if not status then
				Ext.PrintError("[LeaderLib:SkillEventData:ForEach] Error:", err)
				Ext.PrintError(err)
			end
		end
	end
	local runOnPositions = mode ~= 0 and self.TotalTargetPositions > 0
	if runOnPositions then
		for i,v in pairs(self.TargetPositions) do
			local status,err = xpcall(func, debug.traceback, v, "table", self)
			if not status then
				Ext.PrintError("[LeaderLib:SkillEventData:ForEach] Error:", err)
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
	return Ext.JsonStringify(printableData)
end

Classes.SkillEventData = SkillEventData