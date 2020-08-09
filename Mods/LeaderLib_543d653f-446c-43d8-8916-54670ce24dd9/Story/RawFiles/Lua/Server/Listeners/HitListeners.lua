---@type target string
---@type source string
---@type damage integer
---@type handle integer
function OnPrepareHit(target, source, damage, handle)
	if Ext.Version() < 50 then
		if type(damage) == "string" then
			damage = math.tointeger(tonumber(damage))
		end
		if type(handle) == "string" then
			handle = math.tointeger(tonumber(handle))
		end
	end
	if #Listeners.OnPrepareHit > 0 then
		for i,callback in ipairs(Listeners.OnPrepareHit) do
			local status,err = xpcall(callback, debug.traceback, target, source, damage, handle)
			if not status then
				Ext.PrintError("[LeaderLib:HitListeners.lua] Error calling function for 'OnPrepareHit':\n", err)
			end
		end
	end
end

---@type target string
---@type source string
---@type damage integer
---@type handle integer
function OnHit(target, source, damage, handle)
	if Ext.Version() < 50 then
		if type(damage) == "string" then
			damage = math.tointeger(tonumber(damage))
		end
		if type(handle) == "string" then
			handle = math.tointeger(tonumber(handle))
		end
	end
	local skillprototype = NRD_StatusGetString(target, handle, "SkillId")
	if skillprototype ~= "" and skillprototype ~= nil then
		OnSkillHit(source, skillprototype, target, handle, damage)
	end

	if source ~= nil and Features.ApplyBonusWeaponStatuses == true and GameHelpers.HitWithWeapon(target, handle, nil, nil, source) then
		for i,status in pairs(Ext.GetCharacter(source):GetStatuses()) do
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

	if #Listeners.OnHit > 0 then
		for i,callback in ipairs(Listeners.OnHit) do
			local status,err = xpcall(callback, debug.traceback, target, source, damage, handle)
			if not status then
				Ext.PrintError("[LeaderLib:HitListeners.lua] Error calling function for 'OnHit':\n", err)
			end
		end
	end
end

if Ext.Version() >= 50 then
	Ext.RegisterOsirisListener("NRD_OnPrepareHit", 4, "after", OnPrepareHit)
	Ext.RegisterOsirisListener("NRD_OnHit", 4, "after", OnHit)
end