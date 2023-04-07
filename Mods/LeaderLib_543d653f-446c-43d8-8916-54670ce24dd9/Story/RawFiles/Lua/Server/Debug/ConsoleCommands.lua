local MessageData = Classes.MessageData

local function ResetLua()
	if not Ext.Debug.IsDeveloperMode() then
		error("!luareset can only be reset in developer mode. True reset instead", 2)
	end
	local varData = {
		_PrintSettings = Vars.Print,
		_CommandSettings = Vars.Commands,
	}
	
	for name,data in pairs(Mods) do
		if data.PersistentVars ~= nil then
			local b,err = xpcall(Common.JsonStringify, debug.traceback, data.PersistentVars)
			if not b then
				Ext.Utils.PrintError("Error stringifying PersistentVars for", name)
				local checkTable = nil
				checkTable = function(tbl,space)
					for k,v in pairs(tbl) do
						if type(k) == "userdata" or type(v) == "userdata" then
							Ext.Utils.PrintError(string.format("%s%s",space,k),v)
						elseif type(v) == "table" then
							Ext.Utils.PrintError(string.format("%s%s",space,k))
							checkTable(v,space .. " ")
						end
					end
				end
				checkTable(data.PersistentVars, "")
			end
			varData[name] = TableHelpers.SanitizeTable(data.PersistentVars, nil, true)
		end
	end
	if varData ~= nil then
		GameHelpers.IO.SaveJsonFile("LeaderLib_Debug_PersistentVars.json", varData)
	end
	Osi.TimerCancel("Timers_LeaderLib_Debug_LuaReset")
	Osi.GlobalSetFlag("LeaderLib_ResettingLua")
	Osi.TimerLaunch("Timers_LeaderLib_Debug_LuaReset", 500)
	fprint(LOGLEVEL.TRACE, "[LeaderLib:luareset] Reseting lua.")
	Osi.NRD_LuaReset(1,1,1)
	Vars.JustReset = true
end

local function OnLuaResetCommand(cmd, delay)
	if delay == "" then
		delay = nil
	end
	Vars.Resetting = true
	Events.BeforeLuaReset:Invoke({})
	--GameHelpers.Net.Broadcast("LeaderLib_Client_InvokeListeners", "BeforeLuaReset")
	delay = delay or 1000
	fprint(LOGLEVEL.WARNING, "[LeaderLib:luareset] Resetting lua after (%s) ms", delay)
	if delay ~= nil then
		delay = tonumber(delay)
		if delay > 0 then
			Osi.TimerLaunch("Timers_LeaderLib_Debug_ResetLua", delay)
		else
			ResetLua()
		end
	else
		ResetLua()
	end
end

Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function (timerName)
	if timerName == "Timers_LeaderLib_Debug_ResetLua" then
		ResetLua()
	end
end)

Ext.RegisterConsoleCommand("luareset", OnLuaResetCommand)
Ext.RegisterNetListener("LeaderLib_Client_RequestLuaReset", OnLuaResetCommand)

Ext.RegisterConsoleCommand("pos", function()
	---@type StatCharacter
	local character = Osi.CharacterGetHostCharacter()
	fprint("Pos:", Osi.GetPosition(character))
	fprint("Rot:", Osi.GetRotation(character))
end)

Ext.RegisterConsoleCommand("pos2", function()
	local character = GameHelpers.Character.GetHost()
	fprint("Position:", Common.JsonStringify(character.WorldPos))
	fprint("Rotation:", Common.JsonStringify(character.Rotation))
end)

Ext.RegisterConsoleCommand("printuuids", function(call, radiusVal, skipSelfParam, charactersOnlyParam)
	local skipSelf = false
	local charactersOnly = false
	if skipSelfParam == true or skipSelfParam == "true" then
		skipSelf = true
	end
	if charactersOnlyParam == true or charactersOnlyParam == "true" then
		charactersOnly = true
	end
	local radius = 6.0
	if radiusVal ~= nil then
		radius = tonumber(radiusVal) or 6.0
	end
	local host = StringHelpers.GetUUID(Osi.CharacterGetHostCharacter())
	local characters = nil
	if radius < 0 then
		characters = Ext.Entity.GetAllCharacterGuids()
	else
		characters = GameHelpers.GetCharacter(host):GetNearbyCharacters(radius)
	end
	for i,uuid in pairs(characters) do
		if skipSelf and uuid == host then
			--Skip
		else
			---@type EsvCharacter
			local character = GameHelpers.GetCharacter(uuid)
			---@type StatCharacter
			local characterStats = character.Stats
	
			print("CHARACTER")
			print("===============")
			print("UUID:", uuid)
			print("NetID:", character.NetID)
			print("Name:", character.DisplayName)
			print("Stat:", characterStats.Name)
			print("Faction:", character.RootTemplate.CombatTemplate.Alignment)
			print("Archetype:", character.Archetype)
			print("Pos:", table.unpack(character.WorldPos))
			print("Rot:", table.unpack(character.Rotation))
			print("CustomTradeTreasure:", Common.Dump(character.CustomTradeTreasure))
			print("Gain:", GameHelpers.Stats.GetAttribute(character.Stats.Name, "Gain"))
			print("===============")
		end
	end
	if charactersOnly ~= true then
		local items = nil
		if radius < 0 then
			items = Ext.Entity.GetAllItemGuids()
		else
			items = {}
			for _,v in pairs(Ext.Entity.GetAllItemGuids()) do
				if Osi.GetDistanceTo(v, host) <= radius then
					items[#items+1] = v
				end
			end
		end
		for i,uuid in pairs(items) do
			---@type EsvItem
			local item = GameHelpers.GetItem(uuid)
			print("ITEM")
			print("===============")
			print("UUID:", uuid)
			print("NetID:", item.NetID)
			print("Name:", item.DisplayName)
			print("StatsId:", item.StatsId)
			print("Pos:", table.unpack(item.WorldPos))
			print("Rot:", Osi.GetRotation(item.MyGuid))
			print("===============")
		end
	end
end)

--!teleport "c099caa6-1938-4b4f-9365-d0881c611e71"

Ext.RegisterConsoleCommand("teleport", function(cmd,target,param2,param3)
	local host = Osi.CharacterGetHostCharacter()
	if param2 == "host" then param2 = host end
	if param3 == "host" then param3 = host end

	fprint(LOGLEVEL.TRACE, cmd,target,param2,param3)

	if param2 == nil or param3 == nil then
		if Osi.ObjectExists(target) == 1 then
			fprint(LOGLEVEL.TRACE, "Teleporting (%s) to (%s)[%s]",host,target,StringHelpers.Join(";", GameHelpers.Math.GetPosition(target)))
			Osi.TeleportTo(host, target)
		else
			fprint(LOGLEVEL.TRACE, "Target (%s) does not exist", target)
		end
	else
		local x = tonumber(target)
		if x ~= nil then
			local y = tonumber(param2)
			local z = tonumber(param3)

			if y ~= nil and z ~= nil then
				Osi.TeleportToPosition(target, x, y, z, "", 1, 0)
			end
		else
			fprint(LOGLEVEL.TRACE, "[teleport] Failed to parse position?")	
		end
	end
end)

Ext.RegisterConsoleCommand("movie", function(command,movie)
	if movie == nil then
		movie = "Splash_Logo_Larian"
	end
	local host = Osi.CharacterGetHostCharacter()
	Osi.MoviePlay(host,movie)
end)

-- !statusapply LLLICH_DOMINATED 18.0 1 145810cc-7e46-43e7-9fdf-ab9bb8ffcdc0 host
-- !statusapply LLLICH_DOMINATED_BEAM_FX 0.0 1 145810cc-7e46-43e7-9fdf-ab9bb8ffcdc0 host
-- !statusapply MADNESS 12.0 1 319_31dc549d-dfc0-4558-821a-5e3d468e5b1a host
Ext.RegisterConsoleCommand("statusapply", function(command,status,duration,force,target,source)
	local host = Osi.CharacterGetHostCharacter()
	if target == nil or target == "host" then
		target = host
	end
	if source == nil or source == "host" then
		source = host
	end
	if duration == nil then
		duration = 18.0
	else
		duration = tonumber(duration)
	end
	if force == nil then
		force = 0
	else
		force = tonumber(force)
	end
	if status == nil then
		status = "HASTED"
	end
	local character = GameHelpers.GetCharacter(host)
	if character.CannotDie or GameHelpers.Character.IsInvulnerable(character) then
		--Invulnerable/Immortality can block statuses
		force = 1
	end
	force = force == 1
	fprint(LOGLEVEL.TRACE, "statusapply Status(\"%s\") Target(%s) Source(%s) Duration(%s) Force(%s)",status,target,source,duration,force)
	GameHelpers.Status.Apply(target, status, duration, force, source)
	--ApplyStatus(target,status,duration,force,source)
end)

-- !statusremove LLLICH_DOMINATED_BEAM_FX 145810cc-7e46-43e7-9fdf-ab9bb8ffcdc0
Ext.RegisterConsoleCommand("statusremove", function(command,status,target)
	local host = Osi.CharacterGetHostCharacter()
	if target == nil or target == "host" then
		target = host
	end
	if status == nil then
		status = "HASTED"
	end
	if status == "ALL" then
		Osi.RemoveHarmfulStatuses(target)
	else
		Osi.RemoveStatus(target,status)
	end
end)

Ext.RegisterConsoleCommand("setstatusturns", function(command,target,status,turnsStr)
	local host = Osi.CharacterGetHostCharacter()
	if target == nil or target == "host" then
		target = host
	end
	if status == nil then
		status = "ENCOURAGED"
	end
	local turns = 1
	if turnsStr ~= nil then
		turns = tonumber(turnsStr)
	else
		turns = Ext.Utils.Random(2,5)
	end
	--GameHelpers.UI.RefreshStatusTurns(target, status)
	GameHelpers.Status.SetTurns(target, status, turns)
end)

Ext.RegisterConsoleCommand("clearinventory", function(command)
	local host = Osi.CharacterGetHostCharacter()
	local x,y,z = Osi.GetPosition(host)
	--local backpack = CreateItemTemplateAtPosition("LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
	for player in GameHelpers.Character.GetPlayers(false) do
		for i,v in pairs(player:GetInventoryItems()) do
			local item = GameHelpers.GetItem(v)
			if Data.EquipmentSlots[item.Slot] and not item.StoryItem then
				Osi.ItemRemove(v)
			end
		end
	end
end)

local treasureChest = nil
Ext.RegisterConsoleCommand("addtreasure", function(command, treasure, identifyItems, levelstr)
	if identifyItems == "false" or identifyItems == "0" then
		identifyItems = false
	else
		identifyItems = true
	end
	if treasure == nil or treasure == "" or treasure == "nil" then
		treasure = "ArenaMode_ArmsTrader"
	end
	local host = Osi.CharacterGetHostCharacter()
	local level = Osi.CharacterGetLevel(host)
	if levelstr ~= nil then
		level = Ext.Utils.Round(tonumber(levelstr))
	end
	local x,y,z = Osi.GetPosition(host)
	if treasureChest == nil or Osi.ObjectExists(treasureChest) == 0 then
		treasureChest = Osi.CreateItemTemplateAtPosition("219f6175-312b-4520-afce-a92c7fadc1ee", x, y, z)
	end
	local tx,ty,tz = Osi.FindValidPosition(x,y,z, 8.0, treasureChest)
	Osi.ItemMoveToPosition(treasureChest, tx,ty,tz,16.0,20.0,"",0)
	Osi.GenerateTreasure(treasureChest, treasure, level, host)
	if identifyItems then
		Osi.ContainerIdentifyAll(treasureChest)
	end
end)

---@private
---@class DebugCommandStatTables:table
---@field Armor string[]
---@field Weapon string[]
---@field Shield string[]
---@field Object string[]

---@param name string
---@param stats DebugCommandStatTables
---@return string|nil
local function findStatByObjectCategory(name, stats)
	for statType,entries in pairs(stats) do
		for _,v in pairs(entries) do
			local stat = Ext.Stats.Get(v, nil, false)
			if stat and stat.ObjectCategory == name then
				return stat
			end
		end
	end
	return nil
end

local function processTreasure(treasure, props, host, generateAmount)
	generateAmount = generateAmount or 1
	local tbl = Ext.Stats.TreasureTable.GetLegacy(treasure)
	if tbl then
		local stats = {
			Armor = Ext.Stats.GetStats("Armor"),
			Weapon = Ext.Stats.GetStats("Weapon"),
			Shield = Ext.Stats.GetStats("Shield"),
			Object = Ext.Stats.GetStats("Object")
		}

		for _,sub in pairs(tbl.SubTables) do
			for _,cat in pairs(sub.Categories) do
				if cat.TreasureCategory then
					if string.find(cat.TreasureCategory, "I_", nil, true) then
						local stat = string.gsub(cat.TreasureCategory, "I_", "")
						for i=0,generateAmount do
							local item = GameHelpers.Item.CreateItemByStat(stat, props)
							if item then
								Osi.ItemToInventory(item, host, 1, 0, 0)
							else
								fprint(LOGLEVEL.WARNING, "Failed to create item for treasure (%s) stat (%s)", treasure, stat)
							end
						end
					else
						local stat = findStatByObjectCategory(cat.TreasureCategory, stats)
						if stat then
							for i=0,generateAmount do
								local item = GameHelpers.Item.CreateItemByStat(stat, props)
								if item then
									Osi.ItemToInventory(item, host, 1, 0, 0)
								else
									fprint(LOGLEVEL.WARNING, "Failed to create item for treasure (%s) stat (%s)", treasure, stat)
								end
							end
						end
					end
				elseif cat.TreasureTable then
					processTreasure(cat.TreasureTable, props, host, generateAmount)
				else
					fprint(LOGLEVEL.TRACE, Common.Dump(cat))
				end
			end
		end
	end
end

Ext.RegisterConsoleCommand("addtreasureex", function(command, treasure, level, forceRarity, generateAmount)
	local host = Osi.CharacterGetHostCharacter()
	if treasure == nil then
		treasure = "ArenaMode_ArmsTrader"
	end
	if level == nil then
		level = Osi.CharacterGetLevel(host)
	else
		level = Ext.Utils.Round(tonumber(level))
	end
	if generateAmount then
		generateAmount = tonumber(generateAmount) or 1
	end
	---@type EocItemDefinition
	local props = {
		Level = level,
		ItemType = forceRarity or "Rare",
		GenerationItemType = forceRarity or "Rare",
		IsIdentified = true,
		HasGeneratedStats = true,
	}
	processTreasure(treasure, props, host, generateAmount)
end)

--!addreward ST_LLWEAPONEX_RunebladesRare
Ext.RegisterConsoleCommand("addreward", function(command, treasure, identifyItems)
	if treasure == nil then
		treasure = "ST_WeaponRare"
	end
	local host = Osi.CharacterGetHostCharacter()
	local identified = identifyItems ~= 0
	Osi.CharacterGiveReward(host, treasure, identified)
end)

Ext.RegisterConsoleCommand("questreward", function(command, treasure, delay)
	if treasure == nil then
		treasure = "RC_GY_RykersContract"
	end
	local host = Osi.CharacterGetHostCharacter()
	if delay ~= nil then
		delay = tonumber(delay)
	end
	if delay ~= nil then
		Timer.StartOneshot(string.format("Timers_LeaderLib_Debug_QuestReward%s%s%s", host, treasure, delay), delay, function()
			Osi.CharacterGiveQuestReward(host, treasure, "QuestReward")
		end)
	else
		Osi.CharacterGiveQuestReward(host, treasure, "QuestReward")
	end
end)

Ext.RegisterConsoleCommand("addskill", function(command, skill)
	local host = Osi.CharacterGetHostCharacter()
	Osi.CharacterAddSkill(host, skill, 1)
end)

Ext.RegisterConsoleCommand("addskillset", function(command, name, addRequirements)
	local host = GameHelpers.Character.GetHost()
	local skillset = Ext.Stats.SkillSet.GetLegacy(name)
	addRequirements = addRequirements == "true" or addRequirements == "1"
	if skillset then
		if addRequirements then
			local total = #skillset.Skills
			if host.Stats.Memory < total then
				Osi.CharacterAddAttribute(host.MyGuid, "Memory", (total - host.Stats.Memory) + 1)
			end
		end
		Timer.StartOneshot("", 250, function ()
			for _,v in pairs(skillset.Skills) do
				if addRequirements then
					local stat = Ext.Stats.Get(v, nil, false)
					if stat then
						for _,req in pairs(stat.MemorizationRequirements) do
							if req.Not == false then
								if Data.Ability[req.Requirement] then
									local addAmount = req.Param - host.Stats[req.Requirement]
									if addAmount > 0 then
										Osi.CharacterAddAbility(host.MyGuid, req.Requirement, addAmount)
									end
								elseif Data.Attribute[req.Requirement] then
									local addAmount = req.Param - host.Stats[req.Requirement]
									if addAmount > 0 then
										Osi.CharacterAddAttribute(host.MyGuid, req.Requirement, addAmount)
									end
								end
							end
						end
					end
				end
				Osi.CharacterRemoveSkill(host.MyGuid, v)
				Osi.CharacterAddSkill(host.MyGuid, v, 1)
			end
		end)
	end
end)

local removedSkills = {}

Ext.RegisterConsoleCommand("removeskill", function(cmd, skill)
	local host = Osi.CharacterGetHostCharacter()
	Osi.CharacterRemoveSkill(host, skill)
	GameHelpers.Skill.RemoveFromSlots(host,skill)
end)

Ext.RegisterConsoleCommand("removeunmemorizedskills", function(cmd)
	local host = Osi.CharacterGetHostCharacter()
	local char = GameHelpers.GetCharacter(host)
	removedSkills[host] = {}
	for i,skill in pairs(char:GetSkills()) do
		local slot = Osi.NRD_SkillBarFindSkill(host, skill)
		if slot == nil then
			table.insert(removedSkills[host], {Skill=skill, Slot=slot})
			fprint(LOGLEVEL.TRACE, "[LeaderLib:removeunmemorizedskills] Removing "..skill)
			Osi.CharacterRemoveSkill(host, skill)
			--local skillInfo = char:GetSkillInfo(skill)
			--print(string.format("[%s](%i) IsActivated(%s) IsLearned(%s), ZeroMemory(%s)", skill, slot, skillInfo.IsActivated, skillInfo.IsLearned, skillInfo.ZeroMemory))
		end
	end
end)

Ext.RegisterConsoleCommand("undoremoveunmemorizedskills", function(cmd)
	local host = Osi.CharacterGetHostCharacter()
	local skills = removedSkills[host]
	if skills ~= nil then
		for i,v in pairs(skills) do
			Osi.CharacterAddSkill(host, v.Skill, 0)
			GameHelpers.Skill.TrySetSlot(host, v.Slot, v.Skill, true)
		end
		removedSkills[host] = nil
	end
end)

Ext.RegisterConsoleCommand("printalldeltamods", function(command, ...)
	local host = Osi.CharacterGetHostCharacter()
	---@type EsvCharacter
	local character = GameHelpers.GetCharacter(host)
	for i,slot in Data.EquipmentSlots:Get() do
		---@type StatItem
		--local item = character.Stats:GetItemBySlot(slot)
		local itemUUID = Osi.CharacterGetEquippedItem(host, slot)
		if itemUUID ~= nil then
			---@type EsvItem
			local item = GameHelpers.GetItem(itemUUID)
			if item ~= nil then
				fprint(LOGLEVEL.TRACE, slot, itemUUID)
				fprint(LOGLEVEL.TRACE, "Stat (%s)", item.StatsId)
				fprint(LOGLEVEL.TRACE, "=======")
				fprint(LOGLEVEL.TRACE, "Item Boost Stats:")
				fprint(LOGLEVEL.TRACE, "=======")
				for i,stat in pairs(item.Stats.DynamicStats) do
					if not StringHelpers.IsNullOrEmpty(stat.BoostName) then
						fprint(LOGLEVEL.TRACE, i,stat.BoostName)
					end
				end
				fprint(LOGLEVEL.TRACE, "=======")
				Osi.NRD_ItemIterateDeltaModifiers(itemUUID, "LLWEAPONEX_Debug_PrintDeltamod")
			end
		end
	end
end)

Ext.RegisterConsoleCommand("clearcombatlog", function(command, text)
	GameHelpers.Net.PostToUser(Osi.CharacterGetHostCharacter(), "LeaderLib_ClearCombatLog", "0")
end)

Ext.RegisterConsoleCommand("refreshskill", function(command, skill, enabled)
	SetSkillEnabled(Osi.CharacterGetHostCharacter(), skill, false)
end)

Ext.RegisterConsoleCommand("sethelmetoption", function(command, param)
	local host = Osi.CharacterGetHostCharacter()
	local enabled = param == "true"
	fprint(LOGLEVEL.TRACE, "[sethelmetoption]",host,enabled)
	GameHelpers.Net.PostToUser(host, "LeaderLib_SetHelmetOption", MessageData:CreateFromTable("HelmetOption", {UUID = host, Enabled = enabled}):ToString())
end)

Ext.RegisterConsoleCommand("addpoints", function(cmd, pointType, amount, id)
	local host = StringHelpers.GetUUID(Osi.CharacterGetHostCharacter())
	if amount == nil then
		amount = 1
	else
		amount = tonumber(amount)
	end
	if pointType == nil then
		pointType = "ability"
	else
		pointType = StringHelpers.Trim(string.lower(pointType))
	end
	if pointType == "ability" then
		Osi.CharacterAddAbilityPoint(host, amount)
	elseif pointType == "attribute" then
		Osi.CharacterAddAttributePoint(host, amount)
	elseif pointType == "civil" then
		Osi.CharacterAddCivilAbilityPoint(host, amount)
	elseif pointType == "talent" then
		Osi.CharacterAddTalentPoint(host, amount)
	elseif pointType == "source" then
		Osi.CharacterAddSourcePoints(host, amount)
	elseif pointType == "sourcemax" then
		local next = Osi.CharacterGetMaxSourcePoints(host) + amount
		Osi.CharacterOverrideMaxSourcePoints(host, next)
	elseif pointType == "custom" and id then
		if Mods.CharacterExpansionLib then
			Mods.CharacterExpansionLib.CustomStatSystem:AddAvailablePoints(host, id, amount)
		end
	end

	GameHelpers.Data.SyncSharedData(false, host)
end)

Ext.RegisterConsoleCommand("printitemboosts", function(cmd)
	local host = GameHelpers.Character.GetHost()
	local weapon = GameHelpers.GetItem(Osi.CharacterGetEquippedItem(host.MyGuid, "Weapon"))
	fprint(LOGLEVEL.TRACE, weapon.MyGuid, weapon.StatsId)
	fprint(LOGLEVEL.TRACE, weapon.Stats.StatsEntry.Boosts)
	for i,v in pairs(weapon:GetGeneratedBoosts()) do
		fprint(LOGLEVEL.TRACE, i,v)
	end
	for i,v in pairs(weapon:GetDeltaMods()) do
		fprint(LOGLEVEL.TRACE, i,v)
	end
	fprint(LOGLEVEL.TRACE, weapon.Stats["Damage Type"])
end)

Ext.RegisterConsoleCommand("fx", function(cmd, effect, bone, target)
	if target == nil then target = Osi.CharacterGetHostCharacter() end
	if bone == nil then bone = "Dummy_OverheadFX" end
	Osi.PlayEffect(target, effect, bone)
	fprint(LOGLEVEL.TRACE, "PlayEffect(\"%s\", \"%s\", \"%s\")", target, effect, bone)
end)

Ext.RegisterConsoleCommand("sfx", function(cmd, soundevent, target)
	if target == nil then target = Osi.CharacterGetHostCharacter() end
	Osi.PlaySound(target, soundevent)
end)

local modifierTypes = {
	"Armor",
	"Weapon",
	"Shield",
}

Ext.RegisterConsoleCommand("printdeltamods", function(cmd, attributeFilter, filterValue, filter2, filter2Value)
	---@type DeltaMod[]
	local deltamods = Ext.Stats.GetStats("DeltaMod")
	for _,v in pairs(deltamods) do
		local deltamod = Ext.Stats.DeltaMod.GetLegacy(v.Name, v.ModifierType)
		local canPrint = false
		local slotType = Data.EquipmentSlots[deltamod.SlotType]
		if attributeFilter == "SlotType" then
			canPrint = slotType == filterValue
		else
			canPrint = attributeFilter == nil or deltamod[attributeFilter] == filterValue
		end
		if canPrint and filter2 ~= nil then
			if string.sub(filter2Value, 1, 1) == "!" then
				canPrint = deltamod[filter2] ~= string.sub(filter2Value, 2)
			else
				canPrint = deltamod[filter2] == filter2Value
			end
		end
		--print(deltamod.Name, deltamod.ModifierType, deltamod.SlotType)
		-- if string.find(deltamod.Name, "Belt") or deltamod.SlotType == "Belt" then
		-- 	print(deltamod.SlotType, slotType)
		-- 	--print(deltamod.Name, canPrint, deltamod.SlotType, deltamod.BoostType)
		-- end
		if canPrint then
			fprint(LOGLEVEL.TRACE, deltamod.Name)
			--print(string.format("[%s] BoostType(%s) LevelRange(%s-%s) Frequency(%s) ModifierType(%s) SlotType(%s:%s)\nBoosts:", deltamod.Name, deltamod.BoostType, deltamod.MinLevel, deltamod.MaxLevel, deltamod.Frequency, deltamod.ModifierType, deltamod.SlotType, slotType))
			-- for i,boost in pairs(deltamod.Boosts) do
			-- 	print("  ", i, boost.Boost, boost.Count)
			-- end
		end
	end
end)

local PlayerCustomDataAttributes = {
	"Name",
	"Race",
	"OriginName",
	"ClassType",
	"IsMale",
	"CustomLookEnabled",
	"SkinColor",
	"HairColor",
	"ClothColor1",
	"ClothColor2",
	"ClothColor3",
	"Icon",
	"MusicInstrument",
	"OwnerProfileID",
	"ReservedProfileID",
	"AiPersonality",
	"Speaker",
}

Ext.RegisterConsoleCommand("printpdata", function(cmd, target)
	target = target or Osi.CharacterGetHostCharacter()
	local character = GameHelpers.GetCharacter(target)
	if character ~= nil and character.PlayerCustomData ~= nil then
		local pdata = character.PlayerCustomData
			fprint(LOGLEVEL.TRACE, string.format("[%s] %s", target, character.DisplayName))
		for i,v in ipairs(PlayerCustomDataAttributes) do
			fprint(LOGLEVEL.TRACE, string.format("[%s] %s", v, pdata[v]))
		end
	else
		Ext.Utils.PrintError(target, "has no PlayerCustomData!")
	end
end)

Ext.RegisterConsoleCommand("hidestatusmc", function(command, visible)
	visible = visible or "false"
	GameHelpers.Net.PostToUser(Osi.CharacterGetHostCharacter(), "LeaderLib_UI_HideStatuses", visible)
end)

Ext.RegisterConsoleCommand("clonedeltamodtest", function(command, amount)
	---@type EocItemDefinition
	local properties = {}
	local deltamods = {
		"Boost_Weapon_Rune_LOOT_Rune_Venom_Giant",
		"Boost_Weapon_Damage_Poison_Axe",
	}
	properties.GMFolding = false
	properties.IsIdentified = true
	properties.DamageTypeOverwrite = "Fire"
	properties.WeightValueOverwrite = 10
	--properties.HasGeneratedStats = true
	properties.DeltaMods = deltamods
	properties.RootTemplate = "3dd01bc4-65e7-4468-9854-b19bc980b3f8"
	properties.OriginalRootTemplate = "3dd01bc4-65e7-4468-9854-b19bc980b3f8"
	properties.StatsEntryName = "WPN_Sword_1H"
	properties.GenerationStatsId = "WPN_Sword_1H"
	properties.StatsLevel = 10
	properties.GenerationLevel = 10
	properties.GenerationRandom = LEADERLIB_RAN_SEED
	properties.ItemType = "Rare"
	properties.GenerationItemType = "Rare"
	properties.HasModifiedSkills = true
	properties.Skills = "Projectile_Fireball"
	local host = GameHelpers.Character.GetHost()
	local weapon = Osi.CharacterGetEquippedWeapon(host.MyGuid)
	weapon = not StringHelpers.IsNullOrEmpty(weapon) and GameHelpers.GetItem(weapon) or "3dd01bc4-65e7-4468-9854-b19bc980b3f8"
	-- local item = GameHelpers.Item.Clone(weapon, properties)
	-- if item ~= nil then
	-- 	ItemToInventory(item.MyGuid, host.MyGuid, 1, 1, 0)
	-- end
	local item2 = GameHelpers.Item.CreateItemByTemplate("3dd01bc4-65e7-4468-9854-b19bc980b3f8", properties)
	if item2 ~= nil then
		Osi.ItemToInventory(item2.MyGuid, host.MyGuid, 1, 1, 0)
		Osi.NRD_ItemSetIdentified(item2.MyGuid, 1)
	end
	properties.HasGeneratedStats = true
	local item2 = GameHelpers.Item.CreateItemByTemplate("3dd01bc4-65e7-4468-9854-b19bc980b3f8", properties)
	if item2 ~= nil then
		Osi.ItemToInventory(item2.MyGuid, host.MyGuid, 1, 1, 0)
		Osi.NRD_ItemSetIdentified(item2.MyGuid, 1)
	end
	-- local item3 = GameHelpers.Item.CreateItemByStat("WPN_Sword_1H", true, properties)
	-- if item3 then
	-- 	ItemToInventory(item3, host.MyGuid, 1, 1, 0)
	-- end
end)

Ext.RegisterConsoleCommand("printrunes", function(command, equipmentSlot)
	equipmentSlot = equipmentSlot or "Weapon"
	local host = GameHelpers.Character.GetHost()
	local item = GameHelpers.Item.GetItemInSlot(host, equipmentSlot)
	if item then
		local boosts = GameHelpers.Stats.GetRuneBoosts(item)
		if boosts then
			fprint(LOGLEVEL.DEFAULT, "Runes (%s)", equipmentSlot)
			fprint(LOGLEVEL.TRACE, "======")
			for i,v in pairs(boosts) do
				fprint(LOGLEVEL.DEFAULT, "[%s] (%s) RuneEffectWeapon(%s) RuneEffectUpperbody(%s) RuneEffectAmulet(%s)", v.Slot, v.Name, v.Boosts.RuneEffectWeapon, v.Boosts.RuneEffectUpperbody, v.Boosts.RuneEffectAmulet)
			end
			fprint(LOGLEVEL.TRACE, "======")
		end
	else
		fprint(LOGLEVEL.WARNING, "No item in slot (%s)", equipmentSlot)
	end
end)

Ext.RegisterConsoleCommand("cctest", function(cmd, disable)
	local player = GameHelpers.Character.GetHost()
	local username = Osi.GetUserName(player.ReservedUserID)
	local profile = Osi.GetUserProfileID(player.ReservedUserID)
	for dummy in GameHelpers.DB.GetAllEntries("DB_CharacterCreationDummy", 1) do
		local assigned = Osi.DB_AssignedDummyForUser:Get(nil,dummy)
		if disable then
			Osi.PROC_RemoveCCDummy(dummy)
		else
			if assigned == nil or #assigned == 0 then
				Osi.ProcAssignDummyToUser(dummy, username)
			end
		end
	end
	if disable then
		Ext.Utils.PrintError("Removing")
		Osi.ProcRemovePreviousSelectedCharacter(profile)
		Osi.ProcRemovePreviousDummy(profile)
		Timer.StartOneshot("", 250, function (e)
			Osi.PROC_Shared_CharacterCreationStarted()
		end)
	end
end)

Ext.RegisterConsoleCommand("treasureupdatetest", function ()
	Ext.IO.SaveFile("Dumps/TreasureTableTest_ST_WeaponLegendary_Before.json", Ext.DumpExport(Ext.Stats.TreasureTable.Get("ST_WeaponLegendary")))
	Ext.Stats.TreasureTable.Update(Ext.Stats.TreasureTable.GetLegacy("ST_WeaponLegendary"))
	Ext.IO.SaveFile("Dumps/TreasureTableTest_ST_WeaponLegendary_After.json", Ext.DumpExport(Ext.Stats.TreasureTable.Get("ST_WeaponLegendary")))
end)