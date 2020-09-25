---@class MainMenuMC
---@field addOptionButton fun(label:string, callback:string, id:integer, isCurrent:boolean)
---@field addMenuCheckbox fun(id:integer, label:string, enabled:boolean, state:integer, filterBool:boolean, tooltip:string)
---@field setMenuCheckbox fun(id:integer, enabled:boolean, state:integer)
---@field addMenuInfoLabel fun(id:integer, label:string, info:string)
---@field addMenuLabel fun(label:string)
---@field addMenuSelectorEntry fun(id:integer, label:string)
---@field setMenuDropDownEnabled fun(id:integer, enabled:boolean)
---@field setMenuDropDownDisabledTooltip fun(id:integer, tooltip:string)
---@field addMenuDropDown fun(id:integer, label:string, tooltip:string)
---@field addMenuDropDownEntry fun(id:integer, entryText:string)
---@field selectMenuDropDownEntry fun(id:integer, index:integer)
---@field addMenuSlider fun(id:integer, label:string, amount:integer, min:integer, max:integer, snapInterval:integer, hide:boolean, tooltip:string)
---@field setMenuSlider fun(id:integer, amount:integer)
---@field addMenuButton fun(id:integer, label:string, soundUp:string, enabled:boolean, tooltip:string)
---@field setButtonEnabled fun(id:integer, enabled:boolean)
---@field removeItems function
---@field resetMenuButtons fun(activeButtonId:integer)
---@field setTitle fun(title:string) Sets the top title on the right hand side (Gameplay, Audio, etc.)

ModMenuManager = {
	Controls = {},
	LastID = 0
}

local function AddModSettingsEntry(ui, mainMenu, name, v)
	if v.Type == "FlagData" then
		local state = v.Enabled and 1 or 0
		local displayName = name
		local tooltip = "Global Flag"
		if v.DisplayName ~= nil and v.DisplayName ~= "" then
			if type(v.DisplayName) == "string" then
				displayName = v.DisplayName
			elseif v.DisplayName.Type == Classes.TranslatedString.Type and not StringHelpers.IsNullOrEmpty(v.DisplayName.Value) then
				displayName = v.DisplayName.Value
			end
		end
		if v.Tooltip ~= nil and v.Tooltip ~= "" then
			if type(v.Tooltip) == "string" then
				tooltip = v.Tooltip
			elseif v.DisplayName.Type == Classes.TranslatedString.Type and not StringHelpers.IsNullOrEmpty(v.Tooltip.Value) then
				tooltip = v.Tooltip.Value
			end
		end
		if displayName == name or displayName == "stringkey" then
			local stringKeyText = Ext.GetTranslatedStringFromKey(name)
			if stringKeyText ~= nil and stringKeyText ~= "" then
				displayName = stringKeyText
				if tooltip == "Global Flag" then
					local tooltipStringKeyText = Ext.GetTranslatedStringFromKey(name.."_Description")
					if tooltipStringKeyText ~= nil and tooltipStringKeyText ~= "" then
						tooltip = tooltipStringKeyText
					end
				end
			end
		end
		mainMenu.addMenuCheckbox(ModMenuManager.LastID, displayName, true, state, false, tooltip)
		ModMenuManager.Controls[ModMenuManager.LastID] = v
		ModMenuManager.LastID = ModMenuManager.LastID + 1
	elseif v.Type == "VariableData" then
		local displayName = name
		local tooltip = "Global Variable"
		local varType = type(v.Value)
		if varType == "number" then
			local interval = v.Interval or 1
			local min = v.Min or 0
			local max = v.Max or 999
			if v.DisplayName ~= nil and v.DisplayName ~= "" then
				if type(v.DisplayName) == "string" then
					displayName = v.DisplayName
				elseif v.DisplayName.Type == Classes.TranslatedString.Type and not StringHelpers.IsNullOrEmpty(v.DisplayName.Value) then
					displayName = v.DisplayName.Value
				end
			end
			if v.Tooltip ~= nil and v.Tooltip ~= "" then
				if type(v.Tooltip) == "string" then
					tooltip = v.Tooltip
				elseif v.DisplayName.Type == Classes.TranslatedString.Type and not StringHelpers.IsNullOrEmpty(v.Tooltip.Value) then
					tooltip = v.Tooltip.Value
				end
			end
			mainMenu.addMenuSlider(ModMenuManager.LastID, displayName, v.Value, min, max, interval, false, tooltip)
			ModMenuManager.Controls[ModMenuManager.LastID] = v
			ModMenuManager.LastID = ModMenuManager.LastID + 1
		end
	end
end

---@param ui UIObject
---@param mainMenu MainMenuMC
---@param modSettings ModSettings
---@param order table<string, string[]>|nil
local function ParseModSettings(ui, mainMenu, modSettings, order)
	if order ~= nil then
		for section,keys in pairs(order) do
			mainMenu.addMenuLabel(section)
			for _,name in pairs(keys) do
				local v = modSettings.Global.Flags[name] or modSettings.Global.Variables[name]
				if v ~= nil then
					AddModSettingsEntry(ui, mainMenu, name, v)
				end
			end
		end
	else
		for name,v in pairs(modSettings.Global.Flags) do
			AddModSettingsEntry(ui, mainMenu, name, v)
		end
		for name,v in pairs(modSettings.Global.Variables) do
			AddModSettingsEntry(ui, mainMenu, name, v)
		end
	end
end

---@param ui UIObject
---@param mainMenu MainMenuMC
function ModMenuManager.CreateMenu(ui, mainMenu)
	ModMenuManager.LastID = 0
	ModMenuManager.Controls = {}

	local title = Ext.GetTranslatedString("h12905237ga2afg43fcg8fc4g6a993789ecba", "Mod Settings")
	mainMenu.setTitle(title)

	local settings = {}
	for uuid,v in pairs(GlobalSettings.Mods) do
		settings[#settings+1] = v
	end
	---@param a ModSettings
	---@param b ModSettings
	table.sort(settings, function(a,b)
		return a.Name < b.Name
	end)

	for _,modSettings in pairs(settings) do
		if modSettings.Global ~= nil then
			local modName = modSettings.Name
			if Ext.IsModLoaded(modSettings.UUID) then
				local modInfo = Ext.GetModInfo(modSettings.UUID)
				if modInfo ~= nil then
					modName = modInfo.Name
				end
			end
			mainMenu.addMenuLabel(modName)
			if modSettings.GetMenuOrder ~= nil then
				local b,result = xpcall(modSettings.GetMenuOrder, debug.traceback)
				if not b then
					Ext.PrintError(result)
				end
				ParseModSettings(ui, mainMenu, modSettings, result)
			else
				ParseModSettings(ui, mainMenu, modSettings)
			end
		end
	end
end