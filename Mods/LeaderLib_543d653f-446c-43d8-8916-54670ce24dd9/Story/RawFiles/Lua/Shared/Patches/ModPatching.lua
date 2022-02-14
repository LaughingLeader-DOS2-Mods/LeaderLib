local isClient = Ext.IsClient()
local function PatchMods()
	if isClient then
				--Weapon Expansion
		if Ext.IsModLoaded("c60718c3-ba22-4702-9c5d-5ad92b41ba5f")
		and Ext.GetModInfo("c60718c3-ba22-4702-9c5d-5ad92b41ba5f").Version <= 153288705
		then
			if Ext.Version() < 56 then
				Ext._NetListeners["LLWEAPONEX_SetWorldTooltipText"] = nil
			else
				Ext._Internal._NetListeners["LLWEAPONEX_SetWorldTooltipText"] = nil			
			end

			Ext.RegisterNetListener("LLWEAPONEX_SetWorldTooltipText", function (text)
				local ui = Ext.GetUIByType(Data.UIType.tooltip)
				if ui then
					local main = ui:GetRoot()
					if main ~= nil then
						local text = e.Payload or ""
						if main.tf ~= nil then
							main.tf.shortDesc = text
							if main.tf.setText ~= nil then
								main.tf.setText(text,0)
							end
						elseif main.defaultTooltip ~= nil then
							main.defaultTooltip.shortDesc = text
							if main.defaultTooltip.setText ~= nil then
								main.defaultTooltip.setText(text,0)
							end
						end
					end
				end
			end)
			-- Ext.Events.NetMessageReceived:Subscribe(function (e)
			-- 	if e.Channel == "LLWEAPONEX_SetWorldTooltipText" then
			-- 		e:StopPropagation()
					
			-- 	end
			-- end)
		end
	end
end

Ext.RegisterListener("SessionLoaded", PatchMods)