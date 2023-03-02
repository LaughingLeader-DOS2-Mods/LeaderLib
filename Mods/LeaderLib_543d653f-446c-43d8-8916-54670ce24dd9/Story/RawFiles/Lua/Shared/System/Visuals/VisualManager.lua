local _ISCLIENT = Ext.IsClient()
local _EXTVERSION = Ext.Utils.Version()

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

	---@class LeaderLibVisualManagerRequestAttachVisualBaseOptions
	---@field ID string
	---@field Persistence LeaderLibClientVisualPersistenceOptions If set, this visual will be created when the game is initialized, or when it's destroyed and needs to be recreated again (i.e. after POLYMORPH is removed).
	---@field CreationSettings ExtenderClientVisualOptions
	---@field ExtraSettings LeaderLibClientVisualOptions

	---@class LeaderLibVisualManagerRequestAttachVisualOptions:LeaderLibVisualManagerRequestAttachVisualBaseOptions
	---@field Resource string|string[]

	--print(Mods.LeaderLib.GameHelpers.Math.GetDistance(me.WorldPos, "d11296d9-833f-4070-9fa7-44ac606aedb8"))
	--Osi.TeleportTo(me.MyGuid, "d11296d9-833f-4070-9fa7-44ac606aedb8")
	--Mods.LeaderLib.VisualManager.RequestAttachVisual("d11296d9-833f-4070-9fa7-44ac606aedb8", {Resource="ba560b88-57e4-4f15-a4e2-379568f0c5b0", CreationSettings={Bone="Dummy_R_HandFX"}})

	---🔨**Server-Only**🔨  
	---@param object ObjectParam
	---@param options LeaderLibVisualManagerRequestAttachVisualOptions
	function VisualManager.RequestAttachVisual(object, options)
		object = GameHelpers.TryGetObject(object)
		if not object then
			error("Object parameter is invalid")
		end
		options = options or {}
		assert(options.Resource ~= nil, "options.Resource is required")
		local opts = options.CreationSettings and TableHelpers.SanitizeTable(options.CreationSettings, {userdata=true, table=true}, true, _ObjToNetID) or nil
		local extraOptions = options.ExtraSettings and TableHelpers.SanitizeTable(options.ExtraSettings, {userdata=true, table=true}, true, _ObjToNetID) or nil
		if options.Persistence and Common.TableHasAnyEntry(options.Persistence) then
			if _PV.PersistentVisuals[object.MyGuid] == nil then
				_PV.PersistentVisuals[object.MyGuid] = {}
			end
			local persistentCharacterData = _PV.PersistentVisuals[object.MyGuid]
			table.insert(persistentCharacterData, {
				ID = options.ID,
				Resource = options.Resource,
				Options = opts,
				ExtraOptions = extraOptions,
				Persistence = TableHelpers.SanitizeTable(options.Persistence, nil, true),
				RestrictToVisual = options.Persistence.CurrentVisualOnly == true and object.RootTemplate.VisualTemplate or nil
			})
		end
		---@type LeaderLibRequestAttachVisualData
		local data = {
			ID = options.ID,
			Target = object.NetID,
			Options = opts,
			ExtraOptions = extraOptions,
			Resource = options.Resource,
			IsItem = GameHelpers.Ext.ObjectIsItem(object)
		}
		GameHelpers.Net.Broadcast("LeaderLib_VisualManager_RequestAttachVisual", data)
	end

	---@alias LeaderLibVisualManagerMultiRacialVisualSettings table<RaceTag, {Male:string, Female:string}>

	---@class LeaderLibVisualManagerRequestAttachMultiRacialVisualOptions:LeaderLibVisualManagerRequestAttachVisualBaseOptions
	---@field Visuals LeaderLibVisualManagerMultiRacialVisualSettings

	---@param character EsvCharacter
	---@param settings LeaderLibVisualManagerMultiRacialVisualSettings
	---@return FixedString|nil
	local function _GetResourceForCharacter(character, settings)
		local race = nil
		if character.PlayerCustomData then
			race = string.upper(character.PlayerCustomData.Race)
		end
		if StringHelpers.IsNullOrEmpty(race) then
			race = GameHelpers.Character.GetBaseRace(character)
		end
		local visual = nil
		local isFemale = GameHelpers.Character.IsFemale(character)
		local raceSettings = settings[race]
		if raceSettings then
			if not isFemale then
				visual = raceSettings.Male
			else
				visual = raceSettings.Female
			end
		end
		if StringHelpers.IsNullOrEmpty(visual) then
			fprint(LOGLEVEL.WARNING, "[VisualManager.RequestAttachMultiRacialVisual] No visual for character's race (%s) or gender (%s)", race, isFemale and "Female" or "Male")
		end
		return visual
	end

	---Work-in-Progress
	---🔨**Server-Only**🔨  
	---@param character CharacterParam
	---@param options LeaderLibVisualManagerRequestAttachMultiRacialVisualOptions
	function VisualManager.RequestAttachMultiRacialVisual(character, options)
		character = GameHelpers.GetCharacter(character)
		if not character then
			error("Character parameter is invalid")
		end
		options = options or {}
		assert(options.Visuals ~= nil, "options.Visuals is required")
		local visual = _GetResourceForCharacter(character, options.Visuals)
		local opts = options.CreationSettings and TableHelpers.SanitizeTable(options.CreationSettings, {userdata=true, table=true}, true, _ObjToNetID) or nil
		local extraOptions = options.ExtraSettings and TableHelpers.SanitizeTable(options.ExtraSettings, {userdata=true, table=true}, true, _ObjToNetID) or nil
		if options.Persistence and Common.TableHasAnyEntry(options.Persistence) then
			if _PV.PersistentVisuals[character.MyGuid] == nil then
				_PV.PersistentVisuals[character.MyGuid] = {}
			end
			_PV.PersistentVisuals[character.MyGuid][#_PV.PersistentVisuals[character.MyGuid]+1] = {
				ID = options.ID,
				IsMultiRacial = true,
				Resource = visual or "",
				Options = opts,
				ExtraOptions = extraOptions,
				Persistence = TableHelpers.SanitizeTable(options.Persistence, nil, true),
				RestrictToVisual = options.Persistence.CurrentVisualOnly == true and character.RootTemplate.VisualTemplate or nil
			}
		end
		if not StringHelpers.IsNullOrEmpty(visual) then
			---@type LeaderLibRequestAttachVisualData
			local data = {
				ID = options.ID,
				Target = character.NetID,
				Options = opts,
				ExtraOptions = extraOptions,
				Resource = visual,
			}
			GameHelpers.Net.Broadcast("LeaderLib_VisualManager_RequestAttachVisual", data)
		end
	end

	---🔨**Server-Only**🔨  
	---@param character CharacterParam
	---@param visualResource string|string[]
	function VisualManager.RequestDeleteVisual(character, visualResource)
		character = GameHelpers.GetCharacter(character)
		if not character then
			error("Character parameter is invalid")
		end
		local data = {
			Target = character.NetID,
			Resource = visualResource
		}
		GameHelpers.Net.Broadcast("LeaderLib_VisualManager_RequestDeleteVisual", data)
		local persistentData = _PV.PersistentVisuals[character.MyGuid]
		if persistentData then
			local changed = false
			local nextData = {}
			local t = type(visualResource)
			for i,v in pairs(persistentData) do
				if (t == "string" and v.Resource == visualResource) or (t == "table" and Common.TableHasEntry(visualResource, v)) then
					changed = true
				else
					nextData[#nextData+1] = v
				end
			end
			if changed then
				_PV.PersistentVisuals[character.MyGuid] = nextData
			end
		end
	end

	---🔨**Server-Only**🔨  
	---@param character CharacterParam
	---@param id string|string[]
	function VisualManager.RequestDeleteVisualByID(character, id)
		character = GameHelpers.GetCharacter(character)
		if not character then
			error("Character parameter is invalid")
		end
		local data = {
			Target = character.NetID,
			Resource = id
		}
		GameHelpers.Net.Broadcast("LeaderLib_VisualManager_RequestDeleteVisual", data)
		local persistentData = _PV.PersistentVisuals[character.MyGuid]
		if persistentData then
			local changed = false
			local nextData = {}
			local t = type(id)
			for i,v in pairs(persistentData) do
				if (t == "string" and v.Resource == id) or (t == "table" and Common.TableHasEntry(id, v)) then
					changed = true
				else
					nextData[#nextData+1] = v
				end
			end
			if changed then
				_PV.PersistentVisuals[character.MyGuid] = nextData
			end
		end
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
		local visuals = _PV.PersistentVisuals[character.MyGuid]
		if visuals then
			for _,v in pairs(visuals) do
				if CanCreateVisual(character, v) then
					VisualManager.RequestAttachVisual(character, {Resource=v.Resource, ExtraOptions=v.ExtraOptions, Options=v.Options})
				end
			end
		end
	end

	local _CauseIndex = {
		Loaded = 0,
		Transformed = 1,
		Unsheathed = 2,
		Sheathed = 3,
	}

	---@param character EsvCharacter
	---@param cause RebuildVisualsEventCause
	local function _InvokeRebuildVisuals(character, cause)
		local race = GameHelpers.Character.GetRace(character)
		local gender = GameHelpers.Character.GetGender(character)
		local skeletonVisual = character.RootTemplate.VisualTemplate
		Events.RebuildVisuals:Invoke({
			Character = character,
			CharacterGUID = character.MyGuid,
			CharacterVisual = skeletonVisual,
			Cause = cause,
			CauseIndex = _CauseIndex[cause] or -1,
			Gender = gender,
			Race = race,
		})
	end
	
	Ext.Osiris.RegisterListener("ObjectTransformed", 2, "after", function (guid, template)
		if ObjectExists(guid) == 1 and ObjectIsCharacter(guid) == 1 then
			local character = GameHelpers.GetCharacter(guid)
			if character then
				_InvokeRebuildVisuals(character, "Transformed")
			end
		end
	end)

	--local _VISUAL_REFRESH_STATUSES = {"BOOST", "SNEAKING", "UNSHEATHED"}
	local _VISUAL_REFRESH_STATUSES = "UNSHEATHED"

	Ext.Events.SessionLoaded:Subscribe(function (e)
		Events.RebuildVisuals:Subscribe(function (e)
			VisualManager.RebuildPersistentVisuals(e.Character)
		end, {Priority=0})

		StatusManager.Subscribe.Applied(_VISUAL_REFRESH_STATUSES, function (e)
			if GameHelpers.Ext.ObjectIsCharacter(e.Target) then
				_InvokeRebuildVisuals(e.Target, "Unsheathed")
			end
		end, 1000)

		StatusManager.Subscribe.Removed(_VISUAL_REFRESH_STATUSES, function (e)
			if GameHelpers.Ext.ObjectIsCharacter(e.Target) then
				_InvokeRebuildVisuals(e.Target, "Sheathed")
			end
		end, 1000)
	end)

	Events.Initialized:Subscribe(function (e)
		for player in GameHelpers.Character.GetPlayers(true) do
			_InvokeRebuildVisuals(player, "Loaded")
		end
	end)
else
	Ext.Require("Shared/System/Visuals/ClientVisuals.lua")
end