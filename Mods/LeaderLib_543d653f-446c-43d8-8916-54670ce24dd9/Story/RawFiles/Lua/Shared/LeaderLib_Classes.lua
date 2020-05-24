---@class TranslatedString
local TranslatedString = {
	Handle = "",
	Content = "",
	Value = ""
}
TranslatedString.__index = TranslatedString

---@param handle string
---@param content string
---@return TranslatedString
function TranslatedString:Create(handle,content)
    local this =
    {
		Handle = handle,
		Content = content
	}
	setmetatable(this, self)
	if this.Handle ~= "" and this.Handle ~= nil then
		if Ext.Version() >= 43 then
			this.Value = Ext.GetTranslatedString(this.Handle, this.Content)
		else
			this.Value = this.Content
		end
	end
	table.insert(TranslatedStringEntries, this)
    return this
end

function TranslatedString:Update()
	if self.Handle ~= "" and self.Handle ~= nil then
		if Ext.Version() >= 43 then
			self.Value = Ext.GetTranslatedString(self.Handle, self.Content)
		else
			self.Value = self.Content
		end
	else
		self.Value = self.Content
	end
	return self.Value
end

Classes["TranslatedString"] = TranslatedString
--local TranslatedString = Classes["TranslatedString"]

---@class MessageData
local MessageData = {
	ID = "NONE",
	Params = {}
}
MessageData.__index = MessageData

---Prepares a message for data transfer and converts it to string.
---@return string
function MessageData:ToString()
    return Ext.JsonStringify(self)
end

local function TryParseTable(str)
	local tbl = Ext.JsonParse(str)
	if tbl ~= nil then
		if tbl.ID ~= nil and tbl.Params ~= nil then
			return MessageData:CreateFromTable(tbl.ID, tbl.Params)
		end
	end
	error("String is not a MessageData structure.")
end

---Prepares a message for data transfer and converts it to string.
---@param str string
---@return MessageData
function MessageData:CreateFromString(str)
	local b,result = xpcall(TryParseTable, function(err)
		Ext.PrintError("[LeaderLib_Classes.lua:MessageData:CreateFromString] Error parsing string as table ("..str.."):\n" .. tostring(err))
	end, str)
	if b and result ~= nil then
		return result
	end
	return nil
end

---@param id string
---@return MessageData
function MessageData:Create(id,...)
    local this =
    {
		ID = id,
		Params = {...}
	}
	setmetatable(this, self)
    return this
end

---@param id string
---@param params table
---@return MessageData
function MessageData:CreateFromTable(id,params)
    local this =
    {
		ID = id,
		Params = params
	}
	setmetatable(this, self)
    return this
end

Classes["MessageData"] = MessageData

---An item boost to be used with NRD_ItemCloneAddBoost.
---@class DeltaMod
local DeltaMod = {
	Type = "DeltaMod",
	SlotType = "",
	WeaponType = "",
	TwoHanded = "",
	Boost = "",
	MinLevel = -1,
	MaxLevel = -1,
	Chance = 100
}
DeltaMod.__index = DeltaMod

---@param deltaMod DeltaMod
---@param vars table
local function SetVars(deltaMod, vars)
	if vars ~= nil then
		if vars.Type ~= nil then deltaMod.Type = vars.Type end
		if vars.MinLevel ~= nil then deltaMod.MinLevel = vars.MinLevel end
		if vars.MaxLevel ~= nil then deltaMod.MaxLevel = vars.MaxLevel end
		if vars.Chance ~= nil then deltaMod.Chance = vars.Chance end
		if vars.SlotType ~= nil then deltaMod.SlotType = vars.SlotType end
		if vars.TwoHanded ~= nil then deltaMod.TwoHanded = vars.TwoHanded end
		if vars.WeaponType ~= nil then deltaMod.WeaponType = vars.WeaponType end
	end
end

---@param boost string
---@param vars table
---@return DeltaMod
function DeltaMod:Create(boost, vars)
    local this =
    {
		Boost = boost,
		Type = "DeltaMod",
		MinLevel = -1,
		MaxLevel = -1,
		Chance = 100
	}
	setmetatable(this, self)
	SetVars(this, vars)
    return this
end

Classes["DeltaMod"] = DeltaMod
--local DeltaMod = Classes["DeltaMod"]

---A container for multiple DeltaMod entries.
---@class DeltaModGroup
local DeltaModGroup = {
	Entries = {}
}
DeltaModGroup.__index = DeltaModGroup

---@param entries table
---@param vars table
---@return DeltaModGroup
function DeltaModGroup:Create(entries, vars)
    local this =
    {
		Entries = entries
	}
	setmetatable(this, self)
	if vars ~= nil then
		for i,v in pairs(this.Entries) do
			SetVars(v, vars)
		end
	end
    return this
end

---@return table
function DeltaModGroup:GetRandomEntry()
    return Common.GetRandomTableEntry(self.Entries)
end
Classes["DeltaModGroup"] = DeltaModGroup

---@type LeaderLibGameSettings
Classes["LeaderLibGameSettings"] = Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Shared/Settings/LeaderLibGameSettings.lua").LeaderLibGameSettings

---Data passed to callbacks for the various functions in SkillListeners.lua
---@class SkillEventData
local SkillEventData = {
	ID = "SkillEventData",
	Source = nil,
	Skill = "",
	SkillType = "",
	SkillAbility = "",
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
		SkillAbility = StringHelpers.Capitalize(skillAbility)
	}
	setmetatable(this, self)
    return this
end

---@param target string
function SkillEventData:AddTargetObject(target)
	if self.TargetObjects == nil then 
		self.TargetObjects = {}
		self.TotalTargetObjects = 0
	end
	self.TargetObjects[#self.TargetObjects+1] = target
	self.TotalTargetObjects = self.TotalTargetObjects + 1
end

---@param x number
---@param y number
---@param z number
function SkillEventData:AddTargetPosition(x,y,z)
	if self.TargetPositions == nil then 
		self.TargetPositions = {}
		self.TotalTargetPositions = 0
	end
	self.TargetPositions[#self.TargetPositions+1] = {x,y,z}
	self.TotalTargetPositions = self.TotalTargetPositions + 1
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

Classes["SkillEventData"] = SkillEventData

---Data passed to hit callbacks, such as the various functions in SkillListeners.lua
---@class HitData
local HitData = {
	ID = "HitData",
	Target = "",
	Attacker = "",
	Skill = "",
	IsFromSkll = false
}
HitData.__index = HitData

---@param target string The source of the skill.
---@param attacker string
---@param damage integer
---@param handle integer
---@param skill string|nil
---@return HitData
function HitData:Create(target, attacker, damage, handle, skill)
	---@type HitData
    local this =
    {
		Target = target,
		Attacker = attacker,
		Damage = damage,
		Handle = handle
	}
	if skill ~= nil then
		this.Skill = skill
		this.IsFromSkll = true
	end
	setmetatable(this, self)
    return this
end

Classes["HitData"] = HitData