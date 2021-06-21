---@alias BeforeStatusAttemptCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, handle:integer):void
---@alias StatusEventCallback fun(target:string, status:string, source:string|nil):void
---@alias StatusEventID string

StatusListeners = {}
---@type table<string, BeforeStatusAttemptCallback[]>
StatusListeners.BeforeAttempt = {}
---@type table<string, StatusEventCallback[]>
StatusListeners.Attempt = {}
---@type table<string, StatusEventCallback[]>
StatusListeners.Applied = {}
---@type table<string, StatusEventCallback[]>
StatusListeners.Removed = {}

---If a mod registers a listener for an ignored status (such as HIT), it will be added to this table to allow callbacks to run for that status.
---@type table<string,boolean>
Vars.RegisteredIgnoredStatus = {}

---Values for the RegisterStatusListener event parameter.
---@class StatusEventValues
---@field BeforeAttempt StatusEventID BeforeAttempt, NRD_OnStatusAttempt
---@field Attempt StatusEventID Attempt, CharacterStatusAttempt/ItemStatusAttempt
---@field Applied StatusEventID Applied, CharacterStatusApplied/ItemStatusChange
---@field Removed StatusEventID Removed, CharacterStatusRemoved/ItemStatusRemoved
Vars.StatusEvent = {
	BeforeAttempt = "BeforeAttempt",
	Attempt = "Attempt",
	Applied = "Applied",
	Removed = "Removed",
}

---@param event StatusEventID BeforeAttempt, Attempt, Applied, Removed
---@param status string
---@param callback StatusEventCallback
function RegisterStatusListener(event, status, callback)
    local statusEventHolder = StatusListeners[event]
	if statusEventHolder then
        if type(status) == "table" then
			for i,v in pairs(status) do
				RegisterStatusListener(event, v, callback)
            end
        else
            if StringHelpers.Equals(status, "All", true) then
                status = "All"
            elseif Data.IgnoredStatus[status] == true then
                Vars.RegisteredIgnoredStatus[status] = true
            end

            if statusEventHolder[status] == nil then
                statusEventHolder[status] = {}
            end
            table.insert(statusEventHolder[status], callback)
        end
    end
end

---@param event StatusEventID
---@param status string
---@param callback StatusEventCallback
---@param removeAll boolean|nil
function RemoveStatusListener(event, status, callback, removeAll)
    local statusEventHolder = StatusListeners[event]
    if statusEventHolder then
        local tbl = statusEventHolder[status]
        if tbl then
            if removeAll ~= true then
                for i,v in pairs(tbl) do
                    if v == callback then
                        table.remove(tbl, i)
                    end
                end
            else
                statusEventHolder[status] = nil
            end
        end
    end
end

Ext.Require("Server/Listeners/ClientMessageReceiver.lua")
Ext.Require("Server/Listeners/HitListeners.lua")
Ext.Require("Server/Listeners/SkillListeners.lua")
Ext.Require("Server/Listeners/StatusListeners.lua")
Ext.Require("Server/Listeners/OsirisListeners.lua")
Ext.Require("Server/Listeners/CharacterStatListeners.lua")