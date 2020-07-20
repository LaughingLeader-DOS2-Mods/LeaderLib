---@param pickpocketSkill integer
---@return number
local function GetPickpocketPricing(pickpocketSkill)
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

GameHelpers.GetPickpocketPricing = GetPickpocketPricing

--- Get an ExtraData entry, with an optional fallback value if the key does not exist.
---@param key string
---@param fallback number
---@return number
local function GetExtraData(key,fallback)
	return Ext.ExtraData[key] or fallback
end

GameHelpers.GetExtraData = GetExtraData