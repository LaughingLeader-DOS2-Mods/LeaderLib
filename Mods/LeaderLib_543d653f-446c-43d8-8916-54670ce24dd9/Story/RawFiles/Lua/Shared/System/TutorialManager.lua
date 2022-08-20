local isClient = Ext.IsClient()

if isClient and Ext.Utils.Version() >= 56 then
	TutorialBox = Classes.UIWrapper:CreateFromType(Data.UIType.tutorialBox, {ControllerID=Data.UIType.tutorialBox_c, IsControllerSupported=true})

	---@param category string
	---@param titleText string
	---@param tutorialText string
	---@param x number
	---@param y number
	function TutorialBox:CreateTutorial(category, titleText, tutorialText, x, y)
		local ui = self.Instance
		if ui then
			local this = ui:GetRoot()
			local hasInputFlag = false
			local hasModalFlag = false
			for i,flag in pairs(ui.Flags) do
				if not hasInputFlag and string.find(flag, "PlayerInput") then
					hasInputFlag = true
				end
				if not hasModalFlag and string.find(flag, "PlayerModal") then
					hasModalFlag = true
				end
			end
			if not hasInputFlag then
				table.insert(ui.Flags, "OF_PlayerInput1")
			end
			if not hasModalFlag then
				table.insert(ui.Flags, "OF_PlayerModal1")
			end
			this.setWindow(1920.0, 825.0)
			--[fadeInModal(method)] ("Character Creation", "Character Creation", "Welcome to the <font color="70b10e">Character Creation</font> Screen! Here, you can select an <font color="70b10e">Origin character</font> or create a <font color="70b10e">custom hero</font>.", 640.0, 510.0)
			--[fadeInNonModalPointer(method)] ("Select your origin <font color="008858">instrument</font>. It will take the lead in the music during fights and will <font color="008858">highlight</font> various moments of your adventure.", 1571.0, 352.0, 1.0)
			--[fadeInModal(method)] ("Stats", "Tags", "Tags determine what options are available to you in dialogue and how the world reacts to your party members. <font color="008858">Custom characters</font> have race, gender, and background tags. <font color="008858">Origin characters</font> have unique origin tags.", 640.0, 510.0)

			this.fadeInModal(category, titleText, tutorialText, x, y)
			ui:Show()
		end
	end
end