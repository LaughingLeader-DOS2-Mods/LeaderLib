local self = CustomStatSystem

---@alias CustomStatCanAddPointsCallback fun(id:string, stat:CustomStatData, character:EclCharacter, currentValue:integer, availablePoints:integer, canAdd:boolean):boolean
---@alias CustomStatCanRemovePointsCallback fun(id:string, stat:CustomStatData, character:EclCharacter, currentValue:integer, canRemove:boolean):boolean
---@alias OnAvailablePointsChangedCallback fun(id:string, stat:CustomStatData, character:EsvCharacter, previousPoints:integer, currentPoints:integer):void
---@alias OnStatValueChangedCallback fun(id:string, stat:CustomStatData, character:EsvCharacter, previousPoints:integer, currentPoints:integer):void

local isClient = Ext.IsClient()

CustomStatSystem.Listeners = {
	---@type table<string, OnAvailablePointsChangedCallback[]>
	OnAvailablePointsChanged = {All = {}},
	---@type table<string, OnStatValueChangedCallback[]>
	OnStatValueChanged = {All = {}},
}

if isClient then
	---@type table<string, CustomStatCanAddPointsCallback[]>
	CustomStatSystem.Listeners.CanAddPoints = {All = {}}
	---@type table<string, CustomStatCanRemovePointsCallback[]>
	CustomStatSystem.Listeners.CanRemovePoints = {All = {}}
end

---@param id string
---@param callback CustomStatCanAddPointsCallback
function CustomStatSystem:RegisterCanAddPointsHandler(id, callback)
	if not isClient then
		fprint(LOGLEVEL.ERROR, "[CustomStatSystem:RegisterCanAddPointsHandler] This listener is only for the client-side. Stat(%s)", Common.Dump(id))
		return
	end
	if type(id) == "table" then
		for i=1,#id do
			self:RegisterCanAddPointsHandler(id[i], callback)
		end
	else
		if not self.Listeners.CanAddPoints[id] then
			self.Listeners.CanAddPoints[id] = {}
		end
		table.insert(self.Listeners.CanAddPoints[id], callback)
	end
end

---@param id string
---@param callback CustomStatCanRemovePointsCallback
function CustomStatSystem:RegisterCanRemovePointsHandler(id, callback)
	if not isClient then
		fprint(LOGLEVEL.ERROR, "[CustomStatSystem:RegisterCanRemovePointsHandler] This listener is only for the client-side. Stat(%s)", Common.Dump(id))
		return
	end
	if type(id) == "table" then
		for i=1,#id do
			self:RegisterCanRemovePointsHandler(id[i], callback)
		end
	else
		if not self.Listeners.CanRemovePoints[id] then
			self.Listeners.CanRemovePoints[id] = {}
		end
		table.insert(self.Listeners.CanRemovePoints[id], callback)
	end
end

---@param id string
---@param callback OnAvailablePointsChangedCallback
function CustomStatSystem:RegisterAvailablePointsChangedListener(id, callback)
	if type(id) == "table" then
		for i=1,#id do
			self:RegisterAvailablePointsChangedListener(id[i], callback)
		end
	else
		if not self.Listeners.OnAvailablePointsChanged[id] then
			self.Listeners.OnAvailablePointsChanged[id] = {}
		end
		table.insert(self.Listeners.OnAvailablePointsChanged[id], callback)
	end
end

---@param id string
---@param callback OnAvailablePointsChangedCallback
function CustomStatSystem:RegisterStatValueChangedListener(id, callback)
	if type(id) == "table" then
		for i=1,#id do
			self:RegisterStatValueChangedListener(id[i], callback)
		end
	else
		if not self.Listeners.OnStatValueChanged[id] then
			self.Listeners.OnStatValueChanged[id] = {}
		end
		table.insert(self.Listeners.OnStatValueChanged[id], callback)
	end
end

function CustomStatSystem:InvokeStatValueChangedListeners(stat, character, last, current)
	for listener in self:GetListenerIterator(self.Listeners.OnStatValueChanged[stat.ID], self.Listeners.OnStatValueChanged.All) do
		local b,err = xpcall(listener, debug.traceback, stat.ID, stat, character, last, current)
		if not b then
			fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:OnStatPointAdded] Error calling OnStatValueChanged listener for stat (%s):\n%s", stat.ID, err)
		end
	end
end

---@param character EsvCharacter|UUID|NETID
---@param statId string A stat id or stat PoolID.
---@param amount integer
---@param skipSync boolean Skips syncing if true.
function CustomStatSystem:SetAvailablePoints(character, statId, amount, skipSync)
	local uuid = character
	if type(character) == "userdata" and character.MyGuid then
		uuid = character.MyGuid
	end
	if type(uuid) == "string" and type(amount) == "number" then
		-- local targetTable = nil
		-- if Ext.IsServer() then
		-- 	targetTable = PersistentVars.CustomStatAvailablePoints
		-- else
		-- 	targetTable = self.PointsPool
		-- end
		if self.PointsPool then
			if not self.PointsPool[uuid] then
				self.PointsPool[uuid] = {}
			end
			self.PointsPool[uuid][statId] = amount
			if Vars.DebugMode and amount ~= self.PointsPool[uuid][statId] then
				fprint(LOGLEVEL.DEFAULT, "Set available points for custom stat or pool (%s) to (%s) for character(%s). Total(%s)", statId, amount, uuid, self.PointsPool[uuid][statId])
			end
			if not skipSync then
				if not isClient then
					-- If a save is loaded or the game is stopped, it'll get synced in the next SharedData cycle anyway
					Timer.StartOneshot("Timers_LeaderLib_SyncCustomStatData", 10, function()
						self:SyncData()
					end)
				end
			end
		end
	else
		error(string.format("Invalid parameters character(%s) uuid(%s) statId(%s) amount(%s)", tostring(character), tostring(uuid), tostring(statId), tostring(amount)), 1)
	end
end

if not isClient then
	Ext.RegisterNetListener("LeaderLib_CustomStatSystem_AvailablePointsChanged", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local character = Ext.GetCharacter(data.NetID)
			local stat = CustomStatSystem:GetStatByID(data.Stat, data.Mod)
			if character and stat then
				for listener in self:GetListenerIterator(self.Listeners.OnAvailablePointsChanged[stat.ID], self.Listeners.OnAvailablePointsChanged.All) do
					local b,err = xpcall(listener, debug.traceback, stat.ID, stat, character, data.Last, data.Current)
					if not b then
						fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:OnStatPointAdded] Error calling OnAvailablePointsChanged listener for stat (%s):\n%s", stat.ID, err)
					end
				end
			end
		end
	end)
	Ext.RegisterNetListener("LeaderLib_CustomStatSystem_StatValuesChanged", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local character = Ext.GetCharacter(data.NetID)
			for _,v in pairs(data.Stats) do
				local stat = CustomStatSystem:GetStatByID(v.ID, v.Mod)
				if stat then
					local last = stat.LastValue[character.MyGuid] or 0
					local current = stat:GetValue(character)
					if last ~= current then
						CustomStatSystem:InvokeStatValueChangedListeners(stat, character, last, current)
					end
					stat.LastValue[character.MyGuid] = current
				end
			end
		end
	end)

	---@param character EsvCharacter|UUID|NETID
	---@param statId string A stat id or stat PoolID.
	---@param amount integer
	function CustomStatSystem:AddAvailablePoints(character, statId, amount)
		local uuid = character
		if type(character) == "userdata" and character.MyGuid then
			uuid = character.MyGuid
		end
		if type(uuid) == "string" and type(amount) == "number" then
			if not self.PointsPool[uuid] then
				self.PointsPool[uuid] = {}
			end
			local current = self.PointsPool[uuid][statId] or 0
			self.PointsPool[uuid][statId] = current + amount

			if Vars.DebugMode then
				fprint(LOGLEVEL.DEFAULT, "Added (%s) available points for custom stat (%s) to character(%s). Total(%s)", amount, statId, uuid, self.PointsPool[uuid][statId])
			end

			-- If a save is loaded or the game is stopped, it'll get synced in the next SharedData cycle anyway
			Timer.StartOneshot("Timers_LeaderLib_SyncCustomStatData", 10, function()
				self:SyncData()
			end)
		else
			error(string.format("Invalid parameters character(%s) uuid(%s) statId(%s) amount(%s)", tostring(character), tostring(uuid), tostring(statId), tostring(amount)), 1)
		end
	end

	---@param character EsvCharacter|UUID|NETID
	---@param statId string A stat id.
	---@param amount integer The amount to modify the stat by.
	---@param mod string|nil A mod UUID to use when fetching the stat by ID.
	function CustomStatSystem:ModifyStat(character, statId, amount, mod)
		if type(character) ~= "userdata" then
			character = Ext.GetCharacter(character)
		end
		if character then
			local stat = self:GetStatByID(statId, mod)
			if stat then
				local current = stat:GetValue(character)
				if StringHelpers.IsNullOrWhitespace(stat.UUID) then
					stat.UUID = Ext.CreateCustomStat(stat.DisplayName, stat.Description)
				end
				character:SetCustomStat(stat.UUID, current + amount)
				return true
			else
				error(string.format("Stat does not exist. statId(%s) mod(%s)", statId or "nil", mod or ""), 2)
			end
		else
			error(string.format("Failed to get character from (%s)", character or ""), 2)
		end
	end

	---@param character EsvCharacter|UUID|NETID
	---@param statId string A stat id.
	---@param amount integer The value to set the stat to.
	---@param mod string|nil A mod UUID to use when fetching the stat by ID.
	function CustomStatSystem:SetStat(character, statId, amount, mod)
		if type(character) ~= "userdata" then
			character = Ext.GetCharacter(character)
		end
		if character then
			local stat = self:GetStatByID(statId, mod)
			if stat then
				if StringHelpers.IsNullOrWhitespace(stat.UUID) then
					stat.UUID = Ext.CreateCustomStat(stat.DisplayName, stat.Description)
				end
				character:SetCustomStat(stat.UUID, amount)
				return true
			else
				error(string.format("Stat does not exist. statId(%s) mod(%s)", statId or "nil", mod or ""), 2)
			end
		else
			error(string.format("Failed to get character from (%s)", character or ""), 2)
		end
	end
end

if isClient then
---@return integer
function CustomStatSystem:GetTotalAvailablePoints(character)
	character = character or Client:GetCharacter()
	local points = 0
	local pointsTable = nil
	if character and self.PointsPool[character.MyGuid] then
		for id,amount in pairs(self.PointsPool[character.MyGuid]) do
			points = points + amount
		end
	end
	-- for stat in self:GetAllStats() do
	-- 	points = points + self:GetAvailablePointsForStat(stat, character)
	-- end
	return points
end

---@param stat CustomStatData
---@return integer
function CustomStatSystem:GetAvailablePointsForStat(stat, character)
	character = character or Client:GetCharacter()
	local points = 0
	if stat and character and stat.AvailablePoints then
		return stat.AvailablePoints[character.MyGuid] or 0
	end
	return 0
end

function CustomStatSystem:GetCanAddPoints(ui, doubleHandle, character)
	if GameHelpers.Client.IsGameMaster(ui) == true then
		return true
	end
	character = character or Client:GetCharacter()
	local stat = self:GetStatByDouble(doubleHandle)
	if stat then
		local value = self:GetStatValueForCharacter(character, stat.ID, stat.Mod)
		local availablePoints = self:GetAvailablePointsForStat(stat)
		local canAdd = availablePoints > 0
		for listener in self:GetListenerIterator(self.Listeners.CanAddPoints[stat.ID], self.Listeners.CanRemovePoints.All) do
			local b,result = xpcall(listener, debug.traceback, stat.ID, stat, character, value, availablePoints, canAdd)
			if b then
				if type(result) == "boolean" then
					canAdd = result
				end
			else
				fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:GetAvailablePoints] Error calling CanAddPoints listener for stat (%s):\n%s", stat.ID, result)
			end
		end
		return canAdd
	end
	return false
end

function CustomStatSystem:GetCanRemovePoints(ui, doubleHandle, character)
	if GameHelpers.Client.IsGameMaster(ui) == true then
		return true
	end
	character = character or Client:GetCharacter()
	local stat = self:GetStatByDouble(doubleHandle)
	if stat then
		local value = self:GetStatValueForCharacter(character, stat.ID, stat.Mod)
		if value then
			local canRemove = false
			for listener in self:GetListenerIterator(self.Listeners.CanRemovePoints[stat.ID], self.Listeners.CanRemovePoints.All) do
				local b,result = xpcall(listener, debug.traceback, stat.ID, stat, character, value, canRemove)
				if b then
					if type(result) == "boolean" then
						canRemove = result
					end
				else
					fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:GetAvailablePoints] Error calling CanRemovePoints listener for stat (%s):\n%s", stat.ID, result)
				end
			end
			return canRemove
		end
	end
	return false
end

function CustomStatSystem:OnStatPointAdded(ui, call, doubleHandle)
	local stat = self:GetStatByDouble(doubleHandle)
	local stat_mc = self:GetStatMovieClipByDouble(ui, doubleHandle)

	local character = Client:GetCharacter()
	if character then
		local points = stat.AvailablePoints and stat.AvailablePoints[character.MyGuid] or nil
		if points then
			local lastPoints = points
			if points > 0 then
				points = points - 1
				stat.AvailablePoints[character.MyGuid] = points
			end
			if points == 0 then
				local isGM = GameHelpers.Client.IsGameMaster(ui)
				stat_mc.plus_mc.visible = isGM
				if isGM then
					stat_mc.minus_mc.visible = isGM
				end
			end
			for listener in self:GetListenerIterator(self.Listeners.OnAvailablePointsChanged[stat.ID], self.Listeners.OnAvailablePointsChanged.All) do
				local b,err = xpcall(listener, debug.traceback, stat.ID, stat, character, lastPoints, points)
				if not b then
					fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:OnStatPointAdded] Error calling OnAvailablePointsChanged listener for stat (%s):\n%s", stat.ID, err)
				end
			end
			Ext.PostMessageToServer("LeaderLib_CustomStatSystem_AvailablePointsChanged", Ext.JsonStringify({
				NetID = character.NetID,
				Stat = stat.ID,
				Mod = stat.Mod,
				Last = lastPoints,
				Current = points
			}))
			self:SyncAvailablePoints()
		end
	end
end

function CustomStatSystem:OnStatPointRemoved(ui, call, doubleHandle)
	local stat = self:GetStatByDouble(doubleHandle)
	local stat_mc = self:GetStatMovieClipByDouble(ui, doubleHandle)
	local character = Client:GetCharacter()
	local points = stat.AvailablePoints and stat.AvailablePoints[character.MyGuid] or nil
	if points then
		local lastPoints = points
		stat.AvailablePoints[character.MyGuid] = stat.AvailablePoints[character.MyGuid] + 1
		for listener in self:GetListenerIterator(self.Listeners.OnAvailablePointsChanged[stat.ID], self.Listeners.OnAvailablePointsChanged.All) do
			local b,err = xpcall(listener, debug.traceback, stat.ID, stat, character, lastPoints, stat.AvailablePoints[character.MyGuid])
			if not b then
				fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:OnStatPointRemoved] Error calling OnAvailablePointsChanged listener for stat (%s):\n%s", stat.ID, err)
			end
		end
		Ext.PostMessageToServer("LeaderLib_CustomStatSystem_AvailablePointsChanged", Ext.JsonStringify({
			NetID = character.NetID,
			Stat = stat.ID,
			Mod = stat.Mod,
			Last = lastPoints,
			Current = points
		}))
		self:SyncAvailablePoints()
	end
end

function CustomStatSystem:UpdateAvailablePoints(ui)
	if ui == nil then
		ui = Ext.GetUIByType(Data.UIType.characterSheet)
	end
	if ui then
		local this = ui:GetRoot()
		this.setAvailableCustomStatPoints(self:GetTotalAvailablePoints())
		local stats = this.stats_mc.customStats_mc.stats_array
		for i=0,#stats-1 do
			local stats_mc = stats[i]
			if stats_mc then
				stats_mc.plus_mc.visible = self:GetCanAddPoints(ui, stats_mc.statId)
				stats_mc.minus_mc.visible = self:GetCanRemovePoints(ui, stats_mc.statId)
			end
		end
	end
end

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

if Vars.DebugMode then
	local specialStats = {
		"Lucky",
		"Fear",
		"Pure",
		"RNGesus"
	}
	CustomStatSystem:RegisterAvailablePointsChangedListener("All", function(id, stat, character, previousPoints, currentPoints)
		fprint(LOGLEVEL.DEFAULT, "[OnAvailablePointsChanged:%s] Stat(%s) Character(%s) %s => %s [%s]", id, stat.UUID, character.DisplayName, previousPoints, currentPoints, isClient and "CLIENT" or "SERVER")
	end)
	CustomStatSystem:RegisterStatValueChangedListener("All", function(id, stat, character, previousPoints, currentPoints)
		fprint(LOGLEVEL.DEFAULT, "[OnStatValueChanged:%s] Stat(%s) Character(%s) %s => %s [%s]", id, stat.UUID, character.DisplayName, previousPoints, currentPoints, isClient and "CLIENT" or "SERVER")
	end)
	if isClient then
		CustomStatSystem:RegisterCanAddPointsHandler(specialStats, function(id, stat, character, current, availablePoints, canAdd)
			return availablePoints > 0 and current < 5
		end)
		CustomStatSystem:RegisterCanRemovePointsHandler("Lucky", function(id, stat, character, current, canRemove)
			return current > 0
		end)
	end
end