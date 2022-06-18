local _EXTVERSION = Ext.Version()
local isClient = Ext.IsClient()

if _EXTVERSION >= 56 then
	local function SendDumpCommand(dumpType, synced, ...)
		if synced then
			return
		end
		local args = {...}
		if not isClient then
			GameHelpers.Net.PostMessageToHost("LeaderLib_Debug_RunDumpCommand", {
				Command = dumpType,
				Args = args
			})
		else
			Ext.PostMessageToServer("LeaderLib_Debug_RunDumpCommand", Common.JsonStringify({
				Command = dumpType,
				Args = args
			}))
		end
	end
	local _DUMP = {
		effect = function (...)
			if not isClient then
				if Ext.Effect then
					Ext.IO.SaveFile("Dumps/Effects.json", Ext.DumpExport(Ext.Effect.GetAllEffectHandles()))
					Ext.Print("[dump:effect] Saved effects to Dumps/Effects.json")
				else
					Ext.PrintWarning("[dump:effect] Ext.Effect is nil!")
				end
			else
				SendDumpCommand(...)
			end
		end,
		cc = function (...)
			if isClient then
				local wiz = Ext.UI.GetCharacterCreationWizard()
				if wiz then
					Ext.IO.SaveFile("Dumps/CC_Wizard.json", Ext.DumpExport(wiz))
					Ext.Print("[dump:cc] Saved data to Dumps/CC_Wizard.json")
				else
					Ext.PrintWarning("[dump:cc] No character creation wizard is available.")
				end
			else
				SendDumpCommand(...)
			end
		end,
		visual = function (...)
			if isClient then
				Ext.IO.SaveFile("Dumps/Visual.json", Ext.DumpExport(Client:GetCharacter().Visual))
				Ext.Print("[dump:visual] Saved visual data to Dumps/Visual.json")
			else
				SendDumpCommand(...)
			end
		end,
		character = function (dumpType, synced, filename)
			local fileName = string.format("Dumps/%s_%s.json", filename or "Character", isClient and "Client" or "Server")
			Ext.IO.SaveFile(fileName, Ext.DumpExport(isClient and Client:GetCharacter() or Ext.GetCharacter(CharacterGetHostCharacter())))
			Ext.Print("[dump:character] Saved character data to", fileName)
			SendDumpCommand(dumpType, synced, filename)
		end,
		uiext = function (dumpType, synced, filename)
			if isClient then
				local data = {
					UIExtensions = UIExtensions.Instance,
					CCExt = UIExtensions.CC.GetInstance(false) or "nil"
				}
				local callbacks = Listeners.DebugCommand.uiext
				if callbacks then
					for i,v in pairs(callbacks) do
						local b,err = xpcall(v, debug.traceback, dumpType, isClient, data)
						if not b then
							Ext.PrintError(err)
						end
					end
				end
				for id,v in pairs(Data.UIType) do
					if type(v) == "number" then
						local ui = Ext.GetUIByType(v)
						if ui then
							data[string.gsub(ui.Path, "G:/Divinity Original Sin 2/DefEd/Data/Public/Game/GUI/", "")] = ui
						end
					end
				end
				filename = "Dumps/" .. (filename or "UIExtensions.json")
				Ext.SaveFile(filename, Ext.DumpExport(data))
				fprint(LOGLEVEL.DEFAULT, "[dump:uiext] Saved UIExtensions data to %s", filename)
			else
				SendDumpCommand(dumpType, synced, filename)
			end
		end,
		modmanager = function (dumpType, synced, ...)
			if _EXTVERSION >= 56 then
				local fileName = string.format("Dumps/ModManager_%s.json", isClient and "Client" or "Server")
				Ext.IO.SaveFile(fileName, Ext.DumpExport(isClient and Ext.Client.GetModManager() or Ext.Server.GetModManager()))
				Ext.Print("[dump:modmanager] Saved mod manager data to",fileName)
				if not synced then
					SendDumpCommand(dumpType, true, ...)
				end
			end
		end,
		leaderlib_globals = function (dumpType, synced, ...)
			local tbl = {};
			local globalIndex = getmetatable(_ENV).__index
			for k,v in pairs(Mods.LeaderLib) do
				if k == "GameHelpers" or (not globalIndex[k] and not Importer.PrivateKeys[k]) then
					table.insert(tbl, {Name=k, Type=type(v)})
					if k == "GameHelpers" then
						for k2,v2 in pairs(v) do
							table.insert(tbl, {Name="GameHelpers." .. k2, Type=type(v2)})
						end
					end
				end
			end 
			table.sort(tbl, function(a,b)
				if a.Type == b.Type then 
					return a.Name < b.Name
				end 
				return a.Type > b.Type
			end) 
			local txt = "Name\tType\n" .. Mods.LeaderLib.StringHelpers.Join("\n", tbl, false, function(k,v)
				return string.format("%s\t%s", v.Name,v.Type)
			end)
			GameHelpers.IO.SaveFile(string.format("Dumps/LeaderLib_Globals_%s.tsv", isClient and "Client" or "Server"), txt)
			SendDumpCommand(dumpType, synced, ...)
		end
	}

	local function OnDumpCommand(cmd, dumpType, synced, ...)
		local args = {...}
		if type(synced) == "string" then
			table.insert(args, 1, synced)
			synced = false
		end
		dumpType = string.lower(dumpType or "")
		if dumpType == "" then
			return
		end
		for k,func in pairs(_DUMP) do
			if string.find(dumpType, k) then
				func(dumpType, synced, ...)
			end
		end
	end

	Ext.RegisterConsoleCommand("dump", OnDumpCommand)

	Ext.RegisterNetListener("LeaderLib_Debug_RunDumpCommand", function (netmsg, payload)
		local cmdData = Common.JsonParse(payload)
		if cmdData then
			OnDumpCommand("dump", cmdData.Command, true, table.unpack(cmdData.Args))
		end
	end)
end

Ext.RegisterConsoleCommand("modorder", function(command)
	fprint(LOGLEVEL.TRACE, "Mods [%s]", Ext.IsClient() and "CLIENT" or "SERVER")
	PrintDebug("=============")
	local mods = Ext.GetModLoadOrder()
	for i=1,#mods do
		local info = Ext.GetModInfo(mods[i])
		fprint(LOGLEVEL.TRACE, "[%i] %s (%s) [%s]", i, info and info.Name or "???", mods[i], info and info.ModuleType or "")
	end
	PrintDebug("=============")
end)