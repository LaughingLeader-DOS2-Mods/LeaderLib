if TagManager == nil then
	TagManager = {}
end

Managers.Tag = TagManager

---@private
TagManager.Callbacks = {
	TagObject = {}
}

---@alias TagManagerTagObjectCallback fun(object:EsvCharacter|EsvItem, isInCombat:boolean, isCharacter:boolean, ...:any)

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
			Osi.SetTag(object.MyGuid, "LeaderLib_FriendlyFireEnabled")
		else
			Osi.ClearTag(object.MyGuid, "LeaderLib_FriendlyFireEnabled")
		end
	
		if object.RootTemplate.CombatTemplate.IsBoss then
			Osi.SetTag(object.MyGuid, "BOSS")
		else
			Osi.ClearTag(object.MyGuid, "BOSS")
		end

		if object.CannotDie then
			Osi.SetTag(object.MyGuid, "IMMORTAL")
		else
			Osi.ClearTag(object.MyGuid, "IMMORTAL")
		end
	else
		if _OSIRIS() then
			if Osi.ItemIsDestructible(object.MyGuid) == 0 then
				Osi.SetTag(object.MyGuid, "IMMORTAL")
			else
				Osi.ClearTag(object.MyGuid, "IMMORTAL")
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
				if _OSIRIS() and Osi.CharacterIsInCombat(object.MyGuid) == 1 then
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
		for i,v in pairs(Ext.Entity.GetAllCharacterGuids(SharedData.RegionData.Current)) do
			TagManager:TagObject(v, nil, ...)
		end
	end
end

Ext.Osiris.RegisterListener("ObjectEnteredCombat", 2, "after", function(uuid, combatId)
	if Osi.ObjectIsCharacter(uuid) == 1 then
		TagManager:TagObject(uuid, true)
	end
end)

Ext.Osiris.RegisterListener("ObjectLeftCombat", 2, "after", function(uuid, combatId)
	if Osi.ObjectIsCharacter(uuid) == 1 then
		TagManager:TagObject(uuid, false)
	end
end)

Ext.Osiris.RegisterListener("ObjectSwitchedCombat", 3, "after", function(uuid, oldCombatId, combatId)
	if Osi.ObjectIsCharacter(uuid) == 1 then
		TagManager:TagObject(uuid, true)
	end
end)

Ext.Osiris.RegisterListener("ObjectTransformed", 2, "after", function(uuid, template)
	if Osi.ObjectIsCharacter(uuid) == 1 then
		TagManager:TagObject(uuid, true)
	end
end)

Ext.Osiris.RegisterListener("GameStarted", 2, "after", function(region, isEditorMode)
	--Delay in case a player loads a save again
	Timer.StartOneshot("LeaderLib_TagAllCharacters", 5000, function()
		TagManager:TagAll()
	end)
end)