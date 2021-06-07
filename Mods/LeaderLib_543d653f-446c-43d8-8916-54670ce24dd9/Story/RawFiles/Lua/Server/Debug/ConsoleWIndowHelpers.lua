
if Ext.IsDeveloperMode() then
	local consoleEnvironment = getmetatable(_ENV).__index

	local host = {}
	setmetatable(host, {
		__call = function(includeSommons, includeFollowers)
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