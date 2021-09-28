if TagManager == nil then
	TagManager = {}
end

if TagManager.Listeners == nil then
	TagManager.Listeners = {}
end

---@alias TagManagerTagObjectCallback fun(object:EsvCharacter|EsvItem, isInCombat:boolean, isCharacter:boolean, ...:any):void

TagManager.Listeners.TagObject = {
	---@private
	---@type TagManagerTagObjectCallback[]
	Callbacks = {},
	---@param callback TagManagerTagObjectCallback
	Register = function(callback)
		table.insert(TagManager.Listeners.TagObject.Callbacks, callback)
	end
}

--LeaderLib_FriendlyFireEnabled, BOSS, and IMMORTAL tags.
TagManager.Listeners.TagObject.Register(function(object, isInCombat, isCharacter, ...)
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
	end
end)

---@param ... any Optional parameters to pass to listeners.
function TagManager:TagAll(...)
	for i,v in pairs(Ext.GetAllCharacters()) do
		local object = Ext.GetCharacter(v)
		local isInCombat = Ext.OsirisIsCallable() and CharacterIsInCombat(object.MyGuid) == 1
		InvokeListenerCallbacks(TagManager.Listeners.TagObject.Callbacks, object, isInCombat, true, ...)
	end
end

---@param object UUID|NETID|EsvCharacter|EsvItem
---@param isInCombat boolean|nil
---@param ... any Optional parameters to pass to listeners.
function TagManager:TagObject(object, isInCombat, ...)
	object = GameHelpers.TryGetObject(object)
	local isCharacter = GameHelpers.Ext.ObjectIsCharacter(object)
	isInCombat = isInCombat
	if isInCombat == nil then
		isInCombat = (isCharacter and Ext.OsirisIsCallable() and CharacterIsInCombat(object.MyGuid) == 1)
	end
	InvokeListenerCallbacks(TagManager.Listeners.TagObject.Callbacks, object, isInCombat, isCharacter, ...)
end

Ext.RegisterOsirisListener("ObjectEnteredCombat", 2, "after", function(uuid, combatId)
	TagManager:TagObject(uuid, true)
end)

Ext.RegisterOsirisListener("ObjectLeftCombat", 2, "after", function(uuid, combatId)
	TagManager:TagObject(uuid, false)
end)

Ext.RegisterOsirisListener("ObjectSwitchedCombat", 3, "after", function(uuid, oldCombatId, combatId)
	TagManager:TagObject(uuid, true)
end)

Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region, isEditorMode)
	--Delay in case a player loads a save again
	Timer.StartOneshot("LeaderLib_TagAllCharacter", 5000, function()
		TagManager:TagAll()
	end)
end)