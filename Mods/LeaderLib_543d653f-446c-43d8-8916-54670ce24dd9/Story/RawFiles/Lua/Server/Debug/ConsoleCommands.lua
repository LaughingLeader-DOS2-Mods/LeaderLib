local MessageData = Classes.MessageData

local dynamicStatsVars = {
	"AccuracyBoost",
	"AirResistance",
	"APRecovery",
	"AttackAPCost",
	"Bodybuilding",
	"BoostName",
	"ChanceToHitBoost",
	"CleaveAngle",
	"CleavePercentage",
	"ConstitutionBoost",
	"CorrosiveResistance",
	"CriticalChance",
	"CriticalDamage",
	"CustomResistance",
	"DamageBoost",
	"DamageFromBase",
	"DamageType",
	"DodgeBoost",
	"Durability",
	"DurabilityDegradeSpeed",
	"EarthResistance",
	"FinesseBoost",
	"FireResistance",
	"HearingBoost",
	"Initiative",
	"IntelligenceBoost",
	"ItemColor",
	"LifeSteal",
	"MaxAP",
	"MaxDamage",
	"MaxSummons",
	"MemoryBoost",
	"MinDamage",
	"ModifierType",
	"Movement",
	"MovementSpeedBoost",
	"ObjectInstanceName",
	"PhysicalResistance",
	"PiercingResistance",
	"PoisonResistance",
	"RuneSlots_V1",
	"RuneSlots",
	"ShadowResistance",
	"SightBoost",
	"Skills",
	"SourcePointsBoost",
	"StartAP",
	"StatsType",
	"StrengthBoost",
	"Value",
	"VitalityBoost",
	"WaterResistance",
	"WeaponRange",
	"Weight",
	"Willpower",
	"WitsBoost",
}

local armorBoostProps = {
	"ArmorBoost",
	"ArmorValue",
	"Blocking",
	"MagicArmorBoost",
	"MagicArmorValue",
	"MagicResistance",
}

local function PrintDynamicStats(dynamicStats)
	for i,v in pairs(dynamicStats) do
		Ext.Print("["..tostring(i) .. "]")
		if v ~= nil and v.DamageFromBase > 0 then
			for i,attribute in ipairs(dynamicStatsVars) do
				local val = v[attribute]
				if val ~= nil then
					Ext.Print(string.format("  [%s] = (%s)", attribute, val))
				end
			end
			if v.StatsType ~= "Weapon" then
				for i,attribute in ipairs(armorBoostProps) do
					local val = v[attribute]
					if val ~= nil then
						Ext.Print(string.format("  [%s] = (%s)", attribute, val))
					end
				end
			end
		end
	end
end

---@param uuid string An item's GUIDSTRING/ITEMGUID.
local function PrintItemStats(uuid)
	---@type EsvItem
	local item = Ext.GetItem(uuid)
	if item ~= nil and item.Stats ~= nil then
		Ext.Print("Item:", uuid, item.Stats.Name)
		Ext.Print("Boost Stats:")
		Ext.Print("------")
		---@type StatItemDynamic[]
		local stats = item.Stats.DynamicStats
		PrintDynamicStats(item.Stats.DynamicStats)
		Ext.Print("------")
		Ext.Print("")
	end
end

Ext.RegisterConsoleCommand("printitemstats", function(command, slot)
	local target = CharacterGetHostCharacter()
	---@type EsvCharacter
	local characterObject = Ext.GetCharacter(target)
	if slot == nil then
		for i,item in ipairs(characterObject:GetInventoryItems()) do
			PrintItemStats(item)
		end
	else
		local item = CharacterGetEquippedItem(target, slot)
		if item ~= nil then
			PrintItemStats(item)
		else
			Ext.PrintError("[LeaderLib:printitemstats] Item as slot", slot, "does not exist!")
		end
	end
end)

Ext.RegisterConsoleCommand("adddeltamod", function(command, slot, deltamod)
	if slot == nil then
		slot = "Weapon"
	end
	if deltamod == nil then
		deltamod = "Boost_Weapon_Status_Set_Petrify_Sword"
	end
	local target = CharacterGetHostCharacter()
	local item = CharacterGetEquippedItem(target, slot)
	print(slot,deltamod,item,target)
	if item ~= nil then
		ItemAddDeltaModifier(item, deltamod)
		print(string.format("[LeaderLib] Added deltamod %s to item (%s) in slot %s", deltamod, item, slot))
	end
end)

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
	CharacterLaunchIteratorAroundObject(host, radius, "Iterator_LeaderLib_Debug_Ext_PrintCharacter")
end)

Ext.RegisterConsoleCommand("listenskill", function (call, skill)
	if skill ~= nil then
		RegisterSkillListener(skill, function(skill, uuid, state, ...)
			print("[LeaderLib:DebugMain.lua:SkillListener] skill(",skill,") caster(",uuid,") state(",state,") params(",Ext.JsonStringify({...}),")")
		end)
		print("[LeaderLib:listenskill] Registered listener function for skill ", skill)
	else
		Ext.PrintWarning("[LeaderLib:listenskill] Please provide a valid skill ID to listen for!")
	end
end)
 
Ext.RegisterConsoleCommand("luareset", function(command)
	TimerCancel("Timers_LeaderLib_Debug_LuaReset")
	TimerLaunch("Timers_LeaderLib_Debug_LuaReset", 500)
	print("[LeaderLib:luareset] Reseting lua.")
	NRD_LuaReset(1,1,1)
	Vars.JustReset = true
end)

Ext.RegisterConsoleCommand("movie", function(command,movie)
	if movie == nil then
		movie = "Splash_Logo_Larian"
	end
	local host = CharacterGetHostCharacter()
	MoviePlay(host,movie)
end)

-- !applystatus LLLICH_DOMINATED 145810cc-7e46-43e7-9fdf-ab9bb8ffcdc0 host 18.0 1
-- !applystatus LLLICH_DOMINATED_BEAM_FX 145810cc-7e46-43e7-9fdf-ab9bb8ffcdc0 host -1.0 1
Ext.RegisterConsoleCommand("statusapply", function(command,status,duration,force,target,source)
	print(command,status,target,source,duration,force)
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
	print(CharacterGetDisplayName(target))
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

Ext.RegisterConsoleCommand("testrespen", function(command, level)
	local host = CharacterGetHostCharacter()
	local x,y,z = GetPosition(host)
	if level ~= nil then
		level = math.tointeger(tonumber(level))
	else
		level = CharacterGetLevel(host)
	end
	local item = CreateItemTemplateAtPosition("537a06a5-0619-4d57-b77d-b4c319eab3e6", x, y, z)
	SetTag(item, "LeaderLib_HasResistancePenetration")
	local tag = Data.ResistancePenetrationTags["Fire"][4].Tag
	SetTag(item, tag)
	ItemLevelUpTo(item, level)
	PrintDebug("[LeaderLib:testrespen] Added tag",tag,"to item",item)
	ItemToInventory(item, host, 1, 1, 0)
end)

Ext.RegisterConsoleCommand("testrespen2", function(...)
	local host = CharacterGetHostCharacter()
	ApplyStatus(host, "LADY_VENGEANCE", -1.0, 0, host)
	StartOneshotTimer("Timers_LeaderLib_Debug_ResPenTest", 3000, function()
		--ApplyDamage(CharacterGetHostCharacter(), 50, "Fire", CharacterGetHostCharacter())
		--ApplyDamage(CharacterGetHostCharacter(), 1, "Physical")
		--Osi.ApplyDamage(host, 10, "Water")
		local x,y,z = GetPosition(host)
		CreateExplosionAtPosition(x, y, z, "Projectile_EnemyIceShard", 1)
		CharacterStatusText(host, "Took Damage?")
	end)
end)

Ext.RegisterConsoleCommand("clearinventory", function(command)
	local host = CharacterGetHostCharacter()
	local x,y,z = GetPosition(host)
	--local backpack = CreateItemTemplateAtPosition("LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
	for i,item in pairs(Ext.GetCharacter(host):GetInventoryItems()) do
		if ItemIsStoryItem(item) == 0 and ItemIsDestructible(item) and not GameHelpers.ItemIsEquipped(host, item) then
			ItemRemove(item)
		end
	end
end)

local treasureChest = nil
Ext.RegisterConsoleCommand("addtreasure", function(command, treasure, identifyItems)
	if treasure == nil then
		treasure = "ArenaMode_ArmsTrader"
	end
	local host = CharacterGetHostCharacter()
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

Ext.RegisterConsoleCommand("questreward", function(command, treasure)
	if treasure == nil then
		treasure = "RC_GY_RykersContract"
	end
	local host = CharacterGetHostCharacter()
	CharacterGiveQuestReward(host, treasure, "QuestReward")
end)

Ext.RegisterConsoleCommand("addskill", function(command, skill)
	local host = CharacterGetHostCharacter()
	CharacterAddSkill(host, skill, 1)
end)

--!additemstat ARM_UNIQUE_LLWEAPONEX_ThiefGloves_A Unique fe0754e3-5f0b-409e-a856-31e646201ee4
Ext.RegisterConsoleCommand("additemstat", function(command, stat, rarity, template)
	if rarity == nil then
		if Ext.StatGetAttribute(stat, "Unique") == 1 then
			rarity = "Unique"
		else
			rarity = "Epic"
		end
	end
	if template == nil then
		template = "374cf6c2-3606-49a9-875b-be0adf103807"
	end
	local host = CharacterGetHostCharacter()
	local x,y,z = GetPosition(host)
	local itemBase = CreateItemTemplateAtPosition(template, x, y, z)
	NRD_ItemCloneBegin(itemBase)
	--NRD_ItemConstructBegin("374cf6c2-3606-49a9-875b-be0adf103807")
	--NRD_ItemCloneResetProgression()
	NRD_ItemCloneSetString("GenerationStatsId", stat)
	NRD_ItemCloneSetString("StatsEntryName", stat)
	NRD_ItemCloneSetInt("HasGeneratedStats", 1)
	NRD_ItemCloneSetInt("GenerationLevel", 1)
	NRD_ItemCloneSetInt("StatsLevel", 1)
	NRD_ItemCloneSetInt("IsIdentified", 1)
	NRD_ItemCloneSetString("ItemType", rarity)
	NRD_ItemCloneSetString("GenerationItemType", rarity)
	local item = NRD_ItemClone()
	ItemToInventory(item, host, 1, 1, 1)
	NRD_ItemSetIdentified(item, 1)
	ItemRemove(itemBase)
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

Ext.RegisterConsoleCommand("printdeltamods", function(command, ...)
	local host = CharacterGetHostCharacter()
	---@type EsvCharacter
	local character = Ext.GetCharacter(host)
	for i,slot in LeaderLib.Data.EquipmentSlots:Get() do
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
				for i,stat in ipairs(item.Stats.DynamicStats) do
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

Ext.RegisterConsoleCommand("combatlog", function(command, text)
	local host = CharacterGetHostCharacter()
	if text == nil then
		local name = Ext.GetCharacter(host).DisplayName
		text = "<font color='#CCFF00'>Test</font> did <font color='#FF0000'>TONS</font> of damage to " .. name
	end
	GameHelpers.CombatLog(text, 0)
end)

Ext.RegisterConsoleCommand("clearcombatlog", function(command, text)
	local host = CharacterGetHostCharacter()
	Ext.PostMessageToClient(host, "LeaderLib_ClearCombatLog", "0")
end)

Ext.RegisterConsoleCommand("leaderlib_statustext", function(command, text)
	if text == nil then
		text = "Test Status Text!"
	end
	local host = CharacterGetHostCharacter()
	Ext.BroadcastMessage("LeaderLib_DisplayStatusText", MessageData:CreateFromTable("StatusTextData", {
		UUID = host,
		Text = text,
		Duration = 5.0,
		IsItem = false
	}):ToString(), nil)
	-- StartOneshotTimer("Timers_LeaderLib_Debug_StatusTextTest", 2000, function()
		
	-- end)
end)

Ext.RegisterConsoleCommand("leaderlib_messageboxtest", function(command, text)
	StartOneshotTimer("Timers_LeaderLib_Debug_MessageBoxTest", 2000, function()
		local host = CharacterGetHostCharacter()
		GameHelpers.ShowMessageBox(string.format("<font  color='#FF00CC'>One or more players are missing the script extender.</font><br>Please help:<br>* %s", "LaughingLeader"), host, 0, "<font color='#FF0000'>Script Extender Missing!</font>")
	end)
end)

Ext.RegisterConsoleCommand("printrespentags", function(command)
	print("Data.ResistancePenetrationTags = {")
	for damageType,_ in pairs(Data.DamageTypeToResistance) do
		print("\t"..damageType.." = {")
		for i,entry in ipairs(Data.ResistancePenetrationTags[damageType]) do
			print(string.format("\t\t[%i] = {Tag=\"%s\", Amount=%i},", i, entry.Tag, entry.Amount))
		end
		print("\t},")
	end
	print("}")
end)

Ext.RegisterConsoleCommand("refreshskill", function(command, skill, enabled)
	SetSkillEnabled(CharacterGetHostCharacter(), skill, enabled == "true")
end)