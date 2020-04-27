---@type TranslatedString
local TranslatedString = Classes["TranslatedString"]

---Get localized damage text wrapped in that damage type's color.
---@param damageType string
---@param damageValue integer
---@return string
local function GetDamageText(damageType, damageValue)
	local entry = LocalizedText.DamageTypeHandles[damageType]
	if entry ~= nil then
		if damageValue ~= nil then
			return string.format("<font color='%s'>%s %s</font>", entry.Color, damageValue, entry.Text.Value)
		else
			return string.format("<font color='%s'>%s</font>", entry.Color, entry.Text.Value)
		end
	else
		Ext.PrintError("No damage name/color entry for type " .. tostring(damageType))
	end
	return ""
end

Game.GetDamageText = GetDamageText

--- Get the localized name for an ability.
---@param ability string|integer
---@return string
local function GetAbilityName(ability)
	if type(ability) == "number" then
		ability = Data.Ability(math.tointeger(ability))
	else
		if ability == "None" then
			return ""
		end
	end
	local entry = LocalizedText.AbilityNames[ability]
	if entry ~= nil then
		return entry.Value
	else
		Ext.PrintError("[Game.GetAbilityName] No ability name for ["..tostring(ability).."]")
	end
	return nil
end

Game.GetAbilityName = GetAbilityName

--- Get an ExtraData entry, with an optional fallback value if the key does not exist.
---@param key string
---@param fallback number
---@return number
local function GetExtraData(key,fallback)
	local value = Ext.ExtraData[key]
	if value ~= nil then
		return value
	end
	return fallback
end

Game.GetExtraData = GetExtraData