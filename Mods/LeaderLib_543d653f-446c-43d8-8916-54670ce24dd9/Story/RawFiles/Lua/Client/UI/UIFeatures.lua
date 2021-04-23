--param1:Number, param2:Boolean, param3:String, param4:Boolean = false

---@param ui UIObject
local function PrintCall(ui, call, ...)
	print("[PrintCall]",call, Ext.JsonStringify({...}))
end

local PATTERN_HIDE_CURRENT = "%d+/"
local PATTERN_HIDE_MAX = "/%d+"

local PATTERNS = {
	[1] = PATTERN_HIDE_MAX,
	[2] = PATTERN_HIDE_CURRENT,
}

---@param ui UIObject
local function ModifyBarText(pattern, ui, call, percentage, doTween, text, someBool)
	if text ~= "" then
		return percentage, doTween, string.gsub(text, pattern, ""), someBool
	end
end

---@param ui UIObject
local function ModifyHealthText(pattern, ui, call, percentage, text, doTween)
	if text ~= "" then
		return percentage, doTween, string.gsub(text, pattern, ""), doTween
	end
end

function UI.GetArrayIndexStart(ui, arrayName, offset)
	local i = 0
	while i < 9999 do
		local val = ui:GetValue(arrayName, "number", i)
		if val == nil then
			val = ui:GetValue(arrayName, "string", i)
			if val == nil then
				val = ui:GetValue(arrayName, "boolean", i)
			end
		end
		if val == nil then
			return i
		end
		i = i + offset
	end
	return -1
end

function UI.IsInArray(ui, arrayName, id, start, offset)
	local i = start
	while i < 200 do
		local check = ui:GetValue(arrayName,"number", i)
		if check ~= nil and math.tointeger(check) == id then
			return true
		end
		i = i + offset
	end
	return false
end

---@param ui UIObject
local function DisplayTalents(ui, call, ...)
	---@type EsvCharacter
	local player = nil
	local handle = ui:GetPlayerHandle()
	if handle ~= nil then
		player = Ext.GetCharacter(handle)
	elseif Client.Character ~= nil then
		player = Client:GetCharacter()
	end
	if player ~= nil then
		TalentManager.Update(ui, player)
		local length = #Listeners.OnTalentArrayUpdating
		if length > 0 then
			for i=1,length do
				local callback = Listeners.OnTalentArrayUpdating[i]
				local talentArrayStartIndex = UI.GetArrayIndexStart(ui, "talent_array", 3)
				local b,err = xpcall(callback, debug.traceback, ui, player, talentArrayStartIndex, Data.TalentEnum)
				if not b then
					Ext.PrintError("Error calling function for 'OnTalentArrayUpdating':\n", err)
				end
			end
		end
		--UI.PrintArray(ui, "talent_array")
	end
end

-- addTalentElement(talentId:uint, talentName:String, state:Boolean, choosable:Boolean, isRacial:Boolean) : *

---@param ui UIObject
local function DisplayTalents_CC(ui, call, ...)
	if GameSettings.Default == nil then
		-- This function may run before the game is "Running" and the settings load normally.
		LoadGameSettings()
	end

	---@type EsvCharacter
	local player = nil
	local handle = ui:GetPlayerHandle()
	if handle ~= nil then
		player = Ext.GetCharacter(handle)
	elseif  Client.Character ~= nil then
		player = Client:GetCharacter()
	end
	if player ~= nil then
		local root = ui:GetRoot()
		local talent_mc = root.CCPanel_mc.talents_mc
		TalentManager.Update_CC(ui, talent_mc, player)
	end
end

local function AddToCombatLog(text)
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/combatLog.swf")
	if ui ~= nil then
		ui:Invoke("addTextToTab", 0, text)
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
	-- 		ModifyBarText(...)
	-- 	end
	-- end)
	-- Ext.RegisterUINameCall("setMagicArmourBar", function(...)
	-- 	if Features.HideMaxMagicArmor then
	-- 		ModifyBarText(...)
	-- 	end
	-- end)
	-- Ext.RegisterUINameCall("setHPBars", function(...)
	-- 	if Features.HideMaxMagicArmor then
	-- 		ModifyHealthText(...)
	-- 	end
	-- end)

	local ui = Ext.GetBuiltinUI("Public/Game/GUI/enemyHealthBar.swf")
	if ui ~= nil then
		Ext.RegisterUIInvokeListener(ui, "setArmourBar", function(...)
			if Features.HideArmor > 0 then
				ModifyBarText(PATTERNS[Features.HideArmor], ...)
			end
		end)
		Ext.RegisterUIInvokeListener(ui, "setMagicArmourBar", function(...)
			if Features.HideMagicArmor > 0 then
				ModifyBarText(PATTERNS[Features.HideMagicArmor], ...)
			end
		end)
		Ext.RegisterUIInvokeListener(ui, "setHPBars", function(...)
			if Features.HideVitality > 0 then
				ModifyHealthText(PATTERNS[Features.HideVitality], ...)
			end
		end)
	end
	Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", DisplayTalents)
	Ext.RegisterUITypeInvokeListener(Data.UIType.statsPanel_c, "updateArraySystem", DisplayTalents)

	--characterCreation.swf
	Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation, "updateTalents", DisplayTalents_CC)
	Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation_c, "updateTalents", DisplayTalents_CC)

	TalentManager.Gamepad.RegisterListeners()
end)