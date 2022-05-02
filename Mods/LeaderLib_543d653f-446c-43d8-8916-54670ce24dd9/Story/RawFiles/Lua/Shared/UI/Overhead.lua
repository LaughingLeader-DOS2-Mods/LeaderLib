local isClient = Ext.IsClient()

---@class OverheadHelpers
local Overhead = {}



if isClient then
	Overhead.UI = Classes.UIWrapper:CreateFromType(Data.UIType.overhead, {IsControllerSupported=true})

	Ext.RegisterNetListener("LeaderLib_Overhead_AddDamage", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			assert(type(data.NetID) == "number", "[LeaderLib_Overhead_AddDamage] A valid NetID number is required.")
			assert(type(data.Amount) == "number", "[LeaderLib_Overhead_AddDamage] A valid Amount number is required.")
			--assert(type(data.DamageType) == "string", "[LeaderLib_Overhead_AddDamage] A valid DamageType string is required.")
			Overhead.AddDamage(data.NetID, data.Amount, data.DamageType)
		end
	end)
end

---@param target EsvCharacter|EclCharacter|NETID|UUID
---@param amount integer
---@param damageType DAMAGE_TYPE
function Overhead.AddDamage(target, amount, damageType)
	--public function addOverheadDamage(charID:Number, text:String) : *
	if not isClient then
		GameHelpers.Net.Broadcast("LeaderLib_Overhead_AddDamage", {
			NetID=GameHelpers.GetNetID(target),
			Amount=amount,
			DamageType=damageType})
	else
		local object = GameHelpers.TryGetObject(target)
		if object then
			local charID = Ext.HandleToDouble(object.Handle)
			damageType = damageType or "None"
			local text = GameHelpers.GetDamageText(damageType, amount, true)
			local root = Overhead.UI:GetRoot()
			root.updateOHs()
			root.clearObsoleteOHTs()
			-- root.addOverheadDamage(charID, text)
			-- root.clearObsoleteOHTs()
			-- Overhead.UI:Invoke("addOverheadDamage", charID, text)
			-- Overhead.UI:Invoke("clearObsoleteOHTs")
		else
			fprint(LOGLEVEL.ERROR, "[Overhead.AddDamage] Failed to get character with ID (%s)", target)
		end
	end
end

--Mods.LeaderLib.GameHelpers.UI.Overhead.AddDamage(me.MyGuid, 10, "Fire")

GameHelpers.UI.Overhead = Overhead