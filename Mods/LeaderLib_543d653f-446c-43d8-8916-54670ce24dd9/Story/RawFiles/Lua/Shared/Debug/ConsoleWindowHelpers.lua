Vars.ConsoleWindowVariables = {}
local _ISCLIENT = Ext.IsClient()

local _consoleVars = {}

local consoleEnvironment = getmetatable(_ENV).__index
if consoleEnvironment then
	local meta = getmetatable(consoleEnvironment)
	if meta == nil then
		setmetatable(consoleEnvironment, {
			__index = _consoleVars
		})
	end
end

function AddConsoleVariable(name, value)
	_consoleVars[name] = value
	Vars.ConsoleWindowVariables[name] = value
end

if Vars.DebugMode then

	AddConsoleVariable("Common", Common)
	AddConsoleVariable("GameHelpers", GameHelpers)
	AddConsoleVariable("CombatLog", CombatLog)
	AddConsoleVariable("inspect", Lib.inspect)
	AddConsoleVariable("serpent", Lib.serpent)

	--local x,y,z = table.unpack(_ctxt.WorldPos); ItemMoveToPosition(_ctxt.MyGuid, x, y + 4, z, 2, 2, "", 0);
	--local x,y,z = table.unpack(_ctxt.WorldPos); local rx,rt,rz = GetRotation(_ctxt.MyGuid); ItemToTransform(_ctxt.MyGuid, x, y + 4, z, rx,rt,rz, 1, "");
	Ext.RegisterNetListener("LeaderLib_SetLastContextTarget", function (cmd, uuid)
		Vars.LastContextTarget = uuid
	end)

	local _getLastContextObject = function()
		if Vars.LastContextTarget then
			return GameHelpers.TryGetObject(Vars.LastContextTarget)
		end
	end
	local _ctxt = {}
	setmetatable(_ctxt, {
		__call = _getLastContextObject,
		__index = function(tbl,k)
			local obj = _getLastContextObject()
			if obj then
				if k == "Print" then
					return Lib.serpent.block(obj, {SimplifyUserdata = true})
				end
				local v = obj[k]
				if type(v) == "function" then
					return function(...)
						local params = {...}
						if params[1] == _ctxt then
							table.remove(params, 1)
						end
						local b,result = pcall(v, obj, table.unpack(params))
						if not b then
							Ext.PrintError(result)
						else
							return result
						end
					end
				else
					return v
				end
			else
				fprint(LOGLEVEL.WARNING, "[_ctxt] Vars.LastContextTarget is not set.")
			end
		end,
		__newindex = function(tbl,k,v)
			local obj = _getLastContextObject()
			if obj then
				obj[k] = v
			end
		end,
		__tostring = function()
			return string.format("Last Context Menu Target: %s", Vars.LastContextTarget or "nil")
		end
	})
	AddConsoleVariable("_ctxt", _ctxt)
end

if not _ISCLIENT then
	local me = {}
	setmetatable(me, {
		__call = function()
			return Ext.GetCharacter(CharacterGetHostCharacter())
		end,
		__index = function(tbl,k)
			local char = Ext.GetCharacter(CharacterGetHostCharacter())
			if k == "Print" then
				return Lib.inspect(char)
			end
			local v = char[k]
			if type(v) == "function" then
				return function(...)
					local params = {...}
					if params[1] == me then
						table.remove(params, 1)
					end
					local b,result = pcall(v, char, table.unpack(params))
					return result
				end
			else
				return v
			end
		end,
		__newindex = function(tbl,k,v)
			local char = Ext.GetCharacter(CharacterGetHostCharacter())
			if char then
				char[k] = v
			end
		end,
		__tostring = function()
			return StringHelpers.GetUUID(CharacterGetHostCharacter())
		end
	})
	AddConsoleVariable("me", me)

	local party = {}
	function party.ApplyStatus(entries, status, duration, force)
		if entries == party or entries == nil then
			entries = GameHelpers.GetParty(nil, true, true, false, true)
		end
		PrintDebug(entries, #entries, status)
		if status then
			duration = duration or 6.0
			if force == nil then
				force = false
			end
			for i,v in pairs(entries) do
				fprint(LOGLEVEL.DEFAULT, "party.ApplyStatus(\"%s\", \"%s\", %s, %s) to %s", v, status, duration, force, GameHelpers.Character.GetDisplayName(v))
				ApplyStatus(v, status, duration, force, CharacterGetHostCharacter())
			end
			return true
		end
		return false
	end
	function party.RemoveStatus(entries, status)
		if entries == party or entries == nil then
			entries = GameHelpers.GetParty(nil, true, true, false, true)
		end
		if status then
			local removeAll = StringHelpers.Equals(status, "all", true)
			for i,v in pairs(entries) do
				if not removeAll then
					fprint(LOGLEVEL.DEFAULT, "party.RemoveStatus(\"%s\", \"%s\") from %s", v, status, GameHelpers.Character.GetDisplayName(v))
					RemoveStatus(v, status)
				else
					local statuses = Ext.GetCharacter(v):GetStatuses()
					fprint(LOGLEVEL.DEFAULT, "party.RemoveStatus(\"%s\", \"%s\") from %s", v, StringHelpers.Join(",", statuses), GameHelpers.Character.GetDisplayName(v))
					for _,id in pairs(statuses) do
						RemoveStatus(v, id)
					end
				end
			end
			return true
		end
		return false
	end
	local function ConfigurePartyMetdata(data)
		local meta = {}
		for k,v in pairs(party) do
			if type(v) == "function" then
				meta[k] = function(tbl, ...)
					PrintDebug("meta", k, tbl == data, ...)
					local b,result = pcall(v, data, ...)
					return result
				end
			end
		end
		function meta.__pairs(_)
			local function iter(_, k)
				local v
				k, v = next(data, k)
				if v ~= nil then return k,v end
			end

			-- Return an iterator function, the table, starting point
			return iter, data, nil
		end
		function meta.__ipairs(_)
			local function iter(_, i)
				i = i + 1
				local v = data[i]
				if v ~= nil then return i,v end
			end
			return iter, data, nil
		end
		meta.__index = meta
		setmetatable(data, meta)
		return data
	end
	setmetatable(party, {
		__call = function(includeSommons, includeFollowers)
			return ConfigurePartyMetdata(GameHelpers.GetParty(CharacterGetHostCharacter(), includeSommons, includeFollowers, false, true))
		end,
		__index = function(tbl,k,v)
			local partyMembers = GameHelpers.GetParty(CharacterGetHostCharacter(), true, true, false, true)
			if type(k) == "string" then
				k = string.lower(k)
				local data = {}
				if string.find(k, "player") then
					for _,v in pairs(partyMembers) do
						if GameHelpers.Character.IsPlayer(v) then
							data[#data+1] = v
						end
					end
					return ConfigurePartyMetdata(data)
				elseif string.find(k, "summon") then
					for _,v in pairs(partyMembers) do
						if CharacterIsSummon(v) == 1 then
							data[#data+1] = v
						end
					end
					return ConfigurePartyMetdata(data)
				elseif string.find(k, "follower") then
					for _,v in pairs(partyMembers) do
						if CharacterIsPartyFollower(v) == 1 then
							data[#data+1] = v
						end
					end
					return ConfigurePartyMetdata(data)
				end
			end
			return partyMembers
		end,
		__tostring = function()
			local data = {}
			for _,v in pairs(GameHelpers.GetParty(CharacterGetHostCharacter(), false, false, false, true)) do
				data[v] = GameHelpers.Character.GetDisplayName(v)
			end
			return Common.JsonStringify(data)
		end
	})
	AddConsoleVariable("_party", party)


	if Vars.DebugMode then
		local character = {}
		function character.GetAll(props, includeDefault, exportToFileName)
			local data = Ext.GetAllCharacters()
			setmetatable(data, {
				__tostring = function()
					local text = {}
					local printProps = props and type(props) == "table"
					for _,v in pairs(data) do
						local c = Ext.GetCharacter(v)
						local entry = {}
						if printProps then
							for _,propertyName in pairs(props) do
								if propertyName == "Tags" then
									local tags = c:GetTags()
									table.sort(tags)
									entry.Tags = tags
								else
									local value = c[propertyName] or c.RootTemplate[propertyName] or c.Stats[propertyName] or nil
									if type(value) == "function" then
										local b,result = xpcall(value, debug.traceback, c)
										if not b then
											Ext.PrintError(result)
										else
											if string.find(propertyName, "Statuses") then
												propertyName = "Statuses"
											end
											entry[propertyName] = result
										end
									elseif value then
										entry[propertyName] = tostring(value)
									end
								end
							end
						end
						if not printProps or includeDefault then
							entry.DisplayName = GameHelpers.Character.GetDisplayName(c)
							entry.NetID = c.NetID
							entry.StatsId = c.Stats.Name
							entry.Name = c.RootTemplate.Name
							entry.RootTemplate = c.RootTemplate.TemplateName
							if c.OffStage then
								entry.OffStage = true
							end
						end
						text[v] = entry
					end
					return Common.JsonStringify(text)
				end
			})
			if exportToFileName then
				Ext.SaveFile(string.format("ConsoleDebug/%s.json", exportToFileName), tostring(data))
			end
			return data
		end
		setmetatable(character, {
			__call = function(tbl, uuid)
				local t = type(uuid)
				if t == "string" then
					if ObjectExists(uuid) == 0 then
						error(string.format("UUID '%s' does not exist!", uuid))
					end
					return Ext.GetCharacter(uuid)
				elseif t == "number" then
					return Ext.GetCharacter(uuid)
				end
				return nil
			end,
			__index = function(tbl,k)
				Ext.PrintWarning("Call character() with a uuid first.")
				return character
			end
		})
		AddConsoleVariable("_character", character)
	end
else
	local me = {}
	setmetatable(me, {
		__call = function()
			return Client:GetCharacter()
		end,
		__index = function(tbl,k)
			local char = Client:GetCharacter()
			if k == "Print" then
				return Lib.inspect(char)
			end
			local v = char[k]
			if type(v) == "function" then
				return function(...)
					local params = {...}
					if params[1] == me then
						table.remove(params, 1)
					end
					local b,result = pcall(v, char, table.unpack(params))
					return result
				end
			else
				return v
			end
		end,
		__newindex = function(tbl,k,v)
			local char = Client:GetCharacter()
			if char then
				char[k] = v
			end
		end,
		__tostring = function()
			return tostring(Client:GetCharacter().NetID)
		end
	})
	AddConsoleVariable("me", me)

	if Vars.DebugMode then
		local function CreateUIWrapperTable(uiType, controllerUIType)
			local tbl = {}
			local _getInst = function() return Ext.GetUIByType(not Vars.ControllerEnabled and uiType or controllerUIType) end
			setmetatable(tbl, {
				__call = function()
					local ui = _getInst()
					if ui then
						return ui:GetRoot()
					end
				end,
				__index = function(tbl,k)
					local ui = _getInst()
					if ui then
						if k == "Instance" then
							return ui
						end
						local this = ui:GetRoot()
						if k == "Root" then
							return this
						end
						local v = this[k] or ui[k]
						if type(v) == "function" then
							return function(...)
								local b,result = pcall(v, this, ...)
								return result
							end
						else
							return v
						end
					end
				end,
				__newindex = function(tbl,k,v)
					local ui = _getInst()
					if ui then
						local t = type(ui[k])
						if t == "number" or t == "string" or t == "boolean" or t == "table" then
							ui[k] = v
							return
						end
						local this = ui:GetRoot()
						this[k] = v
					end
				end,
				__tostring = function()
					return tostring(not Vars.ControllerEnabled and uiType or controllerUIType)
				end
			})
		end

		AddConsoleVariable("_ui_sheet", CreateUIWrapperTable(Data.UIType.characterSheet, Data.UIType.statsPanel_c))
		AddConsoleVariable("_ui_hotbar", CreateUIWrapperTable(Data.UIType.hotBar, Data.UIType.bottomBar_c))
		AddConsoleVariable("_ui_tutorialBox", CreateUIWrapperTable(Data.UIType.tutorialBox, Data.UIType.tutorialBox_c))

		--_ui_tutorialBox.fadeInNonModalPointer("Test here!", 100, 200, 0)
	end
end