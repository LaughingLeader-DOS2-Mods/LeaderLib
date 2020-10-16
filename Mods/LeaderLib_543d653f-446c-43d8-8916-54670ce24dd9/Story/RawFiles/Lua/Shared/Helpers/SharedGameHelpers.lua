---@param pickpocketSkill integer
---@return number
function GameHelpers.GetPickpocketPricing(pickpocketSkill)
	local expLevel = Ext.Round(pickpocketSkill * Ext.ExtraData.PickpocketExperienceLevelsPerPoint)
	local priceGrowthExp = Ext.ExtraData.PriceGrowth ^ (expLevel - 1)
	if (expLevel >= Ext.ExtraData.FirstPriceLeapLevel) then
	  priceGrowthExp = priceGrowthExp * Ext.ExtraData.FirstPriceLeapGrowth / Ext.ExtraData.PriceGrowth;
	end
	if (expLevel >= Ext.ExtraData.SecondPriceLeapLevel) then
	  priceGrowthExp = priceGrowthExp * Ext.ExtraData.SecondPriceLeapGrowth / Ext.ExtraData.PriceGrowth;
	end
	if (expLevel >= Ext.ExtraData.ThirdPriceLeapLevel) then
	  priceGrowthExp = priceGrowthExp * Ext.ExtraData.ThirdPriceLeapGrowth / Ext.ExtraData.PriceGrowth
	end
	if (expLevel >= Ext.ExtraData.FourthPriceLeapLevel) then
	  priceGrowthExp = priceGrowthExp * Ext.ExtraData.FourthPriceLeapGrowth / Ext.ExtraData.PriceGrowth
	end
	local price = math.ceil(Ext.ExtraData.PickpocketGoldValuePerPoint * priceGrowthExp * Ext.ExtraData.GlobalGoldValueMultiplier)
	return 50 * round(price / 50.0)
end

--- Get an ExtraData entry, with an optional fallback value if the key does not exist.
---@param key string
---@param fallback number
---@return number
function GameHelpers.GetExtraData(key,fallback)
	return Ext.ExtraData[key] or fallback
end

--- Get all enemies within range.
---@param uuid string The character UUID.
---@param radius number
---@return number
function GameHelpers.GetEnemiesInRange(uuid,radius)
	if Ext.IsServer() then
		local character = Ext.GetCharacter(uuid)
		local totalEnemies = 0
		for i,v in pairs(character:GetNearbyCharacters(radius)) do
			if CharacterIsDead(v) == 0 and CharacterIsEnemy(uuid, v) == 1 then
				totalEnemies = totalEnemies + 1
			end
		end
		return totalEnemies
	end
	-- Client-side relation detection isn't a thing yet
	return 0
end

local function ReplacePlaceholders(str, character)
	if character ~= nil and type(character) == "string" then
		character = Ext.GetCharacter(character)
	end
	local output = str
	for v in string.gmatch(output, "%[ExtraData.-%]") do
		local key = v:gsub("%[ExtraData:", ""):gsub("%]", "")
		local value = Ext.ExtraData[key] or ""
		if value ~= "" and type(value) == "number" then
			if value == math.floor(value) then
				value = string.format("%i", math.floor(value))
			else
				if value <= 1.0 and value >= 0.0 then
					-- Percentage display
					value = value * 100
					value = string.format("%i", math.floor(value))
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
		if skillName ~= nil and skillName ~= "" then
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
	local length = #Listeners.GetTooltipSkillParam
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
			if skillName ~= nil and skillName ~= "" then
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
	
	for v in string.gmatch(output, "%[Key:.-%]") do
		local key = v:gsub("%[Key:", ""):gsub("%]", "")
		local translatedText,handle = Ext.GetTranslatedStringFromKey(key)
		if translatedText == nil then 
			translatedText = "" 
		else
			translatedText = string.gsub(translatedText, "%%", "%%%%")
			translatedText = ReplacePlaceholders(translatedText, character)
		end
		local escapedReplace = v:gsub("%[", "%%["):gsub("%]", "%%]")
		output = string.gsub(output, escapedReplace, translatedText)
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

---Get a character's user id, if any.
---@param uuid string
---@return integer|nil
function GameHelpers.GetUserID(uuid)
	if Ext.IsServer() then
		local id = CharacterGetReservedUserID(uuid)
		if id ~= -65536 then
			return id
		end
	elseif Ext.IsClient() then
		local character = Ext.GetCharacter(uuid)
		if character ~= nil then
			if character.UserID ~= -65536 then
				return character.UserID
			elseif Ext.Version() >= 53 and character.ReservedUserID ~= nil and character.ReservedUserID ~= -65536 then
				return character.ReservedUserID
			end
		end
	end
	return nil
end