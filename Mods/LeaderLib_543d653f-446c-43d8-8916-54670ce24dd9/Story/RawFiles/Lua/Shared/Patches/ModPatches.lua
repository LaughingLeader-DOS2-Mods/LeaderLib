local _ISCLIENT = Ext.IsClient()

--Updates the treasure tables to spawn more items, and spawn items at other traders. This is until the 1.0 update is released
--Ext.IO.AddPathOverride("Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Stats/Generated/TreasureTable.txt", "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Overrides/Patches/LLWEAPONEX_TreasureTable.txt")

--Patches an event name conflict that prevented Soul Harvest's bonus from applying.
Ext.AddPathOverride("Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Scripts/LLWEAPONEX_Statuses.gameScript", "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Overrides/Patches/LLWEAPONEX_Statuses.gameScript")

local Patches = {
	--Weapon Expansion
	["c60718c3-ba22-4702-9c5d-5ad92b41ba5f"] = {
		Version = 153288705,
		Patch = function (initialized, region)
			Ext.Utils.PrintWarning("[LeaderLib] Patching Weapon Expansion version [153288706]")
			
			if not initialized then
				return
			end

			local stat = Ext.Stats.Get("ARM_LLWEAPONEX_HandCrossbow_A", nil, false)
			if stat then
				stat.ObjectCategory = "LLWEAPONEX_HandCrossbows"
			end

			if _ISCLIENT then
				---@diagnostic disable undefined-field
				if Ext.Utils.Version() < 56 then
					Ext._NetListeners["LLWEAPONEX_SetWorldTooltipText"] = nil
				else
					Ext._Internal._NetListeners["LLWEAPONEX_SetWorldTooltipText"] = nil
				end

				---@diagnostic enable
	
				Ext.RegisterNetListener("LLWEAPONEX_SetWorldTooltipText", function (cmd, payload)
					local ui = Ext.GetUIByType(Data.UIType.tooltip)
					if ui then
						---@type {tf:{shortDesc:string|nil, setText:fun(text:string, type:integer)}, defaultTooltip:{shortDesc:string|nil, setText:fun(text:string, type:integer)}}
						local main = ui:GetRoot()
						if main ~= nil then
							local text = payload or ""
							if main.tf ~= nil then
								main.tf.shortDesc = text
								if main.tf.setText ~= nil then
									main.tf.setText(text,0)
								end
							elseif main.defaultTooltip ~= nil then
								main.defaultTooltip.shortDesc = text
								if main.defaultTooltip.setText ~= nil then
									main.defaultTooltip.setText(text,0)
								end
							end
						end
					end
				end)
			else
				--Mods.WeaponExpansion.Uniques.Harvest.ProgressionData[11].Value = "Target_BlackShroud"
				--TradeGenerationStarted("680d2702-721c-412d-b083-4f5e816b945a")
				local _NPC = {
					VendingMachine = "680d2702-721c-412d-b083-4f5e816b945a",
					UniqueHoldingChest = "80976258-a7a5-4430-b102-ba91a604c23f",
					WeaponMaster = "3cabc61d-6385-4ae3-b38f-c4f24a8d16b5"
				}
				--Mods.WeaponExpansion.Uniques.WarchiefHalberd:Transfer("host")
				--Fix SwapUniques not working because the UUID passed in is Name_UUID
				---@param char string
				---@param id string
				local function TrySwapUnique(char, id)
					char = StringHelpers.GetUUID(char)
					local uuid = nil
					local uniqueData = Mods.WeaponExpansion.Uniques[id]
					if uniqueData ~= nil then
						uuid = uniqueData:GetUUID(char)
						if uuid == nil then
							local owner = GameHelpers.Item.GetOwner(uniqueData.UUID)
							if not owner or (owner.MyGuid == char or owner.MyGuid == _NPC.UniqueHoldingChest or owner.MyGuid == _NPC.VendingMachine) then
								uuid = uniqueData.UUID
							end
						end
					end
					if uuid == nil then
						fprint(LOGLEVEL.ERROR, "[WeaponExpansion] Found no unique UUID for unique(%s) and character(%s)[%s]", id, GameHelpers.GetDisplayName(char), char)
						fprint(LOGLEVEL.ERROR, "  UUID(%s)", uniqueData and uniqueData.UUID or "nil")
						fprint(LOGLEVEL.ERROR, "  Owner(%s)", uniqueData and uniqueData.Owner or "nil")
						return false
					end
					local equippedGUID = nil
					local nextGUID = nil
					local linkedGUID = Mods.WeaponExpansion.PersistentVars.LinkedUniques[uuid]
					if linkedGUID ~= nil then
						if GameHelpers.Item.ItemIsEquipped(char, linkedGUID) then
							nextGUID = uuid
							equippedGUID = linkedGUID
						else
							nextGUID = linkedGUID
							equippedGUID = uuid
						end
					else
						fprint(LOGLEVEL.ERROR, "[WeaponExpansion] Found no linked UUID for unique(%s)[%s]\n", id, uuid, Ext.DumpExport(Mods.WeaponExpansion.PersistentVars.LinkedUniques))
					end
					local nextItem = ObjectExists(nextGUID) == 1 and GameHelpers.GetItem(nextGUID) or nil
					local equippedItem = ObjectExists(equippedGUID) == 1 and GameHelpers.GetItem(equippedGUID) or nil
					if nextItem and equippedItem then
						Ext.PrintError("GameHelpers.Item.ItemIsEquipped(char, nextItem)", GameHelpers.Item.ItemIsEquipped(char, nextItem))
						Ext.PrintError("GameHelpers.Item.ItemIsEquipped(char, equippedItem)", GameHelpers.Item.ItemIsEquipped(char, equippedItem))
						local isTwoHanded = false
						local locked = equippedItem.UnEquipLocked
						if nextItem.Stats.ItemType == "Weapon" then
							isTwoHanded = nextItem.Stats.IsTwoHanded
						end
						local slot = GameHelpers.Item.GetEquippedSlot(char,equippedItem) or GameHelpers.Item.GetEquippedSlot(char,nextItem) or "Weapon"
				
						ItemLockUnEquip(equippedItem.MyGuid, 0)
						ItemLockUnEquip(nextItem.MyGuid, 0)
						--CharacterUnequipItem(char, equipped)
				
						if not isTwoHanded then
							local currentEquipped = StringHelpers.GetUUID(CharacterGetEquippedItem(char, slot))
							if not StringHelpers.IsNullOrEmpty(currentEquipped) and currentEquipped ~= equippedGUID then
								ItemLockUnEquip(currentEquipped, 0)
								CharacterUnequipItem(char, currentEquipped)
							end
							NRD_CharacterEquipItem(char, nextItem.MyGuid, slot, 0, 0, 1, 1)
						else
							local mainhand,offhand = GameHelpers.Character.GetEquippedWeapons(char)
							if mainhand and mainhand.MyGuid ~= equippedItem.MyGuid then
								ItemLockUnEquip(mainhand.MyGuid, 0)
								CharacterUnequipItem(char, mainhand.MyGuid)
							end
							if offhand and offhand.MyGuid ~= equippedItem.MyGuid then
								ItemLockUnEquip(offhand.MyGuid, 0)
								CharacterUnequipItem(char, offhand.MyGuid)
							end
							NRD_CharacterEquipItem(char, nextItem.MyGuid, "Weapon", 0, 0, 1, 1)
						end
				
						if locked then
							ItemLockUnEquip(nextItem.MyGuid, 1)
						end
				
						Osi.LeaderLib_Timers_StartObjectObjectTimer(equippedItem.MyGuid, _NPC.UniqueHoldingChest, 50, "Timers_LLWEAPONEX_MoveUniqueToUniqueHolder", "LeaderLib_Commands_ItemToInventory")
					else
						fprint(LOGLEVEL.ERROR, "[WeaponExpansion] Found no linked UUID for unique(%s)[%s]. No UUID found for LinkedItem (%s)", id, uuid, uniqueData and uniqueData.LinkedItem and uniqueData.LinkedItem.ID or "")
					end
				end
				Mods.WeaponExpansion.SwapUnique = function (...)
					local b,err = xpcall(TrySwapUnique, debug.traceback, ...)
					if not b then
						Ext.Utils.PrintError(err)
					end
				end

				--Fix this function may call a debug call when the unarmed hit properties don't line up. We're just cleaning up the messages / ignoring whatever DeathType is.
				local UnarmedHitMatchProperties = {
					DamageType = 0,
					DamagedMagicArmor = 0,
					Equipment = 0,
					--DeathType = 0,
					Bleeding = 0,
					DamagedPhysicalArmor = 0,
					PropagatedFromOwner = 0,
					-- NoWeapon doesn't set HitWithWeapon until after preparation
					HitWithWeapon = 0,
					Surface = 0,
					NoEvents = 0,
					Hit = 0,
					Poisoned = 0,
					--CounterAttack = 0,
					--ProcWindWalker = 1,
					NoDamageOnOwner = 0,
					Burning = 0,
					--DamagedVitality = 0,
					--LifeSteal = 0,
					--ArmorAbsorption = 0,
					--AttackDirection = 0,
					Missed = 0,
					--CriticalHit = 0,
					--Backstab = 0,
					Reflection = 0,
					DoT = 0,
					Dodged = 0,
					--DontCreateBloodSurface = 0,
					FromSetHP = 0,
					FromShacklesOfPain = 0,
					Blocked = 0,
				}
			
				local function IsUnarmedHit(handle)
					for prop,val in pairs(UnarmedHitMatchProperties) do
						if NRD_HitGetInt(handle, prop) ~= val then
							return false
						end
					end
					return true
				end
			
				local lizardHits = {}

				Mods.WeaponExpansion.UnarmedHelpers.ScaleUnarmedHitDamage = function (attacker, target, damage, handle)
					if damage > 0 and IsUnarmedHit(handle) then
						local character = GameHelpers.GetCharacter(attacker)
						local isLizard = character:HasTag("LIZARD")
						local isCombinedHit = isLizard and NRD_HitGetInt(handle, "ProcWindWalker") == 0
						local weapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = Mods.WeaponExpansion.UnarmedHelpers.GetUnarmedWeapon(character.Stats, true)
				
						if isCombinedHit then
							lizardHits[attacker] = nil
						elseif isLizard then
							if lizardHits[attacker] == nil then
								lizardHits[attacker] = 0
							end
							lizardHits[attacker] = lizardHits[attacker] + 1
						end
				
						local isSecondHit = lizardHits[attacker] == 2
						local damageList = Mods.WeaponExpansion.UnarmedHelpers.CalculateWeaponDamage(character.Stats, weapon, false, highestAttribute, isLizard, isSecondHit)
				
						if isCombinedHit then
							local offhandDamage = Mods.WeaponExpansion.UnarmedHelpers.CalculateWeaponDamage(character.Stats, weapon, false, highestAttribute, isLizard, true)
							damageList:Merge(offhandDamage)
						end
						NRD_HitClearAllDamage(handle)
						--NRD_HitStatusClearAllDamage(target, handle)
						local damages = damageList:ToTable()
						local totalDamage = 0
						for i,damage in pairs(damages) do
							NRD_HitAddDamage(handle, damage.DamageType, damage.Amount)
							totalDamage = totalDamage + damage.Amount
						end
						if lizardHits[attacker] == 2 then
							lizardHits[attacker] = nil
						end
					end
				end

				--Fix this flag not being cleared
				ObjectClearFlag("680d2702-721c-412d-b083-4f5e816b945a", "LLWEAPONEX_VendingMachine_OrderMenuDisabled", 0)

				--FIX Vending Machine ordering bug, from the backpack inventory being accessed too soon. Also identifies items it generates.
				Mods.WeaponExpansion.GenerateTradeTreasure = function(uuid, treasure)
					if uuid == "680d2702-721c-412d-b083-4f5e816b945a" then
						ObjectClearFlag(uuid, "LLWEAPONEX_VendingMachine_OrderMenuDisabled", 0)
						--This event was mistakenly not fired like it was previously, causing the order flag to not clear
						SetStoryEvent(uuid, "LLWEAPONEX_VendingMachine_OnOrderGenerated")
					end
					local object = GameHelpers.TryGetObject(uuid)
					if ObjectIsCharacter(uuid) == 1 then
						local x,y,z = GetPosition(uuid)
						--LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830
						local backpackGUID = CreateItemTemplateAtPosition("98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
						Timer.StartOneshot("", 50, function ()
							fprint(LOGLEVEL.TRACE, "[WeaponExpansion:GenerateTradeTreasure] Generating treasure table (%s) for (%s)", treasure, object.DisplayName, uuid)
							local backpack = GameHelpers.GetItem(backpackGUID)
							if backpack then
								GenerateTreasure(backpackGUID, treasure, object.Stats.Level, uuid)
								ContainerIdentifyAll(backpackGUID)
								for i,v in pairs(backpack:GetInventoryItems()) do
									local tItem = GameHelpers.GetItem(v)
									if tItem ~= nil then
										tItem.UnsoldGenerated = true -- Trade treasure flag
										ItemToInventory(v, uuid, tItem.Amount, 0, 0)
									else
										ItemToInventory(v, uuid, 1, 0, 0)
									end
									ItemSetOwner(v, uuid)
									ItemSetOriginalOwner(v, uuid)
								end
								ItemRemove(backpackGUID)
							else
								Ext.Utils.PrintError("[WeaponExpansion:GenerateTradeTreasure] Failed to create backpack from root template 'LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830'")
								CharacterGiveReward(uuid, treasure, 1)
							end
						end)
					elseif ObjectIsItem(uuid) == 1 then
						GenerateTreasure(uuid, treasure, not GameHelpers.Item.IsObject(object) and object.Stats.Level or 1, uuid)
					end
				end

				
				--Buff weapon treasure drop amounts
				--TODO Wait for an extender patch that fixes the bug where updating a table breaks the rarities
				local tt1 = Ext.Stats.TreasureTable.GetLegacy("ST_LLWEAPONEX_VendingMachine")
				if tt1 then
					local dropAmount = 16
					fprint(LOGLEVEL.DEFAULT, "[LeaderLib] Buffing the ST_LLWEAPONEX_VendingMachine treasure table with more drops.")
					for _,sub in pairs(tt1.SubTables) do
						local checkTable = sub.Categories[1] and sub.Categories[1].TreasureTable or ""
						if string.find(checkTable, "Weapons") then
							sub.TotalCount = dropAmount
							--Chance is actually Amount for some reason, and Amount if Chance/Frequency
							sub.DropCounts = {{Amount = dropAmount, Chance = 1}}
						end
					end
					Ext.Stats.TreasureTable.Update(tt1)
				end

				local FixDynamicStatsValueTranslation = {
					CleavePercentage = 0.01,
					WeaponRange = 0.01,
				}

				--These attributes are "Fire", "Air" etc in stats, but FireResistance and so on in the extender
				for k,v in pairs(Mods.WeaponExpansion.Uniques) do
					if v.ProgressionData then
						for _,data in pairs(v.ProgressionData) do
							if data.Attribute == "Skills" then
								data.IsBoost = false
							elseif data.Attribute == "Fire" then
								data.Attribute = "FireResistance"
							elseif data.Attribute == "Air" then
								data.Attribute = "AirResistance"
							end
						end
					end
				end

				Mods.WeaponExpansion.EquipmentManager.SyncItemStatChanges = function (item, changes, dynamicIndex)
					if changes.Boosts ~= nil and changes.Boosts["Damage Type"] ~= nil then
						changes.Boosts["DamageType"] = changes.Boosts["Damage Type"]
						changes.Boosts["Damage Type"] = nil
					end
					local slot = GameHelpers.Item.GetSlot(item, true)
					local owner = GameHelpers.Item.GetOwner(item)
					if owner then
						owner = owner.NetID
					end
					if item ~= nil and item.NetID ~= nil then
						--Fix for CleavePercentage not being correctly translated from the stat attribute (20 = 0.2)
						if changes then
							if changes.Stats then
								for k,mult in pairs(FixDynamicStatsValueTranslation) do
									if changes.Stats[k] then
										local value = Ext.StatGetAttribute(item.StatsId, k)
										if value and value > 0 then
											changes.Stats[k] = value * mult
										end
									end
								end
							end
						end
						local data = {
							ID = item.StatsId,
							UUID = item.MyGuid,
							NetID = item.NetID,
							Slot = slot,
							Owner = owner,
							Changes = changes
						}
						if Mods.WeaponExpansion.EquipmentManager.ItemIsNearPlayers(item) then
							GameHelpers.Net.Broadcast("LLWEAPONEX_SetItemStats", data)
						end
					end
				end

				Timer.StartOneshot("LeaderLib_WeaponEx_FixProgression", 1000, function ()
					--Fix for duplicate skills and incorrect cleave percentages
					for k,v in pairs(Mods.WeaponExpansion.Uniques) do
						local hasSkills = false
						if v.ProgressionData then
							for _,data in pairs(v.ProgressionData) do
								if data.Attribute == "Skills" then
									hasSkills = true
								end
							end
						end
						if hasSkills then
							local item = GameHelpers.GetItem(v.UUID)
							if item then
								item.Stats.DynamicStats[2].Skills = ""
								local syncData = {
									ID = item.StatsId,
									UUID = item.MyGuid,
									NetID = item.NetID,
									Slot = GameHelpers.Item.GetSlot(item, true),
									Owner = GameHelpers.GetNetID(GameHelpers.Item.GetOwner(item)) or nil,
									Changes = {
										Boosts = {
											Skills = "",
										},
										Stats = {}
									}
								}
								local cleave = Ext.StatGetAttribute(item.StatsId, "CleavePercentage")
								if cleave > 0 then
									syncData.Changes.Stats.CleavePercentage = cleave * 0.01
								end
								if Mods.WeaponExpansion.EquipmentManager.ItemIsNearPlayers(item) then
									GameHelpers.Net.Broadcast("LLWEAPONEX_SetItemStats", syncData)
								end
							end
						end
					end
				end)

				--Fix Custom alignment entities may fail to load when the game is loaded multiple times it seems
				--Harken = "e446752a-13cc-4a88-a32e-5df244c90d8b",
				local uuid = "e446752a-13cc-4a88-a32e-5df244c90d8b"
				if ObjectExists(uuid) == 1 then
					local faction = GetFaction(uuid)
					if StringHelpers.IsNullOrWhitespace(faction) then
						if GameHelpers.Character.IsPlayer(uuid) then
							SetFaction(uuid, "Hero LLWEAPONEX_Harken")
							if StringHelpers.IsNullOrWhitespace(GetFaction(uuid)) then
								SetFaction(uuid, "Hero Henchman Fighter")
							end
						else
							SetFaction(uuid, "Good NPC")
						end
					end
				end
				--Korvash = "3f20ae14-5339-4913-98f1-24476861ebd6"
				uuid = "3f20ae14-5339-4913-98f1-24476861ebd6"
				if ObjectExists(uuid) == 1 then
					local faction = GetFaction(uuid)
					if StringHelpers.IsNullOrWhitespace(faction) then
						if GameHelpers.Character.IsPlayer(uuid) then
							SetFaction(uuid, "Hero LLWEAPONEX_Korvash")
							if StringHelpers.IsNullOrWhitespace(GetFaction(uuid)) then
								SetFaction(uuid, "Hero Henchman Inquisitor")
							end
						else
							SetFaction(uuid, "Good NPC")
						end
					end
				end
			end
		end
	}
}

local function PatchMods(initialized)
	for uuid,data in pairs(Patches) do
		if Ext.Mod.IsModLoaded(uuid) and (not data.Version or GameHelpers.GetModVersion(uuid, true) <= data.Version) then
			data.Patch(initialized)
		end
	end
end

Ext.Events.StatsLoaded:Subscribe(function(e) PatchMods(false) end)
Events.Initialized:Subscribe(function(e) PatchMods(true) end, {Priority=999})