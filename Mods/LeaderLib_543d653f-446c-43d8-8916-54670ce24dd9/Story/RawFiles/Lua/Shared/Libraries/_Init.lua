if Lib == nil then Lib = {} end
if Classes == nil then Classes = {} end

local maf = Ext.Require("Shared/Libraries/maf.lua")
---@type Vector3
Classes.Vector3 = maf.Vector3
---@type Quaternion
Classes.Quaternion = maf.Quaternion

Lib.maf = maf

---@type inspect
Lib.inspect = Ext.Require("Shared/Libraries/inspect.lua")

---@type smallfolk
Lib.smallfolk = Ext.Require("Shared/Libraries/smallfolk.lua")

---@type serpent
Lib.serpent = Ext.Require("Shared/Libraries/serpent.lua")