

local function OnStatusApplied(target,status,source)
	if Vars.LeaveActionData.Total > 0 then
		local skill = Vars.LeaveActionData.Statuses[status]
		if skill ~= nil then
			local turns = GetStatusTurns(target, status)
			if turns == 0 then
				GameHelpers.ExplodeProjectile(source, target, skill)
			end
		end
	end
end

local function OnStatusRemoved(target,status)
	if Vars.LeaveActionData.Total > 0 then
		local skill = Vars.LeaveActionData.Statuses[status]
		if skill ~= nil then
			local handle = NRD_StatusGetHandle(target, status)
			if handle ~= nil then
				local source = NRD_StatusGetGuidString(target, handle, "StatusSourceHandle")
				if source ~= nil then
					GameHelpers.ExplodeProjectile(source, target, skill)
				end
			else
				Ext.Print("Handle for status ",status," on target ",target, "is nil")
			end
		end
	end
end

--Ext.RegisterOsirisListener("CharacterStatusApplied", 3, "after", OnStatusApplied)
--Ext.RegisterOsirisListener("ItemStatusChange", 3, "after", OnStatusApplied)
Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "after", OnStatusRemoved)
Ext.RegisterOsirisListener("ItemStatusRemoved", 3, "after", OnStatusRemoved)