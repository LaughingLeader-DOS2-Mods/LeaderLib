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

function SceneManager.AddToQueue(group, sceneId, stateId, param, param2)
	if group == "StoryEvent" then
		if not SceneManager.Queue.StoryEvent[param] then
			SceneManager.Queue.StoryEvent[param] = {}
		end
		if param2 then
			SceneManager.Queue.StoryEvent[param][sceneId] = {State=stateId, UUID=param2}
		else
			SceneManager.Queue.StoryEvent[param][sceneId] = {State=stateId}
		end
	elseif group == "Waiting" then
		SceneManager.CurrentTime = Ext.MonotonicTime()
		SceneManager.Queue.Waiting[sceneId] = {State=stateId, Time=SceneManager.CurrentTime + param}
		SceneManager.StartTimer()
	end
	print("SceneManager.AddToQueue", Ext.JsonStringify(SceneManager.Queue))
	SceneManager.Save()
end

RegisterListener("NamedTimerFinished", "LeaderLib_SceneManager_WaitingTimer", function(...)
	print("NamedTimerFinished", "LeaderLib_SceneManager_WaitingTimer", Ext.JsonStringify(SceneManager.Queue))
	SceneManager.CurrentTime = Ext.MonotonicTime()
	for sceneId,data in pairs(SceneManager.Queue.Waiting) do
		print(SceneManager.CurrentTime, data.Time)
		if data.Time <= SceneManager.CurrentTime then
			local scene = SceneManager.GetSceneByID(sceneId)
			if scene then
				SceneManager.Queue.Waiting[sceneId] = nil
				scene:Resume(data.State)
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
	SceneManager.CurrentTime = Ext.MonotonicTime()
	StartTimer("LeaderLib_SceneManager_WaitingTimer", tick)
end

local function OnStoryEvent(obj, event)
	local sceneIds = SceneManager.Queue.StoryEvent[event]
	if sceneIds then
		for sceneId,data in pairs(sceneIds) do
			local scene = SceneManager.GetSceneByID(sceneId)
			if scene then
				if data.UUID then
					if data.UUID == obj then
						sceneIds[sceneId] = nil
						scene:Resume(data.State, obj, event)
					end
				else
					sceneIds[sceneId] = nil
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

RegisterProtectedOsirisListener("StoryEvent", 2, "after", function(obj, event)
	if SceneManager.IsActive then
		OnStoryEvent(StringHelpers.GetUUID(obj), event)
	end
end)