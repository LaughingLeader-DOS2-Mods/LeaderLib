---@class MainMenuMC:FlashObject
---@field addOptionButton fun(label:string, callback:string, id:integer, isCurrent:boolean, fixedHeight:number|nil)
---@field addMenuCheckbox fun(id:integer, label:string, enabled:boolean, state:integer, filterBool:boolean, tooltip:string)
---@field setMenuCheckbox fun(id:integer, enabled:boolean, state:integer)
---@field addMenuInfoLabel fun(id:integer, label:string, info:string, tooltip:string|nil, fixedHeight:number|nil)
---@field addMenuLabel fun(label:string, tooltip:string|nil, fixedHeight:number|nil, topSpacing:number|nil)
---@field addMenuSelectorEntry fun(id:integer, label:string)
---@field setMenuDropDownEnabled fun(id:integer, enabled:boolean)
---@field setMenuDropDownDisabledTooltip fun(id:integer, tooltip:string)
---@field addMenuDropDown fun(id:integer, label:string, tooltip:string, fixedHeight:number|nil)
---@field addMenuDropDownEntry fun(id:integer, entryText:string)
---@field selectMenuDropDownEntry fun(id:integer, index:integer)
---@field addMenuSlider fun(id:integer, label:string, amount:integer, min:integer, max:integer, snapInterval:integer, hide:boolean, tooltip:string, fixedHeight:number|nil)
---@field setMenuSlider fun(id:integer, amount:integer)
---@field addMenuButton fun(id:integer, label:string, soundUp:string, enabled:boolean, tooltip:string, fixedHeight:number|nil)
---@field setButtonEnabled fun(id:integer, enabled:boolean)
---@field removeItems function
---@field resetMenuButtons fun(activeButtonId:integer)
---@field setTitle fun(title:string) Sets the top title on the right hand side (Gameplay, Audio, etc.)

---@class ModMenuEntryData
---@field Entry FlagData|VariableData
---@field UUID string
---@field Value boolean|any
---@field Last boolean|any

---@alias ModMenuButtonCallback fun(entry:ButtonData, modUUID:string, character:EclCharacter):void

---@class ModMenuButtonEntryData
---@field Entry ButtonData
---@field UUID string

ModMenuManager = {
	---@type table<integer, ModMenuEntryData>
	Controls = {},
	---@type table<integer, ModMenuButtonEntryData>
	Buttons = {},
	LastID = 1000,
	LastScrollPosition = 0
}

local CreatedByText = Classes.TranslatedString:CreateFromKey("LeaderLib_Tooltip_CreatedBy", "[1]<br><font color='#33FF99'>Created by [2]</font>")

---@param name string
---@param v FlagData|VariableData
---@param isCheckbox boolean
---@return string,string
local function PrepareText(name, v, isCheckbox)
	local displayName = name
	local tooltip = ""
	if v ~= nil then
		if v.DisplayName then
			local t = type(v.DisplayName)
			if t == "string" and not StringHelpers.IsNullOrEmpty(v.DisplayName) then
				displayName = v.DisplayName
			elseif t == "table" and v.DisplayName.Type == Classes.TranslatedString.Type and not StringHelpers.IsNullOrEmpty(v.DisplayName.Value) then
				displayName = v.DisplayName.Value
			end
		end
		if v.Tooltip then
			local t = type(v.Tooltip)
			if t == "string" and not StringHelpers.IsNullOrEmpty(v.Tooltip) then
				tooltip = v.Tooltip
			elseif t == "table" and v.Tooltip.Type == Classes.TranslatedString.Type and not StringHelpers.IsNullOrEmpty(v.Tooltip.Value) then
				tooltip = v.Tooltip.Value
			end
		end
	end
	if displayName == name or displayName == "stringkey" then
		local stringKeyText = GameHelpers.GetStringKeyText(name)
		if not StringHelpers.IsNullOrEmpty(stringKeyText) then
			displayName = stringKeyText
			if tooltip == "" then
				local tooltipStringKeyText = GameHelpers.GetStringKeyText(name.."_Description")
				if not StringHelpers.IsNullOrEmpty(tooltipStringKeyText) then
					tooltip = tooltipStringKeyText
				end
			end
		end
	end
	displayName = GameHelpers.Tooltip.ReplacePlaceholders(displayName)
	--Let the generic tooltip listener replace placeholders in the text
	--tooltip = GameHelpers.Tooltip.ReplacePlaceholders(tooltip)
	if displayName == "" then
		displayName = name
	end
	if Vars.ControllerEnabled and isCheckbox == true then
		displayName = string.gsub(displayName, "Enable ", ""):gsub("Disable ", "")
	end
	if Vars.DebugMode and v.Type == "FlagData" then
		tooltip = string.format("%s<br><font color='#44AAFF'>(Flag: <font color='#FFAA33'>%s</font>)</font>", tooltip, v.ID)
	end
	return displayName,tooltip
end

local function AddControl(entry, uuid, value)
	ModMenuManager.Controls[ModMenuManager.LastID] = {Entry=entry, UUID=uuid, Value=value, Last=value}
	ModMenuManager.LastID = ModMenuManager.LastID + 1
end

local function AddButton(entry, modUUID)
	ModMenuManager.Buttons[ModMenuManager.LastID] = {Entry=entry, UUID=modUUID}
	ModMenuManager.LastID = ModMenuManager.LastID + 1
end

---@param ui UIObject
---@param mainMenu MainMenuMC
---@param name string
---@param v FlagData|VariableData
---@param modUUID string The mod's UUID
local function AddModSettingsEntry(ui, mainMenu, name, v, modUUID)
	local debugEnabled = false
	local LeaderLibSettings = SettingsManager.GetMod(ModuleUUID, false, false)
	if LeaderLibSettings ~= nil and LeaderLibSettings.Global:FlagEquals("LeaderLib_DebugModeEnabled", true) then
		debugEnabled = true
	end
	if not v.DebugOnly or debugEnabled then
		if v.Type == "FlagData" then
			local enableControl = v.ClientSide or Client.IsHost or v.FlagType ~= "Global"
			local state = 0
			if v.Default then
				state = v.Enabled and 0 or 1
			else
				state = v.Enabled and 1 or 0
			end
			local displayName, tooltip = PrepareText(name, v)
			mainMenu.addMenuCheckbox(ModMenuManager.LastID, displayName, enableControl, state, false, tooltip)
			AddControl(v, modUUID, v.Enabled)
		elseif v.Type == "VariableData" then
			local varType = type(v.Value)
			if varType == "number" then
				local interval = v.Interval or 1
				local min = v.Min or 0
				local max = v.Max or 999
				local displayName, tooltip = PrepareText(name, v)
				local controlsEnabled = v.ClientSide or Client.IsHost == true
				mainMenu.addMenuSlider(ModMenuManager.LastID, displayName, v.Value, min, max, interval, not controlsEnabled, tooltip)
				AddControl(v, modUUID, v.Value)
				
				local slider = mainMenu.list.content_array[#mainMenu.list.content_array-1]
				if slider ~= nil and slider.slider_mc ~= nil then
					slider.alpha = controlsEnabled and 1.0 or 0.3
					slider.slider_mc.m_disabled = not controlsEnabled
				end
			elseif varType == "boolean" then
				local enableControl = v.ClientSide or Client.IsHost == true
				local state = v.Value == true and 1 or 0
				local displayName, tooltip = PrepareText(name, v, true)
				mainMenu.addMenuCheckbox(ModMenuManager.LastID, displayName, enableControl, state, false, tooltip)
				AddControl(v, modUUID, v.Value)
			elseif varType == "table" then
				if v.Value.Entries ~= nil and type(v.Value.Entries) == "table" then
					local displayName, tooltip = PrepareText(name, v)
					mainMenu.addMenuDropDown(ModMenuManager.LastID, displayName, tooltip)
					AddControl(v, modUUID, v.Value.Selected)
					for _,entry in pairs(v.Value.Entries) do
						local entryName,_ = PrepareText(entry)
						mainMenu.addMenuDropDownEntry(ModMenuManager.LastID, entryName)
						ModMenuManager.LastID = ModMenuManager.LastID + 1
					end
				end
			end
		elseif v.Type == "ButtonData" then
			local enableControl = v.Enabled and (v.ClientSide or Client.IsHost == true or not v.HostOnly)
			local displayName, tooltip = PrepareText(name, v)
			local soundUp = v.SoundUp or ""
			if not Vars.ControllerEnabled then
				mainMenu.addMenuButton(ModMenuManager.LastID, displayName, soundUp, enableControl, tooltip)
			else
				--addMenuButton(param1:Number, param2:String, param3:Boolean)
				mainMenu.addMenuButton(ModMenuManager.LastID, displayName, enableControl, tooltip)
			end
			AddButton(v, modUUID)
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
			local topSpacing = i > 1 and 10 or 0
			if not StringHelpers.IsNullOrEmpty(name) then
				--mainMenu.addMenuInfoLabel(Ext.Random(500,600), section.DisplayName, "Info?")
				if string.sub(name, 0) == "h" then
					mainMenu.addMenuLabel(GameHelpers.GetTranslatedString(name, name), "", 40, topSpacing)
				else
					mainMenu.addMenuLabel(GameHelpers.GetStringKeyText(name, name), "", 40, topSpacing)
				end
			end
			if section.Entries ~= nil then
				for k=1,#section.Entries do
					local name = section.Entries[k]
					local v = modSettings:GetEntry(name)
					if v then
						-- Support duplicate IDs between types, though this isn't recommended
						if type(v) == "table" and v.Type == nil and #v > 0 then
							for _,v2 in pairs(v) do
								if not v2.IsFromFile and v2.Type then
									added[v2.ID] = AddModSettingsEntry(ui, mainMenu, name, v2, modSettings.UUID)
								end
							end
						elseif not v.IsFromFile and v.Type then
							added[v.ID] = AddModSettingsEntry(ui, mainMenu, name, v, modSettings.UUID)
						end
					end
				end
			end
		end
	end
	local otherEntries = {}
	for _,v in pairs(modSettings:GetAllEntries(Client.Profile)) do
		if added[v.ID] == nil then
			table.insert(otherEntries, v)
			added[v.ID] = false
		end
	end
	table.sort(otherEntries, function(a,b)
		return a.ID < b.ID
	end)
	for i=1,#otherEntries do
		local v = otherEntries[i]
		AddModSettingsEntry(ui, mainMenu, v.ID, v, modSettings.UUID)
		added[v.ID] = true
	end
	mainMenu.list.positionElements()
	return added
end

---@param ui UIObject
---@param mainMenu MainMenuMC
function ModMenuManager.CreateMenu(ui, mainMenu)
	ModMenuManager.LastID = 0
	ModMenuManager.Controls = {}

	local title = Ext.GetTranslatedString("h12905237ga2afg43fcg8fc4g6a993789ecba", "Mod Settings")
	mainMenu.setTitle(title)

	---@type ModSettings[]
	local settings = {}
	for uuid,v in pairs(GlobalSettings.Mods) do
		settings[#settings+1] = v
	end
	---@param a ModSettings
	---@param b ModSettings
	table.sort(settings, function(a,b)
		return a.Name < b.Name
	end)

	local index = 0
	for _,modSettings in pairs(settings) do
		index = index + 1
		if modSettings.Global ~= nil then
			if Ext.IsModLoaded(modSettings.UUID) and modSettings:HasEntries() then
				local titleColor = not StringHelpers.IsNullOrEmpty(modSettings.TitleColor) and modSettings.TitleColor or "#369BFF"
				local modName = string.format("<font color='%s' size='24'>%s</font>", titleColor, modSettings.Name)
				local tooltip = ""

				local mod = Ext.Mod.GetMod(modSettings.UUID)
				if mod and mod.Info then
					local name = GameHelpers.GetTranslatedStringValue(mod.Info.DisplayName, mod.Info.Name)
					modName = string.format("<font color='%s' size='24'>%s</font>", titleColor, name)
					local desc = GameHelpers.GetTranslatedStringValue(mod.Info.DisplayDescription, mod.Info.Description)
					local version = StringHelpers.Join(".", mod.Info.ModVersion)
					if not StringHelpers.IsNullOrWhitespace(desc) then
						tooltip = string.format("%s<br><br><font size='18'>%s</font>", CreatedByText:ReplacePlaceholders(string.format("%s v%s", modName, version), mod.Info.Author), desc)
					else
						tooltip = CreatedByText:ReplacePlaceholders(string.format("%s v%s", modName, version), mod.Info.Author)
					end
				else
					tooltip = string.format("%s v%s", modName, StringHelpers.VersionIntegerToVersionString(modSettings.Version))
				end

				if index > 1 then
					mainMenu.addMenuLabel(modName, tooltip, 60, 30)
				else
					mainMenu.addMenuLabel(modName, tooltip, 60, 0)
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

				local length = #Listeners.ModMenuSectionCreated
				if length > 0 then
					for i=1,length do
						local callback = Listeners.ModMenuSectionCreated[i]
						local b,err = xpcall(callback, debug.traceback, modSettings.UUID, modSettings, ui, mainMenu)
						if not b then
							Ext.PrintError("Error calling function for 'ModMenuSectionCreated':\n", err)
						end
					end
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
	local controlData = ModMenuManager.Buttons[id]
	if controlData ~= nil then
		if controlData.Entry and controlData.Entry.Invoke then
			controlData.Entry:Invoke(controlData.Entry, controlData.UUID, Client:GetCharacter())
		end
	end
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
					settings:SetFlag(v.Entry.ID, v.Value == true)
				elseif v.Entry.Type == "VariableData" then
					settings:SetVariable(v.Entry.ID, v.Value)
				end
			end
		end
	end
	Ext.PostMessageToServer("LeaderLib_ModMenu_SaveChanges", Common.JsonStringify(changes))
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