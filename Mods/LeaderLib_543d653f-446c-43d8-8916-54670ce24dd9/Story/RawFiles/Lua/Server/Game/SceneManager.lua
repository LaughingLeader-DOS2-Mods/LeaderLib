local SceneData = Classes.SceneData
local SceneStateData = Classes.SceneStateData

if SceneManager == nil then
	SceneManager = {}
end

---@type SceneData[]
SceneManager.Scenes = {}
SceneManager.ActiveScene = {ID = "", State = ""}
SceneManager.IsActive = false
SceneManager.CurrentTime = Ext.MonotonicTime()
SceneManager.QueueType = {
	StoryEvent = "StoryEvent",
	Waiting = "Waiting",
	DialogEnded = "DialogEnded",
	Signal = "Signal"
}
---@type thread
SceneManager.LastThread = nil

---Resumes the last coroutine thread saved, possibly before a scene state was resumed.
function SceneManager.ResumeLastThread()
	if SceneManager.LastThread then
		local thread = SceneManager.LastThread
		SceneManager.LastThread = nil
		PrintDebug("[SceneManager.ResumeLastThread] Resuming last thread", thread)
		coroutine.resume(thread)
	end
end

---@class StoryEventStateData:table
---@field State string
---@field UUID string|nil

---@class WaitingStateData:table
---@field State string
---@field Time number

---@class DialogStateData:table
---@field State string
---@field Instance integer
---@field IsAutomated boolean

---@class SignalStateData:table
---@field State string
---@field Time integer|nil An optional timeout.

SceneManager.Queue = {
	---@type table<string, table<string, StoryEventStateData[]>>
	StoryEvent = {},
	---@type table<string, WaitingStateData>
	Waiting = {},
	---@type table<string, table<string, DialogStateData>>
	DialogEnded = {},
	---@type table<string, SignalStateData>
	Signal = {}
}
function SceneManager.AddToQueue(group, sceneId, stateId, param, param2, param3, ...)
	if group == SceneManager.QueueType.StoryEvent then
		if not SceneManager.Queue.StoryEvent[param] then
			SceneManager.Queue.StoryEvent[param] = {}
		end
		if param2 then
			SceneManager.Queue.StoryEvent[param][sceneId] = {State=stateId, UUID=param2}
		else
			SceneManager.Queue.StoryEvent[param][sceneId] = {State=stateId}
		end
	elseif group == SceneManager.QueueType.DialogEnded then
		local dialog = param
		local isAutomated = param2
		local instance = param3
		if not SceneManager.Queue.DialogEnded[dialog] then
			SceneManager.Queue.DialogEnded[dialog] = {}
		end
		if instance then
			SceneManager.Queue.DialogEnded[dialog][sceneId] = {State=stateId, IsAutomated=isAutomated, Instance=instance}
		else
			SceneManager.Queue.DialogEnded[dialog][sceneId] = {State=stateId, IsAutomated=isAutomated}
		end
	elseif group == SceneManager.QueueType.Signal then
		if not SceneManager.Queue.Signal[param] then
			SceneManager.Queue.Signal[param] = {}
		end
		if param2 and type(param2) == "number" and param2 > 0 then
			SceneManager.CurrentTime = Ext.MonotonicTime()
			SceneManager.Queue.Signal[sceneId] = {State=stateId, Time=SceneManager.CurrentTime + param2}
			SceneManager.StartTimer()
		else
			SceneManager.Queue.Signal[param][sceneId] = {State=stateId}
		end
	elseif group == SceneManager.QueueType.Waiting then
		SceneManager.CurrentTime = Ext.MonotonicTime()
		SceneManager.Queue.Waiting[sceneId] = {State=stateId, Time=SceneManager.CurrentTime + param}
		SceneManager.StartTimer()
	end
	PrintDebug("SceneManager.AddToQueue", group, sceneId, stateId, param, param2, param3, Ext.JsonStringify(SceneManager.Queue))
	SceneManager.Save()
end

function SceneManager.Save()
	PersistentVars.SceneData.Queue = SceneManager.Queue
	PersistentVars.SceneData.ActiveScene = SceneManager.ActiveScene
end

function SceneManager.Load()
	if Vars.DebugMode then
		PersistentVars.SceneData.Queue = SceneManager.Queue
		PersistentVars.SceneData.ActiveScene = SceneManager.ActiveScene
	else
		if PersistentVars.SceneData then
			if PersistentVars.SceneData.Queue then
				for k,v in pairs(PersistentVars.SceneData.Queue) do
					if v ~= nil then
						SceneManager.Queue[k] = v
					end
				end
			end
			if PersistentVars.SceneData.ActiveScene and PersistentVars.SceneData.ActiveScene.ID then
				SceneManager.ActiveScene.ID = PersistentVars.SceneData.ActiveScene.ID
				SceneManager.ActiveScene.State = PersistentVars.SceneData.ActiveScene.State or ""
			end
		end
		if not SceneManager.IsActive and SceneManager.ActiveScene.ID ~= "" then
			local scene = SceneManager.GetSceneByID(SceneManager.ActiveScene.ID)
			if scene then
				SceneManager.SetScene(scene, SceneManager.ActiveScene.State)
			end
		end
	end
end

---@return SceneData
function SceneManager.CreateScene(id, params)
	local scene = SceneData:Create(id, params)
	table.insert(SceneManager.Scenes, scene)
	return scene
end

---@param scene SceneData
---@param uniqueOnly boolean
function SceneManager.AddScene(scene, uniqueOnly)
	if uniqueOnly == true then
		for i,v in pairs(SceneManager.Scenes) do
			if v.ID == scene.ID then
				return scene
			end
		end
	else
		table.insert(SceneManager.Scenes, scene)
	end
	return scene
end

---@param id string
---@param firstOnly boolean|nil
---@return SceneData|SceneData[]
function SceneManager.GetSceneByID(id, firstOnly)
	local scenes = {}
	for i,v in pairs(SceneManager.Scenes) do
		if v.ID == id then
			table.insert(scenes, v)
		end
	end
	if #scenes == 1 then
		return scenes[1]
	else
		if firstOnly then
			return scenes[1]
		else
			return scenes
		end
	end
end

---@param scene SceneData
function SceneManager.SetScene(scene, state, ...)
	if not StringHelpers.IsNullOrEmpty(state) then
		scene:Resume(state, ...)
	else
		scene:Start(...)
	end
end


---@param id string
---@param state string
function SceneManager.SetSceneByID(id, state, ...)
	local scene = SceneManager.GetSceneByID(id, true)
	if scene then
		SceneManager.SetScene(scene, state, ...)
	end
end

---Send out a signal to scenes in the queue. Will resume any scene waiting for a signal with the same name.
---@param name string
function SceneManager.Signal(name)
	local sceneIds = SceneManager.Queue.Signal[name]
	if sceneIds then
		for sceneId,data in pairs(sceneIds) do
			sceneIds[sceneId] = nil
			local scene = SceneManager.GetSceneByID(sceneId)
			if scene then
				scene:Resume(data.State)
			end
		end
		if Common.TableLength(SceneManager.Queue.Signal[name], true) == 0 then
			SceneManager.Queue.Signal[name] = nil
		end
		SceneManager.Save()
	end
end

Timer.RegisterListener("LeaderLib_SceneManager_WaitingTimer", function()
	local keepTimerGoing = false
	SceneManager.CurrentTime = Ext.MonotonicTime()
	for sceneId,data in pairs(SceneManager.Queue.Waiting) do
		if data.Time <= SceneManager.CurrentTime then
			SceneManager.Queue.Waiting[sceneId] = nil
			local scene = SceneManager.GetSceneByID(sceneId)
			if scene then
				scene:Resume(data.State)
			end
		else
			keepTimerGoing = true
		end
	end
	for sceneId,data in pairs(SceneManager.Queue.Signal) do
		if data.Time then
			if data.Time <= SceneManager.CurrentTime then
				SceneManager.Queue.Signal[sceneId] = nil
				local scene = SceneManager.GetSceneByID(sceneId)
				if scene then
					scene:Resume(data.State)
				end
			else
				keepTimerGoing = true
			end
		end
	end
	if keepTimerGoing then
		StartTimer("LeaderLib_SceneManager_WaitingTimer", 250)
	end
	SceneManager.Save()
end)

function SceneManager.StartTimer(tick)
	local db = Osi.DB_LeaderLib_Helper_Temp_LuaTimer:Get("LeaderLib_SceneManager_WaitingTimer", "LeaderLib_SceneManager_WaitingTimer")
	if db and #db > 0 then
		-- Timer is already running
		return
	end
	if tick == nil then
		tick = 250
	end
	SceneManager.CurrentTime = Ext.MonotonicTime()
	StartTimer("LeaderLib_SceneManager_WaitingTimer", tick)
end

local function OnStoryEvent(obj, event)
	local sceneIds = SceneManager.Queue.StoryEvent[event]
	if sceneIds then
		for sceneId,data in pairs(sceneIds) do
			local scene = SceneManager.GetSceneByID(sceneId)
			if data.UUID then
				if data.UUID == obj then
					sceneIds[sceneId] = nil
					if scene then
						scene:Resume(data.State, obj, event)
					end
				end
			else
				sceneIds[sceneId] = nil
				if scene then
					scene:Resume(data.State, obj, event)
				end
			end
		end
		if Common.TableLength(SceneManager.Queue.StoryEvent[event], true) == 0 then
			SceneManager.Queue.StoryEvent[event] = nil
		end
		SceneManager.Save()
	end
end

Ext.RegisterOsirisListener("StoryEvent", 2, "after", function(obj, event)
	OnStoryEvent(StringHelpers.GetUUID(obj), event)
end)

Ext.RegisterOsirisListener("DialogEnded", 2, "after", function(dialog, instance)
	local sceneIds = SceneManager.Queue.DialogEnded[dialog]
	if sceneIds then
		for sceneId,data in pairs(sceneIds) do
			if not data.IsAutomated and (not data.Instance or data.Instance == instance) then
				sceneIds[sceneId] = nil
				local scene = SceneManager.GetSceneByID(sceneId)
				if scene then
					scene:Resume(data.State, dialog, instance)
				end
			end
		end
		if Common.TableLength(SceneManager.Queue.DialogEnded[dialog], true) == 0 then
			SceneManager.Queue.DialogEnded[dialog] = nil
		end
		SceneManager.Save()
	end
end)

Ext.RegisterOsirisListener("AutomatedDialogEnded", 2, "after", function(dialog, instance)
	local sceneIds = SceneManager.Queue.DialogEnded[dialog]
	if sceneIds then
		for sceneId,data in pairs(sceneIds) do
			if data.IsAutomated and (not data.Instance or data.Instance == instance) then
				sceneIds[sceneId] = nil
				local scene = SceneManager.GetSceneByID(sceneId)
				if scene then
					scene:Resume(data.State, dialog, instance)
				end
			end
		end
		if Common.TableLength(SceneManager.Queue.DialogEnded[dialog], true) == 0 then
			SceneManager.Queue.DialogEnded[dialog] = nil
		end
		SceneManager.Save()
	end
end)

Ext.RegisterOsirisListener("DB_DialogName", 2, "after", function(dialog, instance)
	local sceneIds = SceneManager.Queue.DialogEnded[dialog]
	if sceneIds then
		local saveChanges = false
		for sceneId,data in pairs(sceneIds) do
			if not data.Instance then
				data.Instance = instance
				saveChanges = true
			end
		end
		if saveChanges then
			PrintDebug("SceneManager.DB_DialogName", Ext.JsonStringify(SceneManager.Queue.DialogEnded))
			SceneManager.Save()
		end
	end
end)