local MessageData = Classes.MessageData

Ext.RegisterConsoleCommand("pos", function()
	---@type StatCharacter
	local character = CharacterGetHostCharacter()
	print("Pos:", GetPosition(character))
	print("Rot:", GetRotation(character))
end)

Ext.RegisterConsoleCommand("pos2", function()
	---@type StatCharacter
	local character = Ext.GetCharacter(CharacterGetHostCharacter()).Stats
	print("Position:", Ext.JsonStringify(character.Position))
	print("Rotation:", Ext.JsonStringify(character.Rotation))
end)

Ext.RegisterConsoleCommand("printuuids", function(call, radiusVal)
	local radius = 6.0
	if radiusVal ~= nil then
		radius = tonumber(radiusVal)
	end
	local host = CharacterGetHostCharacter()
	for i,v in pairs(Ext.GetCharacter(host):GetNearbyCharacters(radius)) do
		---@type EsvCharacter
		local character = Ext.GetCharacter(uuid)
		---@type StatCharacter
		local characterStats = character.Stats

		print("CHARACTER")
		print("===============")
		print("UUID:", uuid)
		print("NetID:", character.NetID)
		print("Name:", CharacterGetDisplayName(uuid))
		print("Stat:", characterStats.Name)
		print("Archetype:", character.Archetype)
		print("Pos:", Ext.JsonStringify(characterStats.Position))
		print("Rot:", Ext.JsonStringify(characterStats.Rotation))
	print("===============")
	end
end)

Ext.RegisterConsoleCommand("teleport", function(cmd,target,param2,param3)
	local host = CharacterGetHostCharacter()
	if param2 == "host" then param2 = host end
	if param3 == "host" then param3 = host end

	if param2 == nil or param3 == nil then
		if ObjectExists(target) == 1 then
			print("Teleporting",host,"to",target,GetPosition(target))
			TeleportTo(host, target, "", 1, 0, 1)
		else
			print("Target",target,"does not exist")
		end
	else
		local x = tonumber(target)
		if x ~= nil then
			local y = tonumber(param2)
			local z = tonumber(param3)

			if y ~= nil and z ~= nil then
				TeleportToPosition(target, x, y, z, "", 1, 0)
			end
		else
			print("[teleport] Failed to parse position?")	
		end
	end
end)

Ext.RegisterConsoleCommand("movie", function(command,movie)
	if movie == nil then
		movie = "Splash_Logo_Larian"
	end
	local host = CharacterGetHostCharacter()
	MoviePlay(host,movie)
end)

-- !statusapply LLLICH_DOMINATED 18.0 1 145810cc-7e46-43e7-9fdf-ab9bb8ffcdc0 host
-- !statusapply LLLICH_DOMINATED_BEAM_FX 0.0 1 145810cc-7e46-43e7-9fdf-ab9bb8ffcdc0 host
-- !statusapply MADNESS 12.0 1 319_31dc549d-dfc0-4558-821a-5e3d468e5b1a host
Ext.RegisterConsoleCommand("statusapply", function(command,status,duration,force,target,source)
	local host = CharacterGetHostCharacter()
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
		force = 1
	else
		force = tonumber(force)
	end
	if status == nil then
		status = "HASTED"
	end
	print(command,status,target,source,duration,force)
	ApplyStatus(target,status,duration,force,source)
end)

-- !removestatus LLLICH_DOMINATED_BEAM_FX 145810cc-7e46-43e7-9fdf-ab9bb8ffcdc0
Ext.RegisterConsoleCommand("statusremove", function(command,status,target)
	local host = CharacterGetHostCharacter()
	if target == nil or target == "host" then
		target = host
	end
	if status == nil then
		status = "HASTED"
	end
	if status == "ALL" then
		RemoveHarmfulStatuses(target)
	else
		RemoveStatus(target,status)
	end
end)

Ext.RegisterConsoleCommand("setstatusturns", function(command,target,status,turnsStr)
	local host = CharacterGetHostCharacter()
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
		turns = Ext.Random(2,5)
	end
	--GameHelpers.UI.RefreshStatusTurns(target, status)
	GameHelpers.Status.SetTurns(target, status, turns)
end)

Ext.RegisterConsoleCommand("clearinventory", function(command)
	local host = CharacterGetHostCharacter()
	local x,y,z = GetPosition(host)
	--local backpack = CreateItemTemplateAtPosition("LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
	for i,item in pairs(Ext.GetCharacter(host):GetInventoryItems()) do
		if ItemIsStoryItem(item) == 0 and ItemIsDestructible(item) and not GameHelpers.Item.ItemIsEquipped(host, item) then
			ItemRemove(item)
		end
	end
end)

local treasureChest = nil
Ext.RegisterConsoleCommand("addtreasure", function(command, treasure, identifyItems, levelstr)
	if treasure == nil then
		treasure = "ArenaMode_ArmsTrader"
	end
	local host = CharacterGetHostCharacter()
	local level = CharacterGetLevel(host)
	if levelstr ~= nil then
		level = math.tointeger(tonumber(levelstr))
	end
	local x,y,z = GetPosition(host)
	if treasureChest == nil or ObjectExists(treasureChest) == 0 then
		treasureChest = CreateItemTemplateAtPosition("219f6175-312b-4520-afce-a92c7fadc1ee", x, y, z)
	end
	local tx,ty,tz = FindValidPosition(x,y,z, 8.0, treasureChest)
	ItemMoveToPosition(treasureChest, tx,ty,tz,16.0,20.0,"",0)
	GenerateTreasure(treasureChest, treasure, CharacterGetLevel(host), host)
	if identifyItems ~= 0 then
		ContainerIdentifyAll(treasureChest)
	end
end)

--!addreward ST_LLWEAPONEX_RunebladesRare
Ext.RegisterConsoleCommand("addreward", function(command, treasure, identifyItems)
	if treasure == nil then
		treasure = "ST_WeaponRare"
	end
	local host = CharacterGetHostCharacter()
	local identified = identifyItems ~= 0
	CharacterGiveReward(host, treasure, identified)
end)

Ext.RegisterConsoleCommand("questreward", function(command, treasure, delay)
	if treasure == nil then
		treasure = "RC_GY_RykersContract"
	end
	local host = CharacterGetHostCharacter()
	if delay ~= nil then
		delay = tonumber(delay)
	end
	if delay ~= nil then
		StartOneshotTimer(string.format("Timers_LeaderLib_Debug_QuestReward%s%s%s", host, treasure, delay), delay, function()
			CharacterGiveQuestReward(host, treasure, "QuestReward")
		end)
	else
		CharacterGiveQuestReward(host, treasure, "QuestReward")
	end
end)

Ext.RegisterConsoleCommand("addskill", function(command, skill)
	local host = CharacterGetHostCharacter()
	CharacterAddSkill(host, skill, 1)
end)

local cooldownsDisabled = false
local cooldownsDisabled_AddedListener = false
Ext.RegisterConsoleCommand("nocd", function(command)
	cooldownsDisabled = not cooldownsDisabled
	if cooldownsDisabled then
		CharacterResetCooldowns(CharacterGetHostCharacter()) 
		if not cooldownsDisabled_AddedListener then
			Ext.RegisterOsirisListener("SkillCast", 4, "after", function(char,...)
				if cooldownsDisabled then
					CharacterResetCooldowns(char)
				end
			end)
			cooldownsDisabled_AddedListener = true
		end
	end
end)

Ext.RegisterConsoleCommand("refreshcd", function(command)
	local host = CharacterGetHostCharacter()
	GameHelpers.UI.RefreshSkillBarCooldowns(host)
end)

Ext.RegisterConsoleCommand("ap", function(command, amountStr)
	local host = CharacterGetHostCharacter()
	local amount = Ext.GetCharacter(host).Stats.APMaximum
	if amountStr ~= nil then
		amount = math.tointeger(tonumber(amountStr))
	end
	CharacterAddActionPoints(host, amount)
end)

local removedSkills = {}

Ext.RegisterConsoleCommand("removeskill", function(cmd, skill)
	local host = CharacterGetHostCharacter()
	CharacterRemoveSkill(host, skill)
end)

Ext.RegisterConsoleCommand("removeunmemorizedskills", function(cmd)
	local host = CharacterGetHostCharacter()
	local char = Ext.GetCharacter(host)
	removedSkills[host] = {}
	for i,skill in pairs(char:GetSkills()) do
		local slot = NRD_SkillBarFindSkill(host, skill)
		if slot == nil then
			table.insert(removedSkills[host], {Skill=skill, Slot=slot})
			print("[LeaderLib:removeunmemorizedskills] Removing "..skill)
			CharacterRemoveSkill(host, skill)
			--local skillInfo = char:GetSkillInfo(skill)
			--print(string.format("[%s](%i) IsActivated(%s) IsLearned(%s), ZeroMemory(%s)", skill, slot, skillInfo.IsActivated, skillInfo.IsLearned, skillInfo.ZeroMemory))
		end
	end
end)

Ext.RegisterConsoleCommand("undoremoveunmemorizedskills", function(cmd)
	local host = CharacterGetHostCharacter()
	local skills = removedSkills[host]
	if skills ~= nil then
		for i,v in pairs(skills) do
			CharacterAddSkill(host, v.Skill, 0)
			GameHelpers.Skill.TrySetSlot(host, v.Slot, v.Skill, true)
		end
		removedSkills[host] = nil
	end
end)

--!additemstat ARM_UNIQUE_LLWEAPONEX_ThiefGloves_A Unique fe0754e3-5f0b-409e-a856-31e646201ee4
Ext.RegisterConsoleCommand("additemstat", function(command, stat, levelstr, rarity, template)
	local equipmentStatType = {
		Weapon = true,
		Armor = true,
		Shield = true,
	}
	
	if stat == nil then
		stat = "WPN_Sword_2H"
	end
	if rarity == nil then
		if Ext.StatGetAttribute(stat, "Unique") == 1 then
			rarity = "Unique"
		else
			rarity = "Epic"
		end
	end
	local statType = NRD_StatGetType(stat)
	local host = CharacterGetHostCharacter()
	local level = CharacterGetLevel(host)
	local skipLevelCheck = true
	if levelstr ~= nil then
		level = math.tointeger(tonumber(levelstr)) or level
		skipLevelCheck = false
	end
	local item = GameHelpers.Item.CreateItemByStat(stat, level, rarity, skipLevelCheck, 1, 1)
	if item ~= nil then
		ItemToInventory(item, host, 1, 1, 1)
	else
		print("[additemstat] Failed to generate item!", stat, rarity, levelstr, template)
	end
end)

Ext.RegisterConsoleCommand("additemtemplate", function(command, template, count)
	if count == nil then 
		count = 1
	else
		count = math.tointeger(tonumber(count))
	end
	local host = CharacterGetHostCharacter()
	ItemTemplateAddTo(template, host, count, 1)
end)

Ext.RegisterConsoleCommand("printalldeltamods", function(command, ...)
	local host = CharacterGetHostCharacter()
	---@type EsvCharacter
	local character = Ext.GetCharacter(host)
	for i,slot in Data.EquipmentSlots:Get() do
		---@type StatItem
		--local item = character.Stats:GetItemBySlot(slot)
		local itemUUID = CharacterGetEquippedItem(host, slot)
		if itemUUID ~= nil then
			---@type EsvItem
			local item = Ext.GetItem(itemUUID)
			if item ~= nil then
				print(slot, itemUUID)
				print("Stat:", item.StatsId)
				print("=======")
				print("Item Boost Stats:")
				print("=======")
				for i,stat in pairs(item.Stats.DynamicStats) do
					if not StringHelpers.IsNullOrEmpty(stat.BoostName) then
						print(i,stat.BoostName)
					end
				end
				print("=======")
				NRD_ItemIterateDeltaModifiers(itemUUID, "LLWEAPONEX_Debug_PrintDeltamod")
			end
		end
	end
end)

Ext.RegisterConsoleCommand("clearcombatlog", function(command, text)
	local host = Ext.GetCharacter(CharacterGetHostCharacter())
	Ext.PostMessageToUser(host.UserID, "LeaderLib_ClearCombatLog", "0")
end)

Ext.RegisterConsoleCommand("refreshskill", function(command, skill, enabled)
	SetSkillEnabled(CharacterGetHostCharacter(), skill, false)
end)

Ext.RegisterConsoleCommand("sethelmetoption", function(command, param)
	local host = CharacterGetHostCharacter()
	local enabled = param == "true"
	print("[sethelmetoption]",host,enabled)
	Ext.PostMessageToClient(host, "LeaderLib_SetHelmetOption", MessageData:CreateFromTable("HelmetOption", {UUID = host, Enabled = enabled}):ToString())
end)

Ext.RegisterConsoleCommand("addpoints", function(cmd, pointType, amount)
	local host = CharacterGetHostCharacter()
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
		CharacterAddAbilityPoint(host, amount)
	elseif pointType == "attribute" then
		CharacterAddAttributePoint(host, amount)
	elseif pointType == "civil" then
		CharacterAddCivilAbilityPoint(host, amount)
	elseif pointType == "talent" then
		CharacterAddTalentPoint(host, amount)
	elseif pointType == "source" then
		CharacterAddSourcePoints(host, amount)
	elseif pointType == "sourcemax" then
		local next = CharacterGetMaxSourcePoints(host) + amount
		CharacterOverrideMaxSourcePoints(host, next)
	end
end)

Ext.RegisterConsoleCommand("modorder", function(cmd, uuidOnly)
	if uuidOnly ~= nil then
		for i,v in ipairs(Ext.GetModLoadOrder()) do
			print(string.format("%i. %s", i, v))
		end
	else
		local order = {}
		for i,v in ipairs(Ext.GetModLoadOrder()) do
			local info = Ext.GetModInfo(v)
			if info ~= nil then
				table.insert(order, string.format("%s %s (%s)", info.Name, StringHelpers.VersionIntegerToVersionString(info.Version), info.UUID))
			else
				table.insert(order, v)
			end
		end
		--print(Ext.JsonStringify(order))
		for i,v in ipairs(order) do
			print(string.format("%i. %s", i, v))
		end
	end
end)

Ext.RegisterConsoleCommand("printitemboosts", function(cmd)
	local host = Ext.GetCharacter(CharacterGetHostCharacter())
	local weapon = Ext.GetItem(CharacterGetEquippedItem(host.MyGuid, "Weapon"))
	print(weapon.MyGuid, weapon.StatsId)
	print(weapon.Stats.Boosts)
	for i,v in pairs(weapon:GetGeneratedBoosts()) do
		print(i,v)
	end
	for i,v in pairs(weapon:GetDeltaMods()) do
		print(i,v)
	end
	print(weapon.Stats["Damage Type"])
end)

Ext.RegisterConsoleCommand("fx", function(cmd, effect, bone, target)
	if target == nil then target = CharacterGetHostCharacter() end
	if bone == nil then bone = "" end
	PlayEffect(target, effect, bone)
end)

Ext.RegisterConsoleCommand("sfx", function(cmd, soundevent, target)
	if target == nil then target = CharacterGetHostCharacter() end
	PlaySound(target, soundevent)
end)

local modifierTypes = {
	"Armor",
	"Weapon",
	"Shield",
}

Ext.RegisterConsoleCommand("printdeltamods", function(cmd, attributeFilter, filterValue, filter2, filter2Value)
	---@type DeltaMod[]
	local deltamods = Ext.GetStatEntries("DeltaMod")
	for _,v in pairs(deltamods) do
		local deltamod = Ext.GetDeltaMod(v.Name, v.ModifierType)
		local canPrint = false
		local slotType = Data.DeltaModSlotType[deltamod.SlotType]
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
			print(deltamod.Name)
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
	target = target or CharacterGetHostCharacter()
	local character = Ext.GetCharacter(target)
	if character ~= nil and character.PlayerCustomData ~= nil then
		local pdata = character.PlayerCustomData
		print(string.format("[%s] %s", target, character.DisplayName))
		for i,v in ipairs(PlayerCustomDataAttributes) do
			print(string.format("[%s] %s", v, pdata[v]))
		end
	else
		Ext.PrintError(target, "has no PlayerCustomData!")
	end
end)

Ext.RegisterConsoleCommand("levelup", function(command, amount)
	amount = amount or "1"
	amount = tonumber(amount)
	local host = CharacterGetHostCharacter()
	CharacterLevelUpTo(host, amount)
end)

Ext.RegisterConsoleCommand("printrunes", function(command, equipmentSlot)
	equipmentSlot = equipmentSlot or "Weapon"
	local host = Ext.GetCharacter(CharacterGetHostCharacter())
	local item = host:GetItemBySlot(equipmentSlot)
	if item then
		local boosts = GameHelpers.Stats.GetRuneBoosts(item.Stats)
		if boosts then
			fprint(LOGLEVEL.DEFAULT, "Runes (%s)", equipmentSlot)
			print("======")
			for i,v in pairs(boosts) do
				fprint(LOGLEVEL.DEFAULT, "[%s] (%s) RuneEffectWeapon(%s) RuneEffectUpperbody(%s) RuneEffectAmulet(%s)", v.Slot, v.Name, v.Boosts.RuneEffectWeapon, v.Boosts.RuneEffectUpperbody, v.Boosts.RuneEffectAmulet)
			end
			print("======")
		end
	else
		fprint(LOGLEVEL.WARNING, "No item in slot (%s)", equipmentSlot)
	end
end)
