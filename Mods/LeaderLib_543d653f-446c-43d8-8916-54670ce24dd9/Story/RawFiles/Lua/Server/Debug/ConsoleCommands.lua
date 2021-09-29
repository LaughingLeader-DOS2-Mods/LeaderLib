local MessageData = Classes.MessageData

Ext.RegisterConsoleCommand("pos", function()
	---@type StatCharacter
	local character = CharacterGetHostCharacter()
	fprint("Pos:", GetPosition(character))
	fprint("Rot:", GetRotation(character))
end)

Ext.RegisterConsoleCommand("pos2", function()
	---@type StatCharacter
	local character = Ext.GetCharacter(CharacterGetHostCharacter()).Stats
	fprint("Position:", Ext.JsonStringify(character.Position))
	fprint("Rotation:", Ext.JsonStringify(character.Rotation))
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
		radius = tonumber(radiusVal)
	end
	local host = StringHelpers.GetUUID(CharacterGetHostCharacter())
	local characters = nil
	if radius < 0 then
		characters = Ext.GetAllCharacters()
	else
		characters = Ext.GetCharacter(host):GetNearbyCharacters(radius)
	end
	for i,uuid in pairs(characters) do
		if skipSelf and uuid == host then
			--Skip
		else
			---@type EsvCharacter
			local character = Ext.GetCharacter(uuid)
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
			print("Pos:", table.unpack(characterStats.Position))
			print("Rot:", table.unpack(characterStats.Rotation))
			print("CustomTradeTreasure:", Common.Dump(character.CustomTradeTreasure))
			print("Gain:", Ext.StatGetAttribute(character.Stats.Name, "Gain"))
			print("===============")
		end
	end
	if charactersOnly ~= true then
		local items = nil
		if radius < 0 then
			items = Ext.GetAllItems()
		else
			items = {}
			for _,v in pairs(Ext.GetAllItems()) do
				if GetDistanceTo(v, host) <= radius then
					items[#items+1] = v
				end
			end
		end
		for i,uuid in pairs(items) do
			---@type EsvItem
			local item = Ext.GetItem(uuid)
			print("ITEM")
			print("===============")
			print("UUID:", uuid)
			print("NetID:", item.NetID)
			print("Name:", item.DisplayName)
			print("StatsId:", item.StatsId)
			print("Pos:", table.unpack(item.WorldPos))
			print("Rot:", GetRotation(item.MyGuid))
			print("===============")
		end
	end
end)

--!teleport "c099caa6-1938-4b4f-9365-d0881c611e71"

Ext.RegisterConsoleCommand("teleport", function(cmd,target,param2,param3)
	local host = CharacterGetHostCharacter()
	if param2 == "host" then param2 = host end
	if param3 == "host" then param3 = host end

	PrintDebug(cmd,target,param2,param3)

	if param2 == nil or param3 == nil then
		if ObjectExists(target) == 1 then
			PrintDebug("Teleporting",host,"to",target,GetPosition(target))
			TeleportTo(host, target, "", 1, 0, 1)
		else
			PrintDebug("Target",target,"does not exist")
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
			PrintDebug("[teleport] Failed to parse position?")	
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
		force = 0
	else
		force = tonumber(force)
	end
	if status == nil then
		status = "HASTED"
	end
	PrintDebug(command,status,target,source,duration,force)
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
	for player in GameHelpers.Character.GetPlayers(false) do
		local items = player:GetInventoryItems()
		for i,v in pairs(player:GetInventoryItems()) do
			local item = Ext.GetItem(v)
			if item.Slot > 13 and not item.StoryItem then
				ItemRemove(v)
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
	if treasure == nil then
		treasure = "ArenaMode_ArmsTrader"
	end
	local host = CharacterGetHostCharacter()
	local level = CharacterGetLevel(host)
	if levelstr ~= nil then
		level = Ext.Round(tonumber(levelstr))
	end
	local x,y,z = GetPosition(host)
	if treasureChest == nil or ObjectExists(treasureChest) == 0 then
		treasureChest = CreateItemTemplateAtPosition("219f6175-312b-4520-afce-a92c7fadc1ee", x, y, z)
	end
	local tx,ty,tz = FindValidPosition(x,y,z, 8.0, treasureChest)
	ItemMoveToPosition(treasureChest, tx,ty,tz,16.0,20.0,"",0)
	GenerateTreasure(treasureChest, treasure, level, host)
	if identifyItems then
		ContainerIdentifyAll(treasureChest)
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
			local stat = Ext.GetStat(v)
			if stat and stat.ObjectCategory == name then
				return stat
			end
		end
	end
	return nil
end

local function processTreasure(treasure, props, host, generateAmount)
	generateAmount = generateAmount or 1
	local tbl = Ext.GetTreasureTable(treasure)
	if tbl then
		local stats = {
			Armor = Ext.GetStatEntries("Armor"),
			Weapon = Ext.GetStatEntries("Weapon"),
			Shield = Ext.GetStatEntries("Shield"),
			Object = Ext.GetStatEntries("Object")
		}

		for _,sub in pairs(tbl.SubTables) do
			for _,cat in pairs(sub.Categories) do
				if cat.TreasureCategory then
					if string.find(cat.TreasureCategory, "I_", nil, true) then
						local stat = string.gsub(cat.TreasureCategory, "I_", "")
						for i=0,generateAmount do
							local item = GameHelpers.Item.CreateItemByStat(stat, props)
							if item then
								ItemToInventory(item, host, 1, 0, 0)
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
									ItemToInventory(item, host, 1, 0, 0)
								else
									fprint(LOGLEVEL.WARNING, "Failed to create item for treasure (%s) stat (%s)", treasure, stat)
								end
							end
						end
					end
				elseif cat.TreasureTable then
					processTreasure(cat.TreasureTable, props, host, generateAmount)
				else
					PrintDebug(Common.Dump(cat))
				end
			end
		end
	end
end

Ext.RegisterConsoleCommand("addtreasureex", function(command, treasure, level, forceRarity, generateAmount)
	local host = CharacterGetHostCharacter()
	if treasure == nil then
		treasure = "ArenaMode_ArmsTrader"
	end
	if level == nil then
		level = CharacterGetLevel(host)
	else
		level = Ext.Round(tonumber(level))
	end
	if generateAmount then
		generateAmount = tonumber(generateAmount) or 1
	end
	---@type ItemDefinition
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
		Timer.StartOneshot(string.format("Timers_LeaderLib_Debug_QuestReward%s%s%s", host, treasure, delay), delay, function()
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
			PrintDebug("[LeaderLib:removeunmemorizedskills] Removing "..skill)
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

---@param params ItemDefinition
local function AddItemStat(stat, params)
	if not params then
		params = {}
	else
		if params.Level then
			params.StatsLevel = params.Level
			params.Level = nil
		end
		if params.Rarity then
			params.ItemType = params.Rarity
			params.Rarity = nil
		end
	end
	if params.StatsLevel == nil then
		params.StatsLevel = CharacterGetLevel(CharacterGetHostCharacter())
	end
	if params.ItemType == nil then
		params.ItemType = "Epic"
	end
	if params.IsIdentified == nil then
		params.IsIdentified = true
	end
	if params.GMFolding == nil then
		params.GMFolding = false
	end

	-- local item,obj = GameHelpers.Item.CreateItemByStat("ARM_Metamorph_UpperBody", { GenerationLevel=20, StatsLevel = 1, GenerationItemType = "Divine", ItemType = "Common", IsIdentified = true, GMFolding = false, HasGeneratedStats = true,}); ItemToInventory(item, CharacterGetHostCharacter(), 1, 0, 0); ItemDrop(item); SetOnStage(item); print("OffStage", obj.OffStage);

	--local item = GameHelpers.Item.CreateItemByStat("ARM_Metamorph_UpperBody", { StatsLevel = 4, GenerationItemType = "Rare", ItemType = "Rare", IsIdentified = true, GMFolding = false, HasGeneratedStats = true,}); ItemToInventory(item, CharacterGetHostCharacter(), 1, 0, 0)
	--local item = GameHelpers.Item.CreateItemByStat("WPN_Sword", { StatsLevel = 4, GenerationItemType = "Rare", ItemType = "Rare", IsIdentified = true, GMFolding = false, HasGeneratedStats = true,}); ItemToInventory(item, CharacterGetHostCharacter(), 1, 0, 0)

	local item = GameHelpers.Item.CreateItemByStat(stat, params)
	if item ~= nil then
		ItemToInventory(item, CharacterGetHostCharacter(), 1, 1, 1)
		return true
	end
	return false
end

--!additemstat ARM_UNIQUE_LLWEAPONEX_ThiefGloves_A Unique fe0754e3-5f0b-409e-a856-31e646201ee4
Ext.RegisterConsoleCommand("additemstat", function(command, stat, rarity, levelstr, template)
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
	local level = CharacterGetLevel(CharacterGetHostCharacter())
	if levelstr ~= nil then
		level = math.tointeger(tonumber(levelstr)) or level
	end
	if not AddItemStat(stat, {StatsLevel = level, GenerationLevel = level, ItemType = rarity, GenerationItemType = rarity, HasGeneratedStats = rarity ~= "Unique"}) then
		PrintDebug("[additemstat] Failed to generate item!", stat, {})
	end
end)

AddConsoleVariable("additemstat", AddItemStat)

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
				PrintDebug(slot, itemUUID)
				PrintDebug("Stat:", item.StatsId)
				PrintDebug("=======")
				PrintDebug("Item Boost Stats:")
				PrintDebug("=======")
				for i,stat in pairs(item.Stats.DynamicStats) do
					if not StringHelpers.IsNullOrEmpty(stat.BoostName) then
						PrintDebug(i,stat.BoostName)
					end
				end
				PrintDebug("=======")
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
	PrintDebug("[sethelmetoption]",host,enabled)
	Ext.PostMessageToClient(host, "LeaderLib_SetHelmetOption", MessageData:CreateFromTable("HelmetOption", {UUID = host, Enabled = enabled}):ToString())
end)

Ext.RegisterConsoleCommand("addpoints", function(cmd, pointType, amount, id)
	local host = StringHelpers.GetUUID(CharacterGetHostCharacter())
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
	elseif pointType == "custom" and id then
		if Mods.CharacterExpansionLib then
			Mods.CharacterExpansionLib.CustomStatSystem:AddAvailablePoints(host, id, amount)
		end
	end

	GameHelpers.Data.SyncSharedData(false, host)
end)

Ext.RegisterConsoleCommand("printitemboosts", function(cmd)
	local host = Ext.GetCharacter(CharacterGetHostCharacter())
	local weapon = Ext.GetItem(CharacterGetEquippedItem(host.MyGuid, "Weapon"))
	PrintDebug(weapon.MyGuid, weapon.StatsId)
	PrintDebug(weapon.Stats.Boosts)
	for i,v in pairs(weapon:GetGeneratedBoosts()) do
		PrintDebug(i,v)
	end
	for i,v in pairs(weapon:GetDeltaMods()) do
		PrintDebug(i,v)
	end
	PrintDebug(weapon.Stats["Damage Type"])
end)

Ext.RegisterConsoleCommand("fx", function(cmd, effect, bone, target)
	if target == nil then target = CharacterGetHostCharacter() end
	if bone == nil then bone = "" end
	PlayEffect(target, effect, bone)
	fprint(LOGLEVEL.TRACE, "PlayEffect(%s, %s, %s)", target, effect, bone)
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
			PrintDebug(deltamod.Name)
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
			PrintDebug(string.format("[%s] %s", target, character.DisplayName))
		for i,v in ipairs(PlayerCustomDataAttributes) do
			PrintDebug(string.format("[%s] %s", v, pdata[v]))
		end
	else
		Ext.PrintError(target, "has no PlayerCustomData!")
	end
end)

Ext.RegisterConsoleCommand("hidestatusmc", function(command, visible)
	visible = visible or "false"
	Ext.PostMessageToClient(CharacterGetHostCharacter(), "LeaderLib_UI_HideStatuses", visible)
end)

--[[
---@param item EsvItem
function CloneItemWithDeltaMods(item, deltamods)
	--Testing
	deltamods = deltamods or {"Boost_Weapon_Rune_LOOT_Rune_Venom_Giant", "Boost_Weapon_Damage_Poison_Axe"}
	---@type ItemDefinition
	local properties = {
		GMFolding = false,
		IsIdentified = true,
		DeltaMods = item:GetDeltaMods(),
		HasGeneratedStats = true,
		ItemType = item.ItemType,
		GenerationItemType = "Common",
	}
	local newItem = GameHelpers.Item.Clone(item, properties, deltamods)
	if newItem then
		PrintDebug("NewItem:", newItem.MyGuid, newItem.StatsId, newItem.ItemType)
		PrintDebug("DeltaMods")
		PrintDebug(Ext.JsonStringify(newItem:GetDeltaMods()))
	end
	return newItem
end
]]

Ext.RegisterConsoleCommand("clonedeltamodtest", function(command, amount)
	---@type ItemDefinition
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
	properties.GenerationStatsId = "WPN_Sword_1H"
	properties.StatsLevel = 10
	properties.GenerationLevel = 10
	properties.GenerationRandom = LEADERLIB_RAN_SEED
	properties.ItemType = "Rare"
	properties.GenerationItemType = "Rare"
	properties.HasModifiedSkills = true
	properties.Skills = "Projectile_Fireball"
	local host = Ext.GetCharacter(CharacterGetHostCharacter())
	local weapon = CharacterGetEquippedWeapon(host.MyGuid)
	weapon = not StringHelpers.IsNullOrEmpty(weapon) and Ext.GetItem(weapon) or "3dd01bc4-65e7-4468-9854-b19bc980b3f8"
	-- local item = GameHelpers.Item.Clone(weapon, properties)
	-- if item ~= nil then
	-- 	ItemToInventory(item.MyGuid, host.MyGuid, 1, 1, 0)
	-- end
	local item2 = GameHelpers.Item.CreateItemByTemplate("3dd01bc4-65e7-4468-9854-b19bc980b3f8", properties)
	if item2 ~= nil then
		ItemToInventory(item2.MyGuid, host.MyGuid, 1, 1, 0)
		NRD_ItemSetIdentified(item2.MyGuid, 1)
	end
	properties.HasGeneratedStats = true
	local item2 = GameHelpers.Item.CreateItemByTemplate("3dd01bc4-65e7-4468-9854-b19bc980b3f8", properties)
	if item2 ~= nil then
		ItemToInventory(item2.MyGuid, host.MyGuid, 1, 1, 0)
		NRD_ItemSetIdentified(item2.MyGuid, 1)
	end
	-- local item3 = GameHelpers.Item.CreateItemByStat("WPN_Sword_1H", true, properties)
	-- if item3 then
	-- 	ItemToInventory(item3, host.MyGuid, 1, 1, 0)
	-- end
end)

Ext.RegisterConsoleCommand("printrunes", function(command, equipmentSlot)
	equipmentSlot = equipmentSlot or "Weapon"
	local host = Ext.GetCharacter(CharacterGetHostCharacter())
	local item = host:GetItemBySlot(equipmentSlot)
	if item then
		local boosts = GameHelpers.Stats.GetRuneBoosts(item.Stats)
		if boosts then
			fprint(LOGLEVEL.DEFAULT, "Runes (%s)", equipmentSlot)
			PrintDebug("======")
			for i,v in pairs(boosts) do
				fprint(LOGLEVEL.DEFAULT, "[%s] (%s) RuneEffectWeapon(%s) RuneEffectUpperbody(%s) RuneEffectAmulet(%s)", v.Slot, v.Name, v.Boosts.RuneEffectWeapon, v.Boosts.RuneEffectUpperbody, v.Boosts.RuneEffectAmulet)
			end
			PrintDebug("======")
		end
	else
		fprint(LOGLEVEL.WARNING, "No item in slot (%s)", equipmentSlot)
	end
end)