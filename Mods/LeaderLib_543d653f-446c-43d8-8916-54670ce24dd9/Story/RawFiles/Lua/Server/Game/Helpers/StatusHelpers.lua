---Returns true if the object is sneaking or has an INVISIBLE type status.
---@param obj string
---@return boolean
function GameHelpers.Status.IsSneakingOrInvisible(obj)
    if HasActiveStatus(obj, "SNEAKING") == 1 or HasActiveStatus(obj, "INVISIBLE") == 1 then
        return true
	else
		local invisibleTable = StatusTypes["INVISIBLE"]
		if invisibleTable ~= nil then
			for status,b in pairs(invisibleTable) do
				if HasActiveStatus(obj, status) == 1 then
					return true
				end
			end
		end
        -- if Ext.Version() >= 43 then
        --     if ObjectIsCharacter(obj) == 1 then
        --         local statuses = Ext.GetCharacter(obj):GetStatuses()
        --         if statuses ~= nil then
        --             for i,v in pairs(statuses) do
        --                 local statusType = GetStatusType(v)
        --                 if statusType == "INVISIBLE" then
        --                     return true
        --                 end
        --             end
        --         end
        --     end
        -- end
    end
    return false
end

Ext.NewQuery(GameHelpers.Status.IsSneakingOrInvisible, "LeaderLib_Ext_QRY_IsSneakingOrInvisible", "[in](GUIDSTRING)_Object, [out](INTEGER)_Bool")

---Returns true if the object has a tracked type status.
---Current tracked types: ACTIVE_DEFENSE, BLIND, CHARMED, DAMAGE_ON_MOVE, DISARMED, INCAPACITATED, INVISIBLE, KNOCKED_DOWN, MUTED, POLYMORPHED
---@param obj string
---@param statusType string
---@return boolean
local function ObjectHasStatusType(obj, statusType)
	if type(statusType) == "table" then
		for i,v in pairs(statusType) do
			local check = string.upper(v)
			if HasActiveStatus(obj, check) == 1 or NRD_ObjectHasStatusType(obj, check) == 1 then
				return true
			end
		end
	else
		if statusType ~= nil and statusType ~= "" then
			statusType = string.upper(statusType)
			if HasActiveStatus(obj, statusType) == 1 or NRD_ObjectHasStatusType(obj, statusType) == 1 then
				return true
			else
				local statusTypeTable = StatusTypes[statusType]
				if statusTypeTable ~= nil then
					for status,b in pairs(statusTypeTable) do
						if HasActiveStatus(obj, status) == 1 then
							return true
						end
					end
				else
					return HasActiveStatus(obj, statusType) == 1 or NRD_ObjectHasStatusType(obj, statusType) == 1
				end
			end
		end
	end
    return false
end

GameHelpers.Status.HasStatusType = ObjectHasStatusType

Ext.NewQuery(ObjectHasStatusType, "LeaderLib_Ext_QRY_HasStatusType", "[in](GUIDSTRING)_Object, [in](STRING)_StatusType, [out](INTEGER)_Bool")

---Returns true if the object is disabled by a status.
---@param obj string
---@return boolean
function GameHelpers.Status.IsDisabled(obj)
	if ObjectHasStatusType(obj, {"KNOCKED_DOWN", "INCAPACITATED"}) then
		return true
	else
		local statuses = nil
		if ObjectIsCharacter(obj) == 1 then
			statuses = Ext.GetCharacter(obj):GetStatuses()
		elseif ObjectIsItem(obj) == 1 then
			statuses = Ext.GetItem(obj):GetStatuses()
		end
		if statuses ~= nil then
			for i,status in pairs(statuses) do
				if Ext.StatGetAttribute(status, "LoseControl") == "Yes" then
					return true
				end
			end
		end
	end
	return false
end