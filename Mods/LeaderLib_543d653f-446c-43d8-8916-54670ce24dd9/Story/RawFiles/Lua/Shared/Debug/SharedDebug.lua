local _ISCLIENT = Ext.IsClient()

--[[ Events.SummonChanged:Subscribe(function (e)
	if Vars.LeaderDebugMode then
		e:Dump()
		-- if type(e.Summon) == "userdata" then
		-- 	if not e.IsItem then
		-- 		fprint(LOGLEVEL.DEFAULT, "[OnSummonChanged:Character(%s)] Summon(%s)[%s] Totem(%s) Owner(%s) IsDying(%s) isItem(false)", _ISCLIENT and "CLIENT" or "SERVER", GameHelpers.Character.GetDisplayName(e.Summon), e.Summon.NetID, not _ISCLIENT and e.Summon.Totem or e.Summon:HasTag("TOTEM"), GameHelpers.Character.GetDisplayName(e.Owner), e.IsDying)
		-- 		--fprint(LOGLEVEL.WARNING, "Dead(%s) Deactivated(%s) CannotDie(%s) DYING(%s)", e.Summon.Dead, e.Summon.Deactivated, e.Summon.CannotDie, e.Summon:GetStatus("DYING") and e.Summon:GetStatus("DYING").Started or "false")
		-- 	else
		-- 		fprint(LOGLEVEL.DEFAULT, "[OnSummonChanged:Item(%s)] Summon(%s) StatsId(%s) Owner(%s) IsDying(%s) IsItem(true)", _ISCLIENT and "CLIENT" or "SERVER",GameHelpers.Character.GetDisplayName(e.Summon), e.Summon.StatsId, GameHelpers.Character.GetDisplayName(e.Owner), e.IsDying)
		-- 	end
		-- else
		-- 	fprint(LOGLEVEL.DEFAULT, "[OnSummonChanged:Character(%s)] Summon(%s) Owner(%s) IsDying(%s) IsItem(false)", _ISCLIENT and "CLIENT" or "SERVER",e.Summon, GameHelpers.Character.GetDisplayName(e.Owner), e.IsDying)
		-- end
		local summons = nil

		if not _ISCLIENT then
			summons = GameHelpers.Character.GetSummons(e.Owner, true, true, {[e.Summon.MyGuid]=true})
		else
			summons = GameHelpers.Character.GetSummons(e.Owner, true, true, {[e.Summon.NetID]=true})
		end
	
		local len = #summons
		if len > 0 then
			fprint(LOGLEVEL.DEFAULT, "Summons(%s)", _ISCLIENT and "CLIENT" or "SERVER")
			fprint(LOGLEVEL.DEFAULT, "========")
			for i=1,len do
				local summon = summons[i]
				fprint(LOGLEVEL.DEFAULT, "[%s] NetID(%s)", GameHelpers.Character.GetDisplayName(summon), GameHelpers.GetNetID(summon))
			end
			fprint(LOGLEVEL.DEFAULT, "========")
		end
	end
end) ]]

-- if _ISCLIENT then
-- 	Events.ClientCharacterChanged:Subscribe(function (e)
-- 		e:Dump()
-- 	end)
-- end

--[[ Ext.Events.SessionLoaded:Subscribe(function (e)
	if not _ISCLIENT then
		local function SetWalkthrough(character, b)
			character.WalkThrough = b
			character.CanShootThrough = b
			character.RootTemplate.CanShootThrough = b
			character.RootTemplate.WalkThrough = b
			GameHelpers.Net.Broadcast("LeaderLib_Debug_SetWalkthrough", {Target=character.NetID, Enabled=b})
		end
		StatusManager.Subscribe.Applied("SNEAKING", function (e)
			SetWalkthrough(e.Target, true)
		end)
		StatusManager.Subscribe.Removed("SNEAKING", function (e)
			SetWalkthrough(e.Target, false)
		end)
	else
		Ext.RegisterNetListener("LeaderLib_Debug_SetWalkthrough", function (channel, payload, user)
			local data = Common.JsonParse(payload)
			local character = data and GameHelpers.GetCharacter(data.Target) or nil
			if character then
				character.WalkThrough = data.Enabled == true
				character.CanShootThrough = data.Enabled == true
				fprint(LOGLEVEL.ERROR, "[LeaderLib_Debug_SetWalkthrough] character.WalkThrough(%s)", character.WalkThrough)
			end
		end)
	end
end) ]]

-- Events.OnBookRead:Subscribe(function (e)
-- 	Ext.Print(_ISCLIENT and "CLIENT" or "SERVER", e:DumpExport())
-- end)

--[[ if _ISCLIENT then
	local lastCursorPos = {}
	local function HasTotem()
		for summon in GameHelpers.Character.GetSummons(Client:GetCharacter(), false) do
			print(summon, summon:HasTag("TOTEM"))
			if summon:HasTag("TOTEM") then
				return true
			end
		end
		return false
	end
	Ext.Events.SessionLoaded:Subscribe(function (e)
		local totemAction = Classes.ContextMenuAction:Create({
			ID = "LeaderLib_Debug_TransformTotems",
			AutomaticallyAddToBuiltin = true,
			DisplayName = "Transform Totems",
			ShouldOpen = function (cm, x, y)
				local cursor = Ext.UI.GetPickingState()
				if cursor and cursor.WalkablePosition then
					local x,y,z = table.unpack(cursor.WalkablePosition)
					local surfaces = GameHelpers.Grid.GetSurfaces(x, z)
					if surfaces.Ground then
						lastCursorPos = {x,y,z}
						return Client:GetCharacter():HasTag("LeaderLib_HasTotem")
					end
				end
				return false
			end,
			Callback = function ()
				local x,y,z = table.unpack(lastCursorPos)
				if x and z then
					Ext.Net.PostMessageToServer("LeaderLib_ContextMenu_Debug_TransformTotems", Common.JsonStringify({X=x,Z=z}))
				end
				lastCursorPos = {}
			end
		})
		UI.ContextMenu.Register.Action(totemAction)
	end)
else
	Events.SummonChanged:Subscribe(function (e)
		if e.Summon:HasTag("TOTEM") then
			if not e.IsDying then
				CharacterSetSummonLifetime(e.Summon.MyGuid, 99999)
				SetTag(e.Owner.MyGuid, "LeaderLib_HasTotem")
			else
				local ownerGUID = e.Owner.MyGuid
				local timerName = string.format("LeaderLib_Debug_CheckForTotems", ownerGUID)
				Timer.StartOneshot(timerName, 500, function (e)
					local hasTotem = false
					for summon in GameHelpers.Character.GetSummons(ownerGUID, false) do
						if summon:HasTag("TOTEM") then
							hasTotem = true
							break
						end
					end
					if not hasTotem then
						ClearTag(ownerGUID, "LeaderLib_HasTotem")
					end
				end)
			end
		end
	end)
	Ext.RegisterNetListener("LeaderLib_ContextMenu_Debug_TransformTotems", function (channel, payload, user)
		local data = Common.JsonParse(payload)
		if data.X and data.Z then
			local flags = Ext.Entity.GetAiGrid():GetAiFlags(data.X, data.Z)
			local surface = GameHelpers.Grid.GetSurfaceFromAiFlags(flags)
			local surfaceTemplate = Ext.Surface.GetTemplate(surface)
			if surfaceTemplate and not StringHelpers.IsNullOrEmpty(surfaceTemplate.Summon) then
				local template = Ext.Template.GetRootTemplate(surfaceTemplate.Summon)
				if template then
					local host = GameHelpers.GetCharacter(CharacterGetHostCharacter())
					for summon in GameHelpers.Character.GetSummons(host, false) do
						if summon:HasTag("TOTEM") and GameHelpers.GetTemplate(summon) ~= template.Id then
							---@cast summon EsvCharacter
							fprint(LOGLEVEL.DEFAULT, "[TransformTotems] Transforming from (%s) to (%s)[%s] Stats(%s)", GameHelpers.GetTemplate(summon), template.Name, template.Id, template.Stats)
							summon:TransformTemplate(template)
							local level = math.max(summon.Stats.Level, host.Stats.Level)
							local flags = {}
							for _,v in pairs(summon.Flags) do
								if v ~= "HasOwner" then
									flags[#flags+1] = v
								end
							end
							summon.Flags = flags
							GameHelpers.Character.SetStats(summon, template.Stats)
							GameHelpers.Character.SetEquipment(summon, template.Equipment)
							GameHelpers.Status.Apply(summon, "LEADERLIB_VISUALS_RESET", 0)
							local summonGUID = summon.MyGuid
							Timer.StartOneshot("", 250, function (e)
								local summon = GameHelpers.GetCharacter(summonGUID)
								GameHelpers.Character.SetLevel(summon, level, true)
							end)
							Timer.StartOneshot("", 700, function (e)
								local summon = GameHelpers.GetCharacter(summonGUID)
								local flags = {}
								for _,v in pairs(summon.Flags) do
									if v ~= "HasOwner" then
										flags[#flags+1] = v
									else
										return
									end
								end
								flags[#flags+1] = "HasOwner"
								summon.Flags = flags
							end)
							--CharacterTransform(summon.MyGuid, template.Id, 0, 1, 1, 1, 1, 0, 0)
						end
					end
				end
			end
		end
	end)
end ]]