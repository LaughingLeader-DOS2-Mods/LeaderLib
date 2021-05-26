---@type CustomSkillProperty
local SafeForce = {
	GetDescription = function(prop)
		local chance = prop.Arg1
		local distance = math.floor(prop.Arg2/6)
		if chance >= 1 then
			return LocalizedText.SkillTooltip.SafeForce:ReplacePlaceholders(GameHelpers.Math.Round(distance, 1))
		else
			chance = Ext.Round(chance * 100)
			return LocalizedText.SkillTooltip.SafeForceRandom:ReplacePlaceholders(GameHelpers.Math.Round(distance, 1), chance)
		end
	end,
	ExecuteOnPosition = function(prop, attacker, position, areaRadius, isFromItem, skill, hit)
		local chance = prop.Arg1
		local distance = math.floor(prop.Arg2/6)
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			local x,y,z = table.unpack(position)
			for i,v in pairs(Ext.GetCharactersAroundPosition(x,y,z, areaRadius)) do
				GameHelpers.ForceMoveObject(attacker, Ext.GetGameObject(v), distance)
			end
		end
	end,
	ExecuteOnTarget = function(prop, attacker, target, position, isFromItem, skill, hit)
		local chance = prop.Arg1
		local distance = math.floor(prop.Arg2/6)
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			GameHelpers.ForceMoveObject(attacker, target, distance)
		end
	end
}

Ext.RegisterSkillProperty("SafeForce", SafeForce)