---@type target string
---@type source string
---@type damage integer
---@type handle integer
local function OnPrepareHit(target, source, damage, handle)
	if Ext.IsDeveloperMode() then
		Ext.Print(string.format("[NRD_OnPrepareHit] Target(%s) Source(%s) damage(%i) Handle(%s) HitType(%s)", target, source, damage, handle, NRD_HitGetString(handle, "HitType")))
		--Debug_TraceHitPrepare(target, source, damage, handle)
	end
	local length = #Listeners.OnPrepareHit
	if length > 0 then
		for i=1,length do
			local callback = Listeners.OnPrepareHit[i]
			local status,err = xpcall(callback, debug.traceback, target, source, damage, handle)
			if not status then
				Ext.PrintError("[LeaderLib:HitListeners.lua] Error calling function for 'OnPrepareHit':\n", err)
			end
		end
	end
end

RegisterProtectedOsirisListener("NRD_OnPrepareHit", 4, "before", function(target, attacker, damage, handle)
	OnPrepareHit(StringHelpers.GetUUID(target), StringHelpers.GetUUID(attacker), damage, handle)
end)

function GameHelpers.ApplyBonusWeaponStatuses(source, target)
	if ObjectIsCharacter(source) == 1 then
		for i,status in pairs(Ext.GetCharacter(source):GetStatuses()) do
			if type(status) ~= "string" and status.StatusId ~= nil then
				status = status.StatusId
			end
			if not Data.EngineStatus[status] then
				local potion = nil
				if type(status) == "string" then
					potion = Ext.StatGetAttribute(status, "StatsId")
				elseif status.StatusId ~= nil then
					potion = Ext.StatGetAttribute(status.StatusId, "StatsId")
				end
				if potion ~= nil and potion ~= "" then
					local bonusWeapon = Ext.StatGetAttribute(potion, "BonusWeapon")
					if bonusWeapon ~= nil and bonusWeapon ~= "" then
						local extraProps = Ext.StatGetAttribute(bonusWeapon, "ExtraProperties")
						if extraProps ~= nil then
							GameHelpers.ApplyProperties(target, source, extraProps)
						end
					end
				end
			end
		end
	end
end

---@type target string
---@type source string
---@type damage integer
---@type handle integer
local function OnHit(target, source, damage, handle)
	--print(target,source,damage,handle,HasActiveStatus(source, "AOO"),HasActiveStatus(target, "AOO"))
	if Ext.IsDeveloperMode() then 
		Ext.Print(string.format("[NRD_OnHit] Target(%s) Source(%s) damage(%i) Handle(%i) HitType(%s)", target, source, damage, handle, NRD_StatusGetInt(target, handle, "HitReason")))
	end
	local skillprototype = NRD_StatusGetString(target, handle, "SkillId")
	local skill = nil
	if skillprototype ~= "" and skillprototype ~= nil then
		skill = string.gsub(skillprototype, "_%-?%d+$", "")
		OnSkillHit(source, skill, target, handle, damage)
	end

	if source ~= nil and Features.ApplyBonusWeaponStatuses == true and GameHelpers.HitWithWeapon(target, handle, nil, nil, source) then
		GameHelpers.ApplyBonusWeaponStatuses(source, target)
	end

	local length = #Listeners.OnHit
	if length > 0 then
		for i=1,length do
			local callback = Listeners.OnHit[i]
			local status,err = xpcall(callback, debug.traceback, target, source, damage, handle, skill)
			if not status then
				Ext.PrintError("[LeaderLib:HitListeners.lua] Error calling function for 'OnHit':\n", err)
			end
		end
	end
end

RegisterProtectedOsirisListener("NRD_OnHit", 4, "before", function(target, attacker, damage, handle)
	OnHit(StringHelpers.GetUUID(target), StringHelpers.GetUUID(attacker), damage, handle)
end)