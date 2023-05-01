---@diagnostic disable undefined-field

if StatusHider == nil then
	StatusHider = {}
end

local _DoubleToHandle = Ext.UI.DoubleToHandle
local _GetStatus = Ext.Entity.GetStatus

local function GetStatusVisibility(statusId, whitelist,blacklist,allVisible)
	local blacklisted = blacklist[statusId] == true
	local whitelisted = whitelist[statusId] == true
	if allVisible then
		if blacklisted then
			return false
		end
		return true
	elseif not allVisible then
		if whitelisted then
			return true
		end
		return false
	end
end

local function GetStatusVisibilityLists()
	local allVisible = not GameSettings.Settings.Client.StatusOptions.HideAll
	local whitelist = {}
	local blacklist = {}

	if allVisible then
		for i,v in pairs(GameSettings.Settings.Client.StatusOptions.Blacklist) do
			if type(i) == "string" then
				blacklist[i] = v
			elseif type(v) == "string" then
				blacklist[v] = true
			end
		end
	else
		for i,v in pairs(GameSettings.Settings.Client.StatusOptions.Whitelist) do
			if type(i) == "string" then
				whitelist[i] = v
			elseif type(v) == "string" then
				whitelist[v] = true
			end
		end
	end
	return whitelist,blacklist,allVisible
end

local function UpdateStatusVisibility(array, whitelist, blacklist, allVisible)
	if not array then
		return false
	end
	local needsUpdate = false
	for i=0,#array do
		local statusEntry = array[i]
		if statusEntry then
			local statusHandle = _DoubleToHandle(statusEntry.id)
			local ownerHandle = _DoubleToHandle(statusEntry.owner)
			local status = _GetStatus(ownerHandle, statusHandle)
			if status then
				local visible = GetStatusVisibility(status.StatusId, whitelist,blacklist,allVisible)
				if statusEntry.visible ~= visible then
					needsUpdate = true
				end
				statusEntry.alive = visible
				statusEntry.visible = visible
			end
		end
	end
	return needsUpdate
end

local PlayerInfo = {}
StatusHider.PlayerInfo = PlayerInfo

function PlayerInfo:Get()
	local ui = not Vars.ControllerEnabled and Ext.UI.GetByType(Data.UIType.playerInfo) or Ext.UI.GetByType(Data.UIType.playerInfo_c)
	if ui then
		return ui:GetRoot()
	end
	return nil
end

function PlayerInfo:AddStatus(directly, characterDouble, statusDouble, displayName, turns, cooldown, iconId)
	local this = self:Get()
	if directly then
		this.setStatus(true, characterDouble, statusDouble, iconId or -1, turns, cooldown or 0, displayName)
	else
		local index = #this.status_array
		this.status_array[index] = characterDouble
		this.status_array[index+1] = statusDouble
		this.status_array[index+2] = iconId
		this.status_array[index+3] = turns
		this.status_array[index+4] = cooldown
		this.status_array[index+5] = displayName
	end
end

local function NoResult()

end

---@param ignoreSummons boolean|nil
---@return FlashObject
function PlayerInfo:GetCharacterMovieClips(ignoreSummons)
	local this = self:Get()
	if not this then
		return NoResult
	end
	local characters = {}
	for i=0,#this.player_array-1 do
		local player_mc = this.player_array[i]
		if player_mc then
			characters[#characters+1] = player_mc
			if ignoreSummons ~= true and player_mc.summonList then
				for j=0,#player_mc.summonList.content_array do
					local summon_mc = player_mc.summonList.content_array[j]
					if summon_mc then
						characters[#characters+1] = summon_mc
					end
				end
			end
		end
	end

	local i = 0
	local count = #characters
	return function ()
		i = i + 1
		if i <= count then
			return characters[i]
		end
	end
end

---@param ownerHandleMatch number|nil
---@return FlashObject
function PlayerInfo:GetSummonMovieClips(ownerHandleMatch)
	local this = self:Get()
	if not this then
		return NoResult
	end
	local characters = {}
	for i=0,#this.player_array do
		local player_mc = this.player_array[i]
		if player_mc then
			if not ownerHandleMatch or ownerHandleMatch == player_mc.characterHandle then
				if player_mc.summonList then
					for j=0,#player_mc.summonList.content_array do
						local summon_mc = player_mc.summonList.content_array[j]
						if summon_mc then
							characters[#characters+1] = summon_mc
						end
					end
				end
			end
		end
	end

	local i = 0
	local count = #characters
	return function ()
		i = i + 1
		if i <= count then
			return characters[i]
		end
	end
end

function PlayerInfo:GetPlayerOrSummonByHandle(doubleHandle, this)
	this = this or self:Get()
	for i=0,#this.player_array-1 do
		local entry = this.player_array[i]
		if entry then
			if entry.characterHandle == doubleHandle then
				return entry
			end
			if entry.summonList then
				for j=0,#entry.summonList.content_array-1 do
					local summon_mc = entry.summonList.content_array[j]
					if summon_mc and summon_mc.characterHandle == doubleHandle then
						return summon_mc
					end
				end
			end
		end
	end
	return nil
end

function PlayerInfo:UpdateStatusVisibility()
	local this = self:Get()
	local whitelist,blacklist,allVisible = GetStatusVisibilityLists()
	local updated = false
	for mc in self:GetCharacterMovieClips() do
		if UpdateStatusVisibility(mc.status_array, whitelist, blacklist, allVisible) then
			this.cleanupStatuses(mc.characterHandle)
			updated = true
		end
	end
	return updated
end

function PlayerInfo:CleanupStatuses()
	local this = self:Get()
	for mc in self:GetCharacterMovieClips() do
		this.cleanupStatuses(mc.characterHandle)
	end
end

local function RequestPlayerInfoRefresh()
	local character = Client and Client:GetCharacter() or GameHelpers.Client.GetCharacter()
	if character then
		Ext.Net.PostMessageToServer("LeaderLib_UI_Server_RefreshPlayerInfo", tostring(character.NetID))
	end
end

local function NothingIsIgnored()
	if not GameSettings.Settings.Client.StatusOptions.HideAll then
		return #GameSettings.Settings.Client.StatusOptions.Blacklist == 0
	else
		return #GameSettings.Settings.Client.StatusOptions.Whitelist == 0
	end
end

---@param ui UIObject
local function OnUpdateStatuses(ui, method, addIfNotExists, cleanupAll)
	if NothingIsIgnored() then
		return
	end
	local this = ui:GetRoot()
	local status_array = this.status_array
	local length = #status_array
	if length > 0 then
		local whitelist,blacklist,allVisible = GetStatusVisibilityLists()
		for i=0,length-1,6 do
			local ownerDouble = status_array[i]
			if ownerDouble then
				local ownerHandle = _DoubleToHandle(ownerDouble)
				if ownerHandle then
					local statusDouble = status_array[i+1]
					local statusHandle = _DoubleToHandle(statusDouble)
					local status = _GetStatus(ownerHandle, statusHandle)
					if status then
						local visible = GetStatusVisibility(status.StatusId, whitelist,blacklist,allVisible)
						local owner_mc = PlayerInfo:GetPlayerOrSummonByHandle(ownerDouble, this)
						if owner_mc then
							for k=0,#owner_mc.status_array-1 do
								local status_mc = owner_mc.status_array[k]
								if status_mc and status_mc.id == statusDouble then
									status_mc.visible = visible
									status_mc.alive = visible
									if not visible then
										status_mc.fadingOut = true
										this.fadeOutStatusComplete(status_mc.id,status_mc.owner)
									end
									break
								end
							end
						end
						if not visible then
							status_array[i] = ""
							status_array[i+1] = ""
						end
					end
				end
			end
		end
	end
end

Ext.RegisterUITypeInvokeListener(Data.UIType.playerInfo, "updateStatuses", OnUpdateStatuses)
Ext.RegisterUITypeInvokeListener(Data.UIType.playerInfo_c, "updateStatuses", OnUpdateStatuses)

local lastHealthbarOwnerDouble = nil

local function RequestHealthbarRefresh()
	if not lastHealthbarOwnerDouble or not GameSettings.Settings.Client.StatusOptions.AffectHealthbar then
		return
	end
	local ui = Ext.UI.GetByType(Data.UIType.enemyHealthBar)
	if ui then
		local character = GameHelpers.GetCharacter(_DoubleToHandle(lastHealthbarOwnerDouble))
		if character then
			Ext.Net.PostMessageToServer("LeaderLib_UI_Server_RefreshPlayerInfo", tostring(character.NetID))
		end
	end
end

local function TryGetStatus(characterHandle, statusHandle)
	local b,result = xpcall(_GetStatus, debug.traceback, characterHandle, statusHandle)
	if b then
		return result
	end
	return nil
end

local healthBarStatusToOwner = {}

---@param ui UIObject|nil
---@param this FlashMainTimeline|nil
---@param whitelist table|nil
---@param blacklist table|nil
---@param allVisible boolean|nil
local function UpdateHealthbarStatusVisibility(ui, this, whitelist,blacklist,allVisible)
	if not lastHealthbarOwnerDouble then
		return
	end
	ui = ui or Ext.UI.GetByType(Data.UIType.enemyHealthBar)
	if ui then
		this = this or ui:GetRoot()
		if this then
			local characterHandle = lastHealthbarOwnerDouble and _DoubleToHandle(lastHealthbarOwnerDouble) or nil
			if not characterHandle then
				return
			end

			if not whitelist then
				whitelist,blacklist,allVisible = GetStatusVisibilityLists()
			end

			local cleanup = false
			for i=0,this.statusList.length do
				local status_mc = this.statusList.content_array[i]
				if status_mc then
					local statusHandle = _DoubleToHandle(status_mc.id)
					local status = _GetStatus(characterHandle, statusHandle)
					if status then
						local visible = GetStatusVisibility(status.StatusId, whitelist,blacklist,allVisible)
						if status_mc.visible ~= visible then
							cleanup = true
						end
						status_mc.alive = visible
						status_mc.visible = visible
					end
				end
			end
	
			if cleanup then
				this.cleanupStatuses()
			end

			this.statusList.visible = true
			return cleanup
		end
	end
	return false
end

local function OnUpdateStatuses_Healthbar_Delay()
	UpdateHealthbarStatusVisibility()
end

---@param ui UIObject
local function OnUpdateStatuses_Healthbar(ui, method, addIfNotExists)
	if not GameSettings.Settings.Client.StatusOptions.AffectHealthbar or NothingIsIgnored() then
		return
	end
	local this = ui:GetRoot()

	local whitelist,blacklist,allVisible = GetStatusVisibilityLists()

	local nextOwner = this.status_array[0]

	if addIfNotExists and lastHealthbarOwnerDouble == nextOwner then
		UpdateHealthbarStatusVisibility(ui, this, whitelist,blacklist,allVisible)
	end

	lastHealthbarOwnerDouble = nextOwner
	
	local needsUpdate = false
	local status_array = this.status_array
	for i=0,#status_array,6 do
		local ownerDouble = status_array[i]
		if ownerDouble then
			local ownerHandle = _DoubleToHandle(ownerDouble)
			if ownerHandle then
				local id = status_array[i+1]
				local statusHandle = _DoubleToHandle(id)
				local status = _GetStatus(ownerHandle, statusHandle)
				if status then
					if not GetStatusVisibility(status.StatusId, whitelist,blacklist,allVisible) then
						needsUpdate = true
					end
				end
			end
		end
	end

	if needsUpdate then
		this.statusList.visible = false
		Timer.StartOneshot("OnUpdateStatuses_Healthbar_Delay", 1, OnUpdateStatuses_Healthbar_Delay)
	end
end
Ext.RegisterUITypeInvokeListener(Data.UIType.enemyHealthBar, "updateStatuses", OnUpdateStatuses_Healthbar)
Ext.RegisterUITypeInvokeListener(Data.UIType.enemyHealthBar, "hide", function(ui, method)
	lastHealthbarOwnerDouble = nil
end)

function StatusHider.RefreshStatusVisibility()
	if _GS() == "Running" then
		RequestPlayerInfoRefresh()
		RequestHealthbarRefresh()
	end
end

Ext.RegisterNetListener("LeaderLib_UI_UpdateStatusVisibility", function(cmd, payload)
	StatusHider.RefreshStatusVisibility()
end)