local _ISCLIENT = Ext.IsClient()

local function _FixHandCrossbows()
	local stat = Ext.Stats.Get("ARM_LLWEAPONEX_HandCrossbow_A", nil, false)
	if stat and stat.ObjectCategory ~= "LLWEAPONEX_HandCrossbows" then
		stat.ObjectCategory = "LLWEAPONEX_HandCrossbows"
		--if not _ISCLIENT then Ext.Stats.Sync("ARM_LLWEAPONEX_HandCrossbow_A", false) end
	end
end

local _FixTooltips,_FixTreasure = nil,nil

if _ISCLIENT then
	Ext.Events.NetMessageReceived:Subscribe(function (e)
		if e.Channel == "LLWEAPONEX_SetItemStats" then
			local data = Common.JsonParse(e.Payload)
			if data and data.Changes and data.Changes.Requirements then
				data.Changes.Requirements = nil
				e.Payload = Common.JsonStringify(data)
			end
		end	
	end, {Priority=101})

	_FixTooltips = function()
		Game.Tooltip.Register.Skill(function (character, skill, tooltip)
			if skill == "Projectile_LLWEAPONEX_ChaosSlash" then
				local desc = tooltip:GetDescriptionElement()
				if desc then
					desc.Label = desc.Label:gsub("A surface also created", "A surface is also created")
				end
			end
		end)

		Game.Tooltip.Register.Item(function (item, tooltip)
			local desc = tooltip:GetDescriptionElement()
			if desc and string.find(desc.Label, "Combine this with specific unique weapons to change their scaling attribute") then
				desc.Label = desc.Label:gsub("Combine this with specific unique weapons to change their scaling attribute", "Combine this with any weapon to change the scaling attribute")
			end
		end)

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
		---@param _TAGS? table<string,boolean>
		local function GetItemTypeText(item, _TAGS)
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
	end
else
	Events.Initialized:Subscribe(function (_)
		if not Mods.WeaponExpansion or not Mods.WeaponExpansion.PersistentVars then
			return
		end
		if Mods.WeaponExpansion.PersistentVars.AttributeRequirementChanges then
			local existingChanges = {}
			for itemGUID,attribute in pairs(Mods.WeaponExpansion.PersistentVars.AttributeRequirementChanges) do
				if Osi.ObjectExists(itemGUID) == 1 then
					existingChanges[itemGUID] = attribute
					local item = GameHelpers.GetItem(itemGUID)
					if item then
						for _,req in pairs(item.Stats.Requirements) do
							if req.Requirement ~= attribute and Data.AttributeEnum[req.Requirement] then
								req.Requirement = attribute
							end
						end
						GameHelpers.Net.Broadcast("LeaderLib_LLWEAPONEX_ChangeAttributeRequirement", {Item=item.NetID, Attribute=attribute})
					end
				end
			end
			Mods.WeaponExpansion.PersistentVars.AttributeRequirementChanges = existingChanges
		else
			Mods.WeaponExpansion.PersistentVars.AttributeRequirementChanges = {}
		end
	end, {Priority=0})

	_FixTreasure = function ()
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

		--Make tokens work with non-uniques
		local recipe = Ext.Stats.ItemCombo.GetLegacy("LLWEAPONEX_Token_ChangeScalingAttribute")
		if recipe then
			if recipe.Ingredients[1].Object == "UniqueWeapon" then
				recipe.Ingredients[1].Object = "Weapon"
				Ext.Stats.ItemCombo.Update(recipe)
			end
		end

		if not Ext.Stats.ItemComboPreview.GetLegacy("ObjectCategories_Weapon") then
			---@type ItemComboPreviewData
			local weaponCategoryPreview = {
				Icon = "LLWEAPONEX_CraftingCategory_UniqueWeapon",
				Name = "Weapon",
				StatsId = "",
				Tooltip = "ObjectCategories_Weapon_Tooltip",
				Type = "ObjectCategories",
			}
			Ext.Stats.ItemComboPreview.Update(weaponCategoryPreview)
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
	end
end

---@param current string[]
---@vararg string
---@return boolean changed
---@return string[]|nil	categories
local function AppendComboCategory(current, ...)
	local categories = {}
	for i=1,#current do
		categories[current[i]] = true
	end
	local changed = false
	local args = {...}
	for i=1,#args do
		local v = args[i]
		if not categories[v] then
			categories[v] = true
			changed = true
		end
	end
	if not changed then
		return false
	end
	local result = {}
	for v,_ in pairs(categories) do
		result[#result+1] = v
	end
	table.sort(result)
	return true,result
end

return {

Version = 153288705,
Patch = function (initialized, region)
	Ext.Utils.PrintWarning("[LeaderLib] Patching Weapon Expansion version [153288706]")

	local path = Ext.IO.GetPathOverride("Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Scripts/LLWEAPONEX_Statuses.gameScript")
	if path ~= "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Overrides/Patches/LLWEAPONEX_Statuses.gameScript" then
		--Patches an event name conflict that prevented Soul Harvest's bonus from applying.
		Ext.IO.AddPathOverride("Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Scripts/LLWEAPONEX_Statuses.gameScript", "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Overrides/Patches/LLWEAPONEX_Statuses.gameScript")
	end

	if Ext.L10N.CreateTranslatedStringKey("ObjectCategories_Weapon_Tooltip", "hafb9b0ebg208eg43acg9c49gedfa393f6e87") then
		Ext.L10N.CreateTranslatedStringHandle("hafb9b0ebg208eg43acg9c49gedfa393f6e87", "Any Weapon")
	end
	
	if not initialized then
		-- Add the Weapon combo category
		for _,id in pairs(Ext.Stats.GetStats("Weapon")) do
			local stat = Ext.Stats.Get(id)
			---@cast stat StatEntryWeapon
			if stat.Unique == 1 then
				local b,newCategories = AppendComboCategory(stat.ComboCategory, "UniqueWeapon", "Weapon")
				if b then
					---@cast newCategories string[]
					stat.ComboCategory = newCategories
				end
			else
				local b,newCategories = AppendComboCategory(stat.ComboCategory, "Weapon")
				if b then
					---@cast newCategories string[]
					stat.ComboCategory = newCategories
				end
			end
		end

		return
	end

	_FixHandCrossbows()

	--These keys were possibly never exported
	for k,v in pairs({
		LLWEAPONEX_DEMON_GAUNTLET_BONUS_CRIT_DisplayName = "Demonic Surge",
		LLWEAPONEX_DEMON_GAUNTLET_BONUS_CRIT_Description = "The demon has slain an enemy.<font color='#ee3f70'>100% Critical Chance for your next attack or skill.</font>",
	}) do
		if StringHelpers.IsNullOrEmpty(Ext.L10N.GetTranslatedStringFromKey(k)) then
			Ext.L10N.CreateTranslatedString(k,v)
		end
	end

	--Fix the moving object preventing the projectile hit
	local chaosSlash = Ext.Stats.Get("Projectile_LLWEAPONEX_ChaosSlash", nil, false)
	if chaosSlash then
		chaosSlash.MovingObject = ""
	end

	if _ISCLIENT then
		_FixTooltips()

		---@param data table
		GameHelpers.Net.Subscribe("LeaderLib_LLWEAPONEX_ChangeAttributeRequirement", function(e, data)
			if data and data.Item and data.Attribute then
				local item = GameHelpers.GetItem(data.Item)
				if item then
					for _,req in pairs(item.Stats.Requirements) do
						if Data.AttributeEnum[req.Requirement] then
							req.Requirement = data.Attribute
						end
					end
				end
			end
		end)
	else
		_FixTreasure()

		local _SurfHandles = {}
		local _GroundSurfaces = {"Fire", "Water", "WaterFrozen", "WaterElectrified", "Blood", "BloodFrozen", "BloodElectrified", "Poison", "Oil"}
		local _ChaosSlash = {"Projectile_LLWEAPONEX_ChaosSlash", "Projectile_LLWEAPONEX_EnemyChaosSlash"}

		SkillManager.Subscribe.Cast(_ChaosSlash, function (e)
			GameHelpers.DB.TryDelete("DB_LLWEAPONEX_Skills_Temp_ChaosSlashCaster", e.CharacterGUID)
		end)

		SkillManager.Subscribe.ProjectileShoot(_ChaosSlash, function (e)
			local surfaceType = Common.GetRandomTableEntry(_GroundSurfaces)
			local surf = Ext.Surface.Action.Create("ChangeSurfaceOnPathAction") --[[@as EsvChangeSurfaceOnPathAction]]
			surf.SurfaceType = surfaceType
			surf.FollowObject = e.Data.Handle
			surf.Duration = 6.0
			surf.Radius = 0.4
			surf.IgnoreIrreplacableSurfaces = true
			surf.StatusChance = 1.0
			surf.Position = e.Data.Position
			_SurfHandles[e.Character.Handle] = {Handle=surf.MyHandle, SurfaceType=surfaceType}
			Ext.Surface.Action.Execute(surf)
		end)

		SkillManager.Subscribe.ProjectileHit(_ChaosSlash, function (e)
			local data = _SurfHandles[e.Character.Handle]
			if data then
				GameHelpers.Surface.CreateSurface(e.Data.Position, data.SurfaceType, GameHelpers.Stats.GetAttribute(e.Skill, "ExplodeRadius", 2), 6.0, e.Character.Handle, true)
				_SurfHandles[e.Character.Handle] = nil
				Ext.Surface.Action.Cancel(data.Handle)
			else
				GameHelpers.Surface.CreateSurface(e.Data.Position, Common.GetRandomTableEntry(_GroundSurfaces), GameHelpers.Stats.GetAttribute(e.Skill, "ExplodeRadius", 2), 6.0, e.Character.Handle, true)
			end
		end)

		--Sync attribute token changes without requiring a save/load

		local attributeTokenTemplates = {
			["c77de879-b29b-4707-a75c-2c42adc0712b"] = "Strength",
			["95284549-f8c1-496b-af36-9d96565f6c0f"] = "Finesse",
			["bc8c81a1-106d-49ef-beac-e97678ba9b16"] = "Intelligence",
			["d360798f-50e3-4c9e-b0e5-0c69345b1a92"] = "Constitution",
			["1a3acb90-a152-4ebd-8b02-c5fe99f6c0e3"] = "Memory",
			["dfb3db93-2562-46d2-9cd1-5ea5b57b72b9"] = "Wits",
			["27dbe9dd-bf08-4c9f-b79a-01f806e24759"] = "Reset",
		}

		local function _GetAttributeTokenAttribute(entries)
			for i,entry in pairs(entries) do
				local attribute = attributeTokenTemplates[entry.Template]
				if attribute ~= nil then
					return attribute,entry.Item
				end
			end
			return nil
		end

		local function _CraftingTemplateMatch(entries, template, minCount)
			local count = 0
			for i,v in pairs(entries) do
				if template == "NULL_00000000-0000-0000-0000-000000000000" and v == template then
					count = count + 1
				elseif not StringHelpers.IsNullOrEmpty(v) and string.find(v, template) then
					count = count + 1
				end
			end
			return count >= minCount
		end

		local craftingActions = {}

		---@param char string
		Mods.WeaponExpansion.OnCraftingProcessed = function(char, ...)
			local itemArgs = {...}
			local items = {}
			for i,v in pairs(itemArgs) do
				if not StringHelpers.IsNullOrEmpty(v) then
					v = StringHelpers.GetUUID(v)
					local template = GameHelpers.GetTemplate(v)
					items[#items+1] = {
						Template = template,
						Item = v
					}
				end
			end
			craftingActions[StringHelpers.GetUUID(char)] = items
		end

		---@param char string
		---@param a string|nil	Combined template
		---@param b string|nil	Combined template
		---@param c string|nil	Combined template
		---@param d string|nil	Combined template
		---@param e string|nil	Combined template
		---@param newItem string
		Mods.WeaponExpansion.ItemTemplateCombinedWithItemTemplate = function(char, a, b, c, d, e, newItem)
			--Ext.Print("[WeaponExpansion:ItemTemplateCombinedWithItemTemplate]",char, a, b, c, d, e, newItem)
			local craftingEntries = craftingActions[StringHelpers.GetUUID(char)]
			if craftingEntries ~= nil then
				local attribute,tokenItem = _GetAttributeTokenAttribute(craftingEntries)
				if attribute ~= nil then
					for _,v in pairs(craftingEntries) do
						if v ~= tokenItem then
							local item = GameHelpers.GetItem(v.Item)
							if item and not GameHelpers.Item.IsObject(item) and item.Stats.ItemType == "Weapon" then
								Mods.WeaponExpansion.ChangeItemScaling(item, attribute, item.Stats.Name)
							end
						end
					end
				end
				craftingActions[char] = nil
			end

			local templates = {a,b,c,d,e}
			-- LOOT_LLWEAPONEX_Token_Shard_dcd92e16-80a6-43bc-89c5-8e147d95606c
			-- 3 shards = a new attribute token of choice
			if _CraftingTemplateMatch(templates, "dcd92e16%-80a6%-43bc%-89c5%-8e147d95606c", 3)
			and _CraftingTemplateMatch(templates, "NULL_00000000-0000-0000-0000-000000000000", 2) then
				Osi.CharacterGiveQuestReward(char, "LLWEAPONEX_Rewards_AttributeToken", "QuestReward")
			end
		end

		---@param item EsvItem
		---@param attribute string
		---@param itemStat string
		Mods.WeaponExpansion.ChangeItemScaling = function (item, attribute, itemStat)
			if Mods.WeaponExpansion.PersistentVars.AttributeRequirementChanges == nil then
				Mods.WeaponExpansion.PersistentVars.AttributeRequirementChanges = {}
			end

			if attribute == "Reset" then
				Mods.WeaponExpansion.PersistentVars.AttributeRequirementChanges[item.MyGuid] = nil
				for _,req in pairs(item.StatsFromName.StatsEntry.Requirements) do
					if Data.AttributeEnum[req.Requirement] then
						attribute = tostring(req.Requirement)
						break
					end
				end
			else
				Mods.WeaponExpansion.PersistentVars.AttributeRequirementChanges[item.MyGuid] = attribute
			end

			if not StringHelpers.IsNullOrEmpty(attribute) and attribute ~= "Reset" then
				for _,req in pairs(item.Stats.Requirements) do
					if Data.AttributeEnum[req.Requirement] then
						req.Requirement = attribute
						break
					end
				end
			
				GameHelpers.Net.Broadcast("LeaderLib_LLWEAPONEX_ChangeAttributeRequirement", {Item=item.NetID, Attribute=attribute})
			end
		end

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
			local nextItem = Osi.ObjectExists(nextGUID) == 1 and GameHelpers.GetItem(nextGUID) or nil
			local equippedItem = Osi.ObjectExists(equippedGUID) == 1 and GameHelpers.GetItem(equippedGUID) or nil
			if nextItem and equippedItem then
				local isTwoHanded = false
				local locked = equippedItem.UnEquipLocked
				if nextItem.Stats.ItemType == "Weapon" then
					isTwoHanded = nextItem.Stats.IsTwoHanded
				end
				local slot = GameHelpers.Item.GetEquippedSlot(char,equippedItem) or GameHelpers.Item.GetEquippedSlot(char,nextItem) or "Weapon"
		
				Osi.ItemLockUnEquip(equippedItem.MyGuid, 0)
				Osi.ItemLockUnEquip(nextItem.MyGuid, 0)
				--CharacterUnequipItem(char, equipped)
		
				if not isTwoHanded then
					local currentEquipped = StringHelpers.GetUUID(Osi.CharacterGetEquippedItem(char, slot))
					if not StringHelpers.IsNullOrEmpty(currentEquipped) and currentEquipped ~= equippedGUID then
						Osi.ItemLockUnEquip(currentEquipped, 0)
						Osi.CharacterUnequipItem(char, currentEquipped)
					end
					Osi.NRD_CharacterEquipItem(char, nextItem.MyGuid, slot, 0, 0, 1, 1)
				else
					local mainhand,offhand = GameHelpers.Character.GetEquippedWeapons(char)
					if mainhand and mainhand.MyGuid ~= equippedItem.MyGuid then
						Osi.ItemLockUnEquip(mainhand.MyGuid, 0)
						Osi.CharacterUnequipItem(char, mainhand.MyGuid)
					end
					if offhand and offhand.MyGuid ~= equippedItem.MyGuid then
						Osi.ItemLockUnEquip(offhand.MyGuid, 0)
						Osi.CharacterUnequipItem(char, offhand.MyGuid)
					end
					Osi.NRD_CharacterEquipItem(char, nextItem.MyGuid, "Weapon", 0, 0, 1, 1)
				end
		
				if locked then
					Osi.ItemLockUnEquip(nextItem.MyGuid, 1)
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
				if Osi.NRD_HitGetInt(handle, prop) ~= val then
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
				local isCombinedHit = isLizard and Osi.NRD_HitGetInt(handle, "ProcWindWalker") == 0
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
				Osi.NRD_HitClearAllDamage(handle)
				--NRD_HitStatusClearAllDamage(target, handle)
				local damages = damageList:AsArray()
				local totalDamage = 0
				for i,damage in pairs(damages) do
					Osi.NRD_HitAddDamage(handle, tostring(damage.DamageType), damage.Amount)
					totalDamage = totalDamage + damage.Amount
				end
				if lizardHits[attacker] == 2 then
					lizardHits[attacker] = nil
				end
			end
		end

		--Fix this flag not being cleared
		Osi.ObjectClearFlag("680d2702-721c-412d-b083-4f5e816b945a", "LLWEAPONEX_VendingMachine_OrderMenuDisabled", 0)

		--FIX Vending Machine ordering bug, from the backpack inventory being accessed too soon. Also identifies items it generates.
		Mods.WeaponExpansion.GenerateTradeTreasure = function(uuid, treasure)
			if uuid == "680d2702-721c-412d-b083-4f5e816b945a" then
				Osi.ObjectClearFlag(uuid, "LLWEAPONEX_VendingMachine_OrderMenuDisabled", 0)
				--This event was mistakenly not fired like it was previously, causing the order flag to not clear
				Osi.SetStoryEvent(uuid, "LLWEAPONEX_VendingMachine_OnOrderGenerated")
			end
			local object = GameHelpers.TryGetObject(uuid)
			if Osi.ObjectIsCharacter(uuid) == 1 then
				local x,y,z = Osi.GetPosition(uuid)
				--LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830
				local backpackGUID = Osi.CreateItemTemplateAtPosition("98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
				Timer.StartOneshot("", 50, function ()
					fprint(LOGLEVEL.TRACE, "[WeaponExpansion:GenerateTradeTreasure] Generating treasure table (%s) for (%s)", treasure, object.DisplayName, uuid)
					local backpack = GameHelpers.GetItem(backpackGUID)
					if backpack then
						Osi.GenerateTreasure(backpackGUID, treasure, object.Stats.Level, uuid)
						Osi.ContainerIdentifyAll(backpackGUID)
						for i,v in pairs(backpack:GetInventoryItems()) do
							local tItem = GameHelpers.GetItem(v)
							if tItem ~= nil then
								tItem.UnsoldGenerated = true -- Trade treasure flag
								Osi.ItemToInventory(v, uuid, tItem.Amount, 0, 0)
							else
								Osi.ItemToInventory(v, uuid, 1, 0, 0)
							end
							Osi.ItemSetOwner(v, uuid)
							Osi.ItemSetOriginalOwner(v, uuid)
						end
						Osi.ItemRemove(backpackGUID)
					else
						Ext.Utils.PrintError("[WeaponExpansion:GenerateTradeTreasure] Failed to create backpack from root template 'LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830'")
						Osi.CharacterGiveReward(uuid, treasure, 1)
					end
				end)
			elseif Osi.ObjectIsItem(uuid) == 1 then
				Osi.GenerateTreasure(uuid, treasure, not GameHelpers.Item.IsObject(object) and object.Stats.Level or 1, uuid)
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
			if (v.Owner == nil or v.Owner == Mods.WeaponExpansion.NPC.UniqueHoldingChest or Osi.GetRegion(v.UUID) == "")
			and not StringHelpers.IsNullOrEmpty(v.DefaultOwner) 
			and v.DefaultOwner ~= Mods.WeaponExpansion.NPC.UniqueHoldingChest
			and Osi.ObjectGetFlag(v.UUID, "LLWEAPONEX_UniqueData_Initialized") == 1 then
				local item = GameHelpers.GetItem(v.UUID)
				if item then
					local owner = GameHelpers.Item.GetOwner(v.UUID)
					if owner == nil or owner.MyGuid == Mods.WeaponExpansion.NPC.UniqueHoldingChest then
						if Osi.ObjectExists(v.DefaultOwner) == 1 then
							Osi.ItemToInventory(v.UUID, v.DefaultOwner, 1, 0, 1)
							fprint(LOGLEVEL.WARNING, "[LeaderLib:WeaponEx] Moved unique (%s) to '%s' since it was incorrectly without an owner.", k, GameHelpers.GetDisplayName(v.DefaultOwner))
						else
							Osi.ItemToInventory(v.UUID, Mods.WeaponExpansion.NPC.VendingMachine, 1, 0, 1)
							fprint(LOGLEVEL.WARNING, "[LeaderLib:WeaponEx] Moved unique (%s) to the 'Strange Machine' since it was incorrectly without an owner.", k)
						end
					end
				end
			end
		end

		---@param item EsvItem
		---@param changes table
		---@param dynamicIndex? integer
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
		if Osi.ObjectExists(uuid) == 1 then
			local faction = Osi.GetFaction(uuid)
			if StringHelpers.IsNullOrWhitespace(faction) then
				if GameHelpers.Character.IsPlayer(uuid) then
					Osi.SetFaction(uuid, "Hero LLWEAPONEX_Harken")
					if StringHelpers.IsNullOrWhitespace(Osi.GetFaction(uuid)) then
						Osi.SetFaction(uuid, "Hero Henchman Fighter")
					end
				else
					Osi.SetFaction(uuid, "Good NPC")
				end
			end
		end
		--Korvash = "3f20ae14-5339-4913-98f1-24476861ebd6"
		uuid = "3f20ae14-5339-4913-98f1-24476861ebd6"
		if Osi.ObjectExists(uuid) == 1 then
			local faction = Osi.GetFaction(uuid)
			if StringHelpers.IsNullOrWhitespace(faction) then
				if GameHelpers.Character.IsPlayer(uuid) then
					Osi.SetFaction(uuid, "Hero LLWEAPONEX_Korvash")
					if StringHelpers.IsNullOrWhitespace(Osi.GetFaction(uuid)) then
						Osi.SetFaction(uuid, "Hero Henchman Inquisitor")
					end
				else
					Osi.SetFaction(uuid, "Good NPC")
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

		Vars.DisableDummyStatusRedirection.LLWEAPONEX_GREATBOW_FUTUREBARRAGE_DUMMYHIT = true

		--FIX Add safeguards for making sure Frostdyne gets moved
		Mods.WeaponExpansion.FortJoyEvent = function(event)
			if event == "AlexanderDefeated" then
				--Ext.Print(string.format("[FJ_AlexanderDefeated] Owner(%s) Alex(%s) Pos(%s)", Uniques.DivineBanner.Owner, NPC.BishopAlexander, Common.Dump(Ext.GetCharacter(NPC.BishopAlexander).WorldPos)))
				if Mods.WeaponExpansion.Uniques.DivineBanner.Owner == Mods.WeaponExpansion.NPC.BishopAlexander then
					local x,y,z = Osi.GetPosition(Mods.WeaponExpansion.NPC.BishopAlexander)
					if x == nil then
						x,y,z = Osi.GetPosition(Mods.WeaponExpansion.NPC.Dallis)
					end
					Mods.WeaponExpansion.Uniques.DivineBanner:ReleaseFromOwner(true)
					Osi.ItemScatterAt(Mods.WeaponExpansion.Uniques.DivineBanner.UUID, x, y, z)
					Osi.PlayEffectAtPosition("RS3_FX_Skills_Divine_Barrage_Impact_01", x, y, z)
				end
			elseif event == "SlaneReward" then
				local frostDyne = Mods.WeaponExpansion.Uniques.Frostdyne
				local slane = Mods.WeaponExpansion.NPC.Slane
				local chest = Mods.WeaponExpansion.NPC.UniqueHoldingChest
				if StringHelpers.IsNullOrEmpty(frostDyne.Owner) or frostDyne.Owner == slane or frostDyne.Owner == chest then
					frostDyne:ReleaseFromOwner(true)
					if Osi.CharacterIsDead(slane) == 1 then
						Osi.ItemToInventory(frostDyne.UUID, slane, 1, 0, 1)
					else
						local x,y,z = Osi.GetPosition(slane)
						if not x then
							x = 583.75
							z = 167.02076721191406
						end
						y = GameHelpers.Grid.GetY(x,z) + 0.15
						Osi.ItemScatterAt(frostDyne.UUID, x, y, z)
					end
				end
			end
		end
	end
end
}