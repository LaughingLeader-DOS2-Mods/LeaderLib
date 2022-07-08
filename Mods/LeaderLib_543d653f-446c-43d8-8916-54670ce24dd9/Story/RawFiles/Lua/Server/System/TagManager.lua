if TagManager == nil then
	TagManager = {}
end

---@private
TagManager.Callbacks = {
	TagObject = {}
}

---@alias TagManagerTagObjectCallback fun(object:EsvCharacter|EsvItem, isInCombat:boolean, isCharacter:boolean, ...:any):void

TagManager.Register = {
	---@param callback TagManagerTagObjectCallback
	TagObject = function(callback)
		table.insert(TagManager.Callbacks.TagObject, callback)
	end
}

--LeaderLib_FriendlyFireEnabled, BOSS, and IMMORTAL tags.
TagManager.Register.TagObject(function(object, isInCombat, isCharacter, ...)
	if isCharacter then
		local args = {...}
		local friendlyFireEnabled = args[1] == true or SettingsManager.GetMod(ModuleUUID, false).Global:FlagEquals("LeaderLib_FriendlyFireEnabled", true)
		if friendlyFireEnabled then
			SetTag(object.MyGuid, "LeaderLib_FriendlyFireEnabled")
		else
			ClearTag(object.MyGuid, "LeaderLib_FriendlyFireEnabled")
		end
	
		if object.RootTemplate.CombatTemplate.IsBoss then
			SetTag(object.MyGuid, "BOSS")
		else
			ClearTag(object.MyGuid, "BOSS")
		end

		if object.CannotDie then
			SetTag(object.MyGuid, "IMMORTAL")
		else
			ClearTag(object.MyGuid, "IMMORTAL")
		end
	else
		if Ext.OsirisIsCallable() then
			if ItemIsDestructible(object.MyGuid) == 0 then
				SetTag(object.MyGuid, "IMMORTAL")
			else
				ClearTag(object.MyGuid, "IMMORTAL")
			end
		end
	end
end)

---@param object ObjectParam
---@param isInCombat boolean|nil
---@param ... any Optional parameters to pass to listeners.
function TagManager:TagObject(object, isInCombat, ...)
	object = GameHelpers.TryGetObject(object)
	if object then
		local isCharacter = GameHelpers.Ext.ObjectIsCharacter(object)
		if isInCombat == nil then
			if isCharacter then
				if Ext.OsirisIsCallable() and CharacterIsInCombat(object.MyGuid) == 1 then
					isInCombat = true
				else
					if object:GetStatus("COMBAT") then
						isInCombat = true
					end
				end
			end
		end
		InvokeListenerCallbacks(TagManager.Callbacks.TagObject, object, isInCombat, isCharacter, ...)
	end
end

---@param ... any Optional parameters to pass to listeners.
function TagManager:TagAll(...)
	if not StringHelpers.IsNullOrEmpty(SharedData.RegionData.Current) then
		for i,v in pairs(Ext.GetAllCharacters(SharedData.RegionData.Current)) do
			TagManager:TagObject(v, nil, ...)
		end
	end
end

Ext.RegisterOsirisListener("ObjectEnteredCombat", 2, "after", function(uuid, combatId)
	if ObjectIsCharacter(uuid) == 1 then
		TagManager:TagObject(uuid, true)
	end
end)

Ext.RegisterOsirisListener("ObjectLeftCombat", 2, "after", function(uuid, combatId)
	if ObjectIsCharacter(uuid) == 1 then
		TagManager:TagObject(uuid, false)
	end
end)

Ext.RegisterOsirisListener("ObjectSwitchedCombat", 3, "after", function(uuid, oldCombatId, combatId)
	if ObjectIsCharacter(uuid) == 1 then
		TagManager:TagObject(uuid, true)
	end
end)

Ext.RegisterOsirisListener("ObjectTransformed", 2, "after", function(uuid, template)
	if ObjectIsCharacter(uuid) == 1 then
		TagManager:TagObject(uuid, true)
	end
end)

Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region, isEditorMode)
	--Delay in case a player loads a save again
	Timer.StartOneshot("LeaderLib_TagAllCharacters", 5000, function()
		TagManager:TagAll()
	end)
end)