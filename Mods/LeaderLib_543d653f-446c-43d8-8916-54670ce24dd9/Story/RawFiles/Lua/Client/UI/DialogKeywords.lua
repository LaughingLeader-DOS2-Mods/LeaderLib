local DialogEx = {
	Active = false
}
DialogEx.__index = DialogEx

function DialogEx.OnUpdate(ui, event)
	local this = ui:GetRoot()
	local array = this.addTextArray
end

function DialogEx.OnSetPosition(ui, event, side1, side2, side3)
	DialogEx.Active = true
end

---@type UIObject
function DialogEx.OnTextHovered(ui, event, completeText, cursorCharacterIndex, globalX, globalY, name, dialogText, playerId, localX, localY)
	--ExternalInterface.call("dialogTextHovered", text_txt.htmlText, index, pt.x, pt.y, this.nametxt, this.dialogtxt, this.playerID, xCheck, yCheck);
	fprint(LOGLEVEL.TRACE, "event(%s) completeText(%s) cursorCharacterIndex(%s) globalX(%s) globalY(%s) name(%s) dialogText(%s) playerId(%s) localX(%s) localY(%s)", event, completeText, cursorCharacterIndex, globalX, globalY, name, dialogText, playerId, localX, localY)
	cursorCharacterIndex = cursorCharacterIndex + 1
	local checkKeyword = string.sub(completeText, math.max(0, cursorCharacterIndex-3), math.min(#completeText, cursorCharacterIndex+3))
	fprint(LOGLEVEL.TRACE, "checkKeyword(%s) char(%s)", checkKeyword, string.sub(completeText, cursorCharacterIndex, cursorCharacterIndex))
	if string.find(checkKeyword, "Red") then
		local x,y = UIExtensions.GetMousePosition()
		ui:ExternalInterfaceCall("showTooltip", "Super cool origin guy", globalX, globalY, 200, 100, "top", true)
	end
	DialogEx.Active = true
end

Ext.RegisterUITypeCall(Data.UIType.dialog, "dialogTextHovered", DialogEx.OnTextHovered)
Ext.RegisterUITypeCall(Data.UIType.dialog, "dialogTextHovered", DialogEx.OnTextHovered)
--Ext.RegisterUITypeInvokeListener(Data.UIType.dialog, "updateDialog", DialogEx.OnUpdate)
Ext.RegisterUITypeInvokeListener(Data.UIType.dialog, "setPosition", DialogEx.OnSetPosition)
Ext.RegisterUITypeInvokeListener(Data.UIType.hotBar, "showSkillBar", function(ui, method, b)
	if b then
		DialogEx.Active = false
	end
end)

function DialogEx.OnMouseMoved(event, x, y)
	if DialogEx.Active then
		print(event, x, y)
	end
end

Input.RegisterMouseListener(UIExtensions.MouseEvent.Moved, DialogEx.OnMouseMoved)

Ext.AddPathOverride("Public/Game/GUI/dialog.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/dialog.swf")