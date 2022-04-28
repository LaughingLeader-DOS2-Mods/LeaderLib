if GameHelpers.Tooltip == nil then
	GameHelpers.Tooltip = {}
end

local function GetTextParamValues(output, character)
	for v in string.gmatch(output, "%[Special:.-%]") do
		local value = ""
		local fullParam = v:gsub("%[Special:", ""):gsub("%]", "")
		local props = StringHelpers.Split(fullParam, ":")
		local param = ""
		local skipUnpack = false
		if #props >= 0 then
			param = props[1]
			table.remove(props, 1)
			if #props == 0 then
				skipUnpack = true
			end
		end
		if character == nil then
			character = Client:GetCharacter()
		end
		if character ~= nil and character.Stats ~= nil then
			if Listeners.GetTextPlaceholder[param] then
				for _,callback in pairs(Listeners.GetTextPlaceholder[param]) do
					local b = true
					local result = nil
					if skipUnpack then
						b,result = xpcall(callback, debug.traceback, param, character.Stats)
					else
						b,result = xpcall(callback, debug.traceback, param, character.Stats, table.unpack(props))
					end
					if not b then
						Ext.PrintError("[LeaderLib:ReplacePlaceholders] Error calling function for 'GetTextPlaceholder':\n", result)
					elseif result ~= nil then
						value = result
					end
				end
			end
			if Listeners.GetTextPlaceholder.All then
				for _,callback in pairs(Listeners.GetTextPlaceholder.All) do
					local b = true
					local result = nil
					if skipUnpack then
						b,result = xpcall(callback, debug.traceback, param, character.Stats)
					else
						b,result = xpcall(callback, debug.traceback, param, character.Stats, table.unpack(props))
					end
					if not b then
						Ext.PrintError("[LeaderLib:ReplacePlaceholders] Error calling function for 'GetTextPlaceholder':\n", result)
					elseif result ~= nil then
						value = result
					end
				end
			end

		end		
		if value ~= nil and value ~= "" then
			if type(value) == "number" then
				value = string.format("%i", math.floor(value))
			end
		elseif value == nil then
			value = ""
		end
		local escapedReplace = v:gsub("%[", "%%["):gsub("%]", "%%]")
		output = string.gsub(output, escapedReplace, value)
	end
	return output
end

local function ReplacePlaceholders(str, character)
	if not str then
		return str
	end
	if character ~= nil and type(character) == "string" then
		character = Ext.GetCharacter(character)
	end
	if character == nil and Client then
		character = Client:GetCharacter()
	end
	local output = str
	for v in string.gmatch(output, "%[ExtraData.-%]") do
		local key = v:gsub("%[ExtraData:", ""):gsub("%]", "")
		local value = Ext.ExtraData[key] or ""
		if value ~= "" and type(value) == "number" then
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
		-- The parameter brackets will be considered for pattern matching unless we escape them with a percentage sign.
		local escapedReplace = v:gsub("%[", "%%["):gsub("%]", "%%]")
		output = string.gsub(output, escapedReplace, value)
	end
	for v in string.gmatch(output, "%[Stats:.-%]") do
		local value = ""
		local statFetcher = v:gsub("%[Stats:", ""):gsub("%]", "")
		local props = StringHelpers.Split(statFetcher, ":")
		local stat = props[1]
		local property = props[2]
		if stat ~= nil and property ~= nil then
			value = Ext.StatGetAttribute(stat, property)
		end
		if value ~= nil and value ~= "" then
			if type(value) == "number" then
				value = string.format("%i", math.floor(value))
			end
		elseif value == nil then
			value = ""
		end
		-- The parameter brackets will be considered for pattern matching unless we escape them with a percentage sign.
		local escapedReplace = v:gsub("%[", "%%["):gsub("%]", "%%]")
		output = string.gsub(output, escapedReplace, value)
	end
	for v in string.gmatch(output, "%[SkillDamage:.-%]") do
		local value = ""
		local skillName = v:gsub("%[SkillDamage:", ""):gsub("%]", "")
		if not StringHelpers.IsNullOrWhitespace(skillName) then
			local skill = GameHelpers.Ext.CreateSkillTable(skillName)
			if skill ~= nil then
				if character == nil then
					character = Client:GetCharacter()
				end
				if character ~= nil and character.Stats ~= nil then
					local useDefaultSkillDamage = true
					local length = #Listeners.GetTooltipSkillDamage
					if length > 0 then
						for i=1,length do
							local callback = Listeners.GetTooltipSkillDamage[i]
							local b,result = xpcall(callback, debug.traceback, skill, character.Stats)
							if not b then
								Ext.PrintError("[LeaderLib:ReplacePlaceholders] Error calling function for 'GetTooltipSkillDamage':\n", result)
							elseif result ~= nil and result ~= "" then
								value = result
								useDefaultSkillDamage = false
							end
						end
					end
					if useDefaultSkillDamage then
						local damageRange = Game.Math.GetSkillDamageRange(character.Stats, skill)
						value = GameHelpers.Tooltip.FormatDamageRange(damageRange)
					end
				end
			end
		end
		if value ~= nil then
			if type(value) == "number" then
				value = string.format("%i", math.floor(value))
			end
			local escapedReplace = v:gsub("%[", "%%["):gsub("%]", "%%]")
			output = string.gsub(output, escapedReplace, value)
		end
	end
	local length = Listeners.GetTooltipSkillParam and #Listeners.GetTooltipSkillParam or 0
	if length > 0 then
		local value = ""
		for v in string.gmatch(output, "%[Skill:.-%]") do
			local fullParam = v:gsub("%[Skill:", ""):gsub("%]", "")
			local props = StringHelpers.Split(fullParam, ":")
			local skillName = ""
			local param = ""
			if #props >= 2 then
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
						for i=1,length do
							local callback = Listeners.GetTooltipSkillParam[i]
							local b,result = xpcall(callback, debug.traceback, skill, character.Stats, param)
							if not b then
								Ext.PrintError("[LeaderLib:ReplacePlaceholders] Error calling function for 'GetTooltipSkillParam':\n", result)
							elseif result ~= nil then
								value = result
							end
						end
					end
				end
			end			
			if value ~= nil and value ~= "" then
				if type(value) == "number" then
					value = string.format("%i", math.floor(value))
				end
			elseif value == nil then
				value = ""
			end
			local escapedReplace = v:gsub("%[", "%%["):gsub("%]", "%%]")
			output = string.gsub(output, escapedReplace, value)
		end
	end

	output = GetTextParamValues(output, character)
	
	for v in string.gmatch(output, "%[Key:.-%]") do
		local text = v:gsub("%[Key:", ""):gsub("%]", "")
		local key,fallback = table.unpack(StringHelpers.Split(text, ":"))
		if fallback == nil then 
			fallback = key
		end
		if not StringHelpers.IsNullOrWhitespace(key) then
			local translatedText = GameHelpers.GetStringKeyText(key, fallback)
			if translatedText == nil then 
				translatedText = "" 
			else
				translatedText = string.gsub(translatedText, "%%", "%%%%")
				translatedText = ReplacePlaceholders(translatedText, character)
			end
			local escapedReplace = v:gsub("%[", "%%["):gsub("%]", "%%]")
			output = string.gsub(output, escapedReplace, translatedText)
		end
	end
	for v in string.gmatch(output, "%[Handle:.-%]") do
		local text = v:gsub("%[Handle:", ""):gsub("%]", "")
		local props = StringHelpers.Split(text, ":")
		if props[2] == nil then 
			props[2] = ""
		end
		local translatedText = Ext.GetTranslatedString(props[1], props[2])
		if translatedText == nil then 
			translatedText = "" 
		end
		local escapedReplace = v:gsub("%[", "%%["):gsub("%]", "%%]")
		output = string.gsub(output, escapedReplace, translatedText)
	end
	return output
end

---Replace placeholder text in strings, such as ExtraData, Skill, etc.
---@param str string
---@param character EclCharacter|EsvCharacter|nil Optional character to use for the tooltip.
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

if Vars.IsClient then
	local extraPropStatusTurnsPattern = "Set (.+) for (%d+) turn%(s%).-%((%d+)%% Chance%)"

	---@param tooltip TooltipData
	---@param inputElements table
	---@param addColor boolean|nil
	function GameHelpers.Tooltip.CondensePropertiesText(tooltip, inputElements, addColor)
		local entries = {}
		for i,v in pairs(inputElements) do
			v.Label = string.gsub(v.Label, "  ", " ")
			local a,b,status,turns,chance = string.find(v.Label, extraPropStatusTurnsPattern)
			if status ~= nil and turns ~= nil and chance ~= nil then
				local color = ""
				tooltip:RemoveElement(v)
				if addColor == true then
					
				end
				table.insert(entries, {Status = status, Turns = turns, Chance = chance, Color = color})
			end
		end
		
		if #entries > 0 then
			local finalStatusText = ""
			local finalTurnsText = ""
			local finalChanceText = ""
			for i,v in pairs(entries) do
				finalStatusText = finalStatusText .. v.Status
				finalTurnsText = finalTurnsText .. v.Turns
				finalChanceText = finalChanceText .. v.Chance.."%"
				if i >= 1 and i < #entries then
					finalStatusText = finalStatusText .. "/"
					finalTurnsText = finalTurnsText .. "/"
					finalChanceText = finalChanceText .. "/"
				end
			end
			return LocalizedText.Tooltip.ExtraPropertiesOnHit:ReplacePlaceholders(finalStatusText, finalTurnsText, finalChanceText)
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