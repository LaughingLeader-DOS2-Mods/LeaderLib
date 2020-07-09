if PersistentVars.OnPrepareDamage == nil then
	PersistentVars.OnPrepareDamage = {}
end

local preResistanceDamage = PersistentVars.OnPrepareDamage

function SaveDamageAmountForResistancePenetration(target, source, damage, handle)
	for i,damageType in LeaderLib.Data.DamageTypes:Get() do
		local resistance = NRD_CharacterGetComputedStat(target, LeaderLib.Data.DamageTypeToResistance[damageType], 0)
        local typeDamage = NRD_HitGetDamage(handle, damageType)
		if resistance > 0 and typeDamage ~= nil and typeDamage > 0 then
			if preResistanceDamage[target] == nil then
				preResistanceDamage[target] = {}
				preResistanceDamage[target].Count = 0
			end
			if preResistanceDamage[target][source] == nil then
				preResistanceDamage[target][source] = {}
				preResistanceDamage[target].Count = preResistanceDamage[target].Count + 1
			end
            preResistanceDamage[target][source][damageType] = typeDamage
        end
	end
end

--- Makes damage ignore a certain amount of resistance, depending on the values on the item.
---@param target string
---@param source string
---@param damage integer
---@param handle integer
function ApplyResistancePenetration(target, source, damage, handle)
	local targetDamageTable = preResistanceDamage[target] or nil
	if targetDamageTable ~= nil then
		local damageTable = targetDamageTable[source] or nil

		if damageTable ~= nil then
			for damageType,preDamage in pairs(damageTable) do
				local currentDamage = NRD_HitStatusGetDamage(target, handle, damageType)
				local diff = preDamage - currentDamage
				
				if diff > 0 then
					local resistance = NRD_CharacterGetComputedStat(target, LeaderLib.Data.DamageTypeToResistance[damageType], 0)
					local penetrationAmount = 0

					local tags = Data.ResistancePenetrationTags[damageType]
					if tags ~= nil then
						for i,tagEntry in pairs(tags) do
							if HasTagEquipped(source, tagEntry.Tag) then
								penetrationAmount = penetrationAmount + tagEntry.Amount
							end
						end
					end

					penetrationAmount = math.min(penetrationAmount / 100, 1.0)
	
					if penetrationAmount > 0 then
						local nextDamage = preDamage - math.floor(preDamage * ((resistance / 100.0) * penetrationAmount))
						if nextDamage > 0 then
							NRD_HitStatusClearDamage(target, handle, damageType)
							NRD_HitStatusAddDamage(target, handle, damageType, nextDamage)
							Ext.Print("[LeaderLib:ResPen] Penetrated resistance for damage type", damageType)
							Ext.Print("[LeaderLib:ResPen] Resistance Amount:", resistance)
							Ext.Print("[LeaderLib:ResPen] Penetration Amount:", penetrationAmount)
							Ext.Print("[LeaderLib:ResPen] Pre Damage:", preDamage)
							Ext.Print("[LeaderLib:ResPen] Post Damage:", currentDamage)
							Ext.Print("[LeaderLib:ResPen] New Damage:", nextDamage)
							Ext.Print("[LeaderLib:ResPen] Target:", target)
							Ext.Print("[LeaderLib:ResPen] Source:", source)
						else
							NRD_HitStatusClearDamage(target, handle, damageType)
						end
					end
				end
			end

			preResistanceDamage[target][source] = nil
			preResistanceDamage[target].Count = preResistanceDamage[target].Count - 1
			if preResistanceDamage[target].Count == 0 then
				preResistanceDamage[target] = nil
			end
		end
	end
end