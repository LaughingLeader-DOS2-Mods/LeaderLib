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

local tutorialIsDirty = false

Changelog:RegisterInvokeListener("updateJournal", function (self, ui, event)
	--Rename the TUTORIAL button to INFO

	local this = ui:GetRoot()
	if this and this.add_tutEntry then
		if tutorialIsDirty then
			tutorialIsDirty = false
			local tutorialContainer_mc = this.journal_mc.tutorialContainer_mc
			if not tutorialContainer_mc.visible then
				tutorialContainer_mc.title_txt.htmlText = ""
				tutorialContainer_mc.desc_txt.htmlText = ""
			end
		end

		local tabTitle = string.upper(GameHelpers.GetStringKeyText("LeaderLib_UI_Journal_InfoButton_Title", "INFO"))
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

---@return string
local function GetLastGroupId(tutorialList)
	if tutorialList.m_CurrentSelection and tutorialList.m_CurrentSelection.list_pos then
		return tutorialList.content_array[tutorialList.m_CurrentSelection.list_pos].gName
	end
end

local initializedEntries = false

Changelog:RegisterInvokeListener("updateTutorials", function (self, ui, event)
	local this = ui:GetRoot()
	if this and this.add_tutEntry then
		--this.add_tutEntry[val1].toUpperCase(),this.add_tutEntry[val1 + 1],this.add_tutEntry[val1 + 2],this.add_tutEntry[val1 + 3]

		local changelogTitle = GameHelpers.GetStringKeyText("LeaderLib_UI_Journal_Changelogs_Title", "Mod Changes")
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
			
			-- if lastGroup then
			-- 	Timer.StartOneshot("", 250, function ()
			-- 		local this = Changelog:GetRoot()
			-- 		if this and this.journal_mc and this.journal_mc.tutorialList then
			-- 			tutorialList = this.journal_mc.tutorialList
			-- 			local groups_array = tutorialList.content_array
			-- 			for i=0,#groups_array-1 do
			-- 				local group = groups_array[i]
			-- 				if group then
			-- 					if group.gName == lastGroup then
			-- 						print(group.gName, lastGroup, group.gName == lastGroup)
			-- 						tutorialList.clearSelection()
			-- 						group.setOpen(true)
			-- 						group.selectElement()
			-- 						--group.list.content_array[1].selectElement()
			-- 						group.list.content_array.selectFirst()
			-- 						tutorialList.select(lastGroup, true)
			-- 						print(tutorialList.currentSelection, lastGroup)
			-- 						break
			-- 					end
			-- 				end
			-- 			end
			-- 		end
			-- 	end)
			-- end
	
			-- if tutorialList.currentSelection and _IDS[tutorialList.currentSelection.id] then
				
			-- end
	
			-- if groupId then
			-- 	this.journal_mc.tutorialContainer_mc.title_txt.htmlText = ""
			-- 	this.journal_mc.tutorialContainer_mc.desc_txt.htmlText = ""
			-- 	tutorialList.clearSelection()
			-- 	tutorialList.select(groupId)
			-- end
		end
	end
end, "After", "All")

Events.BeforeLuaReset:Subscribe(function ()
	tutorialIsDirty = true
end)

--The tutorial text doesn't scroll unfortunately, so we have to limit the list of changes for now.
Changelog:AddModEntry(Classes.TranslatedString:CreateFromKey("LeaderLib", "LeaderLib"), Classes.TranslatedString:CreateFromKey("LeaderLib_UI_Changelog", "<b><font size='24'>1.7.21.6</font></b><br><br>• Fixed an issue where object timer data wasn't being cleared (important bug to fix to prevent repeated timer results).<br>• (v56) Fixed an issue prevents world effects from working.<br>• Added a workaround for EsvZoneAction surfaces not dealing damage.<br><br>See the full changelog in the 'Change Notes' tab on the Steam Workshop page."))
-- Changelog:AddModEntry(Classes.TranslatedString:CreateFromKey("LeaderLib", "LeaderLib"), "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer eu nibh aliquam, lacinia tellus sed, imperdiet elit. Mauris ultricies nunc at tortor tristique porttitor. Nam orci est, varius iaculis laoreet vel, ultricies in nisi. Pellentesque nec scelerisque nisi. Ut molestie sagittis tempor. Sed tincidunt purus sit amet magna accumsan, ut sollicitudin felis elementum. Mauris posuere malesuada mattis. Duis maximus non massa eu sodales. Pellentesque nibh felis, pellentesque in mauris pretium, vulputate malesuada nunc. Maecenas eget lacinia ex. Integer nec dui vel massa gravida elementum eget nec massa. Aenean tincidunt non est a scelerisque. Nam eu enim mi.\n\nMauris molestie commodo leo quis ultrices. Quisque elementum felis et neque vestibulum scelerisque. Cras sodales felis lorem, vel tempus justo porttitor quis. Suspendisse potenti. Phasellus nisi leo, cursus sed lorem sit amet, semper consequat orci. Aliquam sagittis pellentesque libero et interdum. Sed iaculis facilisis velit, quis hendrerit libero dapibus auctor.\n\n<font color='#FFCC11'>Phasellus mi metus, congue a tincidunt eget, viverra ut lectus. Cras elit quam, fringilla in dui sit amet, tristique faucibus mauris. Ut bibendum rutrum sem, efficitur malesuada nunc euismod quis. Morbi eros leo, commodo quis aliquet eget, pretium sit amet diam. Nullam posuere augue vel ligula gravida fermentum. Proin a consequat risus. Integer ac ligula condimentum, pretium est ac, feugiat lorem. Sed suscipit ut neque vel facilisis. Nullam lobortis lacinia lacus a mattis. Maecenas eget mi fermentum, aliquet odio at, feugiat risus. Integer finibus vitae tortor sed tristique. Pellentesque pellentesque venenatis velit, sit amet euismod dui eleifend eget. Donec malesuada ex nisi, sit amet imperdiet ex scelerisque at.\n\nNulla eget dui sed nulla tempus interdum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Duis a lobortis lacus. Morbi neque nulla, rutrum sit amet leo ac, rutrum efficitur magna. Nulla odio nisi, dignissim a justo rutrum, malesuada eleifend lectus. Fusce nec cursus augue. Morbi at sem iaculis, eleifend libero vel, posuere velit.</font>\n\nMauris non justo nec justo congue laoreet. Maecenas porttitor magna at libero rhoncus bibendum. Phasellus vel sem cursus, semper erat quis, aliquet metus. Aenean quis metus egestas, ultrices velit in, molestie tellus. Etiam nec purus nec quam varius luctus. Nulla quis suscipit tellus, maximus accumsan felis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Sed viverra quis nisi sit amet luctus. Cras dapibus sodales mauris ut tristique. Aliquam orci purus, suscipit in porttitor nec, tincidunt eget lectus.")

UI.Changelog = Changelog