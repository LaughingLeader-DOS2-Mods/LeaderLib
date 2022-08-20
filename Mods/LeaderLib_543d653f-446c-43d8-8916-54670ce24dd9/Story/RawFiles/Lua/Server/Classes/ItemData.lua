---A wrapper around common item queries with additional item-related helpers.
---@class ItemData
---@field NetID integer
---@field Region string
local ItemData = {
	Type = "ItemData",
	UUID = ""
}

local customAccessors = {
	NetID = function(tbl) local item = GameHelpers.GetItem(tbl.UUID); return item and item.NetID or nil end,
	Region = function(tbl) return GetRegion(tbl.UUID) end
}

ItemData.__index = function(tbl, k)
	if customAccessors[k] then
		return customAccessors[k](tbl)
	end
	return ItemData[k]
end

---@param uuid string
---@param params table<string,any>|nil
ItemData.__call = function(_, uuid, params)
	return ItemData:Create(uuid, params)
end

---@param self ItemData
ItemData.__tostring = function(self)
	local item = self:GetItem()
	if item then
		return string.format("[ItemData] DisplayName(%s) UUID(%s) NetID(%s) StatsId(%s)", item.DisplayName, self.UUID, item.NetID, item.Stats.Name)
	else
		return string.format("[ItemData] UUID(%s)", self.UUID)
	end
end

---@param uuid string
---@param params table<string,any>|nil
---@return ItemData
function ItemData:Create(uuid, params)
    local this =
    {
		UUID = uuid or ""
	}
	if params ~= nil then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
	setmetatable(this, self)
    return this
end

---@return boolean
function ItemData:Exists()
	return not StringHelpers.IsNullOrEmpty(self.UUID) and ObjectExists(self.UUID) == 1
end

---Fetches the EsvItem associated with this item's UUID.
---@return EsvItem|nil
function ItemData:GetItem()
	if self:Exists() then
		return GameHelpers.GetItem(self.UUID)
	end
	return nil
end

---@return boolean
function ItemData:IsDestroyed()
	return ItemIsDestroyed(self.UUID) == 1
end

---@param asVector3 boolean|nil
---@return number,number,number|Vector3
function ItemData:GetPosition(asVector3)
	local x,y,z = GetPosition(self.UUID)
	if asVector3 == true then
		return Classes.Vector3(x,y,z)
	else
		return x,y,z
	end
end

---@param status string|string[]
---@return boolean
function ItemData:HasActiveStatus(status)
	if type(status) == "table" then
		for i,v in pairs(status) do
			if self:IsStatusActive(v) then
				return true
			end
		end
	else
		return HasActiveStatus(self.UUID, status) == 1
	end
	return false
end

---@param force boolean|nil Forces the stage change, otherwise it's skipped if they're already on stage.
function ItemData:SetOffStage(force)
	if self:Exists() then
		if force == true or ObjectIsOnStage(self.UUID) == 1 then
			SetOnStage(self.UUID, 0)
			return true
		end
	end
	return false
end

---@param force boolean|nil Forces the stage change, otherwise it's skipped if they're already on stage.
function ItemData:SetOnStage(force)
	if self:Exists() then
		if force == true or ObjectIsOnStage(self.UUID) == 0 then
			SetOnStage(self.UUID, 1)
			return true
		end
	end
	return false
end

--- Applies a status or sets its duration if it's still active, for all instances of the status.
---@param status string|string[]
---@param duration number
---@param force boolean
---@param source string
function ItemData:ApplyOrSetStatus(status, duration, force, source)
	if type(status) == "table" then
		for i,v in pairs(status) do
			self:ApplyOrSetStatus(v, duration, force, source)
		end
	else
		if HasActiveStatus(self.UUID, status) == 0 then
			ApplyStatus(self.UUID, status, duration or 6.0, force and 1 or 0, source or self.UUID)
		else
			local item = self:GetItem()
			if item then
				duration = duration or 6.0
				for i,v in pairs(item:GetStatusObjects()) do
					if v.StatusId == status then
						if v.CurrentLifeTime ~= duration and (v.CurrentLifeTime >= 0 or force == true) then
							v.CurrentLifeTime = duration
							v.RequestClientSync = true
						end
					end
				end
			end
		end
	end
end

--- Removes a status or array of statuses, or 'all'.
---@param status string|string[]
---@param ignorePermanent boolean|nil Ignore permanent statuses when removing 'all'.
function ItemData:RemoveStatus(status, ignorePermanent)
	if type(status) == "table" then
		for i,v in pairs(status) do
			self:RemoveStatus(v)
		end
	else
		if StringHelpers.Equals(status, "all", true) then
			local item = self:GetItem()
			if item then
				if ignorePermanent == true then
					for i,v in pairs(item:GetStatusObjects()) do
						if v.CurrentLifeTime ~= -1 then
							RemoveStatus(self.UUID, v.StatusId)
						end
					end
				else
					for i,v in pairs(item:GetStatuses()) do
						RemoveStatus(self.UUID, v)
					end
				end
			end
		else
			if ignorePermanent == true then
				local item = self:GetItem()
				if item then
					for i,v in pairs(item:GetStatusObjects()) do
						if v.StatusId == status and v.CurrentLifeTime ~= -1 then
							RemoveStatus(self.UUID, v.StatusId)
						end
					end
				end
			else
				RemoveStatus(self.UUID, status)
			end
		end
	end
end

---Shortcut for calling RemoveStatus with 'all'.
---@param ignorePermanent boolean|nil Ignore permanent statuses when removing 'all'.
function ItemData:RemoveAllStatuses(ignorePermanent)
	self:RemoveStatus("all", ignorePermanent)
end

---A better alternative to RemoveHarmfulStatuses since it actually checks for debuffs.
---@param ignorePermanent boolean|nil Ignore permanent statuses.
function ItemData:RemoveHarmfulStatuses(ignorePermanent)
	local item = self:GetItem()
	if item then
		GameHelpers.Status.RemoveHarmful(item, ignorePermanent)
	end
end

---@param level integer
function ItemData:SetLevel(level)
	if self:Exists() then
		local item = self:GetItem()
		if item then
			return GameHelpers.SetExperienceLevel(item, level)
		end
	end
	return false
end

---Sets a item's scale and syncs it to clients.
---@param scale number
---@param persist boolean|nil Whether to persist the scale change through saves.
function ItemData:SetScale(scale, persist)
	if self:Exists() then
		GameHelpers.SetScale(self:GetItem(), scale, persist)
		return true
	end
	return false
end

---Teleports to a position or object.
---This uses the behavior scripting teleport function so it doesn't force-teleport connected summons like Osiris' TeleportToPosition does.
---Supports a string/EsvGameObject/number array as the target, or separate x,y,z values.
---@param targetOrX number|number[]|string|EsvGameObject
---@param y number|nil
---@param z number|nil
function ItemData:TeleportTo(targetOrX,y,z)
	if self:Exists() then
		local t = type(targetOrX)
		if t == "number" and y and z then
			Osi.LeaderLib_Behavior_TeleportTo(self.UUID, targetOrX, y, z)
			return true
		elseif t == "table" then
			targetOrX,y,z = table.unpack(targetOrX)
			if targetOrX and y and z  then
				Osi.LeaderLib_Behavior_TeleportTo(self.UUID, targetOrX, y, z)
				return true
			end
		elseif (t == "userdata" and targetOrX.MyGuid) or t == "string" then
			Osi.LeaderLib_Behavior_TeleportTo(self.UUID, targetOrX.MyGuid)
			return true
		end
	end
	return false
end

local function EventIsForItem(uuid, args)
	for i=1,#args do
		if type(args[i]) == "string" and StringHelpers.GetUUID(args[i]) == uuid then
			return true
		end
	end
	return false
end

---@param callback fun(self:ItemData, character:EsvCharacter, item:EsvItem):boolean A callback that returns false if it wants to block the item usage, true if it doesn't, or nothing to not do anything.
function ItemData:RegisterProcBlockUseOfItemListener(callback)
	RegisterProtectedOsirisListener("ProcBlockUseOfItem", 2, "after", function(character, item)
		character = StringHelpers.GetUUID(character)
		item = StringHelpers.GetUUID(item)
		if item == self.UUID then
			local b,result = xpcall(callback, self, GameHelpers.GetCharacter(character), GameHelpers.GetItem(item))
			if not b then
				fprint(LOGLEVEL.ERROR, "[ItemData:ProcBlockUseOfItem] Error invoking callback:\n%s", result)
			elseif result ~= nil then
				if result then
					Osi.DB_CustomUseItemResponse(character, item, 1)
				else
					Osi.DB_CustomUseItemResponse(character, item, 0)
				end
			end
		end
	end)
end

Classes.ItemData = ItemData