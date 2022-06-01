local _ISCLIENT = Ext.IsClient()

if not _ISCLIENT then
	---@param target EsvCharacter
	local function OnStatusChanged(target)
		if GameHelpers.Ext.ObjectIsCharacter(target) then
			Timer.Cancel("LeaderLib_HideWeapon_ToggleWeaponAttachmentEffects", target.MyGuid)
			Timer.StartObjectTimer("LeaderLib_HideWeapon_ToggleWeaponAttachmentEffects", target.MyGuid, 60)
		end
	end
	StatusManager.Register.Applied("LEADERLIB_HIDE_WEAPON", function(target, status, source, statusType, state)
		OnStatusChanged(target)
	end)

	StatusManager.Register.Removed("LEADERLIB_HIDE_WEAPON", function(target, status, source, statusType, state)
		OnStatusChanged(target)
	end)

	Timer.Subscribe("LeaderLib_HideWeapon_ToggleWeaponAttachmentEffects", function (e)
		if e.Data.Object then
			GameHelpers.Net.Broadcast("LeaderLib_HideWeapon_ToggleWeaponAttachmentEffects", {
				NetID=e.Data.Object.NetID,
				Enabled=GameHelpers.Status.IsActive(e.Data.Object, "LEADERLIB_HIDE_WEAPON") == false
			})
		end
	end)
else
	---@param visual ExtenderClientVisual
	local function TryGetAlphaFactor(visual)
		if visual.SubObjects then
			for _,v in pairs(visual.SubObjects) do
				if v.Renderable ~= nil and v.Renderable.ActiveAppliedMaterial ~= nil then
					local mat = v.Renderable.ActiveAppliedMaterial
					if mat.Material then
						for _,prop in pairs(mat.Material.MaterialParameters.Scalars) do
							if prop.Parameter == "AlphaFactor" then
								return true,prop.Value or 1
							end
						end
					end
				end
			end
		end
		return false,1
	end

	---@param visual ExtenderClientVisual
	---@return boolean
	---@return number
	local function HasAlphaFactorMaterial(visual)
		local b,hasAlpha,currentAmount = xpcall(TryGetAlphaFactor, debug.traceback, visual)
		if b then
			return hasAlpha,currentAmount
		else
			Ext.PrintError(hasAlpha)
		end
		return false,1
	end
	
	local _lastAlphaAmounts = {}
	local function SaveLastAlphaFactorAmount(netId, handle, amount)
		if _lastAlphaAmounts[netId] == nil then
			_lastAlphaAmounts[netId] = {}
		end
		table.insert(_lastAlphaAmounts[netId], {
			Handle = handle,
			Amount = amount
		})
	end

	---@param target EclCharacter
	---@param enabled boolean
	local function ToggleWeaponEffects(target, enabled)
		local alpha = enabled and 1 or 0
		for _,attachment in pairs(GameHelpers.Visual.GetAttachedWeaponEffectVisuals(target, true)) do
			local changeAlpha,currentAmount = HasAlphaFactorMaterial(attachment.Visual)
			if changeAlpha then
				local doubleHandle = Ext.HandleToDouble(attachment.Visual.Handle)
				if not enabled then
					if currentAmount > 0 and currentAmount < 1 then
						SaveLastAlphaFactorAmount(target.NetID, doubleHandle, currentAmount)
					end
				else
					local lastValues = _lastAlphaAmounts[target.NetID]
					if lastValues then
						for i,v in pairs(lastValues) do
							if v.Handle == doubleHandle then
								table.remove(_lastAlphaAmounts, i)
								alpha = v.Amount
							end
						end
						if #lastValues == 0 then
							_lastAlphaAmounts[target.NetID] = nil
						end
					end
				end
				attachment.Visual:OverrideScalarMaterialParameter("AlphaFactor", alpha)
			end
		end
	end

	Ext.RegisterNetListener("LeaderLib_HideWeapon_ToggleWeaponAttachmentEffects", function (cmd, payload)
		local data = Common.JsonParse(payload)
		fassert(type(data) == "table", "Failed to parse payload '%s'", payload)
		assert(data.NetID ~= nil, "A NetID is required.")
		local character = GameHelpers.GetCharacter(data.NetID)
		if character then
			ToggleWeaponEffects(character, data.Enabled == true)
			if data.Enabled ~= true then
				_lastAlphaAmounts[character.NetID] = nil
			end
		else
			fprint(LOGLEVEL.WARNING, "[LeaderLib_HideWeapon_ToggleWeaponAttachmentEffects] Failed to get character with NetID (%s)", data.NetID)
		end
	end)
end