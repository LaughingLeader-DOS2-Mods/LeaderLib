local _ISCLIENT = Ext.IsClient()

--Updates the treasure tables to spawn more items, and spawn items at other traders. This is until the 1.0 update is released
--Ext.IO.AddPathOverride("Public/WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f/Stats/Generated/TreasureTable.txt", "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Overrides/Patches/LLWEAPONEX_TreasureTable.txt")

local EmptyAtlas = "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Overrides/EmptyAtlas.lsx"

local Patches = {
	--Weapon Expansion
	[Data.ModID.WeaponExpansion] = Ext.Require("Shared/Patches/WeaponExpansionBeta.lua"),
	--Toggle Sprint DE
	[Data.ModID.ToggleSprintDE] = {
		Patch = function (initialized, region)
			--Override the icon atlas, since LeaderLib has the same icons
			if not Ext.IO.GetPathOverride("Public/ToggleSprintDefinitiveEdition_4dbc489b-f5cb-40c2-bc9c-ac4f6fb20fad/GUI/LLSPRINT_Icons.lsx") then
				Ext.IO.AddPathOverride("Public/ToggleSprintDefinitiveEdition_4dbc489b-f5cb-40c2-bc9c-ac4f6fb20fad/GUI/LLSPRINT_Icons.lsx", EmptyAtlas)
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