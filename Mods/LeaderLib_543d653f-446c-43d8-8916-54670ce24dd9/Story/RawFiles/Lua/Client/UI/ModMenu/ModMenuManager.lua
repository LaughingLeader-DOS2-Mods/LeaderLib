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

---@class ModMenuEntryData
---@field Entry FlagData|VariableData
---@field UUID string
---@field Value boolean|any
---@field Last boolean|any

ModMenuManager = {
	---@type table<int, ModMenuEntryData>
	Controls = {},
	LastID = 0,
	LastScrollPosition = 0
}

local CreatedByText = Classes.TranslatedString:Create("h1e7b9070ga8cag46f3ga7b4gfccd1addb8ba", "[1]<br>Created by [2]")

---@param name string
---@param v FlagData|VariableData
---@return string,string
local function PrepareText(name, v)
	local displayName = name
	local tooltip = ""
	if v ~= nil then
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
	end
	if displayName == name or displayName == "stringkey" then
		local stringKeyText = Ext.GetTranslatedStringFromKey(name)
		if stringKeyText ~= nil and stringKeyText ~= "" then
			displayName = stringKeyText
			if tooltip == "" then
				local tooltipStringKeyText = Ext.GetTranslatedStringFromKey(name.."_Description")
				if tooltipStringKeyText ~= nil and tooltipStringKeyText ~= "" then
					tooltip = tooltipStringKeyText
				end
			end
		end
	end
	displayName = GameHelpers.Tooltip.ReplacePlaceholders(displayName)
	tooltip = GameHelpers.Tooltip.ReplacePlaceholders(tooltip)
	if displayName == "" then
		displayName = name
	end
	return displayName, tooltip
end

local function AddControl(entry, uuid, value)
	ModMenuManager.Controls[ModMenuManager.LastID] = {Entry=entry, UUID=uuid, Value=value, Last=value}
	ModMenuManager.LastID = ModMenuManager.LastID + 1
end

---@param ui UIObject
---@param mainMenu MainMenuMC
---@param name string
---@param v FlagData|VariableData
---@param uuid string The mod's UUID
local function AddModSettingsEntry(ui, mainMenu, name, v, uuid)
	local debugEnabled = false
	local LeaderLibSettings = GlobalSettings.Mods["7e737d2f-31d2-4751-963f-be6ccc59cd0c"]
	if LeaderLibSettings ~= nil and LeaderLibSettings.Global:FlagEquals("LeaderLib_DebugModeEnabled", true) then
		debugEnabled = true
	end
	if not v.DebugOnly or debugEnabled then
		if v.Type == "FlagData" then
			local enableControl = Client.IsHost or v.FlagType ~= "Global"
			local state = 0
			if v.Default then
				state = v.Enabled and 0 or 1
			else
				state = v.Enabled and 1 or 0
			end
			local displayName, tooltip = PrepareText(name, v)
			mainMenu.addMenuCheckbox(ModMenuManager.LastID, displayName, enableControl, state, false, tooltip)
			AddControl(v, uuid, v.Enabled)
		elseif v.Type == "VariableData" then
			local varType = type(v.Value)
			if varType == "number" then
				local interval = v.Interval or 1
				local min = v.Min or 0
				local max = v.Max or 999
				local displayName, tooltip = PrepareText(name, v)
				mainMenu.addMenuSlider(ModMenuManager.LastID, displayName, v.Value, min, max, interval, false, tooltip)
				AddControl(v, uuid, v.Value)

				if Client.IsHost ~= true then
					local slider = mainMenu.list.content_array[#mainMenu.list.content_array-1]
					if slider ~= nil then
						slider.alpha = 0.3
						slider.slider_mc.m_disabled = true
					end
				end
			elseif varType == "boolean" then
				local enableControl = Client.IsHost == true -- TODO: Specify on entries whether clients can edit them?
				local state = v.Value == true and 1 or 0
				local displayName, tooltip = PrepareText(name, v)
				mainMenu.addMenuCheckbox(ModMenuManager.LastID, displayName, enableControl, state, false, tooltip)
				AddControl(v, uuid, v.Value)
			elseif varType == "table" then
				if v.Value.Entries ~= nil and type(v.Value.Entries) == "table" then
					local displayName, tooltip = PrepareText(name, v)
					mainMenu.addMenuDropDown(ModMenuManager.LastID, displayName, tooltip)
					AddControl(v, uuid, v.Value.Selected)
					for _,entry in pairs(v.Value.Entries) do
						local entryName,_ = PrepareText(entry)
						mainMenu.addMenuDropDownEntry(ModMenuManager.LastID, entryName)
						ModMenuManager.LastID = ModMenuManager.LastID + 1
					end
				end
			end
		end
		return true
	end
	return false
end

---@param ui UIObject
---@param mainMenu MainMenuMC
---@param modSettings ModSettings
---@param order table<string, string[]>|nil
local function ParseModSettings(ui, mainMenu, modSettings, order)
	local added = {}
	if order ~= nil then
		for i=1,#order do
			local section = order[i]
			local name = section.DisplayName or section.Name
			if not StringHelpers.IsNullOrEmpty(name) then
				--mainMenu.addMenuInfoLabel(Ext.Random(500,600), section.DisplayName, "Info?")
				if string.sub(name, 0) == "h" then
					mainMenu.addMenuLabel(Ext.GetTranslatedString(name, name))
				else
					local translatedName = GameHelpers.GetStringKeyText(name, name)
					mainMenu.addMenuLabel(translatedName)
				end
				-- local label = mainMenu.list.content_array[#mainMenu.list.content_array-1]
				-- if label ~= nil then
				-- 	label.heightOverride = label.label_txt.height + 4
				-- 	label.label_txt.y = 2
				-- end
				--mainMenu.totalHeight = mainMenu.totalHeight - 20
			end
			if section.Entries ~= nil then
				for k=1,#section.Entries do
					local name = section.Entries[k]
					local v = modSettings:GetEntry(name)
					if v ~= nil and not v.IsFromFile then
						added[v.ID] = AddModSettingsEntry(ui, mainMenu, name, v, modSettings.UUID)
					end
				end
			end
		end
	end
	local otherEntries = {}
	for _,v in pairs(modSettings:GetAllEntries(Client.Profile)) do
		if added[v.ID] == nil then
			table.insert(otherEntries, v)
		end
	end
	table.sort(otherEntries, function(a,b)
		return a.ID < b.ID
	end)
	for i=1,#otherEntries do
		local v = otherEntries[i]
		AddModSettingsEntry(ui, mainMenu, v.ID, v, modSettings.UUID)
	end
	mainMenu.list.positionElements()
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
			if Ext.IsModLoaded(modSettings.UUID) then
				local modInfo = Ext.GetModInfo(modSettings.UUID)
				local modName = modInfo.Name or modSettings.Name
				mainMenu.addMenuLabel(modName)
				local label = mainMenu.list.content_array[#mainMenu.list.content_array-1]
				if label ~= nil then
					if modInfo ~= nil then
						label.tooltip = CreatedByText:ReplacePlaceholders(string.format("%s v%s", modName, StringHelpers.VersionIntegerToVersionString(modInfo.Version)), modInfo.Author)
					else
						label.tooltip = string.format("%s v%s", modName, StringHelpers.VersionIntegerToVersionString(modSettings.Version))
					end
				end
	
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
end

function ModMenuManager.OnCheckbox(id, state)
	local controlData = ModMenuManager.Controls[id]
	if controlData ~= nil then
		if controlData.Entry.Default then
			controlData.Value = state ~= 1
		else
			controlData.Value = state ~= 0
		end
		--print("ModMenuManager.OnCheckbox", id, state, controlData.Entry.Default, controlData.Value)
	end
end

function ModMenuManager.OnComboBox(id, index)
	local controlData = ModMenuManager.Controls[id]
	if controlData ~= nil then
		controlData.Value = index
	end
end

function ModMenuManager.OnSelector(id, currentSelection)
	local controlData = ModMenuManager.Controls[id]
	if controlData ~= nil then
		--controlData.Value = currentSelection
	end
end

function ModMenuManager.OnSlider(id, value)
	local controlData = ModMenuManager.Controls[id]
	if controlData ~= nil then
		controlData.Value = value
	end
end

function ModMenuManager.OnButtonPressed(id)
	--local controlData = ModMenuManager.Controls[id]
end

function ModMenuManager.CommitChanges()
	local changes = {}
	for i,v in pairs(ModMenuManager.Controls) do
		if v.Value ~= v.Last then
			if changes[v.UUID] == nil then
				changes[v.UUID] = {}
			end
			local modChanges = changes[v.UUID]
			table.insert(modChanges, {ID = v.Entry.ID, Value=v.Value, Type=v.Entry.Type})
			local settings = SettingsManager.GetMod(v.UUID, false)
			if settings ~= nil then
				if v.Entry.Type == "FlagData" then
					settings.Global.Flags[v.Entry.ID].Enabled = v.Value
				elseif v.Entry.Type == "VariableData" then
					settings.Global.Variables[v.Entry.ID].Value = v.Value
				end
			end
		end
	end
	Ext.PostMessageToServer("LeaderLib_ModMenu_SaveChanges", Ext.JsonStringify(changes))
end

function ModMenuManager.UndoChanges()
	for i,v in pairs(ModMenuManager.Controls) do
		v.Value = v.Last
	end
end

function ModMenuManager.SaveScroll(ui)
	local main = ui:GetRoot()
	if main ~= nil then
		local scrollbar_mc = main.mainMenu_mc.list.m_scrollbar_mc
		if scrollbar_mc ~= nil then
			ModMenuManager.LastScrollPosition = scrollbar_mc.m_scrolledY
		end
	end
end

function ModMenuManager.SetScrollPosition(ui)
	if ModMenuManager.LastScrollPosition ~= 0 then
		local main = ui:GetRoot()
		if main ~= nil then
			local scrollbar_mc = main.mainMenu_mc.list.m_scrollbar_mc
			if scrollbar_mc ~= nil then
				scrollbar_mc.m_tweenY = ModMenuManager.LastScrollPosition
				scrollbar_mc.m_scrollAnimToY = ModMenuManager.LastScrollPosition
				scrollbar_mc.INTScrolledY(ModMenuManager.LastScrollPosition)
			end
		end
	end
end

local function SyncControl(control)
	if control.Type == "FlagData" then
		local data = {ID=control.ID, FlagType=control.FlagType, Enabled=enabled, User=Client.Character.ID}
		Ext.PostMessageToServer("LeaderLib_ModMenu_FlagChanged", Ext.JsonStringify(data))
	elseif control.Type == "VariableData" then
		local data = {ID=control.ID, Value=control.Value, User=Client.Character.ID}
		Ext.PostMessageToServer("LeaderLib_ModMenu_VariableChanged", Ext.JsonStringify(data))
	end
end