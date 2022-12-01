local _ISCLIENT = Ext.IsClient()

--Updates the treasure tables to spawn more items, and spawn items at other traders. This is until the 1.0 update is released
--Ext.IO.AddPathOverride("Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Stats/Generated/TreasureTable.txt", "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Overrides/Patches/LLWEAPONEX_TreasureTable.txt")

local Patches = {
	--Weapon Expansion
	["c60718c3-ba22-4702-9c5d-5ad92b41ba5f"] = {
		Version = 153288705,
		Patch = function (initialized, region)
			Ext.Utils.PrintWarning("[LeaderLib] Patching Weapon Expansion version [153288706]")

			local path = Ext.IO.GetPathOverride("Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Scripts/LLWEAPONEX_Statuses.gameScript")
			if path ~= "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Overrides/Patches/LLWEAPONEX_Statuses.gameScript" then
				--Patches an event name conflict that prevented Soul Harvest's bonus from applying.
				Ext.IO.AddPathOverride("Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Scripts/LLWEAPONEX_Statuses.gameScript", "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Overrides/Patches/LLWEAPONEX_Statuses.gameScript")
			end
			
			if not initialized then
				return
			end

			local stat = Ext.Stats.Get("ARM_LLWEAPONEX_HandCrossbow_A", nil, false)
			if stat and stat.ObjectCategory ~= "LLWEAPONEX_HandCrossbows" then
				stat.ObjectCategory = "LLWEAPONEX_HandCrossbows"
				--if not _ISCLIENT then Ext.Stats.Sync("ARM_LLWEAPONEX_HandCrossbow_A", false) end
			end

			--These keys were possibly never exported
			for k,v in pairs({
				LLWEAPONEX_DEMON_GAUNTLET_BONUS_CRIT_DisplayName = "Demonic Surge",
				LLWEAPONEX_DEMON_GAUNTLET_BONUS_CRIT_Description = "The demon has slain an enemy.<font color='#ee3f70'>100% Critical Chance for your next attack or skill.</font>",
			}) do
				if StringHelpers.IsNullOrEmpty(Ext.L10N.GetTranslatedStringFromKey(k)) then
					Ext.L10N.CreateTranslatedString(k,v)
				end
			end

			if _ISCLIENT then
				---@diagnostic disable-next-line undefined-field
				Ext._Internal._NetListeners["LLWEAPONEX_SetWorldTooltipText"] = nil

				local ts = Classes.TranslatedString
				local TwoHandedText = ts:Create("h3fb5cd5ag9ec8g4746g8f9cg03100b26bd3a", "Two-Handed")
				local LLWEAPONEX_Unarmed = ts:Create("h1e98bcebg2e42g4699gba2bg6f647d428699", "Unarmed")
				local WeaponTypeNames = {
					--LLWEAPONEX_Bludgeon = {Text=ts:Create("h448753f3g7785g4681gb639ga0e9d58bfadd", "Bludgeon")},
					--LLWEAPONEX_RunicCannon = {Text=ts:Create("h702bf925gf664g45a7gb3f5g34418bfa2c56", "Runic Weaponry")},
					LLWEAPONEX_Banner = {Text=ts:Create("hbe8ca1e2g4683g4a93g8e20g984992e30d22", "Banner")},
					LLWEAPONEX_BattleBook = {Text=ts:Create("he053a3abge5d8g4d14g9333ga18d6eba3df1", "Battle Book")},
					LLWEAPONEX_DualShields = {Text=ts:Create("h00157a58g9ae0g4119gba1ag3f1e9f11db14", "Dual Shields")},
					LLWEAPONEX_Firearm = {Text=ts:Create("h8d02e345ged4ag4d60g9be9g68a46dda623b", "Firearm")},
					LLWEAPONEX_Greatbow = {Text=ts:Create("h52a81f92g3549g4cb4g9b18g066ba15399c0", "Greatbow")},
					LLWEAPONEX_Katana = {Text=ts:Create("he467f39fg8b65g4136g828fg949f9f3aef15", "Katana"), TwoHandedText=ts:Create("hd1f993bag9dadg49cbga5edgb92880c38e46", "Odachi")},
					LLWEAPONEX_Quarterstaff = {Text=ts:Create("h8d11d8efg0bb8g4130g9393geb30841eaea5", "Quarterstaff")},
					LLWEAPONEX_Polearm = {Text=ts:Create("hd61320b6ge4e6g4f51g8841g132159d6b282", "Polearm")},
					LLWEAPONEX_Rapier = {Text=ts:Create("h84b2d805gff5ag44a5g9f81g416aaf5abf18", "Rapier")},
					LLWEAPONEX_Runeblade = {Text=ts:Create("hb66213fdg1a98g4127ga55fg429f9cde9c6a", "Runeblade")},
					LLWEAPONEX_Scythe = {Text=ts:Create("h1e98bd0bg867dg4a57gb2d4g6d820b4e7dfa", "Scythe")},
					LLWEAPONEX_Unarmed = {Text=LLWEAPONEX_Unarmed},
					LLWEAPONEX_Rod = {Text=ts:Create("heb1c0428g158fg46d6gafa3g6d6143534f37", "One-Handed Scepter")},
					--LLWEAPONEX_Dagger = {Text=ts:Create("h697f3261gc083g4152g84cdgbe559a5e0388", "Dagger")}
				}
				local UniqueWeaponTypeTags = {
					LLWEAPONEX_UniqueBokken1H = ts:Create("h5264ef62gdc22g401fg8b62g303379cd7693", "Wooden Katana"),
					LLWEAPONEX_Blunderbuss = ts:Create("h59b52860gd0e3g4e65g9e61gd66b862178c3", "Blunderbuss"),
					LLWEAPONEX_RunicCannon = ts:Create("h702bf925gf664g45a7gb3f5g34418bfa2c56", "Runic Weaponry"),
					LLWEAPONEX_UniqueWarchiefHalberdSpear = WeaponTypeNames.LLWEAPONEX_Polearm.Text,
					LLWEAPONEX_UniqueWarchiefHalberdAxe = ts:Create("h42439ac8g67ddg48dag810fgf7319b62dc0d", "Axe"),
				}
				
				local UniqueWeaponTypeTagsDisplayTwoHanded = {
					LLWEAPONEX_UniqueBokken2H = true,
					LLWEAPONEX_UniqueWarchiefHalberdAxe = true,
				}
				local weaponTypePreferenceOrder = {
					"LLWEAPONEX_Rapier",
					"LLWEAPONEX_RunicCannon",
					"LLWEAPONEX_Banner",
					"LLWEAPONEX_BattleBook",
					"LLWEAPONEX_DualShields",
					"LLWEAPONEX_Greatbow",
					"LLWEAPONEX_Katana",
					"LLWEAPONEX_Quarterstaff",
					"LLWEAPONEX_Polearm",
					"LLWEAPONEX_Scythe",
					"LLWEAPONEX_Unarmed",
					"LLWEAPONEX_Runeblade",
					"LLWEAPONEX_Rod",
					"LLWEAPONEX_Firearm",
				}

				---@param item EclItem
				---@param _TAGS table<string,boolean>|nil
				function GetItemTypeText(item, _TAGS)
					if not _TAGS then
						_TAGS = GameHelpers.GetAllTags(item, true)
					end
					for tag,t in pairs(UniqueWeaponTypeTags) do
						if _TAGS[tag] then
							if UniqueWeaponTypeTagsDisplayTwoHanded[tag] and item.Stats.IsTwoHanded then
								return TwoHandedText.Value .. " " .. t.Value
							else
								return t.Value
							end
						end
					end
					local typeText = ""
					for i=1,#weaponTypePreferenceOrder do
						local tag = weaponTypePreferenceOrder[i]
						if _TAGS[tag] then
							local renameWeaponType = WeaponTypeNames[tag]
							if renameWeaponType ~= nil then
								if item.Stats.IsTwoHanded and renameWeaponType.TwoHandedText ~= nil and not Game.Math.IsRangedWeapon(item.Stats) then
									typeText = StringHelpers.Append(typeText, renameWeaponType.TwoHandedText.Value, " ")
								else
									typeText = StringHelpers.Append(typeText, renameWeaponType.Text.Value, " ")
								end
							end
						end
					end
					return typeText
				end

				local worldTooltipTypeText = '%s<font size="15"><br>%s</font>'

				Events.OnWorldTooltip:Subscribe(function(e)
					if e.Item and e.IsFromItem then
						local typeText = GetItemTypeText(e.Item)
						if not StringHelpers.IsNullOrEmpty(typeText) then
							local nextText = ""
							local startPos,endPos = string.find(e.Text, '<font size="15"><br>.-</font>')
							if startPos then
								nextText = string.format(worldTooltipTypeText, string.sub(e.Text, 0, startPos-1), typeText)
							else
								nextText = string.format(worldTooltipTypeText, e.Text, typeText)
							end
							e.Text = nextText
						end
					end
				end, {Priority=1})
			else
				--#region Treasure

				--Boost battle book base damage to be closer to _Swords/_Clubs
				for _,v in pairs({
					"_LLWEAPONEX_BattleBooks_1H",
					"WPN_LLWEAPONEX_BattleBook_1H",
					"WPN_LLWEAPONEX_BattleBook_A",
					"WPN_LLWEAPONEX_BattleBook_B",
					"WPN_LLWEAPONEX_BattleBook_C",
					"WPN_LLWEAPONEX_BattleBook_D",
					"WPN_LLWEAPONEX_BattleBook_E",
					"WPN_LLWEAPONEX_BattleBook_F",
				}) do
					local stat = Ext.Stats.Get(v, nil, false)
					if stat and stat.DamageFromBase == 55 then
						stat.DamageFromBase = 63
						Ext.Stats.Sync(v, false)
					end
				end

				--Ext.Stats.TreasureTable.Update(Ext.Stats.TreasureTable.GetLegacy("ST_WeaponLegendary"))
				--Buff weapon treasure drop amounts
				local tt1 = Ext.Stats.TreasureTable.GetLegacy("ST_LLWEAPONEX_VendingMachine")
				if tt1 then
					fprint(LOGLEVEL.DEFAULT, "[LeaderLib] Buffing the ST_LLWEAPONEX_VendingMachine treasure table with more drops.")
					for _,sub in pairs(tt1.SubTables) do
						local checkTable = sub.Categories[1] and sub.Categories[1].TreasureTable or ""
						if string.find(checkTable, "Weapons") then
							sub.DropCounts = {{Amount = 16, Chance = 1}}
						end
					end
					Ext.Stats.TreasureTable.Update(tt1)
				end

				local _HCCAT = "LLWEAPONEX_HandCrossbows"

				local hccatTable = Ext.Stats.TreasureCategory.GetLegacy("LLWEAPONEX_HandCrossbows")
				if not hccatTable then
					local cat = {
						Category = "LLWEAPONEX_HandCrossbows",
						Items = {
							{
								ActPart = 0,
								MaxAmount = 1,
								MaxLevel = 0,
								MinAmount = 1,
								MinLevel = 1,
								Name = "ARM_LLWEAPONEX_HandCrossbow_A",
								Priority = 1,
								Unique = 0
							}
						}
					}
					Ext.Stats.TreasureCategory.Update("LLWEAPONEX_HandCrossbows", cat)
				end

				---@type table<string, StatTreasureTableCategory[]>
				local _AppendCategories = {}
				---@param tableName string
				---@vararg StatTreasureTableCategory
				local _ac = function (tableName, ...)
					_AppendCategories[tableName] = {...}
				end
				local _regularCommonHC = {TreasureCategory = _HCCAT, Common = 1}
				_ac("ST_LLWEAPONEX_AllWeapons", {TreasureCategory = _HCCAT})
				_ac("ST_LLWEAPONEX_RangedNormal", _regularCommonHC)
				_ac("ST_LLWEAPONEX_Trader_RangedNormal", _regularCommonHC)
				_ac("ST_LLWEAPONEX_RingAmuletBelt", _regularCommonHC)

				local _tryUpdateTable = function(st, data)
					for _,cat in pairs(data) do
						---@type StatTreasureTableCategory
						local appendCat = {
							Common = 0,
							Divine = 0,
							Epic = 0,
							Frequency = 1,
							Legendary = 0,
							Rare = 0,
							Uncommon = 0,
							Unique = 0,
						}
						if type(cat) == "table" then
							for k,v in pairs(cat) do
								appendCat[k] = v
							end
						else
							fprint(LOGLEVEL.WARNING, "[LeaderLib:_AppendCategories] Wrong category type? (%s)", type(cat))
							Ext.Utils.PrintError(Ext.Dump(data))
						end
						if appendCat.TreasureTable or appendCat.TreasureCategory then
							st.Categories[#st.Categories+1] = appendCat
						end
					end
				end

				for tableName,data in pairs(_AppendCategories) do
					local tt = Ext.Stats.TreasureTable.GetLegacy(tableName)
					if tt then
						local clone = TableHelpers.Clone(tt)
						local st = tt.SubTables[1]
						if st then
							local b,err = xpcall(_tryUpdateTable, debug.traceback, st, data)
							if not b then
								Ext.Utils.PrintWarning(err)
							end
						end
						local b,err = xpcall(Ext.Stats.TreasureTable.Update, debug.traceback, tt)
						if not b then
							Ext.Utils.PrintWarning(err)
							fprint(LOGLEVEL.ERROR, "[LeaderLib] Error updating TreasureTable (%s)", tableName)
							--Revert
							Ext.Stats.TreasureTable.Update(clone)
						end
					end
				end

				---@type table<string, StatTreasureTableSubTable[]>
				local _AppendSubtables = {}
				---@param tableName string
				---@vararg StatTreasureTableSubTable
				local _ast = function (tableName, ...)
					_AppendSubtables[tableName] = {...}
				end
				---@type StatTreasureTableSubTable
				local _regularCommonHCST = {DropCounts={{Amount=0, Chance=1},{Amount=1,Chance=2}},Categories={TreasureCategory = _HCCAT, Common = 1}}
				local _regularCommonHCST2 = {DropCounts={{Amount=0, Chance=1},{Amount=2,Chance=4}},Categories={TreasureCategory = _HCCAT, Common = 1}}
				local _regularCommonHCST3 = {DropCounts={{Amount=1,Chance=1}},Categories={TreasureCategory = _HCCAT, Common=10, Uncommon=2,Rare=1,}}
				_ast("ST_Trader_WeaponRogue", _regularCommonHCST)
				_ast("ST_Trader_WeaponArcher", _regularCommonHCST)
				_ast("ST_QuestReward_Easy_Choice_Extra", _regularCommonHCST2)
				_ast("ST_QuestReward_High_Choice_Extra", _regularCommonHCST2)
				_ast("FTJ_GhettoGuard", _regularCommonHCST3)
				_ast("FTJ_BlackMarketDealer", _regularCommonHCST3)
				_ast("RC_WC_BombScientist", {Categories={TreasureTable = "ST_LLWEAPONEX_FirearmsNormal", Common=8, Rare=6, Uncommon=3}})

				for tableName,data in pairs(_AppendSubtables) do
					local tt = Ext.Stats.TreasureTable.GetLegacy(tableName)
					if tt then
						local clone = TableHelpers.Clone(tt)
						for _,st in pairs(data) do
							---@type StatTreasureTableSubTable
							local appendSub = {
								DropCounts = {{Amount=1,Chance=1}},
								Categories = {},
								TotalCount = 1,
								TotalFrequency = 1,
							}
							for k,v in pairs(st) do
								if k == "Categories" then
									---@type StatTreasureTableCategory
									local appendCat = {
										Common = 0,
										Divine = 0,
										Epic = 0,
										Frequency = 1,
										Legendary = 0,
										Rare = 0,
										Uncommon = 0,
										Unique = 0,
									}
									if type(v) == "table" then
										for k,v in pairs(v) do
											appendCat[k] = v
										end
									else
										fprint(LOGLEVEL.WARNING, "[LeaderLib:_AppendCategories] Wrong category type? (%s)", type(v))
										Ext.Utils.PrintError(Ext.Dump(data))
									end
									if appendCat.TreasureTable or appendCat.TreasureCategory then
										appendSub.Categories[#appendSub.Categories+1] = appendCat
									end
								else
									appendSub[k] = v
								end
							end
							tt.SubTables[#tt.SubTables+1] = appendSub
						end
						local b,err = xpcall(Ext.Stats.TreasureTable.Update, debug.traceback, tt)
						if not b then
							Ext.Utils.PrintWarning(err)
							fprint(LOGLEVEL.ERROR, "[LeaderLib] Error updating TreasureTable (%s)", tableName)
							Ext.Stats.TreasureTable.Update(clone)
						end
					end
				end

				--#end-region

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
							NRD_HitAddDamage(handle, tostring(damage.DamageType), damage.Amount)
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
					if (v.Owner == nil or v.Owner == Mods.WeaponExpansion.NPC.UniqueHoldingChest or GetRegion(v.UUID) == "")
					and not StringHelpers.IsNullOrEmpty(v.DefaultOwner) 
					and v.DefaultOwner ~= Mods.WeaponExpansion.NPC.UniqueHoldingChest
					and ObjectGetFlag(v.UUID, "LLWEAPONEX_UniqueData_Initialized") == 1 then
						local item = GameHelpers.GetItem(v.UUID)
						if item then
							local owner = GameHelpers.Item.GetOwner(v.UUID)
							if owner == nil or owner.MyGuid == Mods.WeaponExpansion.NPC.UniqueHoldingChest then
								if ObjectExists(v.DefaultOwner) == 1 then
									ItemToInventory(v.UUID, v.DefaultOwner, 1, 0, 1)
									fprint(LOGLEVEL.WARNING, "[LeaderLib:WeaponEx] Moved unique (%s) to '%s' since it was incorrectly without an owner.", k, GameHelpers.GetDisplayName(v.DefaultOwner))
								else
									ItemToInventory(v.UUID, Mods.WeaponExpansion.NPC.VendingMachine, 1, 0, 1)
									fprint(LOGLEVEL.WARNING, "[LeaderLib:WeaponEx] Moved unique (%s) to the 'Strange Machine' since it was incorrectly without an owner.", k)
								end
							end
						end
					end
				end

				---@param item EsvItem
				---@param changes table
				---@param dynamicIndex integer|nil
				Mods.WeaponExpansion.EquipmentManager.SyncItemStatChanges = function (item, changes, dynamicIndex)
					if changes.Boosts ~= nil and changes.Boosts["Damage Type"] ~= nil then
						changes.Boosts["DamageType"] = changes.Boosts["Damage Type"]
						changes.Boosts["Damage Type"] = nil
					end
					local slot = GameHelpers.Item.GetSlot(item, true)
					---@type CharacterParam|integer|nil
					local owner = GameHelpers.Item.GetOwner(item)
					if owner then
						owner = owner.NetID
					end
					if item ~= nil and item.NetID ~= nil then
						--Fix for CleavePercentage not being correctly translated from the stat attribute (20 = 0.2)
						if changes and changes.Stats and item.StatsFromName then
							for k,mult in pairs(FixDynamicStatsValueTranslation) do
								if changes.Stats[k] then
									local value = item.StatsFromName.StatsEntry[k]
									if value and value > 0 then
										changes.Stats[k] = value * mult
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
							if item and item.Stats then
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
								if item.StatsFromName then
									local cleave = item.StatsFromName.StatsEntry.CleavePercentage
									if cleave > 0 then
										syncData.Changes.Stats.CleavePercentage = cleave * 0.01
									end
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

				--ArmCannon fix for the max energy tag not being cleared
				Ext.Osiris.RegisterListener("LLWEAPONEX_ArmCannon_SetEnergyTags", 3, "after", function (char, weapon, energy)
					local maxEnergy = GameHelpers.GetExtraData("LLWEAPONEX_RunicCannon_MaxEnergy", 3, true)
					if energy > 0 and energy < maxEnergy then
						Osi.LeaderLib_Tags_ClearPreservedTag(char, "LLWEAPONEX_ArmCannon_FullyCharged")
						Osi.LeaderLib_Statuses_RemovePermanentStatus(char, "LLWEAPONEX_ARMCANNON_CHARGED")
						GameHelpers.UI.SetSkillEnabled(char, "Zone_LLWEAPONEX_ArmCannon_Disperse", false)
					end
				end)

				--FIX Add safeguards for making sure Frostdyne gets moved
				Mods.WeaponExpansion.FortJoyEvent = function(event)
					if event == "AlexanderDefeated" then
						--Ext.Print(string.format("[FJ_AlexanderDefeated] Owner(%s) Alex(%s) Pos(%s)", Uniques.DivineBanner.Owner, NPC.BishopAlexander, Common.Dump(Ext.GetCharacter(NPC.BishopAlexander).WorldPos)))
						if Mods.WeaponExpansion.Uniques.DivineBanner.Owner == Mods.WeaponExpansion.NPC.BishopAlexander then
							local x,y,z = GetPosition(Mods.WeaponExpansion.NPC.BishopAlexander)
							if x == nil then
								x,y,z = GetPosition(Mods.WeaponExpansion.NPC.Dallis)
							end
							Mods.WeaponExpansion.Uniques.DivineBanner:ReleaseFromOwner(true)
							ItemScatterAt(Mods.WeaponExpansion.Uniques.DivineBanner.UUID, x, y, z)
							PlayEffectAtPosition("RS3_FX_Skills_Divine_Barrage_Impact_01", x, y, z)
						end
					elseif event == "SlaneReward" then
						local frostDyne = Mods.WeaponExpansion.Uniques.Frostdyne
						local slane = Mods.WeaponExpansion.NPC.Slane
						local chest = Mods.WeaponExpansion.NPC.UniqueHoldingChest
						if StringHelpers.IsNullOrEmpty(frostDyne.Owner) or frostDyne.Owner == slane or frostDyne.Owner == chest then
							frostDyne:ReleaseFromOwner(true)
							if CharacterIsDead(slane) == 1 then
								ItemToInventory(frostDyne.UUID, slane, 1, 0, 1)
							else
								local x,y,z = GetPosition(slane)
								if not x then
									x = 583.75
									z = 167.02076721191406
								end
								y = GameHelpers.Grid.GetY(x,z) + 0.15
								ItemScatterAt(frostDyne.UUID, x, y, z)
							end
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