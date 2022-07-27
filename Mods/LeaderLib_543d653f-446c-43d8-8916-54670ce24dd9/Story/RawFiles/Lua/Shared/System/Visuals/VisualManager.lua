local _ISCLIENT = Ext.IsClient()
local _EXTVERSION = Ext.Version()

---@class LeaderLibVisualManager
VisualManager = {}

Managers.Visual = VisualManager

local _ObjToNetID = nil
_ObjToNetID = function(key, value, t)
	if t == "userdata" and value.NetID then
		return value.NetID
	elseif t == "boolean" or t == "string" or t == "number" then
		return value
	elseif t == "table" then
		return TableHelpers.SanitizeTable(value, nil, true, _ObjToNetID)
	end
end

if not _ISCLIENT then
	Ext.Require("Shared/System/Visuals/Elements/ElementManager.lua")
	Ext.Require("Shared/System/Visuals/Events.lua")

	---@class LeaderLibClientVisualPersistenceOptions
	---@field CurrentVisualOnly boolean|nil If true, the visual will only be created if the character is using the same visual resource. This prevents the visual from being recreated when polymorphed into a different race.
	---@field Races "ALL"|RaceTag|table<RaceTag, boolean> Races to restrict the visual to.
	---@field Gender string|"ALL"|"MALE"|"FEMALE" Genders to restrict the visual to.

	---🔨**Server-Only**🔨  
	---@param character CharacterParam
	---@param visualResource string
	---@param options ExtenderClientVisualOptions|nil
	---@param extraOptions LeaderLibClientVisualOptions|nil
	---@param persistence LeaderLibClientVisualPersistenceOptions|nil If true, this visual will be created when the game is initialized, or when it's destroyed and needs to be recreated again (i.e. after POLYMORPH is removed).
	function VisualManager.RequestAttachVisual(character, visualResource, options, extraOptions, persistence)
		character = GameHelpers.GetCharacter(character)
		if not character then
			error("Character parameter is invalid")
		end
		local opts = options and TableHelpers.SanitizeTable(options, {userdata=true, table=true}, true, _ObjToNetID) or nil
		local extraOptions = extraOptions and TableHelpers.SanitizeTable(extraOptions, {userdata=true, table=true}, true, _ObjToNetID) or nil
		local data = {
			Target = character.NetID,
			Options = opts,
			ExtraOptions = extraOptions,
			Resource = visualResource
		}
		if persistence and Common.TableHasAnyEntry(persistence) then
			if PersistentVars.PersistentVisuals[character.MyGuid] == nil then
				PersistentVars.PersistentVisuals[character.MyGuid] = {}
			end
			PersistentVars.PersistentVisuals[character.MyGuid][#PersistentVars.PersistentVisuals[character.MyGuid]+1] = {
				Resource = visualResource,
				Options = opts,
				ExtraOptions = extraOptions,
				Persistence = persistence,
				RestrictToVisual = persistence.CurrentVisualOnly == true and character.RootTemplate.VisualTemplate
			}
		end
		GameHelpers.Net.Broadcast("LeaderLib_VisualManager_RequestAttachVisual", data)
	end

	---@param character EsvCharacter
	---@param v LeaderLibPersistentVisualsEntry
	local function CanCreateVisual(character, v)
		if v.RestrictToVisual and v.RestrictToVisual ~= character.RootTemplate.VisualTemplate then
			return false
		end
		if v.Persistence then
			if v.Persistence.Gender and v.Persistence.Gender ~= "ALL" then
				if not character:HasTag(v.Persistence.Gender) then
					return false
				end
			end
			if v.Persistence.Races and v.Persistence.Races ~= "ALL" then
				local t = type(v.Persistence.Races)
				if t == "table" then
					for tag,b in pairs(v.Persistence.Races) do
						if b == true and not character:HasTag(tag) then
							return false
						end 
					end
				elseif t == "string" then
					if not character:HasTag(v.Persistence.Races) then
						return false
					end
				end
			end
		end
		return true
	end

	---🔨**Server-Only**🔨  
	---@param character EsvCharacter
	function VisualManager.RebuildPersistentVisuals(character)
		local visuals = PersistentVars.PersistentVisuals[character.MyGuid]
		if visuals then
			for _,v in pairs(visuals) do
				if CanCreateVisual(character, v) then
					VisualManager.RequestAttachVisual(character, v.Resource, v.Options, v.ExtraOptions)
				end
			end
		end
	end

	Ext.Events.SessionLoaded:Subscribe(function (e)
		StatusManager.Subscribe.RemovedType("POLYMORPHED", function (e)
			if e.Target then
				VisualManager.RebuildPersistentVisuals(e.Target)
			end
		end, 1000)

		StatusManager.Subscribe.AppliedType("POLYMORPHED", function (e)
			if e.Target then
				VisualManager.RebuildPersistentVisuals(e.Target)
			end
		end, 1000)
	end)
else
	Ext.Require("Shared/System/Visuals/ClientVisuals.lua")
end