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