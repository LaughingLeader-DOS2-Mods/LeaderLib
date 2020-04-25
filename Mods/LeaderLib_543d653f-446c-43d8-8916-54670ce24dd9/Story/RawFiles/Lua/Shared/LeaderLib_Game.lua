---@type TranslatedString
local TranslatedString = LeaderLib.Classes["TranslatedString"]



---Get localized damage text wrapped in that damage type's color.
---@param damageType string
---@param damageValue integer
---@return string
local function GetDamageText(damageType, damageValue)
	local entry = LeaderLib.LocalizedText.DamageTypeHandles[damageType]
	if entry ~= nil then
		return string.format("<font color='%s'>%s %s</font>", entry.Color, damageValue, entry.Text.Value)
	else
		Ext.PrintError("No damage name/color entry for type " .. tostring(damageType))
	end
	return ""
end

LeaderLib.Game.GetDamageText = GetDamageText

--- Get the localized name for an ability.
---@param ability string|integer
---@return string
local function GetAbilityName(ability)
	if type(ability) == "number" then
		ability = LeaderLib.Data.Ability(math.tointeger(ability))
	else
		if ability == "None" then
			return ""
		end
	end
	local entry = LeaderLib.LocalizedText.AbilityNames[ability]
	if entry ~= nil then
		return entry.Value
	else
		Ext.PrintError("[LeaderLib.Game.GetAbilityName] No ability name for ["..tostring(ability).."]")
	end
	return nil
end

LeaderLib.Game.GetAbilityName = GetAbilityName