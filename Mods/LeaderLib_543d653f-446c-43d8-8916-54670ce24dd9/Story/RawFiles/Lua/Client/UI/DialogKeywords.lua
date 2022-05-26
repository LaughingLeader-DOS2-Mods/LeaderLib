local DialogEx = {
	Active = false,
	HasTooltip = false,
}
DialogEx.__index = DialogEx

local keywordsTest = {
	["Mods"] = "Mods are tools that make the game better.",
	["The Red Prince"] = "Super cool origin guy.",
}

---@class KeywordData:table
---@field StartPos integer
---@field EndPos integer
---@field Tooltip string

---@type table<string, KeywordData>
local keywordPositions = {}

function DialogEx.OnUpdate(ui, event)
	keywordPositions = {}
	--local this = ui:GetRoot()
	-- local array = this.addTextArray
	-- for i=0,#array,4 do
	-- 	local name = array[i]
	-- 	local icon = array[i+1]
	-- 	local dialogText = array[i+2]
	-- 	local someType = array[i+3]

	-- 	local completeText = string.format("%s - %s", name, dialogText)
	-- end
end

function DialogEx.FindKeywords(ui, event, text)
	for k,v in pairs(keywordsTest) do
		for match in string.gmatch(text, k) do
			local startPos,endPos = string.find(text, k, 1, true)
			if startPos and endPos then
				keywordPositions[k] = {
					StartPos = startPos,
					EndPos = endPos,
					Tooltip = v
				}
			end
		end
	end
	Ext.Print(event, Common.JsonStringify(keywordPositions))
end

function DialogEx.OnSetPosition(ui, event, side1, side2, side3)
	DialogEx.Active = true
end

---@type UIObject
function DialogEx.OnTextHovered(ui, event, completeText, cursorCharacterIndex, globalX, globalY, name, dialogText, playerId, localX, localY)
	--ExternalInterface.call("dialogTextHovered", text_txt.htmlText, index, pt.x, pt.y, this.nametxt, this.dialogtxt, this.playerID, xCheck, yCheck);
	fprint(LOGLEVEL.TRACE, "event(%s) completeText(%s) cursorCharacterIndex(%s) globalX(%s) globalY(%s) name(%s) dialogText(%s) playerId(%s) localX(%s) localY(%s)", event, completeText, cursorCharacterIndex, globalX, globalY, name, dialogText, playerId, localX, localY)
	cursorCharacterIndex = cursorCharacterIndex + 1
	for keyword,data in pairs(keywordPositions) do
		if cursorCharacterIndex >= data.StartPos and cursorCharacterIndex <= data.EndPos then
			ui:ExternalInterfaceCall("showTooltip", data.Tooltip, globalX, globalY, 200, 100, "top", true)
			DialogEx.HasTooltip = true
		end
	end
	-- local checkKeyword = string.sub(completeText, math.max(0, cursorCharacterIndex-3), math.min(#completeText, cursorCharacterIndex+3))
	-- fprint(LOGLEVEL.TRACE, "checkKeyword(%s) char(%s)", checkKeyword, string.sub(completeText, cursorCharacterIndex, cursorCharacterIndex))
	-- if string.find(checkKeyword, "Red") then
	-- 	ui:ExternalInterfaceCall("showTooltip", "Super cool origin guy", globalX, globalY, 200, 100, "top", true)
	-- end
	DialogEx.Active = true
end

function DialogEx.OnHoverCleared(ui, call)
	if DialogEx.HasTooltip then
		ui:ExternalInterfaceCall("hideTooltip")
		DialogEx.HasTooltip = false
	end
end

Ext.RegisterUITypeCall(Data.UIType.dialog, "dialogTextHovered", DialogEx.OnTextHovered)
Ext.RegisterUITypeCall(Data.UIType.dialog, "dialogTextHoverCleared", DialogEx.OnHoverCleared)
Ext.RegisterUITypeCall(Data.UIType.dialog, "dialogTextFormatted", DialogEx.FindKeywords)
Ext.RegisterUITypeInvokeListener(Data.UIType.dialog, "updateDialog", DialogEx.OnUpdate)
Ext.RegisterUITypeInvokeListener(Data.UIType.dialog, "setPosition", DialogEx.OnSetPosition)
Ext.RegisterUITypeInvokeListener(Data.UIType.hotBar, "showSkillBar", function(ui, method, b)
	if b then
		DialogEx.Active = false
	end
end)

function DialogEx.OnMouseMoved(event, x, y)
	if DialogEx.Active and Vars.LeaderDebugMode then
		Ext.Print(event, x, y)
	end
end

Input.RegisterMouseListener(UIExtensions.MouseEvent.Moved, DialogEx.OnMouseMoved)

--Ext.AddPathOverride("Public/Game/GUI/dialog.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/Overrides/dialog.swf")