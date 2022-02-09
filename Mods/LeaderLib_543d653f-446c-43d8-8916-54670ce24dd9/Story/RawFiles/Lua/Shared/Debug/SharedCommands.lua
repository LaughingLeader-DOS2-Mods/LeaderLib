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
		character = function (dumpType, synced, ...)
			local fileName = string.format("Dumps/Character_%s.json", isClient and "Client" or "Server")
			if isClient then
				Ext.IO.SaveFile(fileName, Ext.DumpExport(isClient and Client:GetCharacter() or Ext.GetCharacter(CharacterGetHostCharacter())))
			else
				local data = {}
				local character = Ext.GetCharacter(CharacterGetHostCharacter())
				if character then
					for k,v in pairs(character) do
						data[k] = v
					end
				end
				data = TableHelpers.SanitizeTable(data, {["userdata"] = true, ["function"] = true})
				Ext.IO.SaveFile(fileName, Ext.DumpExport(data))
			end
			Ext.Print("[dump:character] Saved character data to",fileName)
			if not synced then
				SendDumpCommand(dumpType, true, ...)
			end
		end,
		uiext = function (...)
			if isClient then
				local data = {
					UIExtensions = UIExtensions.Instance,
					CCExt = UIExtensions.CC.GetInstance(false) or "nil"
				}
				if Mods.LLHotbarExtension then
					data.HotbarExt = Mods.LLHotbarExtension.HotbarExt.Instance
				end
				for id,v in pairs(Data.UIType) do
					if type(v) == "number" then
						local ui = Ext.GetUIByType(v)
						if ui then
							data[string.gsub(ui.Path, "G:/Divinity Original Sin 2/DefEd/Data/Public/Game/GUI/", "")] = ui
						end
					end
				end
				Ext.SaveFile("Dumps/UIExtensions.json", Ext.DumpExport(data))
				Ext.Print("[dump:uiext] Saved UIExtensions data to Dumps/UIExtensions.json")
			else
				SendDumpCommand(...)
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
		end
	}

	local function OnDumpCommand(cmd, dumpType, ...)
		dumpType = string.lower(dumpType or "")
		if dumpType == "" then
			return
		end
		for k,func in pairs(_DUMP) do
			if string.find(dumpType, k) then
				func(dumpType, ...)
			end
		end
	end

	Ext.RegisterConsoleCommand("dump", OnDumpCommand)

	Ext.RegisterNetListener("LeaderLib_Debug_RunDumpCommand", function (netmsg, payload)
		local cmdData = Common.JsonParse(payload)
		if cmdData then
			OnDumpCommand(cmdData.Command, table.unpack(cmdData.Args))
		end
	end)
end