local self = CustomStatSystem

---@alias CustomStatGetAvailablePointsCallback fun(id:string, stat:CustomStatData, character:EclCharacter, currentValue:integer):integer
---@alias CustomStatPointsAssignedCallback fun(id:string, currentValue:integer, character:EsvCharacter, stat:CustomStatData):void


self.Listeners = {
	---@type table<string, CustomStatGetAvailablePointsCallback[]>
	GetAvailablePoints = {All = {}},
	OnPointAdded = {},
	OnPointRemoved = {},
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
				fprint(LOGLEVEL.DEFAULT, "Set points for custom stat (%s) to (%s) for character(%s). Total(%s)", statId, amount, uuid, PersistentVars.CustomStatAvailablePoints[uuid][statId])
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
				fprint(LOGLEVEL.DEFAULT, "Added (%s) points for custom stat (%s) to character(%s). Total(%s)", amount, statId, uuid, PersistentVars.CustomStatAvailablePoints[uuid][statId])
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
---@param callback CustomStatGetAvailablePointsCallback
function CustomStatSystem:RegisterGetAvailablePointsHandler(id, callback)
	if not self.Listeners.GetAvailablePoints[id] then
		self.Listeners.GetAvailablePoints[id] = {}
	end
	table.insert(self.Listeners.GetAvailablePoints[id], callback)
end

if Vars.DebugMode then
	self:RegisterGetAvailablePointsHandler("Lucky", function(id, stat, character, current)
		return stat.AvailablePoints[character.MyGuid] or 0
	end)
end

---@return integer
function CustomStatSystem:GetTotalAvailablePoints(character)
	character = character or Client:GetCharacter()
	local points = 0
	print("Iter?")
	for stat in self:GetAllStats() do
		points = points + self:GetAvailablePointsForStat(stat, character)
		print(stat, stat.ID, points)
	end
	return points
end

---@param stat CustomStatData
---@return integer
function CustomStatSystem:GetAvailablePointsForStat(stat, character)
	character = character or Client:GetCharacter()
	local points = 0
	if stat then
		local listeners = self.Listeners.GetAvailablePoints[stat.ID]
		if listeners then
			for i=1,#listeners do
				local b,amount = xpcall(listeners[i], debug.traceback, stat.ID, stat, character, points)
				if b and type(amount) == "number" then
					points = points + amount
				else
					fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:GetAvailablePoints] Error calling listener for stat (%s):\n%s", stat.ID, amount)
				end
			end
		end
		local listeners = self.Listeners.GetAvailablePoints.All
		if listeners then
			for i=1,#listeners do
				local b,amount = xpcall(listeners[i], debug.traceback, stat.ID, stat, character, points)
				if b and type(amount) == "number" then
					points = points + amount
				else
					fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:GetAvailablePoints] Error calling listener for stat (%s):\n%s", stat.ID, amount)
				end
			end
		end
	end
	return points
end

function CustomStatSystem:GetCanAddPoints(ui, call, doubleHandle)
	local stat = self:GetStatByDouble(doubleHandle)
	if stat then
		return self:GetAvailablePointsForStat(stat) > 0
	end
	return false
end

function CustomStatSystem:GetCanRemovePoints(ui, call, doubleHandle)
	if Vars.DebugMode then
		local stat = self:GetStatByDouble(doubleHandle)
		if stat then
			local value = self:GetStatValueForCharacter(nil, stat.ID, stat.Mod)
			return value and value > 0
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
		if points > 0 then
			points = points - 1
			stat.AvailablePoints[character.MyGuid] = points
		end
		if points == 0 then
			stat_mc.plus_mc.visible = false
		end
	end
end

function CustomStatSystem:OnStatPointRemoved(ui, call, doubleHandle)
	local stat = self:GetStatByDouble(doubleHandle)
	local stat_mc = self:GetStatMovieClipByDouble(ui, doubleHandle)

	local character = Client:GetCharacter()
	local points = stat.AvailablePoints[character.MyGuid]
	if points then
		stat.AvailablePoints[character.MyGuid] = stat.AvailablePoints[character.MyGuid] + 1
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
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "plusCustomStat", function(...) CustomStatSystem:OnStatPointAdded(...) end, "Before")
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "minusCustomStat", function(...) CustomStatSystem:OnStatPointRemoved(...) end, "Before")
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