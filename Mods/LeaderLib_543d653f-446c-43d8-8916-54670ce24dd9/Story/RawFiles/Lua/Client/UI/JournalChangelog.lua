local ts = Classes.TranslatedString
local _journal = Classes.UIWrapper:CreateFromType(Data.UIType.journal, {IsControllerSupported = true, ControllerID = Data.UIType.journal_csp})

---@class LeaderLibJournalChangelogEntry:{Title:string|TranslatedString, Description:string|TranslatedString, Tooltip:string|TranslatedString|nil, ID:integer}

---@type LeaderLibJournalChangelogEntry[]
local _entries = {}

---@type table<integer, LeaderLibJournalChangelogEntry>
local _IDToEntry = {}

local Changelogs_Title = ts:CreateFromKey("LeaderLib_UI_Journal_Changelogs_Title", "Mod Changes")

local lastId = 1000

--local this = Ext.UI.GetByType(22):GetRoot().journal_mc.tutorialContainer_mc; print(this.title_txt.x)

local _OVERRIDE_ENABLED = false

local function TryEnableJournalOverride()
	local journalOverride = Ext.IO.GetPathOverride("Public/Game/GUI/journal.swf")
	if journalOverride == nil or journalOverride == "" then
		Ext.IO.AddPathOverride("Public/Game/GUI/journal.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/Overrides/journal.swf")
		_OVERRIDE_ENABLED = true
	end
end

Ext.Events.SessionLoading:Subscribe(TryEnableJournalOverride, {Priority = 1})

---@class LeaderLibChangelog
local Changelog = {}
UI.Changelog = Changelog

---@param modName string|TranslatedString
---@param changelogText string|TranslatedString
---@param tooltip string|TranslatedString|nil
function Changelog:AddModEntry(modName, changelogText, tooltip)
	local entry = {
		Title = modName,
		Description = changelogText,
		Tooltip = tooltip,
		ID = lastId
	}
	_IDToEntry[lastId] = entry
	_entries[#_entries+1] = entry
	lastId = lastId + 1
end

_journal.Register:Invoke("updateJournal", function (self, e, ui, event)
	--Rename the TUTORIAL button to INFO

	local this = ui:GetRoot()
	if this and this.add_tutEntry then
		local tabTitle = string.upper(GameHelpers.GetStringKeyText("LeaderLib_UI_Journal_InfoButton_Title", "INFO"))
		local tutorialTab = GameHelpers.GetTranslatedString("h7a7a3449g5a44g44a7g8132gcf3bb11fe0d5", "TUTORIALS")

		local tabs = this.journal_mc.tabList
		if Vars.ControllerEnabled then
			tabs = this.journal_mc.journalSubTabList
		end
		if tabs and tabs.content_array then
			local arr = tabs.content_array
			local len = #arr-1
			for i=0,len do
				local tab = arr[i]
				if tab then
					local text_mc = tab.text_txt
					if Vars.ControllerEnabled then
						text_mc = tab.tabEntry_mc.text_txt
					end
					if text_mc then
						--fprint(LOGLEVEL.DEFAULT, "[tab] id(%s) funcId(%s) label(%s)", tab.id, tab.funcId, tab.text_txt.htmlText)
						if tab.id == 7 or StringHelpers.Equals(text_mc.htmlText, tutorialTab, true, true) then
							text_mc.htmlText = tabTitle
						end
					end
				end
			end
		end
	end
end, "After", "All")

---@return string|nil
local function GetLastGroupId(tutorialList)
	if tutorialList.m_CurrentSelection and tutorialList.m_CurrentSelection.list_pos then
		return tutorialList.content_array[tutorialList.m_CurrentSelection.list_pos].gName
	end
	return nil
end

local initializedEntries = false

local function OnUpdateDone(ui)
	local this = ui:GetRoot()
	if not this or not this.journal_mc then
		return
	end
	local tutorialList = this.journal_mc.tutorialList
	local changelogTitle = string.upper(Changelogs_Title.Value)
	local len = #tutorialList.content_array
	for i=0,len-1 do
		local group_mc = tutorialList.content_array[i]
		if group_mc and group_mc.gName == changelogTitle then
			group_mc.sortName = "1_MODCHANGES";
			if group_mc.title_txt.htmlText == changelogTitle then
				group_mc.title_txt.htmlText = string.format("====%s====", changelogTitle)
				Ext.OnNextTick(function (e)
					local this = _journal.Root
					if this then
						this.journal_mc.tutorialList.positionElements()
					end
				end)
			end
			--public const tutDeselectColour:uint = 7346462; #70191E
			--public const tutSelectColour:uint = 23424; #005B80
			
			-- group_mc.deselectColour = 0x70191E
			-- group_mc.selectColour = 0x005B80
			-- group_mc.setTextColor(group_mc.deselectColour)

			for j=0,#group_mc.list.content_array-1 do
				local tutorialentry_mc = group_mc.list.content_array[j]
				if tutorialentry_mc then
					local entry = _IDToEntry[tutorialentry_mc.id]
					if entry then
						local tooltip = GameHelpers.Tooltip.ReplacePlaceholders(entry.Tooltip)
						if not StringHelpers.IsNullOrWhitespace(tooltip) then
							tutorialentry_mc.tooltip = tooltip
						end
					end
				end
			end
			break
		end
	end
end

_journal.Register:Call("tutorialUpdateDone", function (self, e, ui, event)
	OnUpdateDone(ui)
end, "Before", "Keyboard")

_journal.Register:Invoke("updateTutorials", function (self, e, ui, event)
	local this = ui:GetRoot()
	if this and this.add_tutEntry then
		--this.add_tutEntry[val1].toUpperCase(),this.add_tutEntry[val1 + 1],this.add_tutEntry[val1 + 2],this.add_tutEntry[val1 + 3]

		local changelogTitle = Changelogs_Title.Value
		local titleUpper = string.upper(changelogTitle)

		local tutorialList = this.journal_mc.tutorialList
		--local _,lastGroup = pcall(GetLastGroupId, tutorialList)

		local groupId = nil

		--Clear the Mod Changes group before adding new entries
		local groups_array = tutorialList.content_array
		for i=0,#groups_array-1 do
			local group = groups_array[i]
			if group then
				if group.gName == titleUpper then
					if not initializedEntries then
						--Clear after an !luareset
						tutorialList.clearGroup(group.groupId, false)
					end
					groupId = group.groupId
					break
				end
			end
		end

		if not groupId or not initializedEntries then
			--Only add changelogs if the group is missing, so selection doesn't reset

			table.sort(_entries, function(a,b)
				return string.upper(StringHelpers.StripFont(tostring(a.Title))) < string.upper(StringHelpers.StripFont(tostring(b.Title)))
			end)
	
			local index = #this.add_tutEntry
			for i=1,#_entries do
				local entry = _entries[i]
				if entry then
					local title = GameHelpers.Tooltip.ReplacePlaceholders(entry.Title)
					local description = GameHelpers.Tooltip.ReplacePlaceholders(entry.Description)
					if not StringHelpers.IsNullOrWhitespace(title) then
						this.add_tutEntry[index] = changelogTitle
						this.add_tutEntry[index+1] = entry.ID
						this.add_tutEntry[index+2] = title
						this.add_tutEntry[index+3] = description
						index = index + 4
					end
				end
			end

			initializedEntries = true

			Ext.OnNextTick(function (e)
				if not _OVERRIDE_ENABLED then
					OnUpdateDone(_journal.Instance)
				end
			end)
		end
	end
end, "After", "All")

Events.BeforeLuaReset:Subscribe(function ()
	if not Vars.ControllerEnabled then
		local this = _journal.Root
		if this then
			this.journal_mc.tutorialContainer_mc.lastGroupId = -1
			if this.journal_mc.tutorialContainer_mc.resetText then
				this.journal_mc.tutorialContainer_mc.resetText()
			end
		end
	end
end)

local function TryFindConfig(info)
	local filePath = string.format("Mods/%s/Changelog.json", info.Directory)
	local file = Ext.IO.LoadFile(filePath, "data")
	if not StringHelpers.IsNullOrWhitespace(file) then
		return Common.JsonParse(file, true)
	end
	return nil
end

---@class LeaderLibChangelogConfigTextEntry
---@field Text string

---@class LeaderLibChangelogConfigChangeEntry
---@field Version string
---@field Changes string[]

---@class LeaderLibChangelogConfigData
---@field DisplayName string|nil
---@field Description string|nil
---@field Entries (LeaderLibChangelogConfigChangeEntry|LeaderLibChangelogConfigTextEntry)[]

local function GetStringValue(str, character)
	local result = str
	if string.find(str, "[", 1, true) then
		result = GameHelpers.Tooltip.ReplacePlaceholders(str, character)
	elseif string.sub(str, 1, 1) == "h" then
		result = GameHelpers.GetTranslatedString(str, str)
	elseif string.find(str, "_", 1, true) then
		result = GameHelpers.GetStringKeyText(str, str)
	end
	return result
end

local _Bullet = "•"
local _NoBullet = "<nb>"

---Load all Mods/ModName_UUID/Changelog.json files. Called automatically at SessionLoaded.
function Changelog.LoadFiles()
	local character = Client:GetCharacter()

	---@type {Data:LeaderLibChangelogConfigData, UUID:string, Name:string, SortName:string}[]
	local loadedData = {}
	for i,uuid in pairs(Ext.Mod.GetLoadOrder()) do
		if IgnoredMods[uuid] ~= true then
			local mod = Ext.Mod.GetMod(uuid)
			if mod ~= nil then
				local b,result = xpcall(TryFindConfig, debug.traceback, mod.Info)
				if not b then
					Ext.Utils.PrintError(result)
				elseif result ~= nil then
					local name = mod.Info.Name
					if result.DisplayName then
						name = GetStringValue(result.DisplayName, character)
					end
					loadedData[#loadedData+1] = {Data=result, UUID=uuid, Name=name, SortName=string.lower(name)}
				end
			end
		end
	end
	table.sort(loadedData, function (a, b)
		return a.SortName < b.SortName
	end)
	for i=1,#loadedData do
		local entry = loadedData[i]
		local description = nil
		local changelogText = ""
		if entry.Data.Description then
			description = GetStringValue(entry.Data.Description, character)
			if StringHelpers.IsNullOrWhitespace(description) then
				description = nil
			end
		end

		if type(entry.Data.Entries) == "table" then
			for j=1,#entry.Data.Entries do
				local logEntry = entry.Data.Entries[j]
				if logEntry.Text then
					changelogText = string.format("%s%s<br>", changelogText, GetStringValue(logEntry.Text, character))
				end
				if logEntry.Version then
					changelogText = string.format("%s<b><font size='24'>%s</font></b><br>", changelogText, GetStringValue(logEntry.Version, character))
				end
				if type(logEntry.Changes) == "table" then
					for k=1,#logEntry.Changes do
						local txt = GetStringValue(logEntry.Changes[k], character)
						local bullet = _Bullet .. " "
						if StringHelpers.IsNullOrWhitespace(txt) or string.find(txt, _Bullet) then
							bullet = ""
						elseif string.find(txt, _NoBullet) then
							bullet = ""
							txt = string.gsub(txt, _NoBullet, "")
						end
						txt = string.gsub(txt, "\t", "    ")
						changelogText = string.format("%s%s%s<br>", changelogText, bullet, txt)
					end
				end
				changelogText = changelogText .. "<br>"
			end
		end

		if not StringHelpers.IsNullOrWhitespace(changelogText) then
			Changelog:AddModEntry(entry.Name, changelogText, description)
		end
	end
end

Ext.Events.SessionLoaded:Subscribe(function ()
	Changelog.LoadFiles()
end)

--[[ Ext.Events.SessionLoaded:Subscribe(function (e)
	if Vars.LeaderDebugMode then
		Changelog:AddModEntry("Test", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer eu nibh aliquam, lacinia tellus sed, imperdiet elit. Mauris ultricies nunc at tortor tristique porttitor. Nam orci est, varius iaculis laoreet vel, ultricies in nisi. Pellentesque nec scelerisque nisi. Ut molestie sagittis tempor. Sed tincidunt purus sit amet magna accumsan, ut sollicitudin felis elementum. Mauris posuere malesuada mattis. Duis maximus non massa eu sodales. Pellentesque nibh felis, pellentesque in mauris pretium, vulputate malesuada nunc. Maecenas eget lacinia ex. Integer nec dui vel massa gravida elementum eget nec massa. Aenean tincidunt non est a scelerisque. Nam eu enim mi.\n\nMauris molestie commodo leo quis ultrices. Quisque elementum felis et neque vestibulum scelerisque. Cras sodales felis lorem, vel tempus justo porttitor quis. Suspendisse potenti. Phasellus nisi leo, cursus sed lorem sit amet, semper consequat orci. Aliquam sagittis pellentesque libero et interdum. Sed iaculis facilisis velit, quis hendrerit libero dapibus auctor.\n\n<font color='#FFCC11'>Phasellus mi metus, congue a tincidunt eget, viverra ut lectus. Cras elit quam, fringilla in dui sit amet, tristique faucibus mauris. Ut bibendum rutrum sem, efficitur malesuada nunc euismod quis. Morbi eros leo, commodo quis aliquet eget, pretium sit amet diam. Nullam posuere augue vel ligula gravida fermentum. Proin a consequat risus. Integer ac ligula condimentum, pretium est ac, feugiat lorem. Sed suscipit ut neque vel facilisis. Nullam lobortis lacinia lacus a mattis. Maecenas eget mi fermentum, aliquet odio at, feugiat risus. Integer finibus vitae tortor sed tristique. Pellentesque pellentesque venenatis velit, sit amet euismod dui eleifend eget. Donec malesuada ex nisi, sit amet imperdiet ex scelerisque at.\n\nNulla eget dui sed nulla tempus interdum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Duis a lobortis lacus. Morbi neque nulla, rutrum sit amet leo ac, rutrum efficitur magna. Nulla odio nisi, dignissim a justo rutrum, malesuada eleifend lectus. Fusce nec cursus augue. Morbi at sem iaculis, eleifend libero vel, posuere velit.</font>\n\nMauris non justo nec justo congue laoreet. Maecenas porttitor magna at libero rhoncus bibendum. Phasellus vel sem cursus, semper erat quis, aliquet metus. Aenean quis metus egestas, ultrices velit in, molestie tellus. Etiam nec purus nec quam varius luctus. Nulla quis suscipit tellus, maximus accumsan felis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Sed viverra quis nisi sit amet luctus. Cras dapibus sodales mauris ut tristique. Aliquam orci purus, suscipit in porttitor nec, tincidunt eget lectus.")
		Changelog:AddModEntry("Test2", "Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>Line<br>End")
	end
end) ]]