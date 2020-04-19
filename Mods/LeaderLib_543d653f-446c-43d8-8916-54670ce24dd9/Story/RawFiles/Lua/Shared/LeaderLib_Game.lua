local DamageTypeHandles = {
	None = {Handle="h8a070775gc251g4f34g9086gb1772f7e2cff",Content="pure damage", Color="#13D177"},
	Physical = {Handle="h40782d69gbfaeg40cegbe3cg370ef44e3980",Content="physical damage", Color="#AE9F95"},
	Piercing = {Handle="hd05581a1g83a7g4d95gb59fgfa5ef68f5c90",Content="piercing damage", Color="#CD1F1F"},
	Corrosive = {Handle="h161d5479g06d6g408egade2g37a203e3361f",Content="corrosive damage", Color="#88A25B"},
	Magic = {Handle="hdb4307b4g1a6fg4c05g9602g6a4a6e7a29d9",Content="magic damage", Color="#7F00FF"},
	-- Special LeaderLib handle
	Chaos = {Handle="h2bc14afag7627g4db8gaaa6g19c26b9820d5",Content="chaos damage", Color="#9A00FF"},
	Air = {Handle="hdd80e44fg9585g48b8ga34dgab20dc18f077",Content="air damage", Color="#7D71D9"},
	Earth = {Handle="h68b77a37g9c43g4436gb360gd651af08d7bb",Content="earth damage", Color="#F7BA14"},
	Fire = {Handle="hc4d062edgd8e6g4048gaa44g160fe3c7b018",Content="fire damage", Color="#FE6E27"},
	Poison = {Handle="ha77d36b3ge969g4461g9b30gfff624024b18",Content="poison damage", Color="#65C900"},
	Shadow = {Handle="h256557fbg1d49g45d9g8690gb86b39d2a135",Content="shadow damage", Color="#797980"},
	Water = {Handle="h8cdcfeedg357eg4877ga69egc05dbe9c68a4",Content="water damage", Color="#4197E2"},
}

---Get localized damage text wrapped in that damage type's color.
---@param damageType string
---@param damageValue integer
---@return string
local function GetDamageText(damageType, damageValue)
	local entry = DamageTypeHandles[damageType]
	if entry ~= nil then
		local name = Ext.GetTranslatedString(entry.Handle, entry.Content)
		return string.format("<font color='%s'>%s %s</font>", entry.Color, damageValue, name)
	else
		Ext.PrintError("No damage name/color entry for type " .. tostring(damageType))
	end
	return ""
end

LeaderLib.Game.GetDamageText = GetDamageText