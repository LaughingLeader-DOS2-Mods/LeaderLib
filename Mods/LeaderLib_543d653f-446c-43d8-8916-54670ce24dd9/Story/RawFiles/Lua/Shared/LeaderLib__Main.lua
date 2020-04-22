--- Registers a function to call when a specific Lua LeaderLib event fires.
---@param event string
---@param callback function
function RegisterListener(event, callback)
	if LeaderLib.Listeners[event] ~= nil then
		table.insert(LeaderLib.Listeners[event], callback)
	else
		error("[LeaderLib__Main.lua:RegisterListener] Event ("..tostring(event)..") is not a valid LeaderLib listener event!")
	end
end

--- Registers a function to call when a specific Lua LeaderLib event fires.
---@param event string
---@param uuid string
---@param callback function
function RegisterModListener(event, uuid, callback)
	if LeaderLib.ModListeners[event] ~= nil then
		LeaderLib.Listeners[event][uuid] = callback
	else
		error("[LeaderLib__Main.lua:RegisterListener] Event ("..tostring(event)..") is not a valid LeaderLib listener event!")
	end
end

--- Registers a function to call when a specific skill's events fire.
---@param skill string
---@param callback function
function RegisterSkillListener(skill, callback)
	if LeaderLib.SkillListeners[skill] == nil then
		LeaderLib.SkillListeners[skill] = {}
	end
	table.insert(LeaderLib.SkillListeners[skill], callback)
end

if _G["LeaderLib"] == nil then
	_G["LeaderLib"] = {
		Classes = {},
		Common = {},
		Game = {},
		Initialized = false,
		Main = {},
		ModRegistration = {},
		Register = {},
		Settings = {},
		StatusTypes = {
			ACTIVE_DEFENSE = {},
			BLIND = { BLIND = true },
			CHARMED = { CHARMED = true },
			DAMAGE_ON_MOVE = { DAMAGE_ON_MOVE = true },
			DISARMED = { DISARMED = true },
			INCAPACITATED = {},
			INVISIBLE = { INVISIBLE = true },
			KNOCKED_DOWN = { KNOCKED_DOWN = true },
			MUTED = { MUTED = true },
			POLYMORPHED = {},
		},
		IgnoredMods = {
			--["7e737d2f-31d2-4751-963f-be6ccc59cd0c"] = true,--LeaderLib
			["2bd9bdbe-22ae-4aa2-9c93-205880fc6564"] = true,--Shared
			["eedf7638-36ff-4f26-a50a-076b87d53ba0"] = true,--Shared_DOS
			["1301db3d-1f54-4e98-9be5-5094030916e4"] = true,--Divinity: Original Sin 2
			["a99afe76-e1b0-43a1-98c2-0fd1448c223b"] = true,--Arena
			["00550ab2-ac92-410c-8d94-742f7629de0e"] = true,--Game Master
			["015de505-6e7f-460c-844c-395de6c2ce34"] = true,--Nine Lives
			["38608c30-1658-4f6a-8adf-e826a5295808"] = true,--Herb Gardens
			["1273be96-6a1b-4da9-b377-249b98dc4b7e"] = true,--Source Meditation
			["af4b3f9c-c5cb-438d-91ae-08c5804c1983"] = true,--From the Ashes
			["ec27251d-acc0-4ab8-920e-dbc851e79bb4"] = true,--Endless Runner
			["b40e443e-badd-4727-82b3-f88a170c4db7"] = true,--Character_Creation_Pack
			["9b45f7e5-d4e2-4fc2-8ef7-3b8e90a5256c"] = true,--8 Action Points
			["f33ded5d-23ab-4f0c-b71e-1aff68eee2cd"] = true,--Hagglers
			["68a99fef-d125-4ed0-893f-bb6751e52c5e"] = true,--Crafter's Kit
			["ca32a698-d63e-4d20-92a7-dd83cba7bc56"] = true,--Divine Talents
			["f30953bb-10d3-4ba4-958c-0f38d4906195"] = true,--Combat Randomiser
			["423fae51-61e3-469a-9c1f-8ad3fd349f02"] = true,--Animal Empathy
			["2d42113c-681a-47b6-96a1-d90b3b1b07d3"] = true,--Fort Joy Magic Mirror
			["8fe1719c-ef8f-4cb7-84bd-5a474ff7b6c1"] = true,--Enhanced Spirit Vision
			["a945eefa-530c-4bca-a29c-a51450f8e181"] = true,--Sourcerous Sundries
			["f243c84f-9322-43ac-96b7-7504f990a8f0"] = true,--Improved Organisation
			["d2507d43-efce-48b8-ba5e-5dd136c715a7"] = true,--Pet Power
		},
		Listeners = {
			CharacterSheetPointChanged = {},
			CharacterBasePointsChanged = {},
			TimerFinished = {},
		},
		SkillListeners = {},
		ModListeners = {
			Registered = {},
			Updated = {},
		},
		RegisterListener = RegisterListener,
		RegisterModListener = RegisterModListener,
		RegisterSkillListener = RegisterSkillListener,
	}
end

Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Shared/LeaderLib__Data.lua")

LeaderLib.StatusTypes.CHARMED = { CHARMED = true }
--LeaderLib.StatusTypes.POLYMORPHED = { POLYMORPHED = true }

local function LeaderLib_Shared_SessionLoading()
	for i,status in pairs(Ext.GetStatEntries("StatusData")) do
		local statusType = Ext.StatGetAttribute(status, "StatusType")
		if statusType ~= nil and statusType ~= "" then
			statusType = string.upper(statusType)
			local statusTypeTable = LeaderLib.StatusTypes[statusType]
			if statusTypeTable ~= nil then
				statusTypeTable[status] = true
				--LeaderLib.Print("[LeaderLib__Main.lua:LeaderLib_Shared_SessionLoading] Added Status ("..status..") to StatusType table ("..statusType..").")
			end
		end
	end
	--LeaderLib.Print("Tables " .. LeaderLib.Common.Dump(LeaderLib.StatusTypes))
end

Ext.RegisterListener("SessionLoading", LeaderLib_Shared_SessionLoading)