local _ISCLIENT = Ext.IsClient()

---@class LeaderLibUserTask
---@field APDescription TranslatedString
---@field Description TranslatedString
---@field IsRegistered boolean
local UserTask = {
	Type = "LeaderLibUserTask",
	---The Task ID.
	ID = "",
	---Print the callback name and params for default task callbacks that were not provided.
	_DebugTrace = false,
	Enabled = true,
	---Whether the task should prevent exiting.
	Locked = false,
	DefaultAPCost = 0,
	DefaultSightRange = 30,
	Priority = 0,
}

---@param task LeaderLibUserTask
---@return UserspaceCharacterTaskCallbacks
local function _DefaultUserTaskCallbacks(task)
	local voidCallback = function(key)
		return function (self, ...)
			if task._DebugTrace then
				fprint(LOGLEVEL.TRACE, "[UserTask:%s:%s] Params(%s)", task.ID, key, Ext.DumpExport({...}))
			end
		end
	end

	return {
		Attached = voidCallback("Attached"),
		CanEnter = function (self)
			return task.Enabled
		end,
		CanExit = function (self)
			return not task.Locked
		end,
		CanExit2 = function (self)
			return not task.Locked
		end,
		ClearAIColliding = voidCallback("ClearAIColliding"),
		Enter = voidCallback("Enter"),
		Exit = voidCallback("Exit"),
		ExitPreview = voidCallback("ExitPreview"),
		GetActionCost = function (self)
			return task.DefaultAPCost
		end,
		GetTotalAPCost = function (self)
			return task.DefaultAPCost
		end,
		GetAPWarning = function (self)
			return 0
		end,
		GetDescription = function (self)
			if task.Description then
				return task.Description
			end
			return ""
		end,
		GetAPDescription = function (self)
			if task.APDescription then
				return task.APDescription:ReplacePlaceholders(self.GetActionCost(self))
			else
				return LocalizedText.Tooltip.APCost:ReplacePlaceholders(self.GetActionCost(self))
			end
		end,
		GetError = function (self)
			return 0
		end,
		GetExecutePriority = function (self, previousPriority)
			return task.Priority
		end,
		GetPriority = function (self, previousPriority)
			return task.Priority
		end,
		GetSightRange = function (self)
			return task.DefaultSightRange
		end,
		HandleInputEvent = voidCallback("HandleInputEvent"),
		SetAIColliding = voidCallback("SetAIColliding"),
		Start = voidCallback("Start"),
		Stop = voidCallback("Stop"),
		Update = function (self)
			return task.Enabled
		end,
		UpdatePreview = voidCallback("UpdatePreview"),
	}
end

---@class LeaderLibUserTaskOptions
---@field Callbacks UserspaceCharacterTaskCallbacks
---@field RegisterImmediately boolean Register the task immediately. If this isn't true, then task:Register() must be called.

local _READ_ONLY = {
	IsRegistered = true,
}

---@param id FixedString
---@param opts LeaderLibUserTaskOptions|nil
---@return LeaderLibUserTask
function UserTask:Create(id, opts)
	local task = {}
	if _ISCLIENT then
		local opts = opts or {}

		local callbacks = _DefaultUserTaskCallbacks(task)
		task._Callbacks = callbacks
		if opts.Callbacks then
			for k,v in pairs(opts.Callbacks) do
				callbacks[k] = v
			end
		end
		setmetatable(task, {
			__index = function (_,k)
				if callbacks[k] then
					return callbacks[k]
				end
				return UserTask[k]
			end,
			__newindex = function (_,k,v)
				if not _READ_ONLY[k] then
					rawset(task, k, v)
				end
			end
		})
		if not opts.RegisterImmediately then
			self.IsRegistered = true
			Ext.Behavior.RegisterCharacterTask(self.ID, callbacks)
		end
	else
		setmetatable(task, {__index = UserTask})
	end
	return task
end

---Set the task's callbacks. Can only be set if this task hasn't been registered yet.
---@param opts UserspaceCharacterTaskCallbacks
function UserTask:SetCallbacks(opts)
	if _ISCLIENT then
		assert(self.IsRegistered == false, string.format("Task '%s' is already registered.", self.ID))
		local callbacks = self._Callbacks
		if type(opts) == "table" then
			for k,v in pairs(opts) do
				callbacks[k] = v
			end
		end
	end
end

function UserTask:Register()
	if _ISCLIENT and not self.IsRegistered then
		rawset(self, "IsRegistered", true)
		Ext.Behavior.RegisterCharacterTask(self.ID, self._Callbacks)
	end
end

Classes.UserTask = UserTask