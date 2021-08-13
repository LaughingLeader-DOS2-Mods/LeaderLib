local self = CustomStatSystem

---@alias CustomStatCanAddPointsCallback fun(id:string, stat:SheetCustomStatData, character:EclCharacter, currentValue:integer, availablePoints:integer, canAdd:boolean):boolean
---@alias CustomStatCanRemovePointsCallback fun(id:string, stat:SheetCustomStatData, character:EclCharacter, currentValue:integer, canRemove:boolean):boolean
---@alias OnAvailablePointsChangedCallback fun(id:string, stat:SheetCustomStatData, character:EsvCharacter, previousPoints:integer, currentPoints:integer, isClientSide:boolean):void
---@alias OnCustomStatValueChangedCallback fun(id:string, stat:SheetCustomStatData, character:EsvCharacter, previousPoints:integer, currentPoints:integer, isClientSide:boolean):void

local isClient = Ext.IsClient()

if isClient then
	---@type table<string, CustomStatCanAddPointsCallback[]>
	CustomStatSystem.Listeners.CanAddPoints = {All = {}}
	---@type table<string, CustomStatCanRemovePointsCallback[]>
	CustomStatSystem.Listeners.CanRemovePoints = {All = {}}
end

---@private
function CustomStatSystem:CanAddListenerCallback(tbl, id, callback)
	if tbl[id] == nil then
		tbl[id] = {}
		return true
	elseif not Common.TableHasValue(tbl, callback) then
		return true
	end
	return false
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
	elseif self:CanAddListenerCallback(self.Listeners.CanAddPoints, id, callback) then
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
	elseif self:CanAddListenerCallback(self.Listeners.CanRemovePoints, id, callback) then
		table.insert(self.Listeners.CanRemovePoints[id], callback)
	end
end

---@param id string|string[]
---@param callback OnAvailablePointsChangedCallback
function CustomStatSystem:RegisterAvailablePointsChangedListener(id, callback)
	if type(id) == "table" then
		for i=1,#id do
			self:RegisterAvailablePointsChangedListener(id[i], callback)
		end
	elseif self:CanAddListenerCallback(self.Listeners.OnAvailablePointsChanged, id, callback) then
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
	elseif self:CanAddListenerCallback(self.Listeners.OnStatValueChanged, id, callback) then
		table.insert(self.Listeners.OnStatValueChanged[id], callback)
	end
end

---@protected
function CustomStatSystem:InvokeStatValueChangedListeners(stat, character, last, current)
	for listener in self:GetListenerIterator(self.Listeners.OnStatValueChanged[stat.ID], self.Listeners.OnStatValueChanged.All) do
		local b,err = xpcall(listener, debug.traceback, stat.ID, stat, character, last, current, isClient)
		if not b then
			fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:OnStatPointAdded] Error calling OnStatValueChanged listener for stat (%s):\n%s", stat.ID, err)
		end
	end
end

local function CharacterIdIsValid(id)
	if not isClient then
		return not StringHelpers.IsNullOrEmpty(id)
	else
		return type(id) == "number"
	end
end

---@param character EsvCharacter|UUID|NETID
---@param statId string A stat id or stat PoolID.
---@param amount integer
---@param skipSync boolean Skips syncing if true.
function CustomStatSystem:SetAvailablePoints(character, statId, amount, skipSync)
	local characterId = GameHelpers.GetCharacterID(character)
	if CharacterIdIsValid(characterId) and type(amount) == "number" then
		if self.PointsPool then
			if not self.PointsPool[characterId] then
				self.PointsPool[characterId] = {}
			end
			local stat = self:GetStatByID(statId)
			if stat and stat.PointID then
				statId = stat.PointID
			end
			self.PointsPool[characterId][statId] = amount
			if Vars.DebugMode and amount ~= self.PointsPool[characterId][statId] then
				fprint(LOGLEVEL.DEFAULT, "Set available points for custom stat or pool (%s) to (%s) for character(%s). Total(%s)", statId, amount, characterId, self.PointsPool[characterId][statId])
			end
			if not skipSync and not isClient then
				-- If a save is loaded or the game is stopped, it'll get synced in the next SharedData cycle anyway
				Timer.StartOneshot("Timers_LeaderLib_SyncCustomStatData", 10, function()
					self:SyncData()
				end)
			end
		end
	else
		error(string.format("Invalid parameters. character(%s) statId(%s) amount(%s)", tostring(character), tostring(statId), tostring(amount)), 1)
	end
end

---@param character EsvCharacter|UUID|EclCharacter|NETID
---@param stat SheetCustomStatData
---@param amount integer The amount to modify the stat by.
function CustomStatSystem:ModifyStat(character, stat, amount)
	return self:SetStat(character, stat, self:GetStatValueForCharacter(character, stat) + amount)
end

---@param character EsvCharacter|UUID|EclCharacter|NETID
---@param stat SheetCustomStatData
---@param value integer The value to set the stat to.
function CustomStatSystem:SetStat(character, stat, value, ...)
	if type(stat) == "string" then
		local mod = table.unpack({...}) or ""
		stat = self:GetStatByID(stat, mod)
	end
	if not isClient then
		if type(character) ~= "userdata" then
			character = GameHelpers.GetCharacter(character)
		end
		
		assert(character ~= nil, string.format("Character is nil!"))
		assert(stat ~= nil, string.format("stat is nil!"))

		if self:GMStatsEnabled() then
			if StringHelpers.IsNullOrWhitespace(stat.UUID) then
				stat.UUID = Ext.CreateCustomStat(stat.DisplayName, stat.Description)
			end
			character:SetCustomStat(stat.UUID, value)
		else
			CustomStatSystem:SetStatValueOnCharacter(character, stat, value)
		end
		return true
	else
		self:RequestValueChange(character, stat.ID, value, stat.Mod)
	end
end

---@param character EsvCharacter|UUID|NETID
---@param statId string A stat id.
---@param value integer The value to set the stat to.
---@param mod string|nil A mod UUID to use when fetching the stat by ID.
function CustomStatSystem:SetStatByID(character, statId, value, mod)
	local stat = self:GetStatByID(statId, mod)
	if stat then
		self:SetStat(character, stat, value)
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
					local b,err = xpcall(listener, debug.traceback, stat.ID, stat, character, data.Last, data.Current, isClient)
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
					local val = stat:GetValue(character)
					local last = stat:GetLastValue(character)
					if not last or last ~= val then
						CustomStatSystem:InvokeStatValueChangedListeners(stat, character, v.Last, val)
						stat:UpdateLastValue(character)
					end
				end
			end
		end
	end)

	---@param character EsvCharacter|UUID|NETID
	---@param statId string A stat ID or stat PointID.
	---@param amount integer
	---@param modId string|nil
	function CustomStatSystem:AddAvailablePoints(character, statId, amount, modId)
		local characterId = GameHelpers.GetUUID(character)
		if type(characterId) == "string" and type(amount) == "number" then
			--Use the PointID for actual storage key.
			local pointId = statId
			---@type SheetCustomStatData
			local stat = nil

			local t = type(statId)
			if t == "string" then
				stat = self:GetStatByID(statId, modId)
			elseif t == "table" and statId.Type == "SheetCustomStatData" then
				stat = statId
			elseif t == "number" then
				stat = self:GetStatByDouble(statId, modId)
			end
			if stat and stat.PointID then
				pointId = stat.PointID
			end

			if type(pointId) ~= "string" then
				error("PointID or statId %s is not a correct type. Stat: %s", pointId, statId, 2)
			end

			if not self.PointsPool[characterId] then
				self.PointsPool[characterId] = {}
			end
			local current = self.PointsPool[characterId][pointId] or 0
			self.PointsPool[characterId][pointId] = current + amount

			if Vars.DebugMode then
				fprint(LOGLEVEL.DEFAULT, "Added (%s) available points for custom stat (%s)[%s] to character(%s). Total(%s)", amount, statId, pointId, characterId, self.PointsPool[characterId][pointId])
			end

			-- If a save is loaded or the game is stopped, it'll get synced in the next SharedData cycle anyway
			Timer.StartOneshot("Timers_LeaderLib_SyncCustomStatData", 10, function()
				self:SyncData()
			end)
		else
			error(string.format("Invalid parameters character(%s) characterId(%s) statId(%s) amount(%s)", tostring(character), tostring(characterId), tostring(statId), tostring(amount)), 1)
		end
	end
end

---@param stat SheetCustomStatData
---@param character EclCharacter|EsvCharacter|UUID|NETID|nil
---@return integer
function CustomStatSystem:GetAvailablePointsForStat(stat, character)
	if isClient then
		character = character or self:GetCharacter()
		local points = 0
		if stat and character and stat.AvailablePoints then
			return stat.AvailablePoints[GameHelpers.GetNetID(character)] or 0
		end
	else
		return stat.AvailablePoints[GameHelpers.GetUUID(character)] or 0
	end
	return 0
end

if isClient then

---@private
---@return integer
function CustomStatSystem:GetTotalAvailablePoints(character)
	character = character or self:GetCharacter()
	local characterId = GameHelpers.GetNetID(character)
	if characterId then
		local points = 0
		local pointsTable = nil
		if self.PointsPool[characterId] then
			for id,amount in pairs(self.PointsPool[characterId]) do
				points = points + amount
			end
		end
		return points
	end
	return 0
end

---@private
function CustomStatSystem:GetCanAddPoints(ui, doubleHandle, character, stat)
	if GameHelpers.Client.IsGameMaster(ui) == true then
		return true
	end
	character = character or self:GetCharacter()
	stat = stat or self:GetStatByDouble(doubleHandle)
	if stat then
		local value = self:GetStatValueForCharacter(character, stat)
		local availablePoints = self:GetAvailablePointsForStat(stat)
		local canAdd = availablePoints > 0
		if canAdd and stat.MaxAmount then
			canAdd = value < stat.MaxAmount
		end
		for listener in self:GetListenerIterator(self.Listeners.CanAddPoints[stat.ID], self.Listeners.CanAddPoints.All) do
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

---@private
function CustomStatSystem:GetCanRemovePoints(ui, doubleHandle, character)
	if GameHelpers.Client.IsGameMaster(ui) == true then
		return true
	end
	character = character or self:GetCharacter()
	local stat = self:GetStatByDouble(doubleHandle)
	if stat then
		local value = self:GetStatValueForCharacter(character, stat)
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

---@private
function CustomStatSystem:OnStatPointAdded(ui, call, doubleHandle)
	if GameHelpers.Client.IsGameMaster(ui) == true then
		return
	end
	local stat = self:GetStatByDouble(doubleHandle)
	local stat_mc = self:GetStatMovieClipByDouble(ui, doubleHandle)

	local character = self:GetCharacter()
	local characterId = GameHelpers.GetNetID(character)
	if characterId then
		local points = stat.AvailablePoints and stat.AvailablePoints[characterId] or nil
		if points then
			local lastPoints = points
			if points > 0 then
				points = points - 1
				stat.AvailablePoints[characterId] = points
			end
			if points == 0 then
				stat_mc.plus_mc.visible = false
				stat_mc.minus_mc.visible = self:GetCanRemovePoints(ui, doubleHandle)
			end
			if lastPoints ~= points then
				for listener in self:GetListenerIterator(self.Listeners.OnAvailablePointsChanged[stat.ID], self.Listeners.OnAvailablePointsChanged.All) do
					local b,err = xpcall(listener, debug.traceback, stat.ID, stat, character, lastPoints, points)
					if not b then
						fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem] Error calling OnAvailablePointsChanged listener for stat (%s):\n%s", stat.ID, err)
					end
				end
				Ext.PostMessageToServer("LeaderLib_CustomStatSystem_AvailablePointsChanged", Ext.JsonStringify({
					NetID = characterId,
					Stat = stat.ID,
					Mod = stat.Mod,
					Last = lastPoints,
					Current = points
				}))
				self:SyncAvailablePoints(character)
			end
		end
	end
end

---@private
function CustomStatSystem:OnStatPointRemoved(ui, call, doubleHandle)
	if GameHelpers.Client.IsGameMaster(ui) == true then
		return
	end
	local stat = self:GetStatByDouble(doubleHandle)
	local stat_mc = self:GetStatMovieClipByDouble(ui, doubleHandle)
	local character = self:GetCharacter()
	local points = stat.AvailablePoints and stat.AvailablePoints[character.NetID] or nil
	if points then
		if stat.AutoAddAvailablePointsOnRemove ~= false then
			local lastPoints = points
			stat.AvailablePoints[character.NetID] = stat.AvailablePoints[character.NetID] + 1
			for listener in self:GetListenerIterator(self.Listeners.OnAvailablePointsChanged[stat.ID], self.Listeners.OnAvailablePointsChanged.All) do
				local b,err = xpcall(listener, debug.traceback, stat.ID, stat, character, lastPoints, stat.AvailablePoints[character.NetID])
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
			self:SyncAvailablePoints(character)
		end
	end
end

---@private
function CustomStatSystem:UpdateAvailablePoints(ui)
	if ui == nil then
		ui = Ext.GetUIByType(Data.UIType.characterSheet)
	end
	if ui then
		local this = ui:GetRoot()
		if not this or this.isExtended ~= true then
			return
		end
		local totalPoints = self:GetTotalAvailablePoints()
		this.setAvailableCustomStatPoints(totalPoints)
		local stats = this.stats_mc.customStats_mc.stats_array
		if stats then
			for i=0,#stats-1 do
				local stats_mc = stats[i]
				if stats_mc then
					stats_mc.plus_mc.visible = self:GetCanAddPoints(ui, stats_mc.statID)
					stats_mc.minus_mc.visible = self:GetCanRemovePoints(ui, stats_mc.statID)
				end
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