local _ISCLIENT = Ext.IsClient()

local _CreatedTasks = {}

---@class LeaderLibUserTaskBase
---@field Vars table A generic table to store task variables.
---@field APDescription TranslatedString
---@field Description TranslatedString
---@field DefaultAPCost integer|DefaultValue<0> Used in the GetAPCost callback.
---@field DefaultSightRange integer|DefaultValue<30>
---@field Priority integer|DefaultValue<0> Used in the default GetExecutePriority/GetPriority callbacks. Defaults to 0.

---@class LeaderLibUserTaskOptions:LeaderLibUserTaskBase


---@class LeaderLibUserTaskClientCallbackRegistration
---@field Attached fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask)), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field CanEnter fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask):boolean), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field CanExit fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask):boolean), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field CanExit2 fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask):boolean), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field ClearAIColliding fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask)), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field Enter fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask):boolean), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field EnterPreview fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask)), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field Exit fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask)), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field ExitPreview fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask)), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field GetActionCost fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask):integer), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field GetTotalAPCost fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask):integer), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field GetAPDescription fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask, description:string):string), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field GetDescription fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask, description:string):string), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field GetAPWarning fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask):integer), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field GetError fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask):integer), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field GetExecutePriority fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask, previousPriority:integer):integer), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field GetPriority fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask, previousPriority:integer):integer), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field GetSightRange fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask):number), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field HandleInputEvent fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask)), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field SetAIColliding fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask)), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field SetCursor fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask)), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field Start fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask)), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field Stop fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask)), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field Update fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask):boolean), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field UpdatePreview fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask)), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration
---@field ValidateTargetRange fun(callback: (fun(self:LeaderLibUserTaskClientSide, task:UserspaceCharacterTask):integer), replace?:boolean):LeaderLibUserTaskClientCallbackRegistration

---@class LeaderLibUserTaskServerCallbackRegistration
---@field OnExecuted fun(callback:(fun(self:LeaderLibUserTask, character:EsvCharacter))):LeaderLibUserTaskServerCallbackRegistration

local _READ_ONLY = {
	IsRegistered = true,
}

---@class LeaderLibUserTaskClientSide:LeaderLibUserTask
---@field Subscribe LeaderLibUserTaskClientCallbackRegistration
---@field GetCharacter fun():EclCharacter
---@field IsPreviewing boolean Whether the task is being previewed (EnterPreview/ExitPreview).
---@field IsRunning boolean Whether the task is running (Enter/Exit).
---@field Constructor fun(char:EclCharacter):UserspaceCharacterTaskCallbacks

---@class LeaderLibUserTaskServerSide:LeaderLibUserTask
---@field Subscribe LeaderLibUserTaskServerCallbackRegistration

---@class LeaderLibUserTask:LeaderLibUserTaskBase
---@field IsRegistered boolean
local UserTask = {
	Type = "LeaderLibUserTask",
	---Print the callback name and params for default task callbacks that were not provided.
	_DebugTrace = false,
	---The Task ID.
	ID = "",
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
		return function (...) end
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
		Enter = function (self)
			task.IsRunning = true
		end,
		Exit = function (self)
			task.IsRunning = false
		end,
		EnterPreview = function (self)
			task.IsPreviewing = true
		end,
		ExitPreview = function (self)
			task.IsPreviewing = false
		end,
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
				return task.Description.Value
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
		ValidateTargetRange = function (self)
			return task.DefaultSightRange
		end,
		HandleInputEvent = voidCallback("HandleInputEvent"),
		SetAIColliding = voidCallback("SetAIColliding"),
		SetCursor = voidCallback("SetCursor"),
		Start = voidCallback("Start"),
		Stop = voidCallback("Stop"),
		Update = function (self)
			return task.Enabled
		end,
		UpdatePreview = voidCallback("UpdatePreview"),
	}
end

---@type LeaderLibUserTaskOptions
local _DefaultOptions = {}

local _PRIVATE = {}

if _ISCLIENT then
	_PRIVATE.GetCharacter = function ()
		return Client:GetCharacter()
	end
end

---@param id FixedString
---@param opts? LeaderLibUserTaskOptions
---@return LeaderLibUserTask
function UserTask:Create(id, opts)
	local options = TableHelpers.SetDefaultOptions(opts, _DefaultOptions)
	local task = {
		ID = id,
		Vars = {},
		IsRegistered = false,
	}
	if options._DebugTrace then
		task._DebugTrace = true
	end
	if _ISCLIENT then
		task.IsPreviewing = false
		task.IsRunning = false
		local defaultCallbacks = _DefaultUserTaskCallbacks(task)
		task.Callbacks = {}
		for k,v in pairs(defaultCallbacks) do
			task.Callbacks[k] = v
		end
		task.Subscribe = {}
		task.Constructor = function (character)
			local tbl = {}
			for k,v in pairs(task.Callbacks) do
				tbl[k] = v
			end
			return tbl
		end
		local function trySubscribe(key)
			return function (callback, replaceOrignal)
				assert(type(callback) == "function", "Callback must be a function type")
				if replaceOrignal == true then
					task.Callbacks[key] = function (...)
						local b,result = xpcall(callback, debug.traceback, task, ...)
						if not b then
							fprint(LOGLEVEL.ERROR, "[LeaderLib:UserTask:%s] Error running callback (%s):\n%s", self.ID, key, result)
						end
						return false
					end
				else
					task.Callbacks[key] = function (...)
						if task._DebugTrace then
							fprint(LOGLEVEL.TRACE, "[UserTask:%s:%s] Params(%s)", task.ID, key, Lib.serpent.block({...}))
						end
						local baseCallback = defaultCallbacks[key]
						local baseResult = false
						if baseCallback then
							baseResult = pcall(baseCallback, ...)
						end
						local b,result = xpcall(callback, debug.traceback, task, ...)
						if not b then
							fprint(LOGLEVEL.ERROR, "[LeaderLib:UserTask:%s] Error running callback (%s):\n%s", self.ID, key, result)
						end
						return baseResult or false
					end
				end
				return task.Subscribe
			end
		end
		local function subscribeErrorCheck(_,key)
			if task.Callbacks[key] == nil then
				error(string.format("Key '%s' is not a valid callback ID", key), 2)
			end
			return trySubscribe(key)
		end
		setmetatable(task.Subscribe, {__index = subscribeErrorCheck})
		setmetatable(task, {
			__index = function (_,k)
				if _PRIVATE[k] ~= nil then
					return _PRIVATE[k]
				end
				return UserTask[k]
			end,
			__newindex = function (_,k,v)
				if _READ_ONLY[k] == nil and _PRIVATE[k] == nil then
					rawset(task, k, v)
				end
			end
		})
	else
		task.Callbacks = {
			OnExecuted = function () end
		}
		task.Subscribe = {}
		local function doSubscribe(key, callback)
			assert(task.Callbacks[key] ~= nil, "Key" .. tostring(key) .. "is not a valid callback")
			assert(type(callback) == "function", "Callback must be a function type")
			task.Callbacks[key] = function (...)
				local b,result = xpcall(callback, debug.traceback, task, ...)
				if not b then
					error(result, 2)
				end
				return result
			end
			return task.Subscribe
		end
		setmetatable(task.Subscribe, {__index = doSubscribe})
		setmetatable(task, {__index = UserTask})
	end
	_CreatedTasks[#_CreatedTasks+1] = task
	return task
end

---Set the task's callbacks. Can only be set if this task hasn't been registered yet.
---@param onClientSide? (fun(task:LeaderLibUserTaskClientSide)) Called if this script it on the client-side.
---@param onServerSide? (fun(task:LeaderLibUserTaskServerSide)) Called if this script it on the server-side.
---@param onInitialized? (fun(tasl:LeaderLibUserTask)) Optional function to run on both server/client sides when this task is initialized (SessionLoaded).
function UserTask:SetCallbacks(onClientSide, onServerSide, onInitialized)
	assert(self.IsRegistered == false, string.format("Task '%s' is already registered.", self.ID))
	if _ISCLIENT then
		if onClientSide then
			onClientSide(self --[[@as LeaderLibUserTaskClientSide]])
		end
	elseif onServerSide then
		onServerSide(self --[[@as LeaderLibUserTaskServerSide]])
	end
	if onInitialized then
		self._OnInitialized = onInitialized
	end
end

Classes.UserTask = UserTask

Ext.Events.SessionLoaded:Subscribe(function (e)
	for _,v in pairs(_CreatedTasks) do
		rawset(v, "IsRegistered", true)
		if _ISCLIENT then
			---@cast v LeaderLibUserTaskClientSide
			local callbacks = v.Callbacks
			if type(callbacks) == "table" then
				Ext.Behavior.RegisterCharacterTask(v.ID, v.Constructor)
			elseif callbacks ~= nil then
				fprint(LOGLEVEL.ERROR, "[SessionLoaded:LeaderLibUserTask] Callbacks key is not a table type for task (%s). Type(%s)", v.ID, type(callbacks))
			end
		end
		local onInitialized = v._OnInitialized
		if type(onInitialized) == "function" then
			local b,err = xpcall(onInitialized, debug.traceback, v)
			if not b then
				Ext.Utils.PrintError(err)
			end
		elseif onInitialized ~= nil then
			fprint(LOGLEVEL.ERROR, "[SessionLoaded:LeaderLibUserTask] OnInitialized param is not a function type for task (%s). Type(%s)", v.ID, type(onInitialized))
		end
	end
end, {Priority=0})
