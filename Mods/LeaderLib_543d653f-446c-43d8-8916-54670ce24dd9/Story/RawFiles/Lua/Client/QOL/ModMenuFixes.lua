local _UI_IDS = {
	[Data.UIType.mods] = true,
	[Data.UIType.mods_c] = true,
}
local _fixingMods = false

Ext.Events.UIObjectCreated:Subscribe(function (e)
	if _UI_IDS[e.UI.Type] then
		_fixingMods = false
		e.UI:CaptureExternalInterfaceCalls()
		e.UI:CaptureInvokes()
	end
end)

Events.LuaReset:Subscribe(function (e)
	for id,b in pairs(_UI_IDS) do
		local ui = Ext.UI.GetByType(id)
		if ui then
			ui:CaptureExternalInterfaceCalls()
			ui:CaptureInvokes()
		end
	end
end)

---@param ui UIObject
local function OnAddCampaign(ui)
	if not _fixingMods then
		_fixingMods = true
		local t = ui.Type
		Timer.StartOneshot("LeaderLib_RecheckMods", 250, function (e)
			_fixingMods = false
			local _activeMods = {}
			local _lastIndex = 0
			for i,v in pairs(Ext.Mod.GetLoadOrder()) do
				local mod = Ext.Mod.GetMod(v)
				if mod then
					_activeMods[mod.Info.Name] = true
					_lastIndex = i - 1
				end
			end

			local ui = Ext.UI.GetByType(t)
			if not ui then
				return
			end
			local this = ui:GetRoot()
			if not this then
				return
			end
			local len = #this.mods_mc.addonList.content_array-1
			for i=0,len do
				if i > _lastIndex then
					break
				end
				local mod_mc = this.mods_mc.addonList.content_array[i]
				if mod_mc and _activeMods[mod_mc.uName] then
					if not Vars.ControllerEnabled then
						--fprint(LOGLEVEL.TRACE, "mod[%s] _state(%s) _buttonState(%s) uName(%s)", mod_mc.id, mod_mc.checkBox_mc._state, mod_mc.checkBox_mc._buttonState, mod_mc.uName)
						if mod_mc.checkBox_mc._state ~= 1 then
							mod_mc.checkBox_mc.state = 1
							--ExternalInterface.call("checkBoxClicked",this.id,this.checkBox_mc.state);
							ui:ExternalInterfaceCall("checkBoxClicked", mod_mc.id, 1)
						end
					else
						if mod_mc._modState ~= 1 then
							mod_mc.setState(1)
							ui:ExternalInterfaceCall("checkBoxClicked", mod_mc.id, 1)
						end
					end
				end
			end
			_fixingMods = false
		end)
	end
end

for t,b in pairs(_UI_IDS) do
	-- Ext.RegisterUITypeInvokeListener(t, "addAlterMod", function(ui, ...)
	-- 	print(...)
	-- end, "After")
	Ext.RegisterUITypeInvokeListener(t, "addCampaign", OnAddCampaign, "After")
end

-- Ext.Events.UIInvoke:Subscribe(function (e)
-- 	if _UI_IDS[e.UI.Type] then
-- 		if e.When == "After" then
-- 			if e.Function == "addCampaign" then
-- 				OnAddCampaign(e.UI)
-- 			elseif e.Function == "addAlterMod" then
-- 				print(e.Function, table.unpack(e.Args))
-- 			end
-- 		end
-- 	end
-- end)