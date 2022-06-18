local Changelog = Classes.UIWrapper:CreateFromType(Data.UIType.journal, {IsControllerSupported = true, ControllerID = Data.UIType.journal_csp})

local _entries = {}

local lastId = 1000

---@param modName string
---@param changelogText string|TranslatedString
function Changelog:AddModEntry(modName, changelogText)
	_entries[#_entries+1] = {
		Title = modName,
		Description = changelogText,
		ID = lastId
	}
	lastId = lastId + 1
end

Changelog:RegisterInvokeListener("updateJournal", function (self, ui, event)
	--Rename the TUTORIAL button to INFO

	local this = ui:GetRoot()
	if this and this.add_tutEntry then
		local tabTitle = string.upper(GameHelpers.GetStringKeyText("LeaderLib_UI_Journal_ButtonTitleOverride", "INFO"))
		local tutorialTab = GameHelpers.GetTranslatedString("h7a7a3449g5a44g44a7g8132gcf3bb11fe0d5", "TUTORIALS")

		for i=0,#this.journal_mc.tabList.content_array-1 do
			local tab = this.journal_mc.tabList.content_array[i]
			if tab then
				--fprint(LOGLEVEL.DEFAULT, "[tab] id(%s) funcId(%s) label(%s)", tab.id, tab.funcId, tab.text_txt.htmlText)
				if tab.id == 7 or StringHelpers.Equals(tab.text_txt.htmlText, tutorialTab, true, true) then
					tab.text_txt.htmlText = tabTitle
				end
			end
		end
	end
end, "After", "All")

Changelog:RegisterInvokeListener("updateTutorials", function (self, ui, event)
	local this = ui:GetRoot()
	if this and this.add_tutEntry then
		--this.add_tutEntry[val1].toUpperCase(),this.add_tutEntry[val1 + 1],this.add_tutEntry[val1 + 2],this.add_tutEntry[val1 + 3]

		local changelogTitle = GameHelpers.GetStringKeyText("LeaderLib_UI_Journal_Changelogs_Title", "Mod Changes")
		local titleUpper = string.upper(changelogTitle)

		--Clear the Mod Changes group before adding new entries
		local groups_array = this.journal_mc.tutorialList.content_array
		for i=0,#groups_array-1 do
			local group = groups_array[i]
			if group then
				if group.gName == titleUpper then
					this.journal_mc.tutorialList.clearGroup(group.groupId, false)
				end
			end
		end

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
	end
end, "After", "All")

Changelog:AddModEntry(Classes.TranslatedString:CreateFromKey("LeaderLib", "LeaderLib"), Classes.TranslatedString:CreateFromKey("LeaderLib_UI_Changelog", "<b><font size='24'>1.7.21.6</font></b><br><br>• Fixed an issue where object timer data wasn't being cleared (important bug to fix to prevent repeated timer results).<br>• (v56) Fixed an issue prevents world effects from working.<br>• Added a workaround for EsvZoneAction surfaces not dealing damage.<br><br><b><font size='24'>1.7.21.5</font></b><br><br>• Fixed red console text from trying to check unavailable properties in v55 extender (they're available in v56).<br>• Fixed an oversight where action icons were being checked for damage types in skill tooltips.<br>• Fixed some red console text that resulted from checking StatsDescriptionParams with a specific name (:Damage).<br>• Fixed a typo preventing the learned parameter from passing to \"Learned\" skill state listeners.<br>• Fixed an issue where unique timers wouldn't be cancelled with Timer.Cancel.<br>• Fixed an issue with older timer listeners not getting the correct timer data passed.<br>• Fixed an issue where registered older timer listeners resulted in timer data being unset.<br>• Fixed an issue where the !additemstat command wasn't able to generate unique items."))

UI.Changelog = Changelog