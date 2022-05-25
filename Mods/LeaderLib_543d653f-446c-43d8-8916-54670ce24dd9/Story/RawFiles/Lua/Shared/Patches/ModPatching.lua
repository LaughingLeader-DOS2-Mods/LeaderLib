local isClient = Ext.IsClient()

local Patches = {
	--Weapon Expansion
	["c60718c3-ba22-4702-9c5d-5ad92b41ba5f"] = {
		Version = 153288706,
		Patch = function (initialized)
			--Fix Patches an event name conflict that prevented Soul Harvest's bonus from applying.
			Ext.AddPathOverride("Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Scripts/LLWEAPONEX_Statuses.gameScript", "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Overrides/Patches/LLWEAPONEX_Statuses.gameScript")
			
			if not initialized then
				return
			end
			if isClient then
				if Ext.Version() < 56 then
					Ext._NetListeners["LLWEAPONEX_SetWorldTooltipText"] = nil
				else
					Ext._Internal._NetListeners["LLWEAPONEX_SetWorldTooltipText"] = nil
				end
	
				Ext.RegisterNetListener("LLWEAPONEX_SetWorldTooltipText", function (cmd, payload)
					local ui = Ext.GetUIByType(Data.UIType.tooltip)
					if ui then
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

				local FixDynamicStatsValueTranslation = {
					CleavePercentage = 0.01,
					WeaponRange = 0.01,
				}

				Mods.WeaponExpansion.EquipmentManager.SyncItemStatChanges = function (item, changes, dynamicIndex)
					if changes.Boosts ~= nil and changes.Boosts["Damage Type"] ~= nil then
						changes.Boosts["DamageType"] = changes.Boosts["Damage Type"]
						changes.Boosts["Damage Type"] = nil
					end
					local slot = Data.EquipmentSlotNames[GameHelpers.Item.GetSlot(item)]
					local owner = nil
					if slot and item.OwnerHandle ~= nil then
						local char = Ext.GetCharacter(item.OwnerHandle)
						if char ~= nil then
							owner = char.NetID
						end
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
									data.IsBoost = false
									hasSkills = true
								end
							end
						end
						if hasSkills then
							local item = Ext.GetItem(v.UUID)
							if item then
								item.Stats.DynamicStats[2].Skills = ""
								local syncData = {
									UUID = item.MyGuid,
									NetID = item.NetID,
									Slot = Data.EquipmentSlotNames[GameHelpers.Item.GetSlot(item)],
									Owner = GameHelpers.GetNetID(ItemGetOwner(item.MyGuid)),
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
								GameHelpers.Net.Broadcast("LLWEAPONEX_SetItemStats", syncData)
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
		if Ext.IsModLoaded(uuid) and Ext.GetModInfo(uuid).Version <= data.Version then
			data.Patch(initialized)
		end
	end
end

Ext.RegisterListener("StatsLoaded", function() PatchMods(false) end)
RegisterListener("Initialized", function() PatchMods(true) end)