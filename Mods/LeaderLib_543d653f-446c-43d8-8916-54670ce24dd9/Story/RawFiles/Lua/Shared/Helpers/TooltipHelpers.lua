if GameHelpers.Tooltip == nil then
	GameHelpers.Tooltip = {}
end

local _EXTVERSION = Ext.Version()
local _ISCLIENT = Ext.IsClient()
local _type = type

local function GetTextParamValues(output, character)
	for v in string.gmatch(output, "%[Special:.-%]") do
		local value = ""
		local fullParam = v:gsub("%[Special:", ""):gsub("%]", "")
		local props = StringHelpers.Split(fullParam, ":")
		local param = ""
		if props and #props >= 0 then
			param = props[1]
			table.remove(props, 1)
		end
		if character == nil then
			character = Client:GetCharacter()
		end
		if character ~= nil and character.Stats ~= nil then
			---@type SubscribableEventInvokeResult<GetTextPlaceholderEventArgs>
			local invokeResult = Events.GetTextPlaceholder:Invoke({
				Character = character.Stats,
				ID = param,
				ExtraParams = props or {},
				Result = ""
			})
			if invokeResult.ResultCode ~= "Error" then
				value = invokeResult.Args.Result
				if invokeResult.Results then
					for i=1,#invokeResult.Results do
						local v = invokeResult.Results[i]
						if type(v) == "string" and not StringHelpers.IsNullOrWhitespace(v) then
							value = v
						end
					end
				end
			end
		end		
		if value ~= nil and value ~= "" then
			if _type(value) == "number" then
				value = string.format("%i", math.floor(value))
			end
		elseif value == nil then
			value = ""
		end
		output = StringHelpers.Replace(output, v, value)
	end
	return output
end

--Ext.Dump(GameHelpers.Tooltip.GetSkillDamageText("Target_LLWEAPONEX_Steal", GameHelpers.GetCharacter(me.MyGuid)))

---@param skillId string The skill ID, i.e "Projectile_Fireball".
---@param character CharacterParam|nil The character to use. Defaults to Client:GetCharacter if on the client-side, or the host otherwise.
---@param skillParams StatEntrySkillData|nil A table of attributes to set on the skill table before calculating the damage.
---@return string damageText
function GameHelpers.Tooltip.GetSkillDamageText(skillId, character, skillParams)
	if not StringHelpers.IsNullOrWhitespace(skillId) then
		local skill = GameHelpers.Ext.CreateSkillTable(skillId, nil, true)
		if skill ~= nil then
			if _type(skillParams) == "table" then
				for k,v in pairs(skillParams) do
					skill[k] = v
				end
			end
			if character then
				character = GameHelpers.GetCharacter(character)
			end
			if character == nil then
				if _ISCLIENT then
					character = Client:GetCharacter()
				elseif Ext.OsirisIsCallable() then
					character = GameHelpers.GetCharacter(CharacterGetHostCharacter())
				end
			end
			if character ~= nil and character.Stats ~= nil then
				local useDefaultSkillDamage = true
				---@type SubscribableEventInvokeResult<GetTooltipSkillDamageEventArgs>
				local invokeResult = Events.GetTooltipSkillDamage:Invoke({
					Character = character.Stats,
					Skill = skillId,
					SkillData = skill,
					Result = ""
				})
				if invokeResult.ResultCode ~= "Error" then
					local result = invokeResult.Args.Result
					if invokeResult.Results then
						for i=1,#invokeResult.Results do
							local v = invokeResult.Results[i]
							if type(v) == "string" and not StringHelpers.IsNullOrEmpty(v) then
								result = v
							end
						end
					end
					if not StringHelpers.IsNullOrEmpty(result) then
						return result
					end
				end
				if useDefaultSkillDamage then
					if _EXTVERSION >= 56 then
						if _ISCLIENT then
							if Ext.Events.SkillGetDescriptionParam then
								---@type {Character:StatCharacter, Description:string, IsFromItem:boolean, Skill:StatEntrySkillData, Params:string[]}
								local evt = {
									Skill = skill,
									Character = character.Stats,
									Description = "",
									IsFromItem = false,
									Params = {"Damage"},
									Stopped = false
								}
								evt.StopPropagation = function (self)
									evt.Stopped = true
								end
								Ext.Events.SkillGetDescriptionParam:Throw(evt)
								if not StringHelpers.IsNullOrWhitespace(evt.Description) then
									return evt.Description
								end
							end
						end
						if Ext.Events.GetSkillDamage then
							---@type {Attacker:StatCharacter, AttackerPosition:number[], DamageList:DamageList, DeathType:DeathType, IsFromItem:boolean, Level:integer, Skill:StatEntrySkillData, Stealthed:boolean, TargetPosition:number[]}
							local evt = {
								Skill = skill,
								Attacker = character.Stats,
								AttackerPosition = character.WorldPos,
								TargetPosition = character.WorldPos,
								DamageList = Ext.Stats.NewDamageList(),
								DeathType = "None",
								Stealthed = character.Stats.IsSneaking == true,
								IsFromItem = false,
								Level = character.Stats.Level,
								Stopped = false
							}
							evt.StopPropagation = function (self)
								evt.Stopped = true
							end
							Ext.Events.GetSkillDamage:Throw(evt)
							if evt.DamageList then
								local hasDamage = false
								for _,v in pairs(evt.DamageList:ToTable()) do
									if v.Amount > 0 then
										hasDamage = true
										break
									end
								end
								if hasDamage then
									return GameHelpers.Tooltip.FormatDamageList(evt.DamageList)
								end
							end
						end
					else
						if _ISCLIENT then
							local b,result = pcall(Ext._SkillGetDescriptionParam, skill, character, false, "Damage")
							if not StringHelpers.IsNullOrEmpty(result) then
								return result
							end
						end
						local b,damageList = pcall(Ext._GetSkillDamage, skill, character.Stats, false, character.Stats.IsSneaking == true, character.WorldPos, character.WorldPos, character.Stats.Level, true)
						if damageList then
							local hasDamage = false
							for _,v in pairs(damageList:ToTable()) do
								if v.Amount > 0 then
									hasDamage = true
									break
								end
							end
							if hasDamage then
								return GameHelpers.Tooltip.FormatDamageList(damageList)
							end
						end
					end
				end

				if useDefaultSkillDamage then
					local damageRange = Game.Math.GetSkillDamageRange(character.Stats, skill)
					return GameHelpers.Tooltip.FormatDamageRange(damageRange)
				end
			end
		end
	end
	return ""
end

---@param str string|TranslatedString
---@param character CharacterParam
local function ReplacePlaceholders(str, character)
	if not str then
		return str
	end
	local character = GameHelpers.GetCharacter(character)
	if character == nil then
		if _ISCLIENT then
			if Client then
				character = Client:GetCharacter()
			else
				character = GameHelpers.Client.GetCharacter()
			end
		elseif Ext.Osiris.IsCallable() then
			character = GameHelpers.GetCharacter(CharacterGetHostCharacter())
		end
	end
	if _type(str) == "table" and str.Type == "TranslatedString" then
		str = str.Value
	end
	local output = str
	for v in string.gmatch(output, "%[ExtraData.-%]") do
		local text = v:gsub("%[ExtraData:", ""):gsub("%]", "")
		local key,fallback = table.unpack(StringHelpers.Split(text, ":"))
		local value = GameHelpers.GetExtraData(key, fallback)
		if _type(value) == "number" then
			local trailingStr = ""
			local startPos,endPos = string.find(output, v, 1, true)
			if endPos then
				trailingStr = string.sub(output, endPos+1, endPos+1)
			end

			if trailingStr == "%" and value > 0 and value <= 1 then
				-- Percentage display
				value = value * 100
				value = string.format("%i", math.floor(value))
			else
				local floored = math.floor(value)
				if floored == value then
					value = string.format("%i", floored)
				else
					value = tostring(value)
				end
			end
		end
		output = StringHelpers.Replace(output, v, value)
	end
	for v in string.gmatch(output, "%[Stats:.-%]") do
		local value = ""
		local statFetcher = v:gsub("%[Stats:", ""):gsub("%]", "")
		local props = StringHelpers.Split(statFetcher, ":")
		local stat = props[1]
		local property = props[2]
		if stat ~= nil and property ~= nil then
			value = Ext.Stats.GetAttribute(stat, property)
		end
		if value ~= nil and value ~= "" then
			if _type(value) == "number" then
				value = string.format("%i", math.floor(value))
			end
		elseif value == nil then
			value = ""
		end
		-- The parameter brackets will be considered for pattern matching unless we escape them with a percentage sign.
		output = StringHelpers.Replace(output, v, value)
	end
	for v in string.gmatch(output, "%[SkillDamage:.-%]") do
		local value = ""
		local skillName = v:gsub("%[SkillDamage:", ""):gsub("%]", "")
		if not StringHelpers.IsNullOrWhitespace(skillName) then
			value = GameHelpers.Tooltip.GetSkillDamageText(skillName, character)
		end
		if value ~= nil then
			if _type(value) == "number" then
				value = string.format("%i", math.floor(value))
			end
			output = StringHelpers.Replace(output, v, value)
		end
	end
	for v in string.gmatch(output, "%[Skill:.-%]") do
		local value = ""
		local fullParam = v:gsub("%[Skill:", ""):gsub("%]", "")
		local props = StringHelpers.Split(fullParam, ":")
		local skillName = ""
		local param = ""
		if props and #props >= 2 then
			skillName = props[1]
			param = props[2]
		end
		if not StringHelpers.IsNullOrWhitespace(skillName) then
			local skill = GameHelpers.Ext.CreateSkillTable(skillName)
			if skill ~= nil then
				if character == nil then
					character = Client:GetCharacter()
				end
				if character ~= nil and character.Stats ~= nil then
					---@type SubscribableEventInvokeResult<GetTooltipSkillParamEventArgs>
					local invokeResult = Events.GetTooltipSkillParam:Invoke({
						Character = character.Stats,
						Skill = skillName,
						SkillData = skill,
						Param = param,
						Result = ""
					})
					if invokeResult.ResultCode ~= "Error" then
						local result = invokeResult.Args.Result
						if invokeResult.Results then
							for i=1,#invokeResult.Results do
								local v = invokeResult.Results[i]
								if v ~= nil then
									result = v
								end
							end
						end
						value = result
					end
				end
			end
		end			
		if value ~= nil and value ~= "" then
			if _type(value) == "number" then
				value = string.format("%i", math.floor(value))
			end
		elseif value == nil then
			value = ""
		end
		output = StringHelpers.Replace(output, v, value)
	end

	output = GetTextParamValues(output, character)
	
	for v in string.gmatch(output, "%[Key:.-%]") do
		local text = v:gsub("%[Key:", ""):gsub("%]", "")
		local split = StringHelpers.Split(text, ":") or {}
		local key,fallback = table.unpack(split)
		if fallback == nil then 
			fallback = key
		end
		if not StringHelpers.IsNullOrWhitespace(key) then
			local translatedText = GameHelpers.GetStringKeyText(key, fallback)
			if translatedText == nil then 
				translatedText = "" 
			else
				translatedText = ReplacePlaceholders(translatedText, character)
			end
			output = StringHelpers.Replace(output, v, translatedText)
		elseif fallback then
			output = fallback
		end
	end
	for v in string.gmatch(output, "%[Handle:.-%]") do
		local text = v:gsub("%[Handle:", ""):gsub("%]", "")
		local props = StringHelpers.Split(text, ":")
		if props[2] == nil then
			props[2] = ""
		end
		local translatedText = GameHelpers.GetTranslatedString(props[1], props[2])
		if translatedText == nil then 
			translatedText = "" 
		else
			translatedText = ReplacePlaceholders(translatedText, character)
		end
		output = StringHelpers.Replace(output, v, translatedText)
	end
	return output
end

---Replace placeholder text in strings, such as ExtraData, Skill, etc.
---@param str string|TranslatedString
---@param character CharacterParam|nil Optional character to use for the tooltip.
---@return string
function GameHelpers.Tooltip.ReplacePlaceholders(str, character)
	local b,result = xpcall(ReplacePlaceholders, debug.traceback, str, character)
	if b then
		return result
	else
		Ext.PrintError("[LeaderLib:GameHelpers.Tooltip.ReplacePlaceholders] Error replacing placeholders:")
		Ext.PrintError(result)
		return str
	end
end

--- Formats a damage range typically returned from GameHelpers.Math.GetSkillDamageRange
---@param damageRange table<string,number[]>
---@return string
function GameHelpers.Tooltip.FormatDamageRange(damageRange)
	if damageRange ~= nil then
		local damageTexts = {}
		local totalDamageTypes = 0
		for damageType,damage in pairs(damageRange) do
			local min = damage.Min or damage[1]
			local max = damage.Max or damage[2]
			if min ~= nil and max ~= nil then
				if max == min then
					table.insert(damageTexts, GameHelpers.GetDamageText(damageType, string.format("%i", max)))
				else
					table.insert(damageTexts, GameHelpers.GetDamageText(damageType, string.format("%i-%i", min, max)))
				end
				totalDamageTypes = totalDamageTypes + 1
			end
		end
		if totalDamageTypes > 0 then
			if totalDamageTypes > 1 then
				return StringHelpers.Join(", ", damageTexts)
			else
				return damageTexts[1]
			end
		end
	end
	return ""
end

--- Formats a damage range typically returned from GameHelpers.Math.GetSkillDamageRange
---@param damageList DamageList
---@return string
function GameHelpers.Tooltip.FormatDamageList(damageList)
	if damageList ~= nil then
		local damageTexts = {}
		local totalDamageTypes = 0
		for _,v in pairs(damageList:ToTable()) do
			table.insert(damageTexts, GameHelpers.GetDamageText(v.DamageType, string.format("%i", v.Amount)))
			totalDamageTypes = totalDamageTypes + 1
		end
		if totalDamageTypes > 0 then
			if totalDamageTypes > 1 then
				return StringHelpers.Join(", ", damageTexts)
			else
				return damageTexts[1]
			end
		end
	end
	return ""
end

if Vars.IsClient then
	--local extraPropStatusTurnsPattern = "Set (.+) for (%d+) turn%(s%).-%((%d+)%% Chance%)"

	---@param tooltip TooltipData
	---@param inputElements table
	---@param addColor boolean|nil
	---@return string combinedText
	---@return table<integer,boolean> indexes Removed element indexes.
	function GameHelpers.Tooltip.CondensePropertiesText(tooltip, inputElements, addColor)
		local _,periodCharacterStart = string.find(LocalizedText.Tooltip.ExtraPropertiesWithTurns.Value, "turn(s)", nil, true)
		periodCharacterStart = periodCharacterStart + 1
		local periodCharacter = string.sub(LocalizedText.Tooltip.ExtraPropertiesWithTurns.Value, periodCharacterStart, periodCharacterStart)
		local periodReplace = ""
		if periodCharacter == "." then
			periodCharacter = "%."
			periodReplace = "%%."
		else
			periodReplace = periodCharacter
		end
		local turnsPattern = LocalizedText.Tooltip.ExtraPropertiesWithTurns:ReplacePlaceholders("(.-)", "(.*)", "(.*)", "([0-9]+)"):gsub("%(s%)"..periodCharacter, "%%(s%%)"..periodReplace)
		--local permanentPattern = LocalizedText.Tooltip.ExtraPropertiesPermanent:ReplacePlaceholders("(.-)", "(.-)", "(.-)"):gsub("%)%.%(", ")%%.(")
		local entries = {}
		local removedElements = {}
		local hasChances = false
		for i,v in ipairs(inputElements) do
			v.Label = string.gsub(v.Label, "  ", " ")
			local _,_,status,turns,chance,extra = string.find(v.Label, turnsPattern)
			if status ~= nil and turns ~= nil and chance ~= nil then
				if chance then
					local _,_,chanceNumber = string.find(chance, "(%d+)")
					if not chanceNumber then
						chance = 100
					end
					if chanceNumber then
						chance = chanceNumber
						hasChances = true
					end
				end
				removedElements[i] = true
				table.insert(entries, {Status = status, Turns = turns, Chance = chance})
			end
		end
		
		if #entries > 0 then
			local finalStatusText = ""
			local finalTurnsText = ""
			local finalChanceText = ""
			for i,v in pairs(entries) do
				finalStatusText = finalStatusText .. v.Status
				finalTurnsText = finalTurnsText .. v.Turns
				if hasChances then
					finalChanceText = finalChanceText .. v.Chance
				end
				if i >= 1 and i < #entries then
					finalStatusText = finalStatusText .. "/"
					finalTurnsText = finalTurnsText .. "/"
					if hasChances then
						finalChanceText = finalChanceText .. "/"
					end
				end
			end
			if hasChances then
				finalChanceText = " " .. LocalizedText.Tooltip.Chance:ReplacePlaceholders(finalChanceText)
			end
			return StringHelpers.Trim(LocalizedText.Tooltip.ExtraPropertiesOnHit:ReplacePlaceholders(finalStatusText, finalTurnsText, finalChanceText)),removedElements
		end
	end

	---@alias TooltipElementParam table<string,string|number>

	---@param element TooltipElementParam
	---@param attribute string
	---@param fallback any|nil An optional fallback value to use. Returns an empty string by default.
	---@return string|number
	function GameHelpers.Tooltip.GetElementAttribute(element, attribute, fallback)
		if element ~= nil and element[attribute] ~= nil then
			return element[attribute]
		end
		return fallback or ""
	end
end