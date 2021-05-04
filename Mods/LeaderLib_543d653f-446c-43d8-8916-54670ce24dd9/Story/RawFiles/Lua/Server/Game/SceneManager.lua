local SceneData = Classes.SceneData
local SceneStateData = Classes.SceneStateData

if SceneManager == nil then
	SceneManager = {}
end

---@type SceneData[]
SceneManager.Scenes = {}
---@type SceneData
SceneManager.ActiveScene = nil
SceneManager.IsActive = false
SceneManager.CurrentTime = Ext.MonotonicTime()

---@class WaitingStateData:table
---@field ID string
---@field Time number

SceneManager.Queue = {
	---@type table<string, string[]>
	StoryEvent = {},
	---@type table<string, WaitingStateData>
	Waiting = {}
}

function SceneManager.Save()
	PersistentVars.SceneData.Queue = SceneManager.Queue
end

function SceneManager.Load()
	if PersistentVars.SceneData and PersistentVars.SceneData.Queue then
		for k,v in pairs(PersistentVars.SceneData.Queue) do
			if v ~= nil then
				SceneManager.Queue[k] = v
			end
		end
	end
end

RegisterListener("SessionLoaded", function()
	SceneManager.Load()
end)

---@return SceneData
function SceneManager.CreateScene(id, params)
	local scene = SceneData:Create(id, params)
	table.insert(SceneManager.Scenes, scene)
	return scene
end

---@return SceneData|SceneData[]
function SceneManager.GetSceneByID(id)
	local scenes = {}
	for i,v in pairs(SceneManager.Scenes) do
		if v.ID == id then
			table.insert(scenes, v)
		end
	end
	if #scenes == 1 then
		return scenes[1]
	else
		return scenes
	end
end

---@param scene SceneData
function SceneManager.SetScene(scene)
	local scenes = {}
	for i,v in pairs(SceneManager.Scenes) do
		if v.ID == id then
			table.insert(scenes, v)
		end
	end
	if #scenes == 1 then
		return scenes[1]
	else
		scenes.ResumeState = function(self, ...)
			for i,v in pairs(scenes) do
				v:ResumeState(...)
			end
		end
		return scenes
	end
end

function SceneManager.AddToQueue(group, sceneId, stateId, param)
	if group == "StoryEvent" then
		if not SceneManager.Queue.StoryEvent[param] then
			SceneManager.Queue.StoryEvent[param] = {}
		end
		SceneManager.Queue.StoryEvent[param][sceneId] = stateId
	elseif group == "Waiting" then
		SceneManager.CurrentTime = Ext.MonotonicTime()
		SceneManager.Queue.Waiting[sceneId] = {ID=stateId, Time=SceneManager.CurrentTime + param}
		SceneManager.StartTimer()
	end
	SceneManager.Save()
end

RegisterListener("NamedTimerFinished", "LeaderLib_SceneManager_WaitingTimer", function(...)
	SceneManager.CurrentTime = Ext.MonotonicTime()
	for sceneId,data in pairs(SceneManager.Queue.Waiting) do
		if data.Time <= SceneManager.CurrentTime then
			local scene = SceneManager.GetSceneByID(sceneId)
			if scene then
				scene:ResumeState(data.ID)
				SceneManager.Queue.Waiting[sceneId] = nil
			end
		end
	end
	if Common.TableLength(SceneManager.Queue.Waiting, true) ~= 0 then
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
	StartTimer("LeaderLib_SceneManager_WaitingTimer", tick)
end

local function OnStoryEvent(obj, event)
	local sceneIds = SceneManager.Queue.StoryEvent[event]
	if sceneIds then
		for sceneId,stateId in pairs(sceneIds) do
			local scene = SceneManager.GetSceneByID(sceneId)
			if scene then
				scene:ResumeState(stateId)
				sceneIds[sceneId] = nil
			end
		end
		if Common.TableLength(SceneManager.Queue.StoryEvent[event], true) == 0 then
			SceneManager.Queue.StoryEvent[event] = nil
		end
		SceneManager.Save()
	end
end

RegisterProtectedOsirisListener("StoryEvent", 2, "after", function(obj, event)
	if SceneManager.IsActive then
		OnStoryEvent(StringHelpers.GetUUID(obj), event)
	end
end)