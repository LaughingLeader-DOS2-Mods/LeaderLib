
if Ext.IsDeveloperMode() then
	local consoleEnvironment = getmetatable(_ENV).__index

	local host = {}
	setmetatable(host, {
		__call = function()
			return Ext.GetCharacter(CharacterGetHostCharacter())
		end,
		__index = function(tbl,k)
			local char = Ext.GetCharacter(CharacterGetHostCharacter())
			local v = char[k]
			if type(v) == "function" then
				return function(...)
					local b,result = pcall(v, char, ...)
					return result
				end
			else
				return v
			end
		end,
		__tostring = function()
			return StringHelpers.GetUUID(CharacterGetHostCharacter())
		end
	})
	consoleEnvironment.host = host

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
				return Ext.JsonStringify(text)
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
	consoleEnvironment.character = character

	local party = {}
	function party.ApplyStatus(entries, status, duration, force)
		if entries == party or entries == nil then
			entries = GameHelpers.GetParty(nil, true, true, false, true)
		end
		print(entries, #entries, status)
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
					print("meta", k, tbl == data, ...)
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
			return Ext.JsonStringify(data)
		end
	})
	consoleEnvironment.party = party
	consoleEnvironment.Common = Common
	consoleEnvironment.GameHelpers = GameHelpers
end