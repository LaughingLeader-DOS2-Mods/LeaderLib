---@diagnostic disable deprecated

local n, v = "serpent", "0.302" -- (C) 2012-18 Paul Kulchenko; MIT License
local c, d = "Paul Kulchenko", "Lua serializer and pretty printer"
local snum = {[tostring(1/0)]='1/0 --[[math.huge]]',[tostring(-1/0)]='-1/0 --[[-math.huge]]',[tostring(0/0)]='0/0'}
local badtype = {thread = true, userdata = true, cdata = true}
local getmetatable = debug and debug.getmetatable or getmetatable
local pairs = function(t) return next, t end -- avoid using __pairs in Lua 5.2+
local keyword, globals, G = {}, {}, (_G or _ENV)

for _,k in ipairs({'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for', 'function', 'goto', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat', 'return', 'then', 'true', 'until', 'while'}) do 
	keyword[k] = true 
end

for k,v in pairs(G) do globals[v] = k end -- build func to name mapping

for _,g in ipairs({'coroutine', 'debug', 'io', 'math', 'string', 'table', 'os'}) do
	for k,v in pairs(type(G[g]) == 'table' and G[g] or {}) do 
		globals[v] = g..'.'..k
	end
end

local function merge(a, b) if b then for k,v in pairs(b) do a[k] = v end end; return a; end

---@param t any
---@param opts serpent_options
local function s(t, opts)
	local level = 0
	local name, indent, fatal, maxnum = opts.name, opts.indent, opts.fatal, opts.maxnum
	local sparse, custom, huge = opts.sparse, opts.custom, not opts.nohuge
	local space, maxl = (opts.compact and '' or ' '), (opts.maxlevel or math.huge)
	local maxlen, metatostring = tonumber(opts.maxlength), opts.metatostring
	local iname, comm = '_'..(name or ''), opts.comment and (tonumber(opts.comment) or math.huge)
	local numformat = opts.numformat or "%.17g"
	local seen, sref, syms, symn = {}, {'local '..iname..'={}'}, {}, 0
	local function gensym(val)
		if type(val) == "userdata" then return tostring(val) end
		return '_'..(tostring(tostring(val)):gsub("[^%w]",""):gsub("(%d%w+)",
		-- tostring(val) is needed because __tostring may return a non-string value
		function(s) if not syms[s] then symn = symn+1; syms[s] = symn end return tostring(syms[s]) end))
	end

	local tableStart = "{"
	local tableEnd = "}"
	local emptyTable = "{}"
	local tableKeyAssign = "="
	local wrapKeys = false

	if opts.inJson then
		tableStart = "["
		tableEnd = "]"
		emptyTable = "[]"
		tableKeyAssign = ":"
		wrapKeys = true
	end

	local function safestr(s) 
		return type(s) == "number" and tostring(huge and snum[tostring(s)] or numformat:format(s))
		or type(s) ~= "string" and tostring(s) -- escape NEWLINE/010 and EOF/026
		or ("%q"):format(s):gsub("\010","n"):gsub("\026","\\026"):gsub("\\\"", "\"")
	end

	local function comment(s,l) return comm and (l or 0) < comm and ' --[['..select(2, pcall(tostring, s))..']]' or '' end

	local function globerr(s,l) return globals[s] and globals[s]..comment(s,l) or not fatal
		and safestr(select(2, pcall(tostring, s))) or error("Can't serialize "..tostring(s))
	end

	local function safename(path, name, wrapKeys) -- generates foo.bar, foo[3], or foo['b a r']
		local n = name == nil and '' or name
		local plain = type(n) == "string" and n:match("^[%l%u_][%w_]*$") and not keyword[n]
		local safe = plain and n or '['..safestr(n)..']'
		local val = (path or '')..(plain and path and '.' or '')..safe
		if wrapKeys then
			val = '"' .. val .. '"'
			safe = '"' .. safe .. '"'
		end
		return val, safe
	end

	local function customtostring(obj, opts)
		if type(obj) == "userdata" then
			return DebugHelpers.TraceUserDataSerpent(obj, merge(opts, {indent=string.rep(indent,level+1)}))
		end
		return safestr(obj)
	end

	local _defaultSort = function(k, o, n) -- k=keys, o=originaltable, n=padding
		local maxn, to = tonumber(n) or 12, {number = 'a', string = 'b'}
		local function padnum(d) return ("%0"..tostring(maxn).."d"):format(tonumber(d)) end
		table.sort(k, function(a,b)
			-- sort numeric keys first: k[key] is not nil for numerical keys
			return (k[a] ~= nil and 0 or to[type(a)] or 'z')..(tostring(a):gsub("%d+",padnum)) < (k[b] ~= nil and 0 or to[type(b)] or 'z')..(tostring(b):gsub("%d+",padnum))
		end)
	end

	local alphanumsort = type(opts.sortkeys) == 'function' and opts.sortkeys or _defaultSort
	local function val2str(t, name, indent, insref, path, plainindex, level)
		local ttype, level, mt = type(t), (level or 0), getmetatable(t)
		local spath, sname = safename(path, name, wrapKeys)
		local tag = ""
		if not wrapKeys then
			tag = plainindex and ((type(name) == "number") and '' or name..space..tableKeyAssign..space) or (name ~= nil and sname..space..tableKeyAssign..space or '')
		else
			if plainindex then
				if type(name) == "number" then
					tag = ''
				else
					local wrappedName = '"' .. tostring(name) .. '"'
					tag = wrappedName..space..tableKeyAssign..space
				end
			else
				if name ~= nil and sname then
					tag = sname..space..tableKeyAssign..space
				end
			end
		end
		if seen[t] then -- already seen this element
			sref[#sref+1] = spath..space..tableKeyAssign..space..seen[t]
			return tag..'nil'..comment('ref', level)
		end
		-- protect from those cases where __tostring may fail
		if type(mt) == 'table' and metatostring ~= false then
			local to, tr = pcall(function() return mt.__tostring(t) end)
			local so, sr = pcall(function() return mt.__serialize(t) end)
			if (to or so) then -- knows how to serialize itself
				seen[t] = insref or spath
				t = so and sr or tr
				ttype = type(t)
			end -- new value falls through to be serialized
		end
		if ttype == "userdata" then
			t = DebugHelpers.TraceUserDataSerpent(t, opts)
			ttype = type(t)
		end
		if ttype == "table" then
			if level >= maxl then return tag..emptyTable..comment('maxlvl', level) end
			seen[t] = insref or spath
			if next(t) == nil then return tag..emptyTable..comment(t, level) end -- table empty
			if maxlen and maxlen < 0 then return tag..emptyTable..comment('maxlen', level) end
			local iskvType = #t == 0
			local maxn, o, out = math.min(#t, maxnum or #t), {}, {}
			for key = 1, maxn do o[key] = key end
			if not maxnum or #o < maxnum then
				local n = #o -- n = n + 1; o[n] is much faster than o[#o+1] on large tables
				for key in pairs(t) do
					if o[key] ~= key then 
						n = n + 1; o[n] = key
					end
				end
			end
			if maxnum and #o > maxnum then o[maxnum+1] = nil end
			if opts.sortkeys and #o > maxn then alphanumsort(o, t, opts.sortkeys) end
			local sparse = sparse and #o > maxn -- disable sparsness if only numeric keys (shorter output)
			for n,k in ipairs(o) do
				local value, ktype, plainindex = t[k], type(k), n <= maxn and not sparse
				if ktype == "userdata" then
					k = tostring(k)
					ktype = "string"
				end
				if opts.valignore and opts.valignore[value] -- skip ignored values; do nothing
				or opts.keyallow and not opts.keyallow[k]
				or opts.keyignore and opts.keyignore[k]
				or opts.valtypeignore and opts.valtypeignore[type(value)] -- skipping ignored value types
				or sparse and value == nil then -- skipping nils; do nothing
				elseif ktype == 'table' or ktype == 'function' or badtype[ktype] then
					if not seen[k] and not globals[k] then
						sref[#sref+1] = 'placeholder'
						local _,sname = safename(iname, gensym(k)) -- iname is table for local variables
						sref[#sref] = val2str(k,sname,indent,sname,iname,true) end
						sref[#sref+1] = 'placeholder'
						local path = seen[t]..'['..tostring(seen[k] or globals[k] or gensym(k))..']'
						sref[#sref] = path..space..tableKeyAssign..space..tostring(seen[value] or val2str(value,nil,indent,path))
				else
					out[#out+1] = val2str(value,k,indent,nil,seen[t],plainindex,level+1)
					if maxlen then
						maxlen = maxlen - #out[#out]
						if maxlen < 0 then break end
					end
				end
			end
			local prefix = string.rep(indent or '', level)
			local head = indent and tableStart..'\n'..prefix..indent or tableStart
			local body = table.concat(out, ','..(indent and '\n'..prefix..indent or space))
			local tail = indent and "\n"..prefix..tableEnd or tableEnd
			if iskvType and opts.inJson then
				head = indent and '{\n'..prefix..indent or '{'
				tail = indent and "\n"..prefix..'}' or '}'
			end
			return (custom and custom(tag,head,body,tail,level) or tag..head..body..tail)..comment(t, level)
		elseif badtype[ttype] then
			seen[t] = insref or spath
			return tag..globerr(t, level)
		elseif ttype == 'function' then
			seen[t] = insref or spath
			if opts.nocode then return tag.."function(...) end"..comment(t, level) end
			local ok, res = pcall(string.dump, t)
			local func = ok and "((loadstring or load)("..safestr(res)..",'@serialized'))"..comment(t, level)
			return tag..(func or globerr(t, level))
		else
				-- handle all other types
			return tag..safestr(t)
		end
	end
	local sepr = indent and "\n" or ";"..space
	local body = val2str(t, name, indent) -- this call also populates sref
	local tail = #sref>1 and table.concat(sref, sepr)..sepr or ''
	local warn = opts.comment and #sref>1 and space.."--[[incomplete output with shared/self-references skipped]]" or ''
	return not name and body..warn or "do local "..body..sepr..tail.."return "..name..sepr.."end"
end
				
local function deserialize(data, opts)
	local env = (opts and opts.safe == false) and G
	or setmetatable({}, {
		__index = function(t,k) return t end,
		__call = function(t,...) error("cannot call functions") end
	})
	local f, res = (loadstring or load)('return '..data, nil, nil, env)
	if not f then f, res = (loadstring or load)(data, nil, nil, env) end
	if not f then return f, res end
	if setfenv then setfenv(f, env) end
	return pcall(f)
end
					
---@class serpent_options:table
---@field indent string indentation; triggers long multi-line output.
---@field comment boolean|integer provide stringified value in a comment (up to maxlevel of depth).
---@field sortkeys boolean|function sort keys.
---@field sparse boolean force sparse encoding (no nil filling based on #t).
---@field compact boolean remove spaces.
---@field fatal boolean raise fatal error on non-serilizable values.
---@field nocode boolean disable bytecode serialization for easy comparison.
---@field nohuge boolean disable checking numbers against undefined and huge values.
---@field maxlevel number specify max level up to which to expand nested tables.
---@field maxnum number specify max number of elements in a table.
---@field maxlength number specify max length for all table elements.
---@field metatostring boolean use __tostring metamethod when serializing tables (v0.29); set to false to disable and serialize the table as is, even when __tostring is present.
---@field numformat string specify format for numeric values as shortest possible round-trippable double (v0.30). Use "%.16g" for better readability and "%.17g" (the default ---@field value) to preserve floating point precision.
---@field valignore table allows to specify a list of values to ignore (as keys).
---@field keyallow table allows to specify the list of keys to be serialized. Any keys not in this list are not included in final output (as keys).
---@field keyignore table allows to specity the list of keys to ignore in serialization.
---@field valtypeignore table allows to specify a list of value types to ignore (as keys).
---@field custom function provide custom output for tables.
---@field name string name; triggers full serialization with self-ref section.
---@field inJson boolean Use a json syntax
---@field SimplifyUserdata boolean|nil Simplifies userdata to just display MyGuid, NetID, and DisplayName.

---Lua serializer and pretty printer.
---@class serpent:table
---@field block fun(tbl:table, options:serpent_options|nil):string multi-line indented pretty printing, no self-ref section; sets indent, sortkeys, and comment options
---@field dump fun(tbl:table, options:serpent_options|nil):string full serialization; sets name, compact and sparse options
---@field line fun(tbl:table, options:serpent_options|nil):string single line pretty printing, no self-ref section; sets sortkeys and comment options
---@field load fun(data:string, options:serpent_options|nil):table Load a serpent-serialized string as a table.
return { 
	_NAME = n,
	_COPYRIGHT = c,
	_DESCRIPTION = d,
	_VERSION = v,
	serialize = s,
	load = deserialize,
	--dump = function(a, opts) return s(a, merge({name = '_', compact = true, sparse = true}, opts)) end,
	dump = function(a, opts) return s(a, merge({compact = false, sparse = false, indent = '\t', comment = false, SimplifyUserdata = true, nocode = true}, opts)) end,
	line = function(a, opts) return s(a, merge({sortkeys = true, comment = false, SimplifyUserdata = true, nocode = true}, opts)) end,
	block = function(a, opts) return s(a, merge({indent = '\t', sortkeys = true, comment = false, SimplifyUserdata = true, nocode = true}, opts)) end,
	raw = function(a, opts) return s(a, merge({}, opts)) end,
}
								