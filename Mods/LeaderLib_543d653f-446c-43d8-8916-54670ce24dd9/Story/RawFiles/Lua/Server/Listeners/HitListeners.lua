---@type target string
---@type source string
---@type damage integer
---@type handle integer
function OnPrepareHit(target, source, damage, handle)
	if Ext.IsDeveloperMode() then
		Ext.Print(string.format("[NRD_OnPrepareHit] Target(%s) Source(%s) damage(%i) Handle(%s) HitType(%s)", target, source, damage, handle, NRD_HitGetString(handle, "HitType")))
	end
	if Ext.Version() < 50 then
		if type(damage) == "string" then
			damage = math.tointeger(tonumber(damage))
		end
		if type(handle) == "string" then
			handle = math.tointeger(tonumber(handle))
		end
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

---@type target string
---@type source string
---@type damage integer
---@type handle integer
function OnHit(target, source, damage, handle)
	--print(target,source,damage,handle,HasActiveStatus(source, "AOO"),HasActiveStatus(target, "AOO"))
	--print(string.format("[NRD_OnHit] Target(%s) Source(%s) damage(%i) Handle(%i) HitType(%s)", target, source, damage, handle, NRD_StatusGetString(target, handle, "HitType")))
	
	if Ext.Version() < 50 then
		if type(damage) == "string" then
			damage = math.tointeger(tonumber(damage))
		end
		if type(handle) == "string" then
			handle = math.tointeger(tonumber(handle))
		end
	end

	if target ~= nil then
		target = GetUUID(target)
	end
	if source ~= nil then
		source = GetUUID(source)
	end

	local skillprototype = NRD_StatusGetString(target, handle, "SkillId")
	local skill = nil
	if skillprototype ~= "" and skillprototype ~= nil then
		skill = string.gsub(skillprototype, "_%-?%d+$", "")
		OnSkillHit(source, skill, target, handle, damage)
	end

	if source ~= nil and Features.ApplyBonusWeaponStatuses == true and GameHelpers.HitWithWeapon(target, handle, nil, nil, source) then
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

if Ext.Version() >= 50 then
	Ext.RegisterOsirisListener("NRD_OnPrepareHit", 4, "after", OnPrepareHit)
	Ext.RegisterOsirisListener("NRD_OnHit", 4, "after", OnHit)
end