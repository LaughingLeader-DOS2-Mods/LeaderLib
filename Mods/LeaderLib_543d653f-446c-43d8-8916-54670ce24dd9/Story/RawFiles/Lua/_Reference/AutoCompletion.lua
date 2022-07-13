---@diagnostic disable

--This file is never actually loaded, and is used to make EmmyLua work better.

if not Mods then Mods = {} end
if not Mods.LeaderLib then Mods.LeaderLib = {} end
if not Mods.LeaderLib.Listeners then
	Mods.LeaderLib.Listeners = {}
end
if not Mods.LeaderLib.Import then
	Mods.LeaderLib.Import = Import
end

---@alias DamageType string|"None"|"Physical"|"Piercing"|"Corrosive"|"Magic"|"Chaos"|"Fire"|"Air"|"Water"|"Earth"|"Poison"|"Shadow"
---@alias DeathType string|"Sulfur"|"FrozenShatter"|"Surrender"|"Lifetime"|"KnockedDown"|"Piercing"|"Physical"|"Sentinel"|"DoT"|"Explode"|"Arrow"|"None"|"Acid"|"PetrifiedShatter"|"Hang"|"Incinerate"|"Electrocution"
---@alias ItemSlot string|"Weapon"|"Shield"|"Helmet"|"Breast"|"Gloves"|"Leggings"|"Boots"|"Belt"|"Amulet"|"Ring"|"Ring2"|"Wings"|"Horns"|"Overhead"|"Sentintel"