--param1:Number, param2:Boolean, param3:String, param4:Boolean = false

---@param ui UIObject
local function PrintCall(ui, call, ...)
	print("[PrintCall]",call, Ext.JsonStringify({...}))
end

local rebuildingBars = false

---@param ui UIObject
local function HideMaxBarAmount(ui, call, percentage, doTween, text, someBool, isFromLua)
	if isFromLua ~= true and text ~= "" then
		print(call, percentage, doTween, text, someBool)
		local nextText = string.gsub(text, "%d+/", "")
		ui:Invoke(call, percentage, doTween, nextText, someBool, true)
	end
end

---@param ui UIObject
local function HideMaxHealthAmount(ui, call, percentage, text, doTween)
	if text ~= "" then
		--print(call, percentage, doTween, text, doTween, string.find(text, "/"))
		if string.find(text, "/") then
			local nextText = string.gsub(text, "%d+/", "")
			ui:Invoke(call, percentage, nextText, doTween)
		end
	end
end

---@param ui UIObject
local function DisplayRacialTalents(ui, call, ...)
	local player = nil
	local handle = ui:GetPlayerHandle()
	if handle ~= nil then
		player = Ext.GetCharacter(handle)
	end
	if player ~= nil then
		print("updateArraySystem", player.MyGuid)
		--PrintArray(ui, "tags_array")
		-- local i = GetArrayIndexStart(ui, "talent_array", 1)
		-- ui:SetValue("talent_array", "Undead", i)
		-- ui:SetValue("talent_array", Data.TalentEnum.Zombie, i+1)
		-- ui:SetValue("talent_array", 0, i+2)
		-- ui:SetValue("talent_array", "Corpse Eater", i+3)
		-- ui:SetValue("talent_array", Data.TalentEnum.Elf_CorpseEating, i+4)
		-- ui:SetValue("talent_array", 0, i+5)
		-- PrintArray(ui, "talent_array")
	end
end

Ext.RegisterListener("SessionLoaded", function()
	-- Ext.RegisterUINameInvokeListener("setHPBars", PrintCall)
	-- Ext.RegisterUINameInvokeListener("updateInfos", PrintCall)
	-- Ext.RegisterUINameInvokeListener("setHPBars", PrintCall)
	-- Ext.RegisterUINameInvokeListener("setArmourBar", PrintCall)
	-- Ext.RegisterUINameInvokeListener("setMagicArmourBar", PrintCall)

	-- Ext.RegisterUINameCall("setArmourBar", function(...)
	-- 	if Features.HideMaxArmor then
	-- 		HideMaxBarAmount(...)
	-- 	end
	-- end)
	-- Ext.RegisterUINameCall("setMagicArmourBar", function(...)
	-- 	if Features.HideMaxMagicArmor then
	-- 		HideMaxBarAmount(...)
	-- 	end
	-- end)
	-- Ext.RegisterUINameCall("setHPBars", function(...)
	-- 	if Features.HideMaxMagicArmor then
	-- 		HideMaxHealthAmount(...)
	-- 	end
	-- end)

	local ui = Ext.GetBuiltinUI("Public/Game/GUI/enemyHealthBar.swf")
	if ui ~= nil then
		Ext.RegisterUIInvokeListener(ui, "setArmourBar", function(...)
			print("setArmourBar")
			if Features.HideMaxArmor then
				HideMaxBarAmount(...)
			end
		end)
		Ext.RegisterUIInvokeListener(ui, "setMagicArmourBar", function(...)
			if Features.HideMaxMagicArmor then
				HideMaxBarAmount(...)
			end
		end)
		Ext.RegisterUIInvokeListener(ui, "setHPBars", function(...)
			if Features.HideMaxMagicArmor then
				HideMaxHealthAmount(...)
			end
		end)
	else
		print("enemyHealthBar not found")
	end
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
	if ui ~= nil then
		---@param ui UIObject
		Ext.RegisterUIInvokeListener(ui, "updateArraySystem", function(...)
			if Features.RacialTalentsDisplayFix then
				DisplayRacialTalents(...)
			end
		end)
	end
end)

Ext.RegisterNetListener("LeaderLib_EnableUIFeatures", function(call, featuresString)
	Features = Ext.JsonParse(featuresString)
end)