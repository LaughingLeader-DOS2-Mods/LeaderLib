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
-- 	Ext.Utils.Print(_ISCLIENT and "CLIENT" or "SERVER", e:DumpExport())
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
							summon.HasOwner = false
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
								summon.HasOwner = true
							end)
						end
					end
				end
			end
		end
	end)
end ]]

--[[ local CivilAbility = {
	Telekinesis = 20,
	Repair = 21,
	Sneaking = 22,
	Pickpocket = 23,
	Thievery = 24,
	Loremaster = 25,
	Crafting = 26,
	Barter = 27,
	Charm = 28,
	Intimidate = 29,
	Reason = 30,
	Persuasion = 31,
	Luck = 33,
	Runecrafting = 37,
	Brewmaster = 38,
}

local function AddPoints(entries, maxAmount, currentAmount)
	local remaining = maxAmount - currentAmount
	local len = #entries
	local bonusAmount = Ext.Utils.Round(remaining/len)
	if bonusAmount > 0 then
		for i=1,len do
			local entry = entries[i]
			if bonusAmount > remaining then
				bonusAmount = remaining
			end
			entry.AmountIncreased = entry.AmountIncreased + bonusAmount
			remaining = remaining - bonusAmount
			if remaining <= 0 then
				break
			end
		end
	end
end

local MAX_ABILITY = 10
local MAX_CIVIL_ABILITY = 5
local MAX_ATTRIBUTE = 10

local function AddPointsToPresets()
	local cc = Ext.Stats.GetCharacterCreation()
	for _,preset in pairs(cc.ClassPresets) do
		if not string.find(preset.ClassType, "_Act2") then
			---@type CharacterCreationAbilityChange[]
			local combatAbilityEntries = {}
			---@type CharacterCreationAbilityChange[]
			local civilAbilityEntries = {}

			for _,v in pairs(preset.AbilityChanges) do
				if CivilAbility[v.Ability] then
					civilAbilityEntries[#civilAbilityEntries+1] = v
				else
					combatAbilityEntries[#combatAbilityEntries+1] = v
				end
			end

			if preset.NumStartingCombatAbilityPoints < MAX_ABILITY then
				AddPoints(combatAbilityEntries, MAX_ABILITY, preset.NumStartingCombatAbilityPoints)
				preset.NumStartingCombatAbilityPoints = MAX_ABILITY
			end

			if preset.NumStartingCivilAbilityPoints < MAX_CIVIL_ABILITY then
				AddPoints(civilAbilityEntries, MAX_CIVIL_ABILITY, preset.NumStartingCivilAbilityPoints)
				preset.NumStartingCivilAbilityPoints = MAX_CIVIL_ABILITY
			end

			if preset.NumStartingAttributePoints < MAX_ATTRIBUTE then
				AddPoints(preset.AttributeChanges, MAX_ATTRIBUTE, preset.NumStartingAttributePoints)
				preset.NumStartingAttributePoints = MAX_ATTRIBUTE
			end
		end
	end
end

Ext.Events.StatsLoaded:Subscribe(function (e)
	AddPointsToPresets()
end)

Ext.Events.ResetCompleted:Subscribe(function (e)
	AddPointsToPresets()
end) ]]

--[[ Ext.Events.SessionLoaded:Subscribe(function (e)
	local testTask = Classes.UserTask:Create("TEST_TASK")
	testTask.HasValidTarget = function (self)
		return Ext.Utils.IsValidHandle(Ext.UI.GetPickingHelper().HoverDeadCharacterHandle)
	end
	testTask:SetCallbacks({
		CanEnter = function (self)
			return testTask.Enabled and testTask:HasValidTarget()
		end,
		SetCursor = function (self)
			local cc = Ext.UI.GetCursorControl()
			if self.Running then
					cc.MouseCursor = "CursorItemMove"
				
				if userAction.HasValidTargetPos() then
					cc.RequestedFlags = 0x30
					ClearCursorText()
				else
					cc.RequestedFlags = 0x10
					SetCursorText("<font color=\"#C80030\">BAD BAD BAD!!!</font>")
				end
			elseif self.Previewing then
					cc.MouseCursor = "CursorShovel"
			else
					cc.MouseCursor = "CursorSystem"
			end
		end,
	})
	testTask:Register()
end) ]]

-- local baseHeal = Ext.Utils.Round(Ext.Stats.GetStatsManager().LevelMaps:GetByName("SkillData HealAmount"):GetScaledValue(Ext.Stats.Get("REGENERATION").HealValue, _C().Stats.Level)); local mult = math.ceil(_C().Stats.WaterSpecialist * Ext.ExtraData.SkillAbilityVitalityRestoredPerPoint); print(baseHeal, mult, baseHeal + Ext.Utils.Round(math.ceil((mult * baseHeal) / 100) * 1.0))
--[[ if not _ISCLIENT then
	Events.OnHeal:Subscribe(function (e)
		--e.Status.HealAmount = GameHelpers.Status.GetHealAmount("BODYPART_HEAL", {ApplyAbilityBoost=false, Target=e.Target.Stats})
		e.Status.HealAmount = 100
	end, {MatchArgs={StatusId="REGENERATION"}})
end ]]


-- Ext.Events.SessionLoaded:Subscribe(function (e)
-- 	if _ISCLIENT then
-- 		GameHelpers.Net.Subscribe("LLTEST_CheckLifeSteal", function (e, data)
-- 			Ext.OnNextTick(function (e)
-- 				local character = GameHelpers.GetCharacter(data.NetID)
-- 				GameHelpers.IO.SaveFile("Dumps/HEAL_Client.json", Ext.DumpExport(character:GetStatus("HEAL")))
-- 			end)
-- 		end)
-- 	else
-- 			--[[ Events.OnHeal:Subscribe(function (e)
-- 			if e.Heal.StatusId == "LIFESTEAL" then
-- 				print(e.Heal.HealAmount)
-- 				e.Heal.HealAmount = 10
-- 			end
-- 		end, {Priority=0})

-- 		Events.OnHit:Subscribe(function (e)
-- 			if e.HitStatus.Hit.LifeSteal > 0 then
-- 				e.Data:SetLifeSteal(10)
-- 				Ext.Utils.PrintError(e.Data.HitRequest.LifeSteal)
-- 			end
-- 		end, {Priority=0})
-- 		]]

-- 		--[[ Ext.Osiris.RegisterListener("NRD_OnHeal", 4, "after", function (target, source, amount, handle)
-- 			local status = Ext.Entity.GetStatus(target, handle)
-- 			if status.StatusId == "HEAL" then
-- 				local character = GameHelpers.GetCharacter(target)
-- 				status.HealAmount = 100
-- 				local regen = character:GetStatus("REGENERATION")
-- 				if regen then
-- 					regen.HealAmount = 100
-- 				end
-- 				GameHelpers.Net.Broadcast("LLTEST_CheckLifeSteal", {NetID=character.NetID})
-- 				GameHelpers.IO.SaveFile("Dumps/HEAL_Server.json", Ext.DumpExport(status))
-- 			end
-- 		end) ]]

-- 		local HEAL_TEST = 100

-- 		StatusManager.Subscribe.BeforeAttempt("REGENERATION", function (e)
-- 			HEAL_TEST = Ext.Utils.Random(50, 700)
-- 		end)

-- 		Events.OnHeal:Subscribe(function (e)
-- 			if e.StatusId == "HEAL" then
-- 				e.Heal.HealAmount = HEAL_TEST
-- 				local regen = e.Target:GetStatus("REGENERATION")
-- 				if regen then
-- 					regen.HealAmount = e.Heal.HealAmount
-- 					if GameHelpers.Ext.ObjectIsCharacter(e.Source) then
-- 						local bonus = (Ext.ExtraData.SkillAbilityWaterDamageBoostPerPoint * e.Source.Stats.WaterSpecialist) * 0.01
-- 						if bonus > 0 then
-- 							local mult = (1 - bonus) + 0.03
-- 							regen.HealAmount = Ext.Utils.Round(e.Heal.HealAmount * mult)
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end)

-- 		--[[ Ext.Events.StatusHitEnter:Subscribe(function (e)
-- 			if e.Hit.Hit.LifeSteal > 0 then
-- 				e.Hit.Hit.LifeSteal = 100
-- 				e:StopPropagation()
-- 			end
-- 		end, {Priority=9999999}) ]]

-- 		--[[ Ext.Events.BeforeCharacterApplyDamage:Subscribe(function (e)
-- 			if e.Hit.LifeSteal > 0 then
-- 				e.Hit.LifeSteal = 777
-- 			end
-- 		end) ]]
-- 	end
-- end)

--[[ if _ISCLIENT then
	Events.ModVersionLoaded:Subscribe(function (e)
		e:Dump()
	end)
end ]]

--[[ Ext.RegisterConsoleCommand("debugitertest", function (cmd, ...)
	local character = Ext.IsClient() and Client:GetCharacter() or GameHelpers.Character.GetHost()
	local pos = character.WorldPos
	local level = Ext.Entity.GetCurrentLevel()
	Ext.Utils.Print("[debugitertest] ", Ext.IsClient() and "CLIENT" or "SERVER")
	local time = Ext.Utils.MonotonicTime()
	local items = level.EntityManager.ItemConversionHelpers.RegisteredItems[level.LevelDesc.LevelName]
	local len = #items
	Ext.Utils.Print("RegisteredItems:", len)
	for i=1,len do
		local item = items[i]
		if Ext.Math.Distance(item.WorldPos, pos) <= 30 then
			--Nearby
		end
	end
	Ext.Utils.Print("Iteration took", Ext.Utils.MonotonicTime() - time, "ms")
	time = Ext.Utils.MonotonicTime()
	local items = level.EntityManager.ItemConversionHelpers.ActivatedItems[level.LevelDesc.LevelName]
	local len = #items
	Ext.Utils.Print("ActivatedItems:", len)
	local distances = {}
	for i=1,len do
		local item = items[i]
		distances[#distances+1] = {Name=GameHelpers.GetDisplayName(item), Distance=Ext.Math.Distance(item.WorldPos, pos),
		MyGuid=item.MyGuid,
		ForceSync=item.ForceSync == true and true or nil,}
	end
	Ext.Utils.Print("Iteration took", Ext.Utils.MonotonicTime() - time, "ms")
	table.sort(distances, function(a,b) return a.Distance < b.Distance end)
	Ext.IO.SaveFile("Dumps/ActivatedItems_Server.json", Ext.DumpExport(distances))
end) ]]

--[[
Ext.Events.Tick:Subscribe(function (e) local host = Mods.LeaderLib.GameHelpers.Character.GetHost(); for obj in Mods.LeaderLib.GameHelpers.Grid.GetNearbyObjects(host, {Type="Item", Radius=10}) do end end)
]]

--Ext.Events.Tick:Subscribe(function (e) local host = Mods.LeaderLib.GameHelpers.Character.GetHost(); for obj in Mods.LeaderLib.GameHelpers.Grid.GetNearbyObjects(host, {Type="Item", Radius=10, ActivatedOnly=true}) do end end)
--for i=0,50 do Ext.Events.Tick:Subscribe(function (e) local host = Mods.LeaderLib.GameHelpers.Character.GetHost(); for obj in Mods.LeaderLib.GameHelpers.Grid.GetNearbyItemsFast(host, 10) do end end) end
--for i=0,1000 do Ext.Events.Tick:Subscribe(function (e) for _,v in pairs(_C():GetNearbyCharacters(10)) do end end) end
--for i=0,500 do Ext.Events.Tick:Subscribe(function (e) local x,y,z = table.unpack(_C().WorldPos); Ext.Entity.GetItemGuidsAroundPosition(x,y,z,30) end) end

--for i=0,100 do Ext.Events.Tick:Subscribe(function (e) local pos = _C().WorldPos; local l = Ext.Entity.GetCurrentLevel() for _,v in pairs(l.EntityManager.ItemConversionHelpers.RegisteredItems[l.LevelDesc.LevelName]) do Ext.Math.Distance(pos, v.WorldPos) end end) end

--[[ if not _ISCLIENT then
	local hitLogTest = Classes.LuaTest:Create("hitlog", {
		---@param self LuaTest
		function(self)
			local host = GameHelpers.Character.GetHost().MyGuid
			local characters,_,cleanup = Testing.Utils.CreateTestCharacters({AutoPositionStartDistance=10, TotalCharacters=2, TotalDummies=0, EquipmentSet="Class_Wizard_Act2"})
			local c1,c2 = table.unpack(characters)
			self:Wait(500)
			Osi.SetFaction(c1, "Evil")
			Osi.SetFaction(c2, "Evil")
			local hitListenerIndex = nil
			local pos = GameHelpers.Math.GetPosition(c2)
			self.Cleanup = function (self)
				cleanup()
				Ext.Events.GetHitChance:Unsubscribe(hitListenerIndex)
				GameHelpers.Surface.CreateSurface(pos, "None", 24)
			end
			Osi.SetTag(c2, "LLDEBUG_AutoDodge")
			GameHelpers.Net.Broadcast("LeaderLib_Test_Debug_CheckHitStatus", {Target=GameHelpers.GetNetID(c2)})
			hitListenerIndex = Ext.Events.GetHitChance:Subscribe(function (e)
				if e.Target.Character:HasTag("LLDEBUG_AutoDodge") then
					e.HitChance = 0
					--e.HitStatus.HitReason = 3
				end
			end)
			Osi.TeleportToRandomPosition(c1, 12, "")
			self:Wait(500)
			Osi.SetCanJoinCombat(c1, 1)
			Osi.SetCanJoinCombat(c2, 1)
			Osi.SetCanFight(c1, 1)
			Osi.SetCanFight(c2, 1)
			self:Wait(500)
			Osi.EnterCombat(c1, c2)
			Osi.EnterCombat(c1, host)
			GameHelpers.Action.Attack(c1, c2)
			self:Wait(5000)
			return true
		end,
	},{
		CallCleanupAfterEachTask = true
	})
	Testing.RegisterConsoleCommandTest(hitLogTest.ID, hitLogTest, "Test some odd NPC-only messages.")
else
	local _hitStatusTarget = nil
	local _tickIndex = nil

	local function _OnTick()
		if _hitStatusTarget then
			local target = GameHelpers.GetCharacter(_hitStatusTarget, "EclCharacter")
			if target then
				for _,status in pairs(target.StatusMachine.Statuses) do
					if status and status.StatusId == "HIT" then
						---@cast status EclStatusHit
						fprint(LOGLEVEL.TRACE, "[EclStatusHit] HitByType(%s) HitReason(%s) Dodged(%s)", status.HitByType, status.HitReason, status.DamageInfo.Dodged)
						-- if status.DamageInfo.Dodged then
						-- 	status.HitByType = 24
						-- 	status.HitReason = 3
						-- end
						status.HitByType = 24
						status.HitReason = 3
						status.DamageInfo.Dodged = true
					end
				end
			else
				Ext.Events.Tick:Unsubscribe(_tickIndex)
				_tickIndex = nil
			end
		end
	end

	GameHelpers.Net.Subscribe("LeaderLib_Test_Debug_CheckHitStatus", function (e, data)
		print("LeaderLib_Test_Debug_CheckHitStatus", Ext.DumpExport(data))
		_hitStatusTarget = data.Target
		if _tickIndex == nil then
			_tickIndex = Ext.Events.Tick:Subscribe(_OnTick)
		end
	end)
end ]]