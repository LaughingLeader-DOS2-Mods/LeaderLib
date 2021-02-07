Ext.Require("Server/Classes/_Init.lua")
Ext.Require("Server/Game/Helpers/MiscHelpers.lua")
Ext.Require("Server/Game/Helpers/DamageHelpers.lua")
Ext.Require("Server/Game/Helpers/HitHelpers.lua")
Ext.Require("Server/Game/Helpers/ItemHelpers.lua")
Ext.Require("Server/Game/Helpers/ProjectileHelpers.lua")
Ext.Require("Server/Game/Helpers/SkillHelpers.lua")
Ext.Require("Server/Game/Helpers/StatusHelpers.lua")
Ext.Require("Server/Game/Helpers/UIHelpers.lua")
Ext.Require("Server/Game/Helpers/MathHelpers.lua")
Ext.Require("Server/Game/Helpers/SurfaceHelpers.lua")
Ext.Require("Server/Game/Helpers/DatabaseSorting.lua")
Ext.Require("Server/Game/Helpers/GridHelpers.lua")
Ext.Require("Server/Game/GameEvents.lua")
Ext.Require("Server/Game/ComputeCharacterHit.lua")
Ext.Require("Server/Game/QualityOfLife.lua")
Ext.Require("Server/Game/VisualElementManager.lua")
Ext.Require("Server/Listeners/_Init.lua")
Ext.Require("Server/ModMenu/ModMenuServerCommands.lua")
Ext.Require("Server/Timers.lua")
Ext.Require("Server/OsirisHelpers.lua")
Ext.Require("Server/Versioning.lua")
Ext.Require("Server/Debug/ConsoleCommands.lua")
if Vars.DebugMode then
	Ext.Require("Server/Debug/DebugMain.lua")
	Ext.Require("Server/Debug/DeveloperCommands.lua")
end

local function table_has_index(tbl, index)
	if #tbl > index then
		if tbl[index] ~= nil then
            return true
        end
	end
    return false
end

local function PrintAttributes(char)
	local attributes = {"Strength", "Finesse", "Intelligence", "Constitution", "Memory", "Wits"}
	for k, att in pairs(attributes) do
		local val = CharacterGetAttribute(char, att)
		Osi.LeaderLog_Log("DEBUG", "[lua:leaderlib.PrintAttributes] (" .. char .. ") | " .. att .. " = " .. val)
	end
end

function SetModIsActiveFlag(uuid, modid)
	--local flag = string.gsub(modid, "%s+", "_") -- Replace spaces
	local flag = tostring(modid).. "_IsActive"
	local flagEnabled = GlobalGetFlag(flag)
	if NRD_IsModLoaded(uuid) == 1 then
		if flagEnabled == 0 then
			GlobalSetFlag(flag)
		end
	else
		if flagEnabled == 1 then
			GlobalClearFlag(flag)
		end
	end
end

---Set a character's name with a translated string value.
---@param char string
---@param handle string
---@param fallback string
function SetCustomNameWithLocalization(char,handle,fallback)
	local name,_ = Ext.GetTranslatedString(handle, fallback)
	CharacterSetCustomName(char, name)
end

---Get a skill's real entry name. Formats away _-1, _10, etc.
---@param skillPrototype string A skill id like Projectile_Fireball_-1
---@return string
function GetSkillEntryName(skillPrototype)
	return string.gsub(skillPrototype, "_%-?%d+$", "")
end
Ext.NewQuery(GetSkillEntryName, "LeaderLib_Ext_QRY_GetSkillEntryName", "[in](STRING)_SkillPrototype, [out](STRING)_SkillId")

local function RandomQRY(min,max)
	if min == nil then min = 0 end
	if max == nil then max = 0 end
	return Ext.Random(min,max)
end
Ext.NewQuery(RandomQRY, "LeaderLib_Ext_Random", "[in](INTEGER)_Min, [in](INTEGER)_Max, [out](INTEGER)_Ran")