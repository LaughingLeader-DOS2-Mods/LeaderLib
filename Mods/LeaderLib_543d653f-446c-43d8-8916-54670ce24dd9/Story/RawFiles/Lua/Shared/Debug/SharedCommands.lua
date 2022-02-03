local _EXTVERSION = Ext.Version()
local isClient = Ext.IsClient()

if _EXTVERSION >= 56 then
	local function SendDumpCommand(...)
		if not isClient then
			GameHelpers.Net.PostMessageToHost("LeaderLib_Debug_RunDumpCommand", {
				Command = "dump",
				Args = {...},
			})
		else
			Ext.PostMessageToServer("LeaderLib_Debug_RunDumpCommand", Common.JsonStringify({
				Command = "dump",
				Args = {...},
			}))
		end
	end
	local _DUMP = {
		effect = function (...)
			if not isClient then
				if Ext.Effect then
					Ext.IO.SaveFile("Dumps/Effects.json", Ext.DumpExport(Ext.Effect.GetAllEffectHandles()))
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
				else
					Ext.PrintWarning("[dump:cc] No character creation wizard is available.")
				end
			else
				SendDumpCommand(...)
			end
		end
	}

	local function OnDumpCommand(cmd, dumpType, ...)
		dumpType = string.lower(dumpType or "")
		if dumpType == "" then
			return
		end
		for k,func in pairs(_DUMP) do
			if string.find(k, dumpType) then
				func(dumpType, ...)
			end
		end
	end

	Ext.RegisterConsoleCommand("dump", OnDumpCommand)

	Ext.RegisterNetListener("LeaderLib_Debug_RunDumpCommand", function (net, payload)
		local cmdData = Common.JsonParse(payload)
		if cmdData then
			OnDumpCommand(cmdData.Command, table.unpack(cmdData.Args))
		end
	end)
end