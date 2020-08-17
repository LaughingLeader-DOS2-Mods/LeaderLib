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
	if Vars.LeaveActionData.Total > 0 then
		local skill = Vars.LeaveActionData.Statuses[status]
		if skill ~= nil then
			local turns = GetStatusTurns(target, status)
			if turns == 0 then
				GameHelpers.ExplodeProjectile(source, target, skill)
			elseif not StringHelpers.IsNullOrEmpty(source) then
				TrackStatusSource(target, status, source)
			end
		end
	end
end

local function OnStatusRemoved(target,status)
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

local function GetUUIDFromString(str)
	local start = string.find(str, "_[^_]*$")
	if start then
		return string.sub(str, start+1, #str)
	end
	return str
end

local function ParseStatusApplied(target,status,source)
	if not Data.EngineStatus[status] then
		OnStatusApplied(GetUUIDFromString(target), status, GetUUIDFromString(source))
	end
end

local function ParseStatusRemoved(target,status,source)
	if not Data.EngineStatus[status] then
		OnStatusApplied(GetUUIDFromString(target), status, GetUUIDFromString(source))
	end
end

Ext.RegisterOsirisListener("CharacterStatusApplied", 3, "after", ParseStatusApplied)
Ext.RegisterOsirisListener("ItemStatusChange", 3, "after", ParseStatusApplied)
Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "after", ParseStatusRemoved)
Ext.RegisterOsirisListener("ItemStatusRemoved", 3, "after", ParseStatusRemoved)