ScriptManager = {
	RegisteredListenerLookup = {},
	---@type table<string, CallbackHandler[]>
	RegisteredHandlers = {},
}
ScriptManager.__index = ScriptManager

local function GetIsRegistered(name, arity)
	return ScriptManager.RegisteredListenerLookup[name] ~= nil and ScriptManager.RegisteredListenerLookup[name][arity] ~= nil
end

local function SetIsRegistered(name, arity)
	if not ScriptManager.RegisteredListenerLookup[name] then
		ScriptManager.RegisteredListenerLookup[name] = {}
	end
	ScriptManager.RegisteredListenerLookup[name][arity] = true
end

local function InvokeHandlers(name, ...)
	local callbacks = ScriptManager.RegisteredHandlers[name]
	local length = callbacks and #callbacks or 0
	if length > 0 then
		for i=1,length do
			local callback = callbacks[i]
			local b,err = xpcall(callback.Invoke, debug.traceback, callback, ...)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
end

--- Registers a handler that is invoked when an Osiris listener is called, but only the gamestate is running.
--- Supports events, built-in queries, DBs, PROCs, QRYs (user queries).
--- @param name string Osiris function/database name
--- @param handler CallbackHandler The handler to invoke. Handlers allow conditional invoking, i.e. only if a character is alive, or if some other condition is met.
--- @param arity number|nil Number of parameters for the listener. Automatically determined by the handler.Callback's args if nil.
--- @param event string|nil Event type ('before' - triggered before Osiris call; 'after' - after Osiris call; 'beforeDelete'/'afterDelete' - before/after delete from DB). "after" by default.
function ScriptManager.RegisterHandler(name, handler, arity, event)
	event = event or "after"
	arity = arity or debug.getinfo(handler.Callback)
	if not GetIsRegistered(name, arity) then
		ScriptManager.RegisteredHandlers[name] = {}
		Ext.RegisterOsirisListener(name, arity, event, function(...)
			if Ext.GetGameState() == "Running" then
				InvokeHandlers(name, ...)
			end
		end)
		SetIsRegistered(name, arity)
	end
	table.insert(ScriptManager.RegisteredHandlers[name], handler)
end

function ScriptManager.RemoveHandler(name, handler)
	local tbl = ScriptManager.RegisteredHandlers[name]
	if tbl then
		for i=1,#tbl do
			if tbl[i] == handler then
				table.remove(tbl, i)
				break
			end
		end
	end
end