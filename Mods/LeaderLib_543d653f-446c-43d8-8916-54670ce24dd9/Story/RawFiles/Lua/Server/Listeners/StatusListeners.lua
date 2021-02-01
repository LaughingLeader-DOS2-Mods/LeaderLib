local function IgnoreStatus(status)
	if Data.IgnoredStatus[status] == true and Vars.RegisteredIgnoredStatus[status] ~= true then
		return true
	end
	return false
end

local function OnNRDOnStatusAttempt(target,status,handle,source)
	target = StringHelpers.GetUUID(target)
	source = StringHelpers.GetUUID(source)
	local callbacks = StatusListeners.BeforeAttempt[status]
	if callbacks then
		for i=1,#callbacks do
			local b,err = xpcall(callbacks[i], debug.traceback, target, status, source, handle)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
end

local function ParseNRDOnStatusAttempt(target,status,handle,source)
	if not IgnoreStatus(status) then
		OnNRDOnStatusAttempt(StringHelpers.GetUUID(target), status, handle, StringHelpers.GetUUID(source))
	end
end

RegisterProtectedOsirisListener("NRD_OnStatusAttempt", 4, "after", ParseNRDOnStatusAttempt)

local function OnStatusAttempt(target,status,source)
	target = StringHelpers.GetUUID(target)
	source = StringHelpers.GetUUID(source)
	local callbacks = StatusListeners.Attempt[status]
	if callbacks then
		for i=1,#callbacks do
			local b,err = xpcall(callbacks[i], debug.traceback, target, status, source)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
end

local function ParseStatusAttempt(target,status,source)
	if not IgnoreStatus(status) then
		OnStatusAttempt(target, status, source)
	end
end

RegisterProtectedOsirisListener("CharacterStatusAttempt", 3, "after", ParseStatusAttempt)
RegisterProtectedOsirisListener("ItemStatusAttempt", 3, "after", ParseStatusAttempt)

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
	target = StringHelpers.GetUUID(target)
	source = StringHelpers.GetUUID(source)
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
	local callbacks = StatusListeners.Applied[status]
	if callbacks then
		for i=1,#callbacks do
			local b,err = xpcall(callbacks[i], debug.traceback, target, status, source)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
end

local function OnStatusRemoved(target,status)
	target = StringHelpers.GetUUID(target)
	--PrintDebug("OnStatusRemoved", target,status)
	local source = nil
	if Vars.LeaveActionData.Total > 0 then
		source = GetStatusSource(target, status)
		if source ~= nil then
			local skill = Vars.LeaveActionData.Statuses[status]
			if skill ~= nil then
				GameHelpers.ExplodeProjectile(source, target, skill)
			end
			ClearStatusSource(target, status)
		end
	end
	local callbacks = StatusListeners.Removed[status]
	if callbacks then
		for i=1,#callbacks do
			local b,err = xpcall(callbacks[i], debug.traceback, target, status, source)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
end

local function ParseStatusApplied(target,status,source)
	if not IgnoreStatus(status) then
		OnStatusApplied(target, status, source)
	end
end

local function ParseStatusRemoved(target,status)
	if not IgnoreStatus(status) then
		OnStatusRemoved(target, status)
	end
end

RegisterProtectedOsirisListener("CharacterStatusApplied", 3, "after", ParseStatusApplied)
RegisterProtectedOsirisListener("ItemStatusChange", 3, "after", ParseStatusApplied)
RegisterProtectedOsirisListener("CharacterStatusRemoved", 3, "after", ParseStatusRemoved)
RegisterProtectedOsirisListener("ItemStatusRemoved", 3, "after", ParseStatusRemoved)