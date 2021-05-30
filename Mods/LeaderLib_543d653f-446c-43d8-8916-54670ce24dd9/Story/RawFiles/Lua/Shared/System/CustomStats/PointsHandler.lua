local self = CustomStatSystem

---@alias CustomStatCanRemovePointsCallback fun(id:string, stat:CustomStatData, character:EclCharacter, currentValue:integer):integer
---@alias CustomStatPointsAssignedCallback fun(id:string, stat:CustomStatData, character:EsvCharacter, previousPoints:integer, currentPoints:integer):void


self.Listeners = {
	---@type table<string, CustomStatCanRemovePointsCallback[]>
	CanRemovePoints = {All = {}},
	---@type table<string, CustomStatPointsAssignedCallback[]>
	OnPointsChanged = {All = {}}
}

if Ext.IsServer() then
	function CustomStatSystem:SetAvailablePoints(character, statId, amount, skipSync)
		local uuid = character
		if type(character) == "userdata" and character.MyGuid then
			uuid = character.MyGuid
		end
		if type(uuid) == "string" and type(amount) == "number" then
			if not PersistentVars.CustomStatAvailablePoints[uuid] then
				PersistentVars.CustomStatAvailablePoints[uuid] = {}
			end
			PersistentVars.CustomStatAvailablePoints[uuid][statId] = amount
			if Vars.DebugMode then
				fprint(LOGLEVEL.DEFAULT, "Set available points for custom stat (%s) to (%s) for character(%s). Total(%s)", statId, amount, uuid, PersistentVars.CustomStatAvailablePoints[uuid][statId])
			end

			if not skipSync then
				-- If a save is loaded or the game is stopped, it'll get synced in the next SharedData cycle anyway
				StartOneshotTimer("Timers_LeaderLib_SyncCustomStatData", 10, function()
					self:SyncData()
				end)
			end
		else
			error(string.format("Invalid parameters character(%s) uuid(%s) statId(%s) amount(%s)", tostring(character), tostring(uuid), tostring(statId), tostring(amount)), 1)
		end
	end

	---@param character EsvCharacter|UUID|NETID
	---@param statId string A stat id or stat PoolID.
	---@param amount integer
	function CustomStatSystem:AddAvailablePoints(character, statId, amount)
		local uuid = character
		if type(character) == "userdata" and character.MyGuid then
			uuid = character.MyGuid
		end
		if type(uuid) == "string" and type(amount) == "number" then
			if not PersistentVars.CustomStatAvailablePoints[uuid] then
				PersistentVars.CustomStatAvailablePoints[uuid] = {}
			end
			local current = PersistentVars.CustomStatAvailablePoints[uuid][statId] or 0
			PersistentVars.CustomStatAvailablePoints[uuid][statId] = current + amount

			if Vars.DebugMode then
				fprint(LOGLEVEL.DEFAULT, "Added (%s) available points for custom stat (%s) to character(%s). Total(%s)", amount, statId, uuid, PersistentVars.CustomStatAvailablePoints[uuid][statId])
			end

			-- If a save is loaded or the game is stopped, it'll get synced in the next SharedData cycle anyway
			StartOneshotTimer("Timers_LeaderLib_SyncCustomStatData", 10, function()
				self:SyncData()
			end)
		else
			error(string.format("Invalid parameters character(%s) uuid(%s) statId(%s) amount(%s)", tostring(character), tostring(uuid), tostring(statId), tostring(amount)), 1)
		end
	end
else

---@param id string
---@param callback CustomStatCanRemovePointsCallback
function CustomStatSystem:RegisterCanRemovePointsHandler(id, callback)
	if not self.Listeners.CanRemovePoints[id] then
		self.Listeners.CanRemovePoints[id] = {}
	end
	table.insert(self.Listeners.CanRemovePoints[id], callback)
end

---@param id string
---@param callback CustomStatPointsAssignedCallback
function CustomStatSystem:RegisterPointsChangedListener(id, callback)
	if not self.Listeners.OnPointsChanged[id] then
		self.Listeners.OnPointsChanged[id] = {}
	end
	table.insert(self.Listeners.OnPointsChanged[id], callback)
end

if Vars.DebugMode then
	CustomStatSystem:RegisterCanRemovePointsHandler("Lucky", function(id, stat, character, current)
		return current > 0
	end)
	CustomStatSystem:RegisterPointsChangedListener("All", function(id, stat, character, previousPoints, currentPoints)
		fprint(LOGLEVEL.DEFAULT, "[OnPointsChanged:%s] Stat(%s) Character(%s) %s => %s", id, stat.UUID, character.DisplayName, previousPoints, currentPoints)
	end)
end

---@return integer
function CustomStatSystem:GetTotalAvailablePoints(character)
	character = character or Client:GetCharacter()
	local points = 0
	for stat in self:GetAllStats() do
		points = points + self:GetAvailablePointsForStat(stat, character)
	end
	return points
end

---@param stat CustomStatData
---@return integer
function CustomStatSystem:GetAvailablePointsForStat(stat, character)
	character = character or Client:GetCharacter()
	local points = 0
	if stat then
		return stat.AvailablePoints or 0
	end
	return 0
end

function CustomStatSystem:GetCanAddPoints(ui, call, doubleHandle)
	local stat = self:GetStatByDouble(doubleHandle)
	if stat then
		return self:GetAvailablePointsForStat(stat) > 0
	end
	return false
end

function CustomStatSystem:GetCanRemovePoints(ui, call, doubleHandle, character)
	character = character or Client:GetCharacter()
	local stat = self:GetStatByDouble(doubleHandle)
	if stat then
		local value = self:GetStatValueForCharacter(character, stat.ID, stat.Mod)
		if value and value > 0 then
			local canRemove = false
			for listener in self:GetListenerIterator(self.Listeners.CanRemovePoints[stat.ID], self.Listeners.CanRemovePoints.All) do
				local b,result = xpcall(listener, debug.traceback, stat.ID, stat, character, value)
				if b and type(result) == "boolean" then
					canRemove = result
				else
					fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:GetAvailablePoints] Error calling listener for stat (%s):\n%s", stat.ID, result)
				end
			end
			return canRemove
		end
	end
	return false
end

function CustomStatSystem:OnStatAdded(ui, call, doubleHandle, index)
	print(call, doubleHandle, index)
	---@type CharacterSheetMainTimeline
	local this = ui:GetRoot()
	local stat_mc = this.stats_mc.customStats_mc.stats_array[index]
	local stat = self:GetStatByDouble(doubleHandle)

	-- stat_mc.plus_mc.visible = true
	-- stat_mc.minus_mc.visible = false
end

function CustomStatSystem:OnStatPointAdded(ui, call, doubleHandle)
	local stat = self:GetStatByDouble(doubleHandle)
	local stat_mc = self:GetStatMovieClipByDouble(ui, doubleHandle)

	local character = Client:GetCharacter()
	local points = stat.AvailablePoints[character.MyGuid]
	if points then
		local lastPoints = points
		if points > 0 then
			points = points - 1
			stat.AvailablePoints[character.MyGuid] = points
		end
		if points == 0 then
			stat_mc.plus_mc.visible = false
		end
		for listener in self:GetListenerIterator(self.Listeners.OnPointsChanged[stat.ID], self.Listeners.OnPointsChanged.All) do
			local b,err = xpcall(listener, debug.traceback, stat.ID, stat, character, lastPoints, points)
			if not b then
				fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:OnStatPointAdded] Error calling OnPointsChanged listener for stat (%s):\n%s", stat.ID, err)
			end
		end
		self:SyncAvailablePoints()
	end
end

function CustomStatSystem:OnStatPointRemoved(ui, call, doubleHandle)
	local stat = self:GetStatByDouble(doubleHandle)
	local stat_mc = self:GetStatMovieClipByDouble(ui, doubleHandle)

	local character = Client:GetCharacter()
	local points = stat.AvailablePoints[character.MyGuid]
	if points then
		local lastPoints = points
		stat.AvailablePoints[character.MyGuid] = stat.AvailablePoints[character.MyGuid] + 1
		for listener in self:GetListenerIterator(self.Listeners.OnPointsChanged[stat.ID], self.Listeners.OnPointsChanged.All) do
			local b,err = xpcall(listener, debug.traceback, stat.ID, stat, character, lastPoints, stat.AvailablePoints[character.MyGuid])
			if not b then
				fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:OnStatPointRemoved] Error calling OnPointsChanged listener for stat (%s):\n%s", stat.ID, err)
			end
		end
		self:SyncAvailablePoints()
	end
end

function CustomStatSystem:UpdateAvailablePoints(ui, call)
	if ui == nil then
		ui = Ext.GetUIByType(Data.UIType.characterSheet)
	end
	if ui then
		ui:Invoke("setAvailableCustomStatPoints", self:GetTotalAvailablePoints())
	end
end

Ext.RegisterUITypeCall(Data.UIType.characterSheet, "customStatAdded", function(...) CustomStatSystem:OnStatAdded(...) end)
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "plusCustomStat", function(...) CustomStatSystem:OnStatPointAdded(...) end, "After")
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "minusCustomStat", function(...) CustomStatSystem:OnStatPointRemoved(...) end, "After")
end

--[[
local this = Ext.GetUIByType(119):GetRoot().stats_mc; local txt = this.pointTexts[3]; print(txt.visible, txt.name, txt.text, txt.x, txt.y, txt.width, txt.height, txt.defaultTextFormat.font); local tf = txt.defaultTextFormat; print(tf.bold, tf.color, tf.italic, tf.align, tf.leftMargin)

local this = Ext.GetUIByType(119):GetRoot().stats_mc; for i=0,4 do print(i, this.pointTexts[i].visible, this.pointTexts[i].x, this.pointTexts[i].y); end; print("pointsFrame_mc", this.pointsFrame_mc.visible);

local this = Ext.GetUIByType(119):GetRoot().stats_mc; print("pointsFrame_mc.x", this.pointsFrame_mc.x); for i=0,4 do local txt = this.pointTexts[i]; local tf = this.pointTexts[i].defaultTextFormat; print(i, string.format("text(%s) x(%s) y(%s) width(%s) height(%s) textWidth(%s) align(%s) size(%s) font(%s) condenseWhite(%s) autoSize(%s) scaleX(%s) scaleY(%s)", txt.text, txt.x, txt.y, txt.width, txt.height, txt.textWidth, tf.align, tf.size, tf.font, txt.condenseWhite, txt.autoSize, txt.scaleX, txt.scaleY)); end;

local this = Ext.GetUIByType(119):GetRoot().stats_mc; this.pointTexts[4].x = this.pointTexts[4].x - 1; print(this.pointTexts[4].x)

print(i, string.format("x(%s) y(%s) width(%s) height(%s) align(%s) size(%s) font(%s)", txt.x, txt.y, tf.align, tf.size, tf.font))

local this = Ext.GetUIByType(119):GetRoot().stats_mc; for i=0,4 do local pw = this.pointsWarn[i]; print(i, pw.visible, pw.x, pw.y, pw.width, pw.height, pw.scaleX, pw.scaleY, pw.currentFrame); end;

local pw = Ext.GetUIByType(119):GetRoot().stats_mc.pointsWarn[4]; pw.x = pw.x - 10; print(pw.x)
]]