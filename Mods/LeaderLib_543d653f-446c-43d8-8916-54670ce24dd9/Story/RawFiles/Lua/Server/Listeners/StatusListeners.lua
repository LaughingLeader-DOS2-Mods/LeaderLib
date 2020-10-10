local function TrackStatusSource(target, status, source)
	if PersistentVars.StatusSource[status] == nil then
		PersistentVars.StatusSource[status] = {}
	end
	PersistentVars.StatusSource[status][target] = source
end

local function GetStatusSource(target, status)
	if PersistentVars.StatusSource[status] ~= nil then
		return PersistentVars.StatusSource[status][target]
	end
	return nil
end

local function ClearStatusSource(target, status, source)
	if PersistentVars.StatusSource[status] ~= nil then
		local canRemove = true
		if HasActiveStatus(target, status) == 1 then
			local handle = NRD_StatusGetHandle(target, status)
			if handle ~= nil then
				local otherSource = NRD_StatusGetGuidString(char, handle, "StatusSourceHandle")
				if otherSource ~= source then
					canRemove = true
				end
			end
		end
		if canRemove then
			PersistentVars.StatusSource[status][target] = nil
			if not Common.TableHasEntry(PersistentVars.StatusSource[status]) then
				PersistentVars.StatusSource[status] = nil
			end
		end
	end
end

local function OnStatusApplied(target,status,source)
	--PrintDebug("OnStatusApplied", target,status,source)
	if Vars.LeaveActionData.Total > 0 then
		local skill = Vars.LeaveActionData.Statuses[status]
		if skill ~= nil then
			local turns = GetStatusTurns(target, status)
			if turns == nil or turns == 0 then
				GameHelpers.ExplodeProjectile(source, target, skill)
			elseif not StringHelpers.IsNullOrEmpty(source) then
				TrackStatusSource(target, status, source)
			end
		end
	end
end

local function OnStatusRemoved(target,status)
	--PrintDebug("OnStatusRemoved", target,status)
	if Vars.LeaveActionData.Total > 0 then
		local source = GetStatusSource(target, status)
		if source ~= nil then
			local skill = Vars.LeaveActionData.Statuses[status]
			if skill ~= nil then
				GameHelpers.ExplodeProjectile(source, target, skill)
			end
			ClearStatusSource(target,status)
		end
	end
end

local function ParseStatusApplied(target,status,source)
	if Data.EngineStatus[status] ~= true then
		OnStatusApplied(StringHelpers.GetUUID(target), status, StringHelpers.GetUUID(source))
	end
end

local function ParseStatusRemoved(target,status)
	if Data.EngineStatus[status] ~= true then
		OnStatusRemoved(StringHelpers.GetUUID(target), status)
	end
end

Ext.RegisterOsirisListener("CharacterStatusApplied", 3, "after", ParseStatusApplied)
Ext.RegisterOsirisListener("ItemStatusChange", 3, "after", ParseStatusApplied)
Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "after", ParseStatusRemoved)
Ext.RegisterOsirisListener("ItemStatusRemoved", 3, "after", ParseStatusRemoved)